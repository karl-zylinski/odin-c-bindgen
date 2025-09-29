package bindgen2

FR_Declaration :: struct {
	name: string,
	variant: FR_Declaration_Variant,
	comment_before: string,
}

FR_Declaration_Variant :: union {
	FR_Struct,
	FR_Typedef,
	FR_Enum,
	FR_Bit_Set,
}

FR_Struct :: struct {
	type: Type_Index,
}

FR_Typedef :: struct {
	typedeffed_type: Type_Index,
}

FR_Enum :: struct {
	type: Type_Index,
}

FR_Bit_Set :: struct {
	enum_type: Type_Index,
}

Final_Representation :: struct {
	decls: []FR_Declaration,
	types: []Type,
}