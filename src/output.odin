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
output :: proc(types: Type_List, decls: Decl_List, o: Output_Input, filename: string, footer: string, package_name: string) {
	ensure(filename != "")
	ensure(package_name != "")
	builder := strings.builder_make()
	sb := &builder

	if o.top_comment != "" {
		pln(sb, o.top_comment)
	}

	pfln(sb, "package %v\n", package_name)

	if len(o.extra_imports) > 0 {
		for ei in o.extra_imports {
			pfln(sb, "import \"%s\"", ei)
		}
		p(sb, "\n")
	}

	if o.top_code != "" {
		pln(sb, o.top_code)
		p(sb, "\n")
	}

	Output_Group_Kind :: enum {
		Default,
		Macro,
		Proc,
	}

	Output_Group_Decl :: struct {
		decl: Decl,
		rhs: string,
	}

	Output_Group :: struct {
		decls: [dynamic]Output_Group_Decl,
		kind: Output_Group_Kind,
		start_foreign_block: bool,
		end_foreign_block: bool,
		proc_calling_convention: Calling_Convention,
	}

	current_group: Output_Group

	for &d in decls {
		if d.invalid {
			continue
		}

		kind: Output_Group_Kind

		proc_type, is_proc := resolve_type_definition(types, d.def, Type_Procedure)

		if is_proc {
			kind = .Proc
		} else if d.from_macro {
			kind = .Macro
		}

		rhs_builder := strings.builder_make()

		if kind == .Proc {
			output_procedure_signature(types, proc_type, &rhs_builder, 1, false)
		} else {
			output_definition(types, d.def, &rhs_builder, 0)
		}

		rhs := strings.to_string(rhs_builder)

		if rhs == string(d.name) {
			continue
		}

		multiline := strings.contains_rune(rhs, '\n')

		if kind != current_group.kind ||
			(kind == .Proc && current_group.proc_calling_convention != proc_type.calling_convention) ||
			d.comment_before != "" ||
			multiline {
			current_group.end_foreign_block = current_group.kind == .Proc && (kind != .Proc ||
				proc_type.calling_convention != current_group.proc_calling_convention)
			output_group(current_group, o, sb)
			clear(&current_group.decls)
			prev_kind := current_group.kind
			prev_proc_calling_conventation := current_group.proc_calling_convention
			current_group.kind = kind
			current_group.start_foreign_block = kind == .Proc && (prev_kind != .Proc ||
				proc_type.calling_convention != prev_proc_calling_conventation)
			current_group.end_foreign_block = kind == .Proc

			current_group.proc_calling_convention = kind == .Proc ? proc_type.calling_convention : {}
		}

		append(&current_group.decls, Output_Group_Decl {
			decl = d,
			rhs = rhs,
		})

		if multiline {
			output_group(current_group, o, sb)
			clear(&current_group.decls)
		}
	}

	output_group(current_group, o, sb)

	output_group :: proc(g: Output_Group, o: Output_Input, sb: ^strings.Builder) {
		if len(g.decls) == 0 {
			return
		}

		k := g.kind

		if g.start_foreign_block {
			pf(sb, "@(default_calling_convention=\"%s\"", calling_convention_string(g.proc_calling_convention))

			if o.link_prefix != "" {
				pf(sb, `, link_prefix="%v"`, o.link_prefix)
			}

			pln(sb, ")")

			pln(sb, "foreign lib {")
		}

		longest_name: int
		for &od in g.decls {
			d := od.decl

			if len(d.name) > longest_name {
				longest_name = len(d.name)
			}
		}

		group_member_texts := make([]string, len(g.decls))
		assert(len(group_member_texts) == len(g.decls))
		longest_member_that_has_comment_on_right: int

		for &od, i in g.decls {
			d := od.decl
			rhs := od.rhs

			tb := strings.builder_make()

			pf(&tb, "%v%*s:: %v", d.name, max(longest_name-len(d.name) + 1, d.explicit_whitespace_after_name), "", rhs)

			if k == .Proc {
				pf(&tb, " ---")
			}

			text := strings.to_string(tb)
			group_member_texts[i] = text

			if d.side_comment != "" && len(text) < 90 && len(text) > longest_member_that_has_comment_on_right {
				longest_member_that_has_comment_on_right = len(text)
			}
		}

		for &od, i in g.decls {
			d := od.decl

			indent := k == .Proc ? 1 : 0

			if d.comment_before != "" {
				cb := d.comment_before
				for l in strings.split_lines_iterator(&cb) {
					output_indent(sb, indent)
					pln(sb, strings.trim_space(l))
				}
			}

			output_indent(sb, indent)
			text := group_member_texts[i]
			p(sb, text)

			if d.side_comment != "" {
				pf(sb, "%*s%v", max(max(longest_member_that_has_comment_on_right-len(text) + 1, 1), d.explicit_whitespace_before_side_comment), "", d.side_comment)
			}

			p(sb, "\n")
		}

		if g.end_foreign_block {
			pln(sb, "}")
		}

		pln(sb, "")
	}

	p(sb, footer)

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

output_struct_definition :: proc(types: ^[dynamic]Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	t_struct := &t.(Type_Struct)

	if len(t_struct.fields) == 0 {
		p(b, "struct {}")
		return
	}

	Struct_Field :: struct {
		type: Type_Struct_Field,
		name: string,
		rhs: string,
	}

	Struct_Fields_Group :: struct {
		header: string,
		line_break_before: bool,
		fields: [dynamic]Struct_Field,
	}


	p(b, "struct")

	if t_struct.raw_union {
		p(b, " #raw_union")
	}

	pln(b, " {")

	current_group: Struct_Fields_Group
	first_field := true

	for &f in t_struct.fields {
		if len(f.names) == 0 && !f.anonymous {
			log.error("Struct field has no name and is not anonymous")
			continue
		}

		// name builder
		nb := strings.builder_make()

		if f.anonymous {
			p(&nb, "using _: ")
		} else {
			if f.is_using {
				p(&nb, "using ")
			}

			for fn, nidx in f.names {
				if nidx != 0 {
					p(&nb, ", ")
				}
				p(&nb, fn)
			}

			p(&nb, ": ")
		}

		name := strings.to_string(nb)

		rhs_builder := strings.builder_make()

		if f.type_overrride != "" {
			p(&rhs_builder, f.type_overrride)
		} else {
			switch r in f.type {
			case Type_Name, Fixed_Value:
				p(&rhs_builder, r)
			case Type_Index:
				parse_type_build(types, r, &rhs_builder, indent + 1)
			}
		}

		if f.tag != "" {
			pf(&rhs_builder, " `%s`", f.tag)
		}

		pf(&rhs_builder, ",")

		rhs := strings.to_string(rhs_builder)
		multiline := strings.contains_rune(rhs, '\n')

		if f.comment_before != "" || multiline {
			output_field_group(current_group, b, indent + 1)
			clear(&current_group.fields)
			current_group.header = f.comment_before
			current_group.line_break_before = !first_field
		}

		first_field = false

		append(&current_group.fields, Struct_Field {
			type = f,
			name = name,
			rhs = rhs,
		})

		if multiline {
			output_field_group(current_group, b, indent + 1)
			clear(&current_group.fields)
			current_group.header = f.comment_before
			current_group.line_break_before = true
		}
	}

	output_field_group(current_group, b, indent + 1)

	output_field_group :: proc(g: Struct_Fields_Group, b: ^strings.Builder, indent: int) {
		if len(g.fields) == 0 {
			return
		}

		if g.line_break_before {
			p(b, "\n")
		}

		if g.header != "" {
			h := g.header

			for l in strings.split_lines_iterator(&h) {
				output_indent(b, indent)
				pln(b, strings.trim_space(l))
			}
		}

		longest_name: int
		for &f in g.fields {
			if len(f.name) > longest_name {
				longest_name = len(f.name)
			}
		}

		longest_field_that_has_comment_on_right: int
		field_texts := make([]string, len(g.fields))

		for f, fi in g.fields {
			tb := strings.builder_make()
			p(&tb, f.name)

			after_name_padding := longest_name-len(f.name)
			for _ in 0..<after_name_padding {
				strings.write_rune(&tb, ' ')
			}

			p(&tb, f.rhs)

			text := strings.to_string(tb)
			field_texts[fi] = text

			if f.type.comment_on_right != "" && len(text) < 120 && len(text) > longest_field_that_has_comment_on_right {
				longest_field_that_has_comment_on_right = len(text)
			}
		}

		for f, fi in g.fields {
			output_indent(b, indent)
			text := field_texts[fi]
			p(b, text)

			if f.type.comment_on_right != "" {
				pf(b, "%*s%v", max(longest_field_that_has_comment_on_right-len(text) + 1, 1), "", f.type.comment_on_right)
			}

			p(b, "\n")
		}
	}
	
	output_indent(b, indent)
	p(b, "}")
}

output_enum_definition :: proc(types: ^[dynamic]Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
	t := types[idx]
	t_enum := &t.(Type_Enum)

	pfln(b, "enum %v {{", t_enum.storage_type)

	longest_name: int
	for &m in t_enum.members {
		if len(m.name) > longest_name {
			longest_name = len(m.name)
		}
	}

	member_texts := make([]string, len(t_enum.members))
	longest_member_that_has_comment_on_right: int

	all_has_default_value := true
	counter := 0
	for &m in t_enum.members {
		if m.value != counter {
			all_has_default_value = false
			break
		}
		counter += 1
	}

	for &m, mi in t_enum.members {
		fb := strings.builder_make()

		pf(&fb, "%s", m.name)	

		if all_has_default_value {
			p(&fb, ",")
		} else {
			after_name_padding := longest_name-len(m.name)
			for _ in 0..<after_name_padding {
				strings.write_rune(&fb, ' ')
			}

			pf(&fb, " = %v,", m.value)
		}

		text := strings.to_string(fb)
		member_texts[mi] = text

		if m.comment_on_right != "" && len(text) > longest_member_that_has_comment_on_right {
			longest_member_that_has_comment_on_right = len(text)
		}
	}

	for &m, mi in t_enum.members {
		if m.comment_before != "" {
			cb := m.comment_before

			if mi > 0 {
				pln(b, "")
			}

			for l in strings.split_lines_iterator(&cb) {
				output_indent(b, indent + 1)	
				pln(b, strings.trim_space(l))
			}
		}
		output_indent(b, indent + 1)

		text := member_texts[mi]
		p(b, text)

		if m.comment_on_right != "" {
			for _ in 0..<longest_member_that_has_comment_on_right-len(text) {
				p(b, ' ')
			}

			p(b, " ")
			p(b, m.comment_on_right)
		}

		p(b, "\n")
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

output_definition :: proc(types: ^[dynamic]Type, def: Definition, b: ^strings.Builder, indent: int) {
	switch d in def {
	case Type_Name, Fixed_Value:
		p(b, d)
	case Type_Index:
		parse_type_build(types, d, b, indent)
	}
}

output_procedure_signature :: proc(types: ^[dynamic]Type, tp: Type_Procedure, b: ^strings.Builder, indent: int, explicit_calling_convention: bool) {
	pf(b, "proc")

	if explicit_calling_convention {
		pf(b, " \"%s\" ", calling_convention_string(tp.calling_convention))
	}

	pf(b, "(")

	all_params_have_name := true

	for param in tp.parameters {
		if param.name == "" {
			all_params_have_name = false
			break
		}
	}

	for param, idx in tp.parameters {
		if idx != 0 {
			p(b, ", ")
		}

		if param.name == "" {
			// We can only write a parameter list without any names if all of them have no name.
			if !all_params_have_name {
				p(b, "_: ")
			}

			output_definition(types, param.type, b, indent)
		} else {
			_, by_ptr := resolve_type_definition(types, param.type, Type_Pointer_By_Ptr)

			if by_ptr {
				pf(b, "#by_ptr ")
			}

			if param.any_int {
				pf(b, "#any_int ")
			}

			pf(b, "%s: ", param.name)
			output_definition(types, param.type, b, indent)
		}
	}

	if tp.is_variadic {
		if len(tp.parameters) > 0 {
			p(b, ", ")
		}
		
		p(b, "#c_vararg _: ..any")
	}

	pf(b, ")")

	if tp.result_type != nil {
		p(b, " -> ")
		output_definition(types, tp.result_type, b, indent)
	}
}

parse_type_build :: proc(types: ^[dynamic]Type, idx: Type_Index, b: ^strings.Builder, indent: int) {
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

	case Type_Pointer_By_Ptr:
		output_definition(types, tv.pointed_to_type, b, indent)

	case Type_CString:
		p(b, "cstring")

	case Type_Raw_Pointer:
		p(b, "rawptr")

	case Type_Struct:
		output_struct_definition(types, idx, b, indent)

	case Type_Alias:
		output_definition(types, tv.aliased_type, b, indent)

	case Type_Enum:
		output_enum_definition(types, idx, b, indent)

	case Type_Procedure:
		output_procedure_signature(types, tv, b, indent, true)

	case Type_Fixed_Array:
		pf(b, "[%i]", tv.size)
		output_definition(types, tv.element_type, b, indent)

	case Type_Bit_Set:
		enum_name, enum_name_ok := tv.enum_decl_name.(Type_Name)

		if !enum_name_ok {
			log.error("Invalid type used with bit set")
			return
		}

		pf(b, "bit_set[%v; i32]", enum_name)

	case Type_Bit_Set_Constant:
		bit_set_type, bit_set_type_ok := resolve_type_definition(types, tv.bit_set_type, Type_Bit_Set)

		if !bit_set_type_ok {
			return
		}

		pf(b, `%v {{`, tv.bit_set_type_name)

		enum_type, enum_type_ok := resolve_type_definition(types, bit_set_type.enum_type, Type_Enum)

		if enum_type_ok {
			first_printed := false
			for &m in enum_type.members {
				if (1 << uint(m.value)) & tv.value != 0 {
					if first_printed == true {
						p(b, ", ")
					} else {
						first_printed = true
					}

					pf(b, ".%v", m.name)
				}
			}
		}
	
		p(b, "}")
	}
}
