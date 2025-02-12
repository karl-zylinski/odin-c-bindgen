# odin-c-bindgen: Generate Odin bindings for C libraries

This program generates Odin bindings for C libraries. It makes it possible to quickly get up and running with C libraries when programming in Odin.

## Requirements
- Odin
- clang (download from https://llvm.org/ or using the clang payload in Visual Studio installer)

## Getting started

1. Build the generator: `odin build src -out:bindgen.exe` (replace `.exe` with `.bin` on mac/Linux)
2. Make a folder. Inside it, put the C headers (`.h` files) of the library you want to generate bindings for.
3. Execute `bindgen the_folder`
4. Bindings can be found inside `the_folder/the_folder`
5. To get more control of how the generation happens, use a `bindgen.sjson` file to. See how in the next section, or look in the `examples` folder.

> [!NOTE]
> The generator assumes that the `clang` executable is in your PATH, i.e. that it is accessible system-wide.
> 
> clang is used for analysing the C headers and outputting an AST. The binding generator then processses that AST into Odin code.

## How do I configure the generator?

Add a `bindgen.sjson` to your bindings folder. I.e. inside the folder you feed into `bindgen`. Below is an example. See the `examples` folder for more advanced examples.

<details>
  <summary>bindgen.sjson template</summary>

```
// Inputs can be folders or files. It will look for header (.h) files inside
// any folder. The bindings will be based on those headers. Also, any .lib,
// .odin, .dll etc will be copied to the output folder.
inputs = [
	"input"
]

// Output folder: One .odin file per processed header
output_folder = "my_lib"

// Remove this prefix from type names and procedure names
remove_prefix = ""

// Only include things that has this prefix
required_prefix = ""

// Single lib file to import
import_lib = "my_lib.lib" // For example: "some_lib.lib"

// Code file that contain libray import code and whatever else extra you need.
// Overrides lib_file. Is pasted near top of the final bindings.
imports_file = ""

// For package line at top of output files
package_name = "my_lib"

// "Old_Name" = "New_Name",
rename_types = {
}

// Turns an enum into a bit_set. Converts the values of the enum into
// appropriate values for a bit_set. Creates a bit_set type that uses the enum.
// Properly removes enum values with value 0. Translates the enum values using
// a log2 procedure.
bit_setify = {
	// "Pre_Existing_Enum_Type" = "New_Bit_Set_Type"
}

// Completely override the definition of a type. The type needs to be pre-existing.
type_overrides = {
	// "Vector2" = "[2]f32"
}

// Override the type of a struct field. Note that a plain `[^]` can be used to
// modify the existing type.
struct_field_overrides = {
	// "Some_Type.some_field" = "My_Type"
}

// Overrides the type of a procedure parameter or return value. For a parameter
// use the key Proc_Name.parameter_name. For a return value use the key Proc_Name.
// Note that a plain `[^]` and `#by_ptr` can be used to modify the existing type.
procedure_type_overrides = {
	// "SetConfigFlags.flags" = "ConfigFlags"
	// "GetKeyPressed"        = "KeyboardKey"
}

// Inject a new type before another type. Use `rename_types` to just rename
// a pre-existing type.
inject_before = {
	// "Some_Type" = "New_Type :: distinct int"
}

// For typedefs that don't resolve to anything: Put them in here to create
// empty structs with that name.
opaque_types = [
	// "Some_Type"
]

// Writes the clang JSON ast dump for debug inspection (in output folder)
debug_dump_json_ast = false
```
</details>

## FAQ

### My bindings don't work

The binding generator does not understand any kind of C macros or inline functions. Those you'll have to port manually.

If your bindings don't work because of a missing C type, then chances are I've forgotten to add support for it. Try adding it to `c_type_mapping` inside `bindgen.odin` and recompile the generator.

If you have some library that is hard to generate bindings for, then submit an issue on this GitHub page and provide the headers in a zip. I'll try to help if I can find some time.

### How do I include a pre-made Odin file?

Add it to the input folder.

### How do I manually type out the library file imports?

Use `imports_file` in `bindgen.sjson`. See `examples/raylib`

## Acknowledgements

This generator was inspired by floooh's Sokol bindgen: https://github.com/floooh/sokol/tree/master/bindgen
