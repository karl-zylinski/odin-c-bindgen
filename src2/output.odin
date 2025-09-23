#+private file
package bindgen2

import "core:os"
import "core:fmt"
import "core:strings"

@(private="package")
output :: proc(fr: Final_Representation, filename: string, package_name: string) {
	ensure(filename != "")
	ensure(package_name != "")
	builder := strings.builder_make()
	sb := &builder

	p :: fmt.sbprint
	pln :: fmt.sbprintln
	pf :: fmt.sbprintf
	pfln :: fmt.sbprintfln

	pfln(sb, "package %v", package_name)
	pln(sb, "")

	for s in fr.structs {
		pfln(sb, "%v :: struct {{", s.name)

		for f in s.fields {
			pfln(sb, "\t%s: %s,", f.name, f.type)	
		}
		
		pln(sb, "}")
		pln(sb, "")
	}

	for a in fr.aliases {
		pfln(sb, "%v :: %v", a.new_name, a.original_name)
		pln(sb, "")
	}

	write_err := os.write_entire_file(filename, transmute([]u8)(strings.to_string(builder)))
	fmt.ensuref(write_err == true, "Failed writing %v", filename)
}