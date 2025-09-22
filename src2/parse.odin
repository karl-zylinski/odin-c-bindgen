#+private file
package bindgen2

import clang "../libclang"
import "core:fmt"
import "base:runtime"
import "core:strings"

@(private="package")
parse :: proc(filename: string) -> IR {
	ir: IR
	
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
				name = get_cursor_name(c),
			}
			append(&ir.structs, irs)
		}
	}

	return ir
}

Cursor_Location :: struct {
	file: clang.File,
	offset: int,
	line: int,
	column: int,
}

get_cursor_location :: proc(cursor: clang.Cursor, file: ^clang.File = nil, offset: ^u32 = nil) -> Cursor_Location {
	file: clang.File
	offset: u32
	column: u32
	line: u32

	clang.getExpansionLocation(clang.getCursorLocation(cursor), &file, &line, &column, &offset)
	
	return {
		file = file,
		offset = int(offset),
		line = int(line),
		column = int(column),
	}
}

get_cursor_name :: proc(cursor: clang.Cursor) -> string {
	return string_from_clang_string(clang.getCursorSpelling(cursor))
}

string_from_clang_string :: proc(str: clang.String) -> string {
	ret := strings.clone_from_cstring(clang.getCString(str))
	clang.disposeString(str)
	return ret
}

get_cursor_children :: proc(cursor: clang.Cursor) -> []clang.Cursor {
	children: [dynamic]clang.Cursor
	clang.visitChildren(cursor, curstor_iterator_iterate, &children)

	curstor_iterator_iterate: clang.Cursor_Visitor : proc "c" (
		cursor, parent: clang.Cursor,
		state: clang.Client_Data,
	) -> clang.Child_Visit_Result {
		context = runtime.default_context()
		arr := (^[dynamic]clang.Cursor)(state)
		append(arr, cursor)
		return .Continue
	}

	return children[:]
}
