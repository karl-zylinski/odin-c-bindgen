package test





MyVtable :: struct {
	myLog: proc "c" (cstring, #c_vararg ..any),
}

test_vtable :: struct {
	listfiles: proc "c" (cstring, proc "c" (cstring, rawptr), rawptr, i32) -> i32,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	myLogImpl                          :: proc(fmt: cstring, #c_vararg _: ..any) ---
	nppiYCCKToCMYK_JPEG_601_8u_P4R_Ctx :: proc(pSrc: [4]^i32, nSrcStep: i32, pDst: [4]^i32, nDstStep: i32, oSizeROI: i32, nppStreamCtx: i32) -> i32 ---
}
