/*===-- clang-c/CXFile.h - C Index File ---------------------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides the interface to C Index files.                       *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/
package libclang

import "core:c"
import "core:c/libc"

_ :: c
_ :: libc

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

// LLVM_CLANG_C_CXFILE_H :: 

/**
* A particular source file that is part of a translation unit.
*/
File :: rawptr

/**
* Uniquely identifies a CXFile, that refers to the same underlying file,
* across an indexing session.
*/
File_Unique_Id :: struct {
	data: [3]c.ulonglong,
}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Retrieve the complete file and path name of the given file.
	*/
	getFileName :: proc(SFile: File) -> String ---

	/**
	* Retrieve the last modification time of the given file.
	*/
	getFileTime :: proc(SFile: File) -> libc.time_t ---

	/**
	* Retrieve the unique ID for the given \c file.
	*
	* \param file the file to get the ID for.
	* \param outID stores the returned CXFileUniqueID.
	* \returns If there was a failure getting the unique ID, returns non-zero,
	* otherwise returns 0.
	*/
	getFileUniqueID :: proc(file: File, outID: ^File_Unique_Id) -> c.int ---

	/**
	* Returns non-zero if the \c file1 and \c file2 point to the same file,
	* or they are both NULL.
	*/
	File_isEqual :: proc(file1: File, file2: File) -> c.int ---

	/**
	* Returns the real path name of \c file.
	*
	* An empty string may be returned. Use \c clang_getFileName() in that case.
	*/
	File_tryGetRealPathName :: proc(file: File) -> String ---
}
