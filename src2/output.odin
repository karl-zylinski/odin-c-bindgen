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

	for &du in fr.decls {
		switch &d in du {
		case FR_Struct:
			if d.comment_before != "" {
				pln(sb, d.comment_before)
			}

			pfln(sb, "%v :: struct {{", d.name)

			for f in d.fields {
				if f.comment_before != "" {
					pfln(sb, "\t%s", f.comment_before)
				}

				pf(sb, "\t%s: %s,", f.name, f.type)	

				if f.comment_on_right != "" {
					pf(sb, " %v", f.comment_on_right)
				}

				pf(sb, "\n")
			}
			
			pln(sb, "}")
			pln(sb, "")
		case FR_Alias:
			pfln(sb, "%v :: %v", d.new_name, d.original_name)
			pln(sb, "")
		}
	}

	write_err := os.write_entire_file(filename, transmute([]u8)(strings.to_string(builder)))
	fmt.ensuref(write_err == true, "Failed writing %v", filename)
}