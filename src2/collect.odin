#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "base:runtime"
import "core:strings"
import "core:log"

@(private="package")
collect :: proc(filename: string) -> Intermediate_Representation {
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
		case .TypedefDecl:
			typedeffed_type := clang.getTypedefDeclUnderlyingType(c)
			typedeffed_type_cursor: clang.Cursor

			#partial switch typedeffed_type.kind {
			case .Elaborated:
				elaborated_type := clang.Type_getNamedType(typedeffed_type)

				#partial switch elaborated_type.kind {
				case .Record:
					typedeffed_type_cursor = clang.getTypeDeclaration(typedeffed_type)
				}

			case .Pointer:
				typedeffed_type_cursor = clang.getTypeDeclaration(typedeffed_type)
			}

			fmt.println(typedeffed_type_cursor)

			// TODO: This won't work for pointers.
			if typedeffed_type_cursor.kind == clang.Cursor_Kind(0) || typedeffed_type_cursor.kind == .NoDeclFound {
				log.errorf("Unhandled typedef kind: %v (%v)", get_cursor_name(c), typedeffed_type_cursor.kind)
			}

			irt := IR_Typedef {
				new_cursor = c,
				original_type = typedeffed_type,
			}

			append(&ir.typedefs, irt)
		}
	}

	return ir
}