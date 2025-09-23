#+private file
package bindgen2

import clang "../libclang"
import "core:strings"

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

	for &t in ir.typedefs {
		fr_a := FR_Alias {
			new_name = get_cursor_name(t.new_cursor),
			original_name = parse_type(t.original_type),
		}

		// TODO Should this be here or in collector? Should we compare types or names? I think names
		// because in C the types / cursors will be different but they will be the same in Odin...
		if fr_a.new_name == fr_a.original_name {
			continue
		}

		append(&fr.aliases, fr_a)
	}

	return fr
}

parse_type :: proc(type: clang.Type) -> string {
	// For getting function parameter names: https://stackoverflow.com/questions/79356416/how-can-i-get-the-argument-names-of-a-function-types-argument-list

	ws :: strings.write_string

	parse_type_build :: proc(t: clang.Type, b: ^strings.Builder) {
		#partial switch t.kind {
		case .Bool:
			ws(b, "bool")
		case .Char_U, .UChar:
			ws(b, "u8")
		case .UShort:
			ws(b, "u16")
		case .UInt:
			ws(b, "u32")
		case .ULongLong:
			ws(b, "u64")
		case .UInt128:
			ws(b, "u128")
		case .Char_S, .SChar:
			ws(b, "i8")
		case .Short:
			ws(b, "i16")
		case .Int:
			ws(b, "i32")
		case .LongLong:
			ws(b, "i64")
		case .Int128:
			ws(b, "i128")
		case .Float:
			ws(b, "f32")
		case .Double, .LongDouble:
			ws(b, "f64")
		case .NullPtr:
			ws(b, "rawptr")
		case .Pointer:
			pointee_type := clang.getPointeeType(t)

			if pointee_type.kind == .Void {
				ws(b, "rawptr")
			} else {
				ws(b, "^")
				parse_type_build(pointee_type, b)
			}
		case .Record:
			ws(b, get_cursor_name(clang.getTypeDeclaration(t)))
		case .Elaborated:
			// Means stuff like `struct S` instead of just `S`
			parse_type_build(clang.Type_getNamedType(t), b)
		case .Typedef:
			parse_type_build(clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(t)), b)
		case .ConstantArray:
			ws(b, "[")
			strings.write_int(b, int(clang.getArraySize(t)))
			ws(b, "]")

			parse_type_build(clang.getArrayElementType(t), b)
		}
	}

	b := strings.builder_make()
	parse_type_build(type, &b)
	return strings.to_string(b)
}