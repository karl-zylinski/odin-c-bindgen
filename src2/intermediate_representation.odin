package bindgen2

import clang "../libclang"

Declaration :: struct {
	type: Type_Index,
	comment: string,
}

Intermediate_Representation :: struct {
	declarations: []Declaration,
	types: [dynamic]Type,
}
