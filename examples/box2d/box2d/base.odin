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
AllocFcn :: proc "c" (c.uint, c.int) -> rawptr

/// Prototype for user free function
/// @param mem the memory previously allocated through `b2AllocFcn`
FreeFcn :: proc "c" (rawptr)

/// Prototype for the user assert callback. Return 0 to skip the debugger break.
AssertFcn :: proc "c" (cstring, cstring, c.int) -> c.int

// BREAKPOINT :: _debugbreak()

/// Version numbering scheme.
/// See https://semver.org/
Version :: struct {
	/// Significant changes
	major: c.int,

	/// Incremental changes
	minor: c.int,

	/// Bug fixes
	revision: c.int,
}

/// Simple djb2 hash function for determinism testing
HASH_INIT :: 5381

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// This allows the user to override the allocation functions. These should be
	/// set during application startup.
	SetAllocator :: proc(allocFcn: AllocFcn, freeFcn: FreeFcn) ---

	/// @return the total bytes allocated by Box2D
	GetByteCount :: proc() -> c.int ---

	/// Override the default assert callback
	/// @param assertFcn a non-null assert callback
	SetAssertFcn      :: proc(assertFcn: AssertFcn) ---
	InternalAssertFcn :: proc(condition: cstring, fileName: cstring, lineNumber: c.int) -> c.int ---

	/// Get the current version of Box2D
	GetVersion :: proc() -> Version ---

	/// Get the absolute number of system ticks. The value is platform specific.
	GetTicks :: proc() -> c.uint64_t ---

	/// Get the milliseconds passed from an initial tick value.
	GetMilliseconds :: proc(ticks: c.uint64_t) -> c.float ---

	/// Get the milliseconds passed from an initial tick value.
	GetMillisecondsAndReset :: proc(ticks: ^c.uint64_t) -> c.float ---

	/// Yield to be used in a busy loop.
	Yield :: proc() ---
	Hash  :: proc(hash: c.uint32_t, data: ^c.uint8_t, count: c.int) -> c.uint32_t ---
}
