/*
Generates Odin bindings from C code.

Usage:
bindgen folder_with_headers_inside

The folder can contain a `bindgen.sjson` file tha can be used to do overrides
and configure the generation. See the examples folder for how to do that.
*/

#+feature dynamic-literals

package bindgen

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strings"
import "core:path/filepath"
import "core:math/bits"
import "core:encoding/json"
import "core:unicode"
import "core:unicode/utf8"
import "base:runtime"
import "core:slice"
import vmem "core:mem/virtual"
import clang "../libclang"

Struct_Field :: struct {
	names: [dynamic]string,
	type: string,
	anon_struct_type: Maybe(Struct),
	anon_using: bool,
	comment: string,
	comment_before: bool,
	original_line: int,
}

Struct :: struct {
	original_name: string,
	name: string,
	id: string,
	fields: []Struct_Field,
	comment: string,
	is_union: bool,
	is_forward_declare: bool,
}

Function_Parameter :: struct {
	name: string,
	type: string,
}

Function :: struct {
	original_name: string,
	name: string,

	// if non-empty, then use this will be the link name used in bindings
	link_name: string,
	parameters: []Function_Parameter,
	return_type: string,
	comment: string,
	comment_before: bool,
	variadic: bool,
	post_comment: string,
}

Enum_Member :: struct {
	name: string,
	value: int,
	comment: string,
	comment_before: bool,
}

Enum :: struct {
	original_name: string,
	name: string,
	id: string,
	members: []Enum_Member,
	comment: string,
	backing_type: string,
}

Typedef :: struct {
	original_name: string,
	name: string,
	type: string,
	pre_comment: string,
	side_comment: string,
}

Macro :: struct {
	original_name: string,
	name: string,
	val: string,
	comment: string,
	side_comment: string,
	whitespace_after_name: int,
	whitespace_before_side_comment: int,
}

Declaration_Variant :: union {
	Struct,
	Function,
	Enum,
	Typedef,
	Macro,
}

Declaration :: struct {
	// Used for sorting the declarations. They may be added out-of-order due to macros
	// coming in from a separate code path.
	cursor: clang.Cursor,

	// The original idx in `s.decls`. This is for tie-breaking when line is the same.
	original_idx: int,
	variant: Declaration_Variant,
}

trim_prefix :: proc(s: string, p: string) -> string {
	return strings.trim_prefix(strings.trim_prefix(s, p), "_")
}

// Types that would need `import "core:c/libc"`. Please add and send in a Pull Request if you needed
// to add anything here!
is_libc_type :: proc(t: string) -> bool{
	base_type := strings.trim_suffix(t, "*")
	base_type = strings.trim_space(base_type)

	switch t {
	case "time_t":
		return true
	}

	return false
}

// Types that would need "import 'core:sys/posix'". Please add and send in a Pull Request if you
// needed to add anything here!
is_posix_type :: proc(t:string) -> bool {
	base_type := strings.trim_suffix(t,"*")
	base_type = strings.trim_space(base_type)
	switch t {
	case "dev_t": return true
	case "blkcnt_t": return true
	case "blksize_t": return true
	case "clock_t": return true
	case "clockid_t": return true
	case "fsblkcnt_t": return true
	case "off_t": return true
	case "gid_t": return true
	case "pid_t": return true
	case "timespec": return true
	}
	return false
}

is_c_type :: proc(t: string) -> bool{
	base_type := strings.trim_suffix(t, "*")
	base_type = strings.trim_space(base_type)
	return base_type in c_type_mapping
}

// This is probably missing some built-in C types (or common types that come
// from stdint.h etc). Please add and send in a Pull Request if you needed to
// add anything here!
c_type_mapping := map[string]string {
	// Char
	"char" = "c.char",

	// Signed
	"signed char" = "c.schar",
	"short"       = "c.short",
	"int"         = "c.int",
	"long"        = "c.long",
	"long long"   = "c.longlong",

	// Unsigned
	"unsigned char"      = "c.uchar",
	"unsigned short"     = "c.ushort",
	"unsigned int"       = "c.uint",
	"unsigned long"      = "c.ulong",
	"unsigned long long" = "c.ulonglong",

	// Bool
	"bool"  = "bool",
	"Bool"  = "bool", // I don't know why this needs to have a capital B, but it does.
	"BOOL"  = "bool", // bool is sometimes a macro for BOOL
	"_Bool" = "bool",

	// Size & wchar
	"size_t"  = "c.size_t",
	"ssize_t" = "c.ssize_t",
	"wchar_t" = "c.wchar_t",

	// Floats
	"float"  = "f32",
	"double" = "f64",
	// I think clang changes this to something else so this might not work.
	// I tried testing it but I couldn't get the complex type working in C.
	"float complex"  = "complex64",
	"double complex" = "complex128",

	// _t types
	"int8_t"   = "i8",
	"uint8_t"  = "u8",
	"int16_t"  = "i16",
	"uint16_t" = "u16",
	"int32_t"  = "i32",
	"uint32_t" = "u32",
	"int64_t"  = "i64",
	"uint64_t" = "u64",

	// least types
	"int_least8_t"   = "i8",
	"uint_least8_t"  = "u8",
	"int_least16_t"  = "i16",
	"uint_least16_t" = "u16",
	"int_least32_t"  = "i32",
	"uint_least32_t" = "u32",
	"int_least64_t"  = "i64",
	"uint_least64_t" = "u64",

	// These type could change base on the platform.
	// Fast types
	"int_fast8_t"   = "c.int_fast8_t",
	"uint_fast8_t"  = "c.uint_fast8_t",
	"int_fast16_t"  = "c.int_fast16_t",
	"uint_fast16_t" = "c.uint_fast16_t",
	"int_fast32_t"  = "c.int_fast32_t",
	"uint_fast32_t" = "c.uint_fast32_t",
	"int_fast64_t"  = "c.int_fast64_t",
	"uint_fast64_t" = "c.uint_fast64_t",

	// ptr types
	"intptr_t"  = "c.intptr_t",
	"uintptr_t" = "c.uintptr_t",
	"ptrdiff_t" = "c.ptrdiff_t",

	// intmax types
	"intmax_t"  = "c.intmax_t",
	"uintmax_t" = "c.uintmax_t",
}

// For translating type names in procedure parameters and struct fields.
translate_type :: proc(s: Gen_State, t: string, override: bool) -> string {
	t := t
	t = strings.trim_space(t)

	// Treat as function typedef
	if strings.contains(t, "(") && strings.contains(t, ")") && !strings.contains(t, ")[") {
		delimiter := strings.index(t, "(*)(")
		remainder_start := delimiter + 4

		if delimiter == -1 {
			delimiter = strings.index(t, "(")
			remainder_start = delimiter + 1
		}

		return_type := translate_type(s, t[:delimiter], false)

		func_builder := strings.builder_make()

		strings.write_string(&func_builder, `proc "c" (`)

		// We find the closing parenthesis for the function parameters.
		// We assume anything after the closing parenthesis is a compiler
		// attribute or something else that we don't care about.
		paren_count := 1
		remainder_end := remainder_start
		for i := remainder_start; i < len(t); i += 1 {
			if t[i] == '(' {
				paren_count += 1
			} else if t[i] == ')' {
				paren_count -= 1
			}

			if paren_count == 0 {
				remainder_end = i
				break
			}
		}

		if paren_count != 0 {
			fmt.panicf("Unmatched parentheses in type: %v", t)
		}

		remainder := t[remainder_start:remainder_end]

		first := true

		for param_type in strings.split_iterator(&remainder, ",") {
			if first {
				first = false
			} else {
				strings.write_string(&func_builder, ", ")
			}
			strings.write_string(&func_builder, translate_type(s, strings.trim_space(param_type), false))
		}

		if return_type == "void" {
			strings.write_string(&func_builder, ")")
		} else {
			strings.write_string(&func_builder, fmt.tprintf(") -> %v", return_type))
		}

		return strings.to_string(func_builder)
	}

	// This type usually means "an array of strings"
	if t == "const char *const *" || t == "char *const *" || t == "const char **" || t == "char **" {
		return "[^]cstring"
	}

	if t == "const char *" || t == "char *" {
		return "cstring"
	}

	if t == "va_list" || t == "struct __va_list_tag *" {
		return "^c.va_list"
	}

	// Tokenize the type and skip over some parameter type keywords that have no meaning in Odin.
	type_tokens: [dynamic]string
	token_start := 0
	num_ptrs := 0

	for s, idx in t {
		tok: string

		if strings.is_space(s) {
			tok = t[token_start:idx]
			token_start = idx + utf8.rune_size(s)
		} else if s == '*' {
			tok = t[token_start:idx]
			token_start = idx + utf8.rune_size(s)
			num_ptrs += 1
		} else if idx == len(t) - 1{
			tok = t[token_start:idx + 1]
		}

		if len(tok) > 0 {
			if tok == "const" {
				continue
			}

			if tok == "struct" {
				continue
			}

			if tok == "enum" {
				continue
			}

			append(&type_tokens, tok)
		}
	}

	t = strings.join(type_tokens[:], " ")

	// A hack to check if something is an array of arrays. Then it will appear as `(*)[3] etc. But
	// the code above removes the `*`, so we check for `( )[`
	t_original := t
	multi_array := strings.index(t_original, "( )[")
	array_start := strings.index(t_original, "[")
	array_end := strings.last_index(t_original, "]")

	if multi_array != -1 {
		t = t[:multi_array]
	} else if array_start != -1 {
		t = t[:array_start]
	}

	// check maps against this in case the header has a type which is exactly [prefix][mapped c type]
	t_prefixed := strings.trim_space(t)
	if t != s.remove_type_prefix {
		t = trim_prefix(t, s.remove_type_prefix)
	}

	t = strings.trim_space(t)

	if is_c_type(t_prefixed) {
		t = c_type_mapping[t]
	} else if is_libc_type(t_prefixed) {
		t = fmt.tprintf("libc.%v", t)
	} else if is_posix_type(t_prefixed) {
		t = fmt.tprintf("posix.%v",t)
	} else if rename, exists := s.rename[t_prefixed]; exists {
		t = vet_name(rename)
	} else if s.force_ada_case_types && t != "void" {
		// It makes sense, in the case we can't find the type, to just follow our naming rules and
		// hope the type is defined somewhere else.
		t = vet_name(strings.to_ada_case(t))
	} else {
		t = vet_name(t)
	}

	b := strings.builder_make()

	if array_start != -1 {
		if multi_array != -1 {
			strings.write_string(&b, "[^]")
		}
		strings.write_string(&b, t_original[array_start:array_end + 1])
	}

	if num_ptrs > 0 {
		if t == "void" {
			t = "rawptr"
			num_ptrs -= 1
		}

		if t in s.type_is_proc {
			num_ptrs -= 1
		}

		if multi_array != -1 {
			num_ptrs -= 1
		}
	}

	if num_ptrs > 0 && override {
		strings.write_string(&b, "[^]")
		num_ptrs -= 1
	}

	for num_ptrs > 0 {
		strings.write_string(&b, "^")
		num_ptrs -= 1
	}

	strings.write_string(&b, t)
	return strings.to_string(b)
}

// Keywords in Odin that don't exist in C. The `_` is there so we can return it
// without allocating memory (we compare to the slice [1:])
VET_NAMES :: [?]string {
	"_rune",
	"_import",
	"_foreign",
	"_package",
	"_typeid",
	"_when",
	"_where",
	"_in",
	"_not_in",
	"_fallthrough",
	"_defer",
	"_proc",
	"_bit_set",
	"_bit_field",
	"_map",
	"_dynamic",
	"_auto_cast",
	"_cast",
	"_transmute",
	"_distinct",
	"_using",
	"_context",
	"_or_else",
	"_or_return",
	"_or_break",
	"_or_continue",
	"_asm",
	"_inline",
	"_no_inline",
	"_matrix",
	"_string",

	// Because we import these three
	"_c",
	"_libc",
	"_posix",
}

vet_name :: proc(s: string) -> string {
	for v in VET_NAMES {
		if s == v[1:] {
			return v
		}
	}

	return s
}

add_to_set :: proc(s: ^map[$T]struct{}, v: T) {
	s[v] = {}
}

fp :: fmt.fprint
fpln :: fmt.fprintln
fpf :: fmt.fprintf
fpfln :: fmt.fprintfln

Config :: struct {
	inputs: []string,
	ignore_inputs: []string,
	output_folder: string,
	package_name: string,
	required_prefix: string,

	// deprecated: use remove_xxx_prefix
	remove_prefix: string,
	remove_type_prefix: string,
	remove_function_prefix: string,
	remove_macro_prefix: string,
	import_lib: string,
	imports_file: string,
	clang_include_paths: []string,
	clang_defines: map[string]string,
	force_ada_case_types: bool,
	debug_dump_json_ast: bool,
	debug_dump_macros: bool,
	opaque_types: []string,
	rename: map[string]string,

	// deprecated: use rename
	rename_types: map[string]string,
	type_overrides: map[string]string,
	struct_field_overrides: map[string]string,
	procedure_type_overrides: map[string]string,
	bit_setify: map[string]string,
	inject_before: map[string]string,
}

Gen_State :: struct {
	using config: Config,
	file: clang.File,
	decls: [dynamic]Declaration,
	defines: map[string]string,
	symbol_indices: map[string]int,
	typedefs: map[string]string,
	created_symbols: map[string]struct {},
	type_is_proc: map[string]struct {},
	opaque_type_lookup: map[string]struct {},
	created_types: map[string]struct {},
	needs_import_c: bool,
	needs_import_libc: bool,
	needs_import_posix: bool,
}

gen :: proc(input: string, c: Config) {
	// Everything allocated within this call to `gen` is allocated on a single
	// arena, which is destroyed when this procedure ends.

	gen_arena: vmem.Arena
	defer vmem.arena_destroy(&gen_arena)
	context.allocator = vmem.arena_allocator(&gen_arena)
	context.temp_allocator = vmem.arena_allocator(&gen_arena)

	s := Gen_State {
		config = c,
	}

	for ot in c.opaque_types {
		// For quick lookup
		add_to_set(&s.opaque_type_lookup, ot)
	}

	//
	// Parse file using libclang and produce an AST.
	//

	clang_args := make([]cstring, 1 + len(c.clang_include_paths) + len(c.clang_defines))
	clang_args[0] = "-fparse-all-comments"

	index := 1
	for &include in c.clang_include_paths {
		clang_args[index] = fmt.ctprintf("-I%v", include)
		index += 1
	}

	for k, v in c.clang_defines {
		clang_args[index] = fmt.ctprintf("-D%s=%s", k, v)
		index += 1
	}

	idx := clang.createIndex(1, 0)
	unit: clang.Translation_Unit

	input_cstring := strings.clone_to_cstring(input)

	// Keep macros, skip function bodies, and keep going on errors.
	options: clang.Translation_Unit_Flags = {
		.DetailedPreprocessingRecord,
		.SkipFunctionBodies,
		.KeepGoing,
	}
	err := clang.parseTranslationUnit2(
		idx,
		input_cstring,
		raw_data(clang_args),
		i32(len(clang_args)),
		nil,
		0,
		options,
		&unit,
	)
	if err != .Success {
		fmt.panicf("Failed to parse translation unit for %s. Error code: %i", input, err)
	}

	s.file = clang.getFile(unit, input_cstring)

	clang_string_to_string :: proc(str: clang.String) -> string {
		cstr := clang.getCString(str)
		defer clang.disposeString(str)
		return strings.clone_from_cstring(cstr)
	}

	get_cursor_location :: proc(cursor: clang.Cursor, file: ^clang.File = nil, offset: ^u32 = nil) -> (line: u32) {
		clang.getExpansionLocation(clang.getCursorLocation(cursor), file, &line, nil, offset)
		return
	}

	get_comment_location :: proc(cursor: clang.Cursor) -> (line: u32) {
		clang.getExpansionLocation(clang.getRangeStart(clang.Cursor_getCommentRange(cursor)), nil, &line, nil, nil)
		return
	}

	get_cursor_type_string :: proc(cursor: clang.Cursor) -> string {
		return clang_string_to_string(clang.getTypeSpelling(clang.getCursorType(cursor)))
	}

	vet_type :: proc(s: ^Gen_State, t: string) {
		if is_c_type(t) {
			s.needs_import_c = true
		} else if is_libc_type(t) {
			s.needs_import_libc = true
		} else if is_posix_type(t) {
			s.needs_import_posix = true
		}
	}

	// We can probably inline these functions.
	parse_function_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Function {
		// We could probably make use of `clang.Type` here and not store a string.
		// This is easier to implement for now. We can make improvments later.
		return_type := clang_string_to_string(clang.getTypeSpelling(clang.getCursorResultType(cursor)))
		if return_type != "void" {
			vet_type(state, return_type)
		}

		out_params: [dynamic]Function_Parameter

		for i in 0 ..< clang.Cursor_getNumArguments(cursor) {
			param_cursor := clang.Cursor_getArgument(cursor, u32(i))
			#partial switch param_kind := clang.getCursorKind(param_cursor); param_kind {
			case .ParmDecl:
				param_name := clang_string_to_string(clang.getCursorSpelling(param_cursor))
				param_type := get_cursor_type_string(param_cursor)
				vet_type(state, param_type)
				append(&out_params, Function_Parameter {
					name = param_name,
					type = param_type,
				})
			case:
				// For debugging purposes.
				fmt.printf("Unexpected cursor kind for parameter: %v\n", param_kind)
			}
		}

		offset: u32
		line := get_cursor_location(cursor, nil, &offset)
		side_comment: string
		translation_unit := clang.Cursor_getTranslationUnit(cursor)
		for true {
			token := clang.getToken(translation_unit, clang.getLocationForOffset(translation_unit, state.file, offset))
			if token == nil {
				break
			}

			defer clang.disposeTokens(translation_unit, token, 1)
			tline: u32
			clang.getFileLocation(clang.getTokenLocation(translation_unit, token^), nil, &tline, nil, &offset)
			if tline != line {
				break
			}
			
			token_string := clang_string_to_string(clang.getTokenSpelling(translation_unit, token^))
			if clang.getTokenKind(token^) == .Comment {
				side_comment = token_string
				break
			}

			offset += u32(len(token_string))
		}

		comment := clang_string_to_string(clang.Cursor_getRawCommentText(cursor))
		cline := get_comment_location(cursor)

		return Function {
			original_name = clang_string_to_string(clang.getCursorSpelling(cursor)),
			parameters = out_params[:],
			return_type = return_type == "void" ? "" : return_type,
			comment = comment,
			comment_before = comment == "" ? false : cline != line,
			post_comment = side_comment,
			variadic = clang.Cursor_isVariadic(cursor) != 0,
		}
	}

	parse_record_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Struct {

		child_proc: clang.Cursor_Visitor : proc "c" (
			cursor, parent: clang.Cursor,
			data: clang.Client_Data,
		) -> clang.Child_Visit_Result {
			context = runtime.default_context()
			data := (^Data)(data)

			line: u32
			clang.getExpansionLocation(clang.getCursorLocation(cursor), nil, &line, nil, nil)

			cline := get_comment_location(cursor)

			comment := clang_string_to_string(clang.Cursor_getRawCommentText(cursor))
			comment_before := comment == "" ? false : cline != line

			#partial switch kind := clang.getCursorKind(cursor); kind {
			case .FieldDecl:
				type := get_cursor_type_string(cursor)
				if prev_idx := len(data.out_fields) - 1; prev_idx >= 0 && data.out_fields[prev_idx].type == type && data.out_fields[prev_idx].original_line == int(line) {
					append(&data.out_fields[len(data.out_fields) - 1].names, clang_string_to_string(clang.getCursorSpelling(cursor)))
				} else {
					append(&data.out_fields, Struct_Field {
						names = [dynamic]string {clang_string_to_string(clang.getCursorSpelling(cursor))},
						type = type,
						anon_using = false,
						comment = comment,
						comment_before = comment_before,
						original_line = int(line),
					})

					vet_type(data.state, type)
				}
			case .StructDecl, .UnionDecl:
				append(&data.out_fields, Struct_Field {
					names = [dynamic]string {clang_string_to_string(clang.getCursorSpelling(cursor))},
					type = get_cursor_type_string(cursor),
					anon_struct_type = parse_record_decl(data.state, cursor),
					anon_using = true,
					comment = comment,
					comment_before = comment_before,
					original_line = int(line),
				})
			case:
				// For debugging purposes.
				fmt.printf("Unexpected cursor kind for field: %v, name: %s\n", kind, clang_string_to_string(clang.getCursorSpelling(cursor)))
			}
			return .Continue
		}

		Data :: struct {
			state: ^Gen_State,
			out_fields: [dynamic]Struct_Field,
		}

		data: Data = {
			state = state,
			out_fields = {},
		}

		clang.visitChildren(cursor, child_proc, &data)

		return {
			original_name = clang_string_to_string(clang.getCursorSpelling(cursor)),
			id = clang_string_to_string(clang.getCursorUSR(cursor)),
			fields = data.out_fields[:],
			comment = clang_string_to_string(clang.Cursor_getRawCommentText(cursor)),
			is_union = clang.getCursorKind(cursor) == .UnionDecl,
		}
	}

	parse_typedef_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Typedef {
		type := clang_string_to_string(clang.getTypeSpelling(clang.getTypedefDeclUnderlyingType(cursor)))
		vet_type(state, type)	
		return {
			original_name = clang_string_to_string(clang.getCursorSpelling(cursor)),
			type = clang_string_to_string(clang.getTypeSpelling(clang.getTypedefDeclUnderlyingType(cursor))),
			pre_comment = clang_string_to_string(clang.Cursor_getRawCommentText(cursor)),
			side_comment = "",
		}
	}

	parse_enum_decl :: proc(state: ^Gen_State, cursor: clang.Cursor, line: u32) -> Enum {
		out_members: [dynamic]Enum_Member

		backing_type := clang.getEnumDeclIntegerType(cursor)
		backing_type_string := clang_string_to_string(clang.getTypeSpelling(backing_type))
		vet_type(state, backing_type_string)

		child_proc: clang.Cursor_Visitor : proc "c" (
			cursor, parent: clang.Cursor,
			data: clang.Client_Data,
		) -> clang.Child_Visit_Result {
			context = runtime.default_context()
			data := (^Data)(data)

			#partial switch kind := clang.getCursorKind(cursor); kind {
			case .EnumConstantDecl:
				comment := clang_string_to_string(clang.Cursor_getRawCommentText(cursor))
				comment_before := comment == "" ? false : get_comment_location(cursor) != get_cursor_location(cursor)

				append(data.out_members, Enum_Member {
					name = clang_string_to_string(clang.getCursorSpelling(cursor)),
					value = data.is_unsigned_type ? (int)(clang.getEnumConstantDeclUnsignedValue(cursor)) : (int)(clang.getEnumConstantDeclValue(cursor)),
					comment = comment,
					comment_before = comment_before,
				})
			case:
				// For debugging purposes.
				fmt.printf("Unexpected cursor kind for enum member: %v\n", kind)
			}

			return .Continue
		}

		Data :: struct {
			is_unsigned_type: bool,
			out_members:      ^[dynamic]Enum_Member,
		}

		clang.visitChildren(cursor, child_proc, &Data {
			is_unsigned_type = backing_type.kind >= .Char_U && backing_type.kind <= .UInt128,
			out_members = &out_members,
		})

		return {
			original_name = clang.Cursor_isAnonymous(cursor) != 0 ? "" : clang_string_to_string(clang.getCursorSpelling(cursor)),
			id = clang_string_to_string(clang.getCursorUSR(cursor)),
			comment = clang_string_to_string(clang.Cursor_getRawCommentText(cursor)),
			members = out_members[:],
			backing_type = backing_type_string,
		}
	}

	parse_macro_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Macro {
		return {
			original_name = clang_string_to_string(clang.getCursorSpelling(cursor)),
			val = "",
			comment = clang_string_to_string(clang.Cursor_getRawCommentText(cursor)),
			side_comment = "", // ??
		}
	}

	root_cursor_visitor_proc: clang.Cursor_Visitor : proc "c" (
		cursor, parent: clang.Cursor,
		state: clang.Client_Data,
	) -> clang.Child_Visit_Result {
		context = runtime.default_context()
		state := (^Gen_State)(state)

		file: clang.File
		line := get_cursor_location(cursor, &file)
		if clang.File_isEqual(file, state.file) == 0 {
			return .Continue // This cursor is not in the file we are interested in.
		}

		kind := clang.getCursorKind(cursor)
		// Need to figure out how to get macro expansion values out and not parse certain macro definitions.
		// We can't just check the file origin of the macro unfortunatly as it doesn't stop us from pulling weird things (e.g. _STDC_VERSION__).
		#partial switch kind {
		// This doesn't work yet.
		// case .MacroDefinition:
		// 	if clang.Cursor_isMacroFunctionLike(cursor) + clang.Cursor_isMacroBuiltin(cursor) != 0 {
		// 		return .Continue
		// 	}

		// 	append(&state.decls, Declaration {
		// 		line = int(line),
		// 		original_idx = len(state.decls),
		// 		variant = parse_macro_decl(state, cursor),
		// 	})
		// 	return .Continue
		case .FunctionDecl:
			// Don't output inlined functions.
			if clang.Cursor_isFunctionInlined(cursor) != 0 {
				return .Continue
			}

			// We have to check for funtions before checking if it's a def.
			append(&state.decls, Declaration {
				cursor = cursor,
				original_idx = len(state.decls),
				variant = parse_function_decl(state, cursor),
			})
			return .Continue
		}

		// This stops us from getting macros so we have to check for macros above.
		if clang.isCursorDefinition(cursor) == 0 {
			return .Continue // Skip forward declarations.
		}

		def: Declaration_Variant
		#partial switch kind {
		case .StructDecl, .UnionDecl:
			def = parse_record_decl(state, cursor)
		case .TypedefDecl:
			def = parse_typedef_decl(state, cursor)
		case .EnumDecl:
			def = parse_enum_decl(state, cursor, line)
		case .VarDecl:
			// Should we output variables as constants?
			return .Continue
		case:
			// For debugging purposes.
			fmt.printf("Unhandled cursor kind: %v, name: %s\n", kind, clang_string_to_string(clang.getCursorSpelling(cursor)))
			return .Continue
		}

		append(&state.decls, Declaration {
			cursor = cursor,
			original_idx = len(state.decls),
			variant = def,
		})

		return .Continue
	}

	cursor := clang.getTranslationUnitCursor(unit)
	clang.visitChildren(cursor, root_cursor_visitor_proc, &s)

	input_filename := filepath.base(input)
	output_stem := filepath.stem(input_filename)
	output_filename := fmt.tprintf("%v/%v.odin", s.output_folder, output_stem)

	slice.sort_by(s.decls[:], proc(i, j: Declaration) -> bool {
		// This should work but I get a linker error. Is the version of libclang from VS dev tools outdated?
		// return clang.isBeforeInTranslationUnit(clang.getCursorLocation(i.cursor), clang.getCursorLocation(j.cursor)) != 0
		// This should be fine for now.
		return get_cursor_location(i.cursor) < get_cursor_location(j.cursor)
	})

	//
	// Use the stuff in `s` and `s.decl` to write out the bindings.
	//

	f, f_err := os.open(output_filename, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644)

	fmt.ensuref(f_err == nil, "Failed opening %v", output_filename)
	defer os.close(f)

	// Extract any big comment at top of file (clang doesn't see these)
	{
		source_data, source_data_ok := os.read_entire_file(input)
		fmt.ensuref(source_data_ok, "Failed reading source file: %v", input)
		source := strings.trim_space(string(source_data))
		in_block := false
		top_comment_loop: for ll in strings.split_lines_iterator(&source) {
			l := strings.trim_space(ll)

			if in_block {
				fpln(f, l)
				if strings.contains(l, "*/") {
					in_block = false
				}
			} else {
				if len(l) < 2 {
					continue
				}

				switch l[:2] {
				case "//":
					fpln(f, l)
				case "/*":
					in_block = !strings.contains(l, "*/")
					fpln(f, l)
				case:
					break top_comment_loop
				}
			}
		}
	}

	fpf(f, "package %v\n\n", s.package_name)

	if s.needs_import_c {
		fpln(f, `import "core:c"`)
	}

	if s.needs_import_libc {
		fpln(f, `import "core:c/libc"`)
	}

	if s.needs_import_posix {
		fpln(f, `import "core:sys/posix"`)
	}

	fp(f, "\n")

	if s.needs_import_c {
		fpln(f, "_ :: c")
	}
	if s.needs_import_libc {
		fpln(f, "_ :: libc")
	}
	if s.needs_import_posix {
		fpln(f, "_ :: posix")
	}

	fp(f, "\n")

	if s.imports_file != "" {
		top_code, top_code_ok := os.read_entire_file(s.imports_file)
		fmt.ensuref(top_code_ok, "Failed to load %v", s.imports_file)
		fp(f, string(top_code))
	} else if s.import_lib != "" {
		fpf(f, `foreign import lib "%v"`, s.import_lib)
	}

	fp(f, "\n\n")

	output_comment :: proc(f: os.Handle, c: string, indent := "") {
		ci := c
		for l in strings.split_lines_iterator(&ci) {
			fp(f, indent)
			fpln(f, strings.trim_space(l))
		}
	}

	//
	// Figure out all type names
	//

	for &decl in s.decls {
		du := &decl.variant
		switch &d in du {
		case Struct:
			name := d.original_name

			// This is really ugly, if you can simplify this, please do.
			if typedef, has_typedef := s.typedefs[d.id]; has_typedef {
				d.original_name = typedef
				name = typedef
				if replacement, has_replacement := s.rename[name]; has_replacement {
					name = replacement
				} else {
					name = trim_prefix(name, s.remove_type_prefix)
					if s.force_ada_case_types {
						name = strings.to_ada_case(name)
					}
				}
				add_to_set(&s.created_symbols, name)
			} else if replacement, has_replacement := s.rename[name]; has_replacement {
				name = replacement
			} else {
				name = trim_prefix(name, s.remove_type_prefix)

				if s.force_ada_case_types {
					name = strings.to_ada_case(name)
				}
			}

			d.name = vet_name(name)
			add_to_set(&s.created_types, d.name)
		case Function:
			name := d.original_name

			if replacement, has_replacement := s.rename[name]; has_replacement {
				d.link_name = d.original_name
				name = replacement
			} else {
				name = trim_prefix(name, s.remove_function_prefix)
			}

			d.name = vet_name(name)
		case Enum:
			name := d.original_name

			if typedef, has_typedef := s.typedefs[d.id]; has_typedef {
				d.original_name = typedef
				name = typedef
				if replacement, has_replacement := s.rename[name]; has_replacement {
					name = replacement
				} else {
					name = trim_prefix(name, s.remove_type_prefix)
					if s.force_ada_case_types {
						name = strings.to_ada_case(name)
					}
				}
				add_to_set(&s.created_symbols, name)
			} else if replacement, has_replacement := s.rename[name]; has_replacement {
				name = replacement
			} else {
				name = trim_prefix(name, s.remove_type_prefix)

				if s.force_ada_case_types {
					name = strings.to_ada_case(name)
				}
			}

			d.name = vet_name(name)
			add_to_set(&s.created_types, d.name)
		case Typedef:
			name := d.original_name

			if is_c_type(name) {
				continue
			}

			if replacement, has_replacement := s.rename[name]; has_replacement {
				name = replacement
			} else {
				name = trim_prefix(name, s.remove_type_prefix)

				if s.force_ada_case_types {
					name = strings.to_ada_case(name)
				}
			}

			d.name = vet_name(name)
			add_to_set(&s.created_types, d.name)
		case Macro:
			name := d.original_name

			if replacement, has_replacement := s.rename[name]; has_replacement {
				name = replacement
			} else {
				name = trim_prefix(name, s.remove_macro_prefix)
			}

			d.name = vet_name(name)
			add_to_set(&s.created_types, d.name)
		}
	}

	for _, b in s.bit_setify {
		add_to_set(&s.created_types, b)
	}

	for &decl, decl_idx in s.decls {
		du := &decl.variant
		switch d in du {
		case Struct:
			n := d.name

			if d.is_forward_declare {
				if d.original_name in s.opaque_type_lookup && d.id not_in s.typedefs {
					output_comment(f, d.comment)
					fpf(f, "%v :: struct {{}}\n\n", n)
				}

				break
			}

			output_comment(f, d.comment)

			if inject, has_injection := s.inject_before[d.original_name]; has_injection {
				fpf(f, "%v\n\n", inject)
			}

			fp(f, n)
			fp(f, " :: ")

			if override, override_ok := s.type_overrides[d.original_name]; override_ok {
				fp(f, override)
				fp(f, "\n\n")
				break
			}

			output_struct :: proc(s: Gen_State, d: Struct, indent: int, n: string) -> string {
				w := strings.builder_make()
				ws :: strings.write_string
				ws(&w, "struct ")

				if d.is_union {
					ws(&w, "#raw_union ")
				}

				ws(&w, "{\n")

				longest_field_name_with_side_comment: int

				for &field in d.fields {
					if _, anon_struct_ok := field.anon_struct_type.?; anon_struct_ok {
						continue
					}

					field_len: int
					for fn, nidx in field.names {
						if nidx != 0 {
							field_len += 2 // for comma and space
						}

						field_len += len(vet_name(fn))
					}
					if (field.comment == "" || !field.comment_before) && field_len > longest_field_name_with_side_comment {
						longest_field_name_with_side_comment = field_len
					}
				}

				Formatted_Field :: struct {
					field:          string,
					comment:        string,
					comment_before: bool,
				}

				fields: [dynamic]Formatted_Field

				for &field in d.fields {
					b := strings.builder_make()

					override_key: string

					if field.anon_using {
						strings.write_string(&b, "using _: ")
					} else {
						for fn, nidx in field.names {
							if nidx != 0 {
								strings.write_string(&b, ", ")
							}

							strings.write_string(&b, vet_name(fn))
						}

						names_len := strings.builder_len(b)
						override_key = fmt.tprintf("%s.%s", d.original_name, strings.to_string(b))
						strings.write_string(&b, ": ")

						if !field.comment_before {
							// Padding between name and =
							for _ in 0..<longest_field_name_with_side_comment-names_len {
								strings.write_rune(&b, ' ')
							}
						}
					}

					field_type: string
					
					if field_type_override, has_field_type_override := s.struct_field_overrides[override_key]; override_key != "" && has_field_type_override {
						if field_type_override == "[^]" {
							// Change first `^` for `[^]`
							field_type = translate_type(s, field.type, true)
						} else {
							field_type = field_type_override
						}
					} else {
						field_type = translate_type(s, field.type, false)
					}

					comment := field.comment
					comment_before := field.comment_before

					if anon_struct, anon_struct_ok := field.anon_struct_type.?; anon_struct_ok {
						if anon_struct.comment != "" {
							comment = anon_struct.comment
							comment_before = true
						}

						field_type = output_struct(s, anon_struct, indent + 1, n)
					}

					strings.write_string(&b, field_type)

					append(&fields, Formatted_Field {
						field = strings.to_string(b),
						comment = comment,
						comment_before = comment_before,
					})
				}

				longest_field_with_side_comment: int

				for &field in fields {
					if field.comment != "" && !field.comment_before {
						longest_field_with_side_comment = max(len(field.field), longest_field_with_side_comment)
					}
				}

				for &field, field_idx in fields {
					has_comment := field.comment != ""
					comment_before := field.comment_before

					if has_comment && comment_before {
						if field_idx != 0 {
							ws(&w, "\n")
						}

						ci := field.comment
						for l in strings.split_lines_iterator(&ci) {
							for _ in 0..<indent+1 {
								ws(&w, "\t")
							}
							ws(&w, strings.trim_space(l))
							ws(&w, "\n")
						}
					}

					for _ in 0..<indent+1 {
						ws(&w, "\t")
					}
					ws(&w, field.field)
					ws(&w, ",")

					if has_comment && !comment_before {
						// Padding in front of comment
						for _ in 0..<(longest_field_with_side_comment - len(field.field)) {
							ws(&w, " ")
						}

						ws(&w, " ")
						ws(&w, field.comment)
					}

					ws(&w, "\n")
				}

				for _ in 0..<indent {
					ws(&w, "\t")
				}
				ws(&w, "}")
				return strings.to_string(w)
			}

			fp(f, output_struct(s, d, 0, n))
			fp(f, "\n\n")
		case Enum:
			output_comment(f, d.comment)

			name := d.name

			// It has no name, turn it into a bunch of constants
			if name == "" {
				for &m in d.members {
					mn := m.name

					if strings.has_prefix(strings.to_lower(mn), strings.to_lower(s.remove_type_prefix)) {
						mn = mn[len(s.remove_type_prefix):]

						if strings.has_prefix(mn, "_") {
							mn = mn[1:]
						}
					}

					fpf(f, "%v :: %v\n\n", mn, m.value)
				}

				break
			}

			fp(f, name)
			fpf(f, " :: enum %v {{\n", translate_type(s, d.backing_type, false))

			bit_set_name, bit_setify := s.bit_setify[d.original_name]
			make_constant: map[string]int

			if bit_setify {
				for &m in d.members {
					if bits.count_ones(m.value) != 1 { // Not a power of two, so not part of a bit_set.
						make_constant[m.name] = m.value
						continue
					}
					m.value = (int)(bits.log2((uint)(m.value)))
				}
			}

			overlap_length := 0
			longest_name := 0

			all_has_default_value := true
			counter := 0
			for &m in d.members {
				if _, skip := make_constant[m.name]; skip {
					continue
				}

				if m.value != counter {
					all_has_default_value = false
					break
				}
				counter += 1
			}

			if len(d.members) > 1 {
				overlap_length_source := d.members[0].name
				overlap_length = len(overlap_length_source)
				longest_name = overlap_length

				for idx in 1..<len(d.members) {
					if _, skip := make_constant[d.members[idx].name]; skip {
						continue
					}

					mn := d.members[idx].name
					length := strings.prefix_length(mn, overlap_length_source)

					if length < overlap_length {
						overlap_length = length
						overlap_length_source = mn
					}

					longest_name = max(len(mn), longest_name)
				}
			}

			Formatted_Member :: struct {
				name:           string,
				member:         string,
				enum_member:    ^Enum_Member,
			}

			members: [dynamic]Formatted_Member

			for &m in d.members {
				if _, skip := make_constant[m.name]; skip {
					continue
				}

				b := strings.builder_make()

				name_without_overlap := m.name[overlap_length:]

				// I added this to fix something but I dont think we actually need it anymore.
				// If you see any enum members that start with an underscore uncomment this.
				// Remove any leading underscores.
				// for ; name_without_overlap[0] == '_'; name_without_overlap = name_without_overlap[1:] {}

				// First letter is number... Can't have that!
				if len(name_without_overlap) > 0 && unicode.is_number(utf8.rune_at(name_without_overlap, 0)) {
					name_without_overlap = fmt.tprintf("_%v", name_without_overlap)
				}

				strings.write_string(&b, name_without_overlap)

				suffix_pad := longest_name - len(name_without_overlap) - overlap_length

				if !all_has_default_value {
					if !m.comment_before {
						for _ in 0..<suffix_pad {
							// Padding between name and `=`
							strings.write_rune(&b, ' ')
						}
					}

					strings.write_string(&b, fmt.tprintf(" = %v", m.value))
				}

				append(&members, Formatted_Member {
					name = name_without_overlap,
					member = strings.to_string(b),
					enum_member = &m,
				})
			}

			longest_member_name_with_side_comment: int

			for &m in members {
				if m.enum_member.comment != "" && !m.enum_member.comment_before && len(m.member) > longest_member_name_with_side_comment {
					longest_member_name_with_side_comment = len(m.member)
				}
			}

			for &m, m_idx in members {
				has_comment := m.enum_member.comment != ""
				comment_before := m.enum_member.comment_before

				if has_comment && comment_before {
					if m_idx != 0 {
						fp(f, "\n")
					}
					output_comment(f, m.enum_member.comment, "\t")
				}

				fp(f, "\t")
				fp(f, m.member)
				fp(f, ",")

				if has_comment && !comment_before {
					for _ in 0..<(longest_member_name_with_side_comment - len(m.member)) {
						// Padding in front of comment
						fp(f, " ")
					}

					fpf(f, " %v", m.enum_member.comment)
				}

				fp(f, '\n')
			}

			fp(f, "}\n\n")

			if bit_setify {
				fpf(f, "%v :: distinct bit_set[%v; %v]\n\n", bit_set_name, name, translate_type(s, d.backing_type, false))

				// In case there is a typedef for this in the code.
				add_to_set(&s.created_symbols, bit_set_name)

				// There was a member with a compound value, so we need to
				// decompose it into a constant bit set
				for constant_name, constant_val in make_constant {
					all_constant := strings.to_screaming_snake_case(trim_prefix(strings.to_lower(constant_name), strings.to_lower(s.remove_type_prefix)))

					if constant_val == 0 {
						// If the value is 0, we don't need to output it.
						// This is because the zero value of a bit set is an empty set.
						continue
					}

					fpf(f, "%v :: %v {{ ", all_constant, bit_set_name)

					for &m, i in members {
						if (1 << uint(m.enum_member.value)) & constant_val != 0 {
							fpf(f, ".%v", m.name)

							if i != len(members) - 1 {
								fp(f, ", ")
							}
						}
					}

					fp(f, " }\n\n")
				}
			}

		case Function:
			// handled later. This makes all procs end up at bottom, after types.

		case Typedef:
			n := d.name

			if n == "" {
				// The name was a C type, so we don't need to output it.
				continue
			}

			if d.original_name in s.opaque_type_lookup {
				if d.pre_comment != "" {
					output_comment(f, d.pre_comment)
				}
				fpf(f, "%v :: struct {{}}", n)

				if d.side_comment != "" {
					fp(f, ' ')
					fp(f, d.side_comment)
				}

				fp(f, "\n\n")
				continue
			}

			if n in s.created_symbols || strings.has_prefix(d.type, "0x") {
				continue
			}

			if translate_type(s, d.type, false) == d.name {
				continue
			}

			if d.pre_comment != "" {
				output_comment(f, d.pre_comment)
			}

			fp(f, n)

			fp(f, " :: ")

			if override, override_ok := s.type_overrides[d.original_name]; override_ok {
				fp(f, override)

				if d.side_comment != "" {
					output_comment(f, d.side_comment)
				}

				fp(f, "\n\n")
				continue
			}

			type := d.type

			if strings.has_prefix(type, "struct ") {
				// This is a weird case -- I used this for opaque types in the
				// beginning, but opaque types are now handled by
				// `s.opaque_type_lookup`, so perhaps this isn't needed anymore?
				fp(f, "struct {}")
			} else if strings.contains(type, "(") && strings.contains(type, ")") {
				// function pointer typedef
				fp(f, translate_type(s, type, false))
				add_to_set(&s.type_is_proc, n)
			} else {
				fpf(f, "%v", translate_type(s, type, false))
			}

			if d.side_comment != "" {
				fp(f, ' ')
				fp(f, d.side_comment)
			}

			fp(f, "\n\n")

		case Macro:
			// val := d.val

			// comment_out := false

			// val = trim_encapsulating_parens(val)
			// b := strings.builder_make()
			// for i := 0; i < len(val); i += 1 {
			// 	switch char_type(val[i]) {
			// 	case .Char:
			// 		// Parsing text here is quite annoying. Is it a type? Is it another macro? Maybe it's an enum field. We don't know.
			// 		// My implementation will check if it's a built-in type or a macro. If it's neither we are going to assume it's a user-defined type.
			// 		// As discussed here https://github.com/karl-zylinski/odin-c-bindgen/pull/27 we dont know all the defined types so figuring out what it is isn't always possible.
			// 		start := i
			// 		for ; i < len(val); i += 1 {
			// 			if char_type(val[i]) != .Char && char_type(val[i]) != .Num {
			// 				break
			// 			}
			// 		}
			// 		if val[start:i] in s.defines {
			// 			strings.write_string(&b, trim_prefix(val[start:i], s.remove_macro_prefix))
			// 		} else if type, exists := c_type_mapping[val[start:i]]; exists {
			// 			strings.write_string(&b, type)
			// 		} else if _, exists =
			// 			   s.created_types[trim_prefix(val[start:i], s.remove_type_prefix)];
			// 		   exists {
			// 			strings.write_string(&b, val[start:i])
			// 		} else {
			// 			comment_out = true

			// 			if s.force_ada_case_types {
			// 				strings.write_string(
			// 					&b,
			// 					strings.to_ada_case(
			// 						trim_prefix(val[start:i], s.remove_type_prefix),
			// 					),
			// 				)
			// 			} else {
			// 				strings.write_string(
			// 					&b,
			// 					trim_prefix(val[start:i], s.remove_type_prefix),
			// 				)
			// 			}
			// 		}
			// 		i -= 1
			// 	case .Num:
			// 		suffix_index := 0
			// 		start := i
			// 		is_prefixed := false

			// 		if i + 1 < len(val) {
			// 			prefix := val[i:i + 2]

			// 			if prefix == "0x" || prefix == "0b" {
			// 				is_prefixed = true
			// 				i += 2
			// 			}
			// 		}

			// 		if is_prefixed {
			// 			// 0x0ULL and 0xFFFF both need to work. This branch makes sure that only things which contain letter above `f` are
			// 			// treated as suffixes, which I think is true for 0x and 0b constants.
			// 			for ; i < len(val); i += 1 {
			// 				type := char_type(val[i])

			// 				if type == .Char &&
			// 				   suffix_index == 0 &&
			// 				   ((val[i] > 'f' && val[i] < 'z') ||
			// 						   (val[i] > 'F' && val[i] <= 'Z')) {
			// 					suffix_index = i
			// 				} else if type != .Num && type != .Char {
			// 					break
			// 				}
			// 			}
			// 		} else {
			// 			// Make 0.3f become 0.3
			// 			for ; i < len(val); i += 1 {
			// 				type := char_type(val[i])

			// 				if type == .Char && suffix_index == 0 {
			// 					suffix_index = i
			// 				} else if type != .Num && type != .Char {
			// 					break
			// 				}
			// 			}
			// 		}

			// 		strings.write_string(&b, val[start:suffix_index > 0 ? suffix_index : i])
			// 		i -= 1
			// 	case .Quote:
			// 		start := i
			// 		for i += 1; i < len(val); i += 1 {
			// 			if val[i] == '\\' {
			// 				i += 1
			// 				continue
			// 			} else if val[i] == '"' {
			// 				break
			// 			}
			// 		}
			// 		strings.write_string(&b, val[start:i + 1])
			// 	case .Other:
			// 		if val[i] == '~' || val[i] == '#' {
			// 			comment_out = true
			// 		}

			// 		strings.write_byte(&b, val[i])
			// 	}
			// }

			// value_string := strings.to_string(b)
			// if value_string == "{}" || value_string == "{0}" {
			// 	continue
			// }

			// if d.comment != "" {
			// 	fp(f, d.comment)
			// }

			// if comment_out {
			// 	fp(f, "// ")
			// }
			// This isn't working atm. I'm hoping that libclang will give use the final value of the macro
			// Making the code above redundant.
			fpf(f, "%s%*s:: %s", d.name, max(d.whitespace_after_name, 1), "", d.val)
			// fpf(f, "%v%*s:: %v", d.name, max(d.whitespace_after_name, 1), "", value_string)

			if d.side_comment != "" {
				fpf(f, "%*s%v", d.whitespace_before_side_comment, "", d.side_comment)
			}

			fp(f, "\n")

			if decl_idx < len(s.decls) - 1 {
				next := &s.decls[decl_idx + 1]

				_, next_is_macro := next.variant.(Macro)

				if !next_is_macro || get_cursor_location(next.cursor) != get_cursor_location(decl.cursor) + 1 {
					fp(f, "\n")
				}
			}
		}
	}

	//
	// Turn functions into groups that are separated by comments. If a comment
	// is before a function then it is used as a "group". If comments are to the
	// right of a function, then the group continues.
	//
	// Everything within a group shares the same padding between the name and
	// the `::`
	//

	Function_Group :: struct {
		header_comment: string,
		functions: [dynamic]Function,
	}

	groups: [dynamic]Function_Group
	curr_group: Function_Group

	for &decl in s.decls {
		du := &decl.variant
		if f, f_ok := du.(Function); f_ok {
			if f.comment != "" {
				if len(curr_group.functions) > 0 {
					append(&groups, curr_group)
				}

				curr_group = {
					header_comment = f.comment,
				}
			}

			append(&curr_group.functions, f)
		}
	}

	if len(curr_group.functions) > 0 {
		append(&groups, curr_group)
	}

	if len(groups) > 0 {
		fmt.fprintfln(f, `@(default_calling_convention="c", link_prefix="%v")`, s.remove_function_prefix)
		fmt.fprintln(f, "foreign lib {")

		for &g, gidx in groups {
			if g.header_comment != "" {
				if gidx != 0 {
					fp(f, "\n")
				}

				output_comment(f, g.header_comment, "\t")
			}

			longest_function_name: int

			for &d in g.functions {
				if len(d.name) > longest_function_name {
					longest_function_name = len(d.name)
				}
			}

			Formatted_Function :: struct {
				function: string,
				post_comment: string,
				attributes: []string,
			}

			Formatted_Member :: struct {
				name: string,
				member: string,
				enum_member: ^Enum_Member,
			}

			formatted_functions: [dynamic]Formatted_Function

			for &d in g.functions {
				b := strings.builder_make()
				attributes := make([dynamic]string)

				w :: strings.write_string

				if d.link_name != "" {
					append(&attributes, fmt.tprintf("link_name=\"%s\"", d.link_name))
				}

				w(&b, d.name)

				for _ in 0..<longest_function_name-len(d.name) {
					strings.write_rune(&b, ' ')
				}

				w(&b, " :: proc(")

				for &p, i in d.parameters {
					n := vet_name(p.name)

					type: string
					type_override_key := fmt.tprintf("%v.%v", d.original_name, n)

					if type_override, type_override_ok := s.procedure_type_overrides[type_override_key]; type_override_ok {
						switch type_override {
						case "#by_ptr":
							type = strings.trim_prefix(translate_type(s, p.type, false), "^")
							w(&b, "#by_ptr ")
						case "[^]":
							type = translate_type(s, p.type, true)
						case:
							type = type_override
						}
					} else {
						type = translate_type(s, p.type, false)
					}

					// Empty name means unnamed parameter. Drop the colon.
					if len(n) != 0 {
						w(&b, n)
						w(&b, ": ")
					} else {
						w(&b, "_: ")
					}

					w(&b, type)

					if i != len(d.parameters) - 1 {
						w(&b, ", ")
					} else {
						if d.variadic {
							w(&b,", #c_vararg _: ..any")
						}
					}
				}

				w(&b, ")")

				if d.return_type != "" {
					w(&b, " -> ")

					return_type: string

					if override, override_ok := s.procedure_type_overrides[d.original_name]; override_ok {
						switch override {
						case "[^]":
							return_type = translate_type(s, d.return_type, true)
						case:
							return_type = override
						}
					} else {
						return_type = translate_type(s, d.return_type, false)
					}

					w(&b, return_type)
				}

				w(&b, " ---")

				append(&formatted_functions, Formatted_Function {
					function = strings.to_string(b),
					post_comment = d.post_comment,
					attributes = attributes[:],
				})
			}

			longest_formatted_function: int

			for &ff in formatted_functions {
				if len(ff.function) < 90 && len(ff.function) > longest_formatted_function {
					longest_formatted_function = len(ff.function)
				}
			}

			for &ff in formatted_functions {
				if len(ff.attributes) > 0 {
					fp(f, "\t")
					fp(f, fmt.tprintf("@(%s)", strings.join(ff.attributes[:], ", ")))
					fp(f, "\n")
				}
				fp(f, "\t")
				fp(f, ff.function)

				if ff.post_comment != "" {
					for _ in 0..<(longest_formatted_function-len(ff.function)) {
						fp(f, ' ')
					}

					fp(f, ' ')
					fp(f, ff.post_comment)
				}

				fp(f, "\n")
			}
		}

		fmt.fprintln(f, "}")
	}
}

main :: proc() {
	permanent_arena: vmem.Arena
	permanent_allocator := vmem.arena_allocator(&permanent_arena)
	context.allocator = permanent_allocator
	context.temp_allocator = permanent_allocator

	ensure(len(os.args) == 2, "Usage: bindgen directory")
	input_arg := os.args[1]

	config_filename := "bindgen.sjson"
	config_dir: string
	if strings.has_suffix(input_arg, ".sjson") && os.is_file(input_arg) {
		config_filename = filepath.base(input_arg)
		config_dir = filepath.dir(input_arg, context.temp_allocator)
	} else if os.is_dir(input_arg) {
		config_dir = input_arg
	} else {
		fmt.panicf("%v is not a directory nor a valid config file", input_arg)
	}

	// Config file is optional
	config: Config

	default_output_folder := "output"
	default_package_name := "pkg"

	if input_dir, input_dir_err := os2.open(input_arg); input_dir_err == nil {
		if stat, stat_err := input_dir.fstat(input_dir, context.allocator); stat_err == nil {
			default_output_folder = stat.name
			default_package_name = stat.name
		}
	}

	if err := os.set_current_directory(config_dir); err != nil {
		fmt.panicf("failed to set current working directory: %v", err)
	}

	if os.is_file(config_filename) {
		if config_data, config_data_ok := os.read_entire_file(config_filename); config_data_ok {
			config_err := json.unmarshal(config_data, &config, .SJSON)
			fmt.ensuref(
				config_err == nil,
				"Failed parsing config %v: %v",
				config_filename,
				config_err,
			)
		} else {
			fmt.ensuref(config_data_ok, "Failed parsing config %v", config_filename)
		}
	} else {
		config.inputs = {"."}
	}

	if config.output_folder == "" {
		config.output_folder = default_output_folder
	}

	if config.package_name == "" {
		config.package_name = default_package_name
	}

	if config.remove_prefix != "" {
		panic(
			"Error in bindgen.sjson: remove_prefix has been split into remove_function_prefix and remove_type_prefix",
		)
	}

	if len(config.rename_types) > 0 {
		panic("Error in bindgen.sjson: rename_types has been renamed to rename")
	}

	input_files: [dynamic]string

	for i in config.inputs {
		if os.is_dir(i) {
			input_folder, input_folder_err := os2.open(i)
			fmt.ensuref(input_folder_err == nil, "Failed opening folder %v: %v", i, input_folder_err)
			iter := os2.read_directory_iterator_create(input_folder)

			for f in os2.read_directory_iterator(&iter) {
				if f.type != .Regular || slice.contains(config.ignore_inputs, f.name) {
					continue
				}

				append(&input_files, fmt.tprintf("%v/%v", i, f.name))
			}

			os2.close(input_folder)
		} else if os.is_file(i) {
			append(&input_files, i)
		} else {
			fmt.eprintfln("%v is neither directory or .h file", i)
		}
	}

	if config.output_folder != "" && !os2.exists(config.output_folder) {
		make_dir_err := os2.make_directory_all(config.output_folder)
		fmt.ensuref(make_dir_err == nil, "Failed creating output directory %v: %v", config.output_folder, make_dir_err)
	}

	for i in input_files {
		ext := filepath.ext(i)
		switch ext {
		case ".h":
			gen(i, config)
		case ".odin", ".lib", ".a", ".dll", ".dylib":
			// Bring along odin and library files
			name := filepath.base(i)
			os2.copy_file(fmt.tprintf("%v/%v", config.output_folder, name), i)
		}
	}
}
