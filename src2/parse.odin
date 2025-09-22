#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "base:runtime"
import "core:strings"

@(private="package")
parse :: proc(filename: string) -> Intermediate_Representation {
	ir: Intermediate_Representation

	clang_args := []cstring {
		"-fparse-all-comments"
	}

	index := clang.createIndex(1, 0)
	unit: clang.Translation_Unit

	options: clang.Translation_Unit_Flags = {
		.DetailedPreprocessingRecord, // Keep macros.
		.SkipFunctionBodies,
		.KeepGoing, // Keep going on errors.
	}

	err := clang.parseTranslationUnit2(
		index,
		to_cstring(filename),
		raw_data(clang_args),
		i32(len(clang_args)),
		nil,
		0,
		options,
		&unit,
	)

	fmt.ensuref(err == .Success, "Failed to parse translation unit for %s. Error code: %v", filename, err)
	root_cursor := clang.getTranslationUnitCursor(unit)

	root_children := get_cursor_children(root_cursor)	

	for c in root_children {
		kind := clang.getCursorKind(c)
		loc := get_cursor_location(c)

		#partial switch kind {
		case .StructDecl:
			irs := IR_Struct {
				cursor = c,
			}
			append(&ir.structs, irs)
		}
	}

	return ir
}