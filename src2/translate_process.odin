#+private file
package bindgen2

import clang "../libclang"
import "core:strings"
import "core:slice"
import "core:log"
import "core:math/bits"
import "core:mem"
import "core:unicode"
import "core:unicode/utf8"

@(private="package")
translate_process :: proc(ts: ^Translate_State) -> Output_State {
	decls: [dynamic]Declaration

	// First: Rename all types that need renaming and also replace them.
	for &t in ts.types {
		if nt, nt_ok := &t.(Type_Named); nt_ok {
			if new_name, renamed := ts.config.rename[nt.name]; renamed {
				nt.name = new_name
			}

			// Note: This should use the new name!

			if nt.definition != TYPE_INDEX_NONE {
				override: bool
				override_definition_text: string

				if type_override, has_override := ts.config.type_overrides[nt.name]; has_override {
					override = true
					override_definition_text = type_override
				}	

				if alias, is_alias := ts.types[nt.definition].(Type_Alias); is_alias {
					named_alias, alias_is_named := ts.types[alias.aliased_type].(Type_Named)
					if alias_is_named && nt.name == named_alias.name {
						override = false
					}
				}

				if override {
					ts.types[nt.definition] = Type_Override {
						definition_text = override_definition_text,
					}
				}
			}
		}
	}

	for &d in ts.declarations {
		t := ts.types[d.named_type]
		tn, is_named := t.(Type_Named)

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
		case Type_Enum:
			if bit_set_name, bit_setify := ts.config.bit_setify[tn.name]; bit_setify {
				new_members: [dynamic]Type_Enum_Member

				// log2-ify value so `2` becomes `1`, `4` becomes `2` etc.
				for m in dv.members {
					if m.value == 0 {
						continue
					}

					append(&new_members, Type_Enum_Member {
						name = m.name,
						value = int(bits.log2(uint(m.value)))
					})
				}

				dv.members = new_members[:]
				bs_idx := Type_Index(len(ts.types))

				append(&ts.types, Type_Bit_Set {
					enum_type = d.named_type,
				})

				bs_named_type_idx := Type_Index(len(ts.types))
				
				append(&ts.types, Type_Named {
					name = bit_set_name,
					definition = bs_idx,
				})

				append(&decls, Declaration {
					named_type = bs_named_type_idx,
				})
			}
		}
	}

	// Extract any big comment at top of file (clang doesn't see these)
	top_comment: string

	{
		src := strings.trim_space(ts.source)
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
			top_comment = strings.trim_space(src[:top_comment_end])
		}
	}

	return {
		decls = decls[:],
		types = ts.types[:],
		top_comment = top_comment,
	}
}
