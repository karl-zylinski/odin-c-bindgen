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

	fr_decls_loop: for &d in fr.decls {
		t := fr.types[d.named_type].(Type_Named)
		rhs := get_type_string(fr.types, t.definition)

		if rhs == t.name {
			continue
		}

		if d.comment_before != "" {
			pln(sb, d.comment_before)
		}

		pf(sb, "%v :: %v", t.name, rhs)
		p(sb, "\n\n")
	}

	log.info(filename)
	write_err := os.write_entire_file(filename, transmute([]u8)(strings.to_string(builder)))
	fmt.ensuref(write_err == true, "Failed writing %v", filename)
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

	pln(b, "struct {")
	for &f in t_struct.fields {
		if f.comment_before != "" {
			output_indent(b, indent + 1)
			pfln(b, "%s", f.comment_before)
		}

		output_indent(b, indent + 1)
		pf(b, "%s: ", f.name)	
		parse_type_build(types, f.type, b, indent + 1)

		pf(b, ",")

		if f.comment_on_right != "" {
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
		p(b, "^")
		parse_type_build(types, tv.pointed_to_type, b, indent)

	case Type_Raw_Pointer:
		p(b, "rawptr")

	case Type_Struct:
		output_struct_declaration(types, idx, b, indent)

	case Type_Alias:
		parse_type_build(types, tv.aliased_type, b, indent)

	case Type_Enum:
		output_enum_declaration(types, idx, b, indent)

	case Type_Bit_Set:
		t := types[tv.enum_type]
		named, is_named := t.(Type_Named)

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