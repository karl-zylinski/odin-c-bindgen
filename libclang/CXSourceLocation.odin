/*===-- clang-c/CXSourceLocation.h - C Index Source Location ------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides the interface to C Index source locations.            *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/
package libclang

import "core:c"

_ :: c

when ODIN_OS == .Windows {
    foreign import lib "system:libclang.lib"
} else {
    foreign import lib "system:clang"
}

/**
* Identifies a specific source location within a translation
* unit.
*
* Use clang_getExpansionLocation() or clang_getSpellingLocation()
* to map a source location to a particular file, line, and column.
*/
Source_Location :: struct {
	ptr_data: [2]rawptr,
	int_data: c.uint,
}

/**
* Identifies a half-open character range in the source code.
*
* Use clang_getRangeStart() and clang_getRangeEnd() to retrieve the
* starting and end locations from a source range, respectively.
*/
Source_Range :: struct {
	ptr_data:       [2]rawptr,
	begin_int_data: c.uint,
	end_int_data:   c.uint,
}

/**
* Identifies an array of ranges.
*/
Source_Range_List :: struct {
	/** The number of ranges in the \c ranges array. */
	count: c.uint,

	/**
	* An array of \c CXSourceRanges.
	*/
	ranges: ^Source_Range,
}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Retrieve a NULL (invalid) source location.
	*/
	getNullLocation :: proc() -> Source_Location ---

	/**
	* Determine whether two source locations, which must refer into
	* the same translation unit, refer to exactly the same point in the source
	* code.
	*
	* \returns non-zero if the source locations refer to the same location, zero
	* if they refer to different locations.
	*/
	equalLocations :: proc(loc1: Source_Location, loc2: Source_Location) -> c.uint ---

	/**
	* Determine for two source locations if the first comes
	* strictly before the second one in the source code.
	*
	* \returns non-zero if the first source location comes
	* strictly before the second one, zero otherwise.
	*/
	isBeforeInTranslationUnit :: proc(loc1: Source_Location, loc2: Source_Location) -> c.uint ---

	/**
	* Returns non-zero if the given source location is in a system header.
	*/
	Location_isInSystemHeader :: proc(location: Source_Location) -> c.int ---

	/**
	* Returns non-zero if the given source location is in the main file of
	* the corresponding translation unit.
	*/
	Location_isFromMainFile :: proc(location: Source_Location) -> c.int ---

	/**
	* Retrieve a NULL (invalid) source range.
	*/
	getNullRange :: proc() -> Source_Range ---

	/**
	* Retrieve a source range given the beginning and ending source
	* locations.
	*/
	getRange :: proc(begin: Source_Location, end: Source_Location) -> Source_Range ---

	/**
	* Determine whether two ranges are equivalent.
	*
	* \returns non-zero if the ranges are the same, zero if they differ.
	*/
	equalRanges :: proc(range1: Source_Range, range2: Source_Range) -> c.uint ---

	/**
	* Returns non-zero if \p range is null.
	*/
	Range_isNull :: proc(range: Source_Range) -> c.int ---

	/**
	* Retrieve the file, line, column, and offset represented by
	* the given source location.
	*
	* If the location refers into a macro expansion, retrieves the
	* location of the macro expansion.
	*
	* \param location the location within a source file that will be decomposed
	* into its parts.
	*
	* \param file [out] if non-NULL, will be set to the file to which the given
	* source location points.
	*
	* \param line [out] if non-NULL, will be set to the line to which the given
	* source location points.
	*
	* \param column [out] if non-NULL, will be set to the column to which the given
	* source location points.
	*
	* \param offset [out] if non-NULL, will be set to the offset into the
	* buffer to which the given source location points.
	*/
	getExpansionLocation :: proc(location: Source_Location, file: ^File, line: ^c.uint, column: ^c.uint, offset: ^c.uint) ---

	/**
	* Retrieve the file, line and column represented by the given source
	* location, as specified in a # line directive.
	*
	* Example: given the following source code in a file somefile.c
	*
	* \code
	* #123 "dummy.c" 1
	*
	* static int func(void)
	* {
	*     return 0;
	* }
	* \endcode
	*
	* the location information returned by this function would be
	*
	* File: dummy.c Line: 124 Column: 12
	*
	* whereas clang_getExpansionLocation would have returned
	*
	* File: somefile.c Line: 3 Column: 12
	*
	* \param location the location within a source file that will be decomposed
	* into its parts.
	*
	* \param filename [out] if non-NULL, will be set to the filename of the
	* source location. Note that filenames returned will be for "virtual" files,
	* which don't necessarily exist on the machine running clang - e.g. when
	* parsing preprocessed output obtained from a different environment. If
	* a non-NULL value is passed in, remember to dispose of the returned value
	* using \c clang_disposeString() once you've finished with it. For an invalid
	* source location, an empty string is returned.
	*
	* \param line [out] if non-NULL, will be set to the line number of the
	* source location. For an invalid source location, zero is returned.
	*
	* \param column [out] if non-NULL, will be set to the column number of the
	* source location. For an invalid source location, zero is returned.
	*/
	getPresumedLocation :: proc(location: Source_Location, filename: ^String, line: ^c.uint, column: ^c.uint) ---

	/**
	* Legacy API to retrieve the file, line, column, and offset represented
	* by the given source location.
	*
	* This interface has been replaced by the newer interface
	* #clang_getExpansionLocation(). See that interface's documentation for
	* details.
	*/
	getInstantiationLocation :: proc(location: Source_Location, file: ^File, line: ^c.uint, column: ^c.uint, offset: ^c.uint) ---

	/**
	* Retrieve the file, line, column, and offset represented by
	* the given source location.
	*
	* If the location refers into a macro instantiation, return where the
	* location was originally spelled in the source file.
	*
	* \param location the location within a source file that will be decomposed
	* into its parts.
	*
	* \param file [out] if non-NULL, will be set to the file to which the given
	* source location points.
	*
	* \param line [out] if non-NULL, will be set to the line to which the given
	* source location points.
	*
	* \param column [out] if non-NULL, will be set to the column to which the given
	* source location points.
	*
	* \param offset [out] if non-NULL, will be set to the offset into the
	* buffer to which the given source location points.
	*/
	getSpellingLocation :: proc(location: Source_Location, file: ^File, line: ^c.uint, column: ^c.uint, offset: ^c.uint) ---

	/**
	* Retrieve the file, line, column, and offset represented by
	* the given source location.
	*
	* If the location refers into a macro expansion, return where the macro was
	* expanded or where the macro argument was written, if the location points at
	* a macro argument.
	*
	* \param location the location within a source file that will be decomposed
	* into its parts.
	*
	* \param file [out] if non-NULL, will be set to the file to which the given
	* source location points.
	*
	* \param line [out] if non-NULL, will be set to the line to which the given
	* source location points.
	*
	* \param column [out] if non-NULL, will be set to the column to which the given
	* source location points.
	*
	* \param offset [out] if non-NULL, will be set to the offset into the
	* buffer to which the given source location points.
	*/
	getFileLocation :: proc(location: Source_Location, file: ^File, line: ^c.uint, column: ^c.uint, offset: ^c.uint) ---

	/**
	* Retrieve a source location representing the first character within a
	* source range.
	*/
	getRangeStart :: proc(range: Source_Range) -> Source_Location ---

	/**
	* Retrieve a source location representing the last character within a
	* source range.
	*/
	getRangeEnd :: proc(range: Source_Range) -> Source_Location ---

	/**
	* Destroy the given \c CXSourceRangeList.
	*/
	disposeSourceRangeList :: proc(ranges: ^Source_Range_List) ---
}
