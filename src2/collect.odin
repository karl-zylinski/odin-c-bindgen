#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "base:runtime"
import "core:strings"
import "core:log"

@(private="package")
collect :: proc(filename: string) -> Intermediate_Representation {
	clang_args := []cstring {
		"-fparse-all-comments"
	}

	index := clang.createIndex(1, 0)
	unit: clang.Translation_Unit

	options: clang.Translation_Unit_Flags = {
		.DetailedPreprocessingRecord, // Keep macros.
		.SkipFunctionBodies,
		.KeepGoing, // Keep going on errors.
	}

	filename_cstr := to_cstring(filename)

	err := clang.parseTranslationUnit2(
		index,
		filename_cstr,
		raw_data(clang_args),
		i32(len(clang_args)),
		nil,
		0,
		options,
		&unit,
	)

	fmt.ensuref(err == .Success, "Failed to parse translation unit for %s. Error code: %v", filename, err)

	file := clang.getFile(unit, filename_cstr)
	root_cursor := clang.getTranslationUnitCursor(unit)

	root_children := get_cursor_children(root_cursor)

	type_lookup: map[clang.Type]Type_Index
	types: [dynamic]Type
	global_scope_decls: [dynamic]Typed_Cursor
	append(&types, Type_Unknown {})

	for c in root_children {
		kind := clang.getCursorKind(c)
		loc := get_cursor_location(c)

		if clang.File_isEqual(file, loc.file) == 0 {
			continue
		}

		type_index := build_cursor_type(&type_lookup, &types, clang.getCursorType(c))

		if type_index == 0 {
			log.errorf("Unknown type: %v", loc)
			continue
		}

		append(&global_scope_decls, Typed_Cursor {
			cursor = c,
			type = type_index
		})
	}

	return {
		global_scope_declarations = global_scope_decls[:],
		types = types[:],
	}
}

build_cursor_type :: proc(type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type, ct: clang.Type) -> Type_Index {
	if t_idx, has_t_idx := type_lookup[ct]; has_t_idx {
		return t_idx
	}

	t: Type

	#partial switch ct.kind {
	case .Bool:
		t = Type_Name("bool")
	case .Char_U, .UChar:
		t = Type_Name("u8")
	case .UShort:
		t = Type_Name("u16")
	case .UInt:
		t = Type_Name("u32")
	case .ULongLong:
		t = Type_Name("u64")
	case .UInt128:
		t = Type_Name("u128")
	case .Char_S, .SChar:
		t = Type_Name("i8")
	case .Short:
		t = Type_Name("i16")
	case .Int:
		t = Type_Name("i32")
	case .LongLong:
		t = Type_Name("i64")
	case .Int128:
		t = Type_Name("i128")
	case .Float:
		t = Type_Name("f32")
	case .Double, .LongDouble:
		t = Type_Name("f64")
	case .NullPtr:
		t = Type_Name("rawptr")
	case .Pointer:
		clang_pointee_type := clang.getPointeeType(ct)

		if clang_pointee_type.kind == .Void {
			t = Type_Raw_Pointer {}
		} else {
			pointee_type := build_cursor_type(type_lookup, types, clang_pointee_type)

			if pointee_type != TYPE_INDEX_NONE {
				t = Type_Pointer { pointee_type }
			}
		}
	case .Record:
		cursor := clang.getTypeDeclaration(ct)
		struct_children := get_cursor_children(cursor)
		fields: [dynamic]Type_Struct_Field

		for sc, sc_i in struct_children {
			sc_kind := clang.getCursorKind(sc)

			if sc_kind == .FieldDecl {
				field_type := build_cursor_type(type_lookup, types, clang.getCursorType(sc))
				name := get_cursor_name(sc)

				if field_type == TYPE_INDEX_NONE {
					log.errorf("Unresolved struct field type: %v", sc)
				}

				append(&fields, Type_Struct_Field {
					cursor = sc,
					name = name,
					type = field_type,
				})
			}
		}

		t = Type_Struct {
			name = get_cursor_name(cursor),
			defined_inline = clang.Cursor_isAnonymous(cursor) == 1,
			fields = fields[:],
		}
	case .Enum:
		cursor := clang.getTypeDeclaration(ct)
		enum_children := get_cursor_children(cursor)
		members: [dynamic]Type_Enum_Member
		backing_type := clang.getEnumDeclIntegerType(cursor)
		is_unsigned_type := backing_type.kind >= .Char_U && backing_type.kind <= .UInt128

		for ec, ec_i in enum_children {
			name := get_cursor_name(ec)
			value := is_unsigned_type ? int(clang.getEnumConstantDeclUnsignedValue(ec)) : int(clang.getEnumConstantDeclValue(ec))
			
			append(&members, Type_Enum_Member {
				name = name,
				value = value,
			})
		}

		t = Type_Enum {
			name = get_cursor_name(cursor),
			members = members[:],
			defined_inline = clang.Cursor_isAnonymous(cursor) == 1,
		}

	case .Elaborated:
		// Just return the type index here so we "short circuit" past `struct S` etc
		return build_cursor_type(type_lookup, types, clang.Type_getNamedType(ct))
	case .Typedef:
		underlying := clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(ct))
		t = Type_Typedef { build_cursor_type(type_lookup, types, underlying) }
	/*case .ConstantArray:
		ws(b, "[")
		strings.write_int(b, int(clang.getArraySize(t)))
		ws(b, "]")

		parse_type_build(clang.getArrayElementType(t), b)*/
	}

	if _, is_unknown := t.(Type_Unknown); is_unknown {
		return 0
	}

	idx := Type_Index(len(types))
	type_lookup[ct] = idx
	append(types, t)
	return idx
}