package bindgen2

import clang "../libclang"

Typed_Cursor :: struct {
	cursor: clang.Cursor,
	type: Type_Index,
}

Intermediate_Representation :: struct {
	global_scope_declarations: []Typed_Cursor,
	types: []Type,
}
