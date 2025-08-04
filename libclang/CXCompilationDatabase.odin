/*===-- clang-c/CXCompilationDatabase.h - Compilation database  ---*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides a public interface to use CompilationDatabase without *|
|* the full Clang C++ API.                                                    *|
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

// LLVM_CLANG_C_CXCOMPILATIONDATABASE_H :: 

/**
* A compilation database holds all information used to compile files in a
* project. For each file in the database, it can be queried for the working
* directory or the command line used for the compiler invocation.
*
* Must be freed by \c clang_CompilationDatabase_dispose
*/
Compilation_Database :: rawptr

/**
* Contains the results of a search in the compilation database
*
* When searching for the compile command for a file, the compilation db can
* return several commands, as the file may have been compiled with
* different options in different places of the project. This choice of compile
* commands is wrapped in this opaque data structure. It must be freed by
* \c clang_CompileCommands_dispose.
*/
Compile_Commands :: rawptr

/**
* Represents the command line invocation to compile a specific file.
*/
Compile_Command :: rawptr

/**
* Error codes for Compilation Database
*/
Compilation_Database_Error :: enum c.int {
	/*
	* No error occurred
	*/
	NoError,

	/*
	* Database can not be loaded
	*/
	CanNotLoadDatabase,
}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Creates a compilation database from the database found in directory
	* buildDir. For example, CMake can output a compile_commands.json which can
	* be used to build the database.
	*
	* It must be freed by \c clang_CompilationDatabase_dispose.
	*/
	CompilationDatabase_fromDirectory :: proc(BuildDir: cstring, ErrorCode: ^Compilation_Database_Error) -> Compilation_Database ---

	/**
	* Free the given compilation database
	*/
	CompilationDatabase_dispose :: proc(_: Compilation_Database) ---

	/**
	* Find the compile commands used for a file. The compile commands
	* must be freed by \c clang_CompileCommands_dispose.
	*/
	CompilationDatabase_getCompileCommands :: proc(_: Compilation_Database, CompleteFileName: cstring) -> Compile_Commands ---

	/**
	* Get all the compile commands in the given compilation database.
	*/
	CompilationDatabase_getAllCompileCommands :: proc(_: Compilation_Database) -> Compile_Commands ---

	/**
	* Free the given CompileCommands
	*/
	CompileCommands_dispose :: proc(_: Compile_Commands) ---

	/**
	* Get the number of CompileCommand we have for a file
	*/
	CompileCommands_getSize :: proc(_: Compile_Commands) -> c.uint ---

	/**
	* Get the I'th CompileCommand for a file
	*
	* Note : 0 <= i < clang_CompileCommands_getSize(CXCompileCommands)
	*/
	CompileCommands_getCommand :: proc(_: Compile_Commands, I: c.uint) -> Compile_Command ---

	/**
	* Get the working directory where the CompileCommand was executed from
	*/
	CompileCommand_getDirectory :: proc(_: Compile_Command) -> String ---

	/**
	* Get the filename associated with the CompileCommand.
	*/
	CompileCommand_getFilename :: proc(_: Compile_Command) -> String ---

	/**
	* Get the number of arguments in the compiler invocation.
	*
	*/
	CompileCommand_getNumArgs :: proc(_: Compile_Command) -> c.uint ---

	/**
	* Get the I'th argument value in the compiler invocations
	*
	* Invariant :
	*  - argument 0 is the compiler executable
	*/
	CompileCommand_getArg :: proc(_: Compile_Command, I: c.uint) -> String ---

	/**
	* Get the number of source mappings for the compiler invocation.
	*/
	CompileCommand_getNumMappedSources :: proc(_: Compile_Command) -> c.uint ---

	/**
	* Get the I'th mapped source path for the compiler invocation.
	*/
	CompileCommand_getMappedSourcePath :: proc(_: Compile_Command, I: c.uint) -> String ---

	/**
	* Get the I'th mapped source content for the compiler invocation.
	*/
	CompileCommand_getMappedSourceContent :: proc(_: Compile_Command, I: c.uint) -> String ---
}
