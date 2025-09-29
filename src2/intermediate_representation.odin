package bindgen2

import clang "../libclang"

Typed_Cursor :: struct {
	cursor: clang.Cursor,
	type: Type_Index,
}

Intermediate_Representation :: struct {
	global_scope_declarations: []Typed_Cursor,
	types: []Type,
}

Type_Index :: distinct int

Type_Name :: distinct string

TYPE_INDEX_NONE :: Type_Index(0)

Type_Pointer :: struct {
	pointed_to_type: Type_Index,
}

Type_Typedef :: struct {
	typedeffed_to_type: Type_Index,
}

Type_Struct_Field :: struct {
	name: string,
	cursor: clang.Cursor,
	type: Type_Index,
	comment_before: string,
	comment_on_right: string,
}

Type_Struct :: struct {
	fields: []Type_Struct_Field,
	defined_inline: bool,
	name: string,
}

Type_Enum_Member :: struct {
	name: string,
	value: int,
}

Type_Enum :: struct {
	name: string,
	members: []Type_Enum_Member,
	defined_inline: bool,
}

Type_Unknown :: struct {}

Type_Raw_Pointer :: struct {}

Type :: union #no_nil {
	Type_Unknown,
	Type_Name,
	Type_Pointer,
	Type_Raw_Pointer,
	Type_Struct,
	Type_Enum,
	Type_Typedef,
}
