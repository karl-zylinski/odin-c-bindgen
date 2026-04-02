#include <stdint.h>

#define FIVE UINT8_C(5)

#define MAX WINT_MAX

#define TEST UINT8_C

#define FN(x) (x)
#define FN_ALIAS FN
#define FN_AA FN_ALIAS
#define TWO FN_AA(2)
