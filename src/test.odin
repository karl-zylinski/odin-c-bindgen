// #+feature dynamic-literals


package bindgen


// import "core:fmt"
// import vmem "core:mem/virtual"
// import "core:os/os2"
// import "core:testing"


// // These are just some simple tests that I wrote while working on the macro parser. They are not exhaustive, but they do cover some of the basic functionality.
// // Feel free to add more tests/test cases as you see fit. I haven't added any test cases for malformed macros but it's not our problem to deal with bad c code.
// @(test)
// test_parse_value :: proc(t: ^testing.T) {
// 	gen_arena: vmem.Arena
// 	defer vmem.arena_destroy(&gen_arena)
// 	context.allocator = vmem.arena_allocator(&gen_arena)
// 	context.temp_allocator = vmem.arena_allocator(&gen_arena)

// 	ret, type := parse_value("5")
// 	testing.expect_value(t, type, Macro_Type.Constant_Expression)
// 	compare_arrays(ret, []string{"5"}, t)

// 	ret, type = parse_value("10 + 5")
// 	testing.expect_value(t, type, Macro_Type.Constant_Expression)
// 	compare_arrays(ret, []string{"10", "+", "5"}, t)

// 	ret, type = parse_value("\"test\", 5")
// 	testing.expect_value(t, type, Macro_Type.Multivalue)
// 	compare_arrays(ret, []string{"\"test\"", "5"}, t)

// 	ret, type = parse_value("(10 + 5)")
// 	testing.expect_value(t, type, Macro_Type.Constant_Expression)
// 	compare_arrays(ret, []string{"(10 + 5)"}, t)
// }

// compare_arrays :: #force_inline proc(a, b: []string, t: ^testing.T) {
// 	if testing.expect_value(t, len(a), len(b)) == false {
// 		return
// 	}
// 	for i in 0 ..< len(a) {
// 		testing.expect_value(t, a[i], b[i])
// 	}
// }

// @(test)
// test_parse_macro :: proc(t: ^testing.T) {
// 	gen_arena: vmem.Arena
// 	defer vmem.arena_destroy(&gen_arena)
// 	context.allocator = vmem.arena_allocator(&gen_arena)
// 	context.temp_allocator = vmem.arena_allocator(&gen_arena)

// 	macro_token := parse_macro("VALUELESS_MACRO")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Valueless)
// 	testing.expect_value(t, macro_token.name, "VALUELESS_MACRO")
// 	compare_arrays(macro_token.values, []string{}, t)


// 	macro_token = parse_macro("CONSTANT 5")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Constant_Expression)
// 	testing.expect_value(t, macro_token.name, "CONSTANT")
// 	compare_arrays(macro_token.values, []string{"5"}, t)


// 	macro_token = parse_macro("CONSTANT 01")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Constant_Expression)
// 	testing.expect_value(t, macro_token.name, "CONSTANT")
// 	compare_arrays(macro_token.values, []string{"01"}, t)


// 	macro_token = parse_macro("CONSTANT 0b0001")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Constant_Expression)
// 	testing.expect_value(t, macro_token.name, "CONSTANT")
// 	compare_arrays(macro_token.values, []string{"0b0001"}, t)


// 	macro_token = parse_macro("CONSTANT 0x0001")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Constant_Expression)
// 	testing.expect_value(t, macro_token.name, "CONSTANT")
// 	compare_arrays(macro_token.values, []string{"0x0001"}, t)


// 	macro_token = parse_macro("CONSTANT \"String\"")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Constant_Expression)
// 	testing.expect_value(t, macro_token.name, "CONSTANT")
// 	compare_arrays(macro_token.values, []string{"\"String\""}, t)

// 	macro_token = parse_macro("FUNCTION(x) (x)")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Function)
// 	testing.expect_value(t, macro_token.name, "FUNCTION")
// 	compare_arrays(macro_token.values, []string{"(${0}$)"}, t)

// 	macro_token = parse_macro("FUNCTION(x, y) (x + y)")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Function)
// 	testing.expect_value(t, macro_token.name, "FUNCTION")
// 	compare_arrays(macro_token.values, []string{"(${0}$ + ${1}$)"}, t)

// 	macro_token = parse_macro("FUNCTION(x, y, z) (z - x + y)")
// 	testing.expect_value(t, macro_token.type, Macro_Type.Function)
// 	testing.expect_value(t, macro_token.name, "FUNCTION")
// 	compare_arrays(macro_token.values, []string{"(${2}$ - ${0}$ + ${1}$)"}, t)
// }


// @(test)
// test_parse_pystring :: proc(t: ^testing.T) {
// 	s := parse_pystring("(${2}$ - ${0}$ + ${1}$)", {"10", "20", "30"})
// 	testing.expect_value(t, s, "(30 - 10 + 20)")

// 	s = parse_pystring("{${2}$ - ${0}$ + ${1}$}", {"10", "20", "30"})
// 	testing.expect_value(t, s, "{30 - 10 + 20}")

// 	s = parse_pystring("${0}$ ${1}$", {"hello", "world"})
// 	testing.expect_value(t, s, "hello world")
// }


// @(test)
// test_parse_file_macros :: proc(t: ^testing.T) {
// 	gen_arena: vmem.Arena
// 	defer vmem.arena_destroy(&gen_arena)
// 	context.allocator = vmem.arena_allocator(&gen_arena)
// 	context.temp_allocator = vmem.arena_allocator(&gen_arena)

// 	s: Gen_State = {
// 		source = "#define FIVE 5",
// 	}
// 	macros := parse_file_macros(&s)
// 	expected := []string{"FIVE"}

// 	for e in expected {
// 		testing.expect(t, e in macros)
// 	}

// 	s = {
// 		source = "#define FIVE 5\n#define TEN 10\n#define TWENTY 20",
// 	}
// 	macros = parse_file_macros(&s)
// 	expected = []string{"FIVE", "TEN", "TWENTY"}
// 	for e in expected {
// 		testing.expect(t, e in macros)
// 	}

// 	s = {
// 		source = "#define ADD(x, y) (x + y)\n#define SUB(x, y) (x - y)\n",
// 	}
// 	macros = parse_file_macros(&s)
// 	expected = []string{"ADD", "SUB"}
// 	for e in expected {
// 		testing.expect(t, e in macros)
// 	}
// }


// @(test)
// test_parse_clang_macros :: proc(t: ^testing.T) {
// 	gen_arena: vmem.Arena
// 	defer vmem.arena_destroy(&gen_arena)
// 	context.allocator = vmem.arena_allocator(&gen_arena)
// 	context.temp_allocator = vmem.arena_allocator(&gen_arena)

// 	s: Gen_State = {}
// 	macros_map := parse_clang_macros(&s, "test/test.h")
// 	macro_tokens := []Macro_Token {
// 		{type = .Function, name = "SUB", values = {"(float) (${0}$) - (float)(${1}$)"}},
// 		{type = .Function, name = "NEST", values = {"NEST1(${0}$)"}},
// 		{type = .Function, name = "NEST1", values = {"NEST2(${0}$)"}},
// 		{type = .Function, name = "NEST2", values = {"(${0}$)"}},
// 		{type = .Constant_Expression, name = "ARRAY", values = {"{1}"}},
// 		{type = .Function, name = "FUNC", values = {"(${0}$ + ${1}$ + ${2}$)"}},
// 		{type = .Multivalue, name = "FUNC_TEST", values = {"1", "2", "3"}},
// 		{type = .Constant_Expression, name = "FUNC_TEST_RESULT", values = {"FUNC(FUNC_TEST)"}},
// 		{type = .Constant_Expression, name = "FALSE", values = {"!", "true"}},
// 		{type = .Constant_Expression, name = "TRUE", values = {"!false"}},
// 		{type = .Multivalue, name = "MULT_VAL", values = {"10", "20", "30"}},
// 		{type = .Constant_Expression, name = "ARRAY_TEST", values = {"{FUNC_TEST}"}},
// 		{type = .Constant_Expression, name = "NO_INDEX", values = {"(uint32_t)0"}},
// 		{type = .Constant_Expression, name = "VALUE", values = {"20010"}},
// 		{type = .Constant_Expression, name = "VALUE_STRING", values = {"#VALUE"}},
// 		{type = .Constant_Expression, name = "CINDEX_VERSION_MAJOR", values = {"0"}},
// 		{type = .Constant_Expression, name = "CINDEX_VERSION_MINOR", values = {"64"}},
// 		{
// 			type = .Constant_Expression,
// 			name = "CINDEX_VERSION_STRING",
// 			values = {"#CINDEX_VERSION_MAJOR", "\".\"", "#CINDEX_VERSION_MINOR"},
// 		},
// 	}
// 	for &macro_token in macro_tokens {
// 		macro, found := macros_map[macro_token.name]
// 		testing.expect_value(t, found, true)
// 		testing.expect_value(t, macro.name, macro_token.name)
// 		testing.expect_value(t, macro.type, macro_token.type)
// 		compare_arrays(macro.values, macro_token.values, t)
// 	}
// }


// @(test)
// test_parse_macros :: proc(t: ^testing.T) {
// 	gen_arena: vmem.Arena
// 	defer vmem.arena_destroy(&gen_arena)
// 	context.allocator = vmem.arena_allocator(&gen_arena)
// 	context.temp_allocator = vmem.arena_allocator(&gen_arena)

// 	// Why ../ here and not in test_parse_clang_macros? IDK but I tested them both and that's how it is.
// 	data, err := os2.read_entire_file("../test/test.h", context.allocator)
// 	if err != nil {
// 		fmt.print("Error reading file: %s\n", err)
// 		return
// 	}

// 	s := Gen_State {
// 		source = string(data),
// 	}
// 	parse_macros(&s, "../test/test.h")

// 	expected_macros := map[string]string {
// 		"ARRAY"                 = "{1}",
// 		"FIVE_SUB_TWO"          = "(float) (5) - (float)(2)",
// 		"UNNEST"                = "(\"Test\")",
// 		"LIGHTGRAY"             = "(Color){ 200, 200, 200, 255 }",
// 		"FUNC_TEST_RESULT"      = "(1 + 2 + 3)",
// 		"FALSE"                 = "! true",
// 		"TRUE"                  = "!false",
// 		"ARRAY_TEST"            = "{1, 2, 3}",
// 		"UFBX_HEADER_VERSION"   = "((uint32_t)(0)*1000000u + (uint32_t)(18)*1000u + (uint32_t)(0))",
// 		"NO_INDEX"              = "(uint32_t)0",
// 		"VALUE"                 = "20010",
// 		"VALUE_STRING"          = "#20010", // TODO: This needs to become \"20010\"
// 		"CINDEX_VERSION_MAJOR"  = "0",
// 		"CINDEX_VERSION_MINOR"  = "64",
// 		"CINDEX_VERSION_STRING" = "#CINDEX_VERSION_MAJOR \".\" #CINDEX_VERSION_MINOR", // TODO: This needs to become \"0.64\"
// 	}
// 	testing.expect_value(t, len(s.defines), len(expected_macros))
// 	for name, expected_value in expected_macros {
// 		value, found := s.defines[name]
// 		testing.expect_value(t, found, true)
// 		testing.expect_value(t, value, expected_value)
// 	}
// }
