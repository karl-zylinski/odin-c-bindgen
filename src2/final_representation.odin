package bindgen2

FR_Declaration :: struct {
	named_type: Type_Index,
	comment_before: string,
}

Final_Representation :: struct {
	decls: []FR_Declaration,
	types: []Type,
}