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

	// Turn an enum into a bit_set. Key is an enum name that exists in the C source. Value is the
	// new bit_set name. Values within the enum will be automatically log2-ified (2
	// becomes 1, 4 becomes 2, 8 becomes 3 etc).
	bit_setify: map[string]string,

	// Rename key name to value.
	rename: map[string]string,

	type_overrides: map[string]string,
}
