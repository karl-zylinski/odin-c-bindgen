/*==-- clang-c/Documentation.h - Utilities for comment processing -*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides a supplementary interface for inspecting              *|
|* documentation comments.                                                    *|
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
* A parsed comment.
*/
CXComment :: struct {
	ASTNode:         rawptr,
	TranslationUnit: Translation_Unit,
}

/**
* Describes the type of the comment AST node (\c CXComment).  A comment
* node can be considered block content (e. g., paragraph), inline content
* (plain text) or neither (the root AST node).
*/
Comment_Kind :: enum c.int {
	/**
	* Null comment.  No AST node is constructed at the requested location
	* because there is no text or a syntax error.
	*/
	Null = 0,

	/**
	* Plain text.  Inline content.
	*/
	Text = 1,

	/**
	* A command with word-like arguments that is considered inline content.
	*
	* For example: \\c command.
	*/
	InlineCommand = 2,

	/**
	* HTML start tag with attributes (name-value pairs).  Considered
	* inline content.
	*
	* For example:
	* \verbatim
	* <br> <br /> <a href="http://example.org/">
	* \endverbatim
	*/
	HTMLStartTag = 3,

	/**
	* HTML end tag.  Considered inline content.
	*
	* For example:
	* \verbatim
	* </a>
	* \endverbatim
	*/
	HTMLEndTag = 4,

	/**
	* A paragraph, contains inline comment.  The paragraph itself is
	* block content.
	*/
	Paragraph = 5,

	/**
	* A command that has zero or more word-like arguments (number of
	* word-like arguments depends on command name) and a paragraph as an
	* argument.  Block command is block content.
	*
	* Paragraph argument is also a child of the block command.
	*
	* For example: \has 0 word-like arguments and a paragraph argument.
	*
	* AST nodes of special kinds that parser knows about (e. g., \\param
	* command) have their own node kinds.
	*/
	BlockCommand = 6,

	/**
	* A \\param or \\arg command that describes the function parameter
	* (name, passing direction, description).
	*
	* For example: \\param [in] ParamName description.
	*/
	ParamCommand = 7,

	/**
	* A \\tparam command that describes a template parameter (name and
	* description).
	*
	* For example: \\tparam T description.
	*/
	TParamCommand = 8,

	/**
	* A verbatim block command (e. g., preformatted code).  Verbatim
	* block has an opening and a closing command and contains multiple lines of
	* text (\c CXComment_VerbatimBlockLine child nodes).
	*
	* For example:
	* \\verbatim
	* aaa
	* \\endverbatim
	*/
	VerbatimBlockCommand = 9,

	/**
	* A line of text that is contained within a
	* CXComment_VerbatimBlockCommand node.
	*/
	VerbatimBlockLine = 10,

	/**
	* A verbatim line command.  Verbatim line has an opening command,
	* a single line of text (up to the newline after the opening command) and
	* has no closing command.
	*/
	VerbatimLine = 11,

	/**
	* A full comment attached to a declaration, contains block content.
	*/
	FullComment = 12,
}

/**
* The most appropriate rendering mode for an inline command, chosen on
* command semantics in Doxygen.
*/
Comment_Inline_Command_Render_Kind :: enum c.int {
	/**
	* Command argument should be rendered in a normal font.
	*/
	Normal,

	/**
	* Command argument should be rendered in a bold font.
	*/
	Bold,

	/**
	* Command argument should be rendered in a monospaced font.
	*/
	Monospaced,

	/**
	* Command argument should be rendered emphasized (typically italic
	* font).
	*/
	Emphasized,

	/**
	* Command argument should not be rendered (since it only defines an anchor).
	*/
	Anchor,
}

/**
* Describes parameter passing direction for \\param or \\arg command.
*/
Comment_Param_Pass_Direction :: enum c.int {
	/**
	* The parameter is an input parameter.
	*/
	In,

	/**
	* The parameter is an output parameter.
	*/
	Out,

	/**
	* The parameter is an input and output parameter.
	*/
	InOut,
}

/**
* CXAPISet is an opaque type that represents a data structure containing all
* the API information for a given translation unit. This can be used for a
* single symbol symbol graph for a given symbol.
*/
Apiset :: struct {}

@(default_calling_convention="c", link_prefix="clang_")
foreign lib {
	/**
	* Given a cursor that represents a documentable entity (e.g.,
	* declaration), return the associated parsed comment as a
	* \c CXComment_FullComment AST node.
	*/
	Cursor_getParsedComment :: proc(C: Cursor) -> CXComment ---

	/**
	* \param Comment AST node of any kind.
	*
	* \returns the type of the AST node.
	*/
	Comment_getKind :: proc(Comment: CXComment) -> Comment_Kind ---

	/**
	* \param Comment AST node of any kind.
	*
	* \returns number of children of the AST node.
	*/
	Comment_getNumChildren :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment AST node of any kind.
	*
	* \param ChildIdx child index (zero-based).
	*
	* \returns the specified child of the AST node.
	*/
	Comment_getChild :: proc(Comment: CXComment, ChildIdx: c.uint) -> CXComment ---

	/**
	* A \c CXComment_Paragraph node is considered whitespace if it contains
	* only \c CXComment_Text nodes that are empty or whitespace.
	*
	* Other AST nodes (except \c CXComment_Paragraph and \c CXComment_Text) are
	* never considered whitespace.
	*
	* \returns non-zero if \c Comment is whitespace.
	*/
	Comment_isWhitespace :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \returns non-zero if \c Comment is inline content and has a newline
	* immediately following it in the comment text.  Newlines between paragraphs
	* do not count.
	*/
	InlineContentComment_hasTrailingNewline :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_Text AST node.
	*
	* \returns text contained in the AST node.
	*/
	TextComment_getText :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_InlineCommand AST node.
	*
	* \returns name of the inline command.
	*/
	InlineCommandComment_getCommandName :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_InlineCommand AST node.
	*
	* \returns the most appropriate rendering mode, chosen on command
	* semantics in Doxygen.
	*/
	InlineCommandComment_getRenderKind :: proc(Comment: CXComment) -> Comment_Inline_Command_Render_Kind ---

	/**
	* \param Comment a \c CXComment_InlineCommand AST node.
	*
	* \returns number of command arguments.
	*/
	InlineCommandComment_getNumArgs :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_InlineCommand AST node.
	*
	* \param ArgIdx argument index (zero-based).
	*
	* \returns text of the specified argument.
	*/
	InlineCommandComment_getArgText :: proc(Comment: CXComment, ArgIdx: c.uint) -> String ---

	/**
	* \param Comment a \c CXComment_HTMLStartTag or \c CXComment_HTMLEndTag AST
	* node.
	*
	* \returns HTML tag name.
	*/
	HTMLTagComment_getTagName :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_HTMLStartTag AST node.
	*
	* \returns non-zero if tag is self-closing (for example, &lt;br /&gt;).
	*/
	HTMLStartTagComment_isSelfClosing :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_HTMLStartTag AST node.
	*
	* \returns number of attributes (name-value pairs) attached to the start tag.
	*/
	HTMLStartTag_getNumAttrs :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_HTMLStartTag AST node.
	*
	* \param AttrIdx attribute index (zero-based).
	*
	* \returns name of the specified attribute.
	*/
	HTMLStartTag_getAttrName :: proc(Comment: CXComment, AttrIdx: c.uint) -> String ---

	/**
	* \param Comment a \c CXComment_HTMLStartTag AST node.
	*
	* \param AttrIdx attribute index (zero-based).
	*
	* \returns value of the specified attribute.
	*/
	HTMLStartTag_getAttrValue :: proc(Comment: CXComment, AttrIdx: c.uint) -> String ---

	/**
	* \param Comment a \c CXComment_BlockCommand AST node.
	*
	* \returns name of the block command.
	*/
	BlockCommandComment_getCommandName :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_BlockCommand AST node.
	*
	* \returns number of word-like arguments.
	*/
	BlockCommandComment_getNumArgs :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_BlockCommand AST node.
	*
	* \param ArgIdx argument index (zero-based).
	*
	* \returns text of the specified word-like argument.
	*/
	BlockCommandComment_getArgText :: proc(Comment: CXComment, ArgIdx: c.uint) -> String ---

	/**
	* \param Comment a \c CXComment_BlockCommand or
	* \c CXComment_VerbatimBlockCommand AST node.
	*
	* \returns paragraph argument of the block command.
	*/
	BlockCommandComment_getParagraph :: proc(Comment: CXComment) -> CXComment ---

	/**
	* \param Comment a \c CXComment_ParamCommand AST node.
	*
	* \returns parameter name.
	*/
	ParamCommandComment_getParamName :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_ParamCommand AST node.
	*
	* \returns non-zero if the parameter that this AST node represents was found
	* in the function prototype and \c clang_ParamCommandComment_getParamIndex
	* function will return a meaningful value.
	*/
	ParamCommandComment_isParamIndexValid :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_ParamCommand AST node.
	*
	* \returns zero-based parameter index in function prototype.
	*/
	ParamCommandComment_getParamIndex :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_ParamCommand AST node.
	*
	* \returns non-zero if parameter passing direction was specified explicitly in
	* the comment.
	*/
	ParamCommandComment_isDirectionExplicit :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_ParamCommand AST node.
	*
	* \returns parameter passing direction.
	*/
	ParamCommandComment_getDirection :: proc(Comment: CXComment) -> Comment_Param_Pass_Direction ---

	/**
	* \param Comment a \c CXComment_TParamCommand AST node.
	*
	* \returns template parameter name.
	*/
	TParamCommandComment_getParamName :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_TParamCommand AST node.
	*
	* \returns non-zero if the parameter that this AST node represents was found
	* in the template parameter list and
	* \c clang_TParamCommandComment_getDepth and
	* \c clang_TParamCommandComment_getIndex functions will return a meaningful
	* value.
	*/
	TParamCommandComment_isParamPositionValid :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_TParamCommand AST node.
	*
	* \returns zero-based nesting depth of this parameter in the template parameter list.
	*
	* For example,
	* \verbatim
	*     template<typename C, template<typename T> class TT>
	*     void test(TT<int> aaa);
	* \endverbatim
	* for C and TT nesting depth is 0,
	* for T nesting depth is 1.
	*/
	TParamCommandComment_getDepth :: proc(Comment: CXComment) -> c.uint ---

	/**
	* \param Comment a \c CXComment_TParamCommand AST node.
	*
	* \returns zero-based parameter index in the template parameter list at a
	* given nesting depth.
	*
	* For example,
	* \verbatim
	*     template<typename C, template<typename T> class TT>
	*     void test(TT<int> aaa);
	* \endverbatim
	* for C and TT nesting depth is 0, so we can ask for index at depth 0:
	* at depth 0 C's index is 0, TT's index is 1.
	*
	* For T nesting depth is 1, so we can ask for index at depth 0 and 1:
	* at depth 0 T's index is 1 (same as TT's),
	* at depth 1 T's index is 0.
	*/
	TParamCommandComment_getIndex :: proc(Comment: CXComment, Depth: c.uint) -> c.uint ---

	/**
	* \param Comment a \c CXComment_VerbatimBlockLine AST node.
	*
	* \returns text contained in the AST node.
	*/
	VerbatimBlockLineComment_getText :: proc(Comment: CXComment) -> String ---

	/**
	* \param Comment a \c CXComment_VerbatimLine AST node.
	*
	* \returns text contained in the AST node.
	*/
	VerbatimLineComment_getText :: proc(Comment: CXComment) -> String ---

	/**
	* Convert an HTML tag AST node to string.
	*
	* \param Comment a \c CXComment_HTMLStartTag or \c CXComment_HTMLEndTag AST
	* node.
	*
	* \returns string containing an HTML tag.
	*/
	HTMLTagComment_getAsString :: proc(Comment: CXComment) -> String ---

	/**
	* Convert a given full parsed comment to an HTML fragment.
	*
	* Specific details of HTML layout are subject to change.  Don't try to parse
	* this HTML back into an AST, use other APIs instead.
	*
	* Currently the following CSS classes are used:
	* \li "para-brief" for \paragraph and equivalent commands;
	* \li "para-returns" for \\returns paragraph and equivalent commands;
	* \li "word-returns" for the "Returns" word in \\returns paragraph.
	*
	* Function argument documentation is rendered as a \<dl\> list with arguments
	* sorted in function prototype order.  CSS classes used:
	* \li "param-name-index-NUMBER" for parameter name (\<dt\>);
	* \li "param-descr-index-NUMBER" for parameter description (\<dd\>);
	* \li "param-name-index-invalid" and "param-descr-index-invalid" are used if
	* parameter index is invalid.
	*
	* Template parameter documentation is rendered as a \<dl\> list with
	* parameters sorted in template parameter list order.  CSS classes used:
	* \li "tparam-name-index-NUMBER" for parameter name (\<dt\>);
	* \li "tparam-descr-index-NUMBER" for parameter description (\<dd\>);
	* \li "tparam-name-index-other" and "tparam-descr-index-other" are used for
	* names inside template template parameters;
	* \li "tparam-name-index-invalid" and "tparam-descr-index-invalid" are used if
	* parameter position is invalid.
	*
	* \param Comment a \c CXComment_FullComment AST node.
	*
	* \returns string containing an HTML fragment.
	*/
	FullComment_getAsHTML :: proc(Comment: CXComment) -> String ---

	/**
	* Convert a given full parsed comment to an XML document.
	*
	* A Relax NG schema for the XML can be found in comment-xml-schema.rng file
	* inside clang source tree.
	*
	* \param Comment a \c CXComment_FullComment AST node.
	*
	* \returns string containing an XML document.
	*/
	FullComment_getAsXML :: proc(Comment: CXComment) -> String ---

	/**
	* Traverses the translation unit to create a \c CXAPISet.
	*
	* \param tu is the \c CXTranslationUnit to build the \c CXAPISet for.
	*
	* \param out_api is a pointer to the output of this function. It is needs to be
	* disposed of by calling clang_disposeAPISet.
	*
	* \returns Error code indicating success or failure of the APISet creation.
	*/
	createAPISet :: proc(tu: Translation_Unit, out_api: ^Apiset) -> Error_Code ---

	/**
	* Dispose of an APISet.
	*
	* The provided \c CXAPISet can not be used after this function is called.
	*/
	disposeAPISet :: proc(api: Apiset) ---

	/**
	* Generate a single symbol symbol graph for the given USR. Returns a null
	* string if the associated symbol can not be found in the provided \c CXAPISet.
	*
	* The output contains the symbol graph as well as some additional information
	* about related symbols.
	*
	* \param usr is a string containing the USR of the symbol to generate the
	* symbol graph for.
	*
	* \param api the \c CXAPISet to look for the symbol in.
	*
	* \returns a string containing the serialized symbol graph representation for
	* the symbol being queried or a null string if it can not be found in the
	* APISet.
	*/
	getSymbolGraphForUSR :: proc(usr: cstring, api: Apiset) -> String ---

	/**
	* Generate a single symbol symbol graph for the declaration at the given
	* cursor. Returns a null string if the AST node for the cursor isn't a
	* declaration.
	*
	* The output contains the symbol graph as well as some additional information
	* about related symbols.
	*
	* \param cursor the declaration for which to generate the single symbol symbol
	* graph.
	*
	* \returns a string containing the serialized symbol graph representation for
	* the symbol being queried or a null string if it can not be found in the
	* APISet.
	*/
	getSymbolGraphForCursor :: proc(cursor: Cursor) -> String ---
}
