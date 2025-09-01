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
import "core:strconv"
import "core:path/filepath"
import "core:math/bits"
import "core:encoding/json"
import "core:unicode"
import "core:unicode/utf8"
import "base:runtime"
import "core:c"
import "core:slice"
import vmem "core:mem/virtual"
import clang "../libclang"

Struct_Field :: struct {
	names: [dynamic]string,
	type: clang.Type,
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
	is_anon: bool,
	is_forward_declare: bool,
}

Function_Parameter :: struct {
	name: string,
	cursor: clang.Cursor,
}

Function :: struct {
	original_name: string,
	name: string,
	cursor: clang.Cursor,

	// if non-empty, then use this will be the link name used in bindings
	link_name: string,
	parameters: []clang.Cursor,
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
	backing_type: clang.Type,
}

Typedef :: struct {
	original_name: string,
	name: string,
	type: clang.Type,
	pre_comment: string,
	side_comment: string,
}

Macro :: struct {
	original_name: string,
	name: string,
	tokens: []clang.Token,
	is_function: bool,
	has_been_evaluated: bool,
	should_not_output: bool,
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

clang_string_to_string :: proc(str: clang.String) -> string {
	ret := strings.clone_from_cstring(clang.getCString(str))
	clang.disposeString(str)
	return ret
}

c_type_mapping := map[string]string {
	// Platform dependent
	"long"    = "c.long",
	"ulong"   = "c.ulong",

	// Size & wchar
	"size_t"  = "c.size_t",
	"ssize_t" = "c.ssize_t",
	"wchar_t" = "c.wchar_t",

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

	// va_list
	"va_list" = "c.va_list",
}

is_c_type :: proc(type: clang.Type) -> bool {
	return clang_string_to_string(clang.getTypeSpelling(type)) in c_type_mapping
}

// Types that would need "import 'core:sys/posix'".
// Please add and send in a Pull Request if you needed to add anything here!
posix_type_mapping := map[string]string {
	"dev_t"      = "posix.dev_t",
	"blkcnt_t"   = "posix.blkcnt_t",
	"blksize_t"  = "posix.blksize_t",
	"clock_t"    = "posix.clock_t",
	"clockid_t"  = "posix.clockid_t",
	"fsblkcnt_t" = "posix.fsblkcnt_t",
	"off_t"      = "posix.off_t",
	"gid_t"      = "posix.gid_t",
	"pid_t"      = "posix.pid_t",
	"timespec"   = "posix.timespec",
}

is_posix_type :: proc(type: clang.Type) -> bool {
	return clang_string_to_string(clang.getTypeSpelling(type)) in posix_type_mapping
}

// Types that would need `import "core:c/libc"`. 
// Please add and send in a Pull Request if you needed to add anything here!
libc_type_mapping := map[string]string {
	"time_t"       = "libc.time_t",
}

is_libc_type :: proc(type: clang.Type) -> bool {
	return clang_string_to_string(clang.getTypeSpelling(type)) in libc_type_mapping
}

parse_record :: proc(s: ^Gen_State, cursor: clang.Cursor) -> string {
	return clang_string_to_string(clang.getCursorSpelling(cursor))
}

parse_enum :: proc(s: ^Gen_State, cursor: clang.Cursor) -> string {
	return clang_string_to_string(clang.getCursorSpelling(cursor))
}

parse_typedef :: proc(s: ^Gen_State, cursor: clang.Cursor) -> string {
	return clang_string_to_string(clang.getCursorSpelling(cursor))
}

parse_function_type :: proc(s: ^Gen_State, type: clang.Type) -> string {
	builder := strings.builder_make()
	strings.write_string(&builder, "proc ")
	#partial switch clang.getFunctionTypeCallingConv(type) {
	case .X86StdCall:
		strings.write_string(&builder, "\"stdcall\" (")
	case .X86FastCall:
		strings.write_string(&builder, "\"fastcall\" (")
	case:
		strings.write_string(&builder, "\"c\" (")
	}

	cursor := clang.getTypeDeclaration(type)
	for i: i32 = 0; i < clang.Cursor_getNumArguments(cursor); i += 1 {
		param_cursor := clang.Cursor_getArgument(cursor, u32(i))
		param_name := clang_string_to_string(clang.getCursorSpelling(param_cursor))
		
		if param_name == "" {
			strings.write_string(&builder, "_: ")
		} else {
			strings.write_string(&builder, param_name)
			strings.write_string(&builder, ": ")
		}

		strings.write_string(&builder, parse_type(s, param_cursor))
	}
	strings.write_string(&builder, ")")

	return_type := clang.getResultType(type)
	if return_type.kind != .Void {
		strings.write_string(&builder, " -> ")
		strings.write_string(&builder, parse_type(s, clang.getTypeDeclaration(return_type)))
	}

	return strings.to_string(builder)
}

parse_nonfunction_type :: proc(s: ^Gen_State, type: clang.Type) -> string {
	if c_type, exists := c_type_mapping[clang_string_to_string(clang.getTypeSpelling(type))]; exists {
		return c_type
	}

	#partial switch type.kind {
	case .Invalid, .Unexposed, .Void:
		return ""
	case .Long, .ULong, .WChar:
		// We handle these with c_type_mapping
		return ""
	case .Bool:
		return "bool"
	case .Char_U, .UChar:
		return "u8"
	case .UShort:
		return "u16"
	case .UInt:
		return "u32"
	case .ULongLong:
		return "u64"
	case .UInt128:
		return "u128"
	case .Char_S, .SChar:
		return "i8"
	case .Short:
		return "i16"
	case .Int:
		return "i32"
	case .LongLong:
		return "i64"
	case .Int128:
		return "i128"
	case .Float:
		return "f32"
	case .Double, .LongDouble:
		return "f64"
	case .NullPtr:
		return "rawptr"
	case .Complex:
		#partial switch clang.getElementType(type).kind {
		case .Float:
			return "complex64"
		case .Double, .LongDouble:
			return "complex128"
		}
	case .Pointer:
		#partial switch pointee_type := clang.getPointeeType(type); pointee_type.kind {
		case .FunctionProto, .FunctionNoProto:
			builder := strings.builder_make()
			strings.write_byte(&builder, '^')
			strings.write_string(&builder, parse_function_type(s, pointee_type))
			return strings.to_string(builder)
		case:
			pointee_string := parse_nonfunction_type(s, pointee_type)
			if pointee_string == "" {
				return "rawptr"
			} else if pointee_string == "u8" {
				return "cstring"
			} else if pointee_string == "cstring" {
				return "[^]cstring"
			}

			builder := strings.builder_make()
			strings.write_byte(&builder, '^')
			strings.write_string(&builder, pointee_string)
			return strings.to_string(builder)
		}
		panic("Unreachable!")
	case .Record:
		cursor := clang.getTypeDeclaration(type)
		if bool(clang.Cursor_isAnonymous(cursor)) {
			return parse_record(s, cursor)
		}
		return clang_string_to_string(clang.getTypeSpelling(type))
	case .Enum:
		// I'm assumming we can never have an anonymous enum
		return clang_string_to_string(clang.getTypeSpelling(type))
	case .Typedef:
		cursor := clang.getTypeDeclaration(type)
		if bool(clang.Cursor_isAnonymous(cursor)) {
			return parse_typedef(s, cursor)
		}
		return clang_string_to_string(clang.getTypeSpelling(type))
	case .ConstantArray, .Vector:
		// I'm not sure if this is correct for vectors.
		builder := strings.builder_make()
		strings.write_byte(&builder, '[')

		str_conv_buf: [20]byte // 20 == base_10_digit_count(c.SIZE_MAX)
		strings.write_string(&builder, strconv.itoa(str_conv_buf[:], int(clang.getArraySize(type))))

		strings.write_byte(&builder, ']')
		strings.write_string(&builder, parse_nonfunction_type(s, clang.getArrayElementType(type)))
		return strings.to_string(builder)
	case .IncompleteArray, .VariableArray:
		builder := strings.builder_make()
		strings.write_string(&builder, "[^]")
		strings.write_string(&builder, parse_nonfunction_type(s, clang.getArrayElementType(type)))
		return strings.to_string(builder)
	}
	// If we get here then we need to add a new case.
	panic("Unreachable!")
}

parse_type :: proc(s: ^Gen_State, cursor: clang.Cursor) -> string {
	#partial switch type := clang.getCursorType(cursor); type.kind {
	case .FunctionProto, .FunctionNoProto:
		return parse_function_type(s, type)
	case:
		return parse_nonfunction_type(s, type)
	}
	panic("Unreachable!")
}

// For translating type names in procedure parameters and struct fields.
translate_type_string :: proc(s: ^Gen_State, t: string, override: bool) -> string {
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

		return_type := translate_type_string(s, t[:delimiter], false)

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
			strings.write_string(&func_builder, translate_type_string(s, strings.trim_space(param_type), false))
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

	if name, exists := c_type_mapping[t_prefixed]; exists {
		t = name
	} else if name, exists := libc_type_mapping[t_prefixed]; exists {
		t = name
	} else if name, exists := posix_type_mapping[t_prefixed]; exists {
		t = name
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
	opaque_types: []string,
	rename: map[string]string,
	remove_macros: []string,

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
	source: string,
	decls: [dynamic]Declaration,
	macro_defines: map[string]int,
	symbol_indices: map[string]int,
	typedefs: map[string]string,
	created_symbols: map[string]struct {},
	type_is_proc: map[string]struct {},
	opaque_type_lookup: map[string]struct {},
	remove_macros_lookup: map[string]struct {},
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

	for m in c.remove_macros {
		// For quick lookup
		add_to_set(&s.remove_macros_lookup, m)
	}

	//
	// Parse file using libclang and produce an AST.
	//

	clang_args := make([]cstring, 1 + len(c.clang_include_paths) + len(c.clang_defines))
	clang_args[0] = "-fparse-all-comments"

	{
		index := 1
		for &include in c.clang_include_paths {
			clang_args[index] = fmt.ctprintf("-I%v", include)
			index += 1
		}

		for k, v in c.clang_defines {
			clang_args[index] = fmt.ctprintf("-D%s=%s", k, v)
			index += 1
		}
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

	source_data, source_data_ok := os.read_entire_file(input)
	fmt.ensuref(source_data_ok, "Failed reading source file: %v", input)
	s.source = string(source_data)

	get_cursor_location :: proc(cursor: clang.Cursor, file: ^clang.File = nil, offset: ^u32 = nil) -> (line: u32) {
		clang.getExpansionLocation(clang.getCursorLocation(cursor), file, &line, nil, offset)
		return
	}

	get_comment_location :: proc(cursor: clang.Cursor) -> (line: u32) {
		clang.getExpansionLocation(clang.getRangeStart(clang.Cursor_getCommentRange(cursor)), nil, &line, nil, nil)
		return
	}

	type_to_string :: proc(type: clang.Type) -> string {
		return clang_string_to_string(clang.getTypeSpelling(type))
	}

	vet_type :: proc(s: ^Gen_State, type: clang.Type) {
		type := type
		for type.kind == .Pointer {
			type = clang.getPointeeType(type)
		}

		if is_c_type(type) {
			s.needs_import_c = true
		} else if is_libc_type(type) {
			s.needs_import_libc = true
		} else if is_posix_type(type) {
			s.needs_import_posix = true
		}
	}

	// We can probably inline these functions.
	parse_function_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Function {
		// We could probably make use of `clang.Type` here and not store a string.
		// This is easier to implement for now. We can make improvments later.
		return_type := clang.getCursorResultType(cursor)
		vet_type(state, return_type)

		out_params: [dynamic]clang.Cursor

		for i in 0 ..< clang.Cursor_getNumArguments(cursor) {
			param_cursor := clang.Cursor_getArgument(cursor, u32(i))
			#partial switch param_kind := clang.getCursorKind(param_cursor); param_kind {
			case .ParmDecl:
				vet_type(state, clang.getCursorType(param_cursor))
				append(&out_params, param_cursor)
			case:
				// For debugging purposes.
				fmt.printfln("Unexpected cursor kind for parameter: %v", param_kind)
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
			cursor = cursor,
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
				type := clang.getCursorType(cursor)
				if prev_idx := len(data.out_fields) - 1; prev_idx >= 0 && bool(clang.equalTypes(data.out_fields[prev_idx].type, type)) \
				  && data.out_fields[prev_idx].original_line == int(line) {
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
				append(&data.state.decls, Declaration {
					cursor = cursor,
					original_idx = len(data.state.decls),
					variant = parse_record_decl(data.state, cursor),
				})

				if bool(clang.Cursor_isAnonymous(cursor)) {
					append(&data.out_fields, Struct_Field {
						names = [dynamic]string {clang_string_to_string(clang.getCursorSpelling(cursor))},
						type = clang.getCursorType(cursor),
						anon_using = true,
						comment = comment,
						comment_before = comment_before,
						original_line = int(line),
					})
				}
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
			is_anon = bool(clang.Cursor_isAnonymous(cursor)),
		}
	}

	parse_typedef_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Typedef {
		type := clang.getTypedefDeclUnderlyingType(cursor)

		source_range := clang.getCursorExtent(cursor)
		start := clang.getRangeStart(source_range)
		start_offset: c.uint
		clang.getExpansionLocation(start, &state.file, nil, nil, &start_offset)
		side_comment, _ := find_comment_at_line_end(state.source[start_offset:])

		return {
			original_name = clang_string_to_string(clang.getCursorSpelling(cursor)),
			type = type,
			pre_comment = clang_string_to_string(clang.Cursor_getRawCommentText(cursor)),
			side_comment = side_comment,
		}
	}

	parse_enum_decl :: proc(state: ^Gen_State, cursor: clang.Cursor, line: u32) -> Enum {
		out_members: [dynamic]Enum_Member

		backing_type := clang.getEnumDeclIntegerType(cursor)
		vet_type(state, backing_type)

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
			original_name = bool(clang.Cursor_isAnonymous(cursor)) ? "" : clang_string_to_string(clang.getCursorSpelling(cursor)),
			id = clang_string_to_string(clang.getCursorUSR(cursor)),
			comment = clang_string_to_string(clang.Cursor_getRawCommentText(cursor)),
			members = out_members[:],
			backing_type = backing_type,
		}
	}

	parse_macro_decl :: proc(state: ^Gen_State, cursor: clang.Cursor) -> Macro {
		translation_unit := clang.Cursor_getTranslationUnit(cursor)
		source_range := clang.getCursorExtent(cursor)
		
		whitespace_after_name: int
		comment: string
		side_comment: string
		side_comment_align_whitespace: int
		{
			start := clang.getRangeStart(source_range)
			start_offset: c.uint
			clang.getExpansionLocation(start, &state.file, nil, nil, &start_offset)
			end := clang.getRangeEnd(source_range)
			end_offset: c.uint
			clang.getExpansionLocation(end, &state.file, nil, nil, &end_offset)
			macro_source := state.source[start_offset:end_offset]

			//
			// Figure out spacing between name and value
			//
			first_space_seen := false

			for c in macro_source {
				if unicode.is_white_space(c) {
					if !first_space_seen {
						first_space_seen = true
					}

					whitespace_after_name += 1
				} else {
					if first_space_seen {
						break
					}
				}
			}

			//
			// Figure out comments at the end of line
			//
			side_comment, side_comment_align_whitespace = find_comment_at_line_end(state.source[start_offset:])

			//
			// Figure out comments before the macro
			//

			{
				Find_Comment_State :: enum {
					Looking_For_Start,
					Looking_For_Comment,
					Looking_For_Single_Line_Start,
					Verifying_Single_Line,
					Inside_Block_Comment,
				}
				src := state.source
				find_state: Find_Comment_State
				comment_start := -1
				comment_end: int

				comment_loop: for i := int(start_offset); i >= 0; {
					c := utf8.rune_at(src, i)
					defer i -= utf8.rune_size(c)
					switch find_state {
					case .Looking_For_Start:
						if c == '#' {
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

						if !unicode.is_white_space(c) {
							break comment_loop
						}
					case .Inside_Block_Comment:
						if c == '/' && i < len(src) - 1 && src[i + 1] == '*' {
							comment_start = i
							find_state = .Looking_For_Comment
							break
						}
					}
				}

				if comment_start != -1 && comment_end > comment_start {
					comment = strings.trim_space(src[comment_start:comment_end])
				}
			}
		}

		tokens: [^]clang.Token
		token_count: u32
		clang.tokenize(translation_unit, source_range, &tokens, &token_count)

		return {
			original_name = clang_string_to_string(clang.getCursorSpelling(cursor)),
			tokens = tokens[:token_count],
			has_been_evaluated = false,
			is_function = bool(clang.Cursor_isMacroFunctionLike(cursor)),
			comment = comment,
			side_comment = side_comment,
			whitespace_before_side_comment = side_comment_align_whitespace,
			whitespace_after_name = whitespace_after_name,
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
		#partial switch kind {
		case .MacroDefinition:
			if bool(clang.Cursor_isMacroBuiltin(cursor)) {
				return .Continue
			}

			append(&state.decls, Declaration {
				cursor = cursor,
				original_idx = len(state.decls),
				variant = parse_macro_decl(state, cursor),
			})
			return .Continue
		case .FunctionDecl:
			if clang.Cursor_isFunctionInlined(cursor) != 0 {
				return .Continue
			}

			append(&state.decls, Declaration {
				cursor = cursor,
				original_idx = len(state.decls),
				variant = parse_function_decl(state, cursor),
			})
			return .Continue
		}

		// Stops forward declarations from being parsed.
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
		// return bool(clang.isBeforeInTranslationUnit(clang.getCursorLocation(i.cursor), clang.getCursorLocation(j.cursor)))

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
		source := strings.trim_space(s.source)
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

	for &decl, i in s.decls {
		du := &decl.variant
		switch &d in du {
		case Struct:
			if d.is_anon {
				s.symbol_indices[d.original_name] = i
				continue // Skip anonymous structs.
			}

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

			if name in c_type_mapping {
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
			s.macro_defines[name] = i

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
		output_struct :: proc(s: ^Gen_State, d: Struct, indent: int, n: string) -> string {
			w := strings.builder_make()
			ws :: strings.write_string
			ws(&w, "struct ")

			if d.is_union {
				ws(&w, "#raw_union ")
			}

			ws(&w, "{\n")

			longest_field_name_with_side_comment: int

			for &field in d.fields {
				if bool(clang.Cursor_isAnonymous(clang.getTypeDeclaration(field.type))) {
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
						field_type = parse_type(s, clang.getTypeDeclaration(field.type))
					} else {
						field_type = field_type_override
					}
				} else {
					field_type = parse_type(s, clang.getTypeDeclaration(field.type))
				}

				comment := field.comment
				comment_before := field.comment_before

				if bool(clang.Cursor_isAnonymous(clang.getTypeDeclaration(field.type))) {
					decl_index, exists := s.symbol_indices[clang_string_to_string(clang.getCursorSpelling(clang.getTypeDeclaration(field.type)))]
					if exists {
						anon_struct := s.decls[decl_index].variant.(Struct)
						if anon_struct.comment != "" {
							comment = anon_struct.comment
							comment_before = true
						}

						field_type = output_struct(s, anon_struct, indent + 1, n)
					}
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

		du := &decl.variant
		switch &d in du {
		case Struct:
			if d.is_anon {
				continue // Skip anonymous structs.
			}

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

			fp(f, output_struct(&s, d, 0, n))
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
			fpf(f, " :: enum %v {{\n", parse_type(&s, clang.getTypeDeclaration(d.backing_type)))

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
				fpf(f, "%v :: distinct bit_set[%v; %v]\n\n", bit_set_name, name, parse_type(&s, clang.getTypeDeclaration(d.backing_type)))

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

			type_string := type_to_string(d.type)
			if n in s.created_symbols || strings.has_prefix(type_string, "0x") {
				continue
			}

			if parse_type(&s, clang.getTypeDeclaration(d.type)) == d.name {
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

			if strings.has_prefix(type_string, "struct ") {
				// This is a weird case -- I used this for opaque types in the
				// beginning, but opaque types are now handled by
				// `s.opaque_type_lookup`, so perhaps this isn't needed anymore?
				fp(f, "struct {}")
			} else if strings.contains(type_string, "(") && strings.contains(type_string, ")") {
				// function pointer typedef
				fp(f, parse_type(&s, clang.getTypeDeclaration(d.type)))
				add_to_set(&s.type_is_proc, n)
			} else {
				fpf(f, "%v", parse_type(&s, clang.getTypeDeclaration(d.type)))
			}

			if d.side_comment != "" {
				fp(f, ' ')
				fp(f, d.side_comment)
			}

			fp(f, "\n\n")

		case Macro:
			// I'm not particularly proud of this implementation.
			// It could probably be massively simplified and improved.

			parse_literal :: proc(token_str: string) -> string {
				switch token_str[0] {
				case '0'..='9':
					token_str := token_str
					if len(token_str) == 1 {
						return token_str
					}

					hex := false
					if token_str[1] == 'x' {
						hex = true
					} else if token_str[1] == 'X' {
						hex = true
						// Odin requires hex x to be lowercase.
						tmp := transmute([]u8)(token_str)
						tmp[1] = 'x'
					}

					index := len(token_str) - 1
					LOOP: for ; index > 0; index -= 1 {
						switch token_str[index] {
						case 'L', 'l', 'U', 'u':
							// These are suffixes for long and unsigned literals.
							continue LOOP
						case 'F', 'f':
							if hex {
								break LOOP
							}
							// Floating point literals can have 'F' or 'f' suffixes.
							continue LOOP
						case:
							// Not a suffix char.
							break LOOP
						}
					}
					return token_str[:index + 1]
				case '"':
					// String literal
					// We'll need to make some considerations here when we want to handle '#' operations.
					return token_str
				}
				return token_str
			}

			parse_identifier :: proc(state: ^Gen_State, cursor: clang.Cursor, macro: ^Macro, index: int) -> (string, int) {
				// Could be a type or macro name. Could also be the name of a function or variable.
				tu := clang.Cursor_getTranslationUnit(cursor)
				token := macro.tokens[index]
				token_str := clang_string_to_string(clang.getTokenSpelling(tu, token))
				if token_str in c_type_mapping {
					return translate_type_string(state, token_str, false), 0
				} else if decl_index, exists := state.macro_defines[token_str]; exists {
					val, offset := expand_inner_macro(state, cursor, macro, &state.decls[decl_index], index)
					if !state.decls[decl_index].variant.(Macro).should_not_output {
						val = state.decls[decl_index].variant.(Macro).name
					}
					return val, offset
				} else if token_str == "true" || token_str == "false" {
					return token_str, 0	
				}
				return "", 0
			}

			parse_format_string :: proc(str: string, args: []string) -> string {
				// Replaces ${0}, ${1}, etc. with the corresponding argument.
				builder := strings.builder_make()
				for i := 0; i < len(str); i += 1 {
					if i + 1 < len(str) && str[i] == '$' && str[i + 1] == '{' {
						i += 2
						for j := i; j < len(str); j += 1 {
							if str[j] == '}' {
								strings.write_string(&builder, args[strconv.atoi(str[i:j])])
								i = j
								break
							}
						}
					} else {
						strings.write_byte(&builder, str[i])
					}
				}
				return strings.to_string(builder)
			}

			get_fn_macro_params :: proc(state: ^Gen_State, cursor: clang.Cursor, macro: ^Macro, index: int) -> ([]string, int) {
				if index >= len(macro.tokens) {
					return nil, 0 // No parameters.
				}
				
				tu := clang.Cursor_getTranslationUnit(cursor)

				{
					token_str := clang_string_to_string(clang.getTokenSpelling(tu, macro.tokens[index]))
					if token_str[0] != '(' {
						return nil, 0 // No parameters.
					}
				}

				params: [dynamic]string
				builder := strings.builder_make()
				for loop_index := index; loop_index < len(macro.tokens); loop_index += 1 {
					token := macro.tokens[loop_index]

					paren_count := 1
					token_str := clang_string_to_string(clang.getTokenSpelling(tu, token))
					#partial switch clang.getTokenKind(token) {
					case .Punctuation:
						switch token_str[0] {
						case '(':
							paren_count += 1
						case ')':
							paren_count -= 1
							if paren_count == 0 {
								append(&params, strings.to_string(builder))
								return params[:], loop_index - index + 1
							}
						case ',':
							if paren_count == 1 {
								append(&params, strings.to_string(builder))
								builder = strings.builder_make() // Reset the builder for the next parameter.
							}
						}
					case .Keyword:
						if token_str in c_type_mapping {
							strings.write_string(&builder, translate_type_string(state, token_str, false))
						}
					case .Identifier:
						val, offset := parse_identifier(state, cursor, macro, loop_index)
						loop_index += offset
						if val == "" {
							// macro.should_not_output = true
							val = token_str // Fallback to the original token string.
						}

						if strings.contains_rune(val, ',') {
							encapsulation := 0
							for r in val {
								switch r {
								case '(':
									encapsulation += 1
								case ')':
									encapsulation -= 1
								case ',':
									if encapsulation == 0 {
										// We found a comma at the top level, so we need to split this parameter.
										append(&params, strings.to_string(builder))
										builder = strings.builder_make() // Reset the builder for the next parameter.
										continue
									}
								case:
									strings.write_rune(&builder, r)
								}
							}
						} else {
							strings.write_string(&builder, val)
						}
					case .Literal:
						strings.write_string(&builder, parse_literal(token_str))
					}
				}
				return nil, 0 // We didn't find the closing parenthesis.
			}

			expand_inner_macro :: proc(state: ^Gen_State, cursor: clang.Cursor, macro: ^Macro, decl: ^Declaration, index: int) -> (val: string, offset: int) {
				decl_macro := &decl.variant.(Macro)
				if !decl_macro.has_been_evaluated {
					evaluate_macro(state, decl.cursor, decl_macro)
				}

				if decl_macro.is_function {
					params: []string
					params, offset = get_fn_macro_params(state, cursor, macro, index + 1)
					if params == nil {
						// We couldn't find the parameters.
						macro.should_not_output = true
						return "", 0
					}

					parsed_fn_string := parse_format_string(decl_macro.val, params)
					if parsed_fn_string == "" {
						// Couldn't parse the function macro.
						// Parameters were probably wrong.
						macro.should_not_output = true
						return "", 0
					}

					val = parsed_fn_string
				} else {
					val = decl_macro.val
				}
				return
			}

			evaluate_fn_macro :: proc(state: ^Gen_State, cursor: clang.Cursor, macro: ^Macro) {
				macro.should_not_output = true
				params, offset := get_fn_macro_params(state, cursor, macro, 1)
				if params == nil {
					// We couldn't find the parameters.
					return
				}

				paramsMap: map[string]int
				for p, i in params {
					paramsMap[p] = i
				}
				
				tu := clang.Cursor_getTranslationUnit(cursor)
				builder := strings.builder_make()
				for index := offset + 1; index < len(macro.tokens); index += 1 {
					token := macro.tokens[index]

					token_str := clang_string_to_string(clang.getTokenSpelling(tu, token))

					if replace_val, has_replace := paramsMap[token_str]; has_replace {
						// If the token is a parameter, replace it with the corresponding value.
						buf: [10]byte // We can have upto 10 digits
						strings.write_string(&builder, "${")
						strings.write_string(&builder, strconv.itoa(buf[:], replace_val))
						strings.write_rune(&builder, '}')
						continue
					}

					#partial switch clang.getTokenKind(token) {
					case .Punctuation:
						switch token_str[0] {
						case '#':
							macro.should_not_output = true
							strings.write_string(&builder, token_str)
						case:
							strings.write_string(&builder, token_str)
						}
					case .Keyword:
						if token_str in c_type_mapping {
							strings.write_string(&builder, translate_type_string(state, token_str, false))
						}
					case .Identifier:
						val, offset2 := parse_identifier(state, cursor, macro, index)
						index += offset2
						if val == "" {
							// macro.should_not_output = true
							val = token_str // Fallback to the original token string.
						}
						strings.write_string(&builder, val)
					case .Literal:
						val := parse_literal(token_str)
						if val == "" {
							macro.should_not_output = true
							val = token_str // Fallback to the original token string.
						}
						strings.write_string(&builder, val)
					}
				}
				macro.val = strings.to_string(builder)
			}

			evaluate_nonfn_macro :: proc(state: ^Gen_State, cursor: clang.Cursor, macro: ^Macro) {
				builder := strings.builder_make()
				curly_parens := 0
				for index := 1; index < len(macro.tokens); index += 1 {
					token := macro.tokens[index]
					tu := clang.Cursor_getTranslationUnit(cursor)
					token_str := clang_string_to_string(clang.getTokenSpelling(tu, token))

					#partial switch clang.getTokenKind(token) {
					case .Identifier:
						val, offset := parse_identifier(state, cursor, macro, index)
						index += offset
						if val == "" {
							// macro.should_not_output = true
							val = token_str // Fallback to the original token string.
						}
						strings.write_string(&builder, val)
					case .Literal:
						val := parse_literal(token_str)
						if val == "" {
							macro.should_not_output = true
							val = token_str // Fallback to the original token string.
						}
						strings.write_string(&builder, val)
					case .Punctuation:
						switch token_str[0] {
						case '#':
							macro.should_not_output = true
							strings.write_string(&builder, token_str)
						case '{':
							// If we hit a curly brace, we need to count how many we have.
							curly_parens += 1
							strings.write_string(&builder, token_str)
						case '}':
							curly_parens -= 1
							strings.write_string(&builder, token_str)
						case ',':
							if curly_parens == 0 {
								// If we are not in a parenthesis, we can't output a comma.
								macro.should_not_output = true
							}
							strings.write_string(&builder, token_str)
							strings.write_rune(&builder, ' ')
						case:
							// +, -, /, *, etc.
							strings.write_string(&builder, token_str)
						}
					case .Keyword:
						if token_str in c_type_mapping {
							strings.write_string(&builder, translate_type_string(state, token_str, false))
						}
					}
				}
				macro.val = strings.to_string(builder)
				if macro.val == "" {
					macro.should_not_output = true // Empty macro, we don't want to output it.
				}
			}

			evaluate_macro :: proc(state: ^Gen_State, cursor: clang.Cursor, macro: ^Macro) {
				// I set this to true before evaluating the macro to avoid infinite recursion.
				// This is just a guard against a macro that calls itself.
				macro.has_been_evaluated = true
				if macro.is_function {
					evaluate_fn_macro(state, cursor, macro)
				} else {
					evaluate_nonfn_macro(state, cursor, macro)
				}
			}

			if d.is_function {
				continue
			}

			if !d.has_been_evaluated {
				evaluate_macro(&s, decl.cursor, &d)
			}

			if d.val == "{}" || d.val == "{0}" {
				continue
			}

			if d.comment != "" {
				fpln(f, d.comment)
			}

			if d.should_not_output || d.original_name in s.remove_macros_lookup {
				// When we're happy with the parser this can change to a continue.
				fp(f, "// ")
			}

			fpf(f, "%v%*s:: %v", d.name, max(d.whitespace_after_name, 1), "", d.val)

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

	for _, index in s.macro_defines {
		decl := &s.decls[index]
		tu := clang.Cursor_getTranslationUnit(decl.cursor)
		clang.disposeTokens(tu, raw_data(decl.variant.(Macro).tokens), u32(len(decl.variant.(Macro).tokens)))
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
					n := vet_name(clang_string_to_string(clang.getCursorSpelling(p)))

					type: string
					type_override_key := fmt.tprintf("%v.%v", d.original_name, n)

					if type_override, type_override_ok := s.procedure_type_overrides[type_override_key]; type_override_ok {
						switch type_override {
						case "#by_ptr":
							type = strings.trim_prefix(parse_type(&s, p), "^")
							w(&b, "#by_ptr ")
						case "[^]":
							type = parse_type(&s, p)
						case:
							type = type_override
						}
					} else {
						type = parse_type(&s, p)
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

				return_type := clang.getResultType(clang.getCursorType(d.cursor))
				if return_type.kind != .Void {
					w(&b, " -> ")

					return_type_string: string

					if override, override_ok := s.procedure_type_overrides[d.original_name]; override_ok {
						switch override {
						case "[^]":
							return_type_string = parse_type(&s, clang.getTypeDeclaration(return_type))
						case:
							return_type_string = override
						}
					} else {
						return_type_string = parse_type(&s, clang.getTypeDeclaration(return_type))
					}

					w(&b, return_type_string)
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
