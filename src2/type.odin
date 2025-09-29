// Type represents everything we need to know about a type. It is used during translation
// and also during output.
//
// It is FORBIDDEN to import or use anything clang-related in here, as the outputter
// should not know of clang.
package bindgen2

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
