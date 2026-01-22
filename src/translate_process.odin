#+private file
package bindgen2

import "core:strings"
import "core:slice"
import "core:log"
import "core:math/bits"
import "core:unicode"
import "core:unicode/utf8"
import "core:fmt"
import "core:os"

@(private="package")
Translate_Process_Result :: struct {
	// Comment at top of file
	top_comment: string,
	top_code: string,
	link_prefix: string,

	extra_imports: []string,
}

@(private="package")
translate_process :: proc(tcr: Translate_Collect_Result, config: Config, types: Type_List, decls: Decl_List) -> Translate_Process_Result {
	forward_declare_resolved: map[string]bool

	to_remove: map[string]struct{}

	for r in config.remove {
		to_remove[r] = {}
	}

	for &d in decls {
		if d.name in to_remove {
			d.invalid = true
			continue
		}

		if d.is_forward_declare {
			if d.name in forward_declare_resolved {
				d.invalid = true
				continue
			}

			forward_declare_resolved[d.name] = false
		}
	}

	for &d in decls {
		// A bit of a hack due to aliases being disregarded later. Perhaps we can change that?
		if _, is_alias := resolve_type_definition(types, d.def, Type_Alias); is_alias {
			continue
		}

		if !d.is_forward_declare && d.name in forward_declare_resolved {
			forward_declare_resolved[d.name] = true
		}
	}

	// Replace types
	for &d in decls {
		override: bool
		override_definition_text: string

		if type_override, has_override := config.type_overrides[d.name]; has_override {
			override = true
			override_definition_text = type_override
		}	

		// Don't override if this is type is an alias that has the same name as the aliased name.
		// Doing that override will just make this alias not get ignored, as it is no longer just
		// doing Some_Type :: Some_Type, but rather Some_New_Type :: Some_Type.
		if alias, is_alias := resolve_type_definition(types, d.def, Type_Alias); is_alias {
			named_alias, alias_is_named := alias.aliased_type.(Type_Name)
			if alias_is_named && d.name == string(named_alias) {
				override = false
			}
		}

		if override {
			d.def = Fixed_Value(override_definition_text)
		}
	}

	remove_enum_members: map[string]struct{}
	remove_enum_suffixes: [dynamic]string
	remove_enum_prefixes: [dynamic]string

	for e in config.remove_enum_members {
		if strings.has_prefix(e, "*") {
			append(&remove_enum_suffixes, e[1:])
		} else if strings.has_suffix(e, "*") {
			append(&remove_enum_prefixes, e[:len(e) - 1])
		} else {
			remove_enum_members[e] = {}
		}
	}

	// Declared here to reuse.
	bit_set_make_constant: map[string]int

	for &d, i in decls {
		if i == 0 {
			d.invalid = true
			continue
		}

		if d.is_forward_declare && forward_declare_resolved[d.name] {
			d.invalid = true
			continue
		}

		if d.name == "" {
			d.invalid = true
			log.errorf("Declaration has no name: %v", d.name)
			continue
		}

		if d.def == nil {
			d.invalid = true
			log.errorf("Type used in declaration %v is zero", d.name)
			continue
		}

		if _, is_fixed_value := d.def.(Fixed_Value); is_fixed_value {
			continue
		}

		if _, is_type_name := d.def.(Type_Name); is_type_name {
			continue
		}

		if _, is_macro_name := d.def.(Macro_Name); is_macro_name {
			continue
		}

		type := &types[d.def.(Type_Index)]

		#partial switch &v in type {
		case Type_Enum:
			automatically_strip_member_prefixes := true
			strip_member_prefix := config.remove_enum_member_prefix[d.name]

			original_member_names: [dynamic]string

			{
				if strip_member_prefix != "" {
					automatically_strip_member_prefixes = false
				}

				new_members: [dynamic]Type_Enum_Member
				
				member_loop: for m in v.members {
					if m.name in remove_enum_members {
						continue
					}

					for p in remove_enum_suffixes {
						if strings.has_suffix(m.name, p) {
							continue member_loop
						}
					}

					for p in remove_enum_prefixes {
						if strings.has_prefix(m.name, p) {
							continue member_loop
						}
					}

					append(&original_member_names, m.name)

					new_m := m
					new_m.name = strings.trim_prefix(new_m.name, strip_member_prefix)

					append(&new_members, new_m)
				}

				v.members = new_members[:]
			}

			if automatically_strip_member_prefixes {
				strip_enum_member_prefixes(&v)
			}

			// Stripping might have caused members to start with a number. Fix that!
			for &m in v.members {
				if is_number(m.name[0]) {
					m.name = fmt.tprintf("_%v", m.name)
				}
			}

			bit_set_enum_name, bit_setify := config.bit_setify[d.name]

			if bit_setify {
				clear(&bit_set_make_constant)

				bs_idx := add_type(types, Type_Bit_Set {
					enum_type = d.def.(Type_Index),
					enum_decl_name = Type_Name(bit_set_enum_name),
				})

				new_members: [dynamic]Type_Enum_Member

				// log2-ify value so `2` becomes `1`, `4` becomes `2` etc.
				for m, m_idx in v.members {
					if m.value == 0 {
						continue
					}

					if bits.count_ones(m.value) != 1 {
						// Not a power of two, so not part of a bit_set. Save it for later for making
						// it into a constant.
						bs_constant_idx := add_type(types, Type_Bit_Set_Constant {
							bit_set_type = bs_idx,
							bit_set_type_name = Type_Name(d.name),
							value = m.value,
						})

						name := m.name

						if len(original_member_names) == len(v.members) {
							name = original_member_names[m_idx]
						}

						constant_name := strings.to_screaming_snake_case(strings.trim_prefix(strings.to_lower(name), strings.to_lower(config.remove_type_prefix)))

						add_decl(decls, {
							original_line = d.original_line + 2,
							name = constant_name,
							def = bs_constant_idx,
							explicitly_created = true,
						})

						continue
					}

					append(&new_members, Type_Enum_Member {
						name = m.name,
						value = int(bits.log2(uint(m.value))),
						comment_before = m.comment_before,
						comment_on_right = m.comment_on_right,
					})
				}

				v.members = new_members[:]

				enum_decl := d
				enum_decl.comment_before = ""
				enum_decl.side_comment = ""
				d.def = bs_idx
				d.original_line += 1

				enum_decl.name = bit_set_enum_name

				add_decl(decls, enum_decl)
			}

		case Type_Struct:
			for &f in v.fields {
				if len(f.names) != 1 {
					continue
				}

				field_key := fmt.tprintf("%s.%s", d.name, f.names[0])
				if override, has_override := config.struct_field_overrides[field_key]; has_override {
					if new_type, ok := augment_pointers(f.type, types, override); ok {
						f.type = new_type
					} else if override == "using" {
						f.is_using = true
					} else {
						f.type = Fixed_Value(override)
					}
				}

				if proc_type := resolve_type_definition_ptr(types, f.type, Type_Procedure); proc_type != nil {
					override_procedure(proc_type, field_key, types, config)
				}

				if tag, has_tag := config.struct_field_tags[field_key]; has_tag {
					f.tag = tag
				}
			}
		case Type_Procedure:
			override_procedure(&v, d.name, types, config)

		case Type_Alias:
			// This condition is only true for direct typedefs of function types,
			// since every other typedef is represented as an alias to Type_Name/Fixed_Value.
			if proc_type := resolve_type_definition_ptr(types, v.aliased_type, Type_Procedure); proc_type != nil {
				override_procedure(proc_type, d.name, types, config)
			}
		}
	}

	top_code: string

	if config.imports_file != "" {
		if imports, imports_ok := os.read_entire_file(config.imports_file); imports_ok {
			top_code = string(imports)
		}
	} else if config.import_lib != "" {
		top_code = fmt.tprintf("foreign import lib \"%v\"\n_ :: lib", config.import_lib)
	}

	if config.procedures_at_end {
		context.user_ptr = types
		slice.sort_by(decls[:], proc(i, j: Decl) -> bool {
			types := (Type_List)(context.user_ptr)
			_, i_is_proc := resolve_type_definition(types, i.def, Type_Procedure)
			_, j_is_proc := resolve_type_definition(types, j.def, Type_Procedure)

			if i_is_proc != j_is_proc {
				return j_is_proc
			}

			return i.original_line < j.original_line
		})
	} else {
		slice.sort_by(decls[:], proc(i, j: Decl) -> bool {
			return i.original_line < j.original_line
		})
	}

	// Run this last! Otherwise mapping that assumes things has their original names may fail.
	resolve_final_names(types, decls, config)

	return {
		top_comment = extract_top_comment(tcr.source),
		top_code = top_code,
		link_prefix = config.remove_function_prefix,
		extra_imports = tcr.extra_imports,
	}
}

strip_enum_member_prefixes :: proc(e: ^Type_Enum) {
	overlap_length := 0

	if len(e.members) > 1 {
		overlap_length_source := e.members[0].name
		overlap_length = len(overlap_length_source)

		for idx in 1..<len(e.members) {
			mn := e.members[idx].name
			length := strings.prefix_length(mn, overlap_length_source)

			if length < overlap_length {
				overlap_length = length
				overlap_length_source = mn
			}
		}

		if overlap_length > 0 {
			back_off := false
			underscore_in_member := false

			for &m in e.members {
				if strings.contains(m.name[overlap_length:], "_") {
					underscore_in_member = true
					break
				}
			}

			if !underscore_in_member && strings.count(overlap_length_source, "_") > 1 {
				back_off = true
			}

			for &m in e.members {
				if overlap_length == len(m.name) {
					back_off = true
					break
				}
			}

			// We stripped too much! Back off to nearest underscore or camelCase change
			if back_off {
				found_underscore := false
				#reverse for c, i in overlap_length_source {
					if c == '_' {
						overlap_length = i + 1
						found_underscore = true
						break
					}
				}

				// No underscore found, try camelCase
				if !found_underscore {
					last_letter: rune

					#reverse for c in overlap_length_source {
						if unicode.is_letter(c) {
							last_letter = c
							break
						}
					}

					#reverse for c, i in overlap_length_source {
						if unicode.is_letter(c) && unicode.is_upper(c) != unicode.is_upper(last_letter) {
							overlap_length = i + 1
							break
						}
					}
				}
			}
		}
	}

	if overlap_length > 0 {
		for &m in e.members {
			name_without_overlap := m.name[overlap_length:]

			if len(name_without_overlap) != 0 {
				m.name = name_without_overlap
			}
		}
	}
}

// Give all types and declarations their final names. Based on config, but also strips enum prefixes etc.
resolve_final_names :: proc(types: Type_List, decls: Decl_List, config: Config) {
	for &t in types {
		switch &tv in t {
		case Type_Unknown:

		case Type_Pointer:
			if type_name, is_type_name := tv.pointed_to_type.(Type_Name); is_type_name {
				tv.pointed_to_type = final_type_name(type_name, config)
			}

		case Type_Multipointer:
			if type_name, is_type_name := tv.pointed_to_type.(Type_Name); is_type_name {
				tv.pointed_to_type = final_type_name(type_name, config)
			}

		case Type_Pointer_By_Ptr:
			if type_name, is_type_name := tv.pointed_to_type.(Type_Name); is_type_name {
				tv.pointed_to_type = final_type_name(type_name, config)
			}

		case Type_Raw_Pointer:

		case Type_CString:

		case Type_Struct:
			for &f in tv.fields {
				for &n in f.names {
					n = ensure_name_valid(n)
				}

				if type_name, is_type_name := f.type.(Type_Name); is_type_name {
					f.type = final_type_name(type_name, config)
				}
			}

		case Type_Enum:

		case Type_Bit_Set:
			if type_name, is_type_name := tv.enum_decl_name.(Type_Name); is_type_name {
				tv.enum_decl_name = final_type_name(type_name, config)
			}

		case Type_Bit_Set_Constant:
			tv.bit_set_type_name = final_type_name(tv.bit_set_type_name, config)

		case Type_Alias:
			if type_name, is_type_name := tv.aliased_type.(Type_Name); is_type_name {
				tv.aliased_type = final_type_name(type_name, config)
			}

		case Type_Fixed_Array:
			if type_name, is_type_name := tv.element_type.(Type_Name); is_type_name {
				tv.element_type = final_type_name(type_name, config)
			}

		case Type_Procedure:
			for &p in tv.parameters {
				p.name = ensure_name_valid(p.name)

				if type_name, is_type_name := p.type.(Type_Name); is_type_name {
					p.type = final_type_name(type_name, config)
				}
			}

			if type_name, is_type_name := tv.result_type.(Type_Name); is_type_name {
				tv.result_type = final_type_name(type_name, config)
			}
		}
	}

	for &d in decls {
		d.name = final_decl_name(d, types, config)
		
		switch &def in d.def {
		case Type_Name: d.def = final_type_name(def, config)
		case Macro_Name: d.def = final_macro_name(def, config)

		case Fixed_Value:
			if d.from_macro {
				s := string(def)

				s = strip_prefix_in_idents(s, config.remove_macro_prefix)
				s = strip_prefix_in_idents(s, config.remove_type_prefix)

				d.def = Fixed_Value(s)
			}

		case Type_Index:
		}
	}
}

override_procedure :: proc(p: ^Type_Procedure, name: string, types: Type_List, config: Config) {
	for &param, param_idx in p.parameters {
		param_name := len(param.name) != 0 ? param.name : fmt.tprintf("#%d", param_idx)
		param_key := fmt.tprintf("%s.%s", name, param_name)
		if override, has_override := config.procedure_type_overrides[param_key]; has_override {
			override_procedure_parameter(&param, types, override)
		} else if proc_type := resolve_type_definition_ptr(types, param.type, Type_Procedure); proc_type != nil {
			override_procedure(proc_type, param_key, types, config)
		}

		if default, has_default := config.procedure_parameter_defaults[param_key]; has_default {
			param.default = default
		}
	}

	return_override_key := name

	if override, has_override := config.procedure_type_overrides[return_override_key]; has_override {
		if new_type, ok := augment_pointers(p.result_type, types, override); ok {
			p.result_type = new_type
		} else {
			p.result_type = Fixed_Value(override)
		}
	}
}

override_procedure_parameter :: proc(p: ^Type_Procedure_Parameter, types: Type_List, override: string) {
	if new_type, ok := augment_pointers(p.type, types, override); ok {
		p.type = new_type
	} else if override == "#by_ptr" {
		if ptr_type, is_ptr_type := resolve_type_definition(types, p.type, Type_Pointer); is_ptr_type {
			p.type = add_type(types, Type_Pointer_By_Ptr {
				pointed_to_type = ptr_type.pointed_to_type,
			})
		}
	} else if override == "#any_int" {
		p.any_int = true
	} else {
		p.type = Fixed_Value(override)
	}
}

augment_pointers :: proc(type: Definition, types: Type_List, override: string) -> (Definition, bool) {
	if override == "" {
		return type, false
	}

	is_wrong_type := false
	new_type := type

	for s := override; s != ""; {
		if ptr_type, is_ptr_type := resolve_type_definition(types, new_type, Type_Pointer); is_ptr_type {
			new_type = ptr_type.pointed_to_type
		} else {
			is_wrong_type = true
		}

		if strings.has_prefix(s, "[^]") {
			s = s[3:]
		} else if strings.has_prefix(s, "^") {
			s = s[1:]
		} else {
			return type, false
		}
	}

	if is_wrong_type {
		// The caller will replace the entire type with override if ok = false,
		// but the override certainly tries to simply augment the type.
		return type, true
	}

	for s := override; s != ""; {
		if strings.has_suffix(s, "[^]") {
			s = s[:len(s) - 3]
			new_type = add_type(types, Type_Multipointer {
				pointed_to_type = new_type,
			})
		} else if strings.has_suffix(s, "^") {
			s = s[:len(s) - 1]
			new_type = add_type(types, Type_Pointer {
				pointed_to_type = new_type,
			})
		} else {
			return type, false
		}
	}

	return new_type, true
}

is_number :: proc(b: byte) -> bool {
	return b >= '0' && b <= '9'
}

ensure_name_valid :: proc(s: string) -> string {
	// TODO make sure this contains all Odin keywords
	KEYWORDS :: [?]string {
		"_bool",
		"_b8",
		"_b16",
		"_b32",
		"_b64",
		"_int",
		"_i8",
		"_i16",
		"_i32",
		"_i64",
		"_i128",
		"_uint",
		"_u8",
		"_u16",
		"_u32",
		"_u64",
		"_u128",
		"_uintptr",
		"_i16le",
		"_i32le",
		"_i64le",
		"_i128le",
		"_u16le",
		"_u32le",
		"_u64le",
		"_u128le",
		"_i16be",
		"_i32be",
		"_i64be",
		"_i128be",
		"_u16be",
		"_u32be",
		"_u64be",
		"_u128be",
		"_f16",
		"_f32",
		"_f64",
		"_f16le",
		"_f32le",
		"_f64le",
		"_f16be",
		"_f32be",
		"_f64be",
		"_complex32",
		"_complex64",
		"_complex128",
		"_quaternion64",
		"_quaternion128",
		"_quaternion256",
		"_rune",
		"_string",
		"_cstring",
		"_string16",
		"_cstring16",
		"_rawptr",
		"_typeid",
		"_any",
		"_asm",
		"_auto_cast",
		"_bit_set",
		"_break",
		"_case",
		"_cast",
		"_context",
		"_continue",
		"_defer",
		"_distinct",
		"_do",
		"_dynamic",
		"_else",
		"_enum",
		"_fallthrough",
		"_for",
		"_foreign",
		"_if",
		"_import",
		"_in",
		"_map",
		"_not_in",
		"_or_else",
		"_or_return",
		"_package",
		"_proc",
		"_return",
		"_struct",
		"_switch",
		"_transmute",
		"_typeid",
		"_union",
		"_using",
		"_when",
		"_where",
		"_matrix",

		// Not keywords, but used names:
		"_c",
	}

	for k in KEYWORDS {
		if s == k[1:] {
			return k
		}
	}

	if len(s) > 0 && unicode.is_number(utf8.rune_at(s, 0)) {
		return fmt.tprintf("_%v", s)
	}

	return s
}

final_decl_name :: proc(d: Decl, types: Type_List, config: Config) -> string {
	if d.explicitly_created {
		return d.name
	}

	if new_name, rename := config.rename[string(d.name)]; rename {
		return new_name
	}

	_, is_proc := resolve_type_definition(types, d.def, Type_Procedure)

	if is_proc {
		return strings.trim_prefix(d.name, config.remove_function_prefix)
	} else if d.from_macro {
		return strings.trim_prefix(d.name, config.remove_macro_prefix)
	} else {
		res := strings.trim_prefix(d.name, config.remove_type_prefix)
		res = strings.trim_suffix(res, config.remove_type_suffix)

		if config.force_ada_case_types {
			res = strings.to_ada_case(res)
		}

		return res
	}

	return d.name
}

final_type_name :: proc(name: Type_Name, config: Config) -> Type_Name {
	if new_name, rename := config.rename[string(name)]; rename {
		return Type_Name(new_name)
	}

	res := strings.trim_prefix(string(name), config.remove_type_prefix)
	res = strings.trim_suffix(res, config.remove_type_suffix)

	if config.force_ada_case_types {
		res = strings.to_ada_case(res)
	}

	return Type_Name(res)
}

final_macro_name :: proc(name: Macro_Name, config: Config) -> Macro_Name {
	return Macro_Name(strings.trim_prefix(string(name), config.remove_macro_prefix))
}

// Extracts any comment at the top of the source file. These will be put above the package line in
// the bindings.
extract_top_comment :: proc(src: string) -> string {
	src := src
	src = strings.trim_space(src)
	top_comment_end: int
	in_block := false
	on_line_comment := false
	
	next_rune :: proc(s: string, cur: rune, cur_idx: int) -> rune {
		next, _ := utf8.decode_rune(s[cur_idx + utf8.rune_size(cur):]) 
		return next
	}

	top_comment_loop: for i := 0; i < len(src); {
		r, r_sz := utf8.decode_rune(src[i:])
		adv := r_sz
		defer i += adv

		if r_sz == 0 {
			break
		}

		if on_line_comment {
			if r == '\n' {
				on_line_comment = false
				top_comment_end = i + 1
			}
		} else if in_block {
			if i + 2 >= len(src) {
				continue
			}

			if src[i:i+2] == "*/" {
				in_block = false
				top_comment_end = i + 2
				adv = 2
			}
		} else {
			if i + 2 >= len(src) {
				continue
			}

			// Only OK to skip whitespace here because `on_line_comment` etc needs to check for newlines.
			if unicode.is_white_space(r) {
				continue
			}

			switch src[i:i+2] {
			case "//":
				adv = 2
				on_line_comment = true
			case "/*":
				adv = 2
				in_block = true
			case:
				top_comment_end = i
				break top_comment_loop
			}
		}
	}

	if top_comment_end > 0 {
		return strings.trim_space(src[:top_comment_end])
	}

	return ""
}

is_ident_char :: proc(c: byte) -> bool {
	return (c >= 'a' && c <= 'z') ||
	       (c >= 'A' && c <= 'Z') ||
	       (c >= '0' && c <= '9') ||
	       (c == '_')
}

is_ident_start :: proc(c: byte) -> bool {
	return (c >= 'a' && c <= 'z') ||
	       (c >= 'A' && c <= 'Z') ||
	       (c == '_')
}

strip_prefix_in_idents :: proc(s: string, prefix: string) -> string {
	if len(prefix) == 0 || len(s) == 0 {
		return s
	}

	out: [dynamic]byte
	out = make([dynamic]byte, 0, len(s))

	in_string := false
	in_char := false
	in_line_comment := false
	in_block_comment := false
	escaped := false

	i := 0
	for i < len(s) {
		if in_line_comment {
			b := s[i]
			append(&out, b)
			i += 1
			if b == '\n' {
				in_line_comment = false
			}
			continue
		}

		if in_block_comment {
			if i + 1 < len(s) && s[i] == '*' && s[i+1] == '/' {
				append(&out, '*')
				append(&out, '/')
				i += 2
				in_block_comment = false
				continue
			}
			append(&out, s[i])
			i += 1
			continue
		}

		if in_string {
			b := s[i]
			append(&out, b)
			i += 1

			if escaped {
				escaped = false
				continue
			}

			if b == '\\' {
				escaped = true
			} else if b == '"' {
				in_string = false
			}
			continue
		}

		if in_char {
			b := s[i]
			append(&out, b)
			i += 1

			if escaped {
				escaped = false
				continue
			}

			if b == '\\' {
				escaped = true
			} else if b == '\'' {
				in_char = false
			}
			continue
		}

		if i + 1 < len(s) && s[i] == '/' && s[i+1] == '/' {
			append(&out, '/')
			append(&out, '/')
			i += 2
			in_line_comment = true
			continue
		}

		if i + 1 < len(s) && s[i] == '/' && s[i+1] == '*' {
			append(&out, '/')
			append(&out, '*')
			i += 2
			in_block_comment = true
			continue
		}

		if s[i] == '"' {
			append(&out, '"')
			i += 1
			in_string = true
			escaped = false
			continue
		}

		if s[i] == '\'' {
			append(&out, '\'')
			i += 1
			in_char = true
			escaped = false
			continue
		}

		if i + len(prefix) <= len(s) && s[i:i+len(prefix)] == prefix {
			prev_ok := (i == 0) || !is_ident_char(s[i-1])
			next_ok := (i + len(prefix) < len(s)) && is_ident_char(s[i+len(prefix)])
			if prev_ok && next_ok {
				i += len(prefix)
				continue
			}
		}

		append(&out, s[i])
		i += 1
	}

	return string(out[:])
}
