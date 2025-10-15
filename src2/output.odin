// Never import clang within this file. Resolve any clang-related things in one of the
// translate_X.odin files.
#+private file
package bindgen2

import "core:os"
import "core:fmt"
import "core:strings"
import "core:log"
import "core:unicode/utf8"
import "core:unicode"

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

	if o.import_core_c {
		pln(sb, "")
		pln(sb, "import \"core:c\"")
	}

	if o.top_code != "" {
		p(sb, "\n")
		p(sb, o.top_code)
		p(sb, "\n")
	}

	// None if previous decls wasn't a proc
	inside_foreign_block: bool
	foreign_block_calling_conv: Calling_Convention
	prev_multiline := true

	fr_decls_loop: for &d in o.decls {
		rhs_builder := strings.builder_make()
		output_definition(o.types, d.def, &rhs_builder, 0)
		rhs := strings.to_string(rhs_builder)

		if rhs == string(d.name) {
			continue
		}

		proc_type, is_proc := resolve_type_definition(o.types, d.def, Type_Procedure)

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
				pf(sb, "\n@(default_calling_convention=\"%s\"", calling_convention_string(proc_type.calling_convention))

				if o.link_prefix != "" {
					pf(sb, `, link_prefix="%v"`, o.link_prefix)
				}

				pln(sb, ")")

				pln(sb, "foreign lib {")
			}
		} else {
			if inside_foreign_block {
				pln(sb, "}")
				inside_foreign_block = false
			}
		}

		multiline := strings.contains_rune(rhs, '\n')

		if multiline || prev_multiline || d.comment_before != "" {
			p(sb, "\n")
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

		pf(sb, "%v%*s:: %v", d.name, max(d.explicit_whitespace_after_name, 1), "", rhs)

		if d.side_comment != "" {
			pf(sb, "%*s%v", d.explicit_whitespace_before_side_comment, "", d.side_comment)
		}

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

output_struct_definition :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
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

		if f.name == "" && !f.anonymous {
			log.error("Struct field has no name and is not anonymous")
			continue
		}

		if f.anonymous {
			p(&fb, "using _: ")
		} else {
			pf(&fb, "%s: ", f.name)	
		}

		after_name_padding := longest_name-len(f.name)
		for _ in 0..<after_name_padding {
			strings.write_rune(&fb, ' ')
		}

		if f.type_overrride != "" {
			p(&fb, f.type_overrride)
		} else {
			switch r in f.type {
			case Type_Name, Fixed_Value:
				p(&fb, r)
			case Type_Index:
				if proc_type, is_proc_type := resolve_type_definition(types, r, Type_Procedure); is_proc_type {
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

output_enum_definition :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	t_enum := &t.(Type_Enum)

	pfln(b, "enum %v {{", t_enum.storage_type)

	for &m in t_enum.members {
		output_indent(b, indent + 1)
		pf(b, "%v = %v", m.name, m.value)
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

output_definition :: proc(types: []Type, def: Definition, b: ^strings.Builder, indent: int) {
	switch d in def {
	case Type_Name, Fixed_Value:
		p(b, d)
	case Type_Index:
		parse_type_build(types, d, b, indent)
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
			output_definition(types, param.type, b, indent)
		} else {
			pf(b, "%s: ", param.name)
			output_definition(types, param.type, b, indent)
		}
	}

	pf(b, ")")

	if tp.result_type != nil {
		p(b, " -> ")
		output_definition(types, tp.result_type, b, indent)
	}
}

parse_type_build :: proc(types: []Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	switch &tv in t {
	case Type_Unknown:
		log.warn("Is this a bug?")

	case Type_Pointer:
		p(b, "^")
		output_definition(types, tv.pointed_to_type, b, indent)

	case Type_Multipointer:
		p(b, "[^]")
		output_definition(types, tv.pointed_to_type, b, indent)

	case Type_CString:
		p(b, "cstring")

	case Type_Raw_Pointer:
		p(b, "rawptr")

	case Type_Struct:
		output_struct_definition(types, idx, b, indent)

	case Type_Alias:
		if proc_type, is_proc_type := resolve_type_definition(types, tv.aliased_type, Type_Procedure); is_proc_type {
			output_procedure_signature(types, proc_type, b, indent, explicit_calling_convention = true)
		} else {
			output_definition(types, tv.aliased_type, b, indent)
		}

	case Type_Enum:
		output_enum_definition(types, idx, b, indent)

	case Type_Procedure:
		output_procedure_signature(types, tv, b, indent)
		pf(b, " ---")

	case Type_Fixed_Array:
		pf(b, "[%i]", tv.size)
		output_definition(types, tv.element_type, b, indent)

	case Type_Bit_Set:
		enum_type_name, enum_type_is_name := tv.enum_type.(Type_Name)

		if !enum_type_is_name {
			log.error("Invalid type used with bit set")
			return
		}

		pf(b, "bit_set[%v; i32]", enum_type_name)
	}
}
