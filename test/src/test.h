#include <stdarg.h>

#define TEST unsigned char

typedef signed long   Int64;
typedef unsigned long UInt64;

typedef char testType[2];

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

char constArray(const char arr[2]);

char typedef_test(testType arr);

void functionNoProto();

void functionProto(void);

