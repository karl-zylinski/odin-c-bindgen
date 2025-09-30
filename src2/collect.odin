#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "base:runtime"
import "core:strings"
import "core:log"
import "core:math/bits"

named_types: map[string]struct{}

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

		// THIS IS SILLY. I should be looking at CursorKind and create structs from StructDecls. All this is wrong!!
		type_index := create_type_recursive(clang.getCursorType(c), &type_lookup, &types)
		log.info(kind)

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

create_type_recursive :: proc(ct: clang.Type, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type) -> Type_Index {
	if t_idx, has_t_idx := type_lookup[ct]; has_t_idx {
		return t_idx
	}

	add_type :: proc(t: Type, ct: clang.Type, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type) -> Type_Index {
		idx := Type_Index(len(types))
		append(types, t)
		type_lookup[ct] = idx
		return idx
	}

	#partial switch ct.kind {
	case .Bool:
		return add_type(Type_Name("bool"), ct, type_lookup, types)
	case .Char_U, .UChar:
		return add_type(Type_Name("u8"), ct, type_lookup, types)
	case .UShort:
		return add_type(Type_Name("u16"), ct, type_lookup, types)
	case .UInt:
		return add_type(Type_Name("u32"), ct, type_lookup, types)
	case .ULongLong:
		return add_type(Type_Name("u64"), ct, type_lookup, types)
	case .UInt128:
		return add_type(Type_Name("u128"), ct, type_lookup, types)
	case .Char_S, .SChar:
		return add_type(Type_Name("i8"), ct, type_lookup, types)
	case .Short:
		return add_type(Type_Name("i16"), ct, type_lookup, types)
	case .Int:
		return add_type(Type_Name("i32"), ct, type_lookup, types)
	case .LongLong:
		return add_type(Type_Name("i64"), ct, type_lookup, types)
	case .Int128:
		return add_type(Type_Name("i128"), ct, type_lookup, types)
	case .Float:
		return add_type(Type_Name("f32"), ct, type_lookup, types)
	case .Double, .LongDouble:
		return add_type(Type_Name("f64"), ct, type_lookup, types)
	case .NullPtr:
		return add_type(Type_Name("rawptr"), ct, type_lookup, types)
	case .Pointer:
		clang_pointee_type := clang.getPointeeType(ct)

		if clang_pointee_type.kind == .Void {
			return add_type(Type_Raw_Pointer{}, ct, type_lookup, types)
		} else {
			ptr_type_idx := add_type(Type_Pointer{}, ct, type_lookup, types)
			pointee_type := create_type_recursive(clang_pointee_type, type_lookup, types)
			(&types[ptr_type_idx].(Type_Pointer)).pointed_to_type = pointee_type
			return ptr_type_idx
		}
	case .Record:
		struct_type_idx := add_type(Type_Struct{}, ct, type_lookup, types)

		cursor := clang.getTypeDeclaration(ct)
		struct_children := get_cursor_children(cursor)
		fields: [dynamic]Type_Struct_Field

		for sc, sc_i in struct_children {
			sc_kind := clang.getCursorKind(sc)

			if sc_kind == .FieldDecl {
				field_type := create_type_recursive(clang.getCursorType(sc), type_lookup, types)
				name := get_cursor_name(sc)

				if field_type == TYPE_INDEX_NONE {
					log.errorf("Unresolved struct field type: %v", sc)
				}

				field_loc := get_cursor_location(sc)
				comment_loc := get_comment_location(sc)

				comment := string_from_clang_string(clang.Cursor_getRawCommentText(sc))
				comment_before: string
				comment_on_right: string

				if field_loc.line == comment_loc.line {
					comment_on_right = comment
				} else {
					comment_before = comment
				}

				append(&fields, Type_Struct_Field {
					name = name,
					type = field_type,
					comment_before = comment_before,
					comment_on_right = comment_on_right,
				})
			}
		}

		(&types[struct_type_idx].(Type_Struct))^ = {
			name = get_cursor_name(cursor),
			defined_inline = clang.Cursor_isAnonymous(cursor) == 1,
			fields = fields[:],
		}

		return struct_type_idx

	case .Enum:
		enum_type_idx := add_type(Type_Enum{}, ct, type_lookup, types)

		cursor := clang.getTypeDeclaration(ct)
		name := get_cursor_name(cursor)

		bit_set_name, bit_setify := bit_setify_lookup[name]

		enum_children := get_cursor_children(cursor)
		members: [dynamic]Type_Enum_Member
		backing_type := clang.getEnumDeclIntegerType(cursor)
		is_unsigned_type := backing_type.kind >= .Char_U && backing_type.kind <= .UInt128

		for ec, ec_i in enum_children {
			member_name := get_cursor_name(ec)
			value := is_unsigned_type ? int(clang.getEnumConstantDeclUnsignedValue(ec)) : int(clang.getEnumConstantDeclValue(ec))
			
			if bit_setify {
				if value == 0 {
					continue
				}

				value = int(bits.log2(uint(value)))
			}

			append(&members, Type_Enum_Member {
				name = member_name,
				value = value,
			})
		}

		if bit_setify {
			append(types, Type_Bit_Set {
				name = bit_set_name,
				enum_type = Type_Index(len(types) + 1),
			})
		}

		(&types[enum_type_idx].(Type_Enum))^ = {
			name = name,
			members = members[:],
			defined_inline = clang.Cursor_isAnonymous(cursor) == 1,
		}

		return enum_type_idx

	case .Elaborated:
		// Just return the type index here so we "short circuit" past `struct S` etc
		return create_type_recursive(clang.Type_getNamedType(ct), type_lookup, types)
	case .Typedef:
		alias_type_idx := add_type(Type_Alias{}, ct, type_lookup, types)
		underlying := clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(ct))
		(&types[alias_type_idx].(Type_Alias))^ = {
			aliased_type = create_type_recursive(underlying, type_lookup, types)
		}
		return alias_type_idx
	/*case .ConstantArray:
		ws(b, "[")
		strings.write_int(b, int(clang.getArraySize(t)))
		ws(b, "]")

		parse_type_build(clang.getArrayElementType(t), b)*/
	}

	//log.error("Unknown type")
	return TYPE_INDEX_NONE
}

/*build_cursor_type :: proc(type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type, ct: clang.Type) -> Type_Index {
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

		if clang.getCanonicalCursor(cursor) == cursor {
			break
		}

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

				field_loc := get_cursor_location(sc)
				comment_loc := get_comment_location(sc)

				comment := string_from_clang_string(clang.Cursor_getRawCommentText(sc))
				comment_before: string
				comment_on_right: string

				if field_loc.line == comment_loc.line {
					comment_on_right = comment
				} else {
					comment_before = comment
				}

				append(&fields, Type_Struct_Field {
					name = name,
					type = field_type,
					comment_before = comment_before,
					comment_on_right = comment_on_right,
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
		name := get_cursor_name(cursor)

		bit_set_name, bit_setify := bit_setify_lookup[name]

		enum_children := get_cursor_children(cursor)
		members: [dynamic]Type_Enum_Member
		backing_type := clang.getEnumDeclIntegerType(cursor)
		is_unsigned_type := backing_type.kind >= .Char_U && backing_type.kind <= .UInt128

		for ec, ec_i in enum_children {
			member_name := get_cursor_name(ec)
			value := is_unsigned_type ? int(clang.getEnumConstantDeclUnsignedValue(ec)) : int(clang.getEnumConstantDeclValue(ec))
			
			if bit_setify {
				if value == 0 {
					continue
				}

				value = int(bits.log2(uint(value)))
			}

			append(&members, Type_Enum_Member {
				name = member_name,
				value = value,
			})
		}

		if bit_setify {
			append(types, Type_Bit_Set {
				name = bit_set_name,
				enum_type = Type_Index(len(types) + 1),
			})
		}

		t = Type_Enum {
			name = name,
			members = members[:],
			defined_inline = clang.Cursor_isAnonymous(cursor) == 1,
		}

	case .Elaborated:
		// Just return the type index here so we "short circuit" past `struct S` etc
		return build_cursor_type(type_lookup, types, clang.Type_getNamedType(ct))
	case .Typedef:
		underlying := clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(ct))
		t = Type_Alias { build_cursor_type(type_lookup, types, underlying) }
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
}*/