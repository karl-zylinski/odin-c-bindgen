//
// Public content header file for PDFio.
//
// Copyright © 2021-2023 by Michael R Sweet.
//
// Licensed under Apache License v2.0.  See the file "LICENSE" for more
// information.
//
package pdfio

import "core:c"

_ :: c

foreign import lib "pdfio1.lib"

// PDFIO_CONTENT_H :: 

//
// Types and constants...
//
cs_e :: enum i32 {
	ADOBE,  // AdobeRGB 1998
	P3_D65, // Display P3
	SRGB,   // sRGB
}

//
// Types and constants...
//
cs_t :: cs_e // Standard color spaces

linecap_e :: enum i32 {
	BUTT,   // Butt ends
	ROUND,  // Round ends
	SQUARE, // Square ends
}

linecap_t :: linecap_e // Line capping modes

linejoin_e :: enum i32 {
	MITER, // Miter joint
	ROUND, // Round joint
	BEVEL, // Bevel joint
}

linejoin_t :: linejoin_e // Line joining modes

matrix_t :: [3][2]f64 // Transform matrix

textrendering_e :: enum i32 {
	FILL,            // Fill text
	STROKE,          // Stroke text
	FILL_AND_STROKE, // Fill then stroke text
	INVISIBLE,       // Don't fill or stroke (invisible)
	FILL_PATH,       // Fill text and add to path
	STROKE_PATH,     // Stroke text and add to path
	FILL_AND_STROKE_PATH,
	TEXT_PATH,       // Add text to path (invisible)
}

textrendering_t :: textrendering_e // Text rendering modes

@(default_calling_convention="c", link_prefix="pdfio")
foreign lib {
	// Color array functions...
	ArrayCreateColorFromICCObj    :: proc(pdf: ^pdfio_file_s, icc_object: ^pdfio_obj_s) -> ^pdfio_array_s ---
	ArrayCreateColorFromMatrix    :: proc(pdf: ^pdfio_file_s, num_colors: c.size_t, gamma: f64, _matrix: [3][3]f64, white_point: [3]f64) -> ^pdfio_array_s ---
	ArrayCreateColorFromPalette   :: proc(pdf: ^pdfio_file_s, num_colors: c.size_t, colors: ^u8) -> ^pdfio_array_s ---
	ArrayCreateColorFromPrimaries :: proc(pdf: ^pdfio_file_s, num_colors: c.size_t, gamma: f64, wx: f64, wy: f64, rx: f64, ry: f64, gx: f64, gy: f64, bx: f64, by: f64) -> ^pdfio_array_s ---
	ArrayCreateColorFromStandard  :: proc(pdf: ^pdfio_file_s, num_colors: c.size_t, cs: cs_e) -> ^pdfio_array_s ---

	// PDF content drawing functions...
	ContentClip                     :: proc(st: ^pdfio_stream_s, even_odd: bool) -> bool ---
	ContentDrawImage                :: proc(st: ^pdfio_stream_s, name: cstring, x: f64, y: f64, w: f64, h: f64) -> bool ---
	ContentFill                     :: proc(st: ^pdfio_stream_s, even_odd: bool) -> bool ---
	ContentFillAndStroke            :: proc(st: ^pdfio_stream_s, even_odd: bool) -> bool ---
	ContentMatrixConcat             :: proc(st: ^pdfio_stream_s, m: [3][2]f64) -> bool ---
	ContentMatrixRotate             :: proc(st: ^pdfio_stream_s, degrees: f64) -> bool ---
	ContentMatrixScale              :: proc(st: ^pdfio_stream_s, sx: f64, sy: f64) -> bool ---
	ContentMatrixTranslate          :: proc(st: ^pdfio_stream_s, tx: f64, ty: f64) -> bool ---
	ContentPathClose                :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentPathCurve                :: proc(st: ^pdfio_stream_s, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) -> bool ---
	ContentPathCurve13              :: proc(st: ^pdfio_stream_s, x1: f64, y1: f64, x3: f64, y3: f64) -> bool ---
	ContentPathCurve23              :: proc(st: ^pdfio_stream_s, x2: f64, y2: f64, x3: f64, y3: f64) -> bool ---
	ContentPathEnd                  :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentPathLineTo               :: proc(st: ^pdfio_stream_s, x: f64, y: f64) -> bool ---
	ContentPathMoveTo               :: proc(st: ^pdfio_stream_s, x: f64, y: f64) -> bool ---
	ContentPathRect                 :: proc(st: ^pdfio_stream_s, x: f64, y: f64, width: f64, height: f64) -> bool ---
	ContentRestore                  :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentSave                     :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentSetDashPattern           :: proc(st: ^pdfio_stream_s, phase: f64, on: f64, off: f64) -> bool ---
	ContentSetFillColorDeviceCMYK   :: proc(st: ^pdfio_stream_s, _c: f64, m: f64, y: f64, k: f64) -> bool ---
	ContentSetFillColorDeviceGray   :: proc(st: ^pdfio_stream_s, g: f64) -> bool ---
	ContentSetFillColorDeviceRGB    :: proc(st: ^pdfio_stream_s, r: f64, g: f64, b: f64) -> bool ---
	ContentSetFillColorGray         :: proc(st: ^pdfio_stream_s, g: f64) -> bool ---
	ContentSetFillColorRGB          :: proc(st: ^pdfio_stream_s, r: f64, g: f64, b: f64) -> bool ---
	ContentSetFillColorSpace        :: proc(st: ^pdfio_stream_s, name: cstring) -> bool ---
	ContentSetFlatness              :: proc(st: ^pdfio_stream_s, f: f64) -> bool ---
	ContentSetLineCap               :: proc(st: ^pdfio_stream_s, lc: linecap_e) -> bool ---
	ContentSetLineJoin              :: proc(st: ^pdfio_stream_s, lj: linejoin_e) -> bool ---
	ContentSetLineWidth             :: proc(st: ^pdfio_stream_s, width: f64) -> bool ---
	ContentSetMiterLimit            :: proc(st: ^pdfio_stream_s, limit: f64) -> bool ---
	ContentSetStrokeColorDeviceCMYK :: proc(st: ^pdfio_stream_s, _c: f64, m: f64, y: f64, k: f64) -> bool ---
	ContentSetStrokeColorDeviceGray :: proc(st: ^pdfio_stream_s, g: f64) -> bool ---
	ContentSetStrokeColorDeviceRGB  :: proc(st: ^pdfio_stream_s, r: f64, g: f64, b: f64) -> bool ---
	ContentSetStrokeColorGray       :: proc(st: ^pdfio_stream_s, g: f64) -> bool ---
	ContentSetStrokeColorRGB        :: proc(st: ^pdfio_stream_s, r: f64, g: f64, b: f64) -> bool ---
	ContentSetStrokeColorSpace      :: proc(st: ^pdfio_stream_s, name: cstring) -> bool ---
	ContentSetTextCharacterSpacing  :: proc(st: ^pdfio_stream_s, spacing: f64) -> bool ---
	ContentSetTextFont              :: proc(st: ^pdfio_stream_s, name: cstring, size: f64) -> bool ---
	ContentSetTextLeading           :: proc(st: ^pdfio_stream_s, leading: f64) -> bool ---
	ContentSetTextMatrix            :: proc(st: ^pdfio_stream_s, m: [3][2]f64) -> bool ---
	ContentSetTextRenderingMode     :: proc(st: ^pdfio_stream_s, mode: textrendering_e) -> bool ---
	ContentSetTextRise              :: proc(st: ^pdfio_stream_s, rise: f64) -> bool ---
	ContentSetTextWordSpacing       :: proc(st: ^pdfio_stream_s, spacing: f64) -> bool ---
	ContentSetTextXScaling          :: proc(st: ^pdfio_stream_s, percent: f64) -> bool ---
	ContentStroke                   :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentTextBegin                :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentTextEnd                  :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentTextMeasure              :: proc(font: ^pdfio_obj_s, s: cstring, size: f64) -> f64 ---
	ContentTextMoveLine             :: proc(st: ^pdfio_stream_s, tx: f64, ty: f64) -> bool ---
	ContentTextMoveTo               :: proc(st: ^pdfio_stream_s, tx: f64, ty: f64) -> bool ---
	ContentTextNewLine              :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentTextNewLineShow          :: proc(st: ^pdfio_stream_s, ws: f64, cs: f64, unicode: bool, s: cstring) -> bool ---
	ContentTextNewLineShowf         :: proc(st: ^pdfio_stream_s, ws: f64, cs: f64, unicode: bool, format: cstring, #c_vararg _: ..any) -> bool ---
	ContentTextNextLine             :: proc(st: ^pdfio_stream_s) -> bool ---
	ContentTextShow                 :: proc(st: ^pdfio_stream_s, unicode: bool, s: cstring) -> bool ---
	ContentTextShowf                :: proc(st: ^pdfio_stream_s, unicode: bool, format: cstring, #c_vararg _: ..any) -> bool ---
	ContentTextShowJustified        :: proc(st: ^pdfio_stream_s, unicode: bool, num_fragments: c.size_t, offsets: ^f64, fragments: [^]cstring) -> bool ---

	// Resource helpers...
	FileCreateFontObjFromBase  :: proc(pdf: ^pdfio_file_s, name: cstring) -> ^pdfio_obj_s ---
	FileCreateFontObjFromFile  :: proc(pdf: ^pdfio_file_s, filename: cstring, unicode: bool) -> ^pdfio_obj_s ---
	FileCreateICCObjFromFile   :: proc(pdf: ^pdfio_file_s, filename: cstring, num_colors: c.size_t) -> ^pdfio_obj_s ---
	FileCreateImageObjFromData :: proc(pdf: ^pdfio_file_s, data: ^u8, width: c.size_t, height: c.size_t, num_colors: c.size_t, color_data: ^pdfio_array_s, alpha: bool, interpolate: bool) -> ^pdfio_obj_s ---
	FileCreateImageObjFromFile :: proc(pdf: ^pdfio_file_s, filename: cstring, interpolate: bool) -> ^pdfio_obj_s ---

	// Image object helpers...
	ImageGetBytesPerLine :: proc(obj: ^pdfio_obj_s) -> c.size_t ---
	ImageGetHeight       :: proc(obj: ^pdfio_obj_s) -> f64 ---
	ImageGetWidth        :: proc(obj: ^pdfio_obj_s) -> f64 ---

	// Page dictionary helpers...
	PageDictAddColorSpace :: proc(dict: ^pdfio_dict_s, name: cstring, data: ^pdfio_array_s) -> bool ---
	PageDictAddFont       :: proc(dict: ^pdfio_dict_s, name: cstring, obj: ^pdfio_obj_s) -> bool ---
	PageDictAddImage      :: proc(dict: ^pdfio_dict_s, name: cstring, obj: ^pdfio_obj_s) -> bool ---
}
