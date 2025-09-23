package bindgen2

FR_Struct_Field :: struct {
	name: string,
	type: string,
	comment_before: string,
	comment_on_right: string,
}

FR_Struct :: struct {
	name: string,
	fields: []FR_Struct_Field,
	comment_before: string,
}

FR_Alias :: struct {
	new_name: string,
	original_name: string,
}

FR_Declaration :: union {
	FR_Struct,
	FR_Alias,
}

Final_Representation :: struct {
	decls: []FR_Declaration,
}