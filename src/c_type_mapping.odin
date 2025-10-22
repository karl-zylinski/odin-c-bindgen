#+feature dynamic-literals
package bindgen2

c_type_mapping := map[string]string {
	// builtin types
	"uint8_t"  = "u8",
	"int8_t"   = "i8",
	"uint16_t" = "u16",
	"int16_t"  = "i16",
	"uint32_t" = "u32",
	"int32_t"  = "i32",
	"uint64_t" = "u64",
	"int64_t"  = "i64",

	"int_least8_t"   = "i8",
	"uint_least8_t"  = "u8",
	"int_least16_t"  = "i16",
	"uint_least16_t" = "u16",
	"int_least32_t"  = "i32",
	"uint_least32_t" = "u32",
	"int_least64_t"  = "i64",
	"uint_least64_t" = "u64",

	"int_fast8_t"   = "i8",
	"uint_fast8_t"  = "u8",
	"int_fast32_t"  = "i32",
	"uint_fast32_t" = "u32",
	"int_fast64_t"  = "i64",
	"uint_fast64_t" = "u64",
	
	// core:c (many of these vary by platform, so we use the `core:c` ones to make this map simpler)

	"long"          = "c.long",
	"unsigned long" = "c.ulong",
	"int_fast16_t"  = "c.int_fast16_t",
	"uint_fast16_t" = "c.uint_fast16_t",

	"size_t"  = "c.size_t",
	"ssize_t" = "c.ssize_t",
	"wchar_t" = "c.wchar_t",

	"intptr_t"  = "c.intptr_t",
	"uintptr_t" = "c.uintptr_t",
	"ptrdiff_t" = "c.ptrdiff_t",

	"intmax_t"  = "c.intmax_t",
	"uintmax_t" = "c.uintmax_t",

	"va_list" = "c.va_list",

	// posix
	"dev_t"      = "posix.dev_t",
	"blkcnt_t"   = "posix.blkcnt_t",
	"blksize_t"  = "posix.blksize_t",
	"clock_t"    = "posix.clock_t",
	"clockid_t"  = "posix.clockid_t",
	"fsblkcnt_t" = "posix.fsblkcnt_t",
	"off_t"      = "posix.off_t",
	"gid_t"      = "posix.gid_t",
	"pid_t"      = "posix.pid_t",
	"timespec"   = "posix.timespec",

	// libc
	"time_t" = "libc.time_t",
}
