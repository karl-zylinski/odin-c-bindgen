#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "core:log"

@(private="package")
translate_collect :: proc(ts: ^Translate_State, filename: string) {
	clang_args := []cstring {
		"-fparse-all-comments",
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

	build_cursor_children_lookup(root_cursor, &ts.children_lookup)

	root_children := ts.children_lookup[root_cursor]

	type_lookup: map[clang.Type]Type_Index
	append(&ts.types, Type_Unknown {})

	// Create all types.
	/*for c in root_children {
		loc := get_cursor_location(c)
		
		if clang.File_isEqual(file, loc.file) == 0 {
			continue
		}

		create_type_recursive(c, clang.getCursorType(c), children_lookup, &type_lookup, &ts.types)
	}*/

	// Create all declarations, i.e. types and such to put into the bindings.

	for c in root_children {
		loc := get_cursor_location(c)

		if clang.File_isEqual(file, loc.file) == 0 {
			continue
		}

		decl, decl_ok := create_declaration(c, ts)

		if decl_ok {
			append(&ts.declarations, decl)
		}
	}
}

build_cursor_children_lookup :: proc(c: clang.Cursor, res: ^Cursor_Children_Map) {
	Build_Children_State :: struct {
		res: ^Cursor_Children_Map,
		children: [dynamic]clang.Cursor,
	}

	bcs := Build_Children_State {
		res = res,
	}

	clang.visitChildren(c, curstor_iterator_iterate, &bcs)

	curstor_iterator_iterate: clang.Cursor_Visitor : proc "c" (
		cursor, parent: clang.Cursor,
		state: clang.Client_Data,
	) -> clang.Child_Visit_Result {
		context = gen_ctx
		bcs := (^Build_Children_State)(state)
		append(&bcs.children, cursor)
		build_cursor_children_lookup(cursor, bcs.res)
		return .Continue
	}

	res[c] = bcs.children[:]
}

translate_cursor_type_name :: proc(c: clang.Cursor) -> string {
	ct := clang.getCursorType(c)

	#partial switch ct.kind {
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

	case .Record:
		return get_cursor_name(c)
	
	case .Elaborated:
		named_type := clang.Type_getNamedType(ct)
		return get_type_name(named_type)
	}

	return ""
}

create_declaration_type :: proc(c: clang.Cursor, ts: ^Translate_State) -> (Declaration_Type, bool) {
	kind := clang.getCursorKind(c)

	#partial switch kind {
	case .FunctionDecl:
		return Declaration_Procedure {}, true
	case .StructDecl:
		struct_children := ts.children_lookup[c]
		fields: [dynamic]Declaration_Struct_Field

		for sc in struct_children {
			sc_kind := clang.getCursorKind(sc)

			if sc_kind == .FieldDecl {
				field_type: Declaration_Type

				if clang.Cursor_isAnonymous(sc) == 1 {
					anon_field_type, anon_field_type_ok := create_declaration_type(sc, ts)

					if anon_field_type_ok {
						field_type = field_type
					}
				} else {
					type_name := translate_cursor_type_name(sc)

					if type_name != "" {
						field_type = Declaration_Name(type_name)
					}
				}

				if _, field_type_is_unknown := field_type.(Declaration_Unknown); field_type_is_unknown {
					log.errorf("Unknown struct field type: %v", sc)
				}

				field_name := get_cursor_name(sc)

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

				append(&fields, Declaration_Struct_Field {
					name = field_name,
					type = field_type,
					comment_before = comment_before,
					comment_on_right = comment_on_right,
				})
			}
		}

		return Declaration_Struct {
			fields = fields[:],
		}, true
	}

	return {}, false
}

create_declaration :: proc(c: clang.Cursor, ts: ^Translate_State) -> (Declaration, bool) {
	name := get_cursor_name(c)

	if name == "" {
		return {}, false
	}

	kind := clang.getCursorKind(c)

	type, type_ok := create_declaration_type(c, ts)

	if !type_ok {
		return {}, false
	}

	return Declaration {
		comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
		type = type,
		name = name,
	}, true
}

create_type_recursive :: proc(c: clang.Cursor, ct: clang.Type, children_lookup: Cursor_Children_Map, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type) -> Type_Index {
	if t_idx, has_t_idx := type_lookup[ct]; has_t_idx {
		return t_idx
	}

	add_anonymous_type :: proc(t: Type, types: ^[dynamic]Type) -> Type_Index {
		idx := Type_Index(len(types))
		append(types, t)
		return idx
	}

	reserve_type :: proc(ct: clang.Type, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type) -> Type_Index {
		idx := Type_Index(len(types))
		append_nothing(types)
		type_lookup[ct] = idx
		return idx
	}

	to_add: Maybe(Type)

	#partial switch ct.kind {
	case .Bool:
		to_add = Type_Named { name = "bool" }
	case .Char_U, .UChar:
		to_add = Type_Named { name = "u8" }
	case .UShort:
		to_add = Type_Named { name = "u16" }
	case .UInt:
		to_add = Type_Named { name = "u32" }
	case .ULongLong:
		to_add = Type_Named { name = "u64" }
	case .UInt128:
		to_add = Type_Named { name = "u128" }
	case .Char_S, .SChar:
		to_add = Type_Named { name = "i8" }
	case .Short:
		to_add = Type_Named { name = "i16" }
	case .Int:
		to_add = Type_Named { name = "i32" }
	case .LongLong:
		to_add = Type_Named { name = "i64" }
	case .Int128:
		to_add = Type_Named { name = "i128" }
	case .Float:
		to_add = Type_Named { name = "f32" }
	case .Double, .LongDouble:
		to_add = Type_Named { name = "f64" }
	case .NullPtr:
		to_add = Type_Named { name = "rawptr" }
	case .Pointer:
		clang_pointee_type := clang.getPointeeType(ct)

		if clang_pointee_type.kind == .Void {
			to_add = Type_Raw_Pointer{}
		} else {
			ptr_type_idx := reserve_type(ct, type_lookup, types)
			pointee_type := create_type_recursive(clang.getTypeDeclaration(clang_pointee_type), clang_pointee_type, children_lookup, type_lookup, types)
			types[ptr_type_idx] = Type_Pointer { pointed_to_type = pointee_type }
			return ptr_type_idx
		}
	case .Record:
		struct_type_idx := reserve_type(ct, type_lookup, types)
		struct_children := children_lookup[c]
		fields: [dynamic]Type_Struct_Field

		for sc in struct_children {
			sc_kind := clang.getCursorKind(sc)

			if sc_kind == .FieldDecl {
				field_type := create_type_recursive(sc, clang.getCursorType(sc), children_lookup, type_lookup, types)
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

		type_definition := Type_Struct {
			fields = fields[:],
		}

		name := get_cursor_name(c)

		if clang.Cursor_isAnonymous(c) == 1 || name == "" {
			types[struct_type_idx] = type_definition
		} else {
			named_type := Type_Named {
				name = name,
				definition = add_anonymous_type(type_definition, types),
			}
			types[struct_type_idx] = named_type
		}

		return struct_type_idx
	case .Enum:
		enum_type_idx := reserve_type(ct, type_lookup, types)
		enum_children := children_lookup[c]
		members: [dynamic]Type_Enum_Member
		backing_type := clang.getEnumDeclIntegerType(c)
		is_unsigned_type := backing_type.kind >= .Char_U && backing_type.kind <= .UInt128

		for ec in enum_children {
			member_name := get_cursor_name(ec)
			value := is_unsigned_type ? int(clang.getEnumConstantDeclUnsignedValue(ec)) : int(clang.getEnumConstantDeclValue(ec))

			append(&members, Type_Enum_Member {
				name = member_name,
				value = value,
			})
		}

		storage_type: typeid = i32

		#partial switch backing_type.kind {
			case .Char_U:
				storage_type = u8
			case .UChar:
				storage_type = u8
			case .Char16:
				storage_type = i16
			case .Char32:
				storage_type = i32
			case .UShort:
				storage_type = u16
			case .UInt:
				storage_type = u32
			case .ULong:
				storage_type = u32
			case .ULongLong:
				storage_type = u64
			case .UInt128:
				storage_type = u128
			case .Char_S:
				storage_type = i8
			case .SChar:
				storage_type = i8
			case .Short:
				storage_type = i16
			case .Int:
				storage_type = i32
			case .Long:
				storage_type = i32
			case .LongLong:
				storage_type = i64
			case .Int128:
				storage_type = i128
		}	

		type_definition := Type_Enum {
			storage_type = storage_type,
			members = members[:],
		}

		name := get_cursor_name(c)

		if clang.Cursor_isAnonymous(c) == 1 || name == "" {
			types[enum_type_idx] = type_definition
		} else {
			named_type := Type_Named {
				name = name,
				definition = add_anonymous_type(type_definition, types),
			}
			types[enum_type_idx] = named_type 
		}

		return enum_type_idx

	case .Elaborated:
		// Just return the type index here so we "short circuit" past `struct S` etc
		named_type := clang.Type_getNamedType(ct)
		elaborated_type_idx := create_type_recursive(clang.getTypeDeclaration(named_type), named_type, children_lookup, type_lookup, types)
		type_lookup[ct] = elaborated_type_idx
		return elaborated_type_idx
	case .Typedef:
		alias_type_idx := reserve_type(ct, type_lookup, types)
		underlying := clang.getTypedefDeclUnderlyingType(clang.getTypeDeclaration(ct))
		
		type_definition := Type_Alias {
			aliased_type = create_type_recursive(clang.getTypeDeclaration(underlying), underlying, children_lookup, type_lookup, types),
		}

		name := get_cursor_name(c)

		if clang.Cursor_isAnonymous(c) == 1 || name == "" {
			types[alias_type_idx] = type_definition
		} else {
			named_type := Type_Named {
				name = name,
				definition = add_anonymous_type(type_definition, types),
			}
			types[alias_type_idx] = named_type 
		}

		return alias_type_idx
	case .ConstantArray:
		array_type_idx := reserve_type(ct, type_lookup, types)
		clang_element_type := clang.getArrayElementType(ct)
		element_type_idx := create_type_recursive(clang.getTypeDeclaration(clang_element_type), clang_element_type, children_lookup, type_lookup, types)

		type_definition := Type_Fixed_Array {
			element_type = element_type_idx,
			size = int(clang.getArraySize(ct)),
		}

		name := get_cursor_name(c)

		if clang.Cursor_isAnonymous(c) == 1 || name == "" {
			types[array_type_idx] = type_definition
		} else {
			named_type := Type_Named {
				name = name,
				definition = add_anonymous_type(type_definition, types),
			}
			types[array_type_idx] = named_type 
		}

		return array_type_idx
	}

	if t, t_ok := to_add.?; t_ok {
		idx := reserve_type(ct, type_lookup, types)
		types[idx] = t
		return idx
	}

	//log.error("Unknown type")
	return TYPE_INDEX_NONE
}
