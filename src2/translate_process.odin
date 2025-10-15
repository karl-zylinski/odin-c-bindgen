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
	decls: []Declaration,
	types: []Type,

	// Comment at top of file
	top_comment: string,
	top_code: string,
	link_prefix: string,

	import_core_c: bool,
}

@(private="package")
translate_process :: proc(tcr: Translate_Collect_Result, macros: []Declaration, config: Config) -> Translate_Process_Result {
	types := slice.to_dynamic(tcr.types)

	forward_declare_resolved: map[string]bool

	for &d in tcr.declarations {
		if d.is_forward_declare {
			forward_declare_resolved[d.name] = false
		}
	}

	for &d in tcr.declarations {
		// A bit of a hack due to aliases being disregarded later. Perhaps we can change that?
		if _, is_alias := resolve_type_definition(tcr.types, d.def, Type_Alias); is_alias {
			continue
		}

		if !d.is_forward_declare && d.name in forward_declare_resolved {
			forward_declare_resolved[d.name] = true
		}
	}

	// Replace types
	for &d in tcr.declarations {
		override: bool
		override_definition_text: string

		if type_override, has_override := config.type_overrides[d.name]; has_override {
			override = true
			override_definition_text = type_override
		}	

		// Don't override if this is type is an alias that has the same name as the aliased name.
		// Doing that override will just make this alias not get ignored, as it is no longer just
		// doing Some_Type :: Some_Type, but rather Some_New_Type :: Some_Type.
		if alias, is_alias := resolve_type_definition(types[:], d.def, Type_Alias); is_alias {
			named_alias, alias_is_named := alias.aliased_type.(Type_Name)
			if alias_is_named && d.name == string(named_alias) {
				override = false
			}
		}

		if override {
			d.def = Fixed_Value(override_definition_text)
		}
	}

	// Build map of enum name -> bit_set config data
	bit_sets_by_enum_name: map[string][dynamic]Config_Bit_Set

	for &b in config.bit_sets {
		sets := &bit_sets_by_enum_name[b.enum_name]

		if sets == nil {
			bit_sets_by_enum_name[b.enum_name] = {}
			sets = &bit_sets_by_enum_name[b.enum_name]
		}

		append(sets, b)
	}

	//rename_aliases: map[string]string

	// We make a new array and add the declrations from 'tcr' into it and also maybe some new ones
	decls: [dynamic]Declaration

	for m in macros {
		append(&decls, m)
	}
	
	// Declared here to reuse.
	bit_set_make_constant: map[string]int

	for &dd in tcr.declarations {
		if dd.is_forward_declare && forward_declare_resolved[dd.name] {
			continue
		}

		if dd.name == "" {
			log.errorf("Declaration has no name: %v", dd.name)
			continue
		}

		if dd.def == nil {
			log.errorf("Type used in declaration %v is zero", dd.name)
			continue
		}

		append(&decls, dd)
		d := &decls[len(decls) - 1]

		if _, is_fixed_value := d.def.(Fixed_Value); is_fixed_value {
			continue
		}

		if _, is_type_name := d.def.(Type_Name); is_type_name {
			continue
		}

		type := &types[d.def.(Type_Index)]

		#partial switch &v in type {
		case Type_Enum:
			bit_sets := bit_sets_by_enum_name[d.name]

			for b in bit_sets {
				clear(&bit_set_make_constant)

				if b.enum_rename != "" {
					//rename_aliases[d.name] = b.enum_rename
					d.name = b.enum_rename
				} else {
					if b.name == b.enum_name {
						log.warnf("bit_set name %v is same as enum name %v. Suggestion: Add \"enum_rename\" = \"New_Name\" on the bit set configuration in bindgen.sjson", b.name, b.enum_name)
					}
				}

				bs_idx := add_type(&types, Type_Bit_Set {
					enum_type = d.def.(Type_Index),
					enum_decl_name = Type_Name(d.name),
				})

				new_members: [dynamic]Type_Enum_Member

				// log2-ify value so `2` becomes `1`, `4` becomes `2` etc.
				for m in v.members {
					if m.value == 0 {
						continue
					}

					if bits.count_ones(m.value) != 1 {
						// Not a power of two, so not part of a bit_set. Save it for later for making
						// it into a constant.
						bs_constant_idx := add_type(&types, Type_Bit_Set_Constant {
							bit_set_type = bs_idx,
							bit_set_type_name = Type_Name(b.name),
							value = m.value,
						})

						all_constant := strings.to_screaming_snake_case(strings.trim_prefix(strings.to_lower(m.name), strings.to_lower(config.remove_type_prefix)))

						append(&decls, Declaration {
							original_line = dd.original_line + 2,
							name = all_constant,
							def = bs_constant_idx,
						})

						continue
					}

					append(&new_members, Type_Enum_Member {
						name = m.name,
						value = int(bits.log2(uint(m.value))),
					})
				}

				v.members = new_members[:]

				append(&decls, Declaration {
					original_line = dd.original_line + 1,
					name = b.name,
					def = bs_idx,
				})
			}

		case Type_Struct:
			for &f in v.fields {
				override_key := fmt.tprintf("%s.%s", d.name, f.name)
				if override, has_override := config.struct_field_overrides[override_key]; has_override {
					if override == "[^]" {
						if ptr_type, is_ptr_type := resolve_type_definition(types[:], f.type, Type_Pointer); is_ptr_type {
							f.type = add_type(&types, Type_Multipointer {
								pointed_to_type = ptr_type.pointed_to_type,
							})
						}	
					} else {
						f.type = Fixed_Value(override)
					}
				}
			}
		case Type_Procedure:
			for &p in v.parameters {
				override_key := fmt.tprintf("%s.%s", d.name, p.name)
				if override, has_override := config.procedure_type_overrides[override_key]; has_override {
					
					if override == "[^]" {
						if ptr_type, is_ptr_type := resolve_type_definition(types[:], p.type, Type_Pointer); is_ptr_type {
							p.type = add_type(&types, Type_Multipointer {
								pointed_to_type = ptr_type.pointed_to_type,
							})	
						}	
					} else if override == "#by_ptr" {
						if ptr_type, is_ptr_type := resolve_type_definition(types[:], p.type, Type_Pointer); is_ptr_type {
							p.type = add_type(&types, Type_Pointer_By_Ptr {
								pointed_to_type = ptr_type.pointed_to_type,
							})
						}
					} else {
						p.type = Fixed_Value(override)
					}
				}
			}
		}
	}

	// Find any aliases that need renaming. We do this because the bit_set enum renaming may cause
	// some confusing aliases otherwise.
	/*for &d in ts.declarations {
		t := &ts.types[d.named_type]
		tn, is_named := &t.(Type_Named)

		if !is_named {
			log.errorf("Type used in declaration has no name: %v", d.named_type)
			continue
		}

		if tn.definition == 0 {
			log.errorf("Type used in declaration has no declaration: %v", tn.name)
			continue
		}

		append(&decls, d)

		def := &ts.types[tn.definition]

		#partial switch &dv in def {
		case Type_Alias:
			if new_name, has_new_name := rename_aliases[tn.name]; has_new_name {
				tn.name = new_name
			}
		}
	}*/

	top_code: string

	if config.imports_file != "" {
		if imports, imports_ok := os.read_entire_file(config.imports_file); imports_ok {
			top_code = string(imports)
		}
	} else if config.import_lib != "" {
		top_code = fmt.tprintf(`foreign import lib "%v"`, config.import_lib)
	}

	slice.sort_by(decls[:], proc(i, j: Declaration) -> bool {
		return i.original_line < j.original_line
	})

	// Run this last! Otherwise mapping that assumes things has their original names may fail.
	resolve_final_names(types[:], decls[:], config)

	return {
		decls = decls[:],
		types = types[:],
		top_comment = extract_top_comment(tcr.source),
		top_code = top_code,
		link_prefix = config.remove_function_prefix,
		import_core_c = tcr.import_core_c,
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
			any_blank := false

			for &m in e.members {
				if overlap_length == len(m.name) {
					any_blank = true
					break
				}
			}

			// We stripped to much! Back off to nearest underscore or camelCase change
			if any_blank {
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

	for &m in e.members {
		name_without_overlap := m.name[overlap_length:]

		if len(name_without_overlap) != 0 {
			m.name = name_without_overlap

			if is_number(m.name[0]) {
				m.name = fmt.tprintf("_%v", m.name)
			}
		}
	}
}

// Give all types and declarations their final names. Based on config, but also strips enum prefixes etc.
resolve_final_names :: proc(types: []Type, decls: []Declaration, config: Config) {
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
				f.name = ensure_name_valid(f.name)

				if type_name, is_type_name := f.type.(Type_Name); is_type_name {
					f.type = final_type_name(type_name, config)
				}
			}

		case Type_Enum:
			strip_enum_member_prefixes(&tv)

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
		_, is_proc := resolve_type_definition(types, d.def, Type_Procedure)
		_, is_bs_const := resolve_type_definition(types, d.def, Type_Bit_Set_Constant)

		if is_proc {
			d.name = strings.trim_prefix(d.name, config.remove_function_prefix)
		} else if d.from_macro {
			d.name = strings.trim_prefix(d.name, config.remove_macro_prefix)
		} else if !is_bs_const {
			d.name = string(final_type_name(Type_Name(d.name), config))
		}
	}
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

final_type_name :: proc(name: Type_Name, config: Config) -> Type_Name {
	res := strings.trim_prefix(string(name), config.remove_type_prefix)

	if config.force_ada_case_types {
		res = strings.to_ada_case(res)
	}

	return Type_Name(res)
}

add_type :: proc(array: ^[dynamic]Type, t: Type) -> Type_Index {
	idx := len(array)
	append(array, t)
	return Type_Index(idx)
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