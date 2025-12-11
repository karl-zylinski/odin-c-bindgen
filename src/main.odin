package bindgen2

import vmem "core:mem/virtual"
import "core:mem"
import "core:os"
import "core:os/os2"
import "core:fmt"
import "core:strings"
import "core:path/filepath"
import "base:runtime"
import "core:encoding/json"
import "core:slice"
import "core:log"

main :: proc() {
	permanent_arena: vmem.Arena
	permanent_allocator := vmem.arena_allocator(&permanent_arena)
	context.allocator = permanent_allocator
	context.temp_allocator = permanent_allocator
	context.logger = log.create_console_logger()

	ensure(len(os.args) == 2, "Usage: 'bindgen directory' or 'bindgen directory/bindgen.sjson'")
	config_dir_or_file := os.args[1]

	DEFAULT_CONFIG_FILENAME :: "bindgen.sjson"
	
	config_filename: string
	dir: string

	if strings.has_suffix(config_dir_or_file, ".sjson") && os.is_file(config_dir_or_file) {
		config_filename = config_dir_or_file
		dir = filepath.dir(config_dir_or_file)
	} else if os.is_dir(config_dir_or_file) {
		config_filename = filepath.join({config_dir_or_file, DEFAULT_CONFIG_FILENAME})
		dir = config_dir_or_file
	} else {
		fmt.panicf("%v is not a directory nor a valid config file", config_dir_or_file)
	}

	default_output_folder := "output"
	default_package_name := "pkg"

	if config_dir_handle, config_dir_handle_err := os2.open(dir); config_dir_handle_err == nil {
		if stat, stat_err := os2.fstat(config_dir_handle, context.allocator); stat_err == nil {
			default_output_folder = stat.name
			default_package_name = stat.name
		}
	}

	config: Config

	if os.is_file(config_filename) {
		if config_data, config_data_ok := os.read_entire_file(config_filename); config_data_ok {
			config_err := json.unmarshal(config_data, &config, .SJSON)
			fmt.ensuref(
				config_err == nil,
				"Failed parsing config %v: %v",
				config_filename,
				config_err,
			)
		} else {
			fmt.ensuref(config_data_ok, "Failed parsing config %v", config_filename)
		}
	} else {
		config.inputs = slice.clone([]string{"."})
	}

	output_folder := filepath.join({dir, config.output_folder != "" ? config.output_folder : default_output_folder})
	package_name := config.package_name != "" ? config.package_name : default_package_name
	
	if config.imports_file != "" {
		config.imports_file = filepath.join({dir, config.imports_file})
	}

	input_files: [dynamic]string

	for input_base in config.inputs {
		input := filepath.join({dir, input_base})
		if os.is_dir(input) {
			input_folder, input_folder_err := os2.open(input)
			log.ensuref(input_folder_err == nil, "Failed opening folder %v: %v", input, input_folder_err)
			iter := os2.read_directory_iterator_create(input_folder)

			for f in os2.read_directory_iterator(&iter) {
				if f.type != .Regular {
					continue
				}

				append(&input_files, filepath.join({input, f.name}))
			}

			os2.close(input_folder)
		} else if os.is_file(input) {
			append(&input_files, input)
		} else {
			log.errorf("%v is neither directory or .h file", input)
		}
	}

	if output_folder != "" && !os2.exists(output_folder) {
		make_dir_err := os2.make_directory_all(output_folder)
		log.ensuref(make_dir_err == nil, "Failed creating output directory %v: %v", output_folder, make_dir_err)
	}

	for input_filename in input_files {
		if filepath.ext(input_filename) == ".h" {
			types_arena: vmem.Arena
			types_arena_err := vmem.arena_init_static(&types_arena, 100 * mem.Megabyte)
			log.assertf(types_arena_err == nil, "Failed reserving types arena memory. Error: %v", types_arena_err)

			decls_arena: vmem.Arena
			decls_arena_err := vmem.arena_init_static(&decls_arena, 100 * mem.Megabyte)
			log.assertf(decls_arena_err == nil, "Failed reserving types arena memory. Error: %v", decls_arena_err)

			type_arr := make([dynamic]Type, allocator = vmem.arena_allocator(&types_arena))
			types := Type_List(&type_arr)
			decl_arr := make([dynamic]Decl, allocator = vmem.arena_allocator(&decls_arena))
			decls := Decl_List(&decl_arr)

			add_decl(decls, {})
			add_type(types, {})

			gen_arena: vmem.Arena
			context.allocator = vmem.arena_allocator(&gen_arena)
			context.temp_allocator = vmem.arena_allocator(&gen_arena)
			gen_ctx = context
			
			log.infof("Collecting data from %v", input_filename)
			collect_res, collect_ok := translate_collect(input_filename, config, types, decls)

			if !collect_ok {
				continue
			}

			translate_macros(collect_res.macros, decls)

			log.infof("Processing data from %v", input_filename)
			process_res := translate_process(collect_res, config, types, decls)
	
			input_folder := filepath.dir(input_filename)
			filename_stem := filepath.stem(input_filename)
			footer_filename := filepath.join({input_folder, fmt.tprintf("%v_footer.odin", filename_stem)})

			footer: string
			if os.exists(footer_filename) {
				if footer_bytes, footer_bytes_ok := os.read_entire_file(footer_filename); footer_bytes_ok {
					footer = string(footer_bytes)
				}
			}

			output_filename := filepath.join({output_folder, fmt.tprintf("%v.odin", filename_stem)})
			log.infof("Writing %v", output_filename)
			output(types, decls, process_res, output_filename, footer, package_name)
			vmem.arena_destroy(&gen_arena)
			vmem.arena_destroy(&types_arena)
			vmem.arena_destroy(&decls_arena)
		}
	}
}

gen_ctx: runtime.Context

to_cstring :: proc(str: string) -> cstring {
	return strings.clone_to_cstring(str)
}