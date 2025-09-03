// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d



foreign import lib "box2d.lib"

// static library
// BOX2D_EXPORT :: 

// API :: BOX2D_EXPORT
// INLINE :: 

/// Prototype for user allocation function
/// @param size the allocation size in bytes
/// @param alignment the required alignment, guaranteed to be a power of 2
AllocFcn :: proc "c" (u32, i32) -> rawptr

/// Prototype for user free function
/// @param mem the memory previously allocated through `b2AllocFcn`
FreeFcn :: proc "c" (rawptr)

/// Prototype for the user assert callback. Return 0 to skip the debugger break.
AssertFcn :: proc "c" (cstring, cstring, i32) -> i32

// BREAKPOINT :: __debugbreak()

/// Version numbering scheme.
/// See https://semver.org/
Version :: struct {
	/// Significant changes
	major: i32,

	/// Incremental changes
	minor: i32,

	/// Bug fixes
	revision: i32,
}

HASH_INIT :: 5381

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// This allows the user to override the allocation functions. These should be
	/// set during application startup.
	SetAllocator :: proc(allocFcn: ^AllocFcn, freeFcn: ^FreeFcn) ---

	/// @return the total bytes allocated by Box2D
	GetByteCount :: proc() -> i32 ---

	/// Override the default assert callback
	/// @param assertFcn a non-null assert callback
	SetAssertFcn      :: proc(assertFcn: ^AssertFcn) ---
	InternalAssertFcn :: proc(condition: cstring, fileName: cstring, lineNumber: i32) -> i32 ---

	/// Get the current version of Box2D
	GetVersion :: proc() -> Version ---

	/// Get the absolute number of system ticks. The value is platform specific.
	GetTicks :: proc() -> uint64_t ---

	/// Get the milliseconds passed from an initial tick value.
	GetMilliseconds :: proc(ticks: uint64_t) -> f32 ---

	/// Get the milliseconds passed from an initial tick value.
	GetMillisecondsAndReset :: proc(ticks: ^uint64_t) -> f32 ---

	/// Yield to be used in a busy loop.
	Yield :: proc() ---
	Hash  :: proc(hash: uint32_t, data: ^uint8_t, count: i32) -> uint32_t ---
}
