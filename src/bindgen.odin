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
import "core:strconv"
import "core:unicode/utf8"
import "core:unicode"
import "core:slice"

Struct_Field :: struct {
	names: [dynamic]string,
	type: string,
	comment: string,
	comment_before: bool,
	original_line: int,
}

Struct :: struct {
	name: string,
	id: string,
	fields: []Struct_Field,
	comment: string,
	is_union: bool,
}

Function_Parameter :: struct {
	name: string,
	type: string,
}

Function :: struct {
	name: string,
	parameters: []Function_Parameter,
	return_type: string,
	comment: string,
	comment_before: bool,
	post_comment: string,
}

Enum_Member :: struct {
	name: string,
	value: Maybe(int),
	comment: string,
	comment_before: bool,
}

Enum :: struct {
	name: string,
	id: string,
	members: []Enum_Member,
	comment: string,
}

Typedef :: struct {
	name: string,
	type: string,
	pre_comment: string,
	side_comment: string,
}

Declaration :: union {
	Struct,
	Function,
	Enum,
	Typedef,
}

get_parameter_type :: proc(s: ^Gen_State, v: json.Value) -> (type: string, ok: bool) {
	t := json_get(v, "type.qualType", json.String) or_return

	if is_c_type(t) {
		s.needs_import_c = true
	}

	if is_libc_type(t) {
		s.needs_import_libc = true
	}

	if is_posix_type(t) {
		s.needs_import_posix = true
	}

	return t, true
}

get_return_type :: proc(v: json.Value) -> (type: string, ok: bool) {
	qual_type := json_get(v, "type.qualType", json.String) or_return
	end := strings.index(qual_type, "(")
	t := qual_type

	if end != -1 {
		t = qual_type[:end]
	}

	t = strings.trim_space(t)

	if t == "void" {
		return "", false
	}

	return t, true
}

find_side_comment :: proc(start_offset: int, s: ^Gen_State) -> (side_comment: string, ok: bool) {
	comment_start: int
	semicolon_pos: int
	for i in start_offset..<len(s.source) {
		if s.source[i] == ';' {
			semicolon_pos = i
		}

		if semicolon_pos > 0 && i+2 < len(s.source) {
			// Comments after proc starting with `//` are not picked up, but
			// those with `///` are picked up.
			if s.source[i] == '/' && s.source[i + 1] == '/' && s.source[i + 2] != '/' {
				comment_start = i
			}
		}

		if s.source[i] == '\n' {
			if comment_start != 0 {
				side_comment = s.source[comment_start:i]
				ok = true
			}
			return
		}
	}
	return
}

parse_decl :: proc(s: ^Gen_State, decl: json.Value) {
	if json_has(decl, "loc.includedFrom") {
		return
	}

	if json_has(decl, "loc.expansionLoc.includedFrom") {
		return
	}

	if json_check_bool(decl, "isImplicit") {
		return
	}
	
	kind, kind_ok := json_get_string(decl, "kind")

	if !kind_ok {
		return
	}

	id, id_ok := json_get_string(decl, "id")

	if !id_ok {
		return
	}

	if kind == "FunctionDecl" {
		name, name_ok := json_get_string(decl, "name")

		if !name_ok {
			return
		}

		line, line_ok := json_get_int(decl, "loc.line")

		if !line_ok {
			return
		}

		return_type, has_return_type := get_return_type(decl)
		out_params: [dynamic]Function_Parameter
		comment: string
		comment_before: bool

		if params, params_ok := json_get_array(decl, "inner"); params_ok {
			for &p in params {
				pkind := json_get_string(p, "kind") or_continue

				if pkind == "ParmVarDecl" {
					param_name := json_get_string(p, "name") or_continue
					param_type := get_parameter_type(s, p) or_continue
					append(&out_params, Function_Parameter {
						name = param_name,
						type = param_type,
					})
				} else if pkind == "FullComment" {
					com, com_line, com_line_ok, comment_ok := get_comment_with_line(p, s)

					if comment_ok {
						comment = com

						if com_line_ok {
							comment_before = com_line < int(line)
						}
					}
				}
			}
		}

		side_comment: string

		if end_offset, end_offset_ok := json_get_int(decl, "range.end.offset"); end_offset_ok {
			side_comment, _ = find_side_comment(end_offset, s)
		}

		append(&s.decls, Function {
			name = name,
			parameters = out_params[:],
			return_type = has_return_type ? return_type : "",
			comment = comment,
			comment_before = comment_before,
			post_comment = side_comment,
		})
	} else if kind == "RecordDecl" {
		name, name_ok := json_get_string(decl, "name")

		if !name_ok {
			return
		}

		out_fields: [dynamic]Struct_Field
		comment: string

		if inner, fields_ok := json_get_array(decl, "inner"); fields_ok {
			prev_idx := -1
			for &i in inner {
				i_kind := json_get_string(i, "kind") or_continue
				if i_kind == "FieldDecl" {
					field_name := json_get_string(i, "name") or_continue
					field_type := get_parameter_type(s, i) or_continue
					field_comment: string
					field_comment_before: bool
					field_line, field_line_ok := json_get_int(i, "loc.line")

					if field_inner, field_inner_ok := json_get_array(i, "inner"); field_inner_ok {
						for &fi in field_inner {
							fi_kind := json_get_string(fi, "kind") or_continue

							if fi_kind == "FullComment" {
								com, com_line, com_line_ok, comment_ok := get_comment_with_line(fi, s)

								if comment_ok {
									field_comment = com

									if com_line_ok {
										field_comment_before = !field_line_ok || com_line < int(field_line)
									}
								}
							}
						}
					}

					merge: bool
					if prev_idx != -1 {
						prev := &out_fields[prev_idx]

						if field_line_ok {
							if prev.original_line == field_line && prev.type == field_type {
								merge = true
							}
						} else if prev.type == field_type {
							merge = true
						}
					}

					if merge {
						assert(prev_idx != -1, "Merge requested by prev_idx == -1")
						prev := &out_fields[prev_idx]
						append(&prev.names, field_name)
					} else {
						prev_idx = len(out_fields)
						f := Struct_Field {
							type = field_type,
							comment = field_comment,
							comment_before = field_comment_before,
							original_line = field_line, 
						}
						append(&f.names, field_name)
						append(&out_fields, f)
					}
				} else if i_kind == "FullComment" {
					comment, _ = get_comment(i, s)
				}
			}
		}

		if forward_idx, forward_declared := s.symbol_indices[name]; forward_declared {
			s.decls[forward_idx] = nil
		}

		s.symbol_indices[name] = len(s.decls)

		append(&s.decls, Struct {
			name = name,
			id = id,
			comment = comment,
			fields = out_fields[:],
			is_union = (json_get_string(decl, "tagUsed") or_else "") == "union",
		})
	} else if kind == "TypedefDecl" {
		type, type_ok := get_parameter_type(s, decl)

		if !type_ok {
			return
		}

		name, _ := json_get_string(decl, "name")
		line, line_ok := json_get_int(decl, "loc.line")
		pre_comment: string
		side_comment: string

		if typedef_inner, typedef_inner_ok := json_get_array(decl, "inner"); typedef_inner_ok {
			for &i in typedef_inner {
				inner_kind := json_get_string(i, "kind") or_continue

				if inner_kind == "ElaboratedType" {
					if typedeffed_id, typedeffed_id_ok := json_get_string(i, "ownedTagDecl.id"); typedeffed_id_ok {
						type = typedeffed_id
					}	
				} else if inner_kind == "FullComment" {
					comment, comment_line, comment_line_ok, comment_ok := get_comment_with_line(i, s)

					if comment_ok {
						if comment_line_ok {
							if line_ok {
								if comment_line < line {
									pre_comment = comment	
								} else {
									side_comment = comment
								}
							}
						} else {
							pre_comment = comment
						}
					}
				}
			}
		}

		if end_offset, end_offset_ok := json_get_int(decl, "range.end.offset"); end_offset_ok {
			side_comment, _ = find_side_comment(end_offset, s)
		}

		s.typedefs[type] = name
		append(&s.decls, Typedef {
			name = name,
			type = type,
			pre_comment = pre_comment,
			side_comment = side_comment,
		})
	} else if kind == "EnumDecl" {
		name, _ := json_get_string(decl, "name")
		comment: string
		out_members: [dynamic]Enum_Member

		if inner, inner_ok := json_get_array(decl, "inner"); inner_ok {
			for &m in inner {
				inner_kind := json_get_string(m, "kind") or_continue

				if inner_kind == "EnumConstantDecl" {
					member_name := json_get_string(m, "name") or_continue
					member_value: Maybe(int)
					member_comment: string
					member_comment_before: bool
					member_line, member_line_ok := json_get_int(m, "loc.line")

					if values, values_ok := json_get_array(m, "inner"); values_ok {
						for &vv in values {
							value_kind := json_get_string(vv, "kind") or_continue

							if value_kind == "ConstantExpr" {
								value := json_get_string(vv, "value") or_continue
								member_value = strconv.atoi(value)
							} else if value_kind == "FullComment" {
								com, com_line, com_line_ok, comment_ok := get_comment_with_line(vv, s)

								if comment_ok {
									member_comment = com

									if com_line_ok && member_line_ok {
										member_comment_before = com_line < int(member_line)
									}
								}
							}
						}
					}

					append(&out_members, Enum_Member {
						name = member_name,
						value = member_value,
						comment = member_comment,
						comment_before = member_comment_before,
					})
				} else if inner_kind == "FullComment" {
					comment, _ = get_comment(m, s)
				}
			}
		}

		append(&s.decls, Enum {
			name = name,
			id = id,
			comment = comment,
			members = out_members[:],
		})
	}
}

get_comment_with_line :: proc(v: json.Value, s: ^Gen_State) -> (comment: string, line: int, line_ok: bool, ok: bool) {
	comment, ok = get_comment(v, s)
	if line_i64, line_i64_ok := json_get(v, "loc.line", json.Integer); line_i64_ok {
		line = int(line_i64)
		line_ok = true
	}
	return
}

get_comment :: proc(v: json.Value, s: ^Gen_State) -> (comment: string, ok: bool) {
	begin := int(json_get(v, "range.begin.offset", json.Integer) or_return)
	end := int(json_get(v, "range.end.offset", json.Integer) or_return)

	// This makes sure to add in the starting `//` and any ending `*/` that clang
	// might not have included in the comment.

	double_slash_found := false

	for idx := int(begin); idx >= 0; idx -= 1 {
		if idx + 2 >= len(s.source) {
			continue
		}

		cur := s.source[idx:idx+2]
		if cur == "//" {
			begin = idx
			double_slash_found = true
		}

		if cur == "/*" {
			begin = idx
			break
		}

		if s.source[idx] == '\n' && double_slash_found {
			break
		}
	}

	cmt := s.source[begin:end+1]

	num_block_openings := strings.count(cmt, "/*")
	num_block_closing := strings.count(cmt, "*/")

	if num_block_openings != num_block_closing {
		for idx in end..<len(s.source) - 2 {
			cur := s.source[idx:idx+2]

			if cur == "*/" {
				end = idx+1
				break
			}
		}
	}

	return s.source[begin:end+1], true
}

trim_prefix :: proc(s: string, p: string) -> string {
	return strings.trim_prefix(strings.trim_prefix(s, p), "_")
}

final_name :: proc(s: string, state: Gen_State) -> string {
	if replacement, has_replacement := state.rename_types[s]; has_replacement {
		return replacement
	}

	return s
}

is_c_type :: proc(t: string) -> bool{
	base_type := strings.trim_suffix(t, "*")
	base_type = strings.trim_space(base_type)
	return base_type in c_type_mapping
}

// Types that would need `import "core:c/libc"`
is_libc_type :: proc(t: string) -> bool{
	base_type := strings.trim_suffix(t, "*")
	base_type = strings.trim_space(base_type)

	switch t {
	case "time_t":
		return true
	}

	return false
}

//Types that would require "import 'core:sys/posix'"
is_posix_type :: proc(t:string) -> bool {
	base_type := strings.trim_suffix(t,"*")
	base_type = strings.trim_space(base_type)
	switch t {
		case "dev_t" : return true
		case "blkcnt_t": return true
		case "blksize_t" : return true
		case "clock_t" : return true
		case "clockid_t": return true
		case "fsblkcnt_t" : return true
		case "off_t" : return true
		case "gid_t": return true
		case "pid_t":  return true
		case "timespec": return true
	}
	return false
}

// This is probably missing some built-in C types (or common types that come
// from stdint.h etc). Please add and send in a Pull Request if you needed to
// add anything here!
c_type_mapping := map[string]string {
	"ssize_t" = "int",
	"size_t" = "uint",
	"float" = "f32",
	"double" = "f64",
	"int" = "i32",
	"char" = "u8",
	"unsigned short" = "u16",
	"unsigned char" = "u8",
	"unsigned int" = "u32",
	"unsigned long" = "c.ulong",
	"Bool" = "bool",
	"BOOL" = "bool",
	"long" = "c.long",
	"uint8_t" = "u8",
	"int8_t" = "i8",
	"uint16_t" = "u16",
	"int16_t" = "i16",
	"uint32_t" = "u32",
	"int32_t" = "i32",
	"uint64_t" = "u64",
	"int64_t" = "i64",
	"uintptr_t" = "uintptr",
	"ptrdiff_t" = "int",
}

// TODO: Replace this whole proc with something smarter. Perhaps make a small
// library that can take a C type and returns an Odin type, and it does the
// correct tokenization and analysis of it.
translate_type :: proc(s: Gen_State, t: string) -> string {
	t := t
	t = strings.trim_space(t)

	if strings.contains(t, "(") && strings.contains(t, ")") && !strings.contains(t, ")[") {
		// function pointer typedef

		delimiter := strings.index(t, "(*)(")
		remainder_start := delimiter + 4

		if delimiter == -1 {
			delimiter = strings.index(t, "(")
			remainder_start = delimiter + 1
		}

		return_type := translate_type(s, t[:delimiter])

		func_builder := strings.builder_make()

		strings.write_string(&func_builder, `proc "c" (`)

		remainder := t[remainder_start:len(t)-1]

		first := true

		for param_type in strings.split_iterator(&remainder, ",") {
			if first {
				first = false
			} else {
				strings.write_string(&func_builder, ", ")
			}
			strings.write_string(&func_builder, translate_type(s, strings.trim_space(param_type)))
		}

		if return_type == "void" {
			strings.write_string(&func_builder, ")")
		} else {
			strings.write_string(&func_builder, fmt.tprintf(") -> %v", return_type))
		}

		return strings.to_string(func_builder)
	}

	if t == "void *" || t == "const void *" {
		return "rawptr"
	}

	if t == "const char *const *" {
		return "[^]cstring"
	}

	switch t {
	case "const char *", "char *":
		return "cstring"
	}

	if t == "va_list" {
		return "^c.va_list"
	}

	num_ptrs := strings.count(t, "*")

	base_type: string

	if strings.contains(t, "(*)") {
		base_type = t
	} else {
		base_type, _ = strings.remove_all(t, "*")
	}

	base_type, _ = strings.remove_all(base_type, "const ")
	base_type = strings.trim_space(base_type)
	base_type = trim_prefix(base_type, "struct ")
	base_type = trim_prefix(base_type, "enum ")
	base_type = strings.trim_space(base_type)
	if base_type != s.remove_type_prefix {
		base_type = trim_prefix(base_type, s.remove_type_prefix)
	}
	base_type = strings.trim_space(base_type)

	transf_type := base_type

	multi_array := strings.index(base_type, "(*)")
	array_start := strings.index(base_type, "[")
	array_end := strings.last_index(base_type, "]")

	if multi_array != -1 {
		transf_type = transf_type[:multi_array]
	} else if array_start != -1 {
		transf_type = transf_type[:array_start]
	}

	transf_type = strings.trim_space(transf_type)

	if is_c_type(transf_type) {
		transf_type = c_type_mapping[transf_type]
	} else if is_libc_type(transf_type) {
		transf_type = fmt.tprintf("libc.%v", transf_type)
	}
	else if is_posix_type(transf_type) {
		transf_type = fmt.tprintf("posix.%v",transf_type)
	}

	if s.force_ada_case_types {
		ada := strings.to_ada_case(final_name(transf_type, s))
		if ada in s.created_types {
			transf_type = ada
		}
	} else {
		transf_type = final_name(vet_name(transf_type), s)
	}

	if array_start != -1 {
		transf_type = fmt.tprintf("%s%s%s", multi_array != -1 ? "[^]" : "", base_type[array_start:array_end + 1], transf_type)
	}

	b := strings.builder_make()

	if num_ptrs > 0 {
		if transf_type in s.type_is_proc {
			num_ptrs -= 1
		}

		if multi_array != -1 {
			num_ptrs -= 1
		}
	}

	for _ in 0..<num_ptrs{
		strings.write_string(&b, "^")
	}

	strings.write_string(&b, transf_type)

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

	// Because we import these two
	"_c",
	"_libc",
	"_posix"
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
	remove_prefix: string,
	remove_type_prefix: string,
	remove_function_prefix: string,
	import_lib: string,
	imports_file: string,
	clang_include_paths: []string,
	force_ada_case_types: bool,
	debug_dump_json_ast: bool,

	opaque_types: []string,
	rename_types: map[string]string,
	type_overrides: map[string]string,
	struct_field_overrides: map[string]string,
	procedure_type_overrides: map[string]string,
	bit_setify: map[string]string,
	inject_before: map[string]string,
}

Gen_State :: struct {
	using config: Config,

	source: string,
	decls: [dynamic]Declaration,
	symbol_indices: map[string]int,
	typedefs: map[string]string,
	created_symbols: map[string]struct{},
	type_is_proc: map[string]struct{},
	opaque_type_lookup: map[string]struct{},
	created_types: map[string]struct{},
	needs_import_c: bool,
	needs_import_libc: bool,
	needs_import_posix:bool
}

gen :: proc(input: string, c: Config) {
	// Everything allocated within this call to `gen` is allocated on a single
	// arena, which is destroyed when this procedure ends.

	// Disabled due to bug in virtual growing allocator: https://github.com/odin-lang/Odin/issues/4834
	/*gen_arena: vmem.Arena
	defer vmem.arena_destroy(&gen_arena)
	context.allocator = vmem.arena_allocator(&gen_arena)
	context.temp_allocator = vmem.arena_allocator(&gen_arena)*/

	s := Gen_State {
		config = c, 
	}

	for ot in c.opaque_types {
		// For quick lookup
		add_to_set(&s.opaque_type_lookup, ot)
	}

	//
	// Run clang and produce an AST in json format that describes the headers.
	//

	command := [dynamic]string {
		"clang", "-Xclang", "-ast-dump=json", "-fparse-all-comments", "-c",  input,
	}

	if len(c.clang_include_paths) != 0 {
		for include in c.clang_include_paths {
			append(&command, fmt.tprintf("-I%v", include))
		}
	}

	process_desc := os2.Process_Desc {
		command = command[:],
	}

	state, sout, serr, err := os2.process_exec(process_desc, context.allocator)

	if err != nil {
		if err == .Not_Exist {
			panic("Could not find clang. Do you have clang installed and in your path?")
		}

		fmt.panicf("Error generating ast dump. Error: %v", err)
	}

	if len(serr) > 0 {
		fmt.eprintln(string(serr))
		fmt.eprintfln("Aborting generation for %v", input)
		return
	}

	ensure(state.success, "Failed running clang")

	input_filename := filepath.base(input)
	output_stem := filepath.stem(input_filename)
	output_filename := fmt.tprintf("%v/%v.odin", s.output_folder, output_stem)
	
	if s.debug_dump_json_ast {
		os.write_entire_file(fmt.tprintf("%v-debug_dump.json", output_filename), sout)
	}

	json_in, json_in_err := json.parse(sout, parse_integers = true)

	if json_in_err != nil {
		fmt.eprintfln("Error parsing json: %v. %v", json_in_err, string(serr))
		fmt.eprintfln("Aborting generation for %v", input)
		return
	}

	// We use the header source text to extract some comments.
	source_data, source_data_ok := os.read_entire_file(input)
	fmt.ensuref(source_data_ok, "Failed reading source file: %v", input)
	s.source = string(source_data)

	inner := json_in.(json.Object)["inner"].(json.Array)

	//
	// Turn the JSON into an intermediate format (parse_decls will append stuff
	// to s.decls)
	//

	for &in_decl in inner {
		if s.required_prefix != "" {
			if name, name_ok := json_get_string(in_decl, "name"); name_ok {
				if !strings.has_prefix(name, s.required_prefix) {
					continue
				}
			}		
		}

		parse_decl(&s, in_decl)
	}

	//
	// Use the stuff in `s` and `s.decl` to write out the bindings.
	//

	f, f_err := os.open(output_filename, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644)

	fmt.ensuref(f_err == nil, "Failed opening %v", output_filename)
	defer os.close(f)

	// Extract any big comment at top of file (clang doesn't see these)
	{
		src := strings.trim_space(s.source)
		in_block := false

		top_comment_loop: for ll in strings.split_lines_iterator(&src) {
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

	if(s.needs_import_posix) {
		fpln(f,`import "core:sys/posix"`)
	}

	fp(f, "\n")

	if s.needs_import_c {
		fpln(f, "_ :: c")
	}
	if s.needs_import_libc {
		fpln(f, "_ :: libc")
	}
	if s.needs_import_posix {
		fpln(f,"_ :: posix")
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

	for &du in s.decls {
		switch &d in du {
			case Struct:
				name := d.name

				if typedef, has_typedef := s.typedefs[d.id]; has_typedef {
					name = typedef
					add_to_set(&s.created_symbols, trim_prefix(name, s.remove_type_prefix))
				}

				name = trim_prefix(name, s.remove_type_prefix)

				if s.force_ada_case_types {
					name = strings.to_ada_case(name)
				}

				d.name = final_name(vet_name(name), s)
				add_to_set(&s.created_types, d.name)
			case Function:
			case Enum:
				name := d.name

				if typedef, has_typedef := s.typedefs[d.id]; has_typedef {
					name = typedef
					add_to_set(&s.created_symbols, trim_prefix(name, s.remove_type_prefix))
				}

				name = trim_prefix(name, s.remove_type_prefix)

				if s.force_ada_case_types {
					name = strings.to_ada_case(name)
				}

				d.name = final_name(vet_name(name), s)
				add_to_set(&s.created_types, d.name)
			case Typedef:
				name := d.name

				if is_c_type(name) {
					continue
				}

				name = trim_prefix(name, s.remove_type_prefix)

				if s.force_ada_case_types {
					name = strings.to_ada_case(name)
				}

				name = final_name(name, s)
				d.name = name
				add_to_set(&s.created_types, d.name)

		}
	}

	for _, b in s.bit_setify {
		add_to_set(&s.created_types, b)
	}

	for &du in s.decls {
		switch d in du {
		case Struct:
			output_comment(f, d.comment)

			n := d.name

			if inject, has_injection := s.inject_before[n]; has_injection {
				fpf(f, "%v\n\n", inject)
			}

			fp(f, n)
			fp(f, " :: ")

			if override, override_ok := s.type_overrides[n]; override_ok {
				fp(f, override)
				fp(f, "\n\n")
				break
			}

			fp(f, "struct ")

			if d.is_union {
				fp(f, "#raw_union ")
			}

			fp(f, "{\n")

			longest_field_name_with_side_comment: int

			for &field in d.fields {
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
				field: string,
				comment: string,
				comment_before: bool,
			}

			fields: [dynamic]Formatted_Field

			for &field in d.fields {
				b := strings.builder_make()

				for fn, nidx in field.names {
					if nidx != 0 {
						strings.write_string(&b, ", ")
					}

					strings.write_string(&b, vet_name(fn))
				}

				names_len := strings.builder_len(b)
				override_key := fmt.tprintf("%s.%s", n, strings.to_string(b))

				strings.write_string(&b, ": ")

				if !field.comment_before {
					// Padding between name and =
					for _ in 0..<longest_field_name_with_side_comment-names_len {
						strings.write_rune(&b, ' ')
					}
				}
				
				field_type := translate_type(s, field.type)

				if field_type_override, has_field_type_override := s.struct_field_overrides[override_key]; has_field_type_override {
					if field_type_override == "[^]" {
						// Change first `^` for `[^]`
						field_type = fmt.tprintf("[^]%v", strings.trim_prefix(field_type, "^"))
					} else {
						field_type = field_type_override
					}
				}

				strings.write_string(&b, field_type)

				append(&fields, Formatted_Field {
					field = strings.to_string(b),
					comment = field.comment,
					comment_before = field.comment_before,
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
						fp(f, "\n")
					}
					output_comment(f, field.comment, "\t")	
				}

				fp(f, "\t")
				fp(f, field.field)
				fp(f, ",")

				if has_comment && !comment_before {
					// Padding in front of comment
					for _ in 0..<(longest_field_with_side_comment - len(field.field)) {
						fp(f, " ")
					}
					
					fpf(f, " %v", field.comment)
				}

				fp(f, "\n")
			}

			fp(f, "}\n\n")
		case Enum:
			output_comment(f, d.comment)

			name := d.name

			// It has no name, turn it into a bunch of constants
			if name == "" {
				for &m in d.members {
					fpf(f, "%v :: %v\n\n", trim_prefix(m.name, s.remove_type_prefix), m.value)
				}	

				break
			}

			fp(f, name)
			fp(f, " :: enum c.int {\n")

			bit_set_name, bit_setify := s.bit_setify[name]
			bit_set_all_constant: string

			overlap_length := 0
			longest_name := 0

			all_has_value := true

			if len(d.members) > 1 {
				overlap_length_source := d.members[0].name
				overlap_length = len(overlap_length_source)
				longest_name = overlap_length

				if d.members[0].value == nil {
					all_has_value = false
				}

				for idx in 1..<len(d.members) {
					if (d.members[idx].value == -1 || d.members[idx].value == 2147483647) && bit_setify {
						continue
					}

					mn := d.members[idx].name
					length := strings.prefix_length(mn, overlap_length_source)

					if length < overlap_length {
						overlap_length = length
						overlap_length_source = mn
					}

					longest_name = max(len(mn), longest_name)

					if d.members[idx].value == nil {
						all_has_value = false
					}
				}
			}	

			Formatted_Member :: struct {
				name: string,
				member: string,
				comment: string,
				comment_before: bool,
			}

			members: [dynamic]Formatted_Member

			for &m in d.members {
				if (m.value == -1 || m.value == 2147483647) && bit_setify {
					bit_set_all_constant = m.name
					continue
				}

				if m.value == 0 && bit_setify {
					continue
				}

				b := strings.builder_make()

				name_without_overlap := m.name[overlap_length:]

				// First letter is number... Can't have that!
				if len(name_without_overlap) > 0 && unicode.is_number(utf8.rune_at(name_without_overlap, 0)) {
					name_without_overlap = fmt.tprintf("_%v", name_without_overlap)
				}

				strings.write_string(&b, name_without_overlap)

				suffix_pad := all_has_value ? longest_name - len(name_without_overlap) - overlap_length : 0

				if vv, v_ok := m.value.?; v_ok {
					if !m.comment_before {
						for _ in 0..<suffix_pad {
							// Padding between name and `=`
							strings.write_rune(&b, ' ')
						}
					}

					val_string: string

					if bit_setify {
						v := u32(vv)
						assert(v != 0)

						// Note the `log2`... This turns a value such as `64`
						// into `6`, which is what it should be for a bit_set.
						val_string = fmt.tprintf(" = %v", bits.log2(v))

					} else {
						val_string = fmt.tprintf(" = %v", vv)
					}
					
					strings.write_string(&b, val_string)
				}

				append(&members, Formatted_Member {
					name = name_without_overlap,
					member = strings.to_string(b),
					comment = m.comment,
					comment_before = m.comment_before,
				})
			}

			longest_member_name_with_side_comment: int

			for &m in members {
				if m.comment != "" && !m.comment_before && len(m.member) > longest_member_name_with_side_comment {
					longest_member_name_with_side_comment = len(m.member)
				}
			}

			for &m, m_idx in members {
				has_comment := m.comment != ""
				comment_before := m.comment_before

				if has_comment && comment_before {
					if m_idx != 0 {
						fp(f, "\n")
					}
					output_comment(f, m.comment, "\t")	
				}

				fp(f, "\t")
				fp(f, m.member)
				fp(f, ",")

				if has_comment && !comment_before {
					for _ in 0..<(longest_member_name_with_side_comment - len(m.member)) {
						// Padding in front of comment
						fp(f, " ")
					}
					
					fpf(f, " %v", m.comment)
				}

				fp(f, '\n')
			}

			fp(f, "}\n\n")

			if bit_setify {
				fpf(f, "%v :: distinct bit_set[%v; c.int]\n\n", bit_set_name, name)

				// In case there is a typedef for this in the code.
				add_to_set(&s.created_symbols, bit_set_name)

				// There was a member with value `-1`... That means all bits are
				// set. Create a bit_set constant with all variants set.
				if bit_set_all_constant != "" {
					all_constant := strings.to_screaming_snake_case(trim_prefix(strings.to_lower(bit_set_all_constant), strings.to_lower(s.remove_type_prefix)))

					fpf(f, "%v :: %v {{ ", all_constant, bit_set_name)

					for &m, i in members {
						fpf(f, ".%v", m.name)

						if i != len(members) - 1 {
							fp(f, ", ")
						}
					}

					fp(f, " }\n\n")
				}
			}

		case Function:
			// handled later. This makes all procs end up at bottom, after types.

		case Typedef:
			t := d.name

			if t in s.opaque_type_lookup {
				if d.pre_comment != "" {
					output_comment(f, d.pre_comment)
				}
				fpf(f, "%v :: struct {{}}\n\n", t)
				continue
			}

			if t in s.created_symbols || strings.has_prefix(d.type, "0x") {
				continue
			}

			if d.pre_comment != "" {
				output_comment(f, d.pre_comment)
			}

			fp(f, t)

			fp(f, " :: ")

			if override, override_ok := s.type_overrides[t]; override_ok {
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
				fp(f, translate_type(s, type))
				add_to_set(&s.type_is_proc, t)
			} else {
				fpf(f, "%v", translate_type(s, type))
			}

			if d.side_comment != "" {
				fp(f, ' ')
				fp(f, d.side_comment)
			}

			fp(f, "\n\n")
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

	for &du in s.decls {
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
			}

			formatted_functions: [dynamic]Formatted_Function

			for &d in g.functions {
				b := strings.builder_make()

				w :: strings.write_string

				proc_name := trim_prefix(d.name, s.remove_function_prefix)
				w(&b, proc_name)

				for _ in 0..<longest_function_name-len(d.name) {
					strings.write_rune(&b, ' ')
				}

				w(&b, " :: proc(")

				for &p, i in d.parameters {
					n := vet_name(p.name)

					type := translate_type(s, p.type)
					type_override_key := fmt.tprintf("%v.%v", proc_name, n)

					if type_override, type_override_ok := s.procedure_type_overrides[type_override_key]; type_override_ok {
						switch type_override {
						case "#by_ptr":
							type = strings.trim_prefix(type, "^")
							w(&b, "#by_ptr ")
						case "[^]":
							type = fmt.tprintf("[^]%v", strings.trim_prefix(type, "^"))
						case:
							type = type_override
						}
					}

					w(&b, n)
					w(&b, ": ")
					w(&b, type)

					if i != len(d.parameters) - 1 {
						w(&b, ", ")
					}
				}

				w(&b, ")")

				if d.return_type != "" {
					w(&b, " -> ")

					return_type := translate_type(s, d.return_type)

					if override, override_ok := s.procedure_type_overrides[proc_name]; override_ok {
						switch override {
						case "[^]":
							return_type = fmt.tprintf("[^]%v", strings.trim_prefix(return_type, "^"))
						case:
							return_type = override
						}
					}

					w(&b, return_type)
				}

				w(&b, " ---")

				append(&formatted_functions, Formatted_Function {
					function = strings.to_string(b),
					post_comment = d.post_comment,
				})
			}

			longest_formatted_function: int

			for &ff in formatted_functions {
				if len(ff.function) < 90 && len(ff.function) > longest_formatted_function {
					longest_formatted_function = len(ff.function)
				}
			}

			for &ff in formatted_functions {
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
	// Disabled due to bug in virtual growing allocator: https://github.com/odin-lang/Odin/issues/4834

	/*permanent_arena: vmem.Arena
	permanent_allocator := vmem.arena_allocator(&permanent_arena)
	context.allocator = permanent_allocator
	context.temp_allocator = permanent_allocator*/

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

	if err := os.set_current_directory(config_dir); err != nil {
		fmt.panicf("failed to set current working directory: %v", err)
	}

	// Config file is optional
	config: Config
	if os.is_file(config_filename) {
		if config_data, config_data_ok := os.read_entire_file(config_filename); config_data_ok {
			config_err := json.unmarshal(config_data, &config, .SJSON)
			fmt.ensuref(config_err == nil, "Failed parsing config %v: %v", config_filename, config_err)
		} else {
			fmt.ensuref(config_data_ok, "Failed parsing config %v", config_filename)
		}
	} else {
		config.inputs = {
			".",
		}

		config.output_folder = "output"
		config.package_name = "pkg"

		// We need the actual name of the directory for the package name and
		// output folder. Since args[1] can be `.` we can't just use that. So
		// we open the directory and stat it to get the name.
		if input_dir, input_dir_err := os2.open(input_arg); input_dir_err == nil {
			if stat, stat_err := input_dir.fstat(input_dir, context.allocator); stat_err == nil {
				config.package_name = stat.name
				config.output_folder = stat.name
			}
		}
	}

	if config.remove_prefix != "" {
		panic("Error in bindgen.sjson: remove_prefix has been split into remove_function_prefix and remove_type_prefix")
	}

	input_files: [dynamic]string

	for i in config.inputs {
		if os.is_dir(i) {
			input_folder, input_folder_err := os2.open(i)
			fmt.ensuref(input_folder_err == nil, "Failed opening folder %v: %v", i, input_folder_err)
			iter, iter_err := os2.read_directory_iterator_create(input_folder)	
			fmt.ensuref(iter_err == nil, "Failed creating directory iterator for %v", input_folder)

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
