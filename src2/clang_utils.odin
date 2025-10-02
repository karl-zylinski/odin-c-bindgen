package bindgen2

import clang "../libclang"
import "core:strings"
import "base:runtime"

get_cursor_name :: proc(cursor: clang.Cursor) -> string {
	return string_from_clang_string(clang.getCursorSpelling(cursor))
}

get_type_name :: proc(type: clang.Type) -> string {
	return string_from_clang_string(clang.getTypeSpelling(type))
}

string_from_clang_string :: proc(str: clang.String) -> string {
	ret := strings.clone_from_cstring(clang.getCString(str))
	clang.disposeString(str)
	return ret
}

Location :: struct {
	file: clang.File,
	offset: int,
	line: int,
	column: int,
}

get_cursor_location :: proc(cursor: clang.Cursor) -> Location {
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

get_comment_location :: proc(cursor: clang.Cursor) -> Location {
	file: clang.File
	offset: u32
	column: u32
	line: u32

	clang.getExpansionLocation(clang.getRangeStart(clang.Cursor_getCommentRange(cursor)), &file, &line, &column, &offset)
	
	return {
		file = file,
		offset = int(offset),
		line = int(line),
		column = int(column),
	}
}