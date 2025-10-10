package bindgen2

import clang "../libclang"

Cursor_Children_Map :: map[clang.Cursor][]clang.Cursor

Translate_State :: struct {
	declarations: []Declaration,
	types: [dynamic]Type,
	type_lookup: map[clang.Type]Type_Index,
	children_lookup: Cursor_Children_Map,
	config: Config,
	source: string,
}
