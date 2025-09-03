// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d



foreign import lib "box2d.lib"

/// World id references a world instance. This should be treated as an opaque handle.
WorldId :: struct {
	index1:     uint16_t,
	generation: uint16_t,
}

/// Body id references a body instance. This should be treated as an opaque handle.
BodyId :: struct {
	index1:     int32_t,
	world0:     uint16_t,
	generation: uint16_t,
}

/// Shape id references a shape instance. This should be treated as an opaque handle.
ShapeId :: struct {
	index1:     int32_t,
	world0:     uint16_t,
	generation: uint16_t,
}

/// Chain id references a chain instances. This should be treated as an opaque handle.
ChainId :: struct {
	index1:     int32_t,
	world0:     uint16_t,
	generation: uint16_t,
}

/// Joint id references a joint instance. This should be treated as an opaque handle.
JointId :: struct {
	index1:     int32_t,
	world0:     uint16_t,
	generation: uint16_t,
}

