#+private file
package bindgen2

import "core:os"
import "core:fmt"
import "core:strings"

@(private="package")
output :: proc(ir: IR, filename: string) {
	builder := strings.builder_make()
	sb := &builder

	p :: fmt.sbprint
	pln :: fmt.sbprintln
	pf :: fmt.sbprintf
	pfln :: fmt.sbprintfln

	for s in ir.structs {
		p(sb, s.name)
		p(sb, " :: struct{} \n")
	}

	write_err := os.write_entire_file(filename, transmute([]u8)(strings.to_string(builder)))
	fmt.ensuref(write_err == true, "Failed writing %v", filename)
}