package tester

Test4 :: struct {
	z: ^i32,
}

Test2 :: struct {
	y: i32,
}

Wa :: enum {
	One = 0,
	Two = 1,
	Three = 2,
}

Test1 :: struct {
	x: i32,
	tt: ^Test1,
	t: Test2,
	w: Wa,
	bam: Di,
	ba: enum {
		Didi = 0,
		Dodo = 1,
	},
}

Di :: struct {
	z: i32,
}

Test3 :: Test1

Test15 :: Test3

