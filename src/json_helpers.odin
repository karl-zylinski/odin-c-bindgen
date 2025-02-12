package bindgen

import "core:encoding/json"
import "core:strings"
import "core:strconv"

_ :: strings
_ :: strconv

json_check_bool :: proc(v: json.Value, key: string) -> bool {
	val, _ := json_get(v, key, json.Boolean)
	return val
}

json_get_string :: proc(v: json.Value, key: string) -> (str: string, ok: bool) {
	return json_get(v, key, json.String)
}

json_get_array :: proc(v: json.Value, key: string) -> (arr: json.Array, ok: bool) {
	return json_get(v, key, json.Array)
}

json_get_int :: proc(v: json.Value, key: string) -> (res: int, ok: bool) {
	i, i_ok := json_get(v, key, json.Integer)
	return int(i), i_ok
}

json_get_object :: proc(v: json.Value, key: string) -> (arr: json.Object, ok: bool) {
	return json_get(v, key, json.Object)
}

json_get :: proc(v: json.Value, key: string, $T: typeid) -> (res: T, ok: bool) {
	key_iter := key
	cur := v

	for k in strings.split_iterator(&key_iter, ".") {
		is_index := false
		index: int
		if i, i_ok := strconv.parse_int(k, 10); i_ok {
			is_index = true
			index = i
		}

		if is_index {
			if arr, is_arr := cur.(json.Array); is_arr {
				if index < 0 || index >= len(arr) {
					return {}, false
				}

				cur = arr[index]
			} else {
				return {}, false
			}
		} else {
			if obj, is_obj := cur.(json.Object); is_obj {
				if child, child_ok := obj[k]; child_ok {
					cur = child
				} else {
					return {}, false
				}
			} else {
				return {}, false
			}
		}
	}

	return cur.(T)
}

json_has :: proc(v: json.Value, key: string) -> (ok: bool) {
	key_iter := key
	cur := v

	for k in strings.split_iterator(&key_iter, ".") {
		is_index := false
		index: int
		if i, i_ok := strconv.parse_int(k, 10); i_ok {
			is_index = true
			index = i
		}

		if is_index {
			if arr, is_arr := cur.(json.Array); is_arr {
				if index < 0 || index >= len(arr) {
					return false
				}

				cur = arr[index]
			} else {
				return false
			}
		} else {
			if obj, is_obj := cur.(json.Object); is_obj {
				if child, child_ok := obj[k]; child_ok {
					cur = child
				} else {
					return false
				}
			} else {
				return false
			}
		}
	}

	return true
}