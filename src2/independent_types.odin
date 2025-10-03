// In here we put types that can be used within any file. They are said to be independent, because
// they do not depend on libclang.
//
// It is FORBIDDEN to import libclang or use anything from libclang in here, as the outputter
// will use these types. The outputter does not, and should not, have any knowledge of clang.
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

Type_Named :: struct {
	name: string,

	// Always zero for "basic types such as 'int'"
	definition: Type_Index,
}

Type_Enum :: struct {
	storage_type: typeid,
	members: []Type_Enum_Member,
}

Type_Unknown :: struct {}

Type_Raw_Pointer :: struct {}

Type_Bit_Set :: struct {
	enum_type: Type_Index,
}

// Hard-coded override containing Odin type text
Type_Override :: struct {
	definition_text: string,
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
	Type_Override,
}

Declaration :: struct {
	named_type: Type_Index,
	comment_before: string,
}