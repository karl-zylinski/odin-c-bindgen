package bindgen2

import clang "../libclang"

Declaration :: struct {
	cursor: clang.Cursor,
	type: Type_Index,
}

Intermediate_Representation :: struct {
	declarations: []Declaration,
	types: []Type,
}
