#+private file
package bindgen2

import clang "../libclang"
import "core:strings"
import "core:slice"
import "core:log"
import "core:math/bits"

@(private="package")
process :: proc(ts: ^Translate_State) -> Final_Representation {
	decls: [dynamic]FR_Declaration

	for &d in ts.declarations {
		t := ts.types[d.type]
		tn, is_named := t.(Type_Named)

		if !is_named {
			log.errorf("Type used in declaration has no name: %v", d.type)
			continue
		}

		if tn.definition == 0 {
			log.errorf("Type used in declaration has no declaration: %v", tn.name)
			continue
		}

		append(&decls, FR_Declaration {
			named_type = d.type,
			comment_before = d.comment,
		})

		def := &ts.types[tn.definition]

		#partial switch &dv in def {
		case Type_Enum:
			if bit_set_name, bit_setify := bit_setify_lookup[tn.name]; bit_setify {
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
					enum_type = d.type,
				})

				bs_named_type_idx := Type_Index(len(ts.types))
				
				append(&ts.types, Type_Named {
					name = bit_set_name,
					definition = bs_idx,
				})

				append(&decls, FR_Declaration {
					named_type = bs_named_type_idx,
				})
			}
		}
	}

	return {
		decls = decls[:],
		types = ts.types[:],
	}
}
