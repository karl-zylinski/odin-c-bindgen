#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "core:log"
import "core:slice"

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

	children_lookup: Cursor_Children_Map

	build_cursor_children_lookup(root_cursor, &children_lookup)

	root_children := children_lookup[root_cursor]

	type_lookup: map[clang.Type]Type_Index
	declarations: [dynamic]Declaration
	append(&ts.types, Type_Unknown {})

	// Create all declarations, i.e. types and such to put into the bindings.

	for c in root_children {
		loc := get_cursor_location(c)

		if clang.File_isEqual(file, loc.file) == 0 {
			continue
		}

		add_declarations(&declarations, &type_lookup, &ts.types, c, children_lookup)
	}

	ts.declarations = declarations[:]
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

add_declarations :: proc(declarations: ^[dynamic]Declaration, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type, c: clang.Cursor, children_lookup: Cursor_Children_Map) {
	if clang.Cursor_isAnonymous(c) == 1 {
		return
	}

	ct := clang.getCursorType(c)

	ti := create_type_recursive(c, ct, children_lookup, type_lookup, types)

	if ti == TYPE_INDEX_NONE {
		//log.errorf("Unknown type: %v", ct)
		return
	}

	kind := clang.getCursorKind(c)

	if kind != .StructDecl && kind != .TypedefDecl && kind != .EnumDecl && kind != .FunctionDecl {
		return
	}

	// Procedures have a "prototype" type that is shared between multiple procedures. Clone it, so
	// each one gets one of their own. That way we can modify it later based on the bindgen config,
	// without affecting other procedures.
	if pt, pt_ok := types[ti].(Type_Procedure); pt_ok && kind == .FunctionDecl {
		type_proc := pt
		type_proc.parameters = slice.clone(pt.parameters)
		ti = add_type(types, type_proc)
	}

	append(declarations, Declaration {
		comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
		type = ti,
		name = get_cursor_name(c),
	})

	if kind == .StructDecl {
		children := children_lookup[c]

		for cc in children {
			add_declarations(declarations, type_lookup, types, cc, children_lookup)
		}
	}
}

type_is_char :: proc(ct: clang.Type) -> bool {
	return ct.kind == .Char_S ||
	       ct.kind == .SChar ||
	       ct.kind == .UChar ||
	       ct.kind == .Char_U
}

get_type_reference_name :: proc(ct: clang.Type) -> string {
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
	case .Long:
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

	case .Record, .Enum, .Typedef:
		ctc := clang.getTypeDeclaration(ct)
		if clang.Cursor_isAnonymous(ctc) == 0 {
			return get_cursor_name(ctc)
		}

	case .Elaborated:
		return get_type_reference_name(clang.Type_getNamedType(ct))
	}

	return ""
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
	case .Pointer:
		clang_pointee_type := clang.getPointeeType(ct)

		is_const := clang.isConstQualifiedType(clang_pointee_type) == 1
		is_const_string := type_is_char(clang_pointee_type) && is_const
		is_dynamic_string := type_is_char(clang_pointee_type) && !is_const

		if clang_pointee_type.kind == .Void {
			to_add = Type_Raw_Pointer{}
		} else if clang_pointee_type.kind == .FunctionProto {
			// In Odin, a proc is a always a pointer. You can think all procs as being pointers to
			// a proc defined somewhere else. So `^proc` should be just `proc`.
			return create_type_recursive(clang.getTypeDeclaration(clang_pointee_type), clang_pointee_type, children_lookup, type_lookup, types)
		} else if is_const_string {
			to_add = Type_CString{}
		} else if is_dynamic_string {
			to_add = Type_Multipointer { pointed_to_type = "u8" }
		} else {
			ptr_type_idx := reserve_type(ct, type_lookup, types)
			type_ref_name := get_type_reference_name(clang_pointee_type)
			ref: Type_Reference

			if type_ref_name == "" {
				ref = create_type_recursive(clang.getTypeDeclaration(clang_pointee_type), clang_pointee_type, children_lookup, type_lookup, types)
			} else {
				ref = type_ref_name
			}

			types[ptr_type_idx] = Type_Pointer { pointed_to_type = ref }
			return ptr_type_idx
		}
	case .Record:
		struct_type_idx := reserve_type(ct, type_lookup, types)
		struct_children := children_lookup[c]
		fields: [dynamic]Type_Struct_Field

		for sc in struct_children {
			sc_kind := clang.getCursorKind(sc)

			if sc_kind == .FieldDecl {
				ref: Type_Reference
				sct := clang.getCursorType(sc)

				type_ref_name := get_type_reference_name(sct)

				if type_ref_name == "" {
					ref = create_type_recursive(sc, sct, children_lookup, type_lookup, types)
				} else {
					ref = type_ref_name
				}

				name := get_cursor_name(sc)
				
				if ref == nil {
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
					type = ref,
					comment_before = comment_before,
					comment_on_right = comment_on_right,
				})
			}
		}

		type_definition := Type_Struct {
			fields = fields[:],
		}

		types[struct_type_idx] = type_definition
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

		types[enum_type_idx] = type_definition
		return enum_type_idx

	case .Elaborated:
		// Just return the type index here so we "short circuit" past `struct S` etc
		named_type := clang.Type_getNamedType(ct)
		elaborated_type_idx := create_type_recursive(clang.getTypeDeclaration(named_type), named_type, children_lookup, type_lookup, types)
		type_lookup[ct] = elaborated_type_idx
		return elaborated_type_idx
	case .Typedef:
		alias_type_idx := reserve_type(ct, type_lookup, types)
		underlying_type_cursor := clang.getTypeDeclaration(ct)
		underlying := clang.getTypedefDeclUnderlyingType(underlying_type_cursor)

		ref: Type_Reference
		type_ref_name := get_type_reference_name(underlying)

		if type_ref_name == "" {
			ref = create_type_recursive(clang.getTypeDeclaration(underlying), underlying, children_lookup, type_lookup, types)
		} else {
			ref = type_ref_name
		}
		
		type_definition := Type_Alias {
			aliased_type = ref
		}
		
		types[alias_type_idx] = type_definition

		return alias_type_idx
	case .ConstantArray:
		array_type_idx := reserve_type(ct, type_lookup, types)
		clang_element_type := clang.getArrayElementType(ct)

		ref: Type_Reference
		type_ref_name := get_type_reference_name(clang_element_type)

		if type_ref_name == "" {
			ref = create_type_recursive(clang.getTypeDeclaration(clang_element_type), clang_element_type, children_lookup, type_lookup, types)
		} else {
			ref = type_ref_name
		}

		type_definition := Type_Fixed_Array {
			element_type = ref,
			size = int(clang.getArraySize(ct)),
		}

		types[array_type_idx] = type_definition

		return array_type_idx

	case .FunctionProto, .FunctionNoProto:
		proc_type := reserve_type(ct, type_lookup, types)
		params: [dynamic]Type_Procedure_Parameter

		if clang.Cursor_getNumArguments(c) != -1 {
			for i in 0..<clang.Cursor_getNumArguments(c) {
				param_cursor := clang.Cursor_getArgument(c, u32(i))
				param_type := clang.getCursorType(param_cursor)
				ref: Type_Reference
				type_ref_name := get_type_reference_name(param_type)

				if type_ref_name == "" {
					ref = create_type_recursive(param_cursor, param_type, children_lookup, type_lookup, types)
				} else {
					ref = type_ref_name
				}

				append(&params, Type_Procedure_Parameter {
					name = get_cursor_name(param_cursor),
					type = ref,
				})
			}
		} else {
			for i in 0..<clang.getNumArgTypes(ct) {
				param_type := clang.getArgType(ct, u32(i))
				param_cursor := clang.getTypeDeclaration(param_type)
				ref: Type_Reference
				type_ref_name := get_type_reference_name(param_type)

				if type_ref_name == "" {
					ref = create_type_recursive(param_cursor, param_type, children_lookup, type_lookup, types)
				} else {
					ref = type_ref_name
				}

				append(&params, Type_Procedure_Parameter {
					name = get_cursor_name(param_cursor),
					type = ref,
				})
			}
		}

		result_type := clang.getResultType(ct)
		result_ref_name := get_type_reference_name(result_type)

		return_type: Type_Reference

		if result_type.kind != .Void {
			if result_ref_name == "" {
				return_type = create_type_recursive(clang.getTypeDeclaration(result_type), result_type, children_lookup, type_lookup, types)
			} else {
				return_type = result_ref_name
			}
		}

		type_definition := Type_Procedure {
			name = get_cursor_name(c),
			parameters = params[:],
			return_type = return_type,
		}

		types[proc_type] = type_definition

		return proc_type
	}

	if t, t_ok := to_add.?; t_ok {
		idx := reserve_type(ct, type_lookup, types)
		types[idx] = t
		return idx
	}

	//log.error("Unknown type")
	return TYPE_INDEX_NONE
}
