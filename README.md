# odin-c-bindgen: Generate Odin bindings for C libraries

This generator makes it possible to quickly generate C library bindings for the Odin Programming Language.

Features:
- Easy to get started with. Can generate bindings from a folder of headers.
- Generates nice-looking bindings that retain comments. Example: [Generated Raylib bindings](https://github.com/karl-zylinski/odin-c-bindgen/blob/main/examples/raylib/raylib/raylib.odin).
- Simplicity. The generator is simple enough that you can modify it, should the need arise.
- Configurable. Easy to override types and turn enums into bit_sets, etc. More info [below](#configuration) and [in the examples](https://github.com/karl-zylinski/odin-c-bindgen/blob/main/examples/raylib/bindgen.sjson).

> If you find this generator helpful and want to say thanks, then please consider [dontating](https://github.com/sponsors/karl-zylinski).

## Requirements
- Odin
- libclang
	- On Windows: Download libclang 20.1.8 from here: https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/clang+llvm-20.1.8-x86_64-pc-windows-msvc.tar.xz -- Copy the following from that archive:
		- `lib/libclang.lib` into the generator's 'libclang' folder
		- `bin/libclang.dll` into the root of the generator (next to where the bindgen executable will end up).
	- On Linux/mac, please install libclang. For example using `apt install libclang-dev` on Ubuntu/Debian/Mint. It doesn't have to be version 20, I've tried it with as low as version 18.

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
// Inputs can be folders or files. If you provide a folder name, then the generator will look for
// header (.h) files inside it. The bindings will be based on those headers. For each header,
// you can create a `header_footer.odin` file with some additional code to append to the finished
// bindings. If the header is called `raylib.h` then the footer would be `raylib_footer.odin`.
inputs = [
	"input"
]

// Output folder. In there you'll find one .odin file per processed header.
output_folder = "my_lib"

// Remove this prefix from types names (structs, enums, etc)
remove_type_prefix = ""

// Remove this prefix from macro names
remove_macro_prefix = ""

// Remove this prefix from function names (and add it as link_prefix) to the foreign group
remove_function_prefix = ""

// Set to true translate type names to Ada_Case
force_ada_case_types = false

// Single lib file to import. Will be ignored if `imports_file` is set.
import_lib = "my_lib.lib"

// The filename of a file that contains the foreign import declarations. In it you can do
// platform-specific library imports etc. The contents of it will  be placed near the top of the
// file.
imports_file = ""

// `package something` to put at top of each generated Odin binding file.
package_name = "my_lib"

// "Old_Name" = "New_Name"
rename = {
}

// Turns an enum into a bit_set. Converts the values of the enum into appropriate values for a
// bit_set. Creates a bit_set type that uses the enum. Properly removes enum values with value 0.
// Translates the enum values using a log2 procedure.
bit_setify = {
	// "Pre_Existing_Enum_Type" = "New_Bit_Set_Type"
}

// Completely override the definition of a type.
type_overrides = {
	// "Vector2" = "[2]f32"
}

// Override the type of a struct field.
// 
// You can also use `[^]` to augment an already existing type.
struct_field_overrides = {
	// "Some_Type.some_field" = "My_Type"
	// "Some_Other_Type.field" = "[^]"
	// "Some_Other_Type.another_file" = "[^]cstring"
}

// Put these tags on the specified struct field
struct_field_tags = {
	// "BoneInfo.name" = "fmt:\"s,0\""
}

// Remove a specific enum member. Write the C name of the member. You can also use wildcards
// such as *_Count
remove_enum_members = [
	// "MAGICAL_ENUM_ALL"
	// "_*Count"
]

// Overrides the type of a procedure parameter or return value. For a parameter use the key
// Proc_Name.parameter_name. For a return value use the key Proc_Name.
//
// You can also use `[^]`, `#by_ptr` and `#any_int` to augment an already existing type.
procedure_type_overrides = {
	// "SetConfigFlags.flags" = "ConfigFlags"
	// "GetKeyPressed"        = "KeyboardKey"
}

// Add in a default value to a procedure parameter. Use `Proc_Name.parameter_name` as key and
// write the plain-text Odin value as value.
//
// You can also add defaults for proc parameters within structs. In that case you do:
// `Struct_Name.proc_field.parameter_name` -- This does not currently support nested structs.
procedure_parameter_defaults = {
	// "DrawTexturePro.tint" = "RED"
	// "Some_Struct.a_field_that_is_a_proc.some_parameter" = "5"
}

// Put the names of declarations in here to remove them.
remove = [
	// "Some_Declaration_Name"
]

// Group all procedures at the end of the file.
procedures_at_end = false

// Additional include paths to send into clang. While generating the bindings clang will look into
// this path in search for included headers.
clang_include_paths = [
	// "include"
]

// Pass these compiler defines into clang. Can be used to control clang pre-processor
clang_defines = {
	// "UFBX_REAL_IS_FLOAT" = "1"
}
```

## FAQ and common problems

### Why didn't my bindings generate correctly?

Please look through the list of configuration options listed above and see if they help you. Also,
see the the examples folder for additional inspiration.

If you fail to make any progress on generating bindings for a certain library, then submit an issue on this GitHub page and provide the headers in a zip. I'll try to help if I can find some time.

### How can I add some extra code to a generated file?

If the source header is called `raylib.h` then add a a file called `raylib_footer.odin` next to it
and put your code in there.

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
clang_include_paths = [
	"include"
]
```

## Acknowledgements

Big thanks to [Xandaron](https://github.com/xandaron/) for figuring out a lot of the libclang stuff.

This generator was inspired by floooh's Sokol bindgen: https://github.com/floooh/sokol/tree/master/bindgen
