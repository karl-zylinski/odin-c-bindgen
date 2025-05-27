package test

import "core:c"

_ :: c



FIVE_SUB_TWO :: (f32) (5) - (f32)(2)
UNNEST :: "Test"

ARRAY :: {1}

LIGHTGRAY :: (Color){ 200, 200, 200, 255 }

FUNC_TEST_RESULT :: 1 + 2 + 3

ARRAY_TEST :: {1, 2, 3}

// FALSE :: ! true
// TRUE :: !false

UFBX_HEADER_VERSION :: (u32)(0)*1000000 + (u32)(18)*1000 + (u32)(0)

NO_INDEX :: (u32)0

VALUE :: 20010
// VALUE_STRING :: #VALUE

CINDEX_VERSION_MAJOR :: 0
CINDEX_VERSION_MINOR :: 64

// CINDEX_VERSION_STRING :: #CINDEX_VERSION_MAJOR "." #CINDEX_VERSION_MINOR

// line comment one line
LINE_COMMENT_ONE :: 1

// line comment two lines
// the other line
LINE_COMMENT_TWO :: 2

/* block comment one line */
BLOCK_COMMENT_ONE :: 1

/* block comment two lines
 * the other line
 */
BLOCK_COMMENT_TWO :: 2

END_LINE_COMMENT :: 12 // end line comment
END_LINE_BLOCK_COMMENT :: 34 /* end line block comment */
BELOW_BLOCK_COMMENT :: 56 /* inline block comment on the line above */

BLOCK_ABOVE_SECTION :: 78

////////////////////////////////////////////////////////////////////////////////
//// Section header
////////////////////////////////////////////////////////////////////////////////
SECTIONED_ONE                 :: 1 << 0  /* end line */
SECTIONED_TWO                 :: 1 << 1  /* end line */

Color :: struct {
	r: i32,
	g: i32,
	b: i32,
	a: i32,
}

