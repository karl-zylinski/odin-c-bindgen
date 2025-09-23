package bindgen2

import clang "../libclang"

IR_Struct :: struct {
	cursor: clang.Cursor,
}

IR_Typedef :: struct {
	new_cursor: clang.Cursor,
	original_type: clang.Type,
}

Intermediate_Representation :: struct {
	structs: [dynamic]IR_Struct,
	typedefs: [dynamic]IR_Typedef,
}