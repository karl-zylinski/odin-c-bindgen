@(extra_linker_flags="/NODEFAULTLIB:libcmt")
foreign import lib {
	"raylib.lib",
	"system:Winmm.lib",
	"system:Gdi32.lib",
	"system:User32.lib",
	"system:Shell32.lib",
}