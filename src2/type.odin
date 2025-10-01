// Type represents everything we need to know about a type. It is used during translation
// and also during output.
//
// It is FORBIDDEN to import or use anything clang-related in here, as the outputter
// should not know of clang.
package bindgen2

Type_Index :: distinct int

TYPE_INDEX_NONE :: Type_Index(0)

Type_Pointer :: struct {
	pointed_to_type: Type_Index,
}

Type_Alias :: struct {
	aliased_type: Type_Index,
}

Type_Struct_Field :: struct {
	name: string,
	type: Type_Index,
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

Type_Named :: struct {
	name: string,

	// Always zero for "basic types such as 'int'"
	definition: Type_Index,
}

Type_Enum :: struct {
	members: []Type_Enum_Member,
}

Type_Unknown :: struct {}

Type_Raw_Pointer :: struct {}

Type_Bit_Set :: struct {
	name: string,
	enum_type: Type_Index,
}

Type :: union #no_nil {
	Type_Unknown,
	Type_Named,
	Type_Pointer,
	Type_Raw_Pointer,
	Type_Struct,
	Type_Enum,
	Type_Bit_Set,
	Type_Alias,
}
