#+private file
package bindgen2

import "core:log"
import "core:strings"

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
	//	macro_evaluated = make([]bool, len(macros)),
	}

	for m, i in macros {
		tms.macro_lookup[m.name] = i
	}

	macro_decls: [dynamic]Declaration

	for m, i in macros {
		odin_value := evaluate_macro(&tms, i)

		if odin_value != "" {
			//append(&macro_decls, Declaration {
			//	name = m.name,
			//	type = 
			//})
		}
	}

	return {}
}

evaluate_macro :: proc(tms: ^Translate_Macros_State, mi: Macro_Index) -> string {
/*	if tms.macro_evaluated[mi] {
		return ""
	}

	tms.macro_evaluated[mi] = true*/
	return evaluate_nonfn_macro(tms, mi)
}

evaluate_nonfn_macro :: proc(tms: ^Translate_Macros_State, mi: Macro_Index) -> string {
	m := &tms.macros[mi]
	curly_braces: int

	b := strings.builder_make()

	for t in m.tokens {
		tv := t.value
		switch t.kind {
		case .Punctuation:
			strings.write_string(&b, tv)
		case .Keyword:
			strings.write_string(&b, tv)
		case .Identifier:
			strings.write_string(&b, tv)
		case .Literal:
			strings.write_string(&b, tv)
		}
	}

	return strings.to_string(b)
}

Macro_Index :: int

Translate_Macros_State :: struct {
	macros: []Raw_Macro,
	macro_lookup: map[string]Macro_Index,
}