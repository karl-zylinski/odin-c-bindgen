// This file "collects" information from the headers we are creating bindings for, using libclang.
//
// It tries to do as little processing of the information as possible. It is usually good to first
// collect all information and then process it, as you otherwise get issues with knowing if
// something has already been declared etc. The processing happens in `translate_process.odin` and
// and `translate_macros.odin`.
#+private file
#+feature dynamic-literals
package bindgen2

import clang "../libclang"
import "core:slice"
import "core:log"
import "core:strings"
import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"
import "core:fmt"

// Return value of `translate_collect`. It's not all that proc returns however, it also writes into
// its `types` and `decls` parameters.
@(private="package")
Translate_Collect_Result :: struct {
	source: string,
	extra_imports: []string,
	macros: []Raw_Macro,
}

// Parses the C headers and "collects" the things we need from them. This file avoids doing any
// further processing, that is deferred to `translate_macros` and `translate_process`.
@(private="package", require_results)
translate_collect :: proc(filename: string, config: Config, types: Type_List, decls: Decl_List) -> (Translate_Collect_Result, bool) {
	clang_version := string_from_clang_string(clang.getClangVersion())
	clang_version = strings.trim_prefix(clang_version, "clang version ")
	clang_version_major_end := strings.index_rune(clang_version, '.')

	if clang_version_major_end == -1 {
		log.panic("Failed checking libclang version")
	}

	clang_major_version_str := clang_version[:clang_version_major_end]

	if clang_major_version, clang_major_version_ok := strconv.parse_int(clang_major_version_str);
		clang_major_version_ok && clang_major_version < 16 {
		log.panic("libclang version 16 or newer is required")
	}

	clang_args: [dynamic]cstring
	// This makes sure we get comments in the clang AST.
	append(&clang_args, "-fparse-all-comments")
	// Strict mode: warn about undefined/implicit types
	append(&clang_args, "-Wimplicit")

	for &include in config.clang_include_paths {
		append(&clang_args, fmt.ctprintf("-I%v", include))
	}

	for k, v in config.clang_defines {
		append(&clang_args, fmt.ctprintf("-D%s=%s", k, v))
	}

	// Clang uses 1 and 0 instead of true and false. The index is a set of translation units.
	//
	// TODO: Should all bindings created into a single directory use the same index, so they can
	// see things between them?
	index := clang.createIndex(1, 0)

	unit: clang.Translation_Unit

	options: clang.Translation_Unit_Flags = {
		.DetailedPreprocessingRecord, // Keep macros.
		.SkipFunctionBodies,
		.KeepGoing, // Keep going on errors.
	}

	filename_cstr := to_cstring(filename)

	// This makes an Abstract Syntax Tree (AST) that can be browsed using the libclang API.
	err := clang.parseTranslationUnit2(
		index,
		filename_cstr,
		raw_data(clang_args),
		i32(len(clang_args)),
		nil,
		0,
		options,
		&unit,
	)

	if err != .Success {
		log.errorf("Failed to parse translation unit for %s. Error code: %v", filename, err)
		return {}, false
	}

	// Check for diagnostics (errors and such).
	for i in 0 ..< clang.getNumDiagnostics(unit) {
		diag := clang.getDiagnostic(unit, i)
		severity := clang.getDiagnosticSeverity(diag)
		diag_message := string_from_clang_string(clang.formatDiagnostic(diag, clang.defaultDiagnosticDisplayOptions()))

		log_level: log.Level
		switch severity {
		case .Ignored:
			log_level = .Debug
		case .Note:
			log_level = .Info
		case .Warning:
			log_level = .Warning
		case .Error:
			log_level = .Error
		case .Fatal:
			log_level = .Fatal
		}
		log.log(log_level, diag_message)

		clang.disposeDiagnostic(diag)
	}

	file := clang.getFile(unit, filename_cstr)
	root_cursor := clang.getTranslationUnitCursor(unit)
	source_size: uint
	source := clang.getFileContents(unit, file, &source_size)

	tcs := Translate_Collect_State {
		// The source is used to extract some comments in `translate_process`. Clang fails to
		// include some comments.
		source = strings.string_from_ptr((^u8)(source), int(source_size)),
		translation_unit = unit,
		types = types,
		decls = decls,
	}

	// I dislike visitors. They make the code hard to read. So I build a map of all parents and
	// children. That way we can use this lookup to find arrays of children and iterate them normally.
	//
	// Also, the combination of Odin + C visitors is annoying because the context isn't passed
	// along, making it even worse.
	build_cursor_children_lookup(root_cursor, &tcs.children_lookup)

	root_children := tcs.children_lookup[root_cursor]

	for c in root_children {
		loc := get_cursor_location(c)

		if clang.File_isEqual(file, loc.file) == 0 {
			continue
		}

		create_declaration(c, &tcs)
	}

	extra_imports, extra_imports_err := slice.map_keys(tcs.extra_imports)
	assert(extra_imports_err == nil)

	return {
		source = tcs.source,
		extra_imports = extra_imports,
		macros = tcs.macros[:],
	}, true
}

Cursor_Children_Map :: map[clang.Cursor][]clang.Cursor

// Convenient blob to pass around within this file, instead of lots of procs params.
Translate_Collect_State :: struct {
	decls: Decl_List,
	type_lookup: map[clang.Type]Type_Index,
	types: Type_List,
	children_lookup: Cursor_Children_Map,
	source: string,
	extra_imports: map[string]bool,
	macros: [dynamic]Raw_Macro,
	translation_unit: clang.Translation_Unit,
}

// Recursive proc to visit everthing in AST and make a handy lookup so we don't have to use
// visitor callbacks later.
build_cursor_children_lookup :: proc(c: clang.Cursor, res: ^Cursor_Children_Map) {
	Build_Children_State :: struct {
		res: ^Cursor_Children_Map,
		children: [dynamic]clang.Cursor,
	}

	bcs := Build_Children_State {
		res = res,
	}

	clang.visitChildren(c, curstor_iterator_iterate, &bcs)

	curstor_iterator_iterate: clang.Cursor_Visitor : proc "c" (
		cursor, parent: clang.Cursor,
		state: clang.Client_Data,
	) -> clang.Child_Visit_Result {
		context = gen_ctx
		bcs := (^Build_Children_State)(state)
		append(&bcs.children, cursor)
		build_cursor_children_lookup(cursor, bcs.res)
		return .Continue
	}

	res[c] = bcs.children[:]
}

// Finds things such as procs and struct declarations and stores them in `tcs.decls`. Recursive.
// Also runs `create_type_recursive` which will fill out `tcs.types`.
create_declaration :: proc(c: clang.Cursor, tcs: ^Translate_Collect_State) {
	name := get_cursor_name(c)
	comment_before := string_from_clang_string(clang.Cursor_getRawCommentText(c))
	line := get_cursor_location(c).line

	// When the cursor is actually defined somewhere else in the file. Used later to resolve
	// forward declarations.
	is_forward_declare := clang.isCursorDefinition(c) == 0

	// Comments on the right side of the line aren't picked up by clang. So we extract them manually.
	side_comment: string
	side_comment_align_whitespace: int
	{
		source_range := clang.getCursorExtent(c)

		start := clang.getRangeStart(source_range)
		start_offset: u32
		clang.getExpansionLocation(start, nil, nil, nil, &start_offset)
		end := clang.getRangeEnd(source_range)
		end_offset: u32
		clang.getExpansionLocation(end, nil, nil, nil, &end_offset)
		side_comment, side_comment_align_whitespace = find_comment_at_line_end(tcs.source[start_offset:])
	}

	ct := clang.getCursorType(c)

	#partial switch c.kind {
	// Struct and union is the same, only difference is that the `Type_Struct` will get `raw_union`
	// set to true.
	case .StructDecl, .UnionDecl:
		ti := create_type_recursive(ct, tcs)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		if clang.Cursor_isAnonymous(c) == 0 {
			add_decl(tcs.decls, {
				comment_before = comment_before,
				def = ti,
				name = name,
				original_line = line,
				side_comment = side_comment,
				is_forward_declare = is_forward_declare,
			})
		}

		children := tcs.children_lookup[c]

		for cc in children {
			create_declaration(cc, tcs)
		}

	case .TypedefDecl:
		ti := create_type_recursive(ct, tcs)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		add_decl(tcs.decls, {
			comment_before = comment_before,
			def = ti,
			name = name,
			original_line = line,
			side_comment = side_comment,
			is_forward_declare = is_forward_declare,
		})
		
	case .EnumDecl:
		ti := create_type_recursive(ct, tcs)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		if clang.Cursor_isAnonymous(c) == 1 {
			e, is_enum := tcs.types[ti].(Type_Enum)

			if is_enum {
				for &m in e.members {
					add_decl(tcs.decls, {
						name = m.name,
						def = Fixed_Value(fmt.tprint(m.value)),
						original_line = line,

						// It's not really from a macro, but it's probably best if it behaves as if.
						from_macro = true,
					})
				}
			}
			return
		}

		add_decl(tcs.decls, {
			comment_before = comment_before,
			def = ti,
			name = name,
			original_line = line,
			side_comment = side_comment,
			is_forward_declare = is_forward_declare,
		})
		
	case .FunctionDecl:
		if clang.Cursor_isFunctionInlined(c) == 1 {
			return
		}

		ti := create_proc_type(tcs.children_lookup[c], ct, tcs)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		add_decl(tcs.decls, {
			comment_before = comment_before,
			def = ti,
			name = name,
			original_line = line,
			side_comment = side_comment,
			is_forward_declare = is_forward_declare,
		})

	case .MacroDefinition:
		if clang.Cursor_isMacroBuiltin(c) == 1 {
			return
		}

		source_range := clang.getCursorExtent(c)

		start := clang.getRangeStart(source_range)
		start_offset: u32
		clang.getExpansionLocation(start, nil, nil, nil, &start_offset)
		end := clang.getRangeEnd(source_range)
		end_offset: u32
		clang.getExpansionLocation(end, nil, nil, nil, &end_offset)
		macro_source := tcs.source[start_offset:end_offset]

		whitespace_after_name: int
		first_space_seen := false
		name_end: int

		for c, i in macro_source {
			if unicode.is_white_space(c) {
				if !first_space_seen {
					first_space_seen = true
					name_end = i
				}

				whitespace_after_name += 1
			} else {
				if first_space_seen {
					break
				}
			}
		}

		comment := find_comment_before(tcs.source, '#', int(start_offset))

		clang_tokens: [^]clang.Token
		clang_token_count: u32
		clang.tokenize(tcs.translation_unit, source_range, &clang_tokens, &clang_token_count)

		if clang_token_count > 1 {
			tokens := make([]Raw_Macro_Token, clang_token_count - 1)

			for i in 1..<clang_token_count {
				val := string_from_clang_string(clang.getTokenSpelling(tcs.translation_unit, clang_tokens[i]))
				kind: Raw_Macro_Token_Kind

				#partial switch clang.getTokenKind(clang_tokens[i]) {
				case .Punctuation: kind = .Punctuation
				case .Keyword: kind = .Keyword
				case .Identifier: kind = .Identifier
				case .Literal: kind = .Literal
				}

				tokens[i - 1] = {
					value = val,
					kind = kind,
				}
			}

			append(&tcs.macros, Raw_Macro {
				name = name,
				is_function_like = clang.Cursor_isMacroFunctionLike(c) == 1,
				tokens = tokens,
				comment = comment,
				side_comment = side_comment,
				whitespace_before_side_comment = side_comment_align_whitespace,
				whitespace_after_name = whitespace_after_name,
				original_line = line,
			})
		}
	}
}

find_comment_before :: proc(src: string, start_rune: rune, start_offset: int) -> string {
	Find_Comment_State :: enum {
		Looking_For_Start,
		Looking_For_Comment,
		Looking_For_Single_Line_Start,
		Verifying_Single_Line,
		Inside_Block_Comment,
	}

	find_state: Find_Comment_State
	comment_start := -1
	comment_end: int

	comment_loop: for i := start_offset; i >= 0; {
		c := utf8.rune_at(src, i)
		defer i -= utf8.rune_size(c)
		switch find_state {
		case .Looking_For_Start:
			if c == start_rune {
				comment_end = i
				find_state = .Looking_For_Comment
				break
			}

			if c == '\n' {
				break comment_loop
			}
		case .Looking_For_Comment:
			if unicode.is_white_space(c) {
				break
			}

			if c == '/' && i > 1 && src[i - 1] == '*' {
				find_state = .Inside_Block_Comment
				break
			}

			// TODO: Special case when line only is `//`

			find_state = .Looking_For_Single_Line_Start
		case .Looking_For_Single_Line_Start:
			if c == '\n' {
				break comment_loop
			}

			if c == '/' && i < len(src) - 1 && src[i + 1] == '/' {
				find_state = .Verifying_Single_Line
				break
			}

		case .Verifying_Single_Line:
			if c == '\n' {
				comment_start = i
				find_state = .Looking_For_Comment
				break
			}

			if c == '/' && ((i > 0 && src[i - 1] == '/') || (i < len(src)-1 && src[i + 1] == '/')) {
				break
			}

			if !unicode.is_white_space(c) {
				break comment_loop
			}
		case .Inside_Block_Comment:
			if c == '/' && i < len(src) - 1 && src[i + 1] == '*' {
				find_state = .Verifying_Single_Line
				break
			}
		}
	}

	if comment_start != -1 && comment_end > comment_start {
		return strings.trim_space(src[comment_start:comment_end])
	}

	return ""
}

find_comment_at_line_end :: proc(str: string) -> (string, int) {
	space_before_comment: int
	comment_start: int
	block_comment: bool

	for c, i in str {
		if c == ' ' {
			space_before_comment += 1
		} else if c == '/' && i + 1 < len(str) && str[i + 1] == '/' {
			comment_start = i
			break
		} else if c == '/' && i + 1 < len(str) && str[i + 1] == '*' {
			comment_start = i
			block_comment = true
			break
		} else if c == '\n' {
			break
		} else {
			space_before_comment = 0
		}
	}

	if comment_start == 0 {
		return "", 0
	}

	if block_comment {
		from_start := str[comment_start:]

		for c, i in from_start {
			if c == '*' && i < len(from_start) - 1 && from_start[i + 1] == '/' {
				return from_start[:i+2], space_before_comment
			}
		}
	} else {
		from_start := str[comment_start:]

		for c, i in from_start {
			if c == '\n' {
				return from_start[:i], space_before_comment
			}
		}
	}

	return "", 0
}

type_probably_is_cstring :: proc(ct: clang.Type) -> bool {
	if ct.kind != .Pointer {
		return false
	}

	pt := clang.getPointeeType(ct)

	return (pt.kind == .Char_S || pt.kind == .SChar)
}

get_type_name_or_create_anon_type :: proc(ct: clang.Type, tcs: ^Translate_Collect_State) -> Definition {
	#partial switch ct.kind {
	case .Void:
		return Fixed_Value("struct {}")
	case .Bool:
		return Fixed_Value("bool")
	case .Char_U, .UChar:
		return Fixed_Value("u8")
	case .UShort:
		return Fixed_Value("u16")
	case .UInt:
		return Fixed_Value("u32")
	case .ULong:
		tcs.extra_imports["core:c"] = true
		return Fixed_Value("c.ulong")
	case .ULongLong:
		return Fixed_Value("u64")
	case .UInt128:
		return Fixed_Value("u128")
	case .Char_S, .SChar:
		return Fixed_Value("i8")
	case .Short:
		return Fixed_Value("i16")
	case .Int:
		return Fixed_Value("i32")
	case .Long:
		tcs.extra_imports["core:c"] = true
		return Fixed_Value("c.long")
	case .LongLong:
		return Fixed_Value("i64")
	case .Int128:
		return Fixed_Value("i128")
	case .Float:
		return Fixed_Value("f32")
	case .Double, .LongDouble:
		return Fixed_Value("f64")
	case .NullPtr:
		return Fixed_Value("rawptr")
	case .WChar:
		tcs.extra_imports["core:c"] = true
		return Fixed_Value("c.wchar_t")

	case .Record, .Enum:
		ctc := clang.getTypeDeclaration(ct)
		if clang.Cursor_isAnonymous(ctc) == 0 {
			return Type_Name(get_cursor_name(ctc))
		}

	case .Typedef:
		ctc := clang.getTypeDeclaration(ct)
		if clang.Cursor_isAnonymous(ctc) == 0 {
			name := get_cursor_name(ctc)

			if replacement, has_replacement := c_type_mapping[name]; has_replacement {
				if strings.has_prefix(replacement, "c.") {
					tcs.extra_imports["core:c"] = true
				} else if strings.has_prefix(replacement, "libc.") {
					tcs.extra_imports["core:c/libc"] = true
				} if strings.has_prefix(replacement, "posix.") {
					tcs.extra_imports["core:sys/posix"] = true
				}
				return Fixed_Value(replacement)
			}

			return Type_Name(name)
		}

	case .Elaborated:
		return get_type_name_or_create_anon_type(clang.Type_getNamedType(ct), tcs)
	}

	// No name found! Create a real type definition (used by anonymous types etc)
	return create_type_recursive(ct, tcs)
}

is_fixed_array :: proc(ct: clang.Type) -> bool {
	ct := ct

	if ct.kind == .Elaborated {
		ct = clang.Type_getNamedType(ct)
	}

	if ct.kind == .ConstantArray {
		return true
	}

	if ct.kind == .Typedef {
		underlying := clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(ct))

		if underlying.kind == .ConstantArray {
			return true
		}
	}

	return false
}

// This is a separate proc because we call it both from create_type_recursive and from
// create_declaration. It's used in create_declaration so we get a unique proc type per proc.
// Otherwise the FunctionProto stuff may make it so that there are shared proc types, which will
// break stuff.
create_proc_type :: proc(param_childs: []clang.Cursor, ct: clang.Type, tcs: ^Translate_Collect_State) -> Type_Index {
	ct := ct
	root_type := reserve_type(ct, tcs)
	proc_type := root_type

	for ct.kind == .Pointer {
		ct = clang.getPointeeType(ct)
		nested_type := reserve_type(ct, tcs)
		tcs.types[proc_type] = Type_Pointer {
			pointed_to_type = nested_type,
		}
		proc_type = nested_type
	}

	params: [dynamic]Type_Procedure_Parameter

	if len(param_childs) > 0 {
		for child in param_childs {
			if child.kind != .ParmDecl {
				continue
			}

			param_type := clang.getCursorType(child)
			name := get_cursor_name(child)

			type_id: Definition

			if unwrapped_type, is_proc := unwrap_proc_pointers(param_type); is_proc {
				type_id = create_proc_type(tcs.children_lookup[child], unwrapped_type, tcs)
			} else {
				type_id = get_type_name_or_create_anon_type(unwrapped_type, tcs)

				// Fixed arrays are passed by pointer into procs. That's how it works in C. I.e.
				// `float numbers[2]` as a function parameter is equivalent to `float *numbers`, but
				// you have that `2` there for documentation purposes. So by default we turn such
				// a parameter into `numbers: ^[2]f32`.
				if is_fixed_array(param_type) {
					wrapper_idx := Type_Index(len(tcs.types))
					append_nothing(tcs.types)
					tcs.types[wrapper_idx] = Type_Pointer {
						pointed_to_type = type_id,
					}
					type_id = wrapper_idx
				}
			}

			append(&params, Type_Procedure_Parameter {
				name = name,
				type = type_id,
			})
		}
	} else {
		num_args := clang.getNumArgTypes(ct)
		for i in 0..<num_args {
			param_type := clang.getArgType(ct, u32(i))

			append(&params, Type_Procedure_Parameter {
				type = get_type_name_or_create_anon_type(param_type, tcs),
			})
		}
	}

	result_ct := clang.getResultType(ct)
	result_type_id: Definition

	if result_ct.kind != .Void {
		result_type_id = get_type_name_or_create_anon_type(result_ct, tcs)
	}

	calling_conv := Calling_Convention.C

	#partial switch clang.getFunctionTypeCallingConv(ct) {
	case .X86StdCall:
		calling_conv = .Std_Call
	case .X86FastCall:
		calling_conv = .Fast_Call
	}

	type_definition := Type_Procedure {
		parameters = params[:],
		result_type = result_type_id,
		calling_convention = calling_conv,

		// Zero length params and variadic isn't really a usable combination. Just pretend it isn't
		// variadic in that case.
		is_variadic = len(params) > 0 && clang.isFunctionTypeVariadic(ct) == 1,
	}

	tcs.types[proc_type] = type_definition
	return root_type
}

reserve_type :: proc(ct: clang.Type, tcs: ^Translate_Collect_State) -> Type_Index {
	idx := Type_Index(len(tcs.types))
	append_nothing(tcs.types)
	tcs.type_lookup[ct] = idx
	return idx
}

// In Odin, every proc is a pointer, and it is like that in C bindings too. So if something takes a
// ptr to a func in C, then it should just take a proc in Odin. In other words, we need to bypass
// one level of pointers whenever the thing we are looking at ends in a function.
unwrap_proc_pointers :: proc(t: clang.Type) -> (unwrapped_type: clang.Type, is_proc: bool) {
	if t.kind == .Pointer {
		first_pointee := clang.getPointeeType(t)
		pointee := first_pointee

		// We loop here so 'some_func_type**' just becomes 'some_func_type*'. We need to find if the
		// chain of pointers end i function type. But we need to discard the first level of pointer
		// indirection.
		for pointee.kind != .Invalid {
			if pointee.kind == .FunctionProto || pointee.kind == .FunctionNoProto {
				return first_pointee, true
			} else if pointee.kind == .Elaborated {
				named := clang.Type_getNamedType(pointee)

				if named.kind == .FunctionProto || named.kind == .FunctionNoProto {
					return first_pointee, true
				} else if named.kind == .Typedef {
					underlying := clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(pointee))

					if underlying.kind == .FunctionProto || underlying.kind == .FunctionNoProto {
						return first_pointee, false
					}
				}
			} 

			pointee = clang.getPointeeType(pointee)
		}
	}

	return t, (t.kind == .FunctionProto || t.kind == .FunctionNoProto)
}

// Used to create entries in `tcs.types` given a `clang.Type`. Has a lookup so that types can refer
// to other types. This makes it possible to create types such as `^^Some_Struct` where everyone
// sees the same type `Some_Struct`.
create_type_recursive :: proc(ct: clang.Type, tcs: ^Translate_Collect_State) -> Type_Index {
	if t_idx, has_t_idx := tcs.type_lookup[ct]; has_t_idx {
		return t_idx
	}

	// Anonymous types are those that do not end up in `type_lookup`. They can never be referred to
	// other than by the thing that calls this proc. Used for inline type definitions.
	add_anonymous_type :: proc(t: Type, types: ^[dynamic]Type) -> Type_Index {
		idx := Type_Index(len(types))
		append(types, t)
		return idx
	}

	#partial switch ct.kind {
	case .Pointer:
		clang_pointee_type := clang.getPointeeType(ct)

		// The current type is a pointer. Here we do some special cases for void pointers and
		// string-like things. This makes `void*` become `rawptr` etc.

		if clang_pointee_type.kind == .Void {
			idx := reserve_type(ct, tcs)
			tcs.types[idx] = Type_Raw_Pointer{}
			return idx
		} else if type_probably_is_cstring(ct) {
			idx := reserve_type(ct, tcs)
			tcs.types[idx] = Type_CString{}
			return idx
		} else if clang_pointee_type.kind == .FunctionProto {
			// In Odin a function pointer type should be just `proc`, not `^proc`. This is because
			// all procs in Odin are pointers.
			return create_proc_type(tcs.children_lookup[clang.getTypeDeclaration(clang_pointee_type)], clang_pointee_type, tcs)
		} else {
			ptr_type_idx := reserve_type(ct, tcs)
			pointing_to_id := get_type_name_or_create_anon_type(clang_pointee_type, tcs)
			tcs.types[ptr_type_idx] = Type_Pointer { pointed_to_type = pointing_to_id }
			return ptr_type_idx
		}

	// Structs and raw unions
	case .Record:
		c := clang.getTypeDeclaration(ct)
		struct_type_idx := reserve_type(ct, tcs)
		struct_children := tcs.children_lookup[c]
		fields: [dynamic]Type_Struct_Field
		prev_named_field := -1

		for sc in struct_children {
			sc_kind := clang.getCursorKind(sc)

			#partial switch sc_kind {
			case .FieldDecl:
				sct := clang.getCursorType(sc)
				type_id: Definition

				// Check if field is function pointer. In that case create the proc type directly,
				// bypassing one level of pointerness.
				if unwrapped_type, is_proc := unwrap_proc_pointers(sct); is_proc {
					type_id = create_proc_type(tcs.children_lookup[sc], unwrapped_type, tcs)
				} else {
					type_id = get_type_name_or_create_anon_type(unwrapped_type, tcs)
				}

				name := get_cursor_name(sc)
				
				if type_id == nil {
					log.errorf("Unresolved struct field type: %v", sc)
				}

				field_loc := get_cursor_location(sc)

				comment_before := find_comment_before(tcs.source, '\n', field_loc.offset)
				comment_on_right, _ := find_comment_at_line_end(tcs.source[field_loc.offset:])

				if prev_named_field >= 0 && prev_named_field == len(fields) - 1 &&
				fields[prev_named_field].type == type_id && field_loc.line == fields[prev_named_field].line {
					append(&fields[prev_named_field].names, name)
				} else {
					prev_named_field = len(fields)
					append(&fields, Type_Struct_Field {
						names = [dynamic]string { name },
						type = type_id,
						comment_before = comment_before,
						comment_on_right = comment_on_right,
						line = field_loc.line,
					})
				}
			
			// This is for fields that are anonymous struct types. Note that there are Record,
			// StructDecl and UnionDecl. Record is the cursor kind used for struct or union types.
			// StructDecl and UnionDecl are the cursor kinds for the declarations themselves. I.e.
			// named things in the file. However, there can be unnamed decls as we see here, which
			// happens when we have this kind of anonymous struct types. 
			case .StructDecl, .UnionDecl:
				if clang.Cursor_isAnonymousRecordDecl(sc) == 1 {
					sct := clang.getCursorType(sc)
					type_id := get_type_name_or_create_anon_type(sct, tcs)

					field_loc := get_cursor_location(sc)
					comment_loc := get_comment_location(sc)

					comment := string_from_clang_string(clang.Cursor_getRawCommentText(sc))
					comment_before: string
					comment_on_right: string

					if field_loc.line == comment_loc.line {
						comment_on_right = comment
					} else {
						comment_before = comment
					}

					append(&fields, Type_Struct_Field {
						anonymous = true,
						type = type_id,
						comment_before = comment_before,
						comment_on_right = comment_on_right,
					})
				}
			}
		}

		type_definition := Type_Struct {
			fields = fields[:],
			raw_union = c.kind == .UnionDecl,
		}

		tcs.types[struct_type_idx] = type_definition

		return struct_type_idx
	case .Enum:
		enum_type_idx := reserve_type(ct, tcs)
		c := clang.getTypeDeclaration(ct)
		enum_children := tcs.children_lookup[c]
		members: [dynamic]Type_Enum_Member
		backing_type := clang.getEnumDeclIntegerType(c)
		is_unsigned_type := backing_type.kind >= .Char_U && backing_type.kind <= .UInt128

		for ec in enum_children {
			member_name := get_cursor_name(ec)
			value := is_unsigned_type ? int(clang.getEnumConstantDeclUnsignedValue(ec)) : int(clang.getEnumConstantDeclValue(ec))
			cursor_loc := get_cursor_location(ec)

			comment_before := find_comment_before(tcs.source, '\n', cursor_loc.offset)
			comment_on_right, _ := find_comment_at_line_end(tcs.source[cursor_loc.offset:])

			append(&members, Type_Enum_Member {
				name = member_name,
				value = value,
				comment_before = comment_before,
				comment_on_right = comment_on_right,
			})
		}

		storage_type: typeid = i32

		#partial switch backing_type.kind {
			case .Char_U:
				storage_type = u8
			case .UChar:
				storage_type = u8
			case .Char16:
				storage_type = i16
			case .Char32:
				storage_type = i32
			case .UShort:
				storage_type = u16
			case .UInt:
				storage_type = u32
			case .ULong:
				storage_type = u32
			case .ULongLong:
				storage_type = u64
			case .UInt128:
				storage_type = u128
			case .Char_S:
				storage_type = i8
			case .SChar:
				storage_type = i8
			case .Short:
				storage_type = i16
			case .Int:
				storage_type = i32
			case .Long:
				storage_type = i32
			case .LongLong:
				storage_type = i64
			case .Int128:
				storage_type = i128
		}	

		type_definition := Type_Enum {
			storage_type = storage_type,
			members = members[:],
		}

		tcs.types[enum_type_idx] = type_definition
		return enum_type_idx

	case .Elaborated:
		// Just return the type index here so we "short circuit" past `struct S` etc
		named_type := clang.Type_getNamedType(ct)
		elaborated_type_idx := create_type_recursive(named_type, tcs)
		tcs.type_lookup[ct] = elaborated_type_idx
		return elaborated_type_idx
	case .Typedef:
		alias_type_idx := reserve_type(ct, tcs)
		c := clang.getTypeDeclaration(ct)
		underlying := clang.getTypedefDeclUnderlyingType(c)
		type_id: Definition

		if unwrapped_type, is_proc := unwrap_proc_pointers(underlying); is_proc {
			type_id = create_proc_type(tcs.children_lookup[c], unwrapped_type, tcs)
		} else {
			type_id = get_type_name_or_create_anon_type(unwrapped_type, tcs)
		}

		type_definition := Type_Alias {
			aliased_type = type_id,
		}

		tcs.types[alias_type_idx] = type_definition

		return alias_type_idx
	case .ConstantArray:
		// For fixed size arrays. 
		array_type_idx := reserve_type(ct, tcs)
		clang_element_type := clang.getArrayElementType(ct)

		type_definition := Type_Fixed_Array {
			element_type = get_type_name_or_create_anon_type(clang_element_type, tcs),
			size = int(clang.getArraySize(ct)),
		}

		tcs.types[array_type_idx] = type_definition

		return array_type_idx

	case .IncompleteArray:
		// For arrays that don't have a specified size. This is actually just an array in C. But the
		// array-ness of hints that this should be a multi pointer.
		array_type_idx := reserve_type(ct, tcs)
		clang_element_type := clang.getArrayElementType(ct)

		type_definition := Type_Multipointer {
			pointed_to_type = get_type_name_or_create_anon_type(clang_element_type, tcs),
		}

		tcs.types[array_type_idx] = type_definition

		return array_type_idx

	case .FunctionProto, .FunctionNoProto:
		return create_proc_type({}, ct, tcs)
	}

	//log.error("Unknown type")
	return TYPE_INDEX_NONE
}

get_cursor_name :: proc(cursor: clang.Cursor) -> string {
	return string_from_clang_string(clang.getCursorSpelling(cursor))
}

get_type_name :: proc(type: clang.Type) -> string {
	return string_from_clang_string(clang.getTypeSpelling(type))
}

string_from_clang_string :: proc(str: clang.String) -> string {
	ret := strings.clone_from_cstring(clang.getCString(str))
	clang.disposeString(str)
	return ret
}

Location :: struct {
	file: clang.File,
	offset: int,
	line: int,
	column: int,
}

get_cursor_location :: proc(cursor: clang.Cursor) -> Location {
	file: clang.File
	offset: u32
	column: u32
	line: u32

	clang.getExpansionLocation(clang.getCursorLocation(cursor), &file, &line, &column, &offset)
	
	return {
		file = file,
		offset = int(offset),
		line = int(line),
		column = int(column),
	}
}

get_comment_location :: proc(cursor: clang.Cursor) -> Location {
	file: clang.File
	offset: u32
	column: u32
	line: u32

	clang.getExpansionLocation(clang.getRangeStart(clang.Cursor_getCommentRange(cursor)), &file, &line, &column, &offset)
	
	return {
		file = file,
		offset = int(offset),
		line = int(line),
		column = int(column),
	}
}