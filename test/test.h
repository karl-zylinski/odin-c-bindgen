#pragma GCC push_options
#pragma GCC optimize ("O0")

#include <stdarg.h>

#define TEST unsigned char

typedef struct CXIndexOptions {
  /**
   * The size of struct CXIndexOptions used for option versioning.
   *
   * Always initialize this member to sizeof(CXIndexOptions), or assign
   * sizeof(CXIndexOptions) to it right after creating a CXIndexOptions object.
   */
  unsigned Size;
  /**
   * A CXChoice enumerator that specifies the indexing priority policy.
   * \sa CXGlobalOpt_ThreadBackgroundPriorityForIndexing
   */
  unsigned char ThreadBackgroundPriorityForIndexing;
  /**
   * A CXChoice enumerator that specifies the editing priority policy.
   * \sa CXGlobalOpt_ThreadBackgroundPriorityForEditing
   */
  unsigned char ThreadBackgroundPriorityForEditing;
  /**
   * \see clang_createIndex()
   */
  unsigned ExcludeDeclarationsFromPCH : 1;
  /**
   * \see clang_createIndex()
   */
  unsigned DisplayDiagnostics : 1;
  /**
   * Store PCH in memory. If zero, PCH are stored in temporary files.
   */
  unsigned StorePreamblesInMemory : 1;
  unsigned /*Reserved*/ : 13;
} CXIndexOptions;

typedef void (*myLogImpl)(const char* fmt, ...);

typedef void (myLogImpl2)(const char* fmt, ...);

struct MyVtable {
  myLogImpl    logger;
  myLogImpl2*  logger2;
  myLogImpl*   logger3;
  myLogImpl2** logger4;
};

void test (myLogImpl log);

void test2 (myLogImpl2* log);

void test3(myLogImpl* log);

void test4(myLogImpl2** log);

int nppiYCCKToCMYK(const int * pSrc[4], int nSrcStep, int * pDst[4], int nDstStep, int oSizeROI, int nppStreamCtx);

void constArray(int arr[4]);

#pragma GCC pop_options
