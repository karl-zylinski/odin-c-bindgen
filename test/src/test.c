#include "test.h"

char constArray(const char arr[2]) {
    return arr[0] + arr[1];
}

char typedef_test(testType arr) {
    return arr[0] + arr[1];
}