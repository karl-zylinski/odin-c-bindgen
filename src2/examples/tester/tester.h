/* a top comment */

#pragma once

#include <stdarg.h>     // Required for: va_list - Only used by TraceLogCallback

#if (defined(__STDC__) && __STDC_VERSION__ >= 199901L) || (defined(_MSC_VER) && _MSC_VER >= 1800)
    #include <stdbool.h>
#elif !defined(__cplusplus) && !defined(bool)
    typedef enum bool { false = 0, true = !false } bool;
#endif

typedef struct Test4 {
	int* z;
} Test4;

struct Test2 {
	int y;
};

enum Wa {
	One,
	Two,
	Three,
};

typedef enum
{
	NVTT_Container_DDS,
	NVTT_Container_DDS10,
} NvttContainer;


#define CLITERAL(type)      (type)
#define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }   // Light Gray

//#define Test5 Test4

//#define Maa (float)5

struct Test1 {
	int x;

	struct Test1 *tt;

	struct Test2 t;

	enum Wa w;

	union {
		int zz;
		int oo;
	} Didido;

	struct Di {
		int z;
	} bam;

	enum {
		Didi,
		Dodo,
	} ba;
};

union Un {
	int x;
	struct Test1 t;
	float y;
}

typedef struct Test1 Test3;

typedef Test3 Test15;


typedef struct {
	int (*hello)(void* data, int len);
} My_API;

typedef void (*TraceLogCallback)(int logLevel, const char *text, va_list args);  // Logging: Redirect trace log messages
typedef unsigned char *(*LoadFileDataCallback)(const char *fileName, int *dataSize);    // FileIO: Load binary data
typedef bool (*SaveFileDataCallback)(const char *fileName, void *data, int dataSize);   // FileIO: Save binary data
typedef char *(*LoadFileTextCallback)(const char *fileName);            // FileIO: Load text data
typedef bool (*SaveFileTextCallback)(const char *fileName, char *text); // FileIO: Save text data

Shader LoadShader(const char *vsFileName, const char *fsFileName);  
Shader LoadShaderFromMemory(const char *vsCode, const char *fsCode);
bool IsShaderValid(Shader shader);