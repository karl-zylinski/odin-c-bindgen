package test

import "core:c"
import "core:c/libc"

_ :: c
_ :: libc



FIVE_SUB_TWO :: (f32)(5)-(f32)(2)
UNNEST :: (x)

ARRAY :: {1}

// LIGHTGRAY :: (Color){200,200,200,255}

// FUNC_TEST :: 1,2,3
FUNC_TEST_RESULT :: (1+2+3)

ARRAY_TEST :: {1,2,3}

FALSE :: !true
TRUE :: !false

// MULT_VAL :: (10,20,30)

UFBX_HEADER_VERSION :: ((u32)(0)*1000000+(u32)(18)*1000+(u32)(0))
// FUNC_ALIAS :: ufbx_pack_version

NO_INDEX :: ~(u32)0

VALUE :: 20010
// VALUE_STRING :: #20010

CINDEX_VERSION_MAJOR :: 0
CINDEX_VERSION_MINOR :: 64

// CINDEX_VERSION_STRING :: #0"."#64

LINE_COMMENT_ONE :: 1

LINE_COMMENT_TWO :: 2

BLOCK_COMMENT_ONE :: 1

BLOCK_COMMENT_TWO :: 2

END_LINE_COMMENT :: 12// end line comment
END_LINE_BLOCK_COMMENT :: 34/* end line block comment */
BELOW_BLOCK_COMMENT :: 56/* inline block comment on the line above */

BLOCK_ABOVE_SECTION :: 78

SECTIONED_ONE :: (1<<0)/* end line */
SECTIONED_TWO :: (1<<1)/* end line */

Color :: struct {
	r: c.int,
	g: c.int,
	b: c.int,
	a: c.int,
}

HasBool :: struct {
	a: bool,
}

my_time :: libc.time_t

// Should add a bindgen.sjson with `remove_type_prefix = "test_"
// typedef struct test_time_t {
//   int seconds;
// } test_time_t;
simple_typedef :: c.int

void_typedef :: void

INT :: c.int

// TYPE :: simple_typedef

// TEST_MACRO :: 
