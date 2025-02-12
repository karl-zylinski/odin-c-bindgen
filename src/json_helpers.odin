package bindgen

import "core:encoding/json"

json_get :: proc(v: json.Value, key: string) -> json.Value {
	return v.(json.Object)[key]
}

json_check_bool :: proc(v: json.Value, key: string) -> bool {
	o := v.(json.Object) or_return
	val := o[key] or_return
	return val.(json.Boolean)
}

json_get_string :: proc(v: json.Value, key: string) -> (str: string, ok: bool) {
	o := v.(json.Object) or_return
	val := o[key] or_return
	return val.(json.String)
}

json_get_array :: proc(v: json.Value, key: string) -> (arr: json.Array, ok: bool) {
	o := v.(json.Object) or_return
	val := o[key] or_return
	return val.(json.Array)
}

json_get_integer :: proc(v: json.Value, key: string) -> (i: json.Integer, ok: bool) {
	o := v.(json.Object) or_return
	val := o[key] or_return
	return val.(json.Integer)
}

json_get_object :: proc(v: json.Value, key: string) -> (arr: json.Object, ok: bool) {
	o := v.(json.Object) or_return
	val := o[key] or_return
	return val.(json.Object)
}
