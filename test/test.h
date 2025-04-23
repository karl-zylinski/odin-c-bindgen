#pragma GCC push_options
#pragma GCC optimize ("O0")

#define NEST(x) NEST1(x)
#define NEST1(x) NEST2(x)
#define NEST2(x) (x)

#define SUB(x, y)(float)(x) - (float)(y)

#define FIVE_SUB_TWO SUB(5, 2)
#define UNNEST NEST("Test")

#define ARRAY {1}

#pragma GCC pop_options