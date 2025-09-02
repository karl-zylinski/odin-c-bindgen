#pragma GCC push_options
#pragma GCC optimize ("O0")

#include <stdarg.h>

struct MyVtable {
        void (*myLog)(const char *fmt, ...);
};

void myLogImpl (const char *fmt, ...) {
        // Do something here
}

struct test_vtable {
    int (*listfiles)(const char* path, void (*callback)(const char* path, void* userdata), void* userdata, int showhidden);
};

int nppiYCCKToCMYK_JPEG_601_8u_P4R_Ctx(const int * pSrc[4], int nSrcStep, int * pDst[4], int nDstStep, int oSizeROI, int nppStreamCtx);

#pragma GCC pop_options
