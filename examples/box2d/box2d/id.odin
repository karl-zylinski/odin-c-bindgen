// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d

foreign import lib "box2d.lib"
_ :: lib

/// World id references a world instance. This should be treated as an opaque handle.
WorldId :: struct {
	index1:     u16,
	generation: u16,
}

/// Body id references a body instance. This should be treated as an opaque handle.
BodyId :: struct {
	index1:     i32,
	world0:     u16,
	generation: u16,
}

/// Shape id references a shape instance. This should be treated as an opaque handle.
ShapeId :: struct {
	index1:     i32,
	world0:     u16,
	generation: u16,
}

/// Chain id references a chain instances. This should be treated as an opaque handle.
ChainId :: struct {
	index1:     i32,
	world0:     u16,
	generation: u16,
}

/// Joint id references a joint instance. This should be treated as an opaque handle.
JointId :: struct {
	index1:     i32,
	world0:     u16,
	generation: u16,
}

