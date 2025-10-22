package bindgen2

// This is populated from a `bindgen.sjson` file
Config :: struct {
	// Inputs can be folders or files. If you provide a folder name, then the generator will look for
	// header (.h) files inside it. The bindings will be based on those headers. For each header,
	// you can create a `header_footer.odin` file with some additional code to append to the finished
	// bindings. If the header is called `raylib.h` then the footer would be `raylib_footer.odin`.
	inputs: []string,

	// Output folder. In there you'll find one .odin file per processed header.
	output_folder: string,

	// Remove this prefix from types names (structs, enums, etc)
	remove_type_prefix: string,

	// Remove this prefix from macro names
	remove_macro_prefix: string,

	// Remove this prefix from function names (and add it as link_prefix) to the foreign group
	remove_function_prefix: string,
	
	// Set to true translate type names to Ada_Case
	force_ada_case_types: bool,

	// Single lib file to import. Will be ignored if `imports_file` is set.
	import_lib: string,

	// The filename of a file that contains the foreign import declarations. In it you can do
	// platform-specific library imports etc. The contents of it will  be placed near the top of the
	// file.
	imports_file: string,

	// `package something` to put at top of each generated Odin binding file.
	package_name: string,
	
	// "Old_Name" = "New_Name"
	rename: map[string]string,

	// Turns an enum into a bit_set. Converts the values of the enum into appropriate values for a
	// bit_set. Creates a bit_set type that uses the enum. Properly removes enum values with value 0.
	// Translates the enum values using a log2 procedure.
	bit_setify: map[string]string,

	// Completely override the definition of a type.
	type_overrides: map[string]string,

	// Override the type of a struct field.
	// 
	// You can also use `[^]` to augment an already existing type.
	struct_field_overrides: map[string]string,

	// Put these tags on the specified struct field
	struct_field_tags: map[string]string,

	// Remove a specific enum member. Write the C name of the member. You can also use wildcards
	// such as *_Count
	remove_enum_members: []string,

	// Overrides the type of a procedure parameter or return value. For a parameter use the key
	// Proc_Name.parameter_name. For a return value use the key Proc_Name.
	//
	// You can also use `[^]`, `#by_ptr` and `#any_int` to augment an already existing type.
	procedure_type_overrides: map[string]string,

	// Put the names of declarations in here to remove them.	
	remove: []string,

	// Group all procedures at the end of the file.
	procedures_at_end: bool,
	
	// Additional include paths to send into clang. While generating the bindings clang will look into
	// this path in search for included headers.
	clang_include_paths: []string,
	clang_defines: map[string]string,

	
}
