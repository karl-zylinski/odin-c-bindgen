// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d

import "core:c"

_ :: c

foreign import lib "box2d.lib"

// API :: BOX2D_EXPORT
// INLINE :: static inline

/// Prototype for user allocation function
/// @param size the allocation size in bytes
/// @param alignment the required alignment, guaranteed to be a power of 2
AllocFcn :: proc "c" (u32, i32) -> rawptr

/// Prototype for user free function
/// @param mem the memory previously allocated through `b2AllocFcn`
FreeFcn :: proc "c" (rawptr)

/// Prototype for the user assert callback. Return 0 to skip the debugger break.
AssertFcn :: proc "c" (cstring, cstring, i32) -> i32

// BREAKPOINT :: _debugbreak()

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

/// Simple djb2 hash function for determinism testing
HASH_INIT :: 5381

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// This allows the user to override the allocation functions. These should be
	/// set during application startup.
	SetAllocator :: proc(allocFcn: AllocFcn, freeFcn: FreeFcn) ---

	/// @return the total bytes allocated by Box2D
	GetByteCount :: proc() -> i32 ---

	/// Override the default assert callback
	/// @param assertFcn a non-null assert callback
	SetAssertFcn      :: proc(assertFcn: AssertFcn) ---
	InternalAssertFcn :: proc(condition: cstring, fileName: cstring, lineNumber: i32) -> i32 ---

	/// Get the current version of Box2D
	GetVersion :: proc() -> Version ---

	/// Get the absolute number of system ticks. The value is platform specific.
	GetTicks :: proc() -> u64 ---

	/// Get the milliseconds passed from an initial tick value.
	GetMilliseconds :: proc(ticks: u64) -> f32 ---

	/// Get the milliseconds passed from an initial tick value.
	GetMillisecondsAndReset :: proc(ticks: ^u64) -> f32 ---

	/// Yield to be used in a busy loop.
	Yield :: proc() ---
	Hash  :: proc(hash: u32, data: ^u8, count: i32) -> u32 ---
}
