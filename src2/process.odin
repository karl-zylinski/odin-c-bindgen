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
				type := parse_type(clang.getCursorType(sc))

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


parse_type :: proc(type: clang.Type) -> string {
	// For getting function parameter names: https://stackoverflow.com/questions/79356416/how-can-i-get-the-argument-names-of-a-function-types-argument-list

	#partial switch type.kind {
	case .Bool:
		return "bool"
	case .Char_U, .UChar:
		return "u8"
	case .UShort:
		return "u16"
	case .UInt:
		return "u32"
	case .ULongLong:
		return "u64"
	case .UInt128:
		return "u128"
	case .Char_S, .SChar:
		return "i8"
	case .Short:
		return "i16"
	case .Int:
		return "i32"
	case .LongLong:
		return "i64"
	case .Int128:
		return "i128"
	case .Float:
		return "f32"
	case .Double, .LongDouble:
		return "f64"
	case .NullPtr:
		return "rawptr"
	}

	return ""
}