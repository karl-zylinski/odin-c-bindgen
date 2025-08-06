# odin-c-bindgen: Generate Odin bindings for C libraries

This generator makes it possible to quickly generate C library bindings for the Odin Programming Language.

Features:
- Easy to get started with. Can generate bindings from a folder of headers.
- Generates nice-looking bindings that retain comments. Example: [Generated Raylib bindings](https://github.com/karl-zylinski/odin-c-bindgen/blob/main/examples/raylib/raylib/raylib.odin).
- Simplicity. The generator is simple enough that you can modify it, should the need arise.
- Configurable. Easy to override types and turn enums into bit_sets, etc. More info [below](#configuration) and [in the examples](https://github.com/karl-zylinski/odin-c-bindgen/blob/main/examples/raylib/bindgen.sjson).

## Requirements
- Odin
- libclang
	- Included on Windows (DLL lives in root folder of repository)
	- On Linux/mac, please install libclang. For example using `apt install libclang-dev` on Ubuntu/Debian/Mint.

> [!NOTE]
> libclang is used for analysing the C headers and deciding what Odin code to output.

## Getting started

1. Build the generator: `odin build src -out:bindgen.exe` (replace `.exe` with `.bin` on mac/Linux)
2. Make a folder. Inside it, put the C headers (`.h` files) of the library you want to generate bindings for.
3. Execute `bindgen the_folder`
4. Bindings can be found inside `the_folder/the_folder`
5. To get more control of how the generation happens, use a `bindgen.sjson` file to. See how in the next section, or look in the `examples` folder.

## Configuration

Add a `bindgen.sjson` to your bindings folder. I.e. inside the folder you feed into `bindgen`. Below is an example. See the [examples folder](https://github.com/karl-zylinski/odin-c-bindgen/tree/main/examples) for more advanced examples.

> NOTE: Config uses the function/type names as found in header files.

```sjson
// Inputs can be folders or files. It will look for header (.h) files inside
// any folder. The bindings will be based on those headers. Also, any .lib,
// .odin, .dll etc will be copied to the output folder.
inputs = [
	"input"
]

// Files to ignore when processing files in the inputs folders
ignore_inputs = [
	// "file.h"
]

// Output folder: One .odin file per processed header
output_folder = "my_lib"

// Remove this prefix from types names (structs, enums, etc)
remove_type_prefix = ""

// Remove this prefix from macro names
remove_macro_prefix = ""

// Remove this prefix from function names (and add it as link_prefix) to the foreign group
remove_function_prefix = ""

// Only include things that has this prefix
required_prefix = ""

// Set to true translate type names to Ada_Case
force_ada_case_types = false

// Single lib file to import
import_lib = "my_lib.lib"

// Use this file instead of `import_lib`. This is a whole file that is pasted near
// the top of the file. In it you can do platform-specific library imports etc.
imports_file = ""

// For package line at top of output files
package_name = "my_lib"

// "Old_Name" = "New_Name",
rename = {
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

// Inject a new type before another type. Use `rename` to just rename
// a pre-existing type.
inject_before = {
	// "Some_Type" = "New_Type :: distinct int"
}

// For typedefs that don't resolve to anything: Put them in here to create
// empty structs with that name.
opaque_types = [
	// "Some_Type"
]

// additional include paths to send into clang. While generating the bindings
// clang will look into this path in search for included headers.
clang_include_paths = [
	// "include"
]

// Put the names of macros to remove in here. This is useful for removing
// macros that were converted into invalid Odin constants.
remove_macros = [
	// "SOME_BROKEN_MACRO"
]
```

## FAQ and common problems

### Why didn't my bindings generate correctly?

If your bindings don't work because of a missing C type, then chances are I've forgotten to add support for it. Try adding it to `c_type_mapping` inside `bindgen.odin` and recompile the generator.

If you have some library that is hard to generate bindings for, then submit an issue on this GitHub page and provide the headers in a zip. I'll try to help if I can find some time.

The generator won't bring along any inline functions.

### How do I include a pre-made Odin file?

Add it to the input folder.

### How do I manually specify which libraries to load on different platforms etc?

Use `imports_file` in `bindgen.sjson`. See `examples/raylib`

### How can I turn an enum into a bit_set?

In `bindgen.sjson`:

```
bit_setify = {
	"your_enum" = "the_bit_set_type"
}
```

This will create a type `the_bit_set_type :: bit_set[your_enum; c.int`.

It will also translate the values of the enum by calculating their log2 value (that gives you the bit index instead of the integer value corresponding to that bit).

### My headers can't find other headers in the same folder

If the generator is processing `include/some_folder/header.h` and it can't find some other header `include/some_folder/something.h`, then add `include` to the include search path by adding he following to `bindgen.sjson`:

```
clang_include_path = "include"
```

### My forward-declared type is missing in the bindings

Add the typename to `opaque_types` in `bindgen.sjson`:
```
opaque_types = [
	"The_Type"
]
```

You should put in the translated type name, as it would appear in the Odin file (will all prefixes removed, etc).

## Acknowledgements

This generator was inspired by floooh's Sokol bindgen: https://github.com/floooh/sokol/tree/master/bindgen
