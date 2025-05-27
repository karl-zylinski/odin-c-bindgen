// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d

import "core:c"

_ :: c

foreign import lib "box2d.lib"

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

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// Store a body id into a uint64_t.
	StoreBodyId :: proc(id: BodyId) -> u64 ---

	/// Load a uint64_t into a body id.
	LoadBodyId :: proc(x: u64) -> BodyId ---

	/// Store a shape id into a uint64_t.
	StoreShapeId :: proc(id: ShapeId) -> u64 ---

	/// Load a uint64_t into a shape id.
	LoadShapeId :: proc(x: u64) -> ShapeId ---

	/// Store a chain id into a uint64_t.
	StoreChainId :: proc(id: ChainId) -> u64 ---

	/// Load a uint64_t into a chain id.
	LoadChainId :: proc(x: u64) -> ChainId ---

	/// Store a joint id into a uint64_t.
	StoreJointId :: proc(id: JointId) -> u64 ---

	/// Load a uint64_t into a joint id.
	LoadJointId :: proc(x: u64) -> JointId ---
}
