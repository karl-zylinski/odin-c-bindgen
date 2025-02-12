//
// Public header file for PDFio.
//
// Copyright © 2021-2025 by Michael R Sweet.
//
// Licensed under Apache License v2.0.  See the file "LICENSE" for more
// information.
//

#ifndef PDFIO_H
#  define PDFIO_H
#  include <stdio.h>
#  include <stdlib.h>
#  include <stdbool.h>
#  include <sys/types.h>
#  include <time.h>
#  ifdef __cplusplus
extern "C" {
#  endif // __cplusplus


//
// Version number...
//

#  define PDFIO_VERSION		"1.4.1"


//
// Visibility and other annotations...
//

#  if defined(__has_extension) || defined(__GNUC__)
#    define _PDFIO_PUBLIC	__attribute__ ((visibility("default")))
#    define _PDFIO_FORMAT(a,b)	__attribute__ ((__format__(__printf__, a,b)))
#    define _PDFIO_DEPRECATED	__attribute__ ((deprecated)) _PDFIO_PUBLIC
#  else
#    define _PDFIO_PUBLIC
#    define _PDFIO_FORMAT(a,b)
#    define _PDFIO_DEPRECATED
#  endif // __has_extension || __GNUC__


//
// Types and constants...
//

#  if _WIN32
typedef __int64 ssize_t;		// POSIX type not present on Windows... @private@
#  endif // _WIN32

typedef struct _pdfio_array_s pdfio_array_t;
					// Array of PDF values
typedef struct _pdfio_dict_s pdfio_dict_t;
					// Key/value dictionary
typedef bool (*pdfio_dict_cb_t)(pdfio_dict_t *dict, const char *key, void *cb_data);
					// Dictionary iterator callback
typedef struct _pdfio_file_s pdfio_file_t;
					// PDF file
typedef bool (*pdfio_error_cb_t)(pdfio_file_t *pdf, const char *message, void *data);
					// Error callback
typedef enum pdfio_encryption_e		// PDF encryption modes
{
  PDFIO_ENCRYPTION_NONE = 0,		// No encryption
  PDFIO_ENCRYPTION_RC4_40,		// 40-bit RC4 encryption (PDF 1.3)
  PDFIO_ENCRYPTION_RC4_128,		// 128-bit RC4 encryption (PDF 1.4)
  PDFIO_ENCRYPTION_AES_128,		// 128-bit AES encryption (PDF 1.6)
  PDFIO_ENCRYPTION_AES_256		// 256-bit AES encryption (PDF 2.0) @exclude all@
} pdfio_encryption_t;
typedef enum pdfio_filter_e		// Compression/decompression filters for streams
{
  PDFIO_FILTER_NONE,			// No filter
  PDFIO_FILTER_ASCIIHEX,		// ASCIIHexDecode filter (reading only)
  PDFIO_FILTER_ASCII85,			// ASCII85Decode filter (reading only)
  PDFIO_FILTER_CCITTFAX,		// CCITTFaxDecode filter
  PDFIO_FILTER_CRYPT,			// Encryption filter
  PDFIO_FILTER_DCT,			// DCTDecode (JPEG) filter
  PDFIO_FILTER_FLATE,			// FlateDecode filter
  PDFIO_FILTER_JBIG2,			// JBIG2Decode filter
  PDFIO_FILTER_JPX,			// JPXDecode filter (reading only)
  PDFIO_FILTER_LZW,			// LZWDecode filter (reading only)
  PDFIO_FILTER_RUNLENGTH,		// RunLengthDecode filter (reading only)
} pdfio_filter_t;
typedef struct _pdfio_obj_s pdfio_obj_t;// Numbered object in PDF file
typedef ssize_t (*pdfio_output_cb_t)(void *ctx, const void *data, size_t datalen);
					// Output callback for pdfioFileCreateOutput
typedef const char *(*pdfio_password_cb_t)(void *data, const char *filename);
					// Password callback for pdfioFileOpen
enum pdfio_permission_e			// PDF permission bits
{
  PDFIO_PERMISSION_NONE = 0,		// No permissions
  PDFIO_PERMISSION_PRINT = 0x0004,	// PDF allows printing
  PDFIO_PERMISSION_MODIFY = 0x0008,	// PDF allows modification
  PDFIO_PERMISSION_COPY = 0x0010,	// PDF allows copying
  PDFIO_PERMISSION_ANNOTATE = 0x0020,	// PDF allows annotation
  PDFIO_PERMISSION_FORMS = 0x0100,	// PDF allows filling in forms
  PDFIO_PERMISSION_READING = 0x0200,	// PDF allows screen reading/accessibility (deprecated in PDF 2.0)
  PDFIO_PERMISSION_ASSEMBLE = 0x0400,	// PDF allows assembly (insert, delete, or rotate pages, add document outlines and thumbnails)
  PDFIO_PERMISSION_PRINT_HIGH = 0x0800,	// PDF allows high quality printing
  PDFIO_PERMISSION_ALL = ~0		// All permissions
};
typedef int pdfio_permission_t;		// PDF permission bitfield
typedef struct pdfio_rect_s		// PDF rectangle
{
  double	x1;			// Lower-left X coordinate
  double	y1;			// Lower-left Y coordinate
  double	x2;			// Upper-right X coordinate
  double	y2;			// Upper-right Y coordinate
} pdfio_rect_t;
typedef struct _pdfio_stream_s pdfio_stream_t;
					// Object data stream in PDF file
typedef enum pdfio_valtype_e		// PDF value types
{
  PDFIO_VALTYPE_NONE,			// No value, not set
  PDFIO_VALTYPE_ARRAY,			// Array
  PDFIO_VALTYPE_BINARY,			// Binary data
  PDFIO_VALTYPE_BOOLEAN,		// Boolean
  PDFIO_VALTYPE_DATE,			// Date/time
  PDFIO_VALTYPE_DICT,			// Dictionary
  PDFIO_VALTYPE_INDIRECT,		// Indirect object (N G obj)
  PDFIO_VALTYPE_NAME,			// Name
  PDFIO_VALTYPE_NULL,			// Null object
  PDFIO_VALTYPE_NUMBER,			// Number (integer or real)
  PDFIO_VALTYPE_STRING			// String
} pdfio_valtype_t;


//
// Functions...
//

extern bool		pdfioArrayAppendArray(pdfio_array_t *a, pdfio_array_t *value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendBinary(pdfio_array_t *a, const unsigned char *value, size_t valuelen) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendBoolean(pdfio_array_t *a, bool value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendDate(pdfio_array_t *a, time_t value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendDict(pdfio_array_t *a, pdfio_dict_t *value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendName(pdfio_array_t *a, const char *value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendNumber(pdfio_array_t *a, double value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendObj(pdfio_array_t *a, pdfio_obj_t *value) _PDFIO_PUBLIC;
extern bool		pdfioArrayAppendString(pdfio_array_t *a, const char *value) _PDFIO_PUBLIC;
extern pdfio_array_t	*pdfioArrayCopy(pdfio_file_t *pdf, pdfio_array_t *a) _PDFIO_PUBLIC;
extern pdfio_array_t	*pdfioArrayCreate(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_array_t	*pdfioArrayGetArray(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern unsigned char	*pdfioArrayGetBinary(pdfio_array_t *a, size_t n, size_t *length) _PDFIO_PUBLIC;
extern bool		pdfioArrayGetBoolean(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern time_t		pdfioArrayGetDate(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern pdfio_dict_t	*pdfioArrayGetDict(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern const char	*pdfioArrayGetName(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern double		pdfioArrayGetNumber(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioArrayGetObj(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern size_t		pdfioArrayGetSize(pdfio_array_t *a) _PDFIO_PUBLIC;
extern const char	*pdfioArrayGetString(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern pdfio_valtype_t	pdfioArrayGetType(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;
extern bool		pdfioArrayRemove(pdfio_array_t *a, size_t n) _PDFIO_PUBLIC;

extern bool		pdfioDictClear(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern pdfio_dict_t	*pdfioDictCopy(pdfio_file_t *pdf, pdfio_dict_t *dict) _PDFIO_PUBLIC;
extern pdfio_dict_t	*pdfioDictCreate(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_array_t	*pdfioDictGetArray(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern unsigned char	*pdfioDictGetBinary(pdfio_dict_t *dict, const char *key, size_t *length) _PDFIO_PUBLIC;
extern bool		pdfioDictGetBoolean(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern time_t		pdfioDictGetDate(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern pdfio_dict_t	*pdfioDictGetDict(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern const char	*pdfioDictGetKey(pdfio_dict_t *dict, size_t n) _PDFIO_PUBLIC;
extern const char	*pdfioDictGetName(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern size_t		pdfioDictGetNumPairs(pdfio_dict_t *dict) _PDFIO_PUBLIC;
extern double		pdfioDictGetNumber(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioDictGetObj(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern pdfio_rect_t	*pdfioDictGetRect(pdfio_dict_t *dict, const char *key, pdfio_rect_t *rect) _PDFIO_PUBLIC;
extern const char	*pdfioDictGetString(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern pdfio_valtype_t	pdfioDictGetType(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern void		pdfioDictIterateKeys(pdfio_dict_t *dict, pdfio_dict_cb_t cb, void *cb_data) _PDFIO_PUBLIC;
extern bool		pdfioDictSetArray(pdfio_dict_t *dict, const char *key, pdfio_array_t *value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetBinary(pdfio_dict_t *dict, const char *key, const unsigned char *value, size_t valuelen) _PDFIO_PUBLIC;
extern bool		pdfioDictSetBoolean(pdfio_dict_t *dict, const char *key, bool value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetDate(pdfio_dict_t *dict, const char *key, time_t value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetDict(pdfio_dict_t *dict, const char *key, pdfio_dict_t *value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetName(pdfio_dict_t *dict, const char *key, const char *value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetNull(pdfio_dict_t *dict, const char *key) _PDFIO_PUBLIC;
extern bool		pdfioDictSetNumber(pdfio_dict_t *dict, const char *key, double value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetObj(pdfio_dict_t *dict, const char *key, pdfio_obj_t *value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetRect(pdfio_dict_t *dict, const char *key, pdfio_rect_t *value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetString(pdfio_dict_t *dict, const char *key, const char *value) _PDFIO_PUBLIC;
extern bool		pdfioDictSetStringf(pdfio_dict_t *dict, const char *key, const char *format, ...) _PDFIO_PUBLIC _PDFIO_FORMAT(3,4);

extern bool		pdfioFileClose(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_file_t	*pdfioFileCreate(const char *filename, const char *version, pdfio_rect_t *media_box, pdfio_rect_t *crop_box, pdfio_error_cb_t error_cb, void *error_data) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileCreateArrayObj(pdfio_file_t *pdf, pdfio_array_t *array) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileCreateNameObj(pdfio_file_t *pdf, const char *name) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileCreateNumberObj(pdfio_file_t *pdf, double number) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileCreateObj(pdfio_file_t *pdf, pdfio_dict_t *dict) _PDFIO_PUBLIC;
extern pdfio_file_t	*pdfioFileCreateOutput(pdfio_output_cb_t output_cb, void *output_ctx, const char *version, pdfio_rect_t *media_box, pdfio_rect_t *crop_box, pdfio_error_cb_t error_cb, void *error_data) _PDFIO_PUBLIC;
// TODO: Add number, array, string, etc. versions of pdfioFileCreateObject?
extern pdfio_stream_t	*pdfioFileCreatePage(pdfio_file_t *pdf, pdfio_dict_t *dict) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileCreateStringObj(pdfio_file_t *pdf, const char *s) _PDFIO_PUBLIC;
extern pdfio_file_t	*pdfioFileCreateTemporary(char *buffer, size_t bufsize, const char *version, pdfio_rect_t *media_box, pdfio_rect_t *crop_box, pdfio_error_cb_t error_cb, void *error_data) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileFindObj(pdfio_file_t *pdf, size_t number) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetAuthor(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_dict_t	*pdfioFileGetCatalog(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern time_t		pdfioFileGetCreationDate(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetCreator(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_array_t	*pdfioFileGetID(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetKeywords(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetName(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern size_t		pdfioFileGetNumObjs(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern size_t		pdfioFileGetNumPages(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileGetObj(pdfio_file_t *pdf, size_t n) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioFileGetPage(pdfio_file_t *pdf, size_t n) _PDFIO_PUBLIC;
extern pdfio_permission_t pdfioFileGetPermissions(pdfio_file_t *pdf, pdfio_encryption_t *encryption) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetProducer(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetSubject(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetTitle(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern const char	*pdfioFileGetVersion(pdfio_file_t *pdf) _PDFIO_PUBLIC;
extern pdfio_file_t	*pdfioFileOpen(const char *filename, pdfio_password_cb_t password_cb, void *password_data, pdfio_error_cb_t error_cb, void *error_data) _PDFIO_PUBLIC;
extern void		pdfioFileSetAuthor(pdfio_file_t *pdf, const char *value) _PDFIO_PUBLIC;
extern void		pdfioFileSetCreationDate(pdfio_file_t *pdf, time_t value) _PDFIO_PUBLIC;
extern void		pdfioFileSetCreator(pdfio_file_t *pdf, const char *value) _PDFIO_PUBLIC;
extern void		pdfioFileSetKeywords(pdfio_file_t *pdf, const char *value) _PDFIO_PUBLIC;
extern bool		pdfioFileSetPermissions(pdfio_file_t *pdf, pdfio_permission_t permissions, pdfio_encryption_t encryption, const char *owner_password, const char *user_password) _PDFIO_PUBLIC;
extern void		pdfioFileSetSubject(pdfio_file_t *pdf, const char *value) _PDFIO_PUBLIC;
extern void		pdfioFileSetTitle(pdfio_file_t *pdf, const char *value) _PDFIO_PUBLIC;

extern bool		pdfioObjClose(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern pdfio_obj_t	*pdfioObjCopy(pdfio_file_t *pdf, pdfio_obj_t *srcobj) _PDFIO_PUBLIC;
extern pdfio_stream_t	*pdfioObjCreateStream(pdfio_obj_t *obj, pdfio_filter_t compression) _PDFIO_PUBLIC;
extern pdfio_array_t	*pdfioObjGetArray(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern pdfio_dict_t	*pdfioObjGetDict(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern unsigned short	pdfioObjGetGeneration(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern size_t		pdfioObjGetLength(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern const char	*pdfioObjGetName(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern size_t		pdfioObjGetNumber(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern const char	*pdfioObjGetSubtype(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern const char	*pdfioObjGetType(pdfio_obj_t *obj) _PDFIO_PUBLIC;
extern pdfio_stream_t	*pdfioObjOpenStream(pdfio_obj_t *obj, bool decode) _PDFIO_PUBLIC;

extern bool		pdfioPageCopy(pdfio_file_t *pdf, pdfio_obj_t *srcpage) _PDFIO_PUBLIC;
extern size_t		pdfioPageGetNumStreams(pdfio_obj_t *page) _PDFIO_PUBLIC;
extern pdfio_stream_t	*pdfioPageOpenStream(pdfio_obj_t *page, size_t n, bool decode) _PDFIO_PUBLIC;

extern bool		pdfioStreamClose(pdfio_stream_t *st) _PDFIO_PUBLIC;
extern bool		pdfioStreamConsume(pdfio_stream_t *st, size_t bytes) _PDFIO_PUBLIC;
extern bool		pdfioStreamGetToken(pdfio_stream_t *st, char *buffer, size_t bufsize) _PDFIO_PUBLIC;
extern ssize_t		pdfioStreamPeek(pdfio_stream_t *st, void *buffer, size_t bytes) _PDFIO_PUBLIC;
extern bool		pdfioStreamPrintf(pdfio_stream_t *st, const char *format, ...) _PDFIO_PUBLIC _PDFIO_FORMAT(2,3);
extern bool		pdfioStreamPutChar(pdfio_stream_t *st, int ch) _PDFIO_PUBLIC;
extern bool		pdfioStreamPuts(pdfio_stream_t *st, const char *s) _PDFIO_PUBLIC;
extern ssize_t		pdfioStreamRead(pdfio_stream_t *st, void *buffer, size_t bytes) _PDFIO_PUBLIC;
extern bool		pdfioStreamWrite(pdfio_stream_t *st, const void *buffer, size_t bytes) _PDFIO_PUBLIC;

extern char		*pdfioStringCreate(pdfio_file_t *pdf, const char *s)  _PDFIO_PUBLIC;
extern char		*pdfioStringCreatef(pdfio_file_t *pdf, const char *format, ...) _PDFIO_FORMAT(2,3) _PDFIO_PUBLIC;


#  ifdef __cplusplus
}
#  endif // __cplusplus
#endif // !PDFIO_H
