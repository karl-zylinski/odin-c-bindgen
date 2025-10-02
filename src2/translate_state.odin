package bindgen2

import clang "../libclang"

Declaration :: struct {
	type: Type_Index,
	comment: string,
}

Cursor_Children_Map :: map[clang.Cursor][]clang.Cursor

Translate_State :: struct {
	declarations: []Declaration,
	types: [dynamic]Type,
	children_lookup: Cursor_Children_Map,
}
