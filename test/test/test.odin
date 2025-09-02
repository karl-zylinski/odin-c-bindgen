package test





CXIndexOptions :: struct {
	/**
	* The size of struct CXIndexOptions used for option versioning.
	*
	* Always initialize this member to sizeof(CXIndexOptions), or assign
	* sizeof(CXIndexOptions) to it right after creating a CXIndexOptions object.
	*/
	Size: u32,

	/**
	* A CXChoice enumerator that specifies the indexing priority policy.
	* \sa CXGlobalOpt_ThreadBackgroundPriorityForIndexing
	*/
	ThreadBackgroundPriorityForIndexing: u8,

	/**
	* A CXChoice enumerator that specifies the editing priority policy.
	* \sa CXGlobalOpt_ThreadBackgroundPriorityForEditing
	*/
	ThreadBackgroundPriorityForEditing: u8,

	/**
	* \see clang_createIndex()
	*/
	ExcludeDeclarationsFromPCH: u32,

	/**
	* \see clang_createIndex()
	*/
	DisplayDiagnostics: u32,

	/**
	* Store PCH in memory. If zero, PCH are stored in temporary files.
	*/
	StorePreamblesInMemory: u32,
	_: u32, /*Reserved*/
}

MyVtable :: struct {
	myLog: proc "c" (cstring, #c_vararg ..any),
}

myLogImpl :: proc "c" (cstring, #c_vararg ..any)

test_vtable :: struct {
	listfiles: proc "c" (cstring, proc "c" (cstring, rawptr), rawptr, i32) -> i32,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	test           :: proc(fmt: cstring, log: proc "c" (cstring, #c_vararg ..any)) ---
	nppiYCCKToCMYK :: proc(pSrc: [4]^i32, nSrcStep: i32, pDst: [4]^i32, nDstStep: i32, oSizeROI: i32, nppStreamCtx: i32) -> i32 ---
}
