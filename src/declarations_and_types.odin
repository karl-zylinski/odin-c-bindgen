// In here we put types that can be used within any file. They are said to be independent, because
// they do not depend on libclang.
//
// It is FORBIDDEN to import libclang or use anything from libclang in here, as the outputter
// will use these types. The outputter does not, and should not, have any knowledge of clang.
package bindgen2

// A Definition can be a type name or refer to another type using an index. Fields will often use
// type names to refer to types while declarations will use type indices to point out how the type
// actually looks.
Definition :: union  {
	Type_Name,
	Fixed_Value,
	Type_Index,
	Macro_Name,
}

Type_Name :: distinct string

// Used for constants etc
Fixed_Value :: distinct string

// For referring to other macros (constant values, these will be evaluated in translate_macros)
Macro_Name :: distinct string

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

// A decl is something with a name such as `Cat :: struct { field: int }`. Here the decl has the
// name Cat. The `def` field will point to a `Type_Index` so that the actual struct definition can
// be outputted.
Decl :: struct {
	name: string,

	def: Definition,
	comment_before: string,
	side_comment: string, // rename to comment_on_right

	invalid: bool,

	is_forward_declare: bool,

	original_line: int,

	explicitly_created: bool,

	// Only used for procs and only if it's not empty.
	link_name: string,

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

// Types such as `Type_Pointer` just refer to other types. Type such as `Type_Struct_Field` contain
// more info such as: What's the name of the field? etc
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
	// the `u32` in `My_Enum :: enum u32 {}`
	storage_type: typeid,
	members: []Type_Enum_Member,
}

Type_Unknown :: struct {}

Type_Raw_Pointer :: struct {}

Type_Bit_Set :: struct {
	enum_decl_name: Definition,
	enum_type: Type_Index,
}

// When bit-setifying, there may exist values that are not power-of-two. Those can't be in the
// bitset because they won't have a unique bit associated with them. They will instead be outputted
// as separate constants.
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
	default: string,
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

// Hard-coded override containing Odin type text, comes from the config file.
Type_Override :: struct {
	definition_text: string,
}

check_type_definition :: proc(types: Type_List, def: Definition, $T: typeid) -> (bool) {
	if idx, is_idx := def.(Type_Index); is_idx {
		_, is_type := types[idx].(T)

		return is_type
	}

	return false
}

resolve_type_definition :: proc(types: Type_List, def: Definition, $T: typeid) -> (T, bool) {
	if idx, is_idx := def.(Type_Index); is_idx {
		return types[idx].(T)
	}

	return {}, false
}

resolve_type_definition_ptr :: proc(types: Type_List, def: Definition, $T: typeid) -> ^T {
	if idx, is_idx := def.(Type_Index); is_idx {
		if t, is_t := &types[idx].(T); is_t {
			return t
		}
	}

	return nil
}

