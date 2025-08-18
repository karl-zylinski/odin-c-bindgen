/*===-- clang-c/CXDiagnostic.h - C Index Diagnostics --------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides the interface to C Index diagnostics.                 *|
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

// LLVM_CLANG_C_CXDIAGNOSTIC_H :: 

/**
* Describes the severity of a particular diagnostic.
*/
Diagnostic_Severity :: enum c.int {
	/**
	* A diagnostic that has been suppressed, e.g., by a command-line
	* option.
	*/
	Ignored,

	/**
	* This diagnostic is a note that should be attached to the
	* previous (non-note) diagnostic.
	*/
	Note,

	/**
	* This diagnostic indicates suspicious code that may not be
	* wrong.
	*/
	Warning,

	/**
	* This diagnostic indicates that the code is ill-formed.
	*/
	Error,

	/**
	* This diagnostic indicates that the code is ill-formed such
	* that future parser recovery is unlikely to produce useful
	* results.
	*/
	Fatal,
}

/**
* A single diagnostic, containing the diagnostic's severity,
* location, text, source ranges, and fix-it hints.
*/
Diagnostic :: rawptr

/**
* A group of CXDiagnostics.
*/
Diagnostic_Set :: rawptr

/**
* Describes the kind of error that occurred (if any) in a call to
* \c clang_loadDiagnostics.
*/
Load_Diag_Error :: enum c.int {
	/**
	* Indicates that no error occurred.
	*/
	None,

	/**
	* Indicates that an unknown error occurred while attempting to
	* deserialize diagnostics.
	*/
	Unknown,

	/**
	* Indicates that the file containing the serialized diagnostics
	* could not be opened.
	*/
	CannotLoad,

	/**
	* Indicates that the serialized diagnostics file is invalid or
	* corrupt.
	*/
	InvalidFile,
}

/**
* Options to control the display of diagnostics.
*
* The values in this enum are meant to be combined to customize the
* behavior of \c clang_formatDiagnostic().
*/
Diagnostic_Display_Options :: enum c.int {
	/**
	* Display the source-location information where the
	* diagnostic was located.
	*
	* When set, diagnostics will be prefixed by the file, line, and
	* (optionally) column to which the diagnostic refers. For example,
	*
	* \code
	* test.c:28: warning: extra tokens at end of #endif directive
	* \endcode
	*
	* This option corresponds to the clang flag \c -fshow-source-location.
	*/
	SourceLocation = 1,

	/**
	* If displaying the source-location information of the
	* diagnostic, also include the column number.
	*
	* This option corresponds to the clang flag \c -fshow-column.
	*/
	Column = 2,

	/**
	* If displaying the source-location information of the
	* diagnostic, also include information about source ranges in a
	* machine-parsable format.
	*
	* This option corresponds to the clang flag
	* \c -fdiagnostics-print-source-range-info.
	*/
	SourceRanges = 4,

	/**
	* Display the option name associated with this diagnostic, if any.
	*
	* The option name displayed (e.g., -Wconversion) will be placed in brackets
	* after the diagnostic text. This option corresponds to the clang flag
	* \c -fdiagnostics-show-option.
	*/
	Option = 8,

	/**
	* Display the category number associated with this diagnostic, if any.
	*
	* The category number is displayed within brackets after the diagnostic text.
	* This option corresponds to the clang flag
	* \c -fdiagnostics-show-category=id.
	*/
	CategoryId = 16,

	/**
	* Display the category name associated with this diagnostic, if any.
	*
	* The category name is displayed within brackets after the diagnostic text.
	* This option corresponds to the clang flag
	* \c -fdiagnostics-show-category=name.
	*/
	CategoryName = 32,
}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Determine the number of diagnostics in a CXDiagnosticSet.
	*/
	getNumDiagnosticsInSet :: proc(Diags: Diagnostic_Set) -> c.uint ---

	/**
	* Retrieve a diagnostic associated with the given CXDiagnosticSet.
	*
	* \param Diags the CXDiagnosticSet to query.
	* \param Index the zero-based diagnostic number to retrieve.
	*
	* \returns the requested diagnostic. This diagnostic must be freed
	* via a call to \c clang_disposeDiagnostic().
	*/
	getDiagnosticInSet :: proc(Diags: Diagnostic_Set, Index: c.uint) -> Diagnostic ---

	/**
	* Deserialize a set of diagnostics from a Clang diagnostics bitcode
	* file.
	*
	* \param file The name of the file to deserialize.
	* \param error A pointer to a enum value recording if there was a problem
	*        deserializing the diagnostics.
	* \param errorString A pointer to a CXString for recording the error string
	*        if the file was not successfully loaded.
	*
	* \returns A loaded CXDiagnosticSet if successful, and NULL otherwise.  These
	* diagnostics should be released using clang_disposeDiagnosticSet().
	*/
	loadDiagnostics :: proc(file: cstring, error: ^Load_Diag_Error, errorString: ^String) -> Diagnostic_Set ---

	/**
	* Release a CXDiagnosticSet and all of its contained diagnostics.
	*/
	disposeDiagnosticSet :: proc(Diags: Diagnostic_Set) ---

	/**
	* Retrieve the child diagnostics of a CXDiagnostic.
	*
	* This CXDiagnosticSet does not need to be released by
	* clang_disposeDiagnosticSet.
	*/
	getChildDiagnostics :: proc(D: Diagnostic) -> Diagnostic_Set ---

	/**
	* Destroy a diagnostic.
	*/
	disposeDiagnostic :: proc(Diagnostic: Diagnostic) ---

	/**
	* Format the given diagnostic in a manner that is suitable for display.
	*
	* This routine will format the given diagnostic to a string, rendering
	* the diagnostic according to the various options given. The
	* \c clang_defaultDiagnosticDisplayOptions() function returns the set of
	* options that most closely mimics the behavior of the clang compiler.
	*
	* \param Diagnostic The diagnostic to print.
	*
	* \param Options A set of options that control the diagnostic display,
	* created by combining \c CXDiagnosticDisplayOptions values.
	*
	* \returns A new string containing for formatted diagnostic.
	*/
	formatDiagnostic :: proc(Diagnostic: Diagnostic, Options: c.uint) -> String ---

	/**
	* Retrieve the set of display options most similar to the
	* default behavior of the clang compiler.
	*
	* \returns A set of display options suitable for use with \c
	* clang_formatDiagnostic().
	*/
	defaultDiagnosticDisplayOptions :: proc() -> c.uint ---

	/**
	* Determine the severity of the given diagnostic.
	*/
	getDiagnosticSeverity :: proc(_: Diagnostic) -> Diagnostic_Severity ---

	/**
	* Retrieve the source location of the given diagnostic.
	*
	* This location is where Clang would print the caret ('^') when
	* displaying the diagnostic on the command line.
	*/
	getDiagnosticLocation :: proc(_: Diagnostic) -> Source_Location ---

	/**
	* Retrieve the text of the given diagnostic.
	*/
	getDiagnosticSpelling :: proc(_: Diagnostic) -> String ---

	/**
	* Retrieve the name of the command-line option that enabled this
	* diagnostic.
	*
	* \param Diag The diagnostic to be queried.
	*
	* \param Disable If non-NULL, will be set to the option that disables this
	* diagnostic (if any).
	*
	* \returns A string that contains the command-line option used to enable this
	* warning, such as "-Wconversion" or "-pedantic".
	*/
	getDiagnosticOption :: proc(Diag: Diagnostic, Disable: ^String) -> String ---

	/**
	* Retrieve the category number for this diagnostic.
	*
	* Diagnostics can be categorized into groups along with other, related
	* diagnostics (e.g., diagnostics under the same warning flag). This routine
	* retrieves the category number for the given diagnostic.
	*
	* \returns The number of the category that contains this diagnostic, or zero
	* if this diagnostic is uncategorized.
	*/
	getDiagnosticCategory :: proc(_: Diagnostic) -> c.uint ---

	/**
	* Retrieve the name of a particular diagnostic category.  This
	*  is now deprecated.  Use clang_getDiagnosticCategoryText()
	*  instead.
	*
	* \param Category A diagnostic category number, as returned by
	* \c clang_getDiagnosticCategory().
	*
	* \returns The name of the given diagnostic category.
	*/
	getDiagnosticCategoryName :: proc(Category: c.uint) -> String ---

	/**
	* Retrieve the diagnostic category text for a given diagnostic.
	*
	* \returns The text of the given diagnostic category.
	*/
	getDiagnosticCategoryText :: proc(_: Diagnostic) -> String ---

	/**
	* Determine the number of source ranges associated with the given
	* diagnostic.
	*/
	getDiagnosticNumRanges :: proc(_: Diagnostic) -> c.uint ---

	/**
	* Retrieve a source range associated with the diagnostic.
	*
	* A diagnostic's source ranges highlight important elements in the source
	* code. On the command line, Clang displays source ranges by
	* underlining them with '~' characters.
	*
	* \param Diagnostic the diagnostic whose range is being extracted.
	*
	* \param Range the zero-based index specifying which range to
	*
	* \returns the requested source range.
	*/
	getDiagnosticRange :: proc(Diagnostic: Diagnostic, Range: c.uint) -> Source_Range ---

	/**
	* Determine the number of fix-it hints associated with the
	* given diagnostic.
	*/
	getDiagnosticNumFixIts :: proc(Diagnostic: Diagnostic) -> c.uint ---

	/**
	* Retrieve the replacement information for a given fix-it.
	*
	* Fix-its are described in terms of a source range whose contents
	* should be replaced by a string. This approach generalizes over
	* three kinds of operations: removal of source code (the range covers
	* the code to be removed and the replacement string is empty),
	* replacement of source code (the range covers the code to be
	* replaced and the replacement string provides the new code), and
	* insertion (both the start and end of the range point at the
	* insertion location, and the replacement string provides the text to
	* insert).
	*
	* \param Diagnostic The diagnostic whose fix-its are being queried.
	*
	* \param FixIt The zero-based index of the fix-it.
	*
	* \param ReplacementRange The source range whose contents will be
	* replaced with the returned replacement string. Note that source
	* ranges are half-open ranges [a, b), so the source code should be
	* replaced from a and up to (but not including) b.
	*
	* \returns A string containing text that should be replace the source
	* code indicated by the \c ReplacementRange.
	*/
	getDiagnosticFixIt :: proc(Diagnostic: Diagnostic, FixIt: c.uint, ReplacementRange: ^Source_Range) -> String ---
}
