/*===-- clang-c/Rewrite.h - C CXRewriter   --------------------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*/
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

// LLVM_CLANG_C_REWRITE_H :: 

Rewriter :: rawptr

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Create CXRewriter.
	*/
	CXRewriter_create :: proc(TU: Translation_Unit) -> Rewriter ---

	/**
	* Insert the specified string at the specified location in the original buffer.
	*/
	CXRewriter_insertTextBefore :: proc(Rew: Rewriter, Loc: Source_Location, Insert: cstring) ---

	/**
	* Replace the specified range of characters in the input with the specified
	* replacement.
	*/
	CXRewriter_replaceText :: proc(Rew: Rewriter, ToBeReplaced: Source_Range, Replacement: cstring) ---

	/**
	* Remove the specified range.
	*/
	CXRewriter_removeText :: proc(Rew: Rewriter, ToBeRemoved: Source_Range) ---

	/**
	* Save all changed files to disk.
	* Returns 1 if any files were not saved successfully, returns 0 otherwise.
	*/
	CXRewriter_overwriteChangedFiles :: proc(Rew: Rewriter) -> c.int ---

	/**
	* Write out rewritten version of the main file to stdout.
	*/
	CXRewriter_writeMainFileToStdOut :: proc(Rew: Rewriter) ---

	/**
	* Free the given CXRewriter.
	*/
	CXRewriter_dispose :: proc(Rew: Rewriter) ---
}
