package bindgen2

Output_State :: struct {
	decls: []Declaration,
	types: []Type,

	// Comment at top of file
	top_comment: string,
}