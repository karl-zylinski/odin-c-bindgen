#pragma once

struct Test2 {
	int y;
};

enum Wa {
	One,
	Two,
	Three,
};

struct Test1;

struct Test1 {
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
	} Ba;
};

typedef struct Test1 Test3;

// this seems bugged?
// typedef Test1 Test3;

typedef struct Test4 {
	int* z;
} Test4;