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
	_foreign: bool,
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
		if m.is_function_like || m._foreign {
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

		odin_value, needs_var_decl := evaluate_macro(macros, macro_lookup, existing_declaration_names, decls, types, i, {}, config)

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
				is_runtime_value = needs_var_decl,
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
	decls: Decl_List,
	types: Type_List,

	// Set to true if this macro's value had to `transmute` an integer literal into a
	// pointer/proc-typed declaration (see `is_c_style_cast`/`is_pointer_like_type`). Such values
	// can't be Odin `::` constants and must be emitted as `:=` variables instead.
	needs_var_decl: bool,
}

// Resolves whether `name` refers to a declaration whose Odin type is pointer/proc-like (i.e. not
// safely `cast`-able from an integer literal in a constant expression; needs `transmute` instead).
// Walks through `Type_Alias` indirections, since a typedef-of-a-typedef would otherwise look like
// neither a pointer nor a concrete numeric type.
is_pointer_like_type :: proc(decls: Decl_List, types: Type_List, existing_declarations: map[string]int, name: string) -> bool {
	decl_idx, ok := existing_declarations[name]
	if !ok {
		return false
	}

	def := decls[decl_idx].def
	type_idx, is_type_idx := def.(Type_Index)

	for depth := 0; is_type_idx && depth < 8; depth += 1 {
		#partial switch t in types[type_idx] {
		case Type_Procedure, Type_Pointer, Type_Multipointer, Type_Pointer_By_Ptr,
		     Type_Raw_Pointer, Type_CString:
			return true
		case Type_Alias:
			type_idx, is_type_idx = t.aliased_type.(Type_Index)
			continue
		}
		break
	}

	return false
}

cur :: proc(ems: Evalulate_Macro_State) -> Raw_Macro_Token {
	return ems.tokens[ems.cur_token]
}

adv :: proc(ems: ^Evalulate_Macro_State) {
	ems.cur_token += 1
}

// Detects a C-style cast at the current token: "(" Identifier ")" <value>,
// e.g. `(sqlite3_destructor_type)0` or `(MyType)-1`. `cur_token` must be on
// the opening "(". C only allows a bare parenthesized type name (as opposed
// to a parenthesized value expression) in a cast, so requiring the
// identifier to resolve to an already-known declaration (a typedef/struct/
// proc name, per `existing_declarations`) and to be immediately followed by
// the start of a new operand (not an operator/comma/close-paren) is enough
// to distinguish this from a plain parenthesized expression.
is_c_style_cast :: proc(ems: Evalulate_Macro_State) -> bool {
	i := ems.cur_token
	if i + 3 >= len(ems.tokens) {
		return false
	}

	id_tok := ems.tokens[i + 1]
	close_tok := ems.tokens[i + 2]
	next_tok := ems.tokens[i + 3]

	if id_tok.kind != .Identifier || id_tok.value not_in ems.existing_declarations {
		return false
	}

	if close_tok.kind != .Punctuation || close_tok.value != ")" {
		return false
	}

	#partial switch next_tok.kind {
	case .Literal, .Identifier:
		return true
	case .Punctuation:
		switch next_tok.value {
		case "-", "+", "~", "!", "(":
			return true
		}
	}

	return false
}

evaluate_macro :: proc(macros: []Raw_Macro, macro_lookup: map[string]Macro_Index, existing_declarations: map[string]int, decls: Decl_List, types: Type_List, mi: Macro_Index, args: []string, config: Config) -> (string, bool) {
	ems := Evalulate_Macro_State {
		cur_token = 0,
		tokens = macros[mi].tokens,
		cur_macro = macros[mi],
		cur_macro_index = mi,
		macros = macros,
		macro_lookup = macro_lookup,
		existing_declarations = existing_declarations,
		decls = decls,
		types = types,
	}

	if ems.cur_macro.is_function_like {
		params := parse_parameter_list(&ems)
		adv(&ems)

		if len(params) != len(args) {
			return "", false
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
				return "", false

			case "{":
				curly_braces += 1
				p(&b, tv)
				

			case "}":
				curly_braces -= 1
				p(&b, tv)

			case ",":
				if curly_braces == 0 {
					return "", false
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

			case "(":
				if is_c_style_cast(ems) {
					// Rewrite C's `(Type)value` cast syntax. For ordinary (numeric/alias) types
					// Odin's `cast(Type)value` is equivalent. But an integer literal cast to a
					// pointer/proc type (e.g. sqlite3.h's `((sqlite3_destructor_type)0)` sentinel
					// idiom) needs `transmute` instead -- Odin's `cast` refuses int->pointer
					// conversions outright. `transmute` of a non-nil pointer also isn't a valid
					// Odin compile-time constant, so this whole macro can't stay a `::` constant;
					// `needs_var_decl` tells the caller to emit it as a `:=` variable instead.
					type_tok := ems.tokens[ems.cur_token + 1]
					is_ptr := is_pointer_like_type(ems.decls, ems.types, ems.existing_declarations, type_tok.value)

					p(&b, is_ptr ? "transmute(" : "cast(")
					p(&b, type_tok.value)
					p(&b, ")")
					adv(&ems) // consume the type identifier
					adv(&ems) // consume the ")"

					if is_ptr {
						ems.needs_var_decl = true

						// `transmute` refuses an untyped integer literal operand (unlike `cast`),
						// so wrap it in `uintptr(...)`. Only handles the common
						// `[-|+|~]<literal>` shape (covers every known real-world case of this
						// idiom, e.g. sqlite3.h's `(sqlite3_destructor_type)0`/`-1`); anything
						// fancier falls through unwrapped and likely won't compile.
						unary := ""
						lit_offset := 1
						next := ems.tokens[ems.cur_token + 1]

						if next.kind == .Punctuation && (next.value == "-" || next.value == "+" || next.value == "~") {
							unary = next.value
							lit_offset = 2
						}

						if ems.cur_token + lit_offset < len(ems.tokens) {
							lit_tok := ems.tokens[ems.cur_token + lit_offset]

							if lit_tok.kind == .Literal {
								// `uintptr` is unsigned, so `uintptr(-1)` is a range error even
								// though C's `(void*)-1` (all-ones bit pattern) is exactly what
								// this idiom wants. Go through a signed 64-bit transmute for
								// negative literals to get the matching two's-complement bits.
								if unary == "-" {
									p(&b, "transmute(uintptr)i64(-")
									p(&b, lit_tok.value)
									p(&b, ")")
								} else {
									p(&b, "uintptr(")
									p(&b, unary)
									p(&b, lit_tok.value)
									p(&b, ")")
								}

								for _ in 0 ..< lit_offset {
									adv(&ems)
								}
							}
						}
					}
				} else {
					p(&b, tv)
				}

			case:
				p(&b, tv)
			}
		case .Keyword:
			return "", false
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
					return "", false
				}
			}
		case .Literal:
			if type, ok := parse_literal(&b, tv); ok == false {
				return "", false
			} else {
				literal_type = type
			}
		}

		adv(&ems)
	}

	if notted {
		switch literal_type {
		case .None: return "", false
		case .U32: return "max(u32)", false
		case .I32: return "max(i32)", false
		case .U64: return "max(u64)", false
		case .I64: return "max(i64)", false
		}

		log.errorf("Unknown type: %v", ems.tokens)
	}

	return strings.to_string(b), ems.needs_var_decl
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
				// If it isn't a call then it's either invalid or an alias.
				// By updating ems.macro_lookup with the inned macro idx we assume it's an alias.
				ems.macro_lookup[ems.cur_macro.name] = inner_macro_idx
				return false
			}
			
			adv(ems)
			args = parse_parameter_list(ems)
		}

		inner, inner_needs_var_decl := evaluate_macro(ems.macros, ems.macro_lookup, ems.existing_declarations, ems.decls, ems.types, inner_macro_idx, args, config)

		if inner == "" {
			return false
		}

		ems.needs_var_decl |= inner_needs_var_decl
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
		case .Or:              return 0
		case .Xor:             return 1
		case .And:             return 2
		case .Lsft, .Rsft:     return 3
		case .Sub, .Add:       return 4
		case .Mul, .Div, .Mod: return 5
		case .Not:             return 6
		}
		panic("Unrechable!")
	}

	Operator :: enum {
		Or,
		Xor,
		And,
		Not,
		Lsft,
		Rsft,
		Sub,
		Add,
		Mul,
		Div,
		Mod,
	}

	Stack_Op :: struct {
		op: Operator,
		prec: int,
	}

	ops: [dynamic]Stack_Op
	prec_mod: int

	rpn: [dynamic]union {
		Operator,
		int,
	}

	// Reconstruct equation in reverse polish notation
	// https://en.wikipedia.org/wiki/Shunting_yard_algorithm
	for tok in toks {
		switch tok.kind {
		case .Literal:
			val, ok := strconv.parse_int(tok.value)
			if !ok {
				return 0, false
			}
			append(&rpn, val)
		case .Identifier:
			macro_idx, is_macro := macro_lookup[tok.value]
			if !is_macro {
				return 0, false
			}
			val, ok := parse_tokens_to_int(macros[macro_idx].tokens, macros, macro_lookup)
			if !ok {
				return 0, false
			}
			append(&rpn, val)
		case .Punctuation:
			if tok.value == "(" {
				prec_mod += len(Operator)
				continue
			} else if tok.value == ")" {
				prec_mod -= len(Operator)
				if prec_mod < 0 {
					// Too many ')'s
					return 0, false
				}
				continue
			}

			op: Operator
			switch tok.value {
			case "|":  op = .Or
			case "^":  op = .Xor
			case "&":  op = .And
			case "~":  op = .Not
			case "<<": op = .Lsft
			case ">>": op = .Rsft
			case "-":  op = .Sub
			case "+":  op = .Add
			case "*":  op = .Mul
			case "/":  op = .Div
			case "%":  op = .Mod
			case: return 0, false
			}

			prec := operator_precedence(op) + prec_mod
			for len(ops) != 0 {
				top_op := pop(&ops)
				if prec > top_op.prec {
					append(&ops, top_op)
					break
				}
				append(&rpn, top_op.op)
			}

			append(&ops, Stack_Op {
				op = op,
				prec = prec,
			})
		case .Keyword:
			return 0, false
		}
	}
	
	if prec_mod != 0 {
		// Didn't have a balanced number of parens
		return 0, false
	}

	for len(ops) > 0 {
		append(&rpn, pop(&ops).op)
	}

	literals: [dynamic]int
	for elem in rpn {
		switch _ in elem {
		case int:
			append(&literals, elem.(int))
		case Operator:
			op := elem.(Operator)
			if op == .Not {
				if len(literals) == 0 {
					return 0, false
				}

				append(&literals, ~pop(&literals))
				continue
			}
			
			if len(literals) < 2 {
				return 0, false
			}
			
			rhs := pop(&literals)
			lhs := pop(&literals)

			// Shift by negative is undefined. I'm going to invert the op but maybe this should be illegal.
			if (op == .Lsft || op == .Rsft) && rhs < 0 {
				rhs *= -1
				op = op == .Lsft ? .Rsft : .Lsft
			}

			val: int
			#partial switch op {
			case .Or:   val = lhs | rhs
			case .Xor:  val = lhs ~ rhs
			case .And:  val = lhs & rhs
			case .Lsft: val = lhs << uint(rhs)
			case .Rsft: val = lhs >> uint(rhs)
			case .Sub:  val = lhs - rhs
			case .Add:  val = lhs + rhs
			case .Mul:  val = lhs * rhs
			case .Div:  val = lhs / rhs
			case .Mod:  val = lhs % rhs
			}
			append(&literals, val)
		}
	}

	return pop(&literals), len(literals) == 0
}

