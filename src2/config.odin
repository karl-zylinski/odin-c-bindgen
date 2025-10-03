package bindgen2

// This is populated from the config `bindgen.sjson`
Config :: struct {
	// Files and folders to generate bindings for, relative to the config. If you specify a folder,
	// then all files within that folder will be used.
	inputs: []string,

	// Put outputted bindings into this folder, relative to the config.
	output_folder: string,

	// The package name to use in `package package_name` at top of each generated file.
	package_name: string,

	bit_sets: []Config_Bit_Set,

	type_overrides: map[string]string,

	struct_field_overrides: map[string]string,
}

Config_Bit_Set :: struct {
	name: string,
	enum_name: string,
	enum_rename: string,
	storage: string,
}