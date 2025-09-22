#+private file
package bindgen2

import clang "../libclang"

@(private="package")
process :: proc(ir: ^Intermediate_Representation) -> Final_Representation {
	fr: Final_Representation

	for &s in ir.structs {
		fields: [dynamic]FR_Struct_Field

		struct_children := get_cursor_children(s.cursor)

		for sc in struct_children {
			sc_kind := clang.getCursorKind(sc)
			#partial switch sc_kind {
			case .FieldDecl:
				name := get_cursor_name(sc)
				type := string_from_clang_string(clang.getTypeSpelling(clang.getCursorType(sc)))

				fr_sf := FR_Struct_Field {
					name = name,
					type = type,
				}

				append(&fields, fr_sf)
			}
		}

		name := get_cursor_name(s.cursor)

		fr_s := FR_Struct {
			name = name,
			fields = fields[:],
		}

		append(&fr.structs, fr_s)
	}

	return fr
}
