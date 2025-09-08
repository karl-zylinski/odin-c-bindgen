package bind_test

import "../binding"
import "core:fmt"

main :: proc() {
    fmt.println("Result:", binding.constArray({2, 9, 4, 10}))
    fmt.println("Expected:", 2 + 9 + 4 + 10)
}