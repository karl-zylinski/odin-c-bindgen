#pragma once

typedef struct {
	int* z;
} Test4;


struct Test2 {
	int y;
};

enum Wa {
	One,
	Two,
	Three,
};

typedef struct Test1 {
	int x;

	struct Test1 *tt;

	struct Test2 t;

	enum Wa w;

	struct Di {
		int z;
	} bam;

	enum {
		Didi,
		Dodo,
	} ba;
} Test1;

typedef struct Test1 Test3;

typedef Test3 Test15;