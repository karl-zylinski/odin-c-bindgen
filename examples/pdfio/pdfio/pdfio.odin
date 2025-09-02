//
// Public header file for PDFio.
//
// Copyright © 2021-2025 by Michael R Sweet.
//
// Licensed under Apache License v2.0.  See the file "LICENSE" for more
// information.
//
package pdfio

import "core:c"
import "core:c/libc"

_ :: c
_ :: libc

foreign import lib "pdfio1.lib"

// PDFIO_H :: 

//
// Version number...
//
PDFIO_VERSION  :: "1.4.1"

// PDFIO_PUBLIC :: ((visibility("default")))
// PDFIO_DEPRECATED :: ((deprecated))PDFIO_PUBLIC

array_t :: struct {}

// Array of PDF values
dict_t :: struct {}

// Key/value dictionary
dict_cb_t :: proc "c" (^pdfio_dict_s, cstring, rawptr) -> bool

// Dictionary iterator callback
file_t :: struct {}

// PDF file
error_cb_t :: proc "c" (^pdfio_file_s, cstring, rawptr) -> bool

// Error callback
encryption_e :: enum i32 {
	NONE,    // No encryption
	RC4_40,  // 40-bit RC4 encryption (PDF 1.3)
	RC4_128, // 128-bit RC4 encryption (PDF 1.4)
	AES_128, // 128-bit AES encryption (PDF 1.6)
	AES_256, // 256-bit AES encryption (PDF 2.0) @exclude all@
}

// Error callback
encryption_t :: encryption_e // PDF encryption modes

filter_e :: enum i32 {
	NONE,      // No filter
	ASCIIHEX,  // ASCIIHexDecode filter (reading only)
	ASCII85,   // ASCII85Decode filter (reading only)
	CCITTFAX,  // CCITTFaxDecode filter
	CRYPT,     // Encryption filter
	DCT,       // DCTDecode (JPEG) filter
	FLATE,     // FlateDecode filter
	JBIG2,     // JBIG2Decode filter
	JPX,       // JPXDecode filter (reading only)
	LZW,       // LZWDecode filter (reading only)
	RUNLENGTH, // RunLengthDecode filter (reading only)
}

filter_t :: filter_e // Compression/decompression filters for streams

obj_t :: struct {} // Numbered object in PDF file

output_cb_t :: proc "c" (rawptr, rawptr, c.size_t) -> c.ssize_t

// Output callback for pdfioFileCreateOutput
password_cb_t :: proc "c" (rawptr, cstring) -> cstring

// Password callback for pdfioFileOpen
permission_e :: enum i32 {
	PRINT      = 2,  // PDF allows printing
	MODIFY     = 3,  // PDF allows modification
	COPY       = 4,  // PDF allows copying
	ANNOTATE   = 5,  // PDF allows annotation
	FORMS      = 8,  // PDF allows filling in forms
	READING    = 9,  // PDF allows screen reading/accessibility (deprecated in PDF 2.0)
	ASSEMBLE   = 10, // PDF allows assembly (insert, delete, or rotate pages, add document outlines and thumbnails)
	PRINT_HIGH = 11, // PDF allows high quality printing
}

permission_t :: distinct bit_set[permission_e; i32]

PERMISSION_ALL :: permission_t { .PRINT, .MODIFY, .COPY, .ANNOTATE, .FORMS, .READING, .ASSEMBLE, .PRINT_HIGH }

rect_s :: struct {
	x1: f64, // Lower-left X coordinate
	y1: f64, // Lower-left Y coordinate
	x2: f64, // Upper-right X coordinate
	y2: f64, // Upper-right Y coordinate
}

rect_t :: struct {} // PDF rectangle

stream_t :: struct {}

// Object data stream in PDF file
valtype_e :: enum i32 {
	NONE,     // No value, not set
	ARRAY,    // Array
	BINARY,   // Binary data
	BOOLEAN,  // Boolean
	DATE,     // Date/time
	DICT,     // Dictionary
	INDIRECT, // Indirect object (N G obj)
	NAME,     // Name
	NULL,     // Null object
	NUMBER,   // Number (integer or real)
	STRING,   // String
}

// Object data stream in PDF file
valtype_t :: valtype_e // PDF value types

@(default_calling_convention="c", link_prefix="pdfio")
foreign lib {
	//
	// Functions...
	//
	ArrayAppendArray    :: proc(a: ^pdfio_array_s, value: ^pdfio_array_s) -> bool ---
	ArrayAppendBinary   :: proc(a: ^pdfio_array_s, value: ^u8, valuelen: c.size_t) -> bool ---
	ArrayAppendBoolean  :: proc(a: ^pdfio_array_s, value: bool) -> bool ---
	ArrayAppendDate     :: proc(a: ^pdfio_array_s, value: libc.time_t) -> bool ---
	ArrayAppendDict     :: proc(a: ^pdfio_array_s, value: ^pdfio_dict_s) -> bool ---
	ArrayAppendName     :: proc(a: ^pdfio_array_s, value: cstring) -> bool ---
	ArrayAppendNumber   :: proc(a: ^pdfio_array_s, value: f64) -> bool ---
	ArrayAppendObj      :: proc(a: ^pdfio_array_s, value: ^pdfio_obj_s) -> bool ---
	ArrayAppendString   :: proc(a: ^pdfio_array_s, value: cstring) -> bool ---
	ArrayCopy           :: proc(pdf: ^pdfio_file_s, a: ^pdfio_array_s) -> ^pdfio_array_s ---
	ArrayCreate         :: proc(pdf: ^pdfio_file_s) -> ^pdfio_array_s ---
	ArrayGetArray       :: proc(a: ^pdfio_array_s, n: c.size_t) -> ^pdfio_array_s ---
	ArrayGetBinary      :: proc(a: ^pdfio_array_s, n: c.size_t, length: ^c.size_t) -> ^u8 ---
	ArrayGetBoolean     :: proc(a: ^pdfio_array_s, n: c.size_t) -> bool ---
	ArrayGetDate        :: proc(a: ^pdfio_array_s, n: c.size_t) -> libc.time_t ---
	ArrayGetDict        :: proc(a: ^pdfio_array_s, n: c.size_t) -> ^pdfio_dict_s ---
	ArrayGetName        :: proc(a: ^pdfio_array_s, n: c.size_t) -> cstring ---
	ArrayGetNumber      :: proc(a: ^pdfio_array_s, n: c.size_t) -> f64 ---
	ArrayGetObj         :: proc(a: ^pdfio_array_s, n: c.size_t) -> ^pdfio_obj_s ---
	ArrayGetSize        :: proc(a: ^pdfio_array_s) -> c.size_t ---
	ArrayGetString      :: proc(a: ^pdfio_array_s, n: c.size_t) -> cstring ---
	ArrayGetType        :: proc(a: ^pdfio_array_s, n: c.size_t) -> valtype_e ---
	ArrayRemove         :: proc(a: ^pdfio_array_s, n: c.size_t) -> bool ---
	DictClear           :: proc(dict: ^pdfio_dict_s, key: cstring) -> bool ---
	DictCopy            :: proc(pdf: ^pdfio_file_s, dict: ^pdfio_dict_s) -> ^pdfio_dict_s ---
	DictCreate          :: proc(pdf: ^pdfio_file_s) -> ^pdfio_dict_s ---
	DictGetArray        :: proc(dict: ^pdfio_dict_s, key: cstring) -> ^pdfio_array_s ---
	DictGetBinary       :: proc(dict: ^pdfio_dict_s, key: cstring, length: ^c.size_t) -> ^u8 ---
	DictGetBoolean      :: proc(dict: ^pdfio_dict_s, key: cstring) -> bool ---
	DictGetDate         :: proc(dict: ^pdfio_dict_s, key: cstring) -> libc.time_t ---
	DictGetDict         :: proc(dict: ^pdfio_dict_s, key: cstring) -> ^pdfio_dict_s ---
	DictGetKey          :: proc(dict: ^pdfio_dict_s, n: c.size_t) -> cstring ---
	DictGetName         :: proc(dict: ^pdfio_dict_s, key: cstring) -> cstring ---
	DictGetNumPairs     :: proc(dict: ^pdfio_dict_s) -> c.size_t ---
	DictGetNumber       :: proc(dict: ^pdfio_dict_s, key: cstring) -> f64 ---
	DictGetObj          :: proc(dict: ^pdfio_dict_s, key: cstring) -> ^pdfio_obj_s ---
	DictGetRect         :: proc(dict: ^pdfio_dict_s, key: cstring, rect: ^rect_s) -> ^rect_s ---
	DictGetString       :: proc(dict: ^pdfio_dict_s, key: cstring) -> cstring ---
	DictGetType         :: proc(dict: ^pdfio_dict_s, key: cstring) -> valtype_e ---
	DictIterateKeys     :: proc(dict: ^pdfio_dict_s, cb: proc "c" (^pdfio_dict_s, cstring, rawptr) -> bool, cb_data: rawptr) ---
	DictSetArray        :: proc(dict: ^pdfio_dict_s, key: cstring, value: ^pdfio_array_s) -> bool ---
	DictSetBinary       :: proc(dict: ^pdfio_dict_s, key: cstring, value: ^u8, valuelen: c.size_t) -> bool ---
	DictSetBoolean      :: proc(dict: ^pdfio_dict_s, key: cstring, value: bool) -> bool ---
	DictSetDate         :: proc(dict: ^pdfio_dict_s, key: cstring, value: libc.time_t) -> bool ---
	DictSetDict         :: proc(dict: ^pdfio_dict_s, key: cstring, value: ^pdfio_dict_s) -> bool ---
	DictSetName         :: proc(dict: ^pdfio_dict_s, key: cstring, value: cstring) -> bool ---
	DictSetNull         :: proc(dict: ^pdfio_dict_s, key: cstring) -> bool ---
	DictSetNumber       :: proc(dict: ^pdfio_dict_s, key: cstring, value: f64) -> bool ---
	DictSetObj          :: proc(dict: ^pdfio_dict_s, key: cstring, value: ^pdfio_obj_s) -> bool ---
	DictSetRect         :: proc(dict: ^pdfio_dict_s, key: cstring, value: ^rect_s) -> bool ---
	DictSetString       :: proc(dict: ^pdfio_dict_s, key: cstring, value: cstring) -> bool ---
	DictSetStringf      :: proc(dict: ^pdfio_dict_s, key: cstring, format: cstring, #c_vararg _: ..any) -> bool ---
	FileClose           :: proc(pdf: ^pdfio_file_s) -> bool ---
	FileCreate          :: proc(filename: cstring, version: cstring, media_box: ^rect_s, crop_box: ^rect_s, error_cb: proc "c" (^pdfio_file_s, cstring, rawptr) -> bool, error_data: rawptr) -> ^pdfio_file_s ---
	FileCreateArrayObj  :: proc(pdf: ^pdfio_file_s, array: ^pdfio_array_s) -> ^pdfio_obj_s ---
	FileCreateNameObj   :: proc(pdf: ^pdfio_file_s, name: cstring) -> ^pdfio_obj_s ---
	FileCreateNumberObj :: proc(pdf: ^pdfio_file_s, number: f64) -> ^pdfio_obj_s ---
	FileCreateObj       :: proc(pdf: ^pdfio_file_s, dict: ^pdfio_dict_s) -> ^pdfio_obj_s ---
	FileCreateOutput    :: proc(output_cb: proc "c" (rawptr, rawptr, u64) -> i64, output_ctx: rawptr, version: cstring, media_box: ^rect_s, crop_box: ^rect_s, error_cb: proc "c" (^pdfio_file_s, cstring, rawptr) -> bool, error_data: rawptr) -> ^pdfio_file_s ---

	// TODO: Add number, array, string, etc. versions of pdfioFileCreateObject?
	FileCreatePage      :: proc(pdf: ^pdfio_file_s, dict: ^pdfio_dict_s) -> ^pdfio_stream_s ---
	FileCreateStringObj :: proc(pdf: ^pdfio_file_s, s: cstring) -> ^pdfio_obj_s ---
	FileCreateTemporary :: proc(buffer: [^]c.char, bufsize: c.size_t, version: cstring, media_box: ^rect_s, crop_box: ^rect_s, error_cb: proc "c" (^pdfio_file_s, cstring, rawptr) -> bool, error_data: rawptr) -> ^pdfio_file_s ---
	FileFindObj         :: proc(pdf: ^pdfio_file_s, number: c.size_t) -> ^pdfio_obj_s ---
	FileGetAuthor       :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetCatalog      :: proc(pdf: ^pdfio_file_s) -> ^pdfio_dict_s ---
	FileGetCreationDate :: proc(pdf: ^pdfio_file_s) -> libc.time_t ---
	FileGetCreator      :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetID           :: proc(pdf: ^pdfio_file_s) -> ^pdfio_array_s ---
	FileGetKeywords     :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetName         :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetNumObjs      :: proc(pdf: ^pdfio_file_s) -> c.size_t ---
	FileGetNumPages     :: proc(pdf: ^pdfio_file_s) -> c.size_t ---
	FileGetObj          :: proc(pdf: ^pdfio_file_s, n: c.size_t) -> ^pdfio_obj_s ---
	FileGetPage         :: proc(pdf: ^pdfio_file_s, n: c.size_t) -> ^pdfio_obj_s ---
	FileGetPermissions  :: proc(pdf: ^pdfio_file_s, encryption: ^encryption_e) -> i32 ---
	FileGetProducer     :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetSubject      :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetTitle        :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileGetVersion      :: proc(pdf: ^pdfio_file_s) -> cstring ---
	FileOpen            :: proc(filename: cstring, password_cb: proc "c" (rawptr, cstring) -> cstring, password_data: rawptr, error_cb: proc "c" (^pdfio_file_s, cstring, rawptr) -> bool, error_data: rawptr) -> ^pdfio_file_s ---
	FileSetAuthor       :: proc(pdf: ^pdfio_file_s, value: cstring) ---
	FileSetCreationDate :: proc(pdf: ^pdfio_file_s, value: libc.time_t) ---
	FileSetCreator      :: proc(pdf: ^pdfio_file_s, value: cstring) ---
	FileSetKeywords     :: proc(pdf: ^pdfio_file_s, value: cstring) ---
	FileSetPermissions  :: proc(pdf: ^pdfio_file_s, permissions: i32, encryption: encryption_e, owner_password: cstring, user_password: cstring) -> bool ---
	FileSetSubject      :: proc(pdf: ^pdfio_file_s, value: cstring) ---
	FileSetTitle        :: proc(pdf: ^pdfio_file_s, value: cstring) ---
	ObjClose            :: proc(obj: ^pdfio_obj_s) -> bool ---
	ObjCopy             :: proc(pdf: ^pdfio_file_s, srcobj: ^pdfio_obj_s) -> ^pdfio_obj_s ---
	ObjCreateStream     :: proc(obj: ^pdfio_obj_s, compression: filter_e) -> ^pdfio_stream_s ---
	ObjGetArray         :: proc(obj: ^pdfio_obj_s) -> ^pdfio_array_s ---
	ObjGetDict          :: proc(obj: ^pdfio_obj_s) -> ^pdfio_dict_s ---
	ObjGetGeneration    :: proc(obj: ^pdfio_obj_s) -> u16 ---
	ObjGetLength        :: proc(obj: ^pdfio_obj_s) -> c.size_t ---
	ObjGetName          :: proc(obj: ^pdfio_obj_s) -> cstring ---
	ObjGetNumber        :: proc(obj: ^pdfio_obj_s) -> c.size_t ---
	ObjGetSubtype       :: proc(obj: ^pdfio_obj_s) -> cstring ---
	ObjGetType          :: proc(obj: ^pdfio_obj_s) -> cstring ---
	ObjOpenStream       :: proc(obj: ^pdfio_obj_s, decode: bool) -> ^pdfio_stream_s ---
	PageCopy            :: proc(pdf: ^pdfio_file_s, srcpage: ^pdfio_obj_s) -> bool ---
	PageGetNumStreams   :: proc(page: ^pdfio_obj_s) -> c.size_t ---
	PageOpenStream      :: proc(page: ^pdfio_obj_s, n: c.size_t, decode: bool) -> ^pdfio_stream_s ---
	StreamClose         :: proc(st: ^pdfio_stream_s) -> bool ---
	StreamConsume       :: proc(st: ^pdfio_stream_s, bytes: c.size_t) -> bool ---
	StreamGetToken      :: proc(st: ^pdfio_stream_s, buffer: [^]c.char, bufsize: c.size_t) -> bool ---
	StreamPeek          :: proc(st: ^pdfio_stream_s, buffer: rawptr, bytes: c.size_t) -> c.ssize_t ---
	StreamPrintf        :: proc(st: ^pdfio_stream_s, format: cstring, #c_vararg _: ..any) -> bool ---
	StreamPutChar       :: proc(st: ^pdfio_stream_s, ch: i32) -> bool ---
	StreamPuts          :: proc(st: ^pdfio_stream_s, s: cstring) -> bool ---
	StreamRead          :: proc(st: ^pdfio_stream_s, buffer: rawptr, bytes: c.size_t) -> c.ssize_t ---
	StreamWrite         :: proc(st: ^pdfio_stream_s, buffer: rawptr, bytes: c.size_t) -> bool ---
	StringCreate        :: proc(pdf: ^pdfio_file_s, s: cstring) -> cstring ---
	StringCreatef       :: proc(pdf: ^pdfio_file_s, format: cstring, #c_vararg _: ..any) -> cstring ---
}
