package bindgen2

FR_Struct_Field :: struct {
	name: string,
	type: string,
}

FR_Struct :: struct {
	name: string,
	fields: []FR_Struct_Field,
}

Final_Representation :: struct {
	structs: [dynamic]FR_Struct,
}