#+private file
package bindgen2

import clang "../libclang"
import "core:log"

@(private="package")
Raw_Macro :: struct {
	name: string,
	tokens: []Raw_Macro_Token,
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
		macro_evaluated = make([]bool, len(macros)),
	}

	for m, i in macros {
		tms.macro_lookup[m.name] = i
	}

	for _, i in macros {
		evaluate_macro(&tms, i)
	}

	return {}
}

evaluate_macro :: proc(tms: ^Translate_Macros_State, mi: Macro_Index) {
	if tms.macro_evaluated[mi] {
		return
	}

	tms.macro_evaluated[mi] = true
	evaluate_nonfn_macro(tms, mi)
}

evaluate_nonfn_macro :: proc(tms: ^Translate_Macros_State, mi: Macro_Index) {
	m := &tms.macros[mi]
	curly_braces: int

	for t in m.tokens {
		tv := t.value
		switch t.kind {
		case .Punctuation:
		case .Keyword:
		case .Identifier:
		case .Literal:
		}
	}
}

Macro_Index :: int

Translate_Macros_State :: struct {
	tu: clang.Translation_Unit,
	macros: []Raw_Macro,
	macro_lookup: map[string]Macro_Index,
	macro_evaluated: []bool,
}