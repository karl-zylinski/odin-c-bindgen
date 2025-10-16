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
	
	rename: map[string]string,
	bit_setify: map[string]string,

	type_overrides: map[string]string,

	struct_field_overrides: map[string]string,
	procedure_type_overrides: map[string]string,

	imports_file: string,
	import_lib: string,
	
	remove_type_prefix: string,
	remove_function_prefix: string,
	remove_macro_prefix: string,
	
	clang_include_paths: []string,
	clang_defines: map[string]string,

	force_ada_case_types: bool,
}
