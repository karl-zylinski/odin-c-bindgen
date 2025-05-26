#pragma GCC push_options
#pragma GCC optimize ("O0")

#define NEST(x) NEST1(x)
#define NEST1(x) NEST2(x)
#define NEST2(x) (x)

#define SUB(x, y) (float) (x) - (float)(y)

#define FIVE_SUB_TWO SUB(5, 2)
#define UNNEST NEST("Test")

#define ARRAY {1}

#define CLITERAL(type) (type)
#define LIGHTGRAY CLITERAL(Color){ 200, 200, 200, 255 }

#define FUNC(x, y, z) (x + y + z)
#define FUNC_TEST 1, 2, 3
#define FUNC_TEST_RESULT FUNC(FUNC_TEST)

#define ARRAY_TEST {FUNC_TEST}

#define FALSE ! true
#define TRUE !false

#define MULT_VAL (10, 20, 30)

#define ufbx_pack_version(major, minor, patch) ((uint32_t)(major)*1000000u + (uint32_t)(minor)*1000u + (uint32_t)(patch))
#define UFBX_HEADER_VERSION ufbx_pack_version(0, 18, 0)
#define FUNC_ALIAS ufbx_pack_version

#define NO_INDEX (uint32_t)0

#define VALUE 20010
#define VALUE_STRING #VALUE

#define CINDEX_VERSION_MAJOR 0
#define CINDEX_VERSION_MINOR 64

#define CINDEX_VERSION_STRING #CINDEX_VERSION_MAJOR "." #CINDEX_VERSION_MINOR

// line comment one line
#define LINE_COMMENT_ONE 1

// line comment two lines
// the other line
#define LINE_COMMENT_TWO 2

/* block comment one line */
#define BLOCK_COMMENT_ONE 1

/* block comment two lines
 * the other line
 */
#define BLOCK_COMMENT_TWO 2

#define END_LINE_COMMENT 12 // end line comment
#define END_LINE_BLOCK_COMMENT 34 /* end line block comment */
#define BELOW_BLOCK_COMMENT 56 /* inline block comment on the line above */

#define BLOCK_ABOVE_SECTION 78

////////////////////////////////////////////////////////////////////////////////
//// Section header
////////////////////////////////////////////////////////////////////////////////

#define SECTIONED_ONE                 (1u << 0u)  /* end line */
#define SECTIONED_TWO                 (1u << 1u)  /* end line */

struct Color {
    int r;
    int g;
    int b;
    int a;
};

typedef int simple_typedef;

typedef void void_typedef;

#pragma GCC pop_options
