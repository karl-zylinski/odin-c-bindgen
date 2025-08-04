/*===-- clang-c/CXErrorCode.h - C Index Error Codes  --------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides the CXErrorCode enumerators.                          *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/
package libclang

import "core:c"

_ :: c

// LLVM_CLANG_C_CXERRORCODE_H :: 

/**
* Error codes returned by libclang routines.
*
* Zero (\c CXError_Success) is the only error code indicating success.  Other
* error codes, including not yet assigned non-zero values, indicate errors.
*/
Error_Code :: enum c.int {
	/**
	* No error.
	*/
	Success,

	/**
	* A generic error code, no further details are available.
	*
	* Errors of this kind can get their own specific error codes in future
	* libclang versions.
	*/
	Failure,

	/**
	* libclang crashed while performing the requested operation.
	*/
	Crashed,

	/**
	* The function detected that the arguments violate the function
	* contract.
	*/
	InvalidArguments,

	/**
	* An AST deserialization error has occurred.
	*/
	ASTReadError,
}

