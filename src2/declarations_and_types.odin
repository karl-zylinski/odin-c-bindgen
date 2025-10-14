// In here we put types that can be used within any file. They are said to be independent, because
// they do not depend on libclang.
//
// It is FORBIDDEN to import libclang or use anything from libclang in here, as the outputter
// will use these types. The outputter does not, and should not, have any knowledge of clang.
package bindgen2

// A type identifier is either a string or an index that points to another type. The string used to
// refer to a type just by its name (for example, when a struct field refers to some other type).
// The index is often used when a struct contains a field of anonymous type.
Definition :: union  {
	string,
	Type_Index,
}

// Just an index into an array of types. Use to point out the definition of another type.
Type_Index :: distinct int

TYPE_INDEX_NONE :: Type_Index(0)

Declaration :: struct {
	name: string,
	def: Definition,
	comment_before: string,
	side_comment: string,

	// TODO can we get these two for all fields

	// Only used for macros.
	explicit_whitespace_before_side_comment: int,

	// Only used for macros.
	explicit_whitespace_after_name: int,
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

	// Should alias really exist in the output stage? Isn't it just a name + a literal or a
	Type_Alias,
	Type_Fixed_Array,
	Type_Procedure,
}

Type_Pointer :: struct {
	pointed_to_type: Definition,
}

Type_Multipointer :: struct {
	pointed_to_type: Definition,
}

Type_Alias :: struct {
	aliased_type: Definition,
}

Type_Struct_Field :: struct {
	name: string,
	type: Definition,
	type_overrride: string,
	comment_before: string,
	comment_on_right: string,
}

Type_Struct :: struct {
	fields: []Type_Struct_Field,
	raw_union: bool,
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
	enum_type: Definition,
}

Type_Fixed_Array :: struct {
	element_type: Definition,
	size: int,
}

Type_Procedure_Parameter :: struct {
	name: string,
	type: Definition,
}

Type_Procedure :: struct {
	parameters: []Type_Procedure_Parameter,
	result_type: Definition,
	calling_convention: Calling_Convention,
}

Calling_Convention :: enum {
	C,
	Std_Call,
	Fast_Call,
}

Type_CString :: struct {}

// Hard-coded override containing Odin type text
Type_Override :: struct {
	definition_text: string,
}

resolve_type_definition :: proc(types: []Type, def: Definition, $T: typeid) -> (T, bool) {
	if idx, is_idx := def.(Type_Index); is_idx {
		return types[idx].(T)
	}

	return {}, false
}
