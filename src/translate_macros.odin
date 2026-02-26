// This file takes the macro information collected by `translate_collect.odin` and evaluates the
// macros. This way we can turn `#define` constants into Odin constants.
//
// Thought: Could we use a Declaration with some Raw_Macro type and just fix this in
// translate_process?
#+private file
package bindgen2

import "core:strings"
import "core:fmt"
import "core:log"
import "core:strconv"

_ :: log

// "Raw" as in not evaluated yet.
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

// Takes the Raw_Macros and turns them into declarations, often constants.
@(private="package")
translate_macros :: proc(macros: []Raw_Macro, decls: Decl_List, types: Type_List, config: Config) {
	// Create lookup / acceleration structures.
	existing_declaration_names: map[string]int

	for d, i in decls {
		existing_declaration_names[d.name] = i
	}

	macro_lookup: map[string]int

	for m, i in macros {
		macro_lookup[m.name] = i
	}
	
	macro_prefix_to_enum_decl: map[string]int
	// Add empty enum defs for macro enumification
	for prefix, enum_name in config.enumify_macros {
		type_idx := add_type(types, Type_Enum {
			storage_type = int,
		})
		macro_prefix_to_enum_decl[prefix] = len(decls)
		add_decl(decls, {
			name = enum_name,
			def = type_idx,
			invalid = true, // We will set this to false later if we find a valid macro
			explicitly_created = true,
		})
	}

	macro_loop: for &m, i in macros {
		// Function-like macros are only used when figuring out a value of a non-function like macro.
		// They will not have a value "of their own".
		if m.is_function_like {
			continue
		}

		for prefix, decl_idx in macro_prefix_to_enum_decl {
			if strings.has_prefix(m.name, prefix) {
				int_value, ok := parse_tokens_to_int(m.tokens, macros, macro_lookup)
				if ok {
					d := &decls[decl_idx]
					if d.invalid {
						d.original_line = m.original_line
						d.invalid = false
					}
					append(
						&(&types[d.def.(Type_Index)].(Type_Enum)).members,
						Type_Enum_Member {
							name = m.name,
							value = int_value,
							comment_before = m.comment,
							comment_on_right = m.side_comment,
						},
					)
					continue macro_loop
				}
			}
		}

		odin_value := evaluate_macro(macros, macro_lookup, existing_declaration_names, i, {}, config)

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

evaluate_macro :: proc(macros: []Raw_Macro, macro_lookup: map[string]Macro_Index, existing_declarations: map[string]int, mi: Macro_Index, args: []string, config: Config) -> string {
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

			case "~":
				if ems.cur_token + 1 < len(ems.tokens) {
					n1 := ems.tokens[ems.cur_token + 1]

					if n1.kind == .Literal {
						notted = true
						break
					}

					if n1.kind == .Punctuation && n1.value == "(" &&
					ems.cur_token + 3 < len(ems.tokens) {
						n2 := ems.tokens[ems.cur_token + 2]
						n3 := ems.tokens[ems.cur_token + 3]
						if n2.kind == .Literal && n3.kind == .Punctuation && n3.value == ")" {
							notted = true
							break
						}
					}
				}

				p(&b, tv)

			case:
				p(&b, tv)
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

			if parse_identifier(&ems, &b, config) == false {
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
		case .None: return ""
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

parse_identifier :: proc(ems: ^Evalulate_Macro_State, b: ^strings.Builder, config: Config) -> bool {
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
		if new_name, exists := config.rename[tv]; exists {
			p(b, new_name)
		} else {
			p(b, tv)
		}
		return true
	}

	if inner_macro_idx, inner_macro_exists := ems.macro_lookup[tv]; inner_macro_exists {
		inner_macro := ems.macros[inner_macro_idx]

		args: []string

		if inner_macro.is_function_like {
			// Only treat as a call if the next token is '('
			if ems.cur_token + 1 >= len(ems.tokens) ||
			ems.tokens[ems.cur_token + 1].kind != .Punctuation ||
			ems.tokens[ems.cur_token + 1].value != "(" {
				p(b, tv)
				return true
			}
			
			adv(ems)
			args = parse_parameter_list(ems)
		}

		inner := evaluate_macro(ems.macros, ems.macro_lookup, ems.existing_declarations, inner_macro_idx, args, config)

		if inner == "" {
			return false
		}

		p(b, inner)
		return true
	}

	return false
}

// Evaluates an equation to an int
parse_tokens_to_int :: proc(toks: []Raw_Macro_Token, macros: []Raw_Macro, macro_lookup: map[string]int) -> (int, bool) {
	if l := len(toks); l == 0 {
		return 0, false
	} else if l == 1 {
		return strconv.parse_int(toks[0].value)
	}
	
	operator_precedence :: proc(op: Operator) -> int {
		switch op {
		case .Or:
			return 0
		case .Xor:
			return 1
		case .And:
			return 2
		case .LShift, .RShift:
			return 3
		case .Sub, .Add:
			return 4
		case .Mul, .Div, .Mod:
			return 5
		case .Not:
			return 6
		}
		panic("Unrechable!")
	}

	Operator :: enum {
		Or,
		Xor,
		And,
		Not,
		LShift,
		RShift,
		Sub,
		Add,
		Mul,
		Div,
		Mod,
		// Inc, // I don't think well need these
		// Dec,
	}

	Stack_Op :: struct {
		op: Operator,
		prec: int,
	}

	Stack_Element :: union {
		Stack_Op,
		int,
	}

	Equation :: struct {
		op_stack: [dynamic]Stack_Op,
		eq_stack: [dynamic]Stack_Element,
		prec_mod: int,
	}

	// Reconstruct equation in reverse polish notation
	// https://en.wikipedia.org/wiki/Shunting_yard_algorithm
	eq: Equation
	for idx := 0; idx < len(toks); idx += 1 {
		tok := &toks[idx]
		switch tok.kind {
		case .Literal:
			val, ok := strconv.parse_int(tok.value)
			if !ok {
				return 0, false
			}
			append(&eq.eq_stack, val)
		case .Identifier:
			macro_idx, is_macro := macro_lookup[tok.value]
			if !is_macro {
				return 0, false
			}
			val, ok := parse_tokens_to_int(macros[macro_idx].tokens, macros, macro_lookup)
			if !ok {
				return 0, false
			}
			append(&eq.eq_stack, val)
		case .Punctuation:
			if tok.value == "(" {
				eq.prec_mod += len(Operator)
				continue
			} else if tok.value == ")" {
				eq.prec_mod -= len(Operator)
				if eq.prec_mod < 0 {
					// Too many ')'s
					return 0, false
				}
				continue
			}

			op: Operator
			switch tok.value {
			case "|":  op = .Or
			case "^":  op = .Xor
			case "&":  op = .Add
			case "~":  op = .Not
			case "<<": op = .LShift
			case ">>": op = .RShift
			case "-":  op = .Sub
			case "+":  op = .Add
			case "*":  op = .Mul
			case "/":  op = .Div
			case "%":  op = .Mod
			case: return 0, false
			}

			prec := operator_precedence(op) + eq.prec_mod
			for len(eq.op_stack) != 0 {
				top_op := eq.op_stack[len(eq.op_stack) - 1]
				if prec <= top_op.prec {
					append(&eq.eq_stack, pop(&eq.op_stack))
					continue
				}
				break
			}

			append(&eq.op_stack, Stack_Op {
				op = op,
				prec = prec
			})
		case .Keyword:
			return 0, false
		}
	}
	
	if eq.prec_mod != 0 {
		// Means we didn't have a balanced number of parens
		return 0, false
	}

	for len(eq.op_stack) > 0 {
		append(&eq.eq_stack, pop(&eq.op_stack))
	}

	literals_stack: [dynamic]int
	for element in eq.eq_stack {
		switch _ in element {
		case int:
			append(&literals_stack, element.(int))
		case Stack_Op:
			// Remove the precidence modifier and cast into an operator
			op := element.(Stack_Op).op
			if op == .Not {
				if len(literals_stack) == 0 {
					return 0, false
				}

				append(&literals_stack, ~pop(&literals_stack))
				continue
			}
			
			if len(literals_stack) < 2 {
				return 0, false
			}
			
			rhs := pop(&literals_stack)
			lhs := pop(&literals_stack)

			// Shift by negative is undefined.
			// Im going to invert the op but maybe this should probably just be illegal.
			if (op == .LShift || op == .RShift) && rhs < 0 {
				rhs *= -1
				op = op == .LShift ? .RShift : .LShift
			}

			val: int
			#partial switch op {
			case .Or:     val = lhs | rhs
			case .Xor:    val = lhs ~ rhs
			case .And:    val = lhs & rhs
			case .LShift: val = lhs << uint(rhs)
			case .RShift: val = lhs >> uint(rhs)
			case .Sub:    val = lhs - rhs
			case .Add:    val = lhs + rhs
			case .Mul:    val = lhs * rhs
			case .Div:    val = lhs / rhs
			case .Mod:    val = lhs % rhs
			}
			append(&literals_stack, val)
		}
	}

	return pop(&literals_stack), len(literals_stack) == 0
}

