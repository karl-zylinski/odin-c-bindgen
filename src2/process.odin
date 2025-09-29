#+private file
package bindgen2

import clang "../libclang"
import "core:strings"
import "core:slice"
import "core:log"

@(private="package")
process :: proc(ir: ^Intermediate_Representation) -> Final_Representation {
	decls: [dynamic]FR_Declaration

	for &gsd in ir.global_scope_declarations {
		c := gsd.cursor

		switch &t in ir.types[gsd.type] {
		case Type_Unknown:
		case Type_Name:
			log.error("Can't have plain name at root level")

		case Type_Pointer:
			log.error("Can't have plain pointer at root level")

		case Type_Struct:
			name := get_cursor_name(c)
			loc := get_cursor_location(c)

			append(&decls, FR_Declaration {
				name = name,
				variant = FR_Struct {
					type = gsd.type,
				},
				comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			})

		case Type_Typedef:
			append(&decls, FR_Declaration {
				name = get_cursor_name(c),
				variant = FR_Typedef {
					typedeffed_type = t.typedeffed_to_type,
				},
				comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			})

		case Type_Raw_Pointer:

		case Type_Enum:
			append(&decls, FR_Declaration {
				name = get_cursor_name(c),
				variant = FR_Enum {
					type = gsd.type,
				},
				comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			})
		}

	}

	return {
		decls = decls[:],
		types = ir.types,
	}
}

/*
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
}*/