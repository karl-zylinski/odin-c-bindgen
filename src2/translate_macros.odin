#+private file
package bindgen2

import "core:log"
import "core:strings"
import "core:unicode"
import "core:fmt"

@(private="package")
Raw_Macro :: struct {
	name: string,
	tokens: []Raw_Macro_Token,
	is_function_like: bool,
}

@(private="package")
Raw_Macro_Token :: struct {
	value: string,
	kind: Raw_Macro_Token_Kind,
}

// Same as Token_Kind in clang, but without 'Comment'
@(private="package")
Raw_Macro_Token_Kind :: enum {
	Punctuation,
	Keyword,
	Identifier,
	Literal,
}

@(private="package")
translate_macros :: proc(macros: []Raw_Macro) -> []Declaration {
	tms := Translate_Macros_State {
		macros = macros,
	//	macro_evaluated = make([]bool, len(macros)),
	}

	for m, i in macros {
		tms.macro_lookup[m.name] = i
	}

	macro_decls: [dynamic]Declaration

	for m, i in macros {
		// Function-like macros are only used when figuring out a value of a non-function like macro.
		// They will not have a value "of their own".
		if m.is_function_like {
			continue
		}

		odin_value := evaluate_macro(&tms, i)

		if odin_value != "" {
			append(&macro_decls, Declaration {
				name = m.name,
				def = odin_value,
			})
		}
	}

	return macro_decls[:]
}

evaluate_macro :: proc(tms: ^Translate_Macros_State, mi: Macro_Index) -> string {
	return evaluate_nonfn_macro(tms, mi)
}

p :: fmt.sbprint
pf :: fmt.sbprintf

parse_literal :: proc(b: ^strings.Builder, val: string) -> bool {
	if len(val) == 0 {
		return false
	}

	if val[0] >= '0' && val[0] <= '9' {
		if len(val) == 1 {
			p(b, val)
			return true
		}

		loop_start := 0
		hex := false

		if val[1] == 'x' || val[1] == 'X' {
			p(b, 'x')
			hex = true
			loop_start = 2
		}

		end := len(val) - 1

		// remove suffix chars such as ULL and f
		LOOP: for ; end > 0; end -= 1 {
			switch val[end] {
			case 'L', 'l', 'U', 'u':
				// These are suffixes for long and unsigned literals.
				continue LOOP
			case 'F', 'f':
				if hex {
					break LOOP
				}
				// Floating point literals can have 'F' or 'f' suffixes.
				continue LOOP
			case:
				// Not a suffix char.
				break LOOP
			}
		}

		p(b, val[:end + 1])
		return true
	} else if val[0] == '"' {
		p(b, val)
		return true
	}
	return false
}

parse_identifier :: proc(tms: ^Translate_Macros_State, b: ^strings.Builder, val: string) -> bool {
	if inner_macro, inner_macro_exists := tms.macro_lookup[val]; inner_macro_exists {
		inner := evaluate_macro(tms, inner_macro)

		if inner == "" {
			return false
		}

		p(b, inner)
		return true
	}

	p(b, val)
	return true
}

evaluate_nonfn_macro :: proc(tms: ^Translate_Macros_State, mi: Macro_Index) -> string {
	m := &tms.macros[mi]
	curly_braces: int

	b := strings.builder_make()

	for t in m.tokens {
		tv := t.value
		switch t.kind {
		case .Punctuation:
			switch tv {
			case "#":
				return ""

			case "{":
				curly_braces += 1
				p(&b, tv)

			case "}":
				curly_braces -= 1
				p(&b, tv)

			case ",":
				if curly_braces == 0 {
					return ""
				}

				p(&b, tv)
				p(&b, ' ')

			case "(", ")", "-", "*", "/", "+":
				p(&b, tv)
			}
		case .Keyword:
			p(&b, tv)
		case .Identifier:
			if parse_identifier(tms, &b, tv) == false {
				return ""
			}
		case .Literal:
			if parse_literal(&b, tv) == false {
				return ""
			}
		}
	}

	return strings.to_string(b)
}

Macro_Index :: int

Translate_Macros_State :: struct {
	macros: []Raw_Macro,
	macro_lookup: map[string]Macro_Index,
}