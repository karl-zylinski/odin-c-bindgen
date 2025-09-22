package bindgen2

import clang "../libclang"

IR_Struct :: struct {
	cursor: clang.Cursor,
}

Intermediate_Representation :: struct {
	structs: [dynamic]IR_Struct,
}