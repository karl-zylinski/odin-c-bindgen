enum Flags : long long {
	Flags_None = 0,
	Flags_Flag1 = 1,
	Flags_Flag2 = 2,
	// Comment
	Flags_SpecialValue = 0xFFFF, // Comment
	Flags_Test = (long long)(1)<<63,
};

// Comment
#define MAKE_ENUM_0 0 // Side Comment 
#define MAKE_ENUM_1 1 // Side Comment 
#define MAKE_ENUM_2 2
#define MAKE_ENUM_3 3

// Header comment
#define MAKE_ENUM_4 4 // More More side Comment
// Another header comment
#define MAKE_ENUM_5 5 // More side Comment
#define MAKE_ENUM_15 15
