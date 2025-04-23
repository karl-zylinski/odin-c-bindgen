#+feature dynamic-literals


package bindgen


import "core:testing"
import "core:os/os2"
import "core:fmt"


// I've gone through and tried to make sure non of these tests leak but in theory even if they do it shouldn't be a problem since we use all these functions with a memory arena that is cleaned up at the end of each file.


// These are just some simple tests that I wrote while working on the macro parser. They are not exhaustive, but they do cover some of the basic functionality.
// Feel free to add more tests as you see fit. I haven't added any test cases for malformed macros but it's not our problem to deal with bad c code.
@(test)
test_parse_macro :: proc(t: ^testing.T) {

    macro_token: Macro_Token
    macro_token = parse_macro("VALUELESS_MACRO")
	testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Valueless, name = "VALUELESS_MACRO", value = ""},
	)

	macro_token = parse_macro("CONSTANT 5")
	testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Constant, name = "CONSTANT", value = "5"},
	)

	macro_token = parse_macro("CONSTANT 01")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Constant, name = "CONSTANT", value = "01"},
	)

	macro_token = parse_macro("CONSTANT 0b0001")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Constant, name = "CONSTANT", value = "0b0001"},
	)

	macro_token = parse_macro("CONSTANT 0x0001")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Constant, name = "CONSTANT", value = "0x0001"},
	)

	macro_token = parse_macro("CONSTANT \"String\"")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Constant, name = "CONSTANT", value = "\"String\""},
	)

	macro_token = parse_macro("FUNCTION(x) (x)")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Function, name = "FUNCTION", value = "(${0}$)"},
	)
    delete(macro_token.value)

	macro_token = parse_macro("FUNCTION(x, y) (x + y)")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Function, name = "FUNCTION", value = "(${0}$ + ${1}$)"},
	)
    delete(macro_token.value)

	macro_token = parse_macro("FUNCTION(x, y, z) (z - x + y)")
    testing.expect_value(
		t,
		macro_token,
		Macro_Token{type = .Function, name = "FUNCTION", value = "(${2}$ - ${0}$ + ${1}$)"},
	)
    delete(macro_token.value)
}


@(test)
test_parse_pystring :: proc(t: ^testing.T) {
    s := parse_pystring("(${2}$ - ${0}$ + ${1}$)", {"10", "20", "30"})
    testing.expect_value(
        t,
        s,
        "(30 - 10 + 20)",
    )

    s = parse_pystring("{${2}$ - ${0}$ + ${1}$}", {"10", "20", "30"})
    testing.expect_value(
        t,
        s,
        "{30 - 10 + 20}",
    )

    s = parse_pystring("${0}$ ${1}$", {"hello", "world"})
    testing.expect_value(
        t,
        s,
        "hello world",
    )
}


@(test)
test_parse_file_macros :: proc(t: ^testing.T) {
    s: Gen_State = {
        source = "#define FIVE 5",
    }
    macros := parse_file_macros(&s)
    expected := []string {
        "FIVE", 
    }

    for macro, i in macros {
        testing.expect_value(
            t,
            macro,
            expected[i],
        )
    }
    delete(macros)

    s = {
        source = "#define FIVE 5\n#define TEN 10\n#define TWENTY 20",
    }
    macros = parse_file_macros(&s)
    expected = []string {
        "FIVE",
        "TEN",
        "TWENTY",
    }
    for macro, i in macros {
        testing.expect_value(
            t,
            macro,
            expected[i],
        )
    }
    delete(macros)

    s = {
        source = "#define ADD(x, y) (x + y)\n#define SUB(x, y) (x - y)\n",
    }
    macros = parse_file_macros(&s)
    expected = []string {
        "ADD",
        "SUB",
    }
    for macro, i in macros {
        testing.expect_value(
            t,
            macro,
            expected[i],
        )
    }
    delete(macros)
}


@(test)
test_parse_clang_macros :: proc(t: ^testing.T) {
    s: Gen_State = {}
    macros_map := parse_clang_macros(&s, ".\\test\\test.h")
    macro_tokens := []Macro_Token {
        {
            type = .Function,
            name = "SUB",
            value = "(float)(${0}$) - (float)(${1}$)",
        },
        {
            type = .Function,
            name = "NEST",
            value = "NEST1(${0}$)",
        },
        {
            type = .Function,
            name = "NEST1",
            value = "NEST2(${0}$)",
        },
        {
            type = .Function,
            name = "NEST2",
            value = "(${0}$)",
        },
        {
            type = .Constant,
            name = "ARRAY",
            value = "{1}",
        },
    }
    for &macro_token in macro_tokens {
        macro, found := macros_map[macro_token.name]
        testing.expect_value(
            t,
            found,
            true,
        )
        testing.expect_value(
            t,
            macro,
            macro_token,
        )

        if macro.type == .Function {
            delete(macro.value)
        }
    }
    delete(macros_map)
}


@(test)
test_parse_macros :: proc(t: ^testing.T) {
    data, err := os2.read_entire_file("test/test.h", context.allocator)
    if err != nil {
        fmt.print("Error reading file: %s\n", err)
        return
    }
    defer delete(data)

    s := Gen_State {
        source = string(data),
    }
    parse_macros(&s, "test/test.h")

    expected_macros := map[string]string {
        "ARRAY" = "{1}",
        "FIVE_SUB_TWO" = "(float)(5) - (float)(2)",
        "UNNEST" = "(\"Test\")",
    }
    defer delete(expected_macros)
    testing.expect_value(
        t,
        len(s.defines),
        len(expected_macros),
    )
    for name, expected_value in expected_macros {
        value, found := s.defines[name]
        testing.expect_value(
            t,
            found,
            true,
        )
        testing.expect_value(
            t,
            value,
            expected_value,
        )
    }
    delete(s.defines)
}
