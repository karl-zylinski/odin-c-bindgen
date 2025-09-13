#pragma GCC push_options
#pragma GCC optimize ("O0")

#include <stdarg.h>

#define TEST unsigned char

typedef int testType[4];

typedef void (*myLogImpl)(const char* fmt, ...);

typedef void (myLogImpl2)(const char* fmt, ...);

struct MyVtable {
  myLogImpl    logger;
  myLogImpl2*  logger2;
  myLogImpl*   logger3;
  myLogImpl2** logger4;
};

void test1(myLogImpl log);

void test2(myLogImpl2* log);

void test3(myLogImpl* log);

void test4(myLogImpl2** log);

int constArray(const int arr[4]);

int typedef_test(testType arr);

void functionNoProto();

void functionProto(void);

#pragma GCC pop_options
