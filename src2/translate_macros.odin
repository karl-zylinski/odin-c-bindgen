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
	macro_lookup: map[string]int

	for m, i in macros {
		macro_lookup[m.name] = i
	}

	macro_decls: [dynamic]Declaration

	for m, i in macros {
		// Function-like macros are only used when figuring out a value of a non-function like macro.
		// They will not have a value "of their own".
		if m.is_function_like {
			continue
		}

		odin_value := evaluate_macro(macros, macro_lookup, i, {})

		if odin_value != "" {
			append(&macro_decls, Declaration {
				name = m.name,
				def = odin_value,
			})
		}
	}

	return macro_decls[:]
}

Macro_Index :: int

Evalulate_Macro_State :: struct {
	cur_token: int,
	tokens: []Raw_Macro_Token,
	cur_macro: Raw_Macro,
	cur_macro_index: Macro_Index,
	macros: []Raw_Macro,
	macro_lookup: map[string]Macro_Index,
	params: map[string]string,
}

cur :: proc(ems: Evalulate_Macro_State) -> Raw_Macro_Token {
	return ems.tokens[ems.cur_token]
}

adv :: proc(ems: ^Evalulate_Macro_State) {
	ems.cur_token += 1
}

evaluate_macro :: proc(macros: []Raw_Macro, macro_lookup: map[string]Macro_Index, mi: Macro_Index, args: []string) -> string {
	ems := Evalulate_Macro_State {
		cur_token = 0,
		tokens = macros[mi].tokens,
		cur_macro = macros[mi],
		cur_macro_index = mi,
		macros = macros,
		macro_lookup = macro_lookup,
	}

	if ems.cur_macro.is_function_like {
		params := parse_parameter_list(&ems)
		adv(&ems)

		if len(params) != len(args) {
			return ""
		}

		for a, i in args {
			ems.params[params[i]] = a
		}
	}

	curly_braces: int

	b := strings.builder_make()

	for ems.cur_token < len(ems.tokens) {
		t := cur(ems)
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
			if parse_identifier(&ems, &b) == false {
				return ""
			}
		case .Literal:
			if parse_literal(&b, tv) == false {
				return ""
			}
		}

		adv(&ems)
	}

	return strings.to_string(b)
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

parse_parameter_list :: proc(ems: ^Evalulate_Macro_State) -> []string {
	t := cur(ems^)

	if t.kind != .Punctuation || t.value != "(" {
		return {}
	}

	paren_count := 1

	adv(ems)

	arg_builder := strings.builder_make()
	args: [dynamic]string

	args_loop: for ems.cur_token < len(ems.tokens) {
		t = cur(ems^)

		#partial switch t.kind {
		case .Punctuation:
			switch t.value {
			case "(":
				paren_count += 1

			case ")":
				paren_count -= 1

				if paren_count == 0 {
					append(&args, strings.to_string(arg_builder))
					arg_builder = strings.builder_make()
					break args_loop
				}

			case ",":
				append(&args, strings.to_string(arg_builder))
				arg_builder = strings.builder_make()
			}
		case .Identifier:
			parse_identifier(ems, &arg_builder)
		}

		adv(ems)
	}

	return args[:]
}

parse_identifier :: proc(ems: ^Evalulate_Macro_State, b: ^strings.Builder) -> bool {
	t := cur(ems^)
	assert(t.kind == .Identifier)

	tv := t.value

	if inner_macro_idx, inner_macro_exists := ems.macro_lookup[tv]; inner_macro_exists {
		inner_macro := ems.macros[inner_macro_idx]

		args: []string

		if inner_macro.is_function_like {
			adv(ems)
			args = parse_parameter_list(ems)
		}

		inner := evaluate_macro(ems.macros, ems.macro_lookup, inner_macro_idx, args)

		if inner == "" {
			return false
		}

		p(b, inner)
		return true
	}

	// We are inside a function-like macro and this identifier is one of the parameter names:
	// Replace the identifier with the argument!
	if parameter_replacement, has_parameter_replacement := ems.params[tv]; has_parameter_replacement {
		p(b, parameter_replacement)
		return true
	}

	p(b, tv)
	return true
}