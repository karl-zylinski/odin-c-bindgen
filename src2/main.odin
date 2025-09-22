package bindgen2

import vmem "core:mem/virtual"
import "core:os"
import "core:os/os2"
import "core:fmt"
import "core:strings"
import "core:path/filepath"
import "base:runtime"

main :: proc() {
	permanent_arena: vmem.Arena
	permanent_allocator := vmem.arena_allocator(&permanent_arena)
	context.allocator = permanent_allocator
	context.temp_allocator = permanent_allocator

	ensure(len(os.args) == 2, "Usage: bindgen directory")
	dir := os.args[1]
	ensure(os.is_dir(dir), "Argument should be a directory")

	input_files: [dynamic]string

	input_folder, input_folder_err := os2.open(fmt.tprintf("%v/%v", dir, "input"))
	fmt.ensuref(input_folder_err == nil, "Failed opening folder %v: %v", dir, input_folder_err)
	iter := os2.read_directory_iterator_create(input_folder)

	for f in os2.read_directory_iterator(&iter) {
		if f.type != .Regular {
			continue
		}

		append(&input_files, fmt.tprintf("%v/input/%v", dir, f.name))
	}

	os2.close(input_folder)

	for i in input_files {
		if filepath.ext(i) == ".h" {
			gen_arena: vmem.Arena
			context.allocator = vmem.arena_allocator(&gen_arena)
			context.temp_allocator = vmem.arena_allocator(&gen_arena)
			gen_ctx = context
			ir := parse(i)
			fr := process(&ir)
			output_stem := filepath.stem(i)
			output_filename := fmt.tprintf("%v/_output/%v.odin", dir, output_stem)
			output(fr, output_filename)
			vmem.arena_destroy(&gen_arena)
		}
	}
}

gen_ctx: runtime.Context

to_cstring :: proc(str: string) -> cstring {
	return strings.clone_to_cstring(str)
}