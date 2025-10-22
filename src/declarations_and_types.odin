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
	Type_Name,
	Fixed_Value,
	Type_Index,
}

Type_Name :: distinct string

Fixed_Value :: distinct string

// Just an index into an array of types. Use to point out the definition of another type.
Type_Index :: distinct int

TYPE_INDEX_NONE :: Type_Index(0)

Decl_List :: ^[dynamic]Decl
Type_List :: ^[dynamic]Type

add_type :: proc(array: Type_List, t: Type) -> Type_Index {
	idx := len(array)
	append(array, t)
	return Type_Index(idx)
}

add_decl :: proc(decls: Decl_List, d: Decl) {
	append(decls, d)
}

Decl :: struct {
	name: string,

	def: Definition,
	comment_before: string,
	side_comment: string, // rename to comment_on_right

	invalid: bool,

	is_forward_declare: bool,

	original_line: int,

	explicitly_created: bool,

	// TODO can we get these two for all fields

	// Only used for macros.
	explicit_whitespace_before_side_comment: int,

	// Only used for macros.
	explicit_whitespace_after_name: int,

	// This declaration originates from a C macro.
	//
	// TODO: We currently have three "categories": types, procs and macros. Should this be enumified
	// perhaps? The proc info comes from 'def' currently
	from_macro: bool,
}

Type :: union #no_nil {
	Type_Unknown,
	Type_Pointer,
	Type_Multipointer,
	Type_Pointer_By_Ptr,
	Type_Raw_Pointer,
	Type_CString,
	Type_Struct,
	Type_Enum,
	Type_Bit_Set,
	Type_Bit_Set_Constant,
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

Type_Pointer_By_Ptr :: struct {
	pointed_to_type: Definition,
}

Type_Alias :: struct {
	aliased_type: Definition,
}

Type_Struct_Field :: struct {
	names: [dynamic]string,
	anonymous: bool,
	type: Definition,
	type_overrride: string,
	comment_before: string,
	comment_on_right: string,

	tag: string,
	is_using: bool,

	// internal
	line: int,
}

Type_Struct :: struct {
	fields: []Type_Struct_Field,
	raw_union: bool,
}

Type_Enum_Member :: struct {
	name: string,
	value: int,
	comment_before: string,
	comment_on_right: string,
}

Type_Enum :: struct {
	storage_type: typeid,
	members: []Type_Enum_Member,
}

Type_Unknown :: struct {}

Type_Raw_Pointer :: struct {}

Type_Bit_Set :: struct {
	enum_decl_name: Definition,
	enum_type: Type_Index,
}

Type_Bit_Set_Constant :: struct {
	bit_set_type: Type_Index,
	bit_set_type_name: Type_Name,
	value: int,
}

Type_Fixed_Array :: struct {
	element_type: Definition,
	size: int,
}

Type_Procedure_Parameter :: struct {
	name: string,
	type: Definition,
	any_int: bool,
}

Type_Procedure :: struct {
	parameters: []Type_Procedure_Parameter,
	result_type: Definition,
	calling_convention: Calling_Convention,
	is_variadic: bool,
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

resolve_type_definition :: proc(types: Type_List, def: Definition, $T: typeid) -> (T, bool) {
	if idx, is_idx := def.(Type_Index); is_idx {
		return types[idx].(T)
	}

	return {}, false
}

