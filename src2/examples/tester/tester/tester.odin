package tester

Test2 :: struct {
	y: i32,
}

Wa :: enum {
	One,
	Two,
	Three,
}

Test1 :: struct {
	x: i32,
	tt: ^Test1,
	t: Test2,
	w: Wa,
	bam: Di,
	Ba: enum {
		Didi,
		Dodo,
	},
}

Test1 :: struct {
	x: i32,
	tt: ^Test1,
	t: Test2,
	w: Wa,
	bam: Di,
	Ba: enum {
		Didi,
		Dodo,
	},
}

Di :: struct {
	z: i32,
}

Test3 :: Test1


// this seems bugged?
// typedef Test1 Test3;
Test4 :: struct {
	z: ^i32,
}

// this seems bugged?
// typedef Test1 Test3;
Test4 :: struct {
	z: ^i32,
}

