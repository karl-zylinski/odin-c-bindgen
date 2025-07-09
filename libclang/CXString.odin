/*===-- clang-c/CXString.h - C Index strings  --------------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides the interface to C Index strings.                     *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/
package libclang

import "core:c"

_ :: c

when ODIN_OS == .Windows {
    @(extra_linker_flags="/NODEFAULTLIB:libcmt")
    foreign import lib {
        "system:ntdll.lib",
        "system:ucrt.lib",
        "system:msvcrt.lib",
        "system:legacy_stdio_definitions.lib",
        "system:kernel32.lib",
        "system:user32.lib",
        "system:advapi32.lib",
        "system:shell32.lib",
        "system:ole32.lib",
        "system:oleaut32.lib",
        "system:uuid.lib",
        "system:ws2_32.lib",
        "system:version.lib",
        "system:oldnames.lib",
        "libclang.lib",
	}
} else {
    foreign import lib "system:clang"
}

// LLVM_CLANG_C_CXSTRING_H :: 

/**
* A character string.
*
* The \c CXString type is used to return strings from the interface when
* the ownership of that string might differ from one call to the next.
* Use \c clang_getCString() to retrieve the string data and, once finished
* with the string data, call \c clang_disposeString() to free the string.
*/
String :: struct {
	data:          rawptr,
	private_flags: c.uint,
}

String_Set :: struct {
	Strings: ^String,
	Count:   c.uint,
}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Retrieve the character data associated with the given string.
	*
	* The returned data is a reference and not owned by the user. This data
	* is only valid while the `CXString` is valid. This function is similar
	* to `std::string::c_str()`.
	*/
	getCString :: proc(_string: String) -> cstring ---

	/**
	* Free the given string.
	*/
	disposeString :: proc(_string: String) ---

	/**
	* Free the given string set.
	*/
	disposeStringSet :: proc(set: ^String_Set) ---
}
