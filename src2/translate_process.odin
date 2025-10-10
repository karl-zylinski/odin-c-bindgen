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
import "base:runtime"

@(private="package")
translate_process :: proc(ts: ^Translate_State) -> Output_State {
	decls: [dynamic]Declaration

	// Replace types
	for &d in ts.declarations {
		override: bool
		override_definition_text: string

		if type_override, has_override := ts.config.type_overrides[d.name]; has_override {
			override = true
			override_definition_text = type_override
		}	

		// Don't override if this is type is an alias that has the same name as the aliased name.
		// Doing that override will just make this alias not get ignored, as it is no longer just
		// doing Some_Type :: Some_Type, but rather Some_New_Type :: Some_Type.
		if alias, is_alias := ts.types[d.type].(Type_Alias); is_alias {
			named_alias, alias_is_named := alias.aliased_type.(string)
			if alias_is_named && d.name == named_alias {
				override = false
			}
		}

		if override {
			d.type = add_type(&ts.types, Type_Override {
				definition_text = override_definition_text
			})
		}
	}

	// Build map of enum name -> bit_set config data
	bit_sets_by_enum_name: map[string][dynamic]Config_Bit_Set

	for &b in ts.config.bit_sets {
		sets := &bit_sets_by_enum_name[b.enum_name]

		if sets == nil {
			bit_sets_by_enum_name[b.enum_name] = {}
			sets = &bit_sets_by_enum_name[b.enum_name]
		}

		append(sets, b)
	}

	rename_aliases: map[string]string

	for &dd in ts.declarations {
		if dd.name == "" {
			log.errorf("Declaration has no name: %v", dd.name)
			continue
		}

		if dd.type == 0 {
			log.errorf("Type used in declaration %v is zero", dd.name)
			continue
		}

		append(&decls, dd)
		d := &decls[len(decls) - 1]

		type := &ts.types[d.type]

		#partial switch &v in type {
		case Type_Enum:
			bit_sets := bit_sets_by_enum_name[d.name]

			for b in bit_sets {
				new_members: [dynamic]Type_Enum_Member

				// log2-ify value so `2` becomes `1`, `4` becomes `2` etc.
				for m in v.members {
					if m.value == 0 {
						continue
					}

					append(&new_members, Type_Enum_Member {
						name = m.name,
						value = int(bits.log2(uint(m.value))),
					})
				}

				v.members = new_members[:]

				if b.enum_rename != "" {
					rename_aliases[d.name] = b.enum_rename
					d.name = b.enum_rename
				} else {
					if d.name == b.enum_name {
						log.warnf("bit_set name %v is same as enum name %v. Suggestion: Add \"enum_rename\" = \"New_Name\" on the bit set configuration in bindgen.sjson", b.name, b.enum_name)
					}
				}

				bs_idx := add_type(&ts.types, Type_Bit_Set {
					enum_type = d.name,
				})

				append(&decls, Declaration {
					name = b.name,
					type = bs_idx,
				})
			}

		case Type_Struct:
			for &f in v.fields {
				override_key := fmt.tprintf("%s.%s", d.name, f.name)
				if override, has_override := ts.config.struct_field_overrides[override_key]; has_override {
					ptr_type, is_ptr_type := get_type_reference(ts.types[:], f.type, Type_Pointer)

					if is_ptr_type && override == "[^]" {
						f.type = add_type(&ts.types, Type_Multipointer {
							pointed_to_type = ptr_type.pointed_to_type
						})
					} else {
						f.type = add_type(&ts.types, Type_Override {
							definition_text = override
						})
					}
				}
			}
		case Type_Procedure:
			for &p in v.parameters {
				override_key := fmt.tprintf("%s.%s", d.name, p.name)
				if override, has_override := ts.config.procedure_type_overrides[override_key]; has_override {
					ptr_type, is_ptr_type := get_type_reference(ts.types[:], p.type, Type_Pointer)
					if is_ptr_type && override == "[^]" {
						p.type = add_type(&ts.types, Type_Multipointer {
							pointed_to_type = ptr_type.pointed_to_type
						})
					} else {
						p.type = add_type(&ts.types, Type_Override {
							definition_text = override
						})
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

	if ts.config.imports_file != "" {
		if imports, imports_ok := os.read_entire_file(ts.config.imports_file); imports_ok {
			top_code = string(imports)
		}
	}

	return {
		decls = decls[:],
		types = ts.types[:],
		top_comment = extract_top_comment(ts.source),
		top_code = top_code,
	}
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