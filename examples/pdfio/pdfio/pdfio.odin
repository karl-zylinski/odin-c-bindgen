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

array_t :: struct {}

// Array of PDF values
dict_t :: struct {}

// Key/value dictionary
dict_cb_t :: proc "c" (^dict_t, cstring, rawptr) -> bool

// Dictionary iterator callback
file_t :: struct {}

// PDF file
error_cb_t :: proc "c" (^file_t, cstring, rawptr) -> bool

// Error callback
encryption_t :: enum c.int {
	NONE = 0, // No encryption
	RC4_40,   // 40-bit RC4 encryption (PDF 1.3)
	RC4_128,  // 128-bit RC4 encryption (PDF 1.4)
	AES_128,  // 128-bit AES encryption (PDF 1.6)
	AES_256,  // 256-bit AES encryption (PDF 2.0) @exclude all@
}

filter_t :: enum c.int {
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

obj_t :: struct {} // Numbered object in PDF file

output_cb_t :: proc "c" (rawptr, rawptr, uint) -> int

// Output callback for pdfioFileCreateOutput
password_cb_t :: proc "c" (rawptr, cstring) -> cstring

// Password callback for pdfioFileOpen
permission_e :: enum c.int {
	PRINT      = 2,  // PDF allows printing
	MODIFY     = 3,  // PDF allows modification
	COPY       = 4,  // PDF allows copying
	ANNOTATE   = 5,  // PDF allows annotation
	FORMS      = 8,  // PDF allows filling in forms
	READING    = 9,  // PDF allows screen reading/accessibility (deprecated in PDF 2.0)
	ASSEMBLE   = 10, // PDF allows assembly (insert, delete, or rotate pages, add document outlines and thumbnails)
	PRINT_HIGH = 11, // PDF allows high quality printing
}

permission_t :: distinct bit_set[permission_e; c.int]

PERMISSION_ALL :: permission_t { .PRINT, .MODIFY, .COPY, .ANNOTATE, .FORMS, .READING, .ASSEMBLE, .PRINT_HIGH }

rect_t :: struct {
	x1: f64, // Lower-left X coordinate
	y1: f64, // Lower-left Y coordinate
	x2: f64, // Upper-right X coordinate
	y2: f64, // Upper-right Y coordinate
}

stream_t :: struct {}

// Object data stream in PDF file
valtype_t :: enum c.int {
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

@(default_calling_convention="c", link_prefix="pdfio")
foreign lib {
	// Functions...
	ArrayAppendArray    :: proc(a: ^array_t, value: ^array_t) -> bool ---
	ArrayAppendBinary   :: proc(a: ^array_t, value: [^]u8, valuelen: uint) -> bool ---
	ArrayAppendBoolean  :: proc(a: ^array_t, value: bool) -> bool ---
	ArrayAppendDate     :: proc(a: ^array_t, value: libc.time_t) -> bool ---
	ArrayAppendDict     :: proc(a: ^array_t, value: ^dict_t) -> bool ---
	ArrayAppendName     :: proc(a: ^array_t, value: cstring) -> bool ---
	ArrayAppendNumber   :: proc(a: ^array_t, value: f64) -> bool ---
	ArrayAppendObj      :: proc(a: ^array_t, value: ^obj_t) -> bool ---
	ArrayAppendString   :: proc(a: ^array_t, value: cstring) -> bool ---
	ArrayCopy           :: proc(pdf: ^file_t, a: ^array_t) -> ^array_t ---
	ArrayCreate         :: proc(pdf: ^file_t) -> ^array_t ---
	ArrayGetArray       :: proc(a: ^array_t, n: uint) -> ^array_t ---
	ArrayGetBinary      :: proc(a: ^array_t, n: uint, length: ^uint) -> [^]u8 ---
	ArrayGetBoolean     :: proc(a: ^array_t, n: uint) -> bool ---
	ArrayGetDate        :: proc(a: ^array_t, n: uint) -> libc.time_t ---
	ArrayGetDict        :: proc(a: ^array_t, n: uint) -> ^dict_t ---
	ArrayGetName        :: proc(a: ^array_t, n: uint) -> cstring ---
	ArrayGetNumber      :: proc(a: ^array_t, n: uint) -> f64 ---
	ArrayGetObj         :: proc(a: ^array_t, n: uint) -> ^obj_t ---
	ArrayGetSize        :: proc(a: ^array_t) -> uint ---
	ArrayGetString      :: proc(a: ^array_t, n: uint) -> cstring ---
	ArrayGetType        :: proc(a: ^array_t, n: uint) -> valtype_t ---
	ArrayRemove         :: proc(a: ^array_t, n: uint) -> bool ---
	DictClear           :: proc(dict: ^dict_t, key: cstring) -> bool ---
	DictCopy            :: proc(pdf: ^file_t, dict: ^dict_t) -> ^dict_t ---
	DictCreate          :: proc(pdf: ^file_t) -> ^dict_t ---
	DictGetArray        :: proc(dict: ^dict_t, key: cstring) -> ^array_t ---
	DictGetBinary       :: proc(dict: ^dict_t, key: cstring, length: ^uint) -> ^u8 ---
	DictGetBoolean      :: proc(dict: ^dict_t, key: cstring) -> bool ---
	DictGetDate         :: proc(dict: ^dict_t, key: cstring) -> libc.time_t ---
	DictGetDict         :: proc(dict: ^dict_t, key: cstring) -> ^dict_t ---
	DictGetKey          :: proc(dict: ^dict_t, n: uint) -> cstring ---
	DictGetName         :: proc(dict: ^dict_t, key: cstring) -> cstring ---
	DictGetNumPairs     :: proc(dict: ^dict_t) -> uint ---
	DictGetNumber       :: proc(dict: ^dict_t, key: cstring) -> f64 ---
	DictGetObj          :: proc(dict: ^dict_t, key: cstring) -> ^obj_t ---
	DictGetRect         :: proc(dict: ^dict_t, key: cstring, rect: ^rect_t) -> ^rect_t ---
	DictGetString       :: proc(dict: ^dict_t, key: cstring) -> cstring ---
	DictGetType         :: proc(dict: ^dict_t, key: cstring) -> valtype_t ---
	DictIterateKeys     :: proc(dict: ^dict_t, cb: dict_cb_t, cb_data: rawptr) ---
	DictSetArray        :: proc(dict: ^dict_t, key: cstring, value: ^array_t) -> bool ---
	DictSetBinary       :: proc(dict: ^dict_t, key: cstring, value: ^u8, valuelen: uint) -> bool ---
	DictSetBoolean      :: proc(dict: ^dict_t, key: cstring, value: bool) -> bool ---
	DictSetDate         :: proc(dict: ^dict_t, key: cstring, value: libc.time_t) -> bool ---
	DictSetDict         :: proc(dict: ^dict_t, key: cstring, value: ^dict_t) -> bool ---
	DictSetName         :: proc(dict: ^dict_t, key: cstring, value: cstring) -> bool ---
	DictSetNull         :: proc(dict: ^dict_t, key: cstring) -> bool ---
	DictSetNumber       :: proc(dict: ^dict_t, key: cstring, value: f64) -> bool ---
	DictSetObj          :: proc(dict: ^dict_t, key: cstring, value: ^obj_t) -> bool ---
	DictSetRect         :: proc(dict: ^dict_t, key: cstring, value: ^rect_t) -> bool ---
	DictSetString       :: proc(dict: ^dict_t, key: cstring, value: cstring) -> bool ---
	DictSetStringf      :: proc(dict: ^dict_t, key: cstring, format: cstring) -> bool ---
	FileClose           :: proc(pdf: ^file_t) -> bool ---
	FileCreate          :: proc(filename: cstring, version: cstring, media_box: ^rect_t, crop_box: ^rect_t, error_cb: error_cb_t, error_data: rawptr) -> ^file_t ---
	FileCreateArrayObj  :: proc(pdf: ^file_t, array: ^array_t) -> ^obj_t ---
	FileCreateNameObj   :: proc(pdf: ^file_t, name: cstring) -> ^obj_t ---
	FileCreateNumberObj :: proc(pdf: ^file_t, number: f64) -> ^obj_t ---
	FileCreateObj       :: proc(pdf: ^file_t, dict: ^dict_t) -> ^obj_t ---
	FileCreateOutput    :: proc(output_cb: output_cb_t, output_ctx: rawptr, version: cstring, media_box: ^rect_t, crop_box: ^rect_t, error_cb: error_cb_t, error_data: rawptr) -> ^file_t ---

	// TODO: Add number, array, string, etc. versions of pdfioFileCreateObject?
	FileCreatePage      :: proc(pdf: ^file_t, dict: ^dict_t) -> ^stream_t ---
	FileCreateStringObj :: proc(pdf: ^file_t, s: cstring) -> ^obj_t ---
	FileCreateTemporary :: proc(buffer: [^]cstring, bufsize: uint, version: cstring, media_box: ^rect_t, crop_box: ^rect_t, error_cb: error_cb_t, error_data: rawptr) -> ^file_t ---
	FileFindObj         :: proc(pdf: ^file_t, number: uint) -> ^obj_t ---
	FileGetAuthor       :: proc(pdf: ^file_t) -> cstring ---
	FileGetCatalog      :: proc(pdf: ^file_t) -> ^dict_t ---
	FileGetCreationDate :: proc(pdf: ^file_t) -> libc.time_t ---
	FileGetCreator      :: proc(pdf: ^file_t) -> cstring ---
	FileGetID           :: proc(pdf: ^file_t) -> ^array_t ---
	FileGetKeywords     :: proc(pdf: ^file_t) -> cstring ---
	FileGetName         :: proc(pdf: ^file_t) -> cstring ---
	FileGetNumObjs      :: proc(pdf: ^file_t) -> uint ---
	FileGetNumPages     :: proc(pdf: ^file_t) -> uint ---
	FileGetObj          :: proc(pdf: ^file_t, n: uint) -> ^obj_t ---
	FileGetPage         :: proc(pdf: ^file_t, n: uint) -> ^obj_t ---
	FileGetPermissions  :: proc(pdf: ^file_t, encryption: ^encryption_t) -> permission_t ---
	FileGetProducer     :: proc(pdf: ^file_t) -> cstring ---
	FileGetSubject      :: proc(pdf: ^file_t) -> cstring ---
	FileGetTitle        :: proc(pdf: ^file_t) -> cstring ---
	FileGetVersion      :: proc(pdf: ^file_t) -> cstring ---
	FileOpen            :: proc(filename: cstring, password_cb: password_cb_t, password_data: rawptr, error_cb: error_cb_t, error_data: rawptr) -> ^file_t ---
	FileSetAuthor       :: proc(pdf: ^file_t, value: cstring) ---
	FileSetCreationDate :: proc(pdf: ^file_t, value: libc.time_t) ---
	FileSetCreator      :: proc(pdf: ^file_t, value: cstring) ---
	FileSetKeywords     :: proc(pdf: ^file_t, value: cstring) ---
	FileSetPermissions  :: proc(pdf: ^file_t, permissions: permission_t, encryption: encryption_t, owner_password: cstring, user_password: cstring) -> bool ---
	FileSetSubject      :: proc(pdf: ^file_t, value: cstring) ---
	FileSetTitle        :: proc(pdf: ^file_t, value: cstring) ---
	ObjClose            :: proc(obj: ^obj_t) -> bool ---
	ObjCopy             :: proc(pdf: ^file_t, srcobj: ^obj_t) -> ^obj_t ---
	ObjCreateStream     :: proc(obj: ^obj_t, compression: filter_t) -> ^stream_t ---
	ObjGetArray         :: proc(obj: ^obj_t) -> ^array_t ---
	ObjGetDict          :: proc(obj: ^obj_t) -> ^dict_t ---
	ObjGetGeneration    :: proc(obj: ^obj_t) -> u16 ---
	ObjGetLength        :: proc(obj: ^obj_t) -> uint ---
	ObjGetName          :: proc(obj: ^obj_t) -> cstring ---
	ObjGetNumber        :: proc(obj: ^obj_t) -> uint ---
	ObjGetSubtype       :: proc(obj: ^obj_t) -> cstring ---
	ObjGetType          :: proc(obj: ^obj_t) -> cstring ---
	ObjOpenStream       :: proc(obj: ^obj_t, decode: bool) -> ^stream_t ---
	PageCopy            :: proc(pdf: ^file_t, srcpage: ^obj_t) -> bool ---
	PageGetNumStreams   :: proc(page: ^obj_t) -> uint ---
	PageOpenStream      :: proc(page: ^obj_t, n: uint, decode: bool) -> ^stream_t ---
	StreamClose         :: proc(st: ^stream_t) -> bool ---
	StreamConsume       :: proc(st: ^stream_t, bytes: uint) -> bool ---
	StreamGetToken      :: proc(st: ^stream_t, buffer: [^]cstring, bufsize: uint) -> bool ---
	StreamPeek          :: proc(st: ^stream_t, buffer: rawptr, bytes: uint) -> int ---
	StreamPrintf        :: proc(st: ^stream_t, format: cstring) -> bool ---
	StreamPutChar       :: proc(st: ^stream_t, ch: i32) -> bool ---
	StreamPuts          :: proc(st: ^stream_t, s: cstring) -> bool ---
	StreamRead          :: proc(st: ^stream_t, buffer: rawptr, bytes: uint) -> int ---
	StreamWrite         :: proc(st: ^stream_t, buffer: rawptr, bytes: uint) -> bool ---
	StringCreate        :: proc(pdf: ^file_t, s: cstring) -> cstring ---
	StringCreatef       :: proc(pdf: ^file_t, format: cstring) -> cstring ---
}
