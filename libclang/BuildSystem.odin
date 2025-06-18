/*==-- clang-c/BuildSystem.h - Utilities for use by build systems -*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides various utilities for use by build systems.           *|
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
* Object encapsulating information about overlaying virtual
* file/directories over the real file system.
*/
Virtual_File_Overlay :: struct {}

/**
* Object encapsulating information about a module.modulemap file.
*/
Module_Map_Descriptor :: struct {}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Return the timestamp for use with Clang's
	* \c -fbuild-session-timestamp= option.
	*/
	getBuildSessionTimestamp :: proc() -> c.ulonglong ---

	/**
	* Create a \c CXVirtualFileOverlay object.
	* Must be disposed with \c clang_VirtualFileOverlay_dispose().
	*
	* \param options is reserved, always pass 0.
	*/
	VirtualFileOverlay_create :: proc(options: c.uint) -> Virtual_File_Overlay ---

	/**
	* Map an absolute virtual file path to an absolute real one.
	* The virtual path must be canonicalized (not contain "."/"..").
	* \returns 0 for success, non-zero to indicate an error.
	*/
	VirtualFileOverlay_addFileMapping :: proc(_: Virtual_File_Overlay, virtualPath: cstring, realPath: cstring) -> Error_Code ---

	/**
	* Set the case sensitivity for the \c CXVirtualFileOverlay object.
	* The \c CXVirtualFileOverlay object is case-sensitive by default, this
	* option can be used to override the default.
	* \returns 0 for success, non-zero to indicate an error.
	*/
	VirtualFileOverlay_setCaseSensitivity :: proc(_: Virtual_File_Overlay, caseSensitive: c.int) -> Error_Code ---

	/**
	* Write out the \c CXVirtualFileOverlay object to a char buffer.
	*
	* \param options is reserved, always pass 0.
	* \param out_buffer_ptr pointer to receive the buffer pointer, which should be
	* disposed using \c clang_free().
	* \param out_buffer_size pointer to receive the buffer size.
	* \returns 0 for success, non-zero to indicate an error.
	*/
	VirtualFileOverlay_writeToBuffer :: proc(_: Virtual_File_Overlay, options: c.uint, out_buffer_ptr: ^^c.char, out_buffer_size: ^c.uint) -> Error_Code ---

	/**
	* free memory allocated by libclang, such as the buffer returned by
	* \c CXVirtualFileOverlay() or \c clang_ModuleMapDescriptor_writeToBuffer().
	*
	* \param buffer memory pointer to free.
	*/
	free :: proc(buffer: rawptr) ---

	/**
	* Dispose a \c CXVirtualFileOverlay object.
	*/
	VirtualFileOverlay_dispose :: proc(_: Virtual_File_Overlay) ---

	/**
	* Create a \c CXModuleMapDescriptor object.
	* Must be disposed with \c clang_ModuleMapDescriptor_dispose().
	*
	* \param options is reserved, always pass 0.
	*/
	ModuleMapDescriptor_create :: proc(options: c.uint) -> Module_Map_Descriptor ---

	/**
	* Sets the framework module name that the module.modulemap describes.
	* \returns 0 for success, non-zero to indicate an error.
	*/
	ModuleMapDescriptor_setFrameworkModuleName :: proc(_: Module_Map_Descriptor, name: cstring) -> Error_Code ---

	/**
	* Sets the umbrella header name that the module.modulemap describes.
	* \returns 0 for success, non-zero to indicate an error.
	*/
	ModuleMapDescriptor_setUmbrellaHeader :: proc(_: Module_Map_Descriptor, name: cstring) -> Error_Code ---

	/**
	* Write out the \c CXModuleMapDescriptor object to a char buffer.
	*
	* \param options is reserved, always pass 0.
	* \param out_buffer_ptr pointer to receive the buffer pointer, which should be
	* disposed using \c clang_free().
	* \param out_buffer_size pointer to receive the buffer size.
	* \returns 0 for success, non-zero to indicate an error.
	*/
	ModuleMapDescriptor_writeToBuffer :: proc(_: Module_Map_Descriptor, options: c.uint, out_buffer_ptr: ^^c.char, out_buffer_size: ^c.uint) -> Error_Code ---

	/**
	* Dispose a \c CXModuleMapDescriptor object.
	*/
	ModuleMapDescriptor_dispose :: proc(_: Module_Map_Descriptor) ---
}
