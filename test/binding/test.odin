package test



foreign import lib "test.lib"

TEST :: u8

testType :: [4]i32

myLogImpl :: proc "c" (cstring, #c_vararg ..any)

myLogImpl2 :: proc "c" (cstring, #c_vararg ..any)

MyVtable :: struct {
	logger:  myLogImpl,
	logger2: myLogImpl2,
	logger3: ^myLogImpl,
	logger4: ^myLogImpl2,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	test1           :: proc(log: myLogImpl) ---
	test2           :: proc(log: myLogImpl2) ---
	test3           :: proc(log: ^myLogImpl) ---
	test4           :: proc(log: ^myLogImpl2) ---
	constArray      :: proc(#by_ptr arr: [4]i32) -> i32 ---
	typedef_test    :: proc(#by_ptr arr: testType) -> i32 ---
	functionNoProto :: proc() ---
	functionProto   :: proc() ---
}
