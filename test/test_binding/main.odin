package bind_test

import "../binding"
import "core:fmt"

main :: proc() {
    fmt.println("Result fixed array:", binding.constArray({2, 9}))
    fmt.println("Result typedefed array:", binding.typedef_test({2, 9}))
    fmt.println("Expected:", 2 + 9)
}