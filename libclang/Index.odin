/*===-- clang-c/Index.h - Indexing Public C Interface -------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides a public interface to a Clang library for extracting  *|
|* high-level symbol information from source files without exposing the full  *|
|* Clang C++ API.                                                             *|
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
 * The version constants for the libclang API.
 * CINDEX_VERSION_MINOR should increase when there are API additions.
 * CINDEX_VERSION_MAJOR is intended for "major" source/ABI breaking changes.
 *
 * The policy about the libclang API was always to keep it source and ABI
 * compatible, thus CINDEX_VERSION_MAJOR is expected to remain stable.
 */
CINDEX_VERSION_MAJOR :: 0
CINDEX_VERSION_MINOR :: 64

CINDEX_VERSION :: ((CINDEX_VERSION_MAJOR)*10000) + ((CINDEX_VERSION_MINOR)*1)

// CINDEX_VERSION_STRING :: #CINDEX_VERSION_MAJOR "." #CINDEX_VERSION_MINOR

/**
* An "index" that consists of a set of translation units that would
* typically be linked together into an executable or library.
*/
Index :: rawptr

/**
* An opaque type representing target information for a given translation
* unit.
*/
Target_Info :: struct {}

/**
* A single translation unit, which resides in an index.
*/
Translation_Unit :: struct {}

/**
* Opaque pointer representing client data that will be passed through
* to various callbacks and visitors.
*/
Client_Data :: rawptr

/**
* Provides the contents of a file that has not yet been saved to disk.
*
* Each CXUnsavedFile instance provides the name of a file on the
* system along with the current contents of that file that have not
* yet been saved to disk.
*/
Unsaved_File :: struct {
	/**
	* The file whose contents have not yet been saved.
	*
	* This file must already exist in the file system.
	*/
	Filename: cstring,

	/**
	* A buffer containing the unsaved contents of this file.
	*/
	Contents: cstring,

	/**
	* The length of the unsaved contents of this buffer.
	*/
	Length: c.ulong,
}

/**
* Describes the availability of a particular entity, which indicates
* whether the use of this entity will result in a warning or error due to
* it being deprecated or unavailable.
*/
Availability_Kind :: enum c.int {
	/**
	* The entity is available.
	*/
	Available,

	/**
	* The entity is available, but has been deprecated (and its use is
	* not recommended).
	*/
	Deprecated,

	/**
	* The entity is not available; any use of it will be an error.
	*/
	NotAvailable,

	/**
	* The entity is available, but not accessible; any use of it will be
	* an error.
	*/
	NotAccessible,
}

/**
* Describes a version number of the form major.minor.subminor.
*/
Version :: struct {
	/**
	* The major version number, e.g., the '10' in '10.7.3'. A negative
	* value indicates that there is no version number at all.
	*/
	Major: c.int,

	/**
	* The minor version number, e.g., the '7' in '10.7.3'. This value
	* will be negative if no minor version number was provided, e.g., for
	* version '10'.
	*/
	Minor: c.int,

	/**
	* The subminor version number, e.g., the '3' in '10.7.3'. This value
	* will be negative if no minor or subminor version number was provided,
	* e.g., in version '10' or '10.7'.
	*/
	Subminor: c.int,
}

/**
* Describes the exception specification of a cursor.
*
* A negative value indicates that the cursor is not a function declaration.
*/
Cursor_Exception_Specification_Kind :: enum c.int {
	/**
	* The cursor has no exception specification.
	*/
	None,

	/**
	* The cursor has exception specification throw()
	*/
	DynamicNone,

	/**
	* The cursor has exception specification throw(T1, T2)
	*/
	Dynamic,

	/**
	* The cursor has exception specification throw(...).
	*/
	MSAny,

	/**
	* The cursor has exception specification basic noexcept.
	*/
	BasicNoexcept,

	/**
	* The cursor has exception specification computed noexcept.
	*/
	ComputedNoexcept,

	/**
	* The exception specification has not yet been evaluated.
	*/
	Unevaluated,

	/**
	* The exception specification has not yet been instantiated.
	*/
	Uninstantiated,

	/**
	* The exception specification has not been parsed yet.
	*/
	Unparsed,

	/**
	* The cursor has a __declspec(nothrow) exception specification.
	*/
	NoThrow,
}

Choice :: enum c.int {
	/**
	* Use the default value of an option that may depend on the process
	* environment.
	*/
	Default = 0,

	/**
	* Enable the option.
	*/
	Enabled = 1,

	/**
	* Disable the option.
	*/
	Disabled = 2,
}

Global_Opt_Flags :: enum c.int {
	/**
	* Used to indicate that no special CXIndex options are needed.
	*/
	None = 0,

	/**
	* Used to indicate that threads that libclang creates for indexing
	* purposes should use background priority.
	*
	* Affects #clang_indexSourceFile, #clang_indexTranslationUnit,
	* #clang_parseTranslationUnit, #clang_saveTranslationUnit.
	*/
	ThreadBackgroundPriorityForIndexing = 1,

	/**
	* Used to indicate that threads that libclang creates for editing
	* purposes should use background priority.
	*
	* Affects #clang_reparseTranslationUnit, #clang_codeCompleteAt,
	* #clang_annotateTokens
	*/
	ThreadBackgroundPriorityForEditing = 2,

	/**
	* Used to indicate that all threads that libclang creates should use
	* background priority.
	*/
	ThreadBackgroundPriorityForAll = 3,
}

/**
* Index initialization options.
*
* 0 is the default value of each member of this struct except for Size.
* Initialize the struct in one of the following three ways to avoid adapting
* code each time a new member is added to it:
* \code
* CXIndexOptions Opts;
* memset(&Opts, 0, sizeof(Opts));
* Opts.Size = sizeof(CXIndexOptions);
* \endcode
* or explicitly initialize the first data member and zero-initialize the rest:
* \code
* CXIndexOptions Opts = { sizeof(CXIndexOptions) };
* \endcode
* or to prevent the -Wmissing-field-initializers warning for the above version:
* \code
* CXIndexOptions Opts{};
* Opts.Size = sizeof(CXIndexOptions);
* \endcode
*/
Index_Options :: struct {
	/**
	* The size of struct CXIndexOptions used for option versioning.
	*
	* Always initialize this member to sizeof(CXIndexOptions), or assign
	* sizeof(CXIndexOptions) to it right after creating a CXIndexOptions object.
	*/
	Size: c.uint,

	/**
	* A CXChoice enumerator that specifies the indexing priority policy.
	* \sa CXGlobalOpt_ThreadBackgroundPriorityForIndexing
	*/
	ThreadBackgroundPriorityForIndexing: c.uchar,

	/**
	* A CXChoice enumerator that specifies the editing priority policy.
	* \sa CXGlobalOpt_ThreadBackgroundPriorityForEditing
	*/
	ThreadBackgroundPriorityForEditing: c.uchar,

	/**
	* \see clang_createIndex()
	*/
	using _: bit_field u16 {
		ExcludeDeclarationsFromPCH: u16 | 1,
		DisplayDiagnostics:         u16 | 1,
		StorePreamblesInMemory:     u16 | 1,
		_:                          u16 | 13, /*Reserved*/
	},

	/**
	* The path to a directory, in which to store temporary PCH files. If null or
	* empty, the default system temporary directory is used. These PCH files are
	* deleted on clean exit but stay on disk if the program crashes or is killed.
	*
	* This option is ignored if \a StorePreamblesInMemory is non-zero.
	*
	* Libclang does not create the directory at the specified path in the file
	* system. Therefore it must exist, or storing PCH files will fail.
	*/
	PreambleStoragePath: cstring,

	/**
	* Specifies a path which will contain log files for certain libclang
	* invocations. A null value implies that libclang invocations are not logged.
	*/
	InvocationEmissionPath: cstring,
}

/**
* Flags that control the creation of translation units.
*
* The enumerators in this enumeration type are meant to be bitwise
* ORed together to specify which options should be used when
* constructing the translation unit.
*/
Translation_Unit_Flag :: enum c.int {
	/**
	* Used to indicate that the parser should construct a "detailed"
	* preprocessing record, including all macro definitions and instantiations.
	*
	* Constructing a detailed preprocessing record requires more memory
	* and time to parse, since the information contained in the record
	* is usually not retained. However, it can be useful for
	* applications that require more detailed information about the
	* behavior of the preprocessor.
	*/
	DetailedPreprocessingRecord = 0,

	/**
	* Used to indicate that the translation unit is incomplete.
	*
	* When a translation unit is considered "incomplete", semantic
	* analysis that is typically performed at the end of the
	* translation unit will be suppressed. For example, this suppresses
	* the completion of tentative declarations in C and of
	* instantiation of implicitly-instantiation function templates in
	* C++. This option is typically used when parsing a header with the
	* intent of producing a precompiled header.
	*/
	Incomplete = 1,

	/**
	* Used to indicate that the translation unit should be built with an
	* implicit precompiled header for the preamble.
	*
	* An implicit precompiled header is used as an optimization when a
	* particular translation unit is likely to be reparsed many times
	* when the sources aren't changing that often. In this case, an
	* implicit precompiled header will be built containing all of the
	* initial includes at the top of the main file (what we refer to as
	* the "preamble" of the file). In subsequent parses, if the
	* preamble or the files in it have not changed, \c
	* clang_reparseTranslationUnit() will re-use the implicit
	* precompiled header to improve parsing performance.
	*/
	PrecompiledPreamble = 2,

	/**
	* Used to indicate that the translation unit should cache some
	* code-completion results with each reparse of the source file.
	*
	* Caching of code-completion results is a performance optimization that
	* introduces some overhead to reparsing but improves the performance of
	* code-completion operations.
	*/
	CacheCompletionResults = 3,

	/**
	* Used to indicate that the translation unit will be serialized with
	* \c clang_saveTranslationUnit.
	*
	* This option is typically used when parsing a header with the intent of
	* producing a precompiled header.
	*/
	ForSerialization = 4,

	/**
	* DEPRECATED: Enabled chained precompiled preambles in C++.
	*
	* Note: this is a *temporary* option that is available only while
	* we are testing C++ precompiled preamble support. It is deprecated.
	*/
	CXXChainedPCH = 5,

	/**
	* Used to indicate that function/method bodies should be skipped while
	* parsing.
	*
	* This option can be used to search for declarations/definitions while
	* ignoring the usages.
	*/
	SkipFunctionBodies = 6,

	/**
	* Used to indicate that brief documentation comments should be
	* included into the set of code completions returned from this translation
	* unit.
	*/
	IncludeBriefCommentsInCodeCompletion = 7,

	/**
	* Used to indicate that the precompiled preamble should be created on
	* the first parse. Otherwise it will be created on the first reparse. This
	* trades runtime on the first parse (serializing the preamble takes time) for
	* reduced runtime on the second parse (can now reuse the preamble).
	*/
	CreatePreambleOnFirstParse = 8,

	/**
	* Do not stop processing when fatal errors are encountered.
	*
	* When fatal errors are encountered while parsing a translation unit,
	* semantic analysis is typically stopped early when compiling code. A common
	* source for fatal errors are unresolvable include files. For the
	* purposes of an IDE, this is undesirable behavior and as much information
	* as possible should be reported. Use this flag to enable this behavior.
	*/
	KeepGoing = 9,

	/**
	* Sets the preprocessor in a mode for parsing a single file only.
	*/
	SingleFileParse = 10,

	/**
	* Used in combination with CXTranslationUnit_SkipFunctionBodies to
	* constrain the skipping of function bodies to the preamble.
	*
	* The function bodies of the main file are not skipped.
	*/
	LimitSkipFunctionBodiesToPreamble = 11,

	/**
	* Used to indicate that attributed types should be included in CXType.
	*/
	IncludeAttributedTypes = 12,

	/**
	* Used to indicate that implicit attributes should be visited.
	*/
	VisitImplicitAttributes = 13,

	/**
	* Used to indicate that non-errors from included files should be ignored.
	*
	* If set, clang_getDiagnosticSetFromTU() will not report e.g. warnings from
	* included files anymore. This speeds up clang_getDiagnosticSetFromTU() for
	* the case where these warnings are not of interest, as for an IDE for
	* example, which typically shows only the diagnostics in the main file.
	*/
	IgnoreNonErrorsFromIncludedFiles = 14,

	/**
	* Tells the preprocessor not to skip excluded conditional blocks.
	*/
	RetainExcludedConditionalBlocks = 15,
}

Translation_Unit_Flags :: distinct bit_set[Translation_Unit_Flag; c.int]

/**
* Flags that control how translation units are saved.
*
* The enumerators in this enumeration type are meant to be bitwise
* ORed together to specify which options should be used when
* saving the translation unit.
*/
Save_Translation_Unit_Flag :: enum c.int {
}

Save_Translation_Unit_Flags :: distinct bit_set[Save_Translation_Unit_Flag; c.int]

/**
* Describes the kind of error that occurred (if any) in a call to
* \c clang_saveTranslationUnit().
*/
Save_Error :: enum c.int {
	/**
	* Indicates that no error occurred while saving a translation unit.
	*/
	None = 0,

	/**
	* Indicates that an unknown error occurred while attempting to save
	* the file.
	*
	* This error typically indicates that file I/O failed when attempting to
	* write the file.
	*/
	Unknown = 1,

	/**
	* Indicates that errors during translation prevented this attempt
	* to save the translation unit.
	*
	* Errors that prevent the translation unit from being saved can be
	* extracted using \c clang_getNumDiagnostics() and \c clang_getDiagnostic().
	*/
	TranslationErrors = 2,

	/**
	* Indicates that the translation unit to be saved was somehow
	* invalid (e.g., NULL).
	*/
	InvalidTU = 3,
}

/**
* Flags that control the reparsing of translation units.
*
* The enumerators in this enumeration type are meant to be bitwise
* ORed together to specify which options should be used when
* reparsing the translation unit.
*/
Reparse_Flags :: enum c.int {
	/**
	* Used to indicate that no special reparsing options are needed.
	*/
	CXReparse_None = 0,
}

/**
* Categorizes how memory is being used by a translation unit.
*/
Turesource_Usage_Kind :: enum c.int {
	AST                                = 1,
	Identifiers                        = 2,
	Selectors                          = 3,
	GlobalCompletionResults            = 4,
	SourceManagerContentCache          = 5,
	AST_SideTables                     = 6,
	SourceManager_Membuffer_Malloc     = 7,
	SourceManager_Membuffer_MMap       = 8,
	ExternalASTSource_Membuffer_Malloc = 9,
	ExternalASTSource_Membuffer_MMap   = 10,
	Preprocessor                       = 11,
	PreprocessingRecord                = 12,
	SourceManager_DataStructures       = 13,
	Preprocessor_HeaderSearch          = 14,
	MEMORY_IN_BYTES_BEGIN              = 1,
	MEMORY_IN_BYTES_END                = 14,
	First                              = 1,
	Last                               = 14,
}

Turesource_Usage_Entry :: struct {
	/* The memory usage category. */
	kind: Turesource_Usage_Kind,

	/* Amount of resources used.
	The units will depend on the resource kind. */
	amount: c.ulong,
}

/**
* The memory usage of a CXTranslationUnit, broken into categories.
*/
Turesource_Usage :: struct {
	/* Private data member, used for queries. */
	data: rawptr,

	/* The number of entries in the 'entries' array. */
	numEntries: c.uint,

	/* An array of key-value pairs, representing the breakdown of memory
	usage. */
	entries: ^Turesource_Usage_Entry,
}

/**
* Describes the kind of entity that a cursor refers to.
*/
Cursor_Kind :: enum c.int {
	/* Declarations */
	/**
	* A declaration whose specific kind is not exposed via this
	* interface.
	*
	* Unexposed declarations have the same operations as any other kind
	* of declaration; one can extract their location information,
	* spelling, find their definitions, etc. However, the specific kind
	* of the declaration is not reported.
	*/
	UnexposedDecl = 1,

	/** A C or C++ struct. */
	StructDecl = 2,

	/** A C or C++ union. */
	UnionDecl = 3,

	/** A C++ class. */
	ClassDecl = 4,

	/** An enumeration. */
	EnumDecl = 5,

	/**
	* A field (in C) or non-static data member (in C++) in a
	* struct, union, or C++ class.
	*/
	FieldDecl = 6,

	/** An enumerator constant. */
	EnumConstantDecl = 7,

	/** A function. */
	FunctionDecl = 8,

	/** A variable. */
	VarDecl = 9,

	/** A function or method parameter. */
	ParmDecl = 10,

	/** An Objective-C \@interface. */
	ObjCInterfaceDecl = 11,

	/** An Objective-C \@interface for a category. */
	ObjCCategoryDecl = 12,

	/** An Objective-C \@protocol declaration. */
	ObjCProtocolDecl = 13,

	/** An Objective-C \@property declaration. */
	ObjCPropertyDecl = 14,

	/** An Objective-C instance variable. */
	ObjCIvarDecl = 15,

	/** An Objective-C instance method. */
	ObjCInstanceMethodDecl = 16,

	/** An Objective-C class method. */
	ObjCClassMethodDecl = 17,

	/** An Objective-C \@implementation. */
	ObjCImplementationDecl = 18,

	/** An Objective-C \@implementation for a category. */
	ObjCCategoryImplDecl = 19,

	/** A typedef. */
	TypedefDecl = 20,

	/** A C++ class method. */
	CXXMethod = 21,

	/** A C++ namespace. */
	Namespace = 22,

	/** A linkage specification, e.g. 'extern "C"'. */
	LinkageSpec = 23,

	/** A C++ constructor. */
	Constructor = 24,

	/** A C++ destructor. */
	Destructor = 25,

	/** A C++ conversion function. */
	ConversionFunction = 26,

	/** A C++ template type parameter. */
	TemplateTypeParameter = 27,

	/** A C++ non-type template parameter. */
	NonTypeTemplateParameter = 28,

	/** A C++ template template parameter. */
	TemplateTemplateParameter = 29,

	/** A C++ function template. */
	FunctionTemplate = 30,

	/** A C++ class template. */
	ClassTemplate = 31,

	/** A C++ class template partial specialization. */
	ClassTemplatePartialSpecialization = 32,

	/** A C++ namespace alias declaration. */
	NamespaceAlias = 33,

	/** A C++ using directive. */
	UsingDirective = 34,

	/** A C++ using declaration. */
	UsingDeclaration = 35,

	/** A C++ alias declaration */
	TypeAliasDecl = 36,

	/** An Objective-C \@synthesize definition. */
	ObjCSynthesizeDecl = 37,

	/** An Objective-C \@dynamic definition. */
	ObjCDynamicDecl = 38,

	/** An access specifier. */
	CXXAccessSpecifier = 39,

	/** An access specifier. */
	FirstDecl = 1,

	/** An access specifier. */
	LastDecl = 39,
	FirstRef                                         = 40, /* Decl references */
	ObjCSuperClassRef                                = 40,
	ObjCProtocolRef                                  = 41,
	ObjCClassRef                                     = 42,

	/**
	* A reference to a type declaration.
	*
	* A type reference occurs anywhere where a type is named but not
	* declared. For example, given:
	*
	* \code
	* typedef unsigned size_type;
	* size_type size;
	* \endcode
	*
	* The typedef is a declaration of size_type (CXCursor_TypedefDecl),
	* while the type of the variable "size" is referenced. The cursor
	* referenced by the type of size is the typedef for size_type.
	*/
	TypeRef = 43,

	/**
	* A reference to a type declaration.
	*
	* A type reference occurs anywhere where a type is named but not
	* declared. For example, given:
	*
	* \code
	* typedef unsigned size_type;
	* size_type size;
	* \endcode
	*
	* The typedef is a declaration of size_type (CXCursor_TypedefDecl),
	* while the type of the variable "size" is referenced. The cursor
	* referenced by the type of size is the typedef for size_type.
	*/
	CXXBaseSpecifier = 44,

	/**
	* A reference to a class template, function template, template
	* template parameter, or class template partial specialization.
	*/
	TemplateRef = 45,

	/**
	* A reference to a namespace or namespace alias.
	*/
	NamespaceRef = 46,

	/**
	* A reference to a member of a struct, union, or class that occurs in
	* some non-expression context, e.g., a designated initializer.
	*/
	MemberRef = 47,

	/**
	* A reference to a labeled statement.
	*
	* This cursor kind is used to describe the jump to "start_over" in the
	* goto statement in the following example:
	*
	* \code
	*   start_over:
	*     ++counter;
	*
	*     goto start_over;
	* \endcode
	*
	* A label reference cursor refers to a label statement.
	*/
	LabelRef = 48,

	/**
	* A reference to a set of overloaded functions or function templates
	* that has not yet been resolved to a specific function or function template.
	*
	* An overloaded declaration reference cursor occurs in C++ templates where
	* a dependent name refers to a function. For example:
	*
	* \code
	* template<typename T> void swap(T&, T&);
	*
	* struct X { ... };
	* void swap(X&, X&);
	*
	* template<typename T>
	* void reverse(T* first, T* last) {
	*   while (first < last - 1) {
	*     swap(*first, *--last);
	*     ++first;
	*   }
	* }
	*
	* struct Y { };
	* void swap(Y&, Y&);
	* \endcode
	*
	* Here, the identifier "swap" is associated with an overloaded declaration
	* reference. In the template definition, "swap" refers to either of the two
	* "swap" functions declared above, so both results will be available. At
	* instantiation time, "swap" may also refer to other functions found via
	* argument-dependent lookup (e.g., the "swap" function at the end of the
	* example).
	*
	* The functions \c clang_getNumOverloadedDecls() and
	* \c clang_getOverloadedDecl() can be used to retrieve the definitions
	* referenced by this cursor.
	*/
	OverloadedDeclRef = 49,

	/**
	* A reference to a variable that occurs in some non-expression
	* context, e.g., a C++ lambda capture list.
	*/
	VariableRef = 50,

	/**
	* A reference to a variable that occurs in some non-expression
	* context, e.g., a C++ lambda capture list.
	*/
	LastRef = 50,

	/* Error conditions */
	FirstInvalid = 70,

	/* Error conditions */
	InvalidFile = 70,

	/* Error conditions */
	NoDeclFound = 71,

	/* Error conditions */
	NotImplemented = 72,

	/* Error conditions */
	InvalidCode = 73,

	/* Error conditions */
	LastInvalid = 73,

	/* Expressions */
	FirstExpr = 100,

	/**
	* An expression whose specific kind is not exposed via this
	* interface.
	*
	* Unexposed expressions have the same operations as any other kind
	* of expression; one can extract their location information,
	* spelling, children, etc. However, the specific kind of the
	* expression is not reported.
	*/
	UnexposedExpr = 100,

	/**
	* An expression that refers to some value declaration, such
	* as a function, variable, or enumerator.
	*/
	DeclRefExpr = 101,

	/**
	* An expression that refers to a member of a struct, union,
	* class, Objective-C class, etc.
	*/
	MemberRefExpr = 102,

	/** An expression that calls a function. */
	CallExpr = 103,

	/** An expression that sends a message to an Objective-C
	object or class. */
	ObjCMessageExpr = 104,

	/** An expression that represents a block literal. */
	BlockExpr = 105,

	/** An integer literal.
	*/
	IntegerLiteral = 106,

	/** A floating point number literal.
	*/
	FloatingLiteral = 107,

	/** An imaginary number literal.
	*/
	ImaginaryLiteral = 108,

	/** A string literal.
	*/
	StringLiteral = 109,

	/** A character literal.
	*/
	CharacterLiteral = 110,

	/** A parenthesized expression, e.g. "(1)".
	*
	* This AST node is only formed if full location information is requested.
	*/
	ParenExpr = 111,

	/** This represents the unary-expression's (except sizeof and
	* alignof).
	*/
	UnaryOperator = 112,

	/** [C99 6.5.2.1] Array Subscripting.
	*/
	ArraySubscriptExpr = 113,

	/** A builtin binary operation expression such as "x + y" or
	* "x <= y".
	*/
	BinaryOperator = 114,

	/** Compound assignment such as "+=".
	*/
	CompoundAssignOperator = 115,

	/** The ?: ternary operator.
	*/
	ConditionalOperator = 116,

	/** An explicit cast in C (C99 6.5.4) or a C-style cast in C++
	* (C++ [expr.cast]), which uses the syntax (Type)expr.
	*
	* For example: (int)f.
	*/
	CStyleCastExpr = 117,

	/** [C99 6.5.2.5]
	*/
	CompoundLiteralExpr = 118,

	/** Describes an C or C++ initializer list.
	*/
	InitListExpr = 119,

	/** The GNU address of label extension, representing &&label.
	*/
	AddrLabelExpr = 120,

	/** This is the GNU Statement Expression extension: ({int X=4; X;})
	*/
	StmtExpr = 121,

	/** Represents a C11 generic selection.
	*/
	GenericSelectionExpr = 122,

	/** Implements the GNU __null extension, which is a name for a null
	* pointer constant that has integral type (e.g., int or long) and is the same
	* size and alignment as a pointer.
	*
	* The __null extension is typically only used by system headers, which define
	* NULL as __null in C++ rather than using 0 (which is an integer that may not
	* match the size of a pointer).
	*/
	GNUNullExpr = 123,

	/** C++'s static_cast<> expression.
	*/
	CXXStaticCastExpr = 124,

	/** C++'s dynamic_cast<> expression.
	*/
	CXXDynamicCastExpr = 125,

	/** C++'s reinterpret_cast<> expression.
	*/
	CXXReinterpretCastExpr = 126,

	/** C++'s const_cast<> expression.
	*/
	CXXConstCastExpr = 127,

	/** Represents an explicit C++ type conversion that uses "functional"
	* notion (C++ [expr.type.conv]).
	*
	* Example:
	* \code
	*   x = int(0.5);
	* \endcode
	*/
	CXXFunctionalCastExpr = 128,

	/** A C++ typeid expression (C++ [expr.typeid]).
	*/
	CXXTypeidExpr = 129,

	/** [C++ 2.13.5] C++ Boolean Literal.
	*/
	CXXBoolLiteralExpr = 130,

	/** [C++0x 2.14.7] C++ Pointer Literal.
	*/
	CXXNullPtrLiteralExpr = 131,

	/** Represents the "this" expression in C++
	*/
	CXXThisExpr = 132,

	/** [C++ 15] C++ Throw Expression.
	*
	* This handles 'throw' and 'throw' assignment-expression. When
	* assignment-expression isn't present, Op will be null.
	*/
	CXXThrowExpr = 133,

	/** A new expression for memory allocation and constructor calls, e.g:
	* "new CXXNewExpr(foo)".
	*/
	CXXNewExpr = 134,

	/** A delete expression for memory deallocation and destructor calls,
	* e.g. "delete[] pArray".
	*/
	CXXDeleteExpr = 135,

	/** A unary expression. (noexcept, sizeof, or other traits)
	*/
	UnaryExpr = 136,

	/** An Objective-C string literal i.e. @"foo".
	*/
	ObjCStringLiteral = 137,

	/** An Objective-C \@encode expression.
	*/
	ObjCEncodeExpr = 138,

	/** An Objective-C \@selector expression.
	*/
	ObjCSelectorExpr = 139,

	/** An Objective-C \@protocol expression.
	*/
	ObjCProtocolExpr = 140,

	/** An Objective-C "bridged" cast expression, which casts between
	* Objective-C pointers and C pointers, transferring ownership in the process.
	*
	* \code
	*   NSString *str = (__bridge_transfer NSString *)CFCreateString();
	* \endcode
	*/
	ObjCBridgedCastExpr = 141,

	/** Represents a C++0x pack expansion that produces a sequence of
	* expressions.
	*
	* A pack expansion expression contains a pattern (which itself is an
	* expression) followed by an ellipsis. For example:
	*
	* \code
	* template<typename F, typename ...Types>
	* void forward(F f, Types &&...args) {
	*  f(static_cast<Types&&>(args)...);
	* }
	* \endcode
	*/
	PackExpansionExpr = 142,

	/** Represents an expression that computes the length of a parameter
	* pack.
	*
	* \code
	* template<typename ...Types>
	* struct count {
	*   static const unsigned value = sizeof...(Types);
	* };
	* \endcode
	*/
	SizeOfPackExpr = 143,

	/* Represents a C++ lambda expression that produces a local function
	* object.
	*
	* \code
	* void abssort(float *x, unsigned N) {
	*   std::sort(x, x + N,
	*             [](float a, float b) {
	*               return std::abs(a) < std::abs(b);
	*             });
	* }
	* \endcode
	*/
	LambdaExpr = 144,

	/** Objective-c Boolean Literal.
	*/
	ObjCBoolLiteralExpr = 145,

	/** Represents the "self" expression in an Objective-C method.
	*/
	ObjCSelfExpr = 146,

	/** OpenMP 5.0 [2.1.5, Array Section].
	* OpenACC 3.3 [2.7.1, Data Specification for Data Clauses (Sub Arrays)]
	*/
	ArraySectionExpr = 147,

	/** Represents an @available(...) check.
	*/
	ObjCAvailabilityCheckExpr = 148,

	/**
	* Fixed point literal
	*/
	FixedPointLiteral = 149,

	/** OpenMP 5.0 [2.1.4, Array Shaping].
	*/
	OMPArrayShapingExpr = 150,

	/**
	* OpenMP 5.0 [2.1.6 Iterators]
	*/
	OMPIteratorExpr = 151,

	/** OpenCL's addrspace_cast<> expression.
	*/
	CXXAddrspaceCastExpr = 152,

	/**
	* Expression that references a C++20 concept.
	*/
	ConceptSpecializationExpr = 153,

	/**
	* Expression that references a C++20 requires expression.
	*/
	RequiresExpr = 154,

	/**
	* Expression that references a C++20 parenthesized list aggregate
	* initializer.
	*/
	CXXParenListInitExpr = 155,

	/**
	*  Represents a C++26 pack indexing expression.
	*/
	PackIndexingExpr = 156,

	/**
	*  Represents a C++26 pack indexing expression.
	*/
	LastExpr = 156,

	/* Statements */
	FirstStmt = 200,

	/**
	* A statement whose specific kind is not exposed via this
	* interface.
	*
	* Unexposed statements have the same operations as any other kind of
	* statement; one can extract their location information, spelling,
	* children, etc. However, the specific kind of the statement is not
	* reported.
	*/
	UnexposedStmt = 200,

	/** A labelled statement in a function.
	*
	* This cursor kind is used to describe the "start_over:" label statement in
	* the following example:
	*
	* \code
	*   start_over:
	*     ++counter;
	* \endcode
	*
	*/
	LabelStmt = 201,

	/** A group of statements like { stmt stmt }.
	*
	* This cursor kind is used to describe compound statements, e.g. function
	* bodies.
	*/
	CompoundStmt = 202,

	/** A case statement.
	*/
	CaseStmt = 203,

	/** A default statement.
	*/
	DefaultStmt = 204,

	/** An if statement
	*/
	IfStmt = 205,

	/** A switch statement.
	*/
	SwitchStmt = 206,

	/** A while statement.
	*/
	WhileStmt = 207,

	/** A do statement.
	*/
	DoStmt = 208,

	/** A for statement.
	*/
	ForStmt = 209,

	/** A goto statement.
	*/
	GotoStmt = 210,

	/** An indirect goto statement.
	*/
	IndirectGotoStmt = 211,

	/** A continue statement.
	*/
	ContinueStmt = 212,

	/** A break statement.
	*/
	BreakStmt = 213,

	/** A return statement.
	*/
	ReturnStmt = 214,

	/** A GCC inline assembly statement extension.
	*/
	GCCAsmStmt = 215,

	/** A GCC inline assembly statement extension.
	*/
	AsmStmt = 215,

	/** Objective-C's overall \@try-\@catch-\@finally statement.
	*/
	ObjCAtTryStmt = 216,

	/** Objective-C's \@catch statement.
	*/
	ObjCAtCatchStmt = 217,

	/** Objective-C's \@finally statement.
	*/
	ObjCAtFinallyStmt = 218,

	/** Objective-C's \@throw statement.
	*/
	ObjCAtThrowStmt = 219,

	/** Objective-C's \@synchronized statement.
	*/
	ObjCAtSynchronizedStmt = 220,

	/** Objective-C's autorelease pool statement.
	*/
	ObjCAutoreleasePoolStmt = 221,

	/** Objective-C's collection statement.
	*/
	ObjCForCollectionStmt = 222,

	/** C++'s catch statement.
	*/
	CXXCatchStmt = 223,

	/** C++'s try statement.
	*/
	CXXTryStmt = 224,

	/** C++'s for (* : *) statement.
	*/
	CXXForRangeStmt = 225,

	/** Windows Structured Exception Handling's try statement.
	*/
	SEHTryStmt = 226,

	/** Windows Structured Exception Handling's except statement.
	*/
	SEHExceptStmt = 227,

	/** Windows Structured Exception Handling's finally statement.
	*/
	SEHFinallyStmt = 228,

	/** A MS inline assembly statement extension.
	*/
	MSAsmStmt = 229,

	/** The null statement ";": C99 6.8.3p3.
	*
	* This cursor kind is used to describe the null statement.
	*/
	NullStmt = 230,

	/** Adaptor class for mixing declarations with statements and
	* expressions.
	*/
	DeclStmt = 231,

	/** OpenMP parallel directive.
	*/
	OMPParallelDirective = 232,

	/** OpenMP SIMD directive.
	*/
	OMPSimdDirective = 233,

	/** OpenMP for directive.
	*/
	OMPForDirective = 234,

	/** OpenMP sections directive.
	*/
	OMPSectionsDirective = 235,

	/** OpenMP section directive.
	*/
	OMPSectionDirective = 236,

	/** OpenMP single directive.
	*/
	OMPSingleDirective = 237,

	/** OpenMP parallel for directive.
	*/
	OMPParallelForDirective = 238,

	/** OpenMP parallel sections directive.
	*/
	OMPParallelSectionsDirective = 239,

	/** OpenMP task directive.
	*/
	OMPTaskDirective = 240,

	/** OpenMP master directive.
	*/
	OMPMasterDirective = 241,

	/** OpenMP critical directive.
	*/
	OMPCriticalDirective = 242,

	/** OpenMP taskyield directive.
	*/
	OMPTaskyieldDirective = 243,

	/** OpenMP barrier directive.
	*/
	OMPBarrierDirective = 244,

	/** OpenMP taskwait directive.
	*/
	OMPTaskwaitDirective = 245,

	/** OpenMP flush directive.
	*/
	OMPFlushDirective = 246,

	/** Windows Structured Exception Handling's leave statement.
	*/
	SEHLeaveStmt = 247,

	/** OpenMP ordered directive.
	*/
	OMPOrderedDirective = 248,

	/** OpenMP atomic directive.
	*/
	OMPAtomicDirective = 249,

	/** OpenMP for SIMD directive.
	*/
	OMPForSimdDirective = 250,

	/** OpenMP parallel for SIMD directive.
	*/
	OMPParallelForSimdDirective = 251,

	/** OpenMP target directive.
	*/
	OMPTargetDirective = 252,

	/** OpenMP teams directive.
	*/
	OMPTeamsDirective = 253,

	/** OpenMP taskgroup directive.
	*/
	OMPTaskgroupDirective = 254,

	/** OpenMP cancellation point directive.
	*/
	OMPCancellationPointDirective = 255,

	/** OpenMP cancel directive.
	*/
	OMPCancelDirective = 256,

	/** OpenMP target data directive.
	*/
	OMPTargetDataDirective = 257,

	/** OpenMP taskloop directive.
	*/
	OMPTaskLoopDirective = 258,

	/** OpenMP taskloop simd directive.
	*/
	OMPTaskLoopSimdDirective = 259,

	/** OpenMP distribute directive.
	*/
	OMPDistributeDirective = 260,

	/** OpenMP target enter data directive.
	*/
	OMPTargetEnterDataDirective = 261,

	/** OpenMP target exit data directive.
	*/
	OMPTargetExitDataDirective = 262,

	/** OpenMP target parallel directive.
	*/
	OMPTargetParallelDirective = 263,

	/** OpenMP target parallel for directive.
	*/
	OMPTargetParallelForDirective = 264,

	/** OpenMP target update directive.
	*/
	OMPTargetUpdateDirective = 265,

	/** OpenMP distribute parallel for directive.
	*/
	OMPDistributeParallelForDirective = 266,

	/** OpenMP distribute parallel for simd directive.
	*/
	OMPDistributeParallelForSimdDirective = 267,

	/** OpenMP distribute simd directive.
	*/
	OMPDistributeSimdDirective = 268,

	/** OpenMP target parallel for simd directive.
	*/
	OMPTargetParallelForSimdDirective = 269,

	/** OpenMP target simd directive.
	*/
	OMPTargetSimdDirective = 270,

	/** OpenMP teams distribute directive.
	*/
	OMPTeamsDistributeDirective = 271,

	/** OpenMP teams distribute simd directive.
	*/
	OMPTeamsDistributeSimdDirective = 272,

	/** OpenMP teams distribute parallel for simd directive.
	*/
	OMPTeamsDistributeParallelForSimdDirective = 273,

	/** OpenMP teams distribute parallel for directive.
	*/
	OMPTeamsDistributeParallelForDirective = 274,

	/** OpenMP target teams directive.
	*/
	OMPTargetTeamsDirective = 275,

	/** OpenMP target teams distribute directive.
	*/
	OMPTargetTeamsDistributeDirective = 276,

	/** OpenMP target teams distribute parallel for directive.
	*/
	OMPTargetTeamsDistributeParallelForDirective = 277,

	/** OpenMP target teams distribute parallel for simd directive.
	*/
	OMPTargetTeamsDistributeParallelForSimdDirective = 278,

	/** OpenMP target teams distribute simd directive.
	*/
	OMPTargetTeamsDistributeSimdDirective = 279,

	/** C++2a std::bit_cast expression.
	*/
	BuiltinBitCastExpr = 280,

	/** OpenMP master taskloop directive.
	*/
	OMPMasterTaskLoopDirective = 281,

	/** OpenMP parallel master taskloop directive.
	*/
	OMPParallelMasterTaskLoopDirective = 282,

	/** OpenMP master taskloop simd directive.
	*/
	OMPMasterTaskLoopSimdDirective = 283,

	/** OpenMP parallel master taskloop simd directive.
	*/
	OMPParallelMasterTaskLoopSimdDirective = 284,

	/** OpenMP parallel master directive.
	*/
	OMPParallelMasterDirective = 285,

	/** OpenMP depobj directive.
	*/
	OMPDepobjDirective = 286,

	/** OpenMP scan directive.
	*/
	OMPScanDirective = 287,

	/** OpenMP tile directive.
	*/
	OMPTileDirective = 288,

	/** OpenMP canonical loop.
	*/
	OMPCanonicalLoop = 289,

	/** OpenMP interop directive.
	*/
	OMPInteropDirective = 290,

	/** OpenMP dispatch directive.
	*/
	OMPDispatchDirective = 291,

	/** OpenMP masked directive.
	*/
	OMPMaskedDirective = 292,

	/** OpenMP unroll directive.
	*/
	OMPUnrollDirective = 293,

	/** OpenMP metadirective directive.
	*/
	OMPMetaDirective = 294,

	/** OpenMP loop directive.
	*/
	OMPGenericLoopDirective = 295,

	/** OpenMP teams loop directive.
	*/
	OMPTeamsGenericLoopDirective = 296,

	/** OpenMP target teams loop directive.
	*/
	OMPTargetTeamsGenericLoopDirective = 297,

	/** OpenMP parallel loop directive.
	*/
	OMPParallelGenericLoopDirective = 298,

	/** OpenMP target parallel loop directive.
	*/
	OMPTargetParallelGenericLoopDirective = 299,

	/** OpenMP parallel masked directive.
	*/
	OMPParallelMaskedDirective = 300,

	/** OpenMP masked taskloop directive.
	*/
	OMPMaskedTaskLoopDirective = 301,

	/** OpenMP masked taskloop simd directive.
	*/
	OMPMaskedTaskLoopSimdDirective = 302,

	/** OpenMP parallel masked taskloop directive.
	*/
	OMPParallelMaskedTaskLoopDirective = 303,

	/** OpenMP parallel masked taskloop simd directive.
	*/
	OMPParallelMaskedTaskLoopSimdDirective = 304,

	/** OpenMP error directive.
	*/
	OMPErrorDirective = 305,

	/** OpenMP scope directive.
	*/
	OMPScopeDirective = 306,

	/** OpenMP reverse directive.
	*/
	OMPReverseDirective = 307,

	/** OpenMP interchange directive.
	*/
	OMPInterchangeDirective = 308,

	/** OpenMP assume directive.
	*/
	OMPAssumeDirective = 309,

	/** OpenACC Compute Construct.
	*/
	OpenACCComputeConstruct = 320,

	/** OpenACC Loop Construct.
	*/
	OpenACCLoopConstruct = 321,

	/** OpenACC Combined Constructs.
	*/
	OpenACCCombinedConstruct = 322,

	/** OpenACC data Construct.
	*/
	OpenACCDataConstruct = 323,

	/** OpenACC enter data Construct.
	*/
	OpenACCEnterDataConstruct = 324,

	/** OpenACC exit data Construct.
	*/
	OpenACCExitDataConstruct = 325,

	/** OpenACC host_data Construct.
	*/
	OpenACCHostDataConstruct = 326,

	/** OpenACC wait Construct.
	*/
	OpenACCWaitConstruct = 327,

	/** OpenACC init Construct.
	*/
	OpenACCInitConstruct = 328,

	/** OpenACC shutdown Construct.
	*/
	OpenACCShutdownConstruct = 329,

	/** OpenACC set Construct.
	*/
	OpenACCSetConstruct = 330,

	/** OpenACC update Construct.
	*/
	OpenACCUpdateConstruct = 331,

	/** OpenACC update Construct.
	*/
	LastStmt = 331,

	/**
	* Cursor that represents the translation unit itself.
	*
	* The translation unit cursor exists primarily to act as the root
	* cursor for traversing the contents of a translation unit.
	*/
	TranslationUnit = 350,

	/* Attributes */
	FirstAttr = 400,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	UnexposedAttr = 400,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	IBActionAttr = 401,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	IBOutletAttr = 402,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	IBOutletCollectionAttr = 403,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CXXFinalAttr = 404,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CXXOverrideAttr = 405,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	AnnotateAttr = 406,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	AsmLabelAttr = 407,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	PackedAttr = 408,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	PureAttr = 409,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ConstAttr = 410,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	NoDuplicateAttr = 411,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CUDAConstantAttr = 412,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CUDADeviceAttr = 413,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CUDAGlobalAttr = 414,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CUDAHostAttr = 415,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	CUDASharedAttr = 416,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	VisibilityAttr = 417,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	DLLExport = 418,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	DLLImport = 419,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	NSReturnsRetained = 420,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	NSReturnsNotRetained = 421,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	NSReturnsAutoreleased = 422,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	NSConsumesSelf = 423,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	NSConsumed = 424,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCException = 425,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCNSObject = 426,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCIndependentClass = 427,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCPreciseLifetime = 428,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCReturnsInnerPointer = 429,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCRequiresSuper = 430,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCRootClass = 431,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCSubclassingRestricted = 432,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCExplicitProtocolImpl = 433,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCDesignatedInitializer = 434,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCRuntimeVisible = 435,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ObjCBoxable = 436,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	FlagEnum = 437,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	ConvergentAttr = 438,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	WarnUnusedAttr = 439,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	WarnUnusedResultAttr = 440,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	AlignedAttr = 441,

	/**
	* An attribute whose specific kind is not exposed via this
	* interface.
	*/
	LastAttr = 441,

	/* Preprocessing */
	PreprocessingDirective = 500,

	/* Preprocessing */
	MacroDefinition = 501,

	/* Preprocessing */
	MacroExpansion = 502,

	/* Preprocessing */
	MacroInstantiation = 502,

	/* Preprocessing */
	InclusionDirective = 503,

	/* Preprocessing */
	FirstPreprocessing = 500,

	/* Preprocessing */
	LastPreprocessing = 503,

	/* Extra Declarations */
	/**
	* A module import declaration.
	*/
	ModuleImportDecl = 600,

	/* Extra Declarations */
	/**
	* A module import declaration.
	*/
	TypeAliasTemplateDecl = 601,

	/**
	* A static_assert or _Static_assert node
	*/
	StaticAssert = 602,

	/**
	* a friend declaration.
	*/
	FriendDecl = 603,

	/**
	* a concept declaration.
	*/
	ConceptDecl = 604,

	/**
	* a concept declaration.
	*/
	FirstExtraDecl = 600,

	/**
	* a concept declaration.
	*/
	LastExtraDecl = 604,

	/**
	* A code completion overload candidate.
	*/
	OverloadCandidate = 700,
}

/**
* A cursor representing some element in the abstract syntax tree for
* a translation unit.
*
* The cursor abstraction unifies the different kinds of entities in a
* program--declaration, statements, expressions, references to declarations,
* etc.--under a single "cursor" abstraction with a common set of operations.
* Common operation for a cursor include: getting the physical location in
* a source file where the cursor points, getting the name associated with a
* cursor, and retrieving cursors for any child nodes of a particular cursor.
*
* Cursors can be produced in two specific ways.
* clang_getTranslationUnitCursor() produces a cursor for a translation unit,
* from which one can use clang_visitChildren() to explore the rest of the
* translation unit. clang_getCursor() maps from a physical source location
* to the entity that resides at that location, allowing one to map from the
* source code into the AST.
*/
Cursor :: struct {
	kind:  Cursor_Kind,
	xdata: c.int,
	data:  [3]rawptr,
}

/**
* Describe the linkage of the entity referred to by a cursor.
*/
Linkage_Kind :: enum c.int {
	/** This value indicates that no linkage information is available
	* for a provided CXCursor. */
	Invalid,

	/**
	* This is the linkage for variables, parameters, and so on that
	*  have automatic storage.  This covers normal (non-extern) local variables.
	*/
	NoLinkage,

	/** This is the linkage for static variables and static functions. */
	Internal,

	/** This is the linkage for entities with external linkage that live
	* in C++ anonymous namespaces.*/
	UniqueExternal,

	/** This is the linkage for entities with true, external linkage. */
	External,
}

Visibility_Kind :: enum c.int {
	/** This value indicates that no visibility information is available
	* for a provided CXCursor. */
	Invalid,

	/** Symbol not seen by the linker. */
	Hidden,

	/** Symbol seen by the linker but resolves to a symbol inside this object. */
	Protected,

	/** Symbol seen by the linker and acts like a normal symbol. */
	Default,
}

/**
* Describes the availability of a given entity on a particular platform, e.g.,
* a particular class might only be available on Mac OS 10.7 or newer.
*/
Platform_Availability :: struct {
	/**
	* A string that describes the platform for which this structure
	* provides availability information.
	*
	* Possible values are "ios" or "macos".
	*/
	Platform: String,

	/**
	* The version number in which this entity was introduced.
	*/
	Introduced: Version,

	/**
	* The version number in which this entity was deprecated (but is
	* still available).
	*/
	Deprecated: Version,

	/**
	* The version number in which this entity was obsoleted, and therefore
	* is no longer available.
	*/
	Obsoleted: Version,

	/**
	* Whether the entity is unconditionally unavailable on this platform.
	*/
	Unavailable: c.int,

	/**
	* An optional message to provide to a user of this API, e.g., to
	* suggest replacement APIs.
	*/
	Message: String,
}

/**
* Describe the "language" of the entity referred to by a cursor.
*/
Language_Kind :: enum c.int {
	Invalid = 0,
	C,
	ObjC,
	CPlusPlus,
}

/**
* Describe the "thread-local storage (TLS) kind" of the declaration
* referred to by a cursor.
*/
Tlskind :: enum c.int {
	None = 0,
	Dynamic,
	Static,
}

/**
* A fast container representing a set of CXCursors.
*/
Cursor_Set :: struct {}

/**
* Describes the kind of type
*/
Type_Kind :: enum c.int {
	/**
	* Represents an invalid type (e.g., where no type is available).
	*/
	Invalid = 0,

	/**
	* A type whose specific kind is not exposed via this
	* interface.
	*/
	Unexposed = 1,

	/* Builtin types */
	Void = 2,

	/* Builtin types */
	Bool = 3,

	/* Builtin types */
	Char_U = 4,

	/* Builtin types */
	UChar = 5,

	/* Builtin types */
	Char16 = 6,

	/* Builtin types */
	Char32 = 7,

	/* Builtin types */
	UShort = 8,

	/* Builtin types */
	UInt = 9,

	/* Builtin types */
	ULong = 10,

	/* Builtin types */
	ULongLong = 11,

	/* Builtin types */
	UInt128 = 12,

	/* Builtin types */
	Char_S = 13,

	/* Builtin types */
	SChar = 14,

	/* Builtin types */
	WChar = 15,

	/* Builtin types */
	Short = 16,

	/* Builtin types */
	Int = 17,

	/* Builtin types */
	Long = 18,

	/* Builtin types */
	LongLong = 19,

	/* Builtin types */
	Int128 = 20,

	/* Builtin types */
	Float = 21,

	/* Builtin types */
	Double = 22,

	/* Builtin types */
	LongDouble = 23,

	/* Builtin types */
	NullPtr = 24,

	/* Builtin types */
	Overload = 25,

	/* Builtin types */
	Dependent = 26,

	/* Builtin types */
	ObjCId = 27,

	/* Builtin types */
	ObjCClass = 28,

	/* Builtin types */
	ObjCSel = 29,

	/* Builtin types */
	Float128 = 30,

	/* Builtin types */
	Half = 31,

	/* Builtin types */
	Float16 = 32,

	/* Builtin types */
	ShortAccum = 33,

	/* Builtin types */
	Accum = 34,

	/* Builtin types */
	LongAccum = 35,

	/* Builtin types */
	UShortAccum = 36,

	/* Builtin types */
	UAccum = 37,

	/* Builtin types */
	ULongAccum = 38,

	/* Builtin types */
	BFloat16 = 39,

	/* Builtin types */
	Ibm128 = 40,

	/* Builtin types */
	FirstBuiltin = 2,

	/* Builtin types */
	LastBuiltin = 40,

	/* Builtin types */
	Complex = 100,

	/* Builtin types */
	Pointer = 101,

	/* Builtin types */
	BlockPointer = 102,

	/* Builtin types */
	LValueReference = 103,

	/* Builtin types */
	RValueReference = 104,

	/* Builtin types */
	Record = 105,

	/* Builtin types */
	Enum = 106,

	/* Builtin types */
	Typedef = 107,

	/* Builtin types */
	ObjCInterface = 108,

	/* Builtin types */
	ObjCObjectPointer = 109,

	/* Builtin types */
	FunctionNoProto = 110,

	/* Builtin types */
	FunctionProto = 111,

	/* Builtin types */
	ConstantArray = 112,

	/* Builtin types */
	Vector = 113,

	/* Builtin types */
	IncompleteArray = 114,

	/* Builtin types */
	VariableArray = 115,

	/* Builtin types */
	DependentSizedArray = 116,

	/* Builtin types */
	MemberPointer = 117,

	/* Builtin types */
	Auto = 118,

	/**
	* Represents a type that was referred to using an elaborated type keyword.
	*
	* E.g., struct S, or via a qualified name, e.g., N::M::type, or both.
	*/
	Elaborated = 119,

	/* OpenCL PipeType. */
	Pipe = 120,

	/* OpenCL builtin types. */
	OCLImage1dRO = 121,

	/* OpenCL builtin types. */
	OCLImage1dArrayRO = 122,

	/* OpenCL builtin types. */
	OCLImage1dBufferRO = 123,

	/* OpenCL builtin types. */
	OCLImage2dRO = 124,

	/* OpenCL builtin types. */
	OCLImage2dArrayRO = 125,

	/* OpenCL builtin types. */
	OCLImage2dDepthRO = 126,

	/* OpenCL builtin types. */
	OCLImage2dArrayDepthRO = 127,

	/* OpenCL builtin types. */
	OCLImage2dMSAARO = 128,

	/* OpenCL builtin types. */
	OCLImage2dArrayMSAARO = 129,

	/* OpenCL builtin types. */
	OCLImage2dMSAADepthRO = 130,

	/* OpenCL builtin types. */
	OCLImage2dArrayMSAADepthRO = 131,

	/* OpenCL builtin types. */
	OCLImage3dRO = 132,

	/* OpenCL builtin types. */
	OCLImage1dWO = 133,

	/* OpenCL builtin types. */
	OCLImage1dArrayWO = 134,

	/* OpenCL builtin types. */
	OCLImage1dBufferWO = 135,

	/* OpenCL builtin types. */
	OCLImage2dWO = 136,

	/* OpenCL builtin types. */
	OCLImage2dArrayWO = 137,

	/* OpenCL builtin types. */
	OCLImage2dDepthWO = 138,

	/* OpenCL builtin types. */
	OCLImage2dArrayDepthWO = 139,

	/* OpenCL builtin types. */
	OCLImage2dMSAAWO = 140,

	/* OpenCL builtin types. */
	OCLImage2dArrayMSAAWO = 141,

	/* OpenCL builtin types. */
	OCLImage2dMSAADepthWO = 142,

	/* OpenCL builtin types. */
	OCLImage2dArrayMSAADepthWO = 143,

	/* OpenCL builtin types. */
	OCLImage3dWO = 144,

	/* OpenCL builtin types. */
	OCLImage1dRW = 145,

	/* OpenCL builtin types. */
	OCLImage1dArrayRW = 146,

	/* OpenCL builtin types. */
	OCLImage1dBufferRW = 147,

	/* OpenCL builtin types. */
	OCLImage2dRW = 148,

	/* OpenCL builtin types. */
	OCLImage2dArrayRW = 149,

	/* OpenCL builtin types. */
	OCLImage2dDepthRW = 150,

	/* OpenCL builtin types. */
	OCLImage2dArrayDepthRW = 151,

	/* OpenCL builtin types. */
	OCLImage2dMSAARW = 152,

	/* OpenCL builtin types. */
	OCLImage2dArrayMSAARW = 153,

	/* OpenCL builtin types. */
	OCLImage2dMSAADepthRW = 154,

	/* OpenCL builtin types. */
	OCLImage2dArrayMSAADepthRW = 155,

	/* OpenCL builtin types. */
	OCLImage3dRW = 156,

	/* OpenCL builtin types. */
	OCLSampler = 157,

	/* OpenCL builtin types. */
	OCLEvent = 158,

	/* OpenCL builtin types. */
	OCLQueue = 159,

	/* OpenCL builtin types. */
	OCLReserveID = 160,

	/* OpenCL builtin types. */
	ObjCObject = 161,

	/* OpenCL builtin types. */
	ObjCTypeParam = 162,

	/* OpenCL builtin types. */
	Attributed = 163,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCMcePayload = 164,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCImePayload = 165,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCRefPayload = 166,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCSicPayload = 167,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCMceResult = 168,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCImeResult = 169,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCRefResult = 170,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCSicResult = 171,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCImeResultSingleReferenceStreamout = 172,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCImeResultDualReferenceStreamout = 173,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCImeSingleReferenceStreamin = 174,

	/* OpenCL builtin types. */
	OCLIntelSubgroupAVCImeDualReferenceStreamin = 175,

	/* Old aliases for AVC OpenCL extension types. */
	OCLIntelSubgroupAVCImeResultSingleRefStreamout = 172,

	/* Old aliases for AVC OpenCL extension types. */
	OCLIntelSubgroupAVCImeResultDualRefStreamout = 173,

	/* Old aliases for AVC OpenCL extension types. */
	OCLIntelSubgroupAVCImeSingleRefStreamin = 174,

	/* Old aliases for AVC OpenCL extension types. */
	OCLIntelSubgroupAVCImeDualRefStreamin = 175,

	/* Old aliases for AVC OpenCL extension types. */
	ExtVector = 176,

	/* Old aliases for AVC OpenCL extension types. */
	Atomic = 177,

	/* Old aliases for AVC OpenCL extension types. */
	BTFTagAttributed = 178,

	/* HLSL Types */
	HLSLResource = 179,

	/* HLSL Types */
	HLSLAttributedResource = 180,
}

/**
* Describes the calling convention of a function type
*/
Calling_Conv :: enum c.int {
	Default           = 0,
	C                 = 1,
	X86StdCall        = 2,
	X86FastCall       = 3,
	X86ThisCall       = 4,
	X86Pascal         = 5,
	AAPCS             = 6,
	AAPCS_VFP         = 7,
	X86RegCall        = 8,
	IntelOclBicc      = 9,
	Win64             = 10,

	/* Alias for compatibility with older versions of API. */
	X86_64Win64 = 10,

	/* Alias for compatibility with older versions of API. */
	X86_64SysV = 11,

	/* Alias for compatibility with older versions of API. */
	X86VectorCall = 12,

	/* Alias for compatibility with older versions of API. */
	Swift = 13,

	/* Alias for compatibility with older versions of API. */
	PreserveMost = 14,

	/* Alias for compatibility with older versions of API. */
	PreserveAll = 15,

	/* Alias for compatibility with older versions of API. */
	AArch64VectorCall = 16,

	/* Alias for compatibility with older versions of API. */
	SwiftAsync = 17,

	/* Alias for compatibility with older versions of API. */
	AArch64SVEPCS = 18,

	/* Alias for compatibility with older versions of API. */
	M68kRTD = 19,

	/* Alias for compatibility with older versions of API. */
	PreserveNone = 20,

	/* Alias for compatibility with older versions of API. */
	RISCVVectorCall = 21,

	/* Alias for compatibility with older versions of API. */
	Invalid = 100,

	/* Alias for compatibility with older versions of API. */
	Unexposed = 200,
}

/**
* The type of an element in the abstract syntax tree.
*
*/
Type :: struct {
	kind: Type_Kind,
	data: [2]rawptr,
}

/**
* Describes the kind of a template argument.
*
* See the definition of llvm::clang::TemplateArgument::ArgKind for full
* element descriptions.
*/
Template_Argument_Kind :: enum c.int {
	Null,
	Type,
	Declaration,
	NullPtr,
	Integral,
	Template,
	TemplateExpansion,
	Expression,
	Pack,

	/* Indicates an error case, preventing the kind from being deduced. */
	Invalid,
}

Type_Nullability_Kind :: enum c.int {
	/**
	* Values of this type can never be null.
	*/
	NonNull = 0,

	/**
	* Values of this type can be null.
	*/
	Nullable = 1,

	/**
	* Whether values of this type can be null is (explicitly)
	* unspecified. This captures a (fairly rare) case where we
	* can't conclude anything about the nullability of the type even
	* though it has been considered.
	*/
	Unspecified = 2,

	/**
	* Nullability is not applicable to this type.
	*/
	Invalid = 3,

	/**
	* Generally behaves like Nullable, except when used in a block parameter that
	* was imported into a swift async method. There, swift will assume that the
	* parameter can get null even if no error occurred. _Nullable parameters are
	* assumed to only get null on error.
	*/
	NullableResult = 4,
}

/**
* List the possible error codes for \c clang_Type_getSizeOf,
*   \c clang_Type_getAlignOf, \c clang_Type_getOffsetOf,
*   \c clang_Cursor_getOffsetOf, and \c clang_getOffsetOfBase.
*
* A value of this enumeration type can be returned if the target type is not
* a valid argument to sizeof, alignof or offsetof.
*/
Type_Layout_Error :: enum c.int {
	/**
	* Type is of kind CXType_Invalid.
	*/
	Invalid = -1,

	/**
	* The type is an incomplete Type.
	*/
	Incomplete = -2,

	/**
	* The type is a dependent Type.
	*/
	Dependent = -3,

	/**
	* The type is not a constant size type.
	*/
	NotConstantSize = -4,

	/**
	* The Field name is not valid for this record.
	*/
	InvalidFieldName = -5,

	/**
	* The type is undeduced.
	*/
	Undeduced = -6,
}

Ref_Qualifier_Kind :: enum c.int {
	/** No ref-qualifier was provided. */
	None = 0,

	/** An lvalue ref-qualifier was provided (\c &). */
	LValue,

	/** An rvalue ref-qualifier was provided (\c &&). */
	RValue,
}

/**
* Represents the C++ access control level to a base class for a
* cursor with kind CX_CXXBaseSpecifier.
*/
Cxxaccess_Specifier :: enum c.int {
	InvalidAccessSpecifier,
	Public,
	Protected,
	Private,
}

/**
* Represents the storage classes as declared in the source. CX_SC_Invalid
* was added for the case that the passed cursor in not a declaration.
*/
Storage_Class :: enum c.int {
	Invalid,
	None,
	Extern,
	Static,
	PrivateExtern,
	OpenCLWorkGroupLocal,
	Auto,
	Register,
}

/**
* Represents a specific kind of binary operator which can appear at a cursor.
*/
CX_Binary_Operator_Kind :: enum c.int {
	Invalid   = 0,
	PtrMemD   = 1,
	PtrMemI   = 2,
	Mul       = 3,
	Div       = 4,
	Rem       = 5,
	Add       = 6,
	Sub       = 7,
	Shl       = 8,
	Shr       = 9,
	Cmp       = 10,
	LT        = 11,
	GT        = 12,
	LE        = 13,
	GE        = 14,
	EQ        = 15,
	NE        = 16,
	And       = 17,
	Xor       = 18,
	Or        = 19,
	LAnd      = 20,
	LOr       = 21,
	Assign    = 22,
	MulAssign = 23,
	DivAssign = 24,
	RemAssign = 25,
	AddAssign = 26,
	SubAssign = 27,
	ShlAssign = 28,
	ShrAssign = 29,
	AndAssign = 30,
	XorAssign = 31,
	OrAssign  = 32,
	Comma     = 33,
	LAST      = 33,
}

/**
* Describes how the traversal of the children of a particular
* cursor should proceed after visiting a particular child cursor.
*
* A value of this enumeration type should be returned by each
* \c CXCursorVisitor to indicate how clang_visitChildren() proceed.
*/
Child_Visit_Result :: enum c.int {
	/**
	* Terminates the cursor traversal.
	*/
	Break,

	/**
	* Continues the cursor traversal with the next sibling of
	* the cursor just visited, without visiting its children.
	*/
	Continue,

	/**
	* Recursively traverse the children of this cursor, using
	* the same visitor and client data.
	*/
	Recurse,
}

/**
* Visitor invoked for each cursor found by a traversal.
*
* This visitor function will be invoked for each cursor found by
* clang_visitCursorChildren(). Its first argument is the cursor being
* visited, its second argument is the parent visitor for that cursor,
* and its third argument is the client data provided to
* clang_visitCursorChildren().
*
* The visitor should return one of the \c CXChildVisitResult values
* to direct clang_visitCursorChildren().
*/
Cursor_Visitor :: proc "c" (Cursor, Cursor, Client_Data) -> Child_Visit_Result

Cursor_Visitor_Block :: struct {}

/**
* Opaque pointer representing a policy that controls pretty printing
* for \c clang_getCursorPrettyPrinted.
*/
Printing_Policy :: rawptr

/**
* Properties for the printing policy.
*
* See \c clang::PrintingPolicy for more information.
*/
Printing_Policy_Property :: enum c.int {
	Indentation,
	SuppressSpecifiers,
	SuppressTagKeyword,
	IncludeTagDefinition,
	SuppressScope,
	SuppressUnwrittenScope,
	SuppressInitializers,
	ConstantArraySizeAsWritten,
	AnonymousTagLocations,
	SuppressStrongLifetime,
	SuppressLifetimeQualifiers,
	SuppressTemplateArgsInCXXConstructors,
	Bool,
	Restrict,
	Alignof,
	UnderscoreAlignof,
	UseVoidForZeroParams,
	TerseOutput,
	PolishForDeclaration,
	Half,
	MSWChar,
	IncludeNewlines,
	MSVCFormatting,
	ConstantsAsWritten,
	SuppressImplicitBase,
	FullyQualifiedName,
	LastProperty = 25,
}

/**
* Property attributes for a \c CXCursor_ObjCPropertyDecl.
*/
Obj_Cproperty_Attr_Kind :: enum c.int {
	noattr            = 0,
	readonly          = 1,
	getter            = 2,
	assign            = 4,
	readwrite         = 8,
	retain            = 16,
	copy              = 32,
	nonatomic         = 64,
	setter            = 128,
	atomic            = 256,
	weak              = 512,
	strong            = 1024,
	unsafe_unretained = 2048,
	class             = 4096,
}

/**
* 'Qualifiers' written next to the return and parameter types in
* Objective-C method declarations.
*/
Obj_Cdecl_Qualifier_Kind :: enum c.int {
	None   = 0,
	In     = 1,
	Inout  = 2,
	Out    = 4,
	Bycopy = 8,
	Byref  = 16,
	Oneway = 32,
}

/**
* \defgroup CINDEX_MODULE Module introspection
*
* The functions in this group provide access to information about modules.
*
* @{
*/
CXModule :: rawptr

Name_Ref_Flags :: enum c.int {
	/**
	* Include the nested-name-specifier, e.g. Foo:: in x.Foo::y, in the
	* range.
	*/
	Qualifier = 1,

	/**
	* Include the explicit template arguments, e.g. \<int> in x.f<int>,
	* in the range.
	*/
	TemplateArgs = 2,

	/**
	* If the name is non-contiguous, return the full spanning range.
	*
	* Non-contiguous names occur in Objective-C when a selector with two or more
	* parameters is used, or in C++ when using an operator:
	* \code
	* [object doSomething:here withValue:there]; // Objective-C
	* return some_vector[1]; // C++
	* \endcode
	*/
	SinglePiece = 4,
}

/**
* Describes a kind of token.
*/
Token_Kind :: enum c.int {
	/**
	* A token that contains some kind of punctuation.
	*/
	Punctuation,

	/**
	* A language keyword.
	*/
	Keyword,

	/**
	* An identifier (that is not a keyword).
	*/
	Identifier,

	/**
	* A numeric, string, or character literal.
	*/
	Literal,

	/**
	* A comment.
	*/
	Comment,
}

/**
* Describes a single preprocessing token.
*/
Token :: struct {
	int_data: [4]c.uint,
	ptr_data: rawptr,
}

/**
* A semantic string that describes a code-completion result.
*
* A semantic string that describes the formatting of a code-completion
* result as a single "template" of text that should be inserted into the
* source buffer when a particular code-completion result is selected.
* Each semantic string is made up of some number of "chunks", each of which
* contains some text along with a description of what that text means, e.g.,
* the name of the entity being referenced, whether the text chunk is part of
* the template, or whether it is a "placeholder" that the user should replace
* with actual code,of a specific kind. See \c CXCompletionChunkKind for a
* description of the different kinds of chunks.
*/
Completion_String :: rawptr

/**
* A single result of code completion.
*/
Completion_Result :: struct {
	/**
	* The kind of entity that this completion refers to.
	*
	* The cursor kind will be a macro, keyword, or a declaration (one of the
	* *Decl cursor kinds), describing the entity that the completion is
	* referring to.
	*
	* \todo In the future, we would like to provide a full cursor, to allow
	* the client to extract additional information from declaration.
	*/
	CursorKind: Cursor_Kind,

	/**
	* The code-completion string that describes how to insert this
	* code-completion result into the editing buffer.
	*/
	CompletionString: Completion_String,
}

/**
* Describes a single piece of text within a code-completion string.
*
* Each "chunk" within a code-completion string (\c CXCompletionString) is
* either a piece of text with a specific "kind" that describes how that text
* should be interpreted by the client or is another completion string.
*/
Completion_Chunk_Kind :: enum c.int {
	/**
	* A code-completion string that describes "optional" text that
	* could be a part of the template (but is not required).
	*
	* The Optional chunk is the only kind of chunk that has a code-completion
	* string for its representation, which is accessible via
	* \c clang_getCompletionChunkCompletionString(). The code-completion string
	* describes an additional part of the template that is completely optional.
	* For example, optional chunks can be used to describe the placeholders for
	* arguments that match up with defaulted function parameters, e.g. given:
	*
	* \code
	* void f(int x, float y = 3.14, double z = 2.71828);
	* \endcode
	*
	* The code-completion string for this function would contain:
	*   - a TypedText chunk for "f".
	*   - a LeftParen chunk for "(".
	*   - a Placeholder chunk for "int x"
	*   - an Optional chunk containing the remaining defaulted arguments, e.g.,
	*       - a Comma chunk for ","
	*       - a Placeholder chunk for "float y"
	*       - an Optional chunk containing the last defaulted argument:
	*           - a Comma chunk for ","
	*           - a Placeholder chunk for "double z"
	*   - a RightParen chunk for ")"
	*
	* There are many ways to handle Optional chunks. Two simple approaches are:
	*   - Completely ignore optional chunks, in which case the template for the
	*     function "f" would only include the first parameter ("int x").
	*   - Fully expand all optional chunks, in which case the template for the
	*     function "f" would have all of the parameters.
	*/
	Optional,

	/**
	* Text that a user would be expected to type to get this
	* code-completion result.
	*
	* There will be exactly one "typed text" chunk in a semantic string, which
	* will typically provide the spelling of a keyword or the name of a
	* declaration that could be used at the current code point. Clients are
	* expected to filter the code-completion results based on the text in this
	* chunk.
	*/
	TypedText,

	/**
	* Text that should be inserted as part of a code-completion result.
	*
	* A "text" chunk represents text that is part of the template to be
	* inserted into user code should this particular code-completion result
	* be selected.
	*/
	Text,

	/**
	* Placeholder text that should be replaced by the user.
	*
	* A "placeholder" chunk marks a place where the user should insert text
	* into the code-completion template. For example, placeholders might mark
	* the function parameters for a function declaration, to indicate that the
	* user should provide arguments for each of those parameters. The actual
	* text in a placeholder is a suggestion for the text to display before
	* the user replaces the placeholder with real code.
	*/
	Placeholder,

	/**
	* Informative text that should be displayed but never inserted as
	* part of the template.
	*
	* An "informative" chunk contains annotations that can be displayed to
	* help the user decide whether a particular code-completion result is the
	* right option, but which is not part of the actual template to be inserted
	* by code completion.
	*/
	Informative,

	/**
	* Text that describes the current parameter when code-completion is
	* referring to function call, message send, or template specialization.
	*
	* A "current parameter" chunk occurs when code-completion is providing
	* information about a parameter corresponding to the argument at the
	* code-completion point. For example, given a function
	*
	* \code
	* int add(int x, int y);
	* \endcode
	*
	* and the source code \c add(, where the code-completion point is after the
	* "(", the code-completion string will contain a "current parameter" chunk
	* for "int x", indicating that the current argument will initialize that
	* parameter. After typing further, to \c add(17, (where the code-completion
	* point is after the ","), the code-completion string will contain a
	* "current parameter" chunk to "int y".
	*/
	CurrentParameter,

	/**
	* A left parenthesis ('('), used to initiate a function call or
	* signal the beginning of a function parameter list.
	*/
	LeftParen,

	/**
	* A right parenthesis (')'), used to finish a function call or
	* signal the end of a function parameter list.
	*/
	RightParen,

	/**
	* A left bracket ('[').
	*/
	LeftBracket,

	/**
	* A right bracket (']').
	*/
	RightBracket,

	/**
	* A left brace ('{').
	*/
	LeftBrace,

	/**
	* A right brace ('}').
	*/
	RightBrace,

	/**
	* A left angle bracket ('<').
	*/
	LeftAngle,

	/**
	* A right angle bracket ('>').
	*/
	RightAngle,

	/**
	* A comma separator (',').
	*/
	Comma,

	/**
	* Text that specifies the result type of a given result.
	*
	* This special kind of informative chunk is not meant to be inserted into
	* the text buffer. Rather, it is meant to illustrate the type that an
	* expression using the given completion string would have.
	*/
	ResultType,

	/**
	* A colon (':').
	*/
	Colon,

	/**
	* A semicolon (';').
	*/
	SemiColon,

	/**
	* An '=' sign.
	*/
	Equal,

	/**
	* Horizontal space (' ').
	*/
	HorizontalSpace,

	/**
	* Vertical space ('\\n'), after which it is generally a good idea to
	* perform indentation.
	*/
	VerticalSpace,
}

/**
* Contains the results of code-completion.
*
* This data structure contains the results of code completion, as
* produced by \c clang_codeCompleteAt(). Its contents must be freed by
* \c clang_disposeCodeCompleteResults.
*/
Code_Complete_Results :: struct {
	/**
	* The code-completion results.
	*/
	Results: ^Completion_Result,

	/**
	* The number of code-completion results stored in the
	* \c Results array.
	*/
	NumResults: c.uint,
}

/**
* Flags that can be passed to \c clang_codeCompleteAt() to
* modify its behavior.
*
* The enumerators in this enumeration can be bitwise-OR'd together to
* provide multiple options to \c clang_codeCompleteAt().
*/
Code_Complete_Flags :: enum c.int {
	/**
	* Whether to include macros within the set of code
	* completions returned.
	*/
	IncludeMacros = 1,

	/**
	* Whether to include code patterns for language constructs
	* within the set of code completions, e.g., for loops.
	*/
	IncludeCodePatterns = 2,

	/**
	* Whether to include brief documentation within the set of code
	* completions returned.
	*/
	IncludeBriefComments = 4,

	/**
	* Whether to speed up completion by omitting top- or namespace-level entities
	* defined in the preamble. There's no guarantee any particular entity is
	* omitted. This may be useful if the headers are indexed externally.
	*/
	SkipPreamble = 8,

	/**
	* Whether to include completions with small
	* fix-its, e.g. change '.' to '->' on member access, etc.
	*/
	IncludeCompletionsWithFixIts = 16,
}

/**
* Bits that represent the context under which completion is occurring.
*
* The enumerators in this enumeration may be bitwise-OR'd together if multiple
* contexts are occurring simultaneously.
*/
Completion_Context :: enum c.int {
	/**
	* The context for completions is unexposed, as only Clang results
	* should be included. (This is equivalent to having no context bits set.)
	*/
	Unexposed = 0,

	/**
	* Completions for any possible type should be included in the results.
	*/
	AnyType = 1,

	/**
	* Completions for any possible value (variables, function calls, etc.)
	* should be included in the results.
	*/
	AnyValue = 2,

	/**
	* Completions for values that resolve to an Objective-C object should
	* be included in the results.
	*/
	ObjCObjectValue = 4,

	/**
	* Completions for values that resolve to an Objective-C selector
	* should be included in the results.
	*/
	ObjCSelectorValue = 8,

	/**
	* Completions for values that resolve to a C++ class type should be
	* included in the results.
	*/
	CXXClassTypeValue = 16,

	/**
	* Completions for fields of the member being accessed using the dot
	* operator should be included in the results.
	*/
	DotMemberAccess = 32,

	/**
	* Completions for fields of the member being accessed using the arrow
	* operator should be included in the results.
	*/
	ArrowMemberAccess = 64,

	/**
	* Completions for properties of the Objective-C object being accessed
	* using the dot operator should be included in the results.
	*/
	ObjCPropertyAccess = 128,

	/**
	* Completions for enum tags should be included in the results.
	*/
	EnumTag = 256,

	/**
	* Completions for union tags should be included in the results.
	*/
	UnionTag = 512,

	/**
	* Completions for struct tags should be included in the results.
	*/
	StructTag = 1024,

	/**
	* Completions for C++ class names should be included in the results.
	*/
	ClassTag = 2048,

	/**
	* Completions for C++ namespaces and namespace aliases should be
	* included in the results.
	*/
	Namespace = 4096,

	/**
	* Completions for C++ nested name specifiers should be included in
	* the results.
	*/
	NestedNameSpecifier = 8192,

	/**
	* Completions for Objective-C interfaces (classes) should be included
	* in the results.
	*/
	ObjCInterface = 16384,

	/**
	* Completions for Objective-C protocols should be included in
	* the results.
	*/
	ObjCProtocol = 32768,

	/**
	* Completions for Objective-C categories should be included in
	* the results.
	*/
	ObjCCategory = 65536,

	/**
	* Completions for Objective-C instance messages should be included
	* in the results.
	*/
	ObjCInstanceMessage = 131072,

	/**
	* Completions for Objective-C class messages should be included in
	* the results.
	*/
	ObjCClassMessage = 262144,

	/**
	* Completions for Objective-C selector names should be included in
	* the results.
	*/
	ObjCSelectorName = 524288,

	/**
	* Completions for preprocessor macro names should be included in
	* the results.
	*/
	MacroName = 1048576,

	/**
	* Natural language completions should be included in the results.
	*/
	NaturalLanguage = 2097152,

	/**
	* #include file completions should be included in the results.
	*/
	IncludedFile = 4194304,

	/**
	* The current context is unknown, so set all contexts.
	*/
	Unknown = 8388607,
}

/**
* Visitor invoked for each file in a translation unit
*        (used with clang_getInclusions()).
*
* This visitor function will be invoked by clang_getInclusions() for each
* file included (either at the top-level or by \#include directives) within
* a translation unit.  The first argument is the file being included, and
* the second and third arguments provide the inclusion stack.  The
* array is sorted in order of immediate inclusion.  For example,
* the first element refers to the location that included 'included_file'.
*/
Inclusion_Visitor :: proc "c" (File, ^Source_Location, c.uint, Client_Data)

Eval_Result_Kind :: enum c.int {
	Int            = 1,
	Float          = 2,
	ObjCStrLiteral = 3,
	StrLiteral     = 4,
	CFStr          = 5,
	Other          = 6,
	UnExposed      = 0,
}

/**
* Evaluation result of a cursor
*/
Eval_Result :: rawptr

/**
* A remapping of original source files and their translated files.
*/
Remapping :: rawptr

/** \defgroup CINDEX_HIGH Higher level API functions
*
* @{
*/
Visitor_Result :: enum c.int {
	Break,
	Continue,
}

Cursor_And_Range_Visitor :: struct {
	_context: rawptr,
	visit:    proc "c" (rawptr, Cursor, Source_Range) -> Visitor_Result,
}

Result :: enum c.int {
	/**
	* Function returned successfully.
	*/
	Success = 0,

	/**
	* One of the parameters was invalid for the function.
	*/
	Invalid = 1,

	/**
	* The function was terminated by a callback (e.g. it returned
	* CXVisit_Break)
	*/
	VisitBreak = 2,
}

Cursor_And_Range_Visitor_Block :: struct {}

/**
* The client's data object that is associated with a CXFile.
*/
Idx_Client_File :: rawptr

/**
* The client's data object that is associated with a semantic entity.
*/
Idx_Client_Entity :: rawptr

/**
* The client's data object that is associated with a semantic container
* of entities.
*/
Idx_Client_Container :: rawptr

/**
* The client's data object that is associated with an AST file (PCH
* or module).
*/
Idx_Client_Astfile :: rawptr

/**
* Source location passed to index callbacks.
*/
Idx_Loc :: struct {
	ptr_data: [2]rawptr,
	int_data: c.uint,
}

/**
* Data for ppIncludedFile callback.
*/
Idx_Included_File_Info :: struct {
	/**
	* Location of '#' in the \#include/\#import directive.
	*/
	hashLoc: Idx_Loc,

	/**
	* Filename as written in the \#include/\#import directive.
	*/
	filename: cstring,

	/**
	* The actual file that the \#include/\#import directive resolved to.
	*/
	file: File,
	isImport: c.int,
	isAngled: c.int,

	/**
	* Non-zero if the directive was automatically turned into a module
	* import.
	*/
	isModuleImport: c.int,
}

/**
* Data for IndexerCallbacks#importedASTFile.
*/
Idx_Imported_Astfile_Info :: struct {
	/**
	* Top level AST file containing the imported PCH, module or submodule.
	*/
	file: File,

	/**
	* The imported module or NULL if the AST file is a PCH.
	*/
	module: CXModule,

	/**
	* Location where the file is imported. Applicable only for modules.
	*/
	loc: Idx_Loc,

	/**
	* Non-zero if an inclusion directive was automatically turned into
	* a module import. Applicable only for modules.
	*/
	isImplicit: c.int,
}

Idx_Entity_Kind :: enum c.int {
	Unexposed             = 0,
	Typedef               = 1,
	Function              = 2,
	Variable              = 3,
	Field                 = 4,
	EnumConstant          = 5,
	ObjCClass             = 6,
	ObjCProtocol          = 7,
	ObjCCategory          = 8,
	ObjCInstanceMethod    = 9,
	ObjCClassMethod       = 10,
	ObjCProperty          = 11,
	ObjCIvar              = 12,
	Enum                  = 13,
	Struct                = 14,
	Union                 = 15,
	CXXClass              = 16,
	CXXNamespace          = 17,
	CXXNamespaceAlias     = 18,
	CXXStaticVariable     = 19,
	CXXStaticMethod       = 20,
	CXXInstanceMethod     = 21,
	CXXConstructor        = 22,
	CXXDestructor         = 23,
	CXXConversionFunction = 24,
	CXXTypeAlias          = 25,
	CXXInterface          = 26,
	CXXConcept            = 27,
}

Idx_Entity_Language :: enum c.int {
	None  = 0,
	C     = 1,
	ObjC  = 2,
	CXX   = 3,
	Swift = 4,
}

/**
* Extra C++ template information for an entity. This can apply to:
* CXIdxEntity_Function
* CXIdxEntity_CXXClass
* CXIdxEntity_CXXStaticMethod
* CXIdxEntity_CXXInstanceMethod
* CXIdxEntity_CXXConstructor
* CXIdxEntity_CXXConversionFunction
* CXIdxEntity_CXXTypeAlias
*/
Idx_Entity_Cxxtemplate_Kind :: enum c.int {
	NonTemplate                   = 0,
	Template                      = 1,
	TemplatePartialSpecialization = 2,
	TemplateSpecialization        = 3,
}

Idx_Attr_Kind :: enum c.int {
	Unexposed          = 0,
	IBAction           = 1,
	IBOutlet           = 2,
	IBOutletCollection = 3,
}

Idx_Attr_Info :: struct {
	kind:   Idx_Attr_Kind,
	cursor: Cursor,
	loc:    Idx_Loc,
}

Idx_Entity_Info :: struct {
	kind:          Idx_Entity_Kind,
	templateKind:  Idx_Entity_Cxxtemplate_Kind,
	lang:          Idx_Entity_Language,
	name:          cstring,
	USR:           cstring,
	cursor:        Cursor,
	attributes:    ^^Idx_Attr_Info,
	numAttributes: c.uint,
}

Idx_Container_Info :: struct {
	cursor: Cursor,
}

Idx_Iboutlet_Collection_Attr_Info :: struct {
	attrInfo:    ^Idx_Attr_Info,
	objcClass:   ^Idx_Entity_Info,
	classCursor: Cursor,
	classLoc:    Idx_Loc,
}

Idx_Decl_Info_Flags :: enum c.int {
	CXIdxDeclFlag_Skipped = 1,
}

Idx_Decl_Info :: struct {
	entityInfo:        ^Idx_Entity_Info,
	cursor:            Cursor,
	loc:               Idx_Loc,
	semanticContainer: ^Idx_Container_Info,

	/**
	* Generally same as #semanticContainer but can be different in
	* cases like out-of-line C++ member functions.
	*/
	lexicalContainer: ^Idx_Container_Info,
	isRedeclaration:   c.int,
	isDefinition:      c.int,
	isContainer:       c.int,
	declAsContainer:   ^Idx_Container_Info,

	/**
	* Whether the declaration exists in code or was created implicitly
	* by the compiler, e.g. implicit Objective-C methods for properties.
	*/
	isImplicit: c.int,
	attributes:        ^^Idx_Attr_Info,
	numAttributes:     c.uint,
	flags:             c.uint,
}

Idx_Obj_Ccontainer_Kind :: enum c.int {
	ForwardRef     = 0,
	Interface      = 1,
	Implementation = 2,
}

Idx_Obj_Ccontainer_Decl_Info :: struct {
	declInfo: ^Idx_Decl_Info,
	kind:     Idx_Obj_Ccontainer_Kind,
}

Idx_Base_Class_Info :: struct {
	base:   ^Idx_Entity_Info,
	cursor: Cursor,
	loc:    Idx_Loc,
}

Idx_Obj_Cprotocol_Ref_Info :: struct {
	protocol: ^Idx_Entity_Info,
	cursor:   Cursor,
	loc:      Idx_Loc,
}

Idx_Obj_Cprotocol_Ref_List_Info :: struct {
	protocols:    ^^Idx_Obj_Cprotocol_Ref_Info,
	numProtocols: c.uint,
}

Idx_Obj_Cinterface_Decl_Info :: struct {
	containerInfo: ^Idx_Obj_Ccontainer_Decl_Info,
	superInfo:     ^Idx_Base_Class_Info,
	protocols:     ^Idx_Obj_Cprotocol_Ref_List_Info,
}

Idx_Obj_Ccategory_Decl_Info :: struct {
	containerInfo: ^Idx_Obj_Ccontainer_Decl_Info,
	objcClass:     ^Idx_Entity_Info,
	classCursor:   Cursor,
	classLoc:      Idx_Loc,
	protocols:     ^Idx_Obj_Cprotocol_Ref_List_Info,
}

Idx_Obj_Cproperty_Decl_Info :: struct {
	declInfo: ^Idx_Decl_Info,
	getter:   ^Idx_Entity_Info,
	setter:   ^Idx_Entity_Info,
}

Idx_Cxxclass_Decl_Info :: struct {
	declInfo: ^Idx_Decl_Info,
	bases:    ^^Idx_Base_Class_Info,
	numBases: c.uint,
}

/**
* Data for IndexerCallbacks#indexEntityReference.
*
* This may be deprecated in a future version as this duplicates
* the \c CXSymbolRole_Implicit bit in \c CXSymbolRole.
*/
Idx_Entity_Ref_Kind :: enum c.int {
	/**
	* The entity is referenced directly in user's code.
	*/
	Direct = 1,

	/**
	* An implicit reference, e.g. a reference of an Objective-C method
	* via the dot syntax.
	*/
	Implicit = 2,
}

/**
* Roles that are attributed to symbol occurrences.
*
* Internal: this currently mirrors low 9 bits of clang::index::SymbolRole with
* higher bits zeroed. These high bits may be exposed in the future.
*/
Symbol_Role :: enum c.int {
	None        = 0,
	Declaration = 1,
	Definition  = 2,
	Reference   = 4,
	Read        = 8,
	Write       = 16,
	Call        = 32,
	Dynamic     = 64,
	AddressOf   = 128,
	Implicit    = 256,
}

/**
* Data for IndexerCallbacks#indexEntityReference.
*/
Idx_Entity_Ref_Info :: struct {
	kind: Idx_Entity_Ref_Kind,

	/**
	* Reference cursor.
	*/
	cursor: Cursor,
	loc:  Idx_Loc,

	/**
	* The entity that gets referenced.
	*/
	referencedEntity: ^Idx_Entity_Info,

	/**
	* Immediate "parent" of the reference. For example:
	*
	* \code
	* Foo *var;
	* \endcode
	*
	* The parent of reference of type 'Foo' is the variable 'var'.
	* For references inside statement bodies of functions/methods,
	* the parentEntity will be the function/method.
	*/
	parentEntity: ^Idx_Entity_Info,

	/**
	* Lexical container context of the reference.
	*/
	container: ^Idx_Container_Info,

	/**
	* Sets of symbol roles of the reference.
	*/
	role: Symbol_Role,
}

/**
* A group of callbacks used by #clang_indexSourceFile and
* #clang_indexTranslationUnit.
*/
Indexer_Callbacks :: struct {
	/**
	* Called periodically to check whether indexing should be aborted.
	* Should return 0 to continue, and non-zero to abort.
	*/
	abortQuery: proc "c" (Client_Data, rawptr) -> c.int,

	/**
	* Called at the end of indexing; passes the complete diagnostic set.
	*/
	diagnostic: proc "c" (Client_Data, Diagnostic_Set, rawptr),
	enteredMainFile:  proc "c" (Client_Data, File, rawptr) -> Idx_Client_File,

	/**
	* Called when a file gets \#included/\#imported.
	*/
	ppIncludedFile: proc "c" (Client_Data, ^Idx_Included_File_Info) -> Idx_Client_File,

	/**
	* Called when a AST file (PCH or module) gets imported.
	*
	* AST files will not get indexed (there will not be callbacks to index all
	* the entities in an AST file). The recommended action is that, if the AST
	* file is not already indexed, to initiate a new indexing job specific to
	* the AST file.
	*/
	importedASTFile: proc "c" (Client_Data, ^Idx_Imported_Astfile_Info) -> Idx_Client_Astfile,

	/**
	* Called at the beginning of indexing a translation unit.
	*/
	startedTranslationUnit: proc "c" (Client_Data, rawptr) -> Idx_Client_Container,
	indexDeclaration: proc "c" (Client_Data, ^Idx_Decl_Info),

	/**
	* Called to index a reference of an entity.
	*/
	indexEntityReference: proc "c" (Client_Data, ^Idx_Entity_Ref_Info),
}

/**
* An indexing action/session, to be applied to one or multiple
* translation units.
*/
Index_Action :: rawptr

Index_Opt_Flags :: enum c.int {
	/**
	* Used to indicate that no special indexing options are needed.
	*/
	None = 0,

	/**
	* Used to indicate that IndexerCallbacks#indexEntityReference should
	* be invoked for only one reference of an entity per source file that does
	* not also include a declaration/definition of the entity.
	*/
	SuppressRedundantRefs = 1,

	/**
	* Function-local symbols should be indexed. If this is not set
	* function-local symbols will be ignored.
	*/
	IndexFunctionLocalSymbols = 2,

	/**
	* Implicit function/class template instantiations should be indexed.
	* If this is not set, implicit instantiations will be ignored.
	*/
	IndexImplicitTemplateInstantiations = 4,

	/**
	* Suppress all compiler warnings when parsing for indexing.
	*/
	SuppressWarnings = 8,

	/**
	* Skip a function/method body that was already parsed during an
	* indexing session associated with a \c CXIndexAction object.
	* Bodies in system headers are always skipped.
	*/
	SkipParsedBodiesInSession = 16,
}

/**
* Visitor invoked for each field found by a traversal.
*
* This visitor function will be invoked for each field found by
* \c clang_Type_visitFields. Its first argument is the cursor being
* visited, its second argument is the client data provided to
* \c clang_Type_visitFields.
*
* The visitor should return one of the \c CXVisitorResult values
* to direct \c clang_Type_visitFields.
*/
Field_Visitor :: proc "c" (Cursor, Client_Data) -> Visitor_Result

/**
* Describes the kind of binary operators.
*/
CXBinary_Operator_Kind :: enum c.int {
	/** This value describes cursors which are not binary operators. */
	Invalid,

	/** C++ Pointer - to - member operator. */
	PtrMemD,

	/** C++ Pointer - to - member operator. */
	PtrMemI,

	/** Multiplication operator. */
	Mul,

	/** Division operator. */
	Div,

	/** Remainder operator. */
	Rem,

	/** Addition operator. */
	Add,

	/** Subtraction operator. */
	Sub,

	/** Bitwise shift left operator. */
	Shl,

	/** Bitwise shift right operator. */
	Shr,

	/** C++ three-way comparison (spaceship) operator. */
	Cmp,

	/** Less than operator. */
	LT,

	/** Greater than operator. */
	GT,

	/** Less or equal operator. */
	LE,

	/** Greater or equal operator. */
	GE,

	/** Equal operator. */
	EQ,

	/** Not equal operator. */
	NE,

	/** Bitwise AND operator. */
	And,

	/** Bitwise XOR operator. */
	Xor,

	/** Bitwise OR operator. */
	Or,

	/** Logical AND operator. */
	LAnd,

	/** Logical OR operator. */
	LOr,

	/** Assignment operator. */
	Assign,

	/** Multiplication assignment operator. */
	MulAssign,

	/** Division assignment operator. */
	DivAssign,

	/** Remainder assignment operator. */
	RemAssign,

	/** Addition assignment operator. */
	AddAssign,

	/** Subtraction assignment operator. */
	SubAssign,

	/** Bitwise shift left assignment operator. */
	ShlAssign,

	/** Bitwise shift right assignment operator. */
	ShrAssign,

	/** Bitwise AND assignment operator. */
	AndAssign,

	/** Bitwise XOR assignment operator. */
	XorAssign,

	/** Bitwise OR assignment operator. */
	OrAssign,

	/** Comma operator. */
	Comma,
}

/**
* Describes the kind of unary operators.
*/
Unary_Operator_Kind :: enum c.int {
	/** This value describes cursors which are not unary operators. */
	Invalid,

	/** Postfix increment operator. */
	PostInc,

	/** Postfix decrement operator. */
	PostDec,

	/** Prefix increment operator. */
	PreInc,

	/** Prefix decrement operator. */
	PreDec,

	/** Address of operator. */
	AddrOf,

	/** Dereference operator. */
	Deref,

	/** Plus operator. */
	Plus,

	/** Minus operator. */
	Minus,

	/** Not operator. */
	Not,

	/** LNot operator. */
	LNot,

	/** "__real expr" operator. */
	Real,

	/** "__imag expr" operator. */
	Imag,

	/** __extension__ marker operator. */
	Extension,

	/** C++ co_await operator. */
	Coawait,
}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Provides a shared context for creating translation units.
	*
	* It provides two options:
	*
	* - excludeDeclarationsFromPCH: When non-zero, allows enumeration of "local"
	* declarations (when loading any new translation units). A "local" declaration
	* is one that belongs in the translation unit itself and not in a precompiled
	* header that was used by the translation unit. If zero, all declarations
	* will be enumerated.
	*
	* Here is an example:
	*
	* \code
	*   // excludeDeclsFromPCH = 1, displayDiagnostics=1
	*   Idx = clang_createIndex(1, 1);
	*
	*   // IndexTest.pch was produced with the following command:
	*   // "clang -x c IndexTest.h -emit-ast -o IndexTest.pch"
	*   TU = clang_createTranslationUnit(Idx, "IndexTest.pch");
	*
	*   // This will load all the symbols from 'IndexTest.pch'
	*   clang_visitChildren(clang_getTranslationUnitCursor(TU),
	*                       TranslationUnitVisitor, 0);
	*   clang_disposeTranslationUnit(TU);
	*
	*   // This will load all the symbols from 'IndexTest.c', excluding symbols
	*   // from 'IndexTest.pch'.
	*   char *args[] = { "-Xclang", "-include-pch=IndexTest.pch" };
	*   TU = clang_createTranslationUnitFromSourceFile(Idx, "IndexTest.c", 2, args,
	*                                                  0, 0);
	*   clang_visitChildren(clang_getTranslationUnitCursor(TU),
	*                       TranslationUnitVisitor, 0);
	*   clang_disposeTranslationUnit(TU);
	* \endcode
	*
	* This process of creating the 'pch', loading it separately, and using it (via
	* -include-pch) allows 'excludeDeclsFromPCH' to remove redundant callbacks
	* (which gives the indexer the same performance benefit as the compiler).
	*/
	createIndex :: proc(excludeDeclarationsFromPCH: c.int, displayDiagnostics: c.int) -> Index ---

	/**
	* Destroy the given index.
	*
	* The index must not be destroyed until all of the translation units created
	* within that index have been destroyed.
	*/
	disposeIndex :: proc(index: Index) ---

	/**
	* Provides a shared context for creating translation units.
	*
	* Call this function instead of clang_createIndex() if you need to configure
	* the additional options in CXIndexOptions.
	*
	* \returns The created index or null in case of error, such as an unsupported
	* value of options->Size.
	*
	* For example:
	* \code
	* CXIndex createIndex(const char *ApplicationTemporaryPath) {
	*   const int ExcludeDeclarationsFromPCH = 1;
	*   const int DisplayDiagnostics = 1;
	*   CXIndex Idx;
	* #if CINDEX_VERSION_MINOR >= 64
	*   CXIndexOptions Opts;
	*   memset(&Opts, 0, sizeof(Opts));
	*   Opts.Size = sizeof(CXIndexOptions);
	*   Opts.ThreadBackgroundPriorityForIndexing = 1;
	*   Opts.ExcludeDeclarationsFromPCH = ExcludeDeclarationsFromPCH;
	*   Opts.DisplayDiagnostics = DisplayDiagnostics;
	*   Opts.PreambleStoragePath = ApplicationTemporaryPath;
	*   Idx = clang_createIndexWithOptions(&Opts);
	*   if (Idx)
	*     return Idx;
	*   fprintf(stderr,
	*           "clang_createIndexWithOptions() failed. "
	*           "CINDEX_VERSION_MINOR = %d, sizeof(CXIndexOptions) = %u\n",
	*           CINDEX_VERSION_MINOR, Opts.Size);
	* #else
	*   (void)ApplicationTemporaryPath;
	* #endif
	*   Idx = clang_createIndex(ExcludeDeclarationsFromPCH, DisplayDiagnostics);
	*   clang_CXIndex_setGlobalOptions(
	*       Idx, clang_CXIndex_getGlobalOptions(Idx) |
	*                CXGlobalOpt_ThreadBackgroundPriorityForIndexing);
	*   return Idx;
	* }
	* \endcode
	*
	* \sa clang_createIndex()
	*/
	createIndexWithOptions :: proc(options: ^Index_Options) -> Index ---

	/**
	* Sets general options associated with a CXIndex.
	*
	* This function is DEPRECATED. Set
	* CXIndexOptions::ThreadBackgroundPriorityForIndexing and/or
	* CXIndexOptions::ThreadBackgroundPriorityForEditing and call
	* clang_createIndexWithOptions() instead.
	*
	* For example:
	* \code
	* CXIndex idx = ...;
	* clang_CXIndex_setGlobalOptions(idx,
	*     clang_CXIndex_getGlobalOptions(idx) |
	*     CXGlobalOpt_ThreadBackgroundPriorityForIndexing);
	* \endcode
	*
	* \param options A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags.
	*/
	CXIndex_setGlobalOptions :: proc(_: Index, options: c.uint) ---

	/**
	* Gets the general options associated with a CXIndex.
	*
	* This function allows to obtain the final option values used by libclang after
	* specifying the option policies via CXChoice enumerators.
	*
	* \returns A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags that
	* are associated with the given CXIndex object.
	*/
	CXIndex_getGlobalOptions :: proc(_: Index) -> c.uint ---

	/**
	* Sets the invocation emission path option in a CXIndex.
	*
	* This function is DEPRECATED. Set CXIndexOptions::InvocationEmissionPath and
	* call clang_createIndexWithOptions() instead.
	*
	* The invocation emission path specifies a path which will contain log
	* files for certain libclang invocations. A null value (default) implies that
	* libclang invocations are not logged..
	*/
	CXIndex_setInvocationEmissionPathOption :: proc(_: Index, Path: cstring) ---

	/**
	* Determine whether the given header is guarded against
	* multiple inclusions, either with the conventional
	* \#ifndef/\#define/\#endif macro guards or with \#pragma once.
	*/
	isFileMultipleIncludeGuarded :: proc(tu: Translation_Unit, file: File) -> c.uint ---

	/**
	* Retrieve a file handle within the given translation unit.
	*
	* \param tu the translation unit
	*
	* \param file_name the name of the file.
	*
	* \returns the file handle for the named file in the translation unit \p tu,
	* or a NULL file handle if the file was not a part of this translation unit.
	*/
	getFile :: proc(tu: Translation_Unit, file_name: cstring) -> File ---

	/**
	* Retrieve the buffer associated with the given file.
	*
	* \param tu the translation unit
	*
	* \param file the file for which to retrieve the buffer.
	*
	* \param size [out] if non-NULL, will be set to the size of the buffer.
	*
	* \returns a pointer to the buffer in memory that holds the contents of
	* \p file, or a NULL pointer when the file is not loaded.
	*/
	getFileContents :: proc(tu: Translation_Unit, file: File, size: ^c.size_t) -> cstring ---

	/**
	* Retrieves the source location associated with a given file/line/column
	* in a particular translation unit.
	*/
	getLocation :: proc(tu: Translation_Unit, file: File, line: c.uint, column: c.uint) -> Source_Location ---

	/**
	* Retrieves the source location associated with a given character offset
	* in a particular translation unit.
	*/
	getLocationForOffset :: proc(tu: Translation_Unit, file: File, offset: c.uint) -> Source_Location ---

	/**
	* Retrieve all ranges that were skipped by the preprocessor.
	*
	* The preprocessor will skip lines when they are surrounded by an
	* if/ifdef/ifndef directive whose condition does not evaluate to true.
	*/
	getSkippedRanges :: proc(tu: Translation_Unit, file: File) -> ^Source_Range_List ---

	/**
	* Retrieve all ranges from all files that were skipped by the
	* preprocessor.
	*
	* The preprocessor will skip lines when they are surrounded by an
	* if/ifdef/ifndef directive whose condition does not evaluate to true.
	*/
	getAllSkippedRanges :: proc(tu: Translation_Unit) -> ^Source_Range_List ---

	/**
	* Determine the number of diagnostics produced for the given
	* translation unit.
	*/
	getNumDiagnostics :: proc(Unit: Translation_Unit) -> c.uint ---

	/**
	* Retrieve a diagnostic associated with the given translation unit.
	*
	* \param Unit the translation unit to query.
	* \param Index the zero-based diagnostic number to retrieve.
	*
	* \returns the requested diagnostic. This diagnostic must be freed
	* via a call to \c clang_disposeDiagnostic().
	*/
	getDiagnostic :: proc(Unit: Translation_Unit, Index: c.uint) -> Diagnostic ---

	/**
	* Retrieve the complete set of diagnostics associated with a
	*        translation unit.
	*
	* \param Unit the translation unit to query.
	*/
	getDiagnosticSetFromTU :: proc(Unit: Translation_Unit) -> Diagnostic_Set ---

	/**
	* Get the original translation unit source file name.
	*/
	getTranslationUnitSpelling :: proc(CTUnit: Translation_Unit) -> String ---

	/**
	* Return the CXTranslationUnit for a given source file and the provided
	* command line arguments one would pass to the compiler.
	*
	* Note: The 'source_filename' argument is optional.  If the caller provides a
	* NULL pointer, the name of the source file is expected to reside in the
	* specified command line arguments.
	*
	* Note: When encountered in 'clang_command_line_args', the following options
	* are ignored:
	*
	*   '-c'
	*   '-emit-ast'
	*   '-fsyntax-only'
	*   '-o \<output file>'  (both '-o' and '\<output file>' are ignored)
	*
	* \param CIdx The index object with which the translation unit will be
	* associated.
	*
	* \param source_filename The name of the source file to load, or NULL if the
	* source file is included in \p clang_command_line_args.
	*
	* \param num_clang_command_line_args The number of command-line arguments in
	* \p clang_command_line_args.
	*
	* \param clang_command_line_args The command-line arguments that would be
	* passed to the \c clang executable if it were being invoked out-of-process.
	* These command-line options will be parsed and will affect how the translation
	* unit is parsed. Note that the following options are ignored: '-c',
	* '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
	*
	* \param num_unsaved_files the number of unsaved file entries in \p
	* unsaved_files.
	*
	* \param unsaved_files the files that have not yet been saved to disk
	* but may be required for code completion, including the contents of
	* those files.  The contents and name of these files (as specified by
	* CXUnsavedFile) are copied when necessary, so the client only needs to
	* guarantee their validity until the call to this function returns.
	*/
	createTranslationUnitFromSourceFile :: proc(CIdx: Index, source_filename: cstring, num_clang_command_line_args: c.int, clang_command_line_args: [^]cstring, num_unsaved_files: c.uint, unsaved_files: ^Unsaved_File) -> Translation_Unit ---

	/**
	* Same as \c clang_createTranslationUnit2, but returns
	* the \c CXTranslationUnit instead of an error code.  In case of an error this
	* routine returns a \c NULL \c CXTranslationUnit, without further detailed
	* error codes.
	*/
	createTranslationUnit :: proc(CIdx: Index, ast_filename: cstring) -> Translation_Unit ---

	/**
	* Create a translation unit from an AST file (\c -emit-ast).
	*
	* \param[out] out_TU A non-NULL pointer to store the created
	* \c CXTranslationUnit.
	*
	* \returns Zero on success, otherwise returns an error code.
	*/
	createTranslationUnit2 :: proc(CIdx: Index, ast_filename: cstring, out_TU: ^Translation_Unit) -> Error_Code ---

	/**
	* Returns the set of flags that is suitable for parsing a translation
	* unit that is being edited.
	*
	* The set of flags returned provide options for \c clang_parseTranslationUnit()
	* to indicate that the translation unit is likely to be reparsed many times,
	* either explicitly (via \c clang_reparseTranslationUnit()) or implicitly
	* (e.g., by code completion (\c clang_codeCompletionAt())). The returned flag
	* set contains an unspecified set of optimizations (e.g., the precompiled
	* preamble) geared toward improving the performance of these routines. The
	* set of optimizations enabled may change from one version to the next.
	*/
	defaultEditingTranslationUnitOptions :: proc() -> c.uint ---

	/**
	* Same as \c clang_parseTranslationUnit2, but returns
	* the \c CXTranslationUnit instead of an error code.  In case of an error this
	* routine returns a \c NULL \c CXTranslationUnit, without further detailed
	* error codes.
	*/
	parseTranslationUnit :: proc(CIdx: Index, source_filename: cstring, command_line_args: [^]cstring, num_command_line_args: c.int, unsaved_files: ^Unsaved_File, num_unsaved_files: c.uint, options: Translation_Unit_Flags) -> Translation_Unit ---

	/**
	* Parse the given source file and the translation unit corresponding
	* to that file.
	*
	* This routine is the main entry point for the Clang C API, providing the
	* ability to parse a source file into a translation unit that can then be
	* queried by other functions in the API. This routine accepts a set of
	* command-line arguments so that the compilation can be configured in the same
	* way that the compiler is configured on the command line.
	*
	* \param CIdx The index object with which the translation unit will be
	* associated.
	*
	* \param source_filename The name of the source file to load, or NULL if the
	* source file is included in \c command_line_args.
	*
	* \param command_line_args The command-line arguments that would be
	* passed to the \c clang executable if it were being invoked out-of-process.
	* These command-line options will be parsed and will affect how the translation
	* unit is parsed. Note that the following options are ignored: '-c',
	* '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
	*
	* \param num_command_line_args The number of command-line arguments in
	* \c command_line_args.
	*
	* \param unsaved_files the files that have not yet been saved to disk
	* but may be required for parsing, including the contents of
	* those files.  The contents and name of these files (as specified by
	* CXUnsavedFile) are copied when necessary, so the client only needs to
	* guarantee their validity until the call to this function returns.
	*
	* \param num_unsaved_files the number of unsaved file entries in \p
	* unsaved_files.
	*
	* \param options A bitmask of options that affects how the translation unit
	* is managed but not its compilation. This should be a bitwise OR of the
	* CXTranslationUnit_XXX flags.
	*
	* \param[out] out_TU A non-NULL pointer to store the created
	* \c CXTranslationUnit, describing the parsed code and containing any
	* diagnostics produced by the compiler.
	*
	* \returns Zero on success, otherwise returns an error code.
	*/
	parseTranslationUnit2 :: proc(CIdx: Index, source_filename: cstring, command_line_args: [^]cstring, num_command_line_args: c.int, unsaved_files: ^Unsaved_File, num_unsaved_files: c.uint, options: Translation_Unit_Flags, out_TU: ^Translation_Unit) -> Error_Code ---

	/**
	* Same as clang_parseTranslationUnit2 but requires a full command line
	* for \c command_line_args including argv[0]. This is useful if the standard
	* library paths are relative to the binary.
	*/
	parseTranslationUnit2FullArgv :: proc(CIdx: Index, source_filename: cstring, command_line_args: [^]cstring, num_command_line_args: c.int, unsaved_files: ^Unsaved_File, num_unsaved_files: c.uint, options: Translation_Unit_Flags, out_TU: ^Translation_Unit) -> Error_Code ---

	/**
	* Returns the set of flags that is suitable for saving a translation
	* unit.
	*
	* The set of flags returned provide options for
	* \c clang_saveTranslationUnit() by default. The returned flag
	* set contains an unspecified set of options that save translation units with
	* the most commonly-requested data.
	*/
	defaultSaveOptions :: proc(TU: Translation_Unit) -> c.uint ---

	/**
	* Saves a translation unit into a serialized representation of
	* that translation unit on disk.
	*
	* Any translation unit that was parsed without error can be saved
	* into a file. The translation unit can then be deserialized into a
	* new \c CXTranslationUnit with \c clang_createTranslationUnit() or,
	* if it is an incomplete translation unit that corresponds to a
	* header, used as a precompiled header when parsing other translation
	* units.
	*
	* \param TU The translation unit to save.
	*
	* \param FileName The file to which the translation unit will be saved.
	*
	* \param options A bitmask of options that affects how the translation unit
	* is saved. This should be a bitwise OR of the
	* CXSaveTranslationUnit_XXX flags.
	*
	* \returns A value that will match one of the enumerators of the CXSaveError
	* enumeration. Zero (CXSaveError_None) indicates that the translation unit was
	* saved successfully, while a non-zero value indicates that a problem occurred.
	*/
	saveTranslationUnit :: proc(TU: Translation_Unit, FileName: cstring, options: c.uint) -> c.int ---

	/**
	* Suspend a translation unit in order to free memory associated with it.
	*
	* A suspended translation unit uses significantly less memory but on the other
	* side does not support any other calls than \c clang_reparseTranslationUnit
	* to resume it or \c clang_disposeTranslationUnit to dispose it completely.
	*/
	suspendTranslationUnit :: proc(_: Translation_Unit) -> c.uint ---

	/**
	* Destroy the specified CXTranslationUnit object.
	*/
	disposeTranslationUnit :: proc(_: Translation_Unit) ---

	/**
	* Returns the set of flags that is suitable for reparsing a translation
	* unit.
	*
	* The set of flags returned provide options for
	* \c clang_reparseTranslationUnit() by default. The returned flag
	* set contains an unspecified set of optimizations geared toward common uses
	* of reparsing. The set of optimizations enabled may change from one version
	* to the next.
	*/
	defaultReparseOptions :: proc(TU: Translation_Unit) -> c.uint ---

	/**
	* Reparse the source files that produced this translation unit.
	*
	* This routine can be used to re-parse the source files that originally
	* created the given translation unit, for example because those source files
	* have changed (either on disk or as passed via \p unsaved_files). The
	* source code will be reparsed with the same command-line options as it
	* was originally parsed.
	*
	* Reparsing a translation unit invalidates all cursors and source locations
	* that refer into that translation unit. This makes reparsing a translation
	* unit semantically equivalent to destroying the translation unit and then
	* creating a new translation unit with the same command-line arguments.
	* However, it may be more efficient to reparse a translation
	* unit using this routine.
	*
	* \param TU The translation unit whose contents will be re-parsed. The
	* translation unit must originally have been built with
	* \c clang_createTranslationUnitFromSourceFile().
	*
	* \param num_unsaved_files The number of unsaved file entries in \p
	* unsaved_files.
	*
	* \param unsaved_files The files that have not yet been saved to disk
	* but may be required for parsing, including the contents of
	* those files.  The contents and name of these files (as specified by
	* CXUnsavedFile) are copied when necessary, so the client only needs to
	* guarantee their validity until the call to this function returns.
	*
	* \param options A bitset of options composed of the flags in CXReparse_Flags.
	* The function \c clang_defaultReparseOptions() produces a default set of
	* options recommended for most uses, based on the translation unit.
	*
	* \returns 0 if the sources could be reparsed.  A non-zero error code will be
	* returned if reparsing was impossible, such that the translation unit is
	* invalid. In such cases, the only valid call for \c TU is
	* \c clang_disposeTranslationUnit(TU).  The error codes returned by this
	* routine are described by the \c CXErrorCode enum.
	*/
	reparseTranslationUnit :: proc(TU: Translation_Unit, num_unsaved_files: c.uint, unsaved_files: ^Unsaved_File, options: c.uint) -> c.int ---

	/**
	* Returns the human-readable null-terminated C string that represents
	*  the name of the memory category.  This string should never be freed.
	*/
	getTUResourceUsageName :: proc(kind: Turesource_Usage_Kind) -> cstring ---

	/**
	* Return the memory usage of a translation unit.  This object
	*  should be released with clang_disposeCXTUResourceUsage().
	*/
	getCXTUResourceUsage     :: proc(TU: Translation_Unit) -> Turesource_Usage ---
	disposeCXTUResourceUsage :: proc(usage: Turesource_Usage) ---

	/**
	* Get target information for this translation unit.
	*
	* The CXTargetInfo object cannot outlive the CXTranslationUnit object.
	*/
	getTranslationUnitTargetInfo :: proc(CTUnit: Translation_Unit) -> Target_Info ---

	/**
	* Destroy the CXTargetInfo object.
	*/
	TargetInfo_dispose :: proc(Info: Target_Info) ---

	/**
	* Get the normalized target triple as a string.
	*
	* Returns the empty string in case of any error.
	*/
	TargetInfo_getTriple :: proc(Info: Target_Info) -> String ---

	/**
	* Get the pointer width of the target in bits.
	*
	* Returns -1 in case of error.
	*/
	TargetInfo_getPointerWidth :: proc(Info: Target_Info) -> c.int ---

	/**
	* Retrieve the NULL cursor, which represents no entity.
	*/
	getNullCursor :: proc() -> Cursor ---

	/**
	* Retrieve the cursor that represents the given translation unit.
	*
	* The translation unit cursor can be used to start traversing the
	* various declarations within the given translation unit.
	*/
	getTranslationUnitCursor :: proc(_: Translation_Unit) -> Cursor ---

	/**
	* Determine whether two cursors are equivalent.
	*/
	equalCursors :: proc(_: Cursor, _: Cursor) -> c.uint ---

	/**
	* Returns non-zero if \p cursor is null.
	*/
	Cursor_isNull :: proc(cursor: Cursor) -> c.int ---

	/**
	* Compute a hash value for the given cursor.
	*/
	hashCursor :: proc(_: Cursor) -> c.uint ---

	/**
	* Retrieve the kind of the given cursor.
	*/
	getCursorKind :: proc(_: Cursor) -> Cursor_Kind ---

	/**
	* Determine whether the given cursor kind represents a declaration.
	*/
	isDeclaration :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine whether the given declaration is invalid.
	*
	* A declaration is invalid if it could not be parsed successfully.
	*
	* \returns non-zero if the cursor represents a declaration and it is
	* invalid, otherwise NULL.
	*/
	isInvalidDeclaration :: proc(_: Cursor) -> c.uint ---

	/**
	* Determine whether the given cursor kind represents a simple
	* reference.
	*
	* Note that other kinds of cursors (such as expressions) can also refer to
	* other cursors. Use clang_getCursorReferenced() to determine whether a
	* particular cursor refers to another entity.
	*/
	isReference :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine whether the given cursor kind represents an expression.
	*/
	isExpression :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine whether the given cursor kind represents a statement.
	*/
	isStatement :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine whether the given cursor kind represents an attribute.
	*/
	isAttribute :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine whether the given cursor has any attributes.
	*/
	Cursor_hasAttrs :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine whether the given cursor kind represents an invalid
	* cursor.
	*/
	isInvalid :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine whether the given cursor kind represents a translation
	* unit.
	*/
	isTranslationUnit :: proc(_: Cursor_Kind) -> c.uint ---

	/***
	* Determine whether the given cursor represents a preprocessing
	* element, such as a preprocessor directive or macro instantiation.
	*/
	isPreprocessing :: proc(_: Cursor_Kind) -> c.uint ---

	/***
	* Determine whether the given cursor represents a currently
	*  unexposed piece of the AST (e.g., CXCursor_UnexposedStmt).
	*/
	isUnexposed :: proc(_: Cursor_Kind) -> c.uint ---

	/**
	* Determine the linkage of the entity referred to by a given cursor.
	*/
	getCursorLinkage :: proc(cursor: Cursor) -> Linkage_Kind ---

	/**
	* Describe the visibility of the entity referred to by a cursor.
	*
	* This returns the default visibility if not explicitly specified by
	* a visibility attribute. The default visibility may be changed by
	* commandline arguments.
	*
	* \param cursor The cursor to query.
	*
	* \returns The visibility of the cursor.
	*/
	getCursorVisibility :: proc(cursor: Cursor) -> Visibility_Kind ---

	/**
	* Determine the availability of the entity that this cursor refers to,
	* taking the current target platform into account.
	*
	* \param cursor The cursor to query.
	*
	* \returns The availability of the cursor.
	*/
	getCursorAvailability :: proc(cursor: Cursor) -> Availability_Kind ---

	/**
	* Determine the availability of the entity that this cursor refers to
	* on any platforms for which availability information is known.
	*
	* \param cursor The cursor to query.
	*
	* \param always_deprecated If non-NULL, will be set to indicate whether the
	* entity is deprecated on all platforms.
	*
	* \param deprecated_message If non-NULL, will be set to the message text
	* provided along with the unconditional deprecation of this entity. The client
	* is responsible for deallocating this string.
	*
	* \param always_unavailable If non-NULL, will be set to indicate whether the
	* entity is unavailable on all platforms.
	*
	* \param unavailable_message If non-NULL, will be set to the message text
	* provided along with the unconditional unavailability of this entity. The
	* client is responsible for deallocating this string.
	*
	* \param availability If non-NULL, an array of CXPlatformAvailability instances
	* that will be populated with platform availability information, up to either
	* the number of platforms for which availability information is available (as
	* returned by this function) or \c availability_size, whichever is smaller.
	*
	* \param availability_size The number of elements available in the
	* \c availability array.
	*
	* \returns The number of platforms (N) for which availability information is
	* available (which is unrelated to \c availability_size).
	*
	* Note that the client is responsible for calling
	* \c clang_disposeCXPlatformAvailability to free each of the
	* platform-availability structures returned. There are
	* \c min(N, availability_size) such structures.
	*/
	getCursorPlatformAvailability :: proc(cursor: Cursor, always_deprecated: ^c.int, deprecated_message: ^String, always_unavailable: ^c.int, unavailable_message: ^String, availability: ^Platform_Availability, availability_size: c.int) -> c.int ---

	/**
	* Free the memory associated with a \c CXPlatformAvailability structure.
	*/
	disposeCXPlatformAvailability :: proc(availability: ^Platform_Availability) ---

	/**
	* If cursor refers to a variable declaration and it has initializer returns
	* cursor referring to the initializer otherwise return null cursor.
	*/
	Cursor_getVarDeclInitializer :: proc(cursor: Cursor) -> Cursor ---

	/**
	* If cursor refers to a variable declaration that has global storage returns 1.
	* If cursor refers to a variable declaration that doesn't have global storage
	* returns 0. Otherwise returns -1.
	*/
	Cursor_hasVarDeclGlobalStorage :: proc(cursor: Cursor) -> c.int ---

	/**
	* If cursor refers to a variable declaration that has external storage
	* returns 1. If cursor refers to a variable declaration that doesn't have
	* external storage returns 0. Otherwise returns -1.
	*/
	Cursor_hasVarDeclExternalStorage :: proc(cursor: Cursor) -> c.int ---

	/**
	* Determine the "language" of the entity referred to by a given cursor.
	*/
	getCursorLanguage :: proc(cursor: Cursor) -> Language_Kind ---

	/**
	* Determine the "thread-local storage (TLS) kind" of the declaration
	* referred to by a cursor.
	*/
	getCursorTLSKind :: proc(cursor: Cursor) -> Tlskind ---

	/**
	* Returns the translation unit that a cursor originated from.
	*/
	Cursor_getTranslationUnit :: proc(_: Cursor) -> Translation_Unit ---

	/**
	* Creates an empty CXCursorSet.
	*/
	createCXCursorSet :: proc() -> Cursor_Set ---

	/**
	* Disposes a CXCursorSet and releases its associated memory.
	*/
	disposeCXCursorSet :: proc(cset: Cursor_Set) ---

	/**
	* Queries a CXCursorSet to see if it contains a specific CXCursor.
	*
	* \returns non-zero if the set contains the specified cursor.
	*/
	CXCursorSet_contains :: proc(cset: Cursor_Set, cursor: Cursor) -> c.uint ---

	/**
	* Inserts a CXCursor into a CXCursorSet.
	*
	* \returns zero if the CXCursor was already in the set, and non-zero otherwise.
	*/
	CXCursorSet_insert :: proc(cset: Cursor_Set, cursor: Cursor) -> c.uint ---

	/**
	* Determine the semantic parent of the given cursor.
	*
	* The semantic parent of a cursor is the cursor that semantically contains
	* the given \p cursor. For many declarations, the lexical and semantic parents
	* are equivalent (the lexical parent is returned by
	* \c clang_getCursorLexicalParent()). They diverge when declarations or
	* definitions are provided out-of-line. For example:
	*
	* \code
	* class C {
	*  void f();
	* };
	*
	* void C::f() { }
	* \endcode
	*
	* In the out-of-line definition of \c C::f, the semantic parent is
	* the class \c C, of which this function is a member. The lexical parent is
	* the place where the declaration actually occurs in the source code; in this
	* case, the definition occurs in the translation unit. In general, the
	* lexical parent for a given entity can change without affecting the semantics
	* of the program, and the lexical parent of different declarations of the
	* same entity may be different. Changing the semantic parent of a declaration,
	* on the other hand, can have a major impact on semantics, and redeclarations
	* of a particular entity should all have the same semantic context.
	*
	* In the example above, both declarations of \c C::f have \c C as their
	* semantic context, while the lexical context of the first \c C::f is \c C
	* and the lexical context of the second \c C::f is the translation unit.
	*
	* For global declarations, the semantic parent is the translation unit.
	*/
	getCursorSemanticParent :: proc(cursor: Cursor) -> Cursor ---

	/**
	* Determine the lexical parent of the given cursor.
	*
	* The lexical parent of a cursor is the cursor in which the given \p cursor
	* was actually written. For many declarations, the lexical and semantic parents
	* are equivalent (the semantic parent is returned by
	* \c clang_getCursorSemanticParent()). They diverge when declarations or
	* definitions are provided out-of-line. For example:
	*
	* \code
	* class C {
	*  void f();
	* };
	*
	* void C::f() { }
	* \endcode
	*
	* In the out-of-line definition of \c C::f, the semantic parent is
	* the class \c C, of which this function is a member. The lexical parent is
	* the place where the declaration actually occurs in the source code; in this
	* case, the definition occurs in the translation unit. In general, the
	* lexical parent for a given entity can change without affecting the semantics
	* of the program, and the lexical parent of different declarations of the
	* same entity may be different. Changing the semantic parent of a declaration,
	* on the other hand, can have a major impact on semantics, and redeclarations
	* of a particular entity should all have the same semantic context.
	*
	* In the example above, both declarations of \c C::f have \c C as their
	* semantic context, while the lexical context of the first \c C::f is \c C
	* and the lexical context of the second \c C::f is the translation unit.
	*
	* For declarations written in the global scope, the lexical parent is
	* the translation unit.
	*/
	getCursorLexicalParent :: proc(cursor: Cursor) -> Cursor ---

	/**
	* Determine the set of methods that are overridden by the given
	* method.
	*
	* In both Objective-C and C++, a method (aka virtual member function,
	* in C++) can override a virtual method in a base class. For
	* Objective-C, a method is said to override any method in the class's
	* base class, its protocols, or its categories' protocols, that has the same
	* selector and is of the same kind (class or instance).
	* If no such method exists, the search continues to the class's superclass,
	* its protocols, and its categories, and so on. A method from an Objective-C
	* implementation is considered to override the same methods as its
	* corresponding method in the interface.
	*
	* For C++, a virtual member function overrides any virtual member
	* function with the same signature that occurs in its base
	* classes. With multiple inheritance, a virtual member function can
	* override several virtual member functions coming from different
	* base classes.
	*
	* In all cases, this function determines the immediate overridden
	* method, rather than all of the overridden methods. For example, if
	* a method is originally declared in a class A, then overridden in B
	* (which in inherits from A) and also in C (which inherited from B),
	* then the only overridden method returned from this function when
	* invoked on C's method will be B's method. The client may then
	* invoke this function again, given the previously-found overridden
	* methods, to map out the complete method-override set.
	*
	* \param cursor A cursor representing an Objective-C or C++
	* method. This routine will compute the set of methods that this
	* method overrides.
	*
	* \param overridden A pointer whose pointee will be replaced with a
	* pointer to an array of cursors, representing the set of overridden
	* methods. If there are no overridden methods, the pointee will be
	* set to NULL. The pointee must be freed via a call to
	* \c clang_disposeOverriddenCursors().
	*
	* \param num_overridden A pointer to the number of overridden
	* functions, will be set to the number of overridden functions in the
	* array pointed to by \p overridden.
	*/
	getOverriddenCursors :: proc(cursor: Cursor, overridden: ^^Cursor, num_overridden: ^c.uint) ---

	/**
	* Free the set of overridden cursors returned by \c
	* clang_getOverriddenCursors().
	*/
	disposeOverriddenCursors :: proc(overridden: ^Cursor) ---

	/**
	* Retrieve the file that is included by the given inclusion directive
	* cursor.
	*/
	getIncludedFile :: proc(cursor: Cursor) -> File ---

	/**
	* Map a source location to the cursor that describes the entity at that
	* location in the source code.
	*
	* clang_getCursor() maps an arbitrary source location within a translation
	* unit down to the most specific cursor that describes the entity at that
	* location. For example, given an expression \c x + y, invoking
	* clang_getCursor() with a source location pointing to "x" will return the
	* cursor for "x"; similarly for "y". If the cursor points anywhere between
	* "x" or "y" (e.g., on the + or the whitespace around it), clang_getCursor()
	* will return a cursor referring to the "+" expression.
	*
	* \returns a cursor representing the entity at the given source location, or
	* a NULL cursor if no such entity can be found.
	*/
	getCursor :: proc(_: Translation_Unit, _: Source_Location) -> Cursor ---

	/**
	* Retrieve the physical location of the source constructor referenced
	* by the given cursor.
	*
	* The location of a declaration is typically the location of the name of that
	* declaration, where the name of that declaration would occur if it is
	* unnamed, or some keyword that introduces that particular declaration.
	* The location of a reference is where that reference occurs within the
	* source code.
	*/
	getCursorLocation :: proc(_: Cursor) -> Source_Location ---

	/**
	* Retrieve the physical extent of the source construct referenced by
	* the given cursor.
	*
	* The extent of a cursor starts with the file/line/column pointing at the
	* first character within the source construct that the cursor refers to and
	* ends with the last character within that source construct. For a
	* declaration, the extent covers the declaration itself. For a reference,
	* the extent covers the location of the reference (e.g., where the referenced
	* entity was actually used).
	*/
	getCursorExtent :: proc(_: Cursor) -> Source_Range ---

	/**
	* Retrieve the type of a CXCursor (if any).
	*/
	getCursorType :: proc(C: Cursor) -> Type ---

	/**
	* Pretty-print the underlying type using the rules of the
	* language of the translation unit from which it came.
	*
	* If the type is invalid, an empty string is returned.
	*/
	getTypeSpelling :: proc(CT: Type) -> String ---

	/**
	* Retrieve the underlying type of a typedef declaration.
	*
	* If the cursor does not reference a typedef declaration, an invalid type is
	* returned.
	*/
	getTypedefDeclUnderlyingType :: proc(C: Cursor) -> Type ---

	/**
	* Retrieve the integer type of an enum declaration.
	*
	* If the cursor does not reference an enum declaration, an invalid type is
	* returned.
	*/
	getEnumDeclIntegerType :: proc(C: Cursor) -> Type ---

	/**
	* Retrieve the integer value of an enum constant declaration as a signed
	*  long long.
	*
	* If the cursor does not reference an enum constant declaration, LLONG_MIN is
	* returned. Since this is also potentially a valid constant value, the kind of
	* the cursor must be verified before calling this function.
	*/
	getEnumConstantDeclValue :: proc(C: Cursor) -> c.longlong ---

	/**
	* Retrieve the integer value of an enum constant declaration as an unsigned
	*  long long.
	*
	* If the cursor does not reference an enum constant declaration, ULLONG_MAX is
	* returned. Since this is also potentially a valid constant value, the kind of
	* the cursor must be verified before calling this function.
	*/
	getEnumConstantDeclUnsignedValue :: proc(C: Cursor) -> c.ulonglong ---

	/**
	* Returns non-zero if the cursor specifies a Record member that is a bit-field.
	*/
	Cursor_isBitField :: proc(C: Cursor) -> c.uint ---

	/**
	* Retrieve the bit width of a bit-field declaration as an integer.
	*
	* If the cursor does not reference a bit-field, or if the bit-field's width
	* expression cannot be evaluated, -1 is returned.
	*
	* For example:
	* \code
	* if (clang_Cursor_isBitField(Cursor)) {
	*   int Width = clang_getFieldDeclBitWidth(Cursor);
	*   if (Width != -1) {
	*     // The bit-field width is not value-dependent.
	*   }
	* }
	* \endcode
	*/
	getFieldDeclBitWidth :: proc(C: Cursor) -> c.int ---

	/**
	* Retrieve the number of non-variadic arguments associated with a given
	* cursor.
	*
	* The number of arguments can be determined for calls as well as for
	* declarations of functions or methods. For other cursors -1 is returned.
	*/
	Cursor_getNumArguments :: proc(C: Cursor) -> c.int ---

	/**
	* Retrieve the argument cursor of a function or method.
	*
	* The argument cursor can be determined for calls as well as for declarations
	* of functions or methods. For other cursors and for invalid indices, an
	* invalid cursor is returned.
	*/
	Cursor_getArgument :: proc(C: Cursor, i: c.uint) -> Cursor ---

	/**
	* Returns the number of template args of a function, struct, or class decl
	* representing a template specialization.
	*
	* If the argument cursor cannot be converted into a template function
	* declaration, -1 is returned.
	*
	* For example, for the following declaration and specialization:
	*   template <typename T, int kInt, bool kBool>
	*   void foo() { ... }
	*
	*   template <>
	*   void foo<float, -7, true>();
	*
	* The value 3 would be returned from this call.
	*/
	Cursor_getNumTemplateArguments :: proc(C: Cursor) -> c.int ---

	/**
	* Retrieve the kind of the I'th template argument of the CXCursor C.
	*
	* If the argument CXCursor does not represent a FunctionDecl, StructDecl, or
	* ClassTemplatePartialSpecialization, an invalid template argument kind is
	* returned.
	*
	* For example, for the following declaration and specialization:
	*   template <typename T, int kInt, bool kBool>
	*   void foo() { ... }
	*
	*   template <>
	*   void foo<float, -7, true>();
	*
	* For I = 0, 1, and 2, Type, Integral, and Integral will be returned,
	* respectively.
	*/
	Cursor_getTemplateArgumentKind :: proc(C: Cursor, I: c.uint) -> Template_Argument_Kind ---

	/**
	* Retrieve a CXType representing the type of a TemplateArgument of a
	*  function decl representing a template specialization.
	*
	* If the argument CXCursor does not represent a FunctionDecl, StructDecl,
	* ClassDecl or ClassTemplatePartialSpecialization whose I'th template argument
	* has a kind of CXTemplateArgKind_Integral, an invalid type is returned.
	*
	* For example, for the following declaration and specialization:
	*   template <typename T, int kInt, bool kBool>
	*   void foo() { ... }
	*
	*   template <>
	*   void foo<float, -7, true>();
	*
	* If called with I = 0, "float", will be returned.
	* Invalid types will be returned for I == 1 or 2.
	*/
	Cursor_getTemplateArgumentType :: proc(C: Cursor, I: c.uint) -> Type ---

	/**
	* Retrieve the value of an Integral TemplateArgument (of a function
	*  decl representing a template specialization) as a signed long long.
	*
	* It is undefined to call this function on a CXCursor that does not represent a
	* FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization
	* whose I'th template argument is not an integral value.
	*
	* For example, for the following declaration and specialization:
	*   template <typename T, int kInt, bool kBool>
	*   void foo() { ... }
	*
	*   template <>
	*   void foo<float, -7, true>();
	*
	* If called with I = 1 or 2, -7 or true will be returned, respectively.
	* For I == 0, this function's behavior is undefined.
	*/
	Cursor_getTemplateArgumentValue :: proc(C: Cursor, I: c.uint) -> c.longlong ---

	/**
	* Retrieve the value of an Integral TemplateArgument (of a function
	*  decl representing a template specialization) as an unsigned long long.
	*
	* It is undefined to call this function on a CXCursor that does not represent a
	* FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization or
	* whose I'th template argument is not an integral value.
	*
	* For example, for the following declaration and specialization:
	*   template <typename T, int kInt, bool kBool>
	*   void foo() { ... }
	*
	*   template <>
	*   void foo<float, 2147483649, true>();
	*
	* If called with I = 1 or 2, 2147483649 or true will be returned, respectively.
	* For I == 0, this function's behavior is undefined.
	*/
	Cursor_getTemplateArgumentUnsignedValue :: proc(C: Cursor, I: c.uint) -> c.ulonglong ---

	/**
	* Determine whether two CXTypes represent the same type.
	*
	* \returns non-zero if the CXTypes represent the same type and
	*          zero otherwise.
	*/
	equalTypes :: proc(A: Type, B: Type) -> c.uint ---

	/**
	* Return the canonical type for a CXType.
	*
	* Clang's type system explicitly models typedefs and all the ways
	* a specific type can be represented.  The canonical type is the underlying
	* type with all the "sugar" removed.  For example, if 'T' is a typedef
	* for 'int', the canonical type for 'T' would be 'int'.
	*/
	getCanonicalType :: proc(T: Type) -> Type ---

	/**
	* Determine whether a CXType has the "const" qualifier set,
	* without looking through typedefs that may have added "const" at a
	* different level.
	*/
	isConstQualifiedType :: proc(T: Type) -> c.uint ---

	/**
	* Determine whether a  CXCursor that is a macro, is
	* function like.
	*/
	Cursor_isMacroFunctionLike :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine whether a  CXCursor that is a macro, is a
	* builtin one.
	*/
	Cursor_isMacroBuiltin :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine whether a  CXCursor that is a function declaration, is an
	* inline declaration.
	*/
	Cursor_isFunctionInlined :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine whether a CXType has the "volatile" qualifier set,
	* without looking through typedefs that may have added "volatile" at
	* a different level.
	*/
	isVolatileQualifiedType :: proc(T: Type) -> c.uint ---

	/**
	* Determine whether a CXType has the "restrict" qualifier set,
	* without looking through typedefs that may have added "restrict" at a
	* different level.
	*/
	isRestrictQualifiedType :: proc(T: Type) -> c.uint ---

	/**
	* Returns the address space of the given type.
	*/
	getAddressSpace :: proc(T: Type) -> c.uint ---

	/**
	* Returns the typedef name of the given type.
	*/
	getTypedefName :: proc(CT: Type) -> String ---

	/**
	* For pointer types, returns the type of the pointee.
	*/
	getPointeeType :: proc(T: Type) -> Type ---

	/**
	* Retrieve the unqualified variant of the given type, removing as
	* little sugar as possible.
	*
	* For example, given the following series of typedefs:
	*
	* \code
	* typedef int Integer;
	* typedef const Integer CInteger;
	* typedef CInteger DifferenceType;
	* \endcode
	*
	* Executing \c clang_getUnqualifiedType() on a \c CXType that
	* represents \c DifferenceType, will desugar to a type representing
	* \c Integer, that has no qualifiers.
	*
	* And, executing \c clang_getUnqualifiedType() on the type of the
	* first argument of the following function declaration:
	*
	* \code
	* void foo(const int);
	* \endcode
	*
	* Will return a type representing \c int, removing the \c const
	* qualifier.
	*
	* Sugar over array types is not desugared.
	*
	* A type can be checked for qualifiers with \c
	* clang_isConstQualifiedType(), \c clang_isVolatileQualifiedType()
	* and \c clang_isRestrictQualifiedType().
	*
	* A type that resulted from a call to \c clang_getUnqualifiedType
	* will return \c false for all of the above calls.
	*/
	getUnqualifiedType :: proc(CT: Type) -> Type ---

	/**
	* For reference types (e.g., "const int&"), returns the type that the
	* reference refers to (e.g "const int").
	*
	* Otherwise, returns the type itself.
	*
	* A type that has kind \c CXType_LValueReference or
	* \c CXType_RValueReference is a reference type.
	*/
	getNonReferenceType :: proc(CT: Type) -> Type ---

	/**
	* Return the cursor for the declaration of the given type.
	*/
	getTypeDeclaration :: proc(T: Type) -> Cursor ---

	/**
	* Returns the Objective-C type encoding for the specified declaration.
	*/
	getDeclObjCTypeEncoding :: proc(C: Cursor) -> String ---

	/**
	* Returns the Objective-C type encoding for the specified CXType.
	*/
	Type_getObjCEncoding :: proc(type: Type) -> String ---

	/**
	* Retrieve the spelling of a given CXTypeKind.
	*/
	getTypeKindSpelling :: proc(K: Type_Kind) -> String ---

	/**
	* Retrieve the calling convention associated with a function type.
	*
	* If a non-function type is passed in, CXCallingConv_Invalid is returned.
	*/
	getFunctionTypeCallingConv :: proc(T: Type) -> Calling_Conv ---

	/**
	* Retrieve the return type associated with a function type.
	*
	* If a non-function type is passed in, an invalid type is returned.
	*/
	getResultType :: proc(T: Type) -> Type ---

	/**
	* Retrieve the exception specification type associated with a function type.
	* This is a value of type CXCursor_ExceptionSpecificationKind.
	*
	* If a non-function type is passed in, an error code of -1 is returned.
	*/
	getExceptionSpecificationType :: proc(T: Type) -> c.int ---

	/**
	* Retrieve the number of non-variadic parameters associated with a
	* function type.
	*
	* If a non-function type is passed in, -1 is returned.
	*/
	getNumArgTypes :: proc(T: Type) -> c.int ---

	/**
	* Retrieve the type of a parameter of a function type.
	*
	* If a non-function type is passed in or the function does not have enough
	* parameters, an invalid type is returned.
	*/
	getArgType :: proc(T: Type, i: c.uint) -> Type ---

	/**
	* Retrieves the base type of the ObjCObjectType.
	*
	* If the type is not an ObjC object, an invalid type is returned.
	*/
	Type_getObjCObjectBaseType :: proc(T: Type) -> Type ---

	/**
	* Retrieve the number of protocol references associated with an ObjC object/id.
	*
	* If the type is not an ObjC object, 0 is returned.
	*/
	Type_getNumObjCProtocolRefs :: proc(T: Type) -> c.uint ---

	/**
	* Retrieve the decl for a protocol reference for an ObjC object/id.
	*
	* If the type is not an ObjC object or there are not enough protocol
	* references, an invalid cursor is returned.
	*/
	Type_getObjCProtocolDecl :: proc(T: Type, i: c.uint) -> Cursor ---

	/**
	* Retrieve the number of type arguments associated with an ObjC object.
	*
	* If the type is not an ObjC object, 0 is returned.
	*/
	Type_getNumObjCTypeArgs :: proc(T: Type) -> c.uint ---

	/**
	* Retrieve a type argument associated with an ObjC object.
	*
	* If the type is not an ObjC or the index is not valid,
	* an invalid type is returned.
	*/
	Type_getObjCTypeArg :: proc(T: Type, i: c.uint) -> Type ---

	/**
	* Return 1 if the CXType is a variadic function type, and 0 otherwise.
	*/
	isFunctionTypeVariadic :: proc(T: Type) -> c.uint ---

	/**
	* Retrieve the return type associated with a given cursor.
	*
	* This only returns a valid type if the cursor refers to a function or method.
	*/
	getCursorResultType :: proc(C: Cursor) -> Type ---

	/**
	* Retrieve the exception specification type associated with a given cursor.
	* This is a value of type CXCursor_ExceptionSpecificationKind.
	*
	* This only returns a valid result if the cursor refers to a function or
	* method.
	*/
	getCursorExceptionSpecificationType :: proc(C: Cursor) -> c.int ---

	/**
	* Return 1 if the CXType is a POD (plain old data) type, and 0
	*  otherwise.
	*/
	isPODType :: proc(T: Type) -> c.uint ---

	/**
	* Return the element type of an array, complex, or vector type.
	*
	* If a type is passed in that is not an array, complex, or vector type,
	* an invalid type is returned.
	*/
	getElementType :: proc(T: Type) -> Type ---

	/**
	* Return the number of elements of an array or vector type.
	*
	* If a type is passed in that is not an array or vector type,
	* -1 is returned.
	*/
	getNumElements :: proc(T: Type) -> c.longlong ---

	/**
	* Return the element type of an array type.
	*
	* If a non-array type is passed in, an invalid type is returned.
	*/
	getArrayElementType :: proc(T: Type) -> Type ---

	/**
	* Return the array size of a constant array.
	*
	* If a non-array type is passed in, -1 is returned.
	*/
	getArraySize :: proc(T: Type) -> c.longlong ---

	/**
	* Retrieve the type named by the qualified-id.
	*
	* If a non-elaborated type is passed in, an invalid type is returned.
	*/
	Type_getNamedType :: proc(T: Type) -> Type ---

	/**
	* Determine if a typedef is 'transparent' tag.
	*
	* A typedef is considered 'transparent' if it shares a name and spelling
	* location with its underlying tag type, as is the case with the NS_ENUM macro.
	*
	* \returns non-zero if transparent and zero otherwise.
	*/
	Type_isTransparentTagTypedef :: proc(T: Type) -> c.uint ---

	/**
	* Retrieve the nullability kind of a pointer type.
	*/
	Type_getNullability :: proc(T: Type) -> Type_Nullability_Kind ---

	/**
	* Return the alignment of a type in bytes as per C++[expr.alignof]
	*   standard.
	*
	* If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
	* If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
	*   is returned.
	* If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
	*   returned.
	* If the type declaration is not a constant size type,
	*   CXTypeLayoutError_NotConstantSize is returned.
	*/
	Type_getAlignOf :: proc(T: Type) -> c.longlong ---

	/**
	* Return the class type of an member pointer type.
	*
	* If a non-member-pointer type is passed in, an invalid type is returned.
	*/
	Type_getClassType :: proc(T: Type) -> Type ---

	/**
	* Return the size of a type in bytes as per C++[expr.sizeof] standard.
	*
	* If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
	* If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
	*   is returned.
	* If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
	*   returned.
	*/
	Type_getSizeOf :: proc(T: Type) -> c.longlong ---

	/**
	* Return the offset of a field named S in a record of type T in bits
	*   as it would be returned by __offsetof__ as per C++11[18.2p4]
	*
	* If the cursor is not a record field declaration, CXTypeLayoutError_Invalid
	*   is returned.
	* If the field's type declaration is an incomplete type,
	*   CXTypeLayoutError_Incomplete is returned.
	* If the field's type declaration is a dependent type,
	*   CXTypeLayoutError_Dependent is returned.
	* If the field's name S is not found,
	*   CXTypeLayoutError_InvalidFieldName is returned.
	*/
	Type_getOffsetOf :: proc(T: Type, S: cstring) -> c.longlong ---

	/**
	* Return the type that was modified by this attributed type.
	*
	* If the type is not an attributed type, an invalid type is returned.
	*/
	Type_getModifiedType :: proc(T: Type) -> Type ---

	/**
	* Gets the type contained by this atomic type.
	*
	* If a non-atomic type is passed in, an invalid type is returned.
	*/
	Type_getValueType :: proc(CT: Type) -> Type ---

	/**
	* Return the offset of the field represented by the Cursor.
	*
	* If the cursor is not a field declaration, -1 is returned.
	* If the cursor semantic parent is not a record field declaration,
	*   CXTypeLayoutError_Invalid is returned.
	* If the field's type declaration is an incomplete type,
	*   CXTypeLayoutError_Incomplete is returned.
	* If the field's type declaration is a dependent type,
	*   CXTypeLayoutError_Dependent is returned.
	* If the field's name S is not found,
	*   CXTypeLayoutError_InvalidFieldName is returned.
	*/
	Cursor_getOffsetOfField :: proc(C: Cursor) -> c.longlong ---

	/**
	* Determine whether the given cursor represents an anonymous
	* tag or namespace
	*/
	Cursor_isAnonymous :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine whether the given cursor represents an anonymous record
	* declaration.
	*/
	Cursor_isAnonymousRecordDecl :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine whether the given cursor represents an inline namespace
	* declaration.
	*/
	Cursor_isInlineNamespace :: proc(C: Cursor) -> c.uint ---

	/**
	* Returns the number of template arguments for given template
	* specialization, or -1 if type \c T is not a template specialization.
	*/
	Type_getNumTemplateArguments :: proc(T: Type) -> c.int ---

	/**
	* Returns the type template argument of a template class specialization
	* at given index.
	*
	* This function only returns template type arguments and does not handle
	* template template arguments or variadic packs.
	*/
	Type_getTemplateArgumentAsType :: proc(T: Type, i: c.uint) -> Type ---

	/**
	* Retrieve the ref-qualifier kind of a function or method.
	*
	* The ref-qualifier is returned for C++ functions or methods. For other types
	* or non-C++ declarations, CXRefQualifier_None is returned.
	*/
	Type_getCXXRefQualifier :: proc(T: Type) -> Ref_Qualifier_Kind ---

	/**
	* Returns 1 if the base class specified by the cursor with kind
	*   CX_CXXBaseSpecifier is virtual.
	*/
	isVirtualBase :: proc(_: Cursor) -> c.uint ---

	/**
	* Returns the offset in bits of a CX_CXXBaseSpecifier relative to the parent
	* class.
	*
	* Returns a small negative number if the offset cannot be computed. See
	* CXTypeLayoutError for error codes.
	*/
	getOffsetOfBase :: proc(Parent: Cursor, Base: Cursor) -> c.longlong ---

	/**
	* Returns the access control level for the referenced object.
	*
	* If the cursor refers to a C++ declaration, its access control level within
	* its parent scope is returned. Otherwise, if the cursor refers to a base
	* specifier or access specifier, the specifier itself is returned.
	*/
	getCXXAccessSpecifier :: proc(_: Cursor) -> Cxxaccess_Specifier ---

	/**
	* \brief Returns the operator code for the binary operator.
	*/
	Cursor_getBinaryOpcode :: proc(C: Cursor) -> CX_Binary_Operator_Kind ---

	/**
	* \brief Returns a string containing the spelling of the binary operator.
	*/
	Cursor_getBinaryOpcodeStr :: proc(Op: CX_Binary_Operator_Kind) -> String ---

	/**
	* Returns the storage class for a function or variable declaration.
	*
	* If the passed in Cursor is not a function or variable declaration,
	* CX_SC_Invalid is returned else the storage class.
	*/
	Cursor_getStorageClass :: proc(_: Cursor) -> Storage_Class ---

	/**
	* Determine the number of overloaded declarations referenced by a
	* \c CXCursor_OverloadedDeclRef cursor.
	*
	* \param cursor The cursor whose overloaded declarations are being queried.
	*
	* \returns The number of overloaded declarations referenced by \c cursor. If it
	* is not a \c CXCursor_OverloadedDeclRef cursor, returns 0.
	*/
	getNumOverloadedDecls :: proc(cursor: Cursor) -> c.uint ---

	/**
	* Retrieve a cursor for one of the overloaded declarations referenced
	* by a \c CXCursor_OverloadedDeclRef cursor.
	*
	* \param cursor The cursor whose overloaded declarations are being queried.
	*
	* \param index The zero-based index into the set of overloaded declarations in
	* the cursor.
	*
	* \returns A cursor representing the declaration referenced by the given
	* \c cursor at the specified \c index. If the cursor does not have an
	* associated set of overloaded declarations, or if the index is out of bounds,
	* returns \c clang_getNullCursor();
	*/
	getOverloadedDecl :: proc(cursor: Cursor, index: c.uint) -> Cursor ---

	/**
	* For cursors representing an iboutletcollection attribute,
	*  this function returns the collection element type.
	*
	*/
	getIBOutletCollectionType :: proc(_: Cursor) -> Type ---

	/**
	* Visit the children of a particular cursor.
	*
	* This function visits all the direct children of the given cursor,
	* invoking the given \p visitor function with the cursors of each
	* visited child. The traversal may be recursive, if the visitor returns
	* \c CXChildVisit_Recurse. The traversal may also be ended prematurely, if
	* the visitor returns \c CXChildVisit_Break.
	*
	* \param parent the cursor whose child may be visited. All kinds of
	* cursors can be visited, including invalid cursors (which, by
	* definition, have no children).
	*
	* \param visitor the visitor function that will be invoked for each
	* child of \p parent.
	*
	* \param client_data pointer data supplied by the client, which will
	* be passed to the visitor each time it is invoked.
	*
	* \returns a non-zero value if the traversal was terminated
	* prematurely by the visitor returning \c CXChildVisit_Break.
	*/
	visitChildren :: proc(parent: Cursor, visitor: Cursor_Visitor, client_data: Client_Data) -> c.uint ---

	/**
	* Visits the children of a cursor using the specified block.  Behaves
	* identically to clang_visitChildren() in all other respects.
	*/
	visitChildrenWithBlock :: proc(parent: Cursor, block: Cursor_Visitor_Block) -> c.uint ---

	/**
	* Retrieve a Unified Symbol Resolution (USR) for the entity referenced
	* by the given cursor.
	*
	* A Unified Symbol Resolution (USR) is a string that identifies a particular
	* entity (function, class, variable, etc.) within a program. USRs can be
	* compared across translation units to determine, e.g., when references in
	* one translation refer to an entity defined in another translation unit.
	*/
	getCursorUSR :: proc(_: Cursor) -> String ---

	/**
	* Construct a USR for a specified Objective-C class.
	*/
	constructUSR_ObjCClass :: proc(class_name: cstring) -> String ---

	/**
	* Construct a USR for a specified Objective-C category.
	*/
	constructUSR_ObjCCategory :: proc(class_name: cstring, category_name: cstring) -> String ---

	/**
	* Construct a USR for a specified Objective-C protocol.
	*/
	constructUSR_ObjCProtocol :: proc(protocol_name: cstring) -> String ---

	/**
	* Construct a USR for a specified Objective-C instance variable and
	*   the USR for its containing class.
	*/
	constructUSR_ObjCIvar :: proc(name: cstring, classUSR: String) -> String ---

	/**
	* Construct a USR for a specified Objective-C method and
	*   the USR for its containing class.
	*/
	constructUSR_ObjCMethod :: proc(name: cstring, isInstanceMethod: c.uint, classUSR: String) -> String ---

	/**
	* Construct a USR for a specified Objective-C property and the USR
	*  for its containing class.
	*/
	constructUSR_ObjCProperty :: proc(property: cstring, classUSR: String) -> String ---

	/**
	* Retrieve a name for the entity referenced by this cursor.
	*/
	getCursorSpelling :: proc(_: Cursor) -> String ---

	/**
	* Retrieve a range for a piece that forms the cursors spelling name.
	* Most of the times there is only one range for the complete spelling but for
	* Objective-C methods and Objective-C message expressions, there are multiple
	* pieces for each selector identifier.
	*
	* \param pieceIndex the index of the spelling name piece. If this is greater
	* than the actual number of pieces, it will return a NULL (invalid) range.
	*
	* \param options Reserved.
	*/
	Cursor_getSpellingNameRange :: proc(_: Cursor, pieceIndex: c.uint, options: c.uint) -> Source_Range ---

	/**
	* Get a property value for the given printing policy.
	*/
	PrintingPolicy_getProperty :: proc(Policy: Printing_Policy, Property: Printing_Policy_Property) -> c.uint ---

	/**
	* Set a property value for the given printing policy.
	*/
	PrintingPolicy_setProperty :: proc(Policy: Printing_Policy, Property: Printing_Policy_Property, Value: c.uint) ---

	/**
	* Retrieve the default policy for the cursor.
	*
	* The policy should be released after use with \c
	* clang_PrintingPolicy_dispose.
	*/
	getCursorPrintingPolicy :: proc(_: Cursor) -> Printing_Policy ---

	/**
	* Release a printing policy.
	*/
	PrintingPolicy_dispose :: proc(Policy: Printing_Policy) ---

	/**
	* Pretty print declarations.
	*
	* \param Cursor The cursor representing a declaration.
	*
	* \param Policy The policy to control the entities being printed. If
	* NULL, a default policy is used.
	*
	* \returns The pretty printed declaration or the empty string for
	* other cursors.
	*/
	getCursorPrettyPrinted :: proc(Cursor: Cursor, Policy: Printing_Policy) -> String ---

	/**
	* Pretty-print the underlying type using a custom printing policy.
	*
	* If the type is invalid, an empty string is returned.
	*/
	getTypePrettyPrinted :: proc(CT: Type, cxPolicy: Printing_Policy) -> String ---

	/**
	* Retrieve the display name for the entity referenced by this cursor.
	*
	* The display name contains extra information that helps identify the cursor,
	* such as the parameters of a function or template or the arguments of a
	* class template specialization.
	*/
	getCursorDisplayName :: proc(_: Cursor) -> String ---

	/** For a cursor that is a reference, retrieve a cursor representing the
	* entity that it references.
	*
	* Reference cursors refer to other entities in the AST. For example, an
	* Objective-C superclass reference cursor refers to an Objective-C class.
	* This function produces the cursor for the Objective-C class from the
	* cursor for the superclass reference. If the input cursor is a declaration or
	* definition, it returns that declaration or definition unchanged.
	* Otherwise, returns the NULL cursor.
	*/
	getCursorReferenced :: proc(_: Cursor) -> Cursor ---

	/**
	*  For a cursor that is either a reference to or a declaration
	*  of some entity, retrieve a cursor that describes the definition of
	*  that entity.
	*
	*  Some entities can be declared multiple times within a translation
	*  unit, but only one of those declarations can also be a
	*  definition. For example, given:
	*
	*  \code
	*  int f(int, int);
	*  int g(int x, int y) { return f(x, y); }
	*  int f(int a, int b) { return a + b; }
	*  int f(int, int);
	*  \endcode
	*
	*  there are three declarations of the function "f", but only the
	*  second one is a definition. The clang_getCursorDefinition()
	*  function will take any cursor pointing to a declaration of "f"
	*  (the first or fourth lines of the example) or a cursor referenced
	*  that uses "f" (the call to "f' inside "g") and will return a
	*  declaration cursor pointing to the definition (the second "f"
	*  declaration).
	*
	*  If given a cursor for which there is no corresponding definition,
	*  e.g., because there is no definition of that entity within this
	*  translation unit, returns a NULL cursor.
	*/
	getCursorDefinition :: proc(_: Cursor) -> Cursor ---

	/**
	* Determine whether the declaration pointed to by this cursor
	* is also a definition of that entity.
	*/
	isCursorDefinition :: proc(_: Cursor) -> c.uint ---

	/**
	* Retrieve the canonical cursor corresponding to the given cursor.
	*
	* In the C family of languages, many kinds of entities can be declared several
	* times within a single translation unit. For example, a structure type can
	* be forward-declared (possibly multiple times) and later defined:
	*
	* \code
	* struct X;
	* struct X;
	* struct X {
	*   int member;
	* };
	* \endcode
	*
	* The declarations and the definition of \c X are represented by three
	* different cursors, all of which are declarations of the same underlying
	* entity. One of these cursor is considered the "canonical" cursor, which
	* is effectively the representative for the underlying entity. One can
	* determine if two cursors are declarations of the same underlying entity by
	* comparing their canonical cursors.
	*
	* \returns The canonical cursor for the entity referred to by the given cursor.
	*/
	getCanonicalCursor :: proc(_: Cursor) -> Cursor ---

	/**
	* If the cursor points to a selector identifier in an Objective-C
	* method or message expression, this returns the selector index.
	*
	* After getting a cursor with #clang_getCursor, this can be called to
	* determine if the location points to a selector identifier.
	*
	* \returns The selector index if the cursor is an Objective-C method or message
	* expression and the cursor is pointing to a selector identifier, or -1
	* otherwise.
	*/
	Cursor_getObjCSelectorIndex :: proc(_: Cursor) -> c.int ---

	/**
	* Given a cursor pointing to a C++ method call or an Objective-C
	* message, returns non-zero if the method/message is "dynamic", meaning:
	*
	* For a C++ method: the call is virtual.
	* For an Objective-C message: the receiver is an object instance, not 'super'
	* or a specific class.
	*
	* If the method/message is "static" or the cursor does not point to a
	* method/message, it will return zero.
	*/
	Cursor_isDynamicCall :: proc(C: Cursor) -> c.int ---

	/**
	* Given a cursor pointing to an Objective-C message or property
	* reference, or C++ method call, returns the CXType of the receiver.
	*/
	Cursor_getReceiverType :: proc(C: Cursor) -> Type ---

	/**
	* Given a cursor that represents a property declaration, return the
	* associated property attributes. The bits are formed from
	* \c CXObjCPropertyAttrKind.
	*
	* \param reserved Reserved for future use, pass 0.
	*/
	Cursor_getObjCPropertyAttributes :: proc(C: Cursor, reserved: c.uint) -> c.uint ---

	/**
	* Given a cursor that represents a property declaration, return the
	* name of the method that implements the getter.
	*/
	Cursor_getObjCPropertyGetterName :: proc(C: Cursor) -> String ---

	/**
	* Given a cursor that represents a property declaration, return the
	* name of the method that implements the setter, if any.
	*/
	Cursor_getObjCPropertySetterName :: proc(C: Cursor) -> String ---

	/**
	* Given a cursor that represents an Objective-C method or parameter
	* declaration, return the associated Objective-C qualifiers for the return
	* type or the parameter respectively. The bits are formed from
	* CXObjCDeclQualifierKind.
	*/
	Cursor_getObjCDeclQualifiers :: proc(C: Cursor) -> c.uint ---

	/**
	* Given a cursor that represents an Objective-C method or property
	* declaration, return non-zero if the declaration was affected by "\@optional".
	* Returns zero if the cursor is not such a declaration or it is "\@required".
	*/
	Cursor_isObjCOptional :: proc(C: Cursor) -> c.uint ---

	/**
	* Returns non-zero if the given cursor is a variadic function or method.
	*/
	Cursor_isVariadic :: proc(C: Cursor) -> c.uint ---

	/**
	* Returns non-zero if the given cursor points to a symbol marked with
	* external_source_symbol attribute.
	*
	* \param language If non-NULL, and the attribute is present, will be set to
	* the 'language' string from the attribute.
	*
	* \param definedIn If non-NULL, and the attribute is present, will be set to
	* the 'definedIn' string from the attribute.
	*
	* \param isGenerated If non-NULL, and the attribute is present, will be set to
	* non-zero if the 'generated_declaration' is set in the attribute.
	*/
	Cursor_isExternalSymbol :: proc(C: Cursor, language: ^String, definedIn: ^String, isGenerated: ^c.uint) -> c.uint ---

	/**
	* Given a cursor that represents a declaration, return the associated
	* comment's source range.  The range may include multiple consecutive comments
	* with whitespace in between.
	*/
	Cursor_getCommentRange :: proc(C: Cursor) -> Source_Range ---

	/**
	* Given a cursor that represents a declaration, return the associated
	* comment text, including comment markers.
	*/
	Cursor_getRawCommentText :: proc(C: Cursor) -> String ---

	/**
	* Given a cursor that represents a documentable entity (e.g.,
	* declaration), return the associated \paragraph; otherwise return the
	* first paragraph.
	*/
	Cursor_getBriefCommentText :: proc(C: Cursor) -> String ---

	/**
	* Retrieve the CXString representing the mangled name of the cursor.
	*/
	Cursor_getMangling :: proc(_: Cursor) -> String ---

	/**
	* Retrieve the CXStrings representing the mangled symbols of the C++
	* constructor or destructor at the cursor.
	*/
	Cursor_getCXXManglings :: proc(_: Cursor) -> ^String_Set ---

	/**
	* Retrieve the CXStrings representing the mangled symbols of the ObjC
	* class interface or implementation at the cursor.
	*/
	Cursor_getObjCManglings :: proc(_: Cursor) -> ^String_Set ---

	/**
	* Given a CXCursor_ModuleImportDecl cursor, return the associated module.
	*/
	Cursor_getModule :: proc(C: Cursor) -> CXModule ---

	/**
	* Given a CXFile header file, return the module that contains it, if one
	* exists.
	*/
	getModuleForFile :: proc(_: Translation_Unit, _: File) -> CXModule ---

	/**
	* \param Module a module object.
	*
	* \returns the module file where the provided module object came from.
	*/
	Module_getASTFile :: proc(Module: CXModule) -> File ---

	/**
	* \param Module a module object.
	*
	* \returns the parent of a sub-module or NULL if the given module is top-level,
	* e.g. for 'std.vector' it will return the 'std' module.
	*/
	Module_getParent :: proc(Module: CXModule) -> CXModule ---

	/**
	* \param Module a module object.
	*
	* \returns the name of the module, e.g. for the 'std.vector' sub-module it
	* will return "vector".
	*/
	Module_getName :: proc(Module: CXModule) -> String ---

	/**
	* \param Module a module object.
	*
	* \returns the full name of the module, e.g. "std.vector".
	*/
	Module_getFullName :: proc(Module: CXModule) -> String ---

	/**
	* \param Module a module object.
	*
	* \returns non-zero if the module is a system one.
	*/
	Module_isSystem :: proc(Module: CXModule) -> c.int ---

	/**
	* \param Module a module object.
	*
	* \returns the number of top level headers associated with this module.
	*/
	Module_getNumTopLevelHeaders :: proc(_: Translation_Unit, Module: CXModule) -> c.uint ---

	/**
	* \param Module a module object.
	*
	* \param Index top level header index (zero-based).
	*
	* \returns the specified top level header associated with the module.
	*/
	Module_getTopLevelHeader :: proc(_: Translation_Unit, Module: CXModule, Index: c.uint) -> File ---

	/**
	* Determine if a C++ constructor is a converting constructor.
	*/
	CXXConstructor_isConvertingConstructor :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ constructor is a copy constructor.
	*/
	CXXConstructor_isCopyConstructor :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ constructor is the default constructor.
	*/
	CXXConstructor_isDefaultConstructor :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ constructor is a move constructor.
	*/
	CXXConstructor_isMoveConstructor :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ field is declared 'mutable'.
	*/
	CXXField_isMutable :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ method is declared '= default'.
	*/
	CXXMethod_isDefaulted :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ method is declared '= delete'.
	*/
	CXXMethod_isDeleted :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ member function or member function template is
	* pure virtual.
	*/
	CXXMethod_isPureVirtual :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ member function or member function template is
	* declared 'static'.
	*/
	CXXMethod_isStatic :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ member function or member function template is
	* explicitly declared 'virtual' or if it overrides a virtual method from
	* one of the base classes.
	*/
	CXXMethod_isVirtual :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ member function is a copy-assignment operator,
	* returning 1 if such is the case and 0 otherwise.
	*
	* > A copy-assignment operator `X::operator=` is a non-static,
	* > non-template member function of _class_ `X` with exactly one
	* > parameter of type `X`, `X&`, `const X&`, `volatile X&` or `const
	* > volatile X&`.
	*
	* That is, for example, the `operator=` in:
	*
	*    class Foo {
	*        bool operator=(const volatile Foo&);
	*    };
	*
	* Is a copy-assignment operator, while the `operator=` in:
	*
	*    class Bar {
	*        bool operator=(const int&);
	*    };
	*
	* Is not.
	*/
	CXXMethod_isCopyAssignmentOperator :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ member function is a move-assignment operator,
	* returning 1 if such is the case and 0 otherwise.
	*
	* > A move-assignment operator `X::operator=` is a non-static,
	* > non-template member function of _class_ `X` with exactly one
	* > parameter of type `X&&`, `const X&&`, `volatile X&&` or `const
	* > volatile X&&`.
	*
	* That is, for example, the `operator=` in:
	*
	*    class Foo {
	*        bool operator=(const volatile Foo&&);
	*    };
	*
	* Is a move-assignment operator, while the `operator=` in:
	*
	*    class Bar {
	*        bool operator=(const int&&);
	*    };
	*
	* Is not.
	*/
	CXXMethod_isMoveAssignmentOperator :: proc(C: Cursor) -> c.uint ---

	/**
	* Determines if a C++ constructor or conversion function was declared
	* explicit, returning 1 if such is the case and 0 otherwise.
	*
	* Constructors or conversion functions are declared explicit through
	* the use of the explicit specifier.
	*
	* For example, the following constructor and conversion function are
	* not explicit as they lack the explicit specifier:
	*
	*     class Foo {
	*         Foo();
	*         operator int();
	*     };
	*
	* While the following constructor and conversion function are
	* explicit as they are declared with the explicit specifier.
	*
	*     class Foo {
	*         explicit Foo();
	*         explicit operator int();
	*     };
	*
	* This function will return 0 when given a cursor pointing to one of
	* the former declarations and it will return 1 for a cursor pointing
	* to the latter declarations.
	*
	* The explicit specifier allows the user to specify a
	* conditional compile-time expression whose value decides
	* whether the marked element is explicit or not.
	*
	* For example:
	*
	*     constexpr bool foo(int i) { return i % 2 == 0; }
	*
	*     class Foo {
	*          explicit(foo(1)) Foo();
	*          explicit(foo(2)) operator int();
	*     }
	*
	* This function will return 0 for the constructor and 1 for
	* the conversion function.
	*/
	CXXMethod_isExplicit :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ record is abstract, i.e. whether a class or struct
	* has a pure virtual member function.
	*/
	CXXRecord_isAbstract :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if an enum declaration refers to a scoped enum.
	*/
	EnumDecl_isScoped :: proc(C: Cursor) -> c.uint ---

	/**
	* Determine if a C++ member function or member function template is
	* declared 'const'.
	*/
	CXXMethod_isConst :: proc(C: Cursor) -> c.uint ---

	/**
	* Given a cursor that represents a template, determine
	* the cursor kind of the specializations would be generated by instantiating
	* the template.
	*
	* This routine can be used to determine what flavor of function template,
	* class template, or class template partial specialization is stored in the
	* cursor. For example, it can describe whether a class template cursor is
	* declared with "struct", "class" or "union".
	*
	* \param C The cursor to query. This cursor should represent a template
	* declaration.
	*
	* \returns The cursor kind of the specializations that would be generated
	* by instantiating the template \p C. If \p C is not a template, returns
	* \c CXCursor_NoDeclFound.
	*/
	getTemplateCursorKind :: proc(C: Cursor) -> Cursor_Kind ---

	/**
	* Given a cursor that may represent a specialization or instantiation
	* of a template, retrieve the cursor that represents the template that it
	* specializes or from which it was instantiated.
	*
	* This routine determines the template involved both for explicit
	* specializations of templates and for implicit instantiations of the template,
	* both of which are referred to as "specializations". For a class template
	* specialization (e.g., \c std::vector<bool>), this routine will return
	* either the primary template (\c std::vector) or, if the specialization was
	* instantiated from a class template partial specialization, the class template
	* partial specialization. For a class template partial specialization and a
	* function template specialization (including instantiations), this
	* this routine will return the specialized template.
	*
	* For members of a class template (e.g., member functions, member classes, or
	* static data members), returns the specialized or instantiated member.
	* Although not strictly "templates" in the C++ language, members of class
	* templates have the same notions of specializations and instantiations that
	* templates do, so this routine treats them similarly.
	*
	* \param C A cursor that may be a specialization of a template or a member
	* of a template.
	*
	* \returns If the given cursor is a specialization or instantiation of a
	* template or a member thereof, the template or member that it specializes or
	* from which it was instantiated. Otherwise, returns a NULL cursor.
	*/
	getSpecializedCursorTemplate :: proc(C: Cursor) -> Cursor ---

	/**
	* Given a cursor that references something else, return the source range
	* covering that reference.
	*
	* \param C A cursor pointing to a member reference, a declaration reference, or
	* an operator call.
	* \param NameFlags A bitset with three independent flags:
	* CXNameRange_WantQualifier, CXNameRange_WantTemplateArgs, and
	* CXNameRange_WantSinglePiece.
	* \param PieceIndex For contiguous names or when passing the flag
	* CXNameRange_WantSinglePiece, only one piece with index 0 is
	* available. When the CXNameRange_WantSinglePiece flag is not passed for a
	* non-contiguous names, this index can be used to retrieve the individual
	* pieces of the name. See also CXNameRange_WantSinglePiece.
	*
	* \returns The piece of the name pointed to by the given cursor. If there is no
	* name, or if the PieceIndex is out-of-range, a null-cursor will be returned.
	*/
	getCursorReferenceNameRange :: proc(C: Cursor, NameFlags: c.uint, PieceIndex: c.uint) -> Source_Range ---

	/**
	* Get the raw lexical token starting with the given location.
	*
	* \param TU the translation unit whose text is being tokenized.
	*
	* \param Location the source location with which the token starts.
	*
	* \returns The token starting with the given location or NULL if no such token
	* exist. The returned pointer must be freed with clang_disposeTokens before the
	* translation unit is destroyed.
	*/
	getToken :: proc(TU: Translation_Unit, Location: Source_Location) -> ^Token ---

	/**
	* Determine the kind of the given token.
	*/
	getTokenKind :: proc(_: Token) -> Token_Kind ---

	/**
	* Determine the spelling of the given token.
	*
	* The spelling of a token is the textual representation of that token, e.g.,
	* the text of an identifier or keyword.
	*/
	getTokenSpelling :: proc(_: Translation_Unit, _: Token) -> String ---

	/**
	* Retrieve the source location of the given token.
	*/
	getTokenLocation :: proc(_: Translation_Unit, _: Token) -> Source_Location ---

	/**
	* Retrieve a source range that covers the given token.
	*/
	getTokenExtent :: proc(_: Translation_Unit, _: Token) -> Source_Range ---

	/**
	* Tokenize the source code described by the given range into raw
	* lexical tokens.
	*
	* \param TU the translation unit whose text is being tokenized.
	*
	* \param Range the source range in which text should be tokenized. All of the
	* tokens produced by tokenization will fall within this source range,
	*
	* \param Tokens this pointer will be set to point to the array of tokens
	* that occur within the given source range. The returned pointer must be
	* freed with clang_disposeTokens() before the translation unit is destroyed.
	*
	* \param NumTokens will be set to the number of tokens in the \c *Tokens
	* array.
	*
	*/
	tokenize :: proc(TU: Translation_Unit, Range: Source_Range, Tokens: ^^Token, NumTokens: ^c.uint) ---

	/**
	* Annotate the given set of tokens by providing cursors for each token
	* that can be mapped to a specific entity within the abstract syntax tree.
	*
	* This token-annotation routine is equivalent to invoking
	* clang_getCursor() for the source locations of each of the
	* tokens. The cursors provided are filtered, so that only those
	* cursors that have a direct correspondence to the token are
	* accepted. For example, given a function call \c f(x),
	* clang_getCursor() would provide the following cursors:
	*
	*   * when the cursor is over the 'f', a DeclRefExpr cursor referring to 'f'.
	*   * when the cursor is over the '(' or the ')', a CallExpr referring to 'f'.
	*   * when the cursor is over the 'x', a DeclRefExpr cursor referring to 'x'.
	*
	* Only the first and last of these cursors will occur within the
	* annotate, since the tokens "f" and "x' directly refer to a function
	* and a variable, respectively, but the parentheses are just a small
	* part of the full syntax of the function call expression, which is
	* not provided as an annotation.
	*
	* \param TU the translation unit that owns the given tokens.
	*
	* \param Tokens the set of tokens to annotate.
	*
	* \param NumTokens the number of tokens in \p Tokens.
	*
	* \param Cursors an array of \p NumTokens cursors, whose contents will be
	* replaced with the cursors corresponding to each token.
	*/
	annotateTokens :: proc(TU: Translation_Unit, Tokens: ^Token, NumTokens: c.uint, Cursors: ^Cursor) ---

	/**
	* Free the given set of tokens.
	*/
	disposeTokens :: proc(TU: Translation_Unit, Tokens: ^Token, NumTokens: c.uint) ---

	/* for debug/testing */
	getCursorKindSpelling          :: proc(Kind: Cursor_Kind) -> String ---
	getDefinitionSpellingAndExtent :: proc(_: Cursor, startBuf: ^^c.char, endBuf: ^^c.char, startLine: ^c.uint, startColumn: ^c.uint, endLine: ^c.uint, endColumn: ^c.uint) ---
	enableStackTraces              :: proc() ---
	executeOnThread                :: proc(fn: proc "c" (rawptr), user_data: rawptr, stack_size: c.uint) ---

	/**
	* Determine the kind of a particular chunk within a completion string.
	*
	* \param completion_string the completion string to query.
	*
	* \param chunk_number the 0-based index of the chunk in the completion string.
	*
	* \returns the kind of the chunk at the index \c chunk_number.
	*/
	getCompletionChunkKind :: proc(completion_string: Completion_String, chunk_number: c.uint) -> Completion_Chunk_Kind ---

	/**
	* Retrieve the text associated with a particular chunk within a
	* completion string.
	*
	* \param completion_string the completion string to query.
	*
	* \param chunk_number the 0-based index of the chunk in the completion string.
	*
	* \returns the text associated with the chunk at index \c chunk_number.
	*/
	getCompletionChunkText :: proc(completion_string: Completion_String, chunk_number: c.uint) -> String ---

	/**
	* Retrieve the completion string associated with a particular chunk
	* within a completion string.
	*
	* \param completion_string the completion string to query.
	*
	* \param chunk_number the 0-based index of the chunk in the completion string.
	*
	* \returns the completion string associated with the chunk at index
	* \c chunk_number.
	*/
	getCompletionChunkCompletionString :: proc(completion_string: Completion_String, chunk_number: c.uint) -> Completion_String ---

	/**
	* Retrieve the number of chunks in the given code-completion string.
	*/
	getNumCompletionChunks :: proc(completion_string: Completion_String) -> c.uint ---

	/**
	* Determine the priority of this code completion.
	*
	* The priority of a code completion indicates how likely it is that this
	* particular completion is the completion that the user will select. The
	* priority is selected by various internal heuristics.
	*
	* \param completion_string The completion string to query.
	*
	* \returns The priority of this completion string. Smaller values indicate
	* higher-priority (more likely) completions.
	*/
	getCompletionPriority :: proc(completion_string: Completion_String) -> c.uint ---

	/**
	* Determine the availability of the entity that this code-completion
	* string refers to.
	*
	* \param completion_string The completion string to query.
	*
	* \returns The availability of the completion string.
	*/
	getCompletionAvailability :: proc(completion_string: Completion_String) -> Availability_Kind ---

	/**
	* Retrieve the number of annotations associated with the given
	* completion string.
	*
	* \param completion_string the completion string to query.
	*
	* \returns the number of annotations associated with the given completion
	* string.
	*/
	getCompletionNumAnnotations :: proc(completion_string: Completion_String) -> c.uint ---

	/**
	* Retrieve the annotation associated with the given completion string.
	*
	* \param completion_string the completion string to query.
	*
	* \param annotation_number the 0-based index of the annotation of the
	* completion string.
	*
	* \returns annotation string associated with the completion at index
	* \c annotation_number, or a NULL string if that annotation is not available.
	*/
	getCompletionAnnotation :: proc(completion_string: Completion_String, annotation_number: c.uint) -> String ---

	/**
	* Retrieve the parent context of the given completion string.
	*
	* The parent context of a completion string is the semantic parent of
	* the declaration (if any) that the code completion represents. For example,
	* a code completion for an Objective-C method would have the method's class
	* or protocol as its context.
	*
	* \param completion_string The code completion string whose parent is
	* being queried.
	*
	* \param kind DEPRECATED: always set to CXCursor_NotImplemented if non-NULL.
	*
	* \returns The name of the completion parent, e.g., "NSObject" if
	* the completion string represents a method in the NSObject class.
	*/
	getCompletionParent :: proc(completion_string: Completion_String, kind: ^Cursor_Kind) -> String ---

	/**
	* Retrieve the brief documentation comment attached to the declaration
	* that corresponds to the given completion string.
	*/
	getCompletionBriefComment :: proc(completion_string: Completion_String) -> String ---

	/**
	* Retrieve a completion string for an arbitrary declaration or macro
	* definition cursor.
	*
	* \param cursor The cursor to query.
	*
	* \returns A non-context-sensitive completion string for declaration and macro
	* definition cursors, or NULL for other kinds of cursors.
	*/
	getCursorCompletionString :: proc(cursor: Cursor) -> Completion_String ---

	/**
	* Retrieve the number of fix-its for the given completion index.
	*
	* Calling this makes sense only if CXCodeComplete_IncludeCompletionsWithFixIts
	* option was set.
	*
	* \param results The structure keeping all completion results
	*
	* \param completion_index The index of the completion
	*
	* \return The number of fix-its which must be applied before the completion at
	* completion_index can be applied
	*/
	getCompletionNumFixIts :: proc(results: ^Code_Complete_Results, completion_index: c.uint) -> c.uint ---

	/**
	* Fix-its that *must* be applied before inserting the text for the
	* corresponding completion.
	*
	* By default, clang_codeCompleteAt() only returns completions with empty
	* fix-its. Extra completions with non-empty fix-its should be explicitly
	* requested by setting CXCodeComplete_IncludeCompletionsWithFixIts.
	*
	* For the clients to be able to compute position of the cursor after applying
	* fix-its, the following conditions are guaranteed to hold for
	* replacement_range of the stored fix-its:
	*  - Ranges in the fix-its are guaranteed to never contain the completion
	*  point (or identifier under completion point, if any) inside them, except
	*  at the start or at the end of the range.
	*  - If a fix-it range starts or ends with completion point (or starts or
	*  ends after the identifier under completion point), it will contain at
	*  least one character. It allows to unambiguously recompute completion
	*  point after applying the fix-it.
	*
	* The intuition is that provided fix-its change code around the identifier we
	* complete, but are not allowed to touch the identifier itself or the
	* completion point. One example of completions with corrections are the ones
	* replacing '.' with '->' and vice versa:
	*
	* std::unique_ptr<std::vector<int>> vec_ptr;
	* In 'vec_ptr.^', one of the completions is 'push_back', it requires
	* replacing '.' with '->'.
	* In 'vec_ptr->^', one of the completions is 'release', it requires
	* replacing '->' with '.'.
	*
	* \param results The structure keeping all completion results
	*
	* \param completion_index The index of the completion
	*
	* \param fixit_index The index of the fix-it for the completion at
	* completion_index
	*
	* \param replacement_range The fix-it range that must be replaced before the
	* completion at completion_index can be applied
	*
	* \returns The fix-it string that must replace the code at replacement_range
	* before the completion at completion_index can be applied
	*/
	getCompletionFixIt :: proc(results: ^Code_Complete_Results, completion_index: c.uint, fixit_index: c.uint, replacement_range: ^Source_Range) -> String ---

	/**
	* Returns a default set of code-completion options that can be
	* passed to\c clang_codeCompleteAt().
	*/
	defaultCodeCompleteOptions :: proc() -> c.uint ---

	/**
	* Perform code completion at a given location in a translation unit.
	*
	* This function performs code completion at a particular file, line, and
	* column within source code, providing results that suggest potential
	* code snippets based on the context of the completion. The basic model
	* for code completion is that Clang will parse a complete source file,
	* performing syntax checking up to the location where code-completion has
	* been requested. At that point, a special code-completion token is passed
	* to the parser, which recognizes this token and determines, based on the
	* current location in the C/Objective-C/C++ grammar and the state of
	* semantic analysis, what completions to provide. These completions are
	* returned via a new \c CXCodeCompleteResults structure.
	*
	* Code completion itself is meant to be triggered by the client when the
	* user types punctuation characters or whitespace, at which point the
	* code-completion location will coincide with the cursor. For example, if \c p
	* is a pointer, code-completion might be triggered after the "-" and then
	* after the ">" in \c p->. When the code-completion location is after the ">",
	* the completion results will provide, e.g., the members of the struct that
	* "p" points to. The client is responsible for placing the cursor at the
	* beginning of the token currently being typed, then filtering the results
	* based on the contents of the token. For example, when code-completing for
	* the expression \c p->get, the client should provide the location just after
	* the ">" (e.g., pointing at the "g") to this code-completion hook. Then, the
	* client can filter the results based on the current token text ("get"), only
	* showing those results that start with "get". The intent of this interface
	* is to separate the relatively high-latency acquisition of code-completion
	* results from the filtering of results on a per-character basis, which must
	* have a lower latency.
	*
	* \param TU The translation unit in which code-completion should
	* occur. The source files for this translation unit need not be
	* completely up-to-date (and the contents of those source files may
	* be overridden via \p unsaved_files). Cursors referring into the
	* translation unit may be invalidated by this invocation.
	*
	* \param complete_filename The name of the source file where code
	* completion should be performed. This filename may be any file
	* included in the translation unit.
	*
	* \param complete_line The line at which code-completion should occur.
	*
	* \param complete_column The column at which code-completion should occur.
	* Note that the column should point just after the syntactic construct that
	* initiated code completion, and not in the middle of a lexical token.
	*
	* \param unsaved_files the Files that have not yet been saved to disk
	* but may be required for parsing or code completion, including the
	* contents of those files.  The contents and name of these files (as
	* specified by CXUnsavedFile) are copied when necessary, so the
	* client only needs to guarantee their validity until the call to
	* this function returns.
	*
	* \param num_unsaved_files The number of unsaved file entries in \p
	* unsaved_files.
	*
	* \param options Extra options that control the behavior of code
	* completion, expressed as a bitwise OR of the enumerators of the
	* CXCodeComplete_Flags enumeration. The
	* \c clang_defaultCodeCompleteOptions() function returns a default set
	* of code-completion options.
	*
	* \returns If successful, a new \c CXCodeCompleteResults structure
	* containing code-completion results, which should eventually be
	* freed with \c clang_disposeCodeCompleteResults(). If code
	* completion fails, returns NULL.
	*/
	codeCompleteAt :: proc(TU: Translation_Unit, complete_filename: cstring, complete_line: c.uint, complete_column: c.uint, unsaved_files: ^Unsaved_File, num_unsaved_files: c.uint, options: c.uint) -> ^Code_Complete_Results ---

	/**
	* Sort the code-completion results in case-insensitive alphabetical
	* order.
	*
	* \param Results The set of results to sort.
	* \param NumResults The number of results in \p Results.
	*/
	sortCodeCompletionResults :: proc(Results: ^Completion_Result, NumResults: c.uint) ---

	/**
	* Free the given set of code-completion results.
	*/
	disposeCodeCompleteResults :: proc(Results: ^Code_Complete_Results) ---

	/**
	* Determine the number of diagnostics produced prior to the
	* location where code completion was performed.
	*/
	codeCompleteGetNumDiagnostics :: proc(Results: ^Code_Complete_Results) -> c.uint ---

	/**
	* Retrieve a diagnostic associated with the given code completion.
	*
	* \param Results the code completion results to query.
	* \param Index the zero-based diagnostic number to retrieve.
	*
	* \returns the requested diagnostic. This diagnostic must be freed
	* via a call to \c clang_disposeDiagnostic().
	*/
	codeCompleteGetDiagnostic :: proc(Results: ^Code_Complete_Results, Index: c.uint) -> Diagnostic ---

	/**
	* Determines what completions are appropriate for the context
	* the given code completion.
	*
	* \param Results the code completion results to query
	*
	* \returns the kinds of completions that are appropriate for use
	* along with the given code completion results.
	*/
	codeCompleteGetContexts :: proc(Results: ^Code_Complete_Results) -> c.ulonglong ---

	/**
	* Returns the cursor kind for the container for the current code
	* completion context. The container is only guaranteed to be set for
	* contexts where a container exists (i.e. member accesses or Objective-C
	* message sends); if there is not a container, this function will return
	* CXCursor_InvalidCode.
	*
	* \param Results the code completion results to query
	*
	* \param IsIncomplete on return, this value will be false if Clang has complete
	* information about the container. If Clang does not have complete
	* information, this value will be true.
	*
	* \returns the container kind, or CXCursor_InvalidCode if there is not a
	* container
	*/
	codeCompleteGetContainerKind :: proc(Results: ^Code_Complete_Results, IsIncomplete: ^c.uint) -> Cursor_Kind ---

	/**
	* Returns the USR for the container for the current code completion
	* context. If there is not a container for the current context, this
	* function will return the empty string.
	*
	* \param Results the code completion results to query
	*
	* \returns the USR for the container
	*/
	codeCompleteGetContainerUSR :: proc(Results: ^Code_Complete_Results) -> String ---

	/**
	* Returns the currently-entered selector for an Objective-C message
	* send, formatted like "initWithFoo:bar:". Only guaranteed to return a
	* non-empty string for CXCompletionContext_ObjCInstanceMessage and
	* CXCompletionContext_ObjCClassMessage.
	*
	* \param Results the code completion results to query
	*
	* \returns the selector (or partial selector) that has been entered thus far
	* for an Objective-C message send.
	*/
	codeCompleteGetObjCSelector :: proc(Results: ^Code_Complete_Results) -> String ---

	/**
	* Return a version string, suitable for showing to a user, but not
	*        intended to be parsed (the format is not guaranteed to be stable).
	*/
	getClangVersion :: proc() -> String ---

	/**
	* Enable/disable crash recovery.
	*
	* \param isEnabled Flag to indicate if crash recovery is enabled.  A non-zero
	*        value enables crash recovery, while 0 disables it.
	*/
	toggleCrashRecovery :: proc(isEnabled: c.uint) ---

	/**
	* Visit the set of preprocessor inclusions in a translation unit.
	*   The visitor function is called with the provided data for every included
	*   file.  This does not include headers included by the PCH file (unless one
	*   is inspecting the inclusions in the PCH file itself).
	*/
	getInclusions :: proc(tu: Translation_Unit, visitor: Inclusion_Visitor, client_data: Client_Data) ---

	/**
	* If cursor is a statement declaration tries to evaluate the
	* statement and if its variable, tries to evaluate its initializer,
	* into its corresponding type.
	* If it's an expression, tries to evaluate the expression.
	*/
	Cursor_Evaluate :: proc(C: Cursor) -> Eval_Result ---

	/**
	* Returns the kind of the evaluated result.
	*/
	EvalResult_getKind :: proc(E: Eval_Result) -> Eval_Result_Kind ---

	/**
	* Returns the evaluation result as integer if the
	* kind is Int.
	*/
	EvalResult_getAsInt :: proc(E: Eval_Result) -> c.int ---

	/**
	* Returns the evaluation result as a long long integer if the
	* kind is Int. This prevents overflows that may happen if the result is
	* returned with clang_EvalResult_getAsInt.
	*/
	EvalResult_getAsLongLong :: proc(E: Eval_Result) -> c.longlong ---

	/**
	* Returns a non-zero value if the kind is Int and the evaluation
	* result resulted in an unsigned integer.
	*/
	EvalResult_isUnsignedInt :: proc(E: Eval_Result) -> c.uint ---

	/**
	* Returns the evaluation result as an unsigned integer if
	* the kind is Int and clang_EvalResult_isUnsignedInt is non-zero.
	*/
	EvalResult_getAsUnsigned :: proc(E: Eval_Result) -> c.ulonglong ---

	/**
	* Returns the evaluation result as double if the
	* kind is double.
	*/
	EvalResult_getAsDouble :: proc(E: Eval_Result) -> f64 ---

	/**
	* Returns the evaluation result as a constant string if the
	* kind is other than Int or float. User must not free this pointer,
	* instead call clang_EvalResult_dispose on the CXEvalResult returned
	* by clang_Cursor_Evaluate.
	*/
	EvalResult_getAsStr :: proc(E: Eval_Result) -> cstring ---

	/**
	* Disposes the created Eval memory.
	*/
	EvalResult_dispose :: proc(E: Eval_Result) ---

	/**
	* Retrieve a remapping.
	*
	* \param path the path that contains metadata about remappings.
	*
	* \returns the requested remapping. This remapping must be freed
	* via a call to \c clang_remap_dispose(). Can return NULL if an error occurred.
	*/
	getRemappings :: proc(path: cstring) -> Remapping ---

	/**
	* Retrieve a remapping.
	*
	* \param filePaths pointer to an array of file paths containing remapping info.
	*
	* \param numFiles number of file paths.
	*
	* \returns the requested remapping. This remapping must be freed
	* via a call to \c clang_remap_dispose(). Can return NULL if an error occurred.
	*/
	getRemappingsFromFileList :: proc(filePaths: ^^c.char, numFiles: c.uint) -> Remapping ---

	/**
	* Determine the number of remappings.
	*/
	remap_getNumFiles :: proc(_: Remapping) -> c.uint ---

	/**
	* Get the original and the associated filename from the remapping.
	*
	* \param original If non-NULL, will be set to the original filename.
	*
	* \param transformed If non-NULL, will be set to the filename that the original
	* is associated with.
	*/
	remap_getFilenames :: proc(_: Remapping, index: c.uint, original: ^String, transformed: ^String) ---

	/**
	* Dispose the remapping.
	*/
	remap_dispose :: proc(_: Remapping) ---

	/**
	* Find references of a declaration in a specific file.
	*
	* \param cursor pointing to a declaration or a reference of one.
	*
	* \param file to search for references.
	*
	* \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
	* each reference found.
	* The CXSourceRange will point inside the file; if the reference is inside
	* a macro (and not a macro argument) the CXSourceRange will be invalid.
	*
	* \returns one of the CXResult enumerators.
	*/
	findReferencesInFile :: proc(cursor: Cursor, file: File, visitor: Cursor_And_Range_Visitor) -> Result ---

	/**
	* Find #import/#include directives in a specific file.
	*
	* \param TU translation unit containing the file to query.
	*
	* \param file to search for #import/#include directives.
	*
	* \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
	* each directive found.
	*
	* \returns one of the CXResult enumerators.
	*/
	findIncludesInFile                  :: proc(TU: Translation_Unit, file: File, visitor: Cursor_And_Range_Visitor) -> Result ---
	findReferencesInFileWithBlock       :: proc(_: Cursor, _: File, _: Cursor_And_Range_Visitor_Block) -> Result ---
	findIncludesInFileWithBlock         :: proc(_: Translation_Unit, _: File, _: Cursor_And_Range_Visitor_Block) -> Result ---
	index_isEntityObjCContainerKind     :: proc(_: Idx_Entity_Kind) -> c.int ---
	index_getObjCContainerDeclInfo      :: proc(_: ^Idx_Decl_Info) -> ^Idx_Obj_Ccontainer_Decl_Info ---
	index_getObjCInterfaceDeclInfo      :: proc(_: ^Idx_Decl_Info) -> ^Idx_Obj_Cinterface_Decl_Info ---
	index_getObjCCategoryDeclInfo       :: proc(_: ^Idx_Decl_Info) -> ^Idx_Obj_Ccategory_Decl_Info ---
	index_getObjCProtocolRefListInfo    :: proc(_: ^Idx_Decl_Info) -> ^Idx_Obj_Cprotocol_Ref_List_Info ---
	index_getObjCPropertyDeclInfo       :: proc(_: ^Idx_Decl_Info) -> ^Idx_Obj_Cproperty_Decl_Info ---
	index_getIBOutletCollectionAttrInfo :: proc(_: ^Idx_Attr_Info) -> ^Idx_Iboutlet_Collection_Attr_Info ---
	index_getCXXClassDeclInfo           :: proc(_: ^Idx_Decl_Info) -> ^Idx_Cxxclass_Decl_Info ---

	/**
	* For retrieving a custom CXIdxClientContainer attached to a
	* container.
	*/
	index_getClientContainer :: proc(_: ^Idx_Container_Info) -> Idx_Client_Container ---

	/**
	* For setting a custom CXIdxClientContainer attached to a
	* container.
	*/
	index_setClientContainer :: proc(_: ^Idx_Container_Info, _: Idx_Client_Container) ---

	/**
	* For retrieving a custom CXIdxClientEntity attached to an entity.
	*/
	index_getClientEntity :: proc(_: ^Idx_Entity_Info) -> Idx_Client_Entity ---

	/**
	* For setting a custom CXIdxClientEntity attached to an entity.
	*/
	index_setClientEntity :: proc(_: ^Idx_Entity_Info, _: Idx_Client_Entity) ---

	/**
	* An indexing action/session, to be applied to one or multiple
	* translation units.
	*
	* \param CIdx The index object with which the index action will be associated.
	*/
	IndexAction_create :: proc(CIdx: Index) -> Index_Action ---

	/**
	* Destroy the given index action.
	*
	* The index action must not be destroyed until all of the translation units
	* created within that index action have been destroyed.
	*/
	IndexAction_dispose :: proc(_: Index_Action) ---

	/**
	* Index the given source file and the translation unit corresponding
	* to that file via callbacks implemented through #IndexerCallbacks.
	*
	* \param client_data pointer data supplied by the client, which will
	* be passed to the invoked callbacks.
	*
	* \param index_callbacks Pointer to indexing callbacks that the client
	* implements.
	*
	* \param index_callbacks_size Size of #IndexerCallbacks structure that gets
	* passed in index_callbacks.
	*
	* \param index_options A bitmask of options that affects how indexing is
	* performed. This should be a bitwise OR of the CXIndexOpt_XXX flags.
	*
	* \param[out] out_TU pointer to store a \c CXTranslationUnit that can be
	* reused after indexing is finished. Set to \c NULL if you do not require it.
	*
	* \returns 0 on success or if there were errors from which the compiler could
	* recover.  If there is a failure from which there is no recovery, returns
	* a non-zero \c CXErrorCode.
	*
	* The rest of the parameters are the same as #clang_parseTranslationUnit.
	*/
	indexSourceFile :: proc(_: Index_Action, client_data: Client_Data, index_callbacks: ^Indexer_Callbacks, index_callbacks_size: c.uint, index_options: c.uint, source_filename: cstring, command_line_args: [^]cstring, num_command_line_args: c.int, unsaved_files: ^Unsaved_File, num_unsaved_files: c.uint, out_TU: ^Translation_Unit, TU_options: c.uint) -> c.int ---

	/**
	* Same as clang_indexSourceFile but requires a full command line
	* for \c command_line_args including argv[0]. This is useful if the standard
	* library paths are relative to the binary.
	*/
	indexSourceFileFullArgv :: proc(_: Index_Action, client_data: Client_Data, index_callbacks: ^Indexer_Callbacks, index_callbacks_size: c.uint, index_options: c.uint, source_filename: cstring, command_line_args: [^]cstring, num_command_line_args: c.int, unsaved_files: ^Unsaved_File, num_unsaved_files: c.uint, out_TU: ^Translation_Unit, TU_options: c.uint) -> c.int ---

	/**
	* Index the given translation unit via callbacks implemented through
	* #IndexerCallbacks.
	*
	* The order of callback invocations is not guaranteed to be the same as
	* when indexing a source file. The high level order will be:
	*
	*   -Preprocessor callbacks invocations
	*   -Declaration/reference callbacks invocations
	*   -Diagnostic callback invocations
	*
	* The parameters are the same as #clang_indexSourceFile.
	*
	* \returns If there is a failure from which there is no recovery, returns
	* non-zero, otherwise returns 0.
	*/
	indexTranslationUnit :: proc(_: Index_Action, client_data: Client_Data, index_callbacks: ^Indexer_Callbacks, index_callbacks_size: c.uint, index_options: c.uint, _: Translation_Unit) -> c.int ---

	/**
	* Retrieve the CXIdxFile, file, line, column, and offset represented by
	* the given CXIdxLoc.
	*
	* If the location refers into a macro expansion, retrieves the
	* location of the macro expansion and if it refers into a macro argument
	* retrieves the location of the argument.
	*/
	indexLoc_getFileLocation :: proc(loc: Idx_Loc, indexFile: ^Idx_Client_File, file: ^File, line: ^c.uint, column: ^c.uint, offset: ^c.uint) ---

	/**
	* Retrieve the CXSourceLocation represented by the given CXIdxLoc.
	*/
	indexLoc_getCXSourceLocation :: proc(loc: Idx_Loc) -> Source_Location ---

	/**
	* Visit the fields of a particular type.
	*
	* This function visits all the direct fields of the given cursor,
	* invoking the given \p visitor function with the cursors of each
	* visited field. The traversal may be ended prematurely, if
	* the visitor returns \c CXFieldVisit_Break.
	*
	* \param T the record type whose field may be visited.
	*
	* \param visitor the visitor function that will be invoked for each
	* field of \p T.
	*
	* \param client_data pointer data supplied by the client, which will
	* be passed to the visitor each time it is invoked.
	*
	* \returns a non-zero value if the traversal was terminated
	* prematurely by the visitor returning \c CXFieldVisit_Break.
	*/
	Type_visitFields :: proc(T: Type, visitor: Field_Visitor, client_data: Client_Data) -> c.uint ---

	/**
	* Visit the base classes of a type.
	*
	* This function visits all the direct base classes of a the given cursor,
	* invoking the given \p visitor function with the cursors of each
	* visited base. The traversal may be ended prematurely, if
	* the visitor returns \c CXFieldVisit_Break.
	*
	* \param T the record type whose field may be visited.
	*
	* \param visitor the visitor function that will be invoked for each
	* field of \p T.
	*
	* \param client_data pointer data supplied by the client, which will
	* be passed to the visitor each time it is invoked.
	*
	* \returns a non-zero value if the traversal was terminated
	* prematurely by the visitor returning \c CXFieldVisit_Break.
	*/
	visitCXXBaseClasses :: proc(T: Type, visitor: Field_Visitor, client_data: Client_Data) -> c.uint ---

	/**
	* Retrieve the spelling of a given CXBinaryOperatorKind.
	*/
	getBinaryOperatorKindSpelling :: proc(kind: CXBinary_Operator_Kind) -> String ---

	/**
	* Retrieve the binary operator kind of this cursor.
	*
	* If this cursor is not a binary operator then returns Invalid.
	*/
	getCursorBinaryOperatorKind :: proc(cursor: Cursor) -> CXBinary_Operator_Kind ---

	/**
	* Retrieve the spelling of a given CXUnaryOperatorKind.
	*/
	getUnaryOperatorKindSpelling :: proc(kind: Unary_Operator_Kind) -> String ---

	/**
	* Retrieve the unary operator kind of this cursor.
	*
	* If this cursor is not a unary operator then returns Invalid.
	*/
	getCursorUnaryOperatorKind :: proc(cursor: Cursor) -> Unary_Operator_Kind ---
}
