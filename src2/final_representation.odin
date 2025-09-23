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

Final_Representation :: struct {
	structs: [dynamic]FR_Struct,
	aliases: [dynamic]FR_Alias,
}