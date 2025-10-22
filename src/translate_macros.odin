#+private file
package bindgen2

import "core:strings"
import "core:fmt"
import "core:log"

_ :: log

// TODO could we use a Declaration with some Raw_Macro type and just fix this in translate_process?
@(private="package")
Raw_Macro :: struct {
	name: string,
	tokens: []Raw_Macro_Token,
	is_function_like: bool,
	comment: string,
	side_comment: string,
	whitespace_before_side_comment: int,
	whitespace_after_name: int,
	original_line: int,
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
translate_macros :: proc(macros: []Raw_Macro, decls: Decl_List) {
	existing_declaration_names: map[string]int

	for d, i in decls {
		existing_declaration_names[d.name] = i
	}

	macro_lookup: map[string]int

	for m, i in macros {
		macro_lookup[m.name] = i
	}

	for m, i in macros {
		// Function-like macros are only used when figuring out a value of a non-function like macro.
		// They will not have a value "of their own".
		if m.is_function_like {
			continue
		}

		odin_value := evaluate_macro(macros, macro_lookup, existing_declaration_names, i, {})

		if odin_value != "" && odin_value[0] != '{' {
			def: Definition
			if decl_idx, decl_exists := existing_declaration_names[odin_value]; decl_exists {
				// We want the value of this macro to change if there is some trimming set in the config etc.

				if decls[decl_idx].from_macro {
					def = Macro_Name(odin_value)
				} else {
					def = Type_Name(odin_value)
				}
			} else {
				def = Fixed_Value(odin_value)
			}

			add_decl(decls, {
				name = m.name,
				def = def,
				comment_before = m.comment,
				side_comment = m.side_comment,
				explicit_whitespace_before_side_comment = m.whitespace_before_side_comment,
				explicit_whitespace_after_name = m.whitespace_after_name,
				original_line = m.original_line,
				from_macro = true,
			})

			existing_declaration_names[m.name] = len(decls) - 1
		}
	}
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
	existing_declarations: map[string]int,
}

cur :: proc(ems: Evalulate_Macro_State) -> Raw_Macro_Token {
	return ems.tokens[ems.cur_token]
}

adv :: proc(ems: ^Evalulate_Macro_State) {
	ems.cur_token += 1
}

evaluate_macro :: proc(macros: []Raw_Macro, macro_lookup: map[string]Macro_Index, existing_declarations: map[string]int, mi: Macro_Index, args: []string) -> string {
	ems := Evalulate_Macro_State {
		cur_token = 0,
		tokens = macros[mi].tokens,
		cur_macro = macros[mi],
		cur_macro_index = mi,
		macros = macros,
		macro_lookup = macro_lookup,
		existing_declarations = existing_declarations,
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
	literal_type: Literal_Type_Info
	notted: bool

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

			case "~":
				notted = true
			}
		case .Keyword:
			return ""
		case .Identifier:
			if tv == "UINT64_MAX" {
				notted = true
				literal_type = .U64
				break
			}

			if tv == "UINT32_MAX" {
				notted = true
				literal_type = .U32
				break
			}

			if tv == "INT32_MAX" {
				notted = true
				literal_type = .I32
				break
			}

			if tv == "INT64_MAX" {
				notted = true
				literal_type = .I64
				break
			}

			if parse_identifier(&ems, &b) == false {
				mapped, has_mapping := c_type_mapping[tv]

				if has_mapping {
					p(&b, mapped)
				} else {
					return ""
				}
			}
		case .Literal:
			if type, ok := parse_literal(&b, tv); ok == false {
				return ""
			} else {
				literal_type = type
			}
		}

		adv(&ems)
	}

	if notted {
		switch literal_type {
		case .None:
		case .U32: return "max(u32)"
		case .I32: return "max(i32)"
		case .U64: return "max(u64)"
		case .I64: return "max(i64)"
		}

		log.errorf("Unknown type: %v", ems.tokens)
	}

	return strings.to_string(b)
}

p :: fmt.sbprint
pf :: fmt.sbprintf

Literal_Type_Info :: enum {
	None,
	U32,
	I32,
	U64,
	I64,
}

parse_literal :: proc(b: ^strings.Builder, val: string) -> (Literal_Type_Info, bool) {
	if len(val) == 0 {
		return {}, false
	}

	if val[0] >= '0' && val[0] <= '9' {
		if len(val) == 1 {
			p(b, val)
			return {}, true
		}

		val_start := 0
		hex := false

		if val[1] == 'x' || val[1] == 'X' {
			p(b, '0')
			p(b, 'x')
			hex = true
			val_start = 2
		}

		end := len(val) - 1

		l: int
		u: int

		// remove suffix chars such as ULL and f
		LOOP: for ; end > 0; end -= 1 {
			switch val[end] {
			case 'L', 'l':
				l += 1
				continue LOOP

			case 'U', 'u':
				u += 1
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

		ti: Literal_Type_Info

		if l == 1 && u == 0 {
			ti = .I32
		}

		if l == 0 && u == 1 || l == 1 && u == 1 {
			ti = .U32
		}

		if l == 2 && u == 0 {
			ti = .I64
		}

		if l == 2 && u == 1 {
			ti = .U64
		}

		p(b, val[val_start:end + 1])
		return ti, true
	} else if val[0] == '"' {
		p(b, val)
		return {}, true
	}
	return {}, false
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
			p(&arg_builder, t.value)

		case .Literal:
			p(&arg_builder, t.value)
		}

		adv(ems)
	}

	return args[:]
}

parse_identifier :: proc(ems: ^Evalulate_Macro_State, b: ^strings.Builder) -> bool {
	t := cur(ems^)
	assert(t.kind == .Identifier)

	tv := t.value

	// We are inside a function-like macro and this identifier is one of the parameter names:
	// Replace the identifier with the argument!
	if parameter_replacement, has_parameter_replacement := ems.params[tv]; has_parameter_replacement {
		p(b, parameter_replacement)
		return true
	}

	if tv in ems.existing_declarations {
		p(b, tv)
		return true
	}

	if inner_macro_idx, inner_macro_exists := ems.macro_lookup[tv]; inner_macro_exists {
		inner_macro := ems.macros[inner_macro_idx]

		args: []string

		if inner_macro.is_function_like {
			adv(ems)
			args = parse_parameter_list(ems)
		}

		inner := evaluate_macro(ems.macros, ems.macro_lookup, ems.existing_declarations, inner_macro_idx, args)

		if inner == "" {
			return false
		}

		p(b, inner)
		return true
	}

	return false
}