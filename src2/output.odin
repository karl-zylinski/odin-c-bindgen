// Never import clang within this file. Resolve any clang-related things in one of the
// translate_X.odin files.
#+private file
package bindgen2

import "core:os"
import "core:fmt"
import "core:strings"
import "core:log"

Output_Input :: Translate_Process_Result

// Takes the result of `translate_process` and outputs bindings into `filename`.
@(private="package")
output :: proc(o: Output_Input, filename: string, package_name: string) {
	ensure(filename != "")
	ensure(package_name != "")
	builder := strings.builder_make()
	sb := &builder

	if o.top_comment != "" {
		pln(sb, o.top_comment)
	}

	pfln(sb, "package %v", package_name)
	pln(sb, "")

	if o.import_core_c {
		pln(sb, "import core_c \"core:c\"\n")
	}

	p(sb, o.top_code)

	// None if previous decls wasn't a proc
	inside_foreign_block: bool
	foreign_block_calling_conv: Calling_Convention
	prev_multiline := false

	fr_decls_loop: for &d in o.decls {
		rhs_builder := strings.builder_make()
		parse_type_build(o.types, d.type, &rhs_builder, 0)
		rhs := strings.to_string(rhs_builder)

		if rhs == d.name {
			continue
		}

		proc_type, is_proc := o.types[d.type].(Type_Procedure)

		if is_proc {
			start_foreign_block := false

			if inside_foreign_block {
				if proc_type.calling_convention != foreign_block_calling_conv  {
					pln(sb, "}")
					start_foreign_block = true
					foreign_block_calling_conv = proc_type.calling_convention
				}
			} else {
				inside_foreign_block = true
				start_foreign_block = true
				foreign_block_calling_conv = proc_type.calling_convention
			}

			if start_foreign_block {
				pfln(sb, "@(default_calling_convention=\"%s\")\nforeign lib {{", calling_convention_string(proc_type.calling_convention))
			}
		} else {
			if inside_foreign_block {
				pln(sb, "}")
				inside_foreign_block = false
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

		multiline := strings.contains_rune(rhs, '\n')

		if multiline || prev_multiline {
			p(sb, "\n")
		}

		pf(sb, "%v :: %v", d.name, rhs)

		p(sb, "\n")

		prev_multiline = multiline
	}

	if inside_foreign_block {
		pln(sb, "}")
	}

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
			switch r in f.type {
			case string:
				p(&fb, r)
			case Type_Index:
				if proc_type, is_proc_type := type_from_identifier(types, r, Type_Procedure); is_proc_type {
					output_procedure_signature(types, proc_type, &fb, indent, explicit_calling_convention = true)
				} else {
					parse_type_build(types, r, &fb, indent + 1)
				}
			}
			
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

	p(b, "struct")

	if t_struct.raw_union {
		p(b, " #raw_union")
	}

	pln(b, " {")

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

	overlap_length := 0

	if len(t_enum.members) > 1 {
		overlap_length_source := t_enum.members[0].name
		overlap_length = len(overlap_length_source)

		for idx in 1..<len(t_enum.members) {
			mn := t_enum.members[idx].name
			length := strings.prefix_length(mn, overlap_length_source)

			if length < overlap_length {
				overlap_length = length
				overlap_length_source = mn
			}
		}
	}

	for &m in t_enum.members {
		output_indent(b, indent + 1)
		name_without_overlap := m.name[overlap_length:]

		if len(name_without_overlap) == 0 {
			pf(b, "%s", m.name)
		} else {
			pf(b, "%s", name_without_overlap)
		}

		pf(b, " = %v", m.value)
		p(b, ",\n")
	}
	
	output_indent(b, indent)
	p(b, "}")
}

// TODO: Clangs seems to always output C calling convention, investigate why.
calling_convention_string :: proc(calling_convention: Calling_Convention) -> string {
	switch calling_convention {
	case .C:
		return "c"
	case .Std_Call:
		return "stdcall"
	case .Fast_Call:
		return "fastcall"
	}

	return "c"
}

ensure_name_valid :: proc(n: string) -> string {
	switch n {
	case "dynamic": return "_dynamic"
	}
	return n
}

output_type_identifier :: proc(types: []Type, ri: Type_Identifier, b: ^strings.Builder, indent: int) {
	switch v in ri {
	case string:
		p(b, ensure_name_valid(v))
	case Type_Index:
		parse_type_build(types, v, b, indent)
	}
}

output_procedure_signature :: proc(types: []Type, tp: Type_Procedure, b: ^strings.Builder, indent: int, explicit_calling_convention := false) {
	pf(b, "proc")

	if explicit_calling_convention {
		pf(b, " \"%s\" ", calling_convention_string(tp.calling_convention))
	}

	pf(b, "(")

	for param, idx in tp.parameters {
		if idx != 0 {
			p(b, ", ")
		}

		if param.name == "" {
			output_type_identifier(types, param.type, b, indent)
		} else {
			pf(b, "%s: ", ensure_name_valid(param.name))
			output_type_identifier(types, param.type, b, indent)
		}
	}

	pf(b, ")")

	if tp.result_type != nil {
		p(b, " -> ")
		output_type_identifier(types, tp.result_type, b, indent)
	}
}

parse_type_build :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	switch &tv in t {
	case Type_Unknown:
		log.warn("Is this a bug?")

	case Type_Override:
		p(b, tv.definition_text)

	case Type_Pointer:
		p(b, "^")
		output_type_identifier(types, tv.pointed_to_type, b, indent)

	case Type_Multipointer:
		p(b, "[^]")
		output_type_identifier(types, tv.pointed_to_type, b, indent)

	case Type_CString:
		p(b, "cstring")

	case Type_Raw_Pointer:
		p(b, "rawptr")

	case Type_Struct:
		output_struct_declaration(types, idx, b, indent)

	case Type_Alias:
		if proc_type, is_proc_type := type_from_identifier(types, tv.aliased_type, Type_Procedure); is_proc_type {
			output_procedure_signature(types, proc_type, b, indent, explicit_calling_convention = true)
		} else {
			output_type_identifier(types, tv.aliased_type, b, indent)
		}

	case Type_Enum:
		output_enum_declaration(types, idx, b, indent)

	case Type_Procedure:
		output_procedure_signature(types, tv, b, indent)
		pf(b, " ---")

	case Type_Fixed_Array:
		pf(b, "[%i]", tv.size)
		output_type_identifier(types, tv.element_type, b, indent)

	case Type_Bit_Set:
		enum_type_str, enum_type_is_str := tv.enum_type.(string)

		if !enum_type_is_str {
			log.error("Invalid type used with bit set")
			return
		}

		pf(b, "bit_set[%v; i32]", enum_type_str)	
	}
}
