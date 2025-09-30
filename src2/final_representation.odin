package bindgen2

FR_Declaration :: struct {
	name: string,
	type: Type_Index,
	comment_before: string,
}

Final_Representation :: struct {
	decls: []FR_Declaration,
	types: []Type,
}