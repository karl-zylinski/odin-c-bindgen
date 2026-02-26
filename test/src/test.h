enum Flags : long long {
	Flags_None = 0,
	Flags_Flag1 = 1,
	Flags_Flag2 = 2,
	// Comment
	Flags_SpecialValue = 0xFFFF, // Comment
	Flags_Test = (long long)(1)<<63,
};

#define MAKE_ENUM_0 0
#define MAKE_ENUM_1 1
#define MAKE_ENUM_2 2
#define MAKE_ENUM_3 3
#define MAKE_ENUM_4 4
#define MAKE_ENUM_5 5
#define MAKE_ENUM_15 15

#define MAKE_INT_test1 (1 << 2)
#define MAKE_INT_test2 1 + 3 + 5 - 4
#define MAKE_INT_test3 2 + 5 * 10 - 10
#define MAKE_INT_test4 2 + 5 / ( 1 + 4 ) * 20
#define MAKE_INT_test5 2+5/(1+4)*20
#define MAKE_INT_test6 1 << 2 + 2
#define MAKE_INT_test7 0b1000 >> 3
#define MAKE_INT_test8 0x1080 & 0xFFFF
#define MAKE_INT_test9 ~0
#define MAKE_INT_test10 MAKE_INT_test6 + 4

typedef long long MyInt64;

#define MACRO (MyInt64)(10)

#define RETRO_TEST_0 8
#define RETRO_TEST_1 (RETRO_TEST_0 << 1) + 8
