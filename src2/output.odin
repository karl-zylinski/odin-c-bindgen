// This files takes the Output_State and produces the bindings based on it.
//
// Never import clang within this file. Resolve any clang-related things in on of the
// translate_X.odin files.
#+private file
package bindgen2

import "core:os"
import "core:fmt"
import "core:strings"
import "core:log"

@(private="package")
output :: proc(fr: Output_State, filename: string, package_name: string) {
	ensure(filename != "")
	ensure(package_name != "")
	builder := strings.builder_make()
	sb := &builder

	if fr.top_comment != "" {
		pln(sb, fr.top_comment)
	}

	pfln(sb, "package %v", package_name)
	pln(sb, "")

	prev_is_proc := false

	for &d in fr.decls {
		// TODO remove when redesign done
		if d.name == "" {
			continue
		}

		pf(sb, "%v :: ", d.name)
		output_declaration_type(d.type, 0, sb)

		p(sb, "\n\n")
	}

	/*fr_decls_loop: for &d in fr.decls {
		t, t_ok := fr.types[d.named_type].(Type_Named)

		if !t_ok {
			continue
		}

		rhs := get_type_string(fr.types, t.definition)

		if rhs == t.name {
			continue
		}

		_, is_proc := fr.types[t.definition].(Type_Procedure)


		if is_proc {
			if !prev_is_proc {
				pln(sb, "foreign lib {")
			}
		} else {
			if prev_is_proc {
				pln(sb, "}")
			}
		}

		if d.comment_before != "" {
			if is_proc {
				p(sb, "\t")
			}

			pln(sb, d.comment_before)
		}

		if is_proc {
			p(sb, "\t")
		}

		pf(sb, "%v :: %v", t.name, rhs)

		if !is_proc {
			p(sb, "\n\n")
		}

		prev_is_proc = is_proc
	}*/

	write_err := os.write_entire_file(filename, transmute([]u8)(strings.to_string(builder)))
	fmt.ensuref(write_err == true, "Failed writing %v", filename)
}

output_declaration_type :: proc(dt: Declaration_Type, indent: int, b: ^strings.Builder) {
	switch &t in dt {
	case Declaration_Unknown:
	case Declaration_Procedure:
		pfln(b, "proc()")
	case Declaration_Struct:
		output_struct_declaration2(t, indent, b)
	}
}

output_struct_declaration2 :: proc(d: Declaration_Struct, indent: int, b: ^strings.Builder) {
	longest_name: int
	for &f in d.fields {
		if len(f.name) > longest_name {
			longest_name = len(f.name)
		}
	}

	field_texts := make([]string, len(d.fields))
	longest_field_that_has_comment_on_right: int

	for &f, fi in d.fields {
		fb := strings.builder_make()

		pf(&fb, "%s: ", f.name)

		after_name_padding := longest_name-len(f.name)
		for _ in 0..<after_name_padding {
			strings.write_rune(&fb, ' ')
		}

		if f.type_overrride != "" {
			p(&fb, f.type_overrride)
		} else {
			output_declaration_type(f.type, indent + 1, b)
		}

		pf(&fb, ",")

		text := strings.to_string(fb)
		field_texts[fi] = text

		if f.comment_on_right != "" && len(text) > longest_field_that_has_comment_on_right {
			longest_field_that_has_comment_on_right = len(text)
		}
	}

	if len(d.fields) == 0 {
		p(b, "struct {}")
		return
	}

	pln(b, "struct {")
	for &f, fi in d.fields {
		if f.comment_before != "" {
			output_indent(b, indent + 1)
			pfln(b, "%s", f.comment_before)
		}

		output_indent(b, indent + 1)
		text := field_texts[fi]
		p(b, text)

		if f.comment_on_right != "" {
			// Padding between name and =
			for _ in 0..<longest_field_that_has_comment_on_right-len(text) {
				p(b, ' ')
			}

			pf(b, " %v", f.comment_on_right)
		}

		pf(b, "\n")
	}
	
	output_indent(b, indent)
	p(b, "}")
}

output_indent :: proc(b: ^strings.Builder, indent: int) {
	for _ in 0..<indent {
		pf(b, "\t")
	}
}

p :: fmt.sbprint
pfln :: fmt.sbprintfln
pf :: fmt.sbprintf
pln :: fmt.sbprintln

output_struct_declaration :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	t_struct := &t.(Type_Struct)

	longest_name: int
	for &f in t_struct.fields {
		if len(f.name) > longest_name {
			longest_name = len(f.name)
		}
	}

	field_texts := make([]string, len(t_struct.fields))
	longest_field_that_has_comment_on_right: int

	for &f, fi in t_struct.fields {
		fb := strings.builder_make()

		pf(&fb, "%s: ", f.name)

		after_name_padding := longest_name-len(f.name)
		for _ in 0..<after_name_padding {
			strings.write_rune(&fb, ' ')
		}

		if f.type_overrride != "" {
			p(&fb, f.type_overrride)
		} else {
			parse_type_build(types, f.type, &fb, indent + 1)
		}

		pf(&fb, ",")

		text := strings.to_string(fb)
		field_texts[fi] = text

		if f.comment_on_right != "" && len(text) > longest_field_that_has_comment_on_right {
			longest_field_that_has_comment_on_right = len(text)
		}
	}

	if len(t_struct.fields) == 0 {
		p(b, "struct {}")
		return
	}

	pln(b, "struct {")
	for &f, fi in t_struct.fields {
		if f.comment_before != "" {
			output_indent(b, indent + 1)
			pfln(b, "%s", f.comment_before)
		}

		output_indent(b, indent + 1)
		text := field_texts[fi]
		p(b, text)

		if f.comment_on_right != "" {
			// Padding between name and =
			for _ in 0..<longest_field_that_has_comment_on_right-len(text) {
				p(b, ' ')
			}

			pf(b, " %v", f.comment_on_right)
		}

		pf(b, "\n")
	}
	
	output_indent(b, indent)
	p(b, "}")
}

output_enum_declaration :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	t_enum := &t.(Type_Enum)

	pfln(b, "enum %v {{", t_enum.storage_type)
	for &m in t_enum.members {
		output_indent(b, indent + 1)
		pf(b, "%s", m.name)
		pf(b, " = %v", m.value)
		p(b, ",\n")
	}
	
	output_indent(b, indent)
	p(b, "}")
}

parse_type_build :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	switch &tv in t {
	case Type_Unknown:
		log.warn("Is this a bug?")

	case Type_Named:
		if tv.name == "" {
			log.errorf("Named type with index %v has no name", idx)
			break
		}
		p(b, string(tv.name))

	case Type_Override:
		p(b, tv.definition_text)

	case Type_Pointer:
		if tv.multipointer {
			p(b, "[^]")
		} else {
			p(b, "^")
		}
		
		parse_type_build(types, tv.pointed_to_type, b, indent)

	case Type_Raw_Pointer:
		p(b, "rawptr")

	case Type_Struct:
		output_struct_declaration(types, idx, b, indent)

	case Type_Alias:
		parse_type_build(types, tv.aliased_type, b, indent)

	case Type_Enum:
		output_enum_declaration(types, idx, b, indent)

	case Type_Procedure:
		pfln(b, "proc()")

	case Type_Fixed_Array:
		pf(b, "[%i]", tv.size)
		parse_type_build(types, tv.element_type, b, indent)

	case Type_Bit_Set:
		t_bs := types[tv.enum_type]
		named, is_named := t_bs.(Type_Named)

		if !is_named {
			log.error("Didn't use named enum type with bit set")
			break
		}

		enum_type, enum_type_ok := types[named.definition].(Type_Enum)

		if enum_type_ok {
			pf(b, "bit_set[%v; %v]", named.name, enum_type.storage_type)	
		}
	}
}

get_type_string :: proc(types: []Type, idx: Type_Index) -> string {
	// For getting function parameter names: https://stackoverflow.com/questions/79356416/how-can-i-get-the-argument-names-of-a-function-types-argument-list
	b := strings.builder_make()
	parse_type_build(types, idx, &b, 0)
	return strings.to_string(b)
}