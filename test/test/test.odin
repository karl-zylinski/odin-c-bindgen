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

Color :: struct {
	r: i32,
	g: i32,
	b: i32,
	a: i32,
}

