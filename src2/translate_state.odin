package bindgen2

import clang "../libclang"

Declaration :: struct {
	type: Type_Index,
	comment: string,
}

Cursor_Children_Map :: map[clang.Cursor][]clang.Cursor

Intermediate_Representation :: struct {
	declarations: []Declaration,
	types: [dynamic]Type,
}
