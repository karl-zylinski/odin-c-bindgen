when ODIN_OS == .Windows {
	foreign import lib "joltc.lib"
} else when ODIN_OS == .Darwin {
	foreign import lib "libjoltc.dylib"
} else when ODIN_OS == .Linux {
	foreign import lib "libjoltc.so"
}