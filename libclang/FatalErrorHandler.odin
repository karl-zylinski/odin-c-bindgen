/*===-- clang-c/FatalErrorHandler.h - Fatal Error Handling --------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/
package libclang



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

// LLVM_CLANG_C_FATAL_ERROR_HANDLER_H :: 

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Installs error handler that prints error message to stderr and calls abort().
	* Replaces currently installed error handler (if any).
	*/
	install_aborting_llvm_fatal_error_handler :: proc() ---

	/**
	* Removes currently installed error handler (if any).
	* If no error handler is intalled, the default strategy is to print error
	* message to stderr and call exit(1).
	*/
	uninstall_llvm_fatal_error_handler :: proc() ---
}
