package bindgen2

FR_Declaration :: struct {
	name: string,
	variant: FR_Declaration_Variant,
	comment_before: string,
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

FR_Declaration_Variant :: union {
	FR_Struct,
	FR_Typedef,
	FR_Enum,
}

Final_Representation :: struct {
	decls: []FR_Declaration,
	types: []Type,
}