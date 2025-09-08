package test





TEST :: u8

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
	test           :: proc(log: myLogImpl) ---
	test2          :: proc(log: myLogImpl2) ---
	test3          :: proc(log: ^myLogImpl) ---
	test4          :: proc(log: ^myLogImpl2) ---
	nppiYCCKToCMYK :: proc(pSrc: [4]^i32, nSrcStep: i32, pDst: [4]^i32, nDstStep: i32, oSizeROI: i32, nppStreamCtx: i32) -> i32 ---
}
