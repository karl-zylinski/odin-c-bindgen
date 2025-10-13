#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "core:log"
import "core:slice"
import "core:strings"

// Parses the C headers and "collects" the things we need from them. This will create a bunch types
// and declarations in the `Translate_State` struct. This file avoids doing any furher processing,
// that is deferred to `translate_process`.
@(private="package", require_results)
translate_collect :: proc(filename: string) -> (Translate_Collect_Result, bool) {
	clang_args := []cstring {
		"-fparse-all-comments",
	}

	// Clang uses 1 and 0 instead of true and false. The index is a set of translation units.
	//
	// TODO: Should all bindings created into a single directory use the same index, so they can
	// see things between them?
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

	if err != .Success {
		log.errorf("Failed to parse translation unit for %s. Error code: %v", filename, err)
		return {}, false
	}

	file := clang.getFile(unit, filename_cstr)
	root_cursor := clang.getTranslationUnitCursor(unit)
	tcs: Translate_Collect_State

	// I dislike visitors. They make the code hard to read. So I build a map of all parents and
	// children. That way we can use this lookup to find arrays of children and iterate them normally.
	build_cursor_children_lookup(root_cursor, &tcs.children_lookup)

	root_children := tcs.children_lookup[root_cursor]

	append(&tcs.types, Type_Unknown {})

	for c in root_children {
		loc := get_cursor_location(c)

		if clang.File_isEqual(file, loc.file) == 0 {
			continue
		}

		create_declaration(&tcs, c)
	}

	source_size: uint
	source := clang.getFileContents(unit, file, &source_size)

	return {
		declarations = tcs.declarations[:],
		types = tcs.types[:],
		source = strings.string_from_ptr((^u8)(source), int(source_size)),
		import_core_c = import_core_c,
	}, true
}

@(private="package")
Translate_Collect_Result :: struct {
	declarations: []Declaration,
	types: []Type,
	source: string,
	import_core_c: bool,
}

Translate_Collect_State :: struct {
	declarations: [dynamic]Declaration,
	type_lookup: map[clang.Type]Type_Index,
	types: [dynamic]Type,
	children_lookup: Cursor_Children_Map,
	import_core_c: bool,
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

create_declaration :: proc(tcs: ^Translate_Collect_State, c: clang.Cursor) {
	if clang.Cursor_isAnonymous(c) == 1 {
		return
	}

	ct := clang.getCursorType(c)

	#partial switch c.kind {

	// Struct and union is the same, only difference is that the `Type_Struct` will get `raw_union`
	// set to true.
	case .StructDecl, .UnionDecl:
		ti := create_type_recursive(ct, tcs.children_lookup, &tcs.type_lookup, &tcs.types)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		append(&tcs.declarations, Declaration {
			comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			type = ti,
			name = get_cursor_name(c),
		})

		children := tcs.children_lookup[c]

		for cc in children {
			create_declaration(tcs, cc)
		}

	case .TypedefDecl:
		ti := create_type_recursive(ct, tcs.children_lookup, &tcs.type_lookup, &tcs.types)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		append(&tcs.declarations, Declaration {
			comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			type = ti,
			name = get_cursor_name(c),
		})
		
	case .EnumDecl:
		ti := create_type_recursive(ct, tcs.children_lookup, &tcs.type_lookup, &tcs.types)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		append(&tcs.declarations, Declaration {
			comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			type = ti,
			name = get_cursor_name(c),
		})
		
	case .FunctionDecl:
		ti := create_proc_type(tcs.children_lookup[c], ct, tcs.children_lookup, &tcs.type_lookup, &tcs.types)

		if ti == TYPE_INDEX_NONE {
			log.errorf("Unknown type: %v", ct)
			return
		}

		append(&tcs.declarations, Declaration {
			comment_before = string_from_clang_string(clang.Cursor_getRawCommentText(c)),
			type = ti,
			name = get_cursor_name(c),
		})
	}
}

type_probably_is_cstring :: proc(ct: clang.Type) -> bool {
	return clang.isConstQualifiedType(ct) == 1 && (ct.kind == .Char_S || ct.kind == .SChar)
}

// TODO: Remove by passing in non-global state to get_type_reference_name
import_core_c := false

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

	case .Record, .Enum:
		ctc := clang.getTypeDeclaration(ct)
		if clang.Cursor_isAnonymous(ctc) == 0 {
			return get_cursor_name(ctc)
		}

	case .Typedef:
		ctc := clang.getTypeDeclaration(ct)
		if clang.Cursor_isAnonymous(ctc) == 0 {
			name := get_cursor_name(ctc)

			if name == "va_list" {
				import_core_c = true
				return "core_c.va_list"
			}

			return name
		}

	case .Elaborated:
		return get_type_reference_name(clang.Type_getNamedType(ct))
	}

	return ""
}

// This is a separate proc because we call it both from create_type_recursive and from
// create_declaration. It's used in create_declaration so we get a unique proc type per proc.
// Otherweise the FunctionProto stuff may make it so that ther are shared proc types, which will
// break stuff.
create_proc_type :: proc(param_childs: []clang.Cursor, ct: clang.Type, children_lookup: Cursor_Children_Map, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type, caller_loc := #caller_location) -> Type_Index {
	proc_type := reserve_type(ct, type_lookup, types)
	params: [dynamic]Type_Procedure_Parameter

	if len(param_childs) > 0 {
		for child in param_childs {
			if child.kind != .ParmDecl {
				continue
			}

			param_type := clang.getCursorType(child)

			name := get_cursor_name(child)

			ref: Type_Reference
			type_ref_name := get_type_reference_name(param_type)

			if type_ref_name == "" {
				ref = create_type_recursive(param_type, children_lookup, type_lookup, types)
			} else {
				ref = type_ref_name
			}

			append(&params, Type_Procedure_Parameter {
				name = name,
				type = ref,
			})
		}
	} else {
		num_args := clang.getNumArgTypes(ct)
		for i in 0..<num_args {
			param_type := clang.getArgType(ct, u32(i))

			ref: Type_Reference
			type_ref_name := get_type_reference_name(param_type)

			if type_ref_name == "" {
				ref = create_type_recursive(param_type, children_lookup, type_lookup, types)
			} else {
				ref = type_ref_name
			}

			append(&params, Type_Procedure_Parameter {
				type = ref,
			})
		}
	}

	result_type := clang.getResultType(ct)
	result_ref_name := get_type_reference_name(result_type)

	return_type: Type_Reference

	if result_type.kind != .Void {
		if result_ref_name == "" {
			return_type = create_type_recursive(result_type, children_lookup, type_lookup, types)
		} else {
			return_type = result_ref_name
		}
	}

	type_definition := Type_Procedure {
		parameters = params[:],
		return_type = return_type,
	}

	types[proc_type] = type_definition
	return proc_type
}

reserve_type :: proc(ct: clang.Type, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type) -> Type_Index {
	idx := Type_Index(len(types))
	append_nothing(types)
	type_lookup[ct] = idx
	return idx
}

create_type_recursive :: proc(ct: clang.Type, children_lookup: Cursor_Children_Map, type_lookup: ^map[clang.Type]Type_Index, types: ^[dynamic]Type) -> Type_Index {
	if t_idx, has_t_idx := type_lookup[ct]; has_t_idx {
		return t_idx
	}

	add_anonymous_type :: proc(t: Type, types: ^[dynamic]Type) -> Type_Index {
		idx := Type_Index(len(types))
		append(types, t)
		return idx
	}

	to_add: Maybe(Type)

	#partial switch ct.kind {
	case .Pointer:
		clang_pointee_type := clang.getPointeeType(ct)

		if clang_pointee_type.kind == .Void {
			to_add = Type_Raw_Pointer{}
		} else if clang_pointee_type.kind == .FunctionProto {
			// In Odin, a proc is a always a pointer. You can think all procs as being pointers to
			// a proc defined somewhere else. So `^proc` should be just `proc`.
			return create_type_recursive(clang_pointee_type, children_lookup, type_lookup, types)
		} else if type_probably_is_cstring(clang_pointee_type) {
			to_add = Type_CString{}
		} else {
			ptr_type_idx := reserve_type(ct, type_lookup, types)
			type_ref_name := get_type_reference_name(clang_pointee_type)
			ref: Type_Reference

			if type_ref_name == "" {
				ref = create_type_recursive(clang_pointee_type, children_lookup, type_lookup, types)
			} else {
				ref = type_ref_name
			}

			types[ptr_type_idx] = Type_Pointer { pointed_to_type = ref }
			return ptr_type_idx
		}
	case .Record:
		c := clang.getTypeDeclaration(ct)
		struct_type_idx := reserve_type(ct, type_lookup, types)
		struct_children := children_lookup[c]
		fields: [dynamic]Type_Struct_Field

		for sc in struct_children {
			sc_kind := clang.getCursorKind(sc)

			if sc_kind == .FieldDecl {
				ref: Type_Reference
				sct := clang.getCursorType(sc)
				
				is_func_ptr := false

				if sct.kind == .Pointer {
					pointee := clang.getPointeeType(sct)

					if pointee.kind == .FunctionProto {
						ref = create_proc_type(children_lookup[sc], pointee, children_lookup, type_lookup, types)
						is_func_ptr = true
					}
				}

				if !is_func_ptr  {
					type_ref_name := get_type_reference_name(sct)

					if type_ref_name == "" {
						ref = create_type_recursive(sct, children_lookup, type_lookup, types)
					} else {
						ref = type_ref_name
					}
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
			raw_union = c.kind == .UnionDecl,
		}

		types[struct_type_idx] = type_definition

		return struct_type_idx
	case .Enum:
		enum_type_idx := reserve_type(ct, type_lookup, types)
		c := clang.getTypeDeclaration(ct)
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
		elaborated_type_idx := create_type_recursive(named_type, children_lookup, type_lookup, types)
		type_lookup[ct] = elaborated_type_idx
		return elaborated_type_idx
	case .Typedef:
		alias_type_idx := reserve_type(ct, type_lookup, types)
		c := clang.getTypeDeclaration(ct)
		underlying := clang.getTypedefDeclUnderlyingType(c)

		is_func_ptr := false

		ref: Type_Reference
		if underlying.kind == .Pointer {
			pointee := clang.getPointeeType(underlying)

			if pointee.kind == .FunctionProto {
				ref = create_proc_type(children_lookup[c], pointee, children_lookup, type_lookup, types)
				is_func_ptr = true
			}
		}

		if !is_func_ptr {
			type_ref_name := get_type_reference_name(underlying)

			if type_ref_name == "" {
				ref = create_type_recursive(underlying, children_lookup, type_lookup, types)
			} else {
				ref = type_ref_name
			}
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
			ref = create_type_recursive(clang_element_type, children_lookup, type_lookup, types)
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
		return create_proc_type({}, ct, children_lookup, type_lookup, types)
	}

	if t, t_ok := to_add.?; t_ok {
		idx := reserve_type(ct, type_lookup, types)
		types[idx] = t
		return idx
	}

	//log.error("Unknown type")
	return TYPE_INDEX_NONE
}
