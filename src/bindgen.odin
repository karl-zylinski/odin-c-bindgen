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
import vmem "core:mem/virtual"

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

Macro :: struct {
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
	line: int,

	// The original idx in `s.decls`. This is for tie-breaking when line is the same.
	original_idx: int,

	variant: Declaration_Variant,
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

find_comment_after_semicolon :: proc(start_offset: int, s: ^Gen_State) -> (side_comment: string, ok: bool) {
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

// used to get comments to the right of macros
find_comment_at_line_end :: proc(str: string) -> (string, int) {
	spaces_counter := 0
	for c, i in str {
		if c == ' ' {
			spaces_counter += 1
		} else if c == '/' && i + 1 < len(str) && (str[i + 1] == '/' || str[i + 1] == '*') {
			return str[i:], spaces_counter
		} else {
			spaces_counter = 0
		}
	}

	return "", 0
}

parse_struct_decl :: proc(s: ^Gen_State, decl: json.Value) -> (res: Struct, ok: bool) {
	out_fields: [dynamic]Struct_Field
	comment: string

	if inner, fields_ok := json_get_array(decl, "inner"); fields_ok {
		anonymous_struct_types: [dynamic]json.Object
		for &i in inner {
			i_kind := json_get_string(i, "kind") or_continue
			if i_kind == "RecordDecl" {
				append(&anonymous_struct_types, i.(json.Object))
			}
		}

		prev_line := 0
		prev_idx := -1
		for &i in inner {
			if loc, loc_ok := json_get_object(i, "loc"); loc_ok {
				if lline, lline_ok := json_get_int(loc, "line"); lline_ok {
					prev_line = lline
				}
			}

			i_kind := json_get_string(i, "kind") or_continue
			if i_kind == "FieldDecl" {
				field_name, field_name_exists := json_get_string(i, "name")
				field_type := get_parameter_type(s, i) or_continue
				field_anon_struct_type: Maybe(Struct)

				is_implicit := json_check_bool(i, "isImplicit")


				has_unnamed_type: bool
				unnamed_type_line: int
				unnamed_type_col: int
				anon_using: bool


				ANON_STRUCT_MARKER :: "struct (unnamed struct at "
				ANON_UNION_MARKER :: "union (unnamed union at "

				is_anon_struct := strings.has_prefix(field_type, ANON_STRUCT_MARKER)
				is_anon_union := strings.has_prefix(field_type, ANON_UNION_MARKER)

				if is_anon_struct || is_anon_union {
					location := is_anon_struct ? field_type[len(ANON_STRUCT_MARKER):len(field_type)-1] : field_type[len(ANON_UNION_MARKER):len(field_type)-1]

					loc_parts := strings.split(location, ":")
					assert(len(loc_parts) == 3)

					has_unnamed_type = true
					unnamed_type_line = strconv.atoi(loc_parts[1])
					unnamed_type_col = strconv.atoi(loc_parts[2])
				} else if is_implicit {
					LOC_START_MARKER :: "anonymous at "
					loc_start := strings.index(field_type, LOC_START_MARKER)

					if loc_start != -1 {
						location := field_type[loc_start + len(LOC_START_MARKER):len(field_type)-1]
						loc_parts := strings.split(location, ":")
						assert(len(loc_parts) == 3)

						anon_using = true
						has_unnamed_type = true
						unnamed_type_line = strconv.atoi(loc_parts[1])
						unnamed_type_col = strconv.atoi(loc_parts[2])
					}
				}

				if has_unnamed_type {
					for a in anonymous_struct_types {
						aloc := json_get(a, "loc", json.Object) or_continue
						aline := json_get(aloc, "line", json.Integer) or_else i64(prev_line)
						acol := json_get(aloc, "col", json.Integer) or_continue

						if unnamed_type_line == int(aline) && unnamed_type_col == int(acol) {
							if anon_struct, anon_struct_ok := parse_struct_decl(s, a); anon_struct_ok {
								field_anon_struct_type = anon_struct
							}
						}
					}
				}

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
				if field_name_exists && prev_idx != -1 {
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
						anon_struct_type = field_anon_struct_type,
						anon_using = anon_using,
						comment = field_comment,
						comment_before = field_comment_before,
						original_line = field_line, 
					}
					
					if field_name_exists {
						append(&f.names, field_name)
					}

					append(&out_fields, f)
					
					if is_c_type(field_type) {
						s.needs_import_c = true
					} else if is_libc_type(field_type) {
						s.needs_import_libc = true
					} else if is_posix_type(field_type) {
						s.needs_import_posix = true
					}
				}
			} else if i_kind == "FullComment" {
				comment, _ = get_comment(i, s)
			}
		}
	}

	res = {
		comment = comment,
		fields = out_fields[:],
		is_union = (json_get_string(decl, "tagUsed") or_else "") == "union",
		is_forward_declare = !json_check_bool(decl, "completeDefinition"),
	}

	ok = true

	return
}

Macro_Type :: enum {
	Valueless,
	Constant_Expression,
	Multivalue,
	Function,
}

Macro_Token :: struct {
	type: Macro_Type,
	name: string,
	values: []string,
}

trim_encapsulating_parens :: proc(s: string) -> string {
	str := strings.trim_space(s)
	// There could be an arbitrary number of parentheses inside the string so we repeat until we're sure we've removed all the outer ones.
	for str[0] == '(' && str[len(str) - 1] == ')' {
		parens := 1
		i := 1
		// It's important to make sure that the parens at the begining and end are a pair.
		// For example without the check a cast statement like `(type)(value)` would have its outer parens removed.
		for ; parens > 0 && i < len(str); i += 1 {
			if str[i] == '(' {
				parens += 1
			} else if str[i] == ')' {
				parens -= 1
			}
		}
		// If parens is 0 before reaching the end of the string then the starting parenthesis doesn't pair with the ending one.
		// If parens doesn't reach 0 then we have unbalanced parenthesis. Maybe we should error here but I'm just going to ignore it for now.
		// It's not our responsibility to ensure the code is valid C. Also clang should have produced an error if there was a syntax error.
		if i == len(str) && parens == 0 {
			str = strings.trim_space(str[1: len(str) - 1])
		} else {
			break
		}
	}
	return str
}

parse_value :: proc(s: string) -> (r: []string, type: Macro_Type = .Constant_Expression) {
	str := strings.trim_space(s)

	ret: [dynamic]string
	grouping_delimiter := 0
	tracker := 0
	for i := 0; i < len(str); i += 1 {
		switch str[i] {
		// We track grouping delimiters so we can ignore commas and spaces inside them such as {10, 20, 30}.
		case '(', '{', '[':
			grouping_delimiter += 1
		case ')', '}', ']':
			grouping_delimiter -= 1
		case ',':
			if grouping_delimiter == 0 {
				tmp := strings.trim_space(s[tracker:i])
				if len(tmp) > 0 {
					append(&ret, tmp)
				}
				tracker = i + 1
				type = .Multivalue
			}
		case ' ':
			if grouping_delimiter == 0 {
				tmp := strings.trim_space(s[tracker:i])
				if len(tmp) > 0 {
					append(&ret, tmp)
				}
				tracker = i + 1
			}
		case '"':
			// We need to find the end of the string. We can't just use `strings.index` because the string can contain escaped quotes.
			for i < len(str) {
				i += 1
				if str[i] == '"' {
					break
				} else if str[i] == '\\' {
					i += 1 // Skip the escaped character
				}
			}
			if grouping_delimiter == 0 {
				tmp := strings.trim_space(str[tracker:i+1])
				if len(tmp) > 0 {
					append(&ret, tmp)
				}
				tracker = i + 1
			}
		}
	}
	tmp := strings.trim_space(s[tracker:])
	if len(tmp) > 0 {
		append(&ret, tmp)
	}

	return ret[:], type
} 

char_type :: proc(c: u8) -> enum {
	Char,
	Num,
	Quote,
	Other,
} {
	if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' {
		return .Char
	} else if (c >= '0' && c <= '9') || c == '.' { // Assume '.' is decimal point
		return .Num
	} else if c == '"' {
		return .Quote
	}
	return .Other
}

parse_macro :: proc(s: string) -> (macro_token: Macro_Token) {
	line := strings.trim_space(s)
	i := 0
	for; i < len(line); i += 1 {
		switch line[i] {
		case '(': // Function-like macro
			macro_token.type = .Function
			macro_token.name = line[:i]

			fn_end := strings.index(line, ")") // fn macros can only have one `(` and `)`
			params := strings.split(line[i + 1:fn_end], ",")

			for &param in params {
				param = strings.trim_space(param)
			}

			parse_number :: proc(str: string, start: u32, b: ^strings.Builder, names: []string) -> u32 {
				end := start + 1
				for; end < u32(len(str)); end += 1 {
					if char_type(str[end]) == .Other { // Assume chars are a type suffix or 'b'/'x' for binary and hex (We'll validate these later)
						break
					}
				}
				strings.write_string(b, str[start:end])
				return end
			}

			parse_name :: proc(str: string, start: u32, b: ^strings.Builder, names: []string) -> u32 {
				end := start + 1
				for; end < u32(len(str)); end += 1 {
					if char_type(str[end]) == .Other { 
						break 
					}
				}
				
				for name, i in names {
					if str[start:end] == name {
						// This will allow me to index the parameter with the number of the parameter similar to pythons "{0}" formatting.
						// We can't copy python syntax exactly here because C uses {} for initializers and we don't want to confuse the two.
						strings.write_string(b, "${")
						strings.write_int(b, i)
						strings.write_string(b, "}$")
						return end
					}
				}
				strings.write_string(b, str[start:end])
				return end
			}

			b := strings.builder_make()
			value := strings.trim_space(line[fn_end+1:])
			
			// We go throught the string and replace all the parameters with `${index}$`.
			for i: u32 = 0; i < u32(len(value)); i += 1 {
				if char_type(value[i]) == .Num {
					i = parse_number(value, i, &b, params) - 1
				} else if char_type(value[i]) == .Char {
					i = parse_name(value, i, &b, params) - 1
				} else {
					strings.write_byte(&b, value[i])
				}
			}
			macro_token.values = make([]string, 1)
			macro_token.values[0] = strings.to_string(b)
			return
		case ' ': // Non function-like macro
			macro_token.name = line[:i]
			macro_token.values, macro_token.type = parse_value(trim_encapsulating_parens(line[i:]))
			return
		}
	}
	macro_token = {
		name = line,
		type = .Valueless,
	}
	return
}

File_Macro :: struct {
	line: int,
	macro_name: string,
	comment: string,
	side_comment: string,
	whitespace_after_name: int,
	whitespace_before_side_comment: int,
}

// Parses the file and finds all the macros that are defined in it.
parse_file_macros :: proc(s: ^Gen_State) -> map[string]File_Macro {
	defined := make(map[string]File_Macro)

	file_lines := strings.split_lines(s.source)
	for i := 0; i < len(file_lines); i += 1 {
		line_idx := i
		line := strings.trim_space(file_lines[i])

		if len(line) == 0 { // Don't parse empty lines
			continue
		}

		for line[len(line)-1] == '\\' { // Backaslash means to treat the next line as part of this line
			i += 1
			line = fmt.tprintf("%v %v", strings.trim_space(line[:len(line)-1]), strings.trim_space(file_lines[i]))
		}

		if strings.has_prefix(line, "#define") { // #define macroName keyValue
			l := strings.trim_prefix(line, "#define")
			l = strings.trim_space(l)

			end_of_name := strings.index(l, " ")

			if end_of_name == -1 {
				end_of_name = strings.index(l, "\t")
			}

			// Macro parameter list start
			first_left_paren := strings.index(l, "(")

			if first_left_paren != -1 && first_left_paren < end_of_name {
				end_of_name = first_left_paren
			}

			if end_of_name == -1 {
				continue
			}

			name := l[:end_of_name]

			if name in defined {
				continue
			}

			whitespace_after_name := 0

			for c in l[end_of_name:] {
				if c == ' ' {
					whitespace_after_name += 1
				} else {
					break
				}
			}

			side_comment, side_comment_align_whitespace := find_comment_at_line_end(line)

			cbidx := i - 1
			cb_block_comment := false
			comment_start := -1
			comment_end := -1

			for cbidx >= 0 {
				cbl := file_lines[cbidx]
				cbl_trim := strings.trim_space(cbl)

				if strings.has_prefix(cbl_trim, "/*") && cb_block_comment {
					// TODO: this doesn't account for the case of a multiline block comment that begins at the end of a non-comment line
					comment_start = cbidx
					break
				} else if cb_block_comment {
					// block comment interior, continue
				} else if strings.has_suffix(cbl_trim, "*/") {
					if comment_end == -1 {
						comment_end = cbidx
					}
					cb_block_comment = true
					if strings.has_prefix(cbl_trim, "/*") {
						// block comment starts on same line
						cb_block_comment = false
						comment_start = cbidx
						break
					} else if strings.contains(cbl_trim, "/*") {
						// this is actually the side comment for another line, discard comment and break
						cb_block_comment = false
						break
					}
				} else if strings.has_prefix(cbl_trim, "//") {
					if comment_end == -1 {
						comment_end = cbidx
					}

					comment_start = cbidx
				} else if cbl_trim != "" {
					break
				}

				cbidx -= 1
			}

			comment: string

			if comment_start != -1 && comment_end != -1 {
				comment_builder := strings.builder_make()

				for comment_line_idx in comment_start..=comment_end {
					strings.write_string(&comment_builder, file_lines[comment_line_idx])
					strings.write_rune(&comment_builder, '\n')
				}

				comment = strings.to_string(comment_builder)
			}

			defined[name] = File_Macro {
				macro_name = name,
				line = line_idx,
				comment = comment,
				side_comment = side_comment,
				whitespace_before_side_comment = side_comment_align_whitespace,
				whitespace_after_name = whitespace_after_name,
			}
		}
	}

	return defined
}

// This function runs clangs preprocessor to get all the macros that are defined during compilation
parse_clang_macros :: proc(s: ^Gen_State, input: string) -> (map[string]Macro_Token) {
	command := [dynamic]string {
		"clang", "-dM", "-E", input,
	}

	for include in s.clang_include_paths {
		append(&command, fmt.tprintf("-I%v", include))
	}

	for k, v in s.clang_defines {
		append(&command, fmt.tprintf("-D%v=%v", k, v))
	}

	process_desc := os2.Process_Desc {
		command = command[:],
	}

	state, sout, serr, err := os2.process_exec(process_desc, context.allocator)

	if err != nil {
		fmt.panicf("Error generating macro dump. Error: %v", err)
	}

	if len(serr) > 0 {
		fmt.eprintln(string(serr))
		fmt.eprintfln("Aborting generation for %v", input)
		return nil
	}

	ensure(state.success, "Failed running clang")

	input_filename := filepath.base(input)
	output_stem := filepath.stem(input_filename)
	output_filename := fmt.tprintf("%v/%v.odin", s.output_folder, output_stem)
	
	if s.debug_dump_macros {
		os.write_entire_file(fmt.tprintf("%v-macro_dump.h", output_filename), sout)
	}

	tokenized_macros: map[string]Macro_Token
	macro_lines := strings.split_lines(string(sout))

	for i := 0; i < len(macro_lines); i += 1 {
		line := strings.trim_space(macro_lines[i])

		if len(line) == 0 { // Don't parse empty lines
			continue
		}

		for line[len(line)-1] == '\\' { // Backaslash means to treat the next line as part of this line
			i += 1
			line = fmt.tprintf("%v %v", strings.trim_space(line[:len(line)-1]), strings.trim_space(macro_lines[i]))
		}

		if strings.has_prefix(line, "#define") {
			token := parse_macro(line[len("#define "):])
			if token.type == .Valueless {
				continue // We don't care about valueless macros
			}
			tokenized_macros[token.name] = token
		}
	}

	return tokenized_macros
}

parse_pystring :: proc(s: string, params: []string) -> string {
	b := strings.builder_make(context.temp_allocator)
	index := 0
	for i := strings.index(s[index:], "${"); i != -1; i = strings.index(s[index:], "${") {
		start_brace := i + index
		end_brace := strings.index(s[start_brace:], "}$")
		if end_brace == -1 {
			break // No closing brace found. The macro is malformed.
		}
		end_brace += start_brace
		param_index := strconv.atoi(s[start_brace+2:end_brace])
		if param_index < 0 || param_index >= len(params) {
			break // Invalid parameter index
		}

		strings.write_string(&b, s[index:index+i])
		strings.write_string(&b, params[param_index])
		index = end_brace + 2
	}
	strings.write_string(&b, s[index:])
	return strings.to_string(b)
}

parse_macros :: proc(s: ^Gen_State, input: string) {
	// First we find all macros in the file, then we also fetch them through clang, so they
	// respect the preprocesor defines etc.
	defined_from_file := parse_file_macros(s)
	tokenized_macros := parse_clang_macros(s, input)

	expand_fn_macro :: proc(value: ^string, name_start, name_end: int, macro_token: Macro_Token, macros: ^map[string]Macro_Token) -> string {
		params_start := name_end
		for ; params_start < len(value); params_start += 1 { // Finds first parenthesis after the macro name
			if value[params_start] == '(' {
				break
			} else if value[params_start] != ' ' {
				return value^
			}
		}
		if params_start == len(value) {
			return value^
		}

		params_start += 1
		params_end := params_start
		parens := 1
		for ; parens > 0 && params_end < len(value); params_end += 1 {
			if value[params_end] == '(' {
				parens += 1
			} else if value[params_end] == ')' {
				parens -= 1
			}
		}
		if parens != 0 {
			return value^
		}
		params_end -= 1

		params, _ := parse_value(value[params_start:params_end])
		for param_index := 0; param_index < len(params); param_index += 1 {
			// If our param contains a macro we need to expand it first.
			strs := check_param_for_macro_and_expand(&params[param_index], macros)
			if len(strs) > 0 {
				new_params := make([]string, len(params) + len(strs) - 1)
				for i := 0; i < param_index; i += 1 {
					new_params[i] = params[i]
				}
				for i := 0; i < len(strs); i += 1 {
					new_params[param_index + i] = strs[i]
				}
				for i := 0; i < len(params) - param_index - 1; i += 1 {
					new_params[param_index + len(strs) + i] = params[param_index + i + 1]
				}
				params = new_params // It might not be safe to do this while looping over the array.
			}
		}

		ret := fmt.tprintf("%s%s", value[:name_start], parse_pystring(macro_token.values[0], params))
		if params_end + 1 < len(value) {
			ret = fmt.tprintf("%s%s", ret, value[params_end + 1:])
		}
		return ret
	}

	check_for_macro :: proc(value: ^string, macros: ^map[string]Macro_Token) -> (int, int) {
		for i := 0; i < len(value); i += 1 {
			if char_type(value[i]) != .Char {
				continue
			}

			name_start := i
			for ; i < len(value); i += 1 {
				if char_type(value[i]) == .Other {
					break
				}
			}
			
			if _, exists := macros[value[name_start:i]]; exists {
				return name_start, i
			}
		}
		return -1, -1
	}

	check_param_for_macro_and_expand :: proc(value: ^string, macros: ^map[string]Macro_Token) -> []string {
		name_start, name_end := check_for_macro(value, macros)
		if name_start == -1 {
			return nil
		}
		if macro, _ := macros[value[name_start:name_end]]; macro.type == .Function {
			value^ = expand_fn_macro(value, name_start, name_end, macro, macros)
		} else if macro.type == .Multivalue {
			return macro.values
		}
		return nil
	}

	check_value_for_macro_and_expand :: proc(value: ^string, macros: ^map[string]Macro_Token) {
		name_start, name_end := check_for_macro(value, macros)
		if name_start == -1 {
			return
		}
		
		macro_name := value[name_start:name_end]
		if macro_token, _ := macros[macro_name]; macro_token.type == .Function {
			value^ = expand_fn_macro(value, name_start, name_end, macro_token, macros)
			if value^ == macro_name {
				return
			}
			check_value_for_macro_and_expand(value, macros)
		} else if macro_token.type == .Multivalue {
			tmp := fmt.tprintf("%s%s", value[:name_start], strings.join(macro_token.values, ", ", context.temp_allocator))
			if name_end < len(value) {
				tmp = fmt.tprintf("%s%s", tmp, value[name_end:])
			}
			value^ = tmp
			check_value_for_macro_and_expand(value, macros)
		}
	}

	for _, &macro in tokenized_macros {
		if macro.type != .Constant_Expression {
			continue
		}

		// I'm not a fan of this way of checking if the macro is defined in the file. Feel free to suggest better ways to do this.
		file_macro, defined := defined_from_file[macro.name]

		if !defined {
			continue
		}

		for &value in macro.values {
			check_value_for_macro_and_expand(&value, &tokenized_macros)
		}

		append(&s.decls, Declaration {
			line = file_macro.line,
			original_idx = len(s.decls),
			variant = Macro {
				name = macro.name,
				val = strings.join(macro.values, " "),
				comment = file_macro.comment,
				side_comment = file_macro.side_comment,
				whitespace_after_name = file_macro.whitespace_after_name,
				whitespace_before_side_comment = file_macro.whitespace_before_side_comment,
			},
		})
	}
}

parse_decl :: proc(s: ^Gen_State, decl: json.Value, line: int) {
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

		_, line_ok := json_get_int(decl, "loc.line")

		if !line_ok {
			return
		}

		return_type, has_return_type := get_return_type(decl)
		if has_return_type {
			if is_c_type(return_type) {
				s.needs_import_c = true
			} else if is_libc_type(return_type) {
				s.needs_import_libc = true
			} else if is_posix_type(return_type) {
				s.needs_import_posix = true
			}
		}

		out_params: [dynamic]Function_Parameter
		comment: string
		comment_before: bool

		if params, params_ok := json_get_array(decl, "inner"); params_ok {
			for &p in params {
				pkind := json_get_string(p, "kind") or_continue

				if pkind == "ParmVarDecl" {
					// Empty name is OK. It's an unnamed parameter.
					param_name, _ := json_get_string(p, "name")
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
			side_comment, _ = find_comment_after_semicolon(end_offset, s)
		}
		append(&s.decls, Declaration {
			line = line,
			original_idx = len(s.decls),
			variant = Function {
				name = name,
				parameters = out_params[:],
				return_type = has_return_type ? return_type : "",
				comment = comment,
				comment_before = comment_before,
				post_comment = side_comment,
				variadic = json_check_bool(decl, "variadic"),
			},
		})
	} else if kind == "RecordDecl" {
		name, _ := json_get_string(decl, "name")

		if struct_decl, struct_decl_ok := parse_struct_decl(s, decl); struct_decl_ok {
			struct_decl.name = name
			struct_decl.id = id

			if name != "" {
				if forward_idx, forward_declared := s.symbol_indices[name]; forward_declared {
					s.decls[forward_idx] = {}
				}

				s.symbol_indices[name] = len(s.decls)
			}
			append(&s.decls, Declaration { line = line, original_idx = len(s.decls), variant = struct_decl })
		}
	} else if kind == "TypedefDecl" {
		type, type_ok := get_parameter_type(s, decl)

		if !type_ok {
			return
		}

		name, _ := json_get_string(decl, "name")
		_, line_ok := json_get_int(decl, "loc.line")
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
						if comment_line_ok && line_ok && comment_line >= line {
							side_comment = comment
						} else {
							pre_comment = comment
						}
					}
				}
			}
		}

		if end_offset, end_offset_ok := json_get_int(decl, "range.end.offset"); end_offset_ok {
			side_comment, _ = find_comment_after_semicolon(end_offset, s)
		}

		s.typedefs[type] = name
		append(&s.decls, Declaration {
			line = line,
			original_idx = len(s.decls),
			variant = Typedef {
				name = name,
				type = type,
				pre_comment = pre_comment,
				side_comment = side_comment,
			},
		})
	} else if kind == "EnumDecl" {
		name, _ := json_get_string(decl, "name")
		comment: string
		out_members: [dynamic]Enum_Member

		s.needs_import_c = true // enums all use c.int

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

		append(&s.decls, Declaration {
			line = line,
			original_idx = len(s.decls),
			variant = Enum {
				name = name,
				id = id,
				comment = comment,
				members = out_members[:],
			},
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
	if replacement, has_replacement := state.rename[s]; has_replacement {
		return replacement
	}

	return s
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

is_c_type :: proc(t: string) -> bool{
	base_type := strings.trim_suffix(t, "*")
	base_type = strings.trim_space(base_type)
	return base_type in c_type_mapping
}

// This is probably missing some built-in C types (or common types that come
// from stdint.h etc). Please add and send in a Pull Request if you needed to
// add anything here!
c_type_mapping := map[string]string {
	"char" = "c.char",

	"signed char" = "c.schar",
	"short"       = "c.short",
	"int"         = "c.int",
	"long"        = "c.long",
	"long long"   = "c.longlong",

	"unsigned char"      = "c.uchar",
	"unsigned short"     = "c.ushort",
	"unsigned int"       = "c.uint",
	"unsigned long"      = "c.ulong",
	"unsigned long long" = "c.ulonglong",

	"bool" = "bool",
	"Bool" = "bool", // I don't know why this needs to have a capital B, but it does.
	"BOOL" = "bool", // bool is sometimes a macro for BOOL
	"_Bool" = "bool",

	"size_t"  = "c.size_t",
	"ssize_t" = "c.ssize_t",
	"wchar_t" = "c.wchar_t",

	"float"          = "f32",
	"double"         = "f64",
	// I think clang changes this to something else so this might not work.
	// I tried testing it but I couldn't get the complex type working in C.
	"float complex"  = "complex64",
	"double complex" = "complex128",

	"int8_t"   = "i8",
	"uint8_t"  = "u8",
	"int16_t"  = "i16",
	"uint16_t" = "u16",
	"int32_t"  = "i32",
	"uint32_t" = "u32",
	"int64_t"  = "i64",
	"uint64_t" = "u64",

	"int_least8_t"   = "i8",
	"uint_least8_t"  = "u8",
	"int_least16_t"  = "i16",
	"uint_least16_t" = "u16",
	"int_least32_t"  = "i32",
	"uint_least32_t" = "u32",
	"int_least64_t"  = "i64",
	"uint_least64_t" = "u64",
	
	// These type could change base on the platform.
	"int_fast8_t"   = "c.int_fast8_t",
	"uint_fast8_t"  = "c.uint_fast8_t",
	"int_fast16_t"  = "c.int_fast16_t",
	"uint_fast16_t" = "c.uint_fast16_t",
	"int_fast32_t"  = "c.int_fast32_t",
	"uint_fast32_t" = "c.uint_fast32_t",
	"int_fast64_t"  = "c.int_fast64_t",
	"uint_fast64_t" = "c.uint_fast64_t",
	
	"intptr_t"  = "c.intptr_t",
	"uintptr_t" = "c.uintptr_t",
	"ptrdiff_t" = "c.ptrdiff_t",

	"intmax_t"  = "c.intmax_t",
	"uintmax_t" = "c.uintmax_t",
}

// For translating type names in procedure parameters and struct fields.
translate_type :: proc(s: Gen_State, t: string) -> string {
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

	// This type usually means "an array of strings"
	if t == "const char *const *" {
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
	} else if s.force_ada_case_types && t != "void" {
		// It makes sense, in the case we can't find the type, to just follow our naming rules and
		// hope the type is defined somewhere else.
		t = final_name(vet_name(strings.to_ada_case(t)), s)
	} else {
		t = final_name(vet_name(t), s)
	}

	if array_start != -1 {
		t = fmt.tprintf("%s%s%s", multi_array != -1 ? "[^]" : "", t_original[array_start:array_end + 1], t)
	}

	b := strings.builder_make()

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

	for _ in 0..<num_ptrs{
		strings.write_string(&b, "^")
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

	source: string,
	decls: [dynamic]Declaration,
	defines: map[string]string,
	symbol_indices: map[string]int,
	typedefs: map[string]string,
	created_symbols: map[string]struct{},
	type_is_proc: map[string]struct{},
	opaque_type_lookup: map[string]struct{},
	created_types: map[string]struct{},
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
	// Run clang and produce an AST in json format that describes the headers.
	//

	command := [dynamic]string {
		"clang", "-Xclang", "-ast-dump=json", "-fparse-all-comments", "-c", input,
	}

	for include in c.clang_include_paths {
		append(&command, fmt.tprintf("-I%v", include))
	}

	for k, v in c.clang_defines {
		append(&command, fmt.tprintf("-D%v=%v", k, v))
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

	parse_macros(&s, input) // Parse macros so we can add them as constants in Odin

	inner := json_in.(json.Object)["inner"].(json.Array)

	//
	// Turn the JSON into an intermediate format (parse_decls will append stuff
	// to s.decls)
	//

	line := 0

	for &in_decl in inner {
		// Some decls don't have a line, in that case we send in the most recent line instead.
		if cur_line, cur_line_ok := json_get_int(in_decl, "loc.line"); cur_line_ok {
			line = cur_line
		}

		if s.required_prefix != "" {
			if name, name_ok := json_get_string(in_decl, "name"); name_ok {
				if !strings.has_prefix(name, s.required_prefix) {
					continue
				}
			}
		}

		parse_decl(&s, in_decl, line)
	}

	slice.sort_by(s.decls[:], proc(i, j: Declaration) -> bool {
		if i.line == j.line {
			return i.original_idx < j.original_idx
		}
		return i.line < j.line
	})

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

	for &decl in s.decls {
		du := &decl.variant
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
			name := trim_prefix(d.name, s.remove_function_prefix)

			if replacement, has_replacement := s.rename[name]; has_replacement {
			d.link_name = d.name
			name = replacement
			}

			d.name = name
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

		case Macro:
			name := d.name
			name = trim_prefix(name, s.remove_macro_prefix)
			name = final_name(name, s)
			d.name = name
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
				if n in s.opaque_type_lookup && d.id not_in s.typedefs {
					output_comment(f, d.comment)
					fpf(f, "%v :: struct {{}}\n\n", n)
				}

				break
			}

			output_comment(f, d.comment)

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
					field: string,
					comment: string,
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
						override_key = fmt.tprintf("%s.%s", n, strings.to_string(b))
						strings.write_string(&b, ": ")

						if !field.comment_before {
							// Padding between name and =
							for _ in 0..<longest_field_name_with_side_comment-names_len {
								strings.write_rune(&b, ' ')
							}
						}
					}
					
					field_type := translate_type(s, field.type)

					if override_key != "" {
						if field_type_override, has_field_type_override := s.struct_field_overrides[override_key]; has_field_type_override {
							if field_type_override == "[^]" {
								// Change first `^` for `[^]`
								field_type = fmt.tprintf("[^]%v", strings.trim_prefix(field_type, "^"))
							} else {
								field_type = field_type_override
							}
						}
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
			n := d.name

			if n in s.opaque_type_lookup {
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

			if translate_type(s, d.type) == d.name {
				continue
			}

			if d.pre_comment != "" {
				output_comment(f, d.pre_comment)
			}

			fp(f, n)

			fp(f, " :: ")

			if override, override_ok := s.type_overrides[n]; override_ok {
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
				add_to_set(&s.type_is_proc, n)
			} else {
				fpf(f, "%v", translate_type(s, type))
			}

			if d.side_comment != "" {
				fp(f, ' ')
				fp(f, d.side_comment)
			}

			fp(f, "\n\n")

		case Macro:
			val := d.val

			comment_out := false
			
			val = trim_encapsulating_parens(val)
			b := strings.builder_make()
			for i := 0; i < len(val); i += 1 {
				switch char_type(val[i]) {
				case .Char:
					// Parsing text here is quite annoying. Is it a type? Is it another macro? Maybe it's an enum field. We don't know.
					// My implementation will check if it's a built-in type or a macro. If it's neither we are going to assume it's a user-defined type.
					// As discussed here https://github.com/karl-zylinski/odin-c-bindgen/pull/27 we dont know all the defined types so figuring out what it is isn't always possible.
					start := i
					for ; i < len(val); i += 1 {
						if char_type(val[i]) != .Char && char_type(val[i]) != .Num {
							break
						}
					}
					if val[start:i] in s.defines {
						strings.write_string(&b, trim_prefix(val[start:i], s.remove_macro_prefix))
					} else if type, exists := c_type_mapping[val[start:i]]; exists {
						strings.write_string(&b, type)
					} else if _, exists = s.created_types[trim_prefix(val[start:i], s.remove_type_prefix)]; exists {
						strings.write_string(&b, val[start:i])
					} else {
						comment_out = true

						if s.force_ada_case_types {
							strings.write_string(&b, strings.to_ada_case(trim_prefix(val[start:i], s.remove_type_prefix)))
						} else {
							strings.write_string(&b, trim_prefix(val[start:i], s.remove_type_prefix))
						}
					}
					i -= 1
				case .Num:
					suffix_index := 0
					start := i
					for ; i < len(val); i += 1 {
						type := char_type(val[i])

						if type == .Char && i == 1 && val[0] == '0' && (val[i] == 'x' || val[i] == 'b') {
							// 0x or 0b prefix
							continue
						} else if type == .Char && suffix_index == 0 {
							suffix_index = i
						} else if type != .Num && type != .Char {
							break
						}
					}
					if suffix_index == 0 {
						suffix_index = i
					}
					strings.write_string(&b, val[start:suffix_index])
					i -= 1
				case .Quote:
					start := i
					for i += 1; i < len(val); i += 1 {
						if val[i] == '\\' {
							i += 1
							continue
						} else if val[i] == '"' {
							break
						}
					}
					strings.write_string(&b, val[start:i + 1])
				case .Other:
					if val[i] == '~' || val[i] == '#' {
						comment_out = true
					}

					strings.write_byte(&b, val[i])
				}
			}

			value_string := strings.to_string(b)
			if value_string == "{}" || value_string == "{0}" {
				continue
			}

			if d.comment != "" {
				fp(f, d.comment)
			}

			if comment_out {
				fp(f, "// ")
			}
			fpf(f, "%v%*s:: %v", d.name, max(d.whitespace_after_name, 1), "", value_string)

			if d.side_comment != "" {
				fpf(f, "%*s%v", d.whitespace_before_side_comment, "", d.side_comment)
			}

			fp(f, "\n")

			if decl_idx < len(s.decls) - 1 {
				next := &s.decls[decl_idx + 1]

				_, next_is_macro := next.variant.(Macro)

				if !next_is_macro || next.line != decl.line + 1 {
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

					type := translate_type(s, p.type)
					type_override_key := fmt.tprintf("%v.%v", d.name, n)

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

					// Empty name means unnamed parameter. Drop the colon.
					if len(n) != 0 {
						w(&b, n)
						w(&b, ": ")
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

					return_type := translate_type(s, d.return_type)

					if override, override_ok := s.procedure_type_overrides[d.name]; override_ok {
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
			fmt.ensuref(config_err == nil, "Failed parsing config %v: %v", config_filename, config_err)
		} else {
			fmt.ensuref(config_data_ok, "Failed parsing config %v", config_filename)
		}
	} else {
		config.inputs = {
			".",
		}
	}

	if config.output_folder == "" {
		config.output_folder = default_output_folder
	}

	if config.package_name == "" {
		config.package_name = default_package_name
	}

	if config.remove_prefix != "" {
		panic("Error in bindgen.sjson: remove_prefix has been split into remove_function_prefix and remove_type_prefix")
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
