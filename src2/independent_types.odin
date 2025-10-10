// In here we put types that can be used within any file. They are said to be independent, because
// they do not depend on libclang.
//
// It is FORBIDDEN to import libclang or use anything from libclang in here, as the outputter
// will use these types. The outputter does not, and should not, have any knowledge of clang.
package bindgen2

import "core:slice"

Type_Index :: distinct int

TYPE_INDEX_NONE :: Type_Index(0)

Type_Pointer :: struct {
	pointed_to_type: Type_Reference,
}

Type_Multipointer :: struct {
	pointed_to_type: Type_Reference,
}

Type_Alias :: struct {
	aliased_type: Type_Reference,
}

Type_Struct_Field :: struct {
	name: string,
	type: Type_Reference,
	type_overrride: string,
	comment_before: string,
	comment_on_right: string,
}

Type_Struct :: struct {
	fields: []Type_Struct_Field,
}

Type_Enum_Member :: struct {
	name: string,
	value: int,
}

Type_Enum :: struct {
	storage_type: typeid,
	members: []Type_Enum_Member,
}

Type_Unknown :: struct {}

Type_Raw_Pointer :: struct {}

Type_Bit_Set :: struct {
	enum_type: Type_Reference,
}

Type_Fixed_Array :: struct {
	element_type: Type_Reference,
	size: int,
}

Type_Procedure_Parameter :: struct {
	name: string,
	type: Type_Reference,
}

Type_Procedure :: struct {
	parameters: []Type_Procedure_Parameter,
	return_type: Type_Reference,
}

Type_CString :: struct {}

// Hard-coded override containing Odin type text
Type_Override :: struct {
	definition_text: string,
}

Type_Reference :: union  {
	string,
	Type_Index,
}

Type :: union #no_nil {
	Type_Unknown,
	Type_Pointer,
	Type_Multipointer,
	Type_Raw_Pointer,
	Type_CString,
	Type_Struct,
	Type_Enum,
	Type_Bit_Set,
	Type_Alias,
	Type_Fixed_Array,
	Type_Procedure,
	Type_Override,
}

Declaration :: struct {
	name: string,
	type: Type_Index,
	comment_before: string,
}

get_type_reference :: proc(types: []Type, ref: Type_Reference, $T: typeid) -> (T, bool) {
	if idx, is_idx := ref.(Type_Index); is_idx {
		return types[idx].(T)
	}

	return {}, false
}

add_type :: proc(array: ^[dynamic]Type, t: Type) -> Type_Index {
	idx := len(array)
	append(array, t)
	return Type_Index(idx)
}
