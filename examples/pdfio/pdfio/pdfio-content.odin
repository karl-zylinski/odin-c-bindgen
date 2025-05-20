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

// Types and constants...
cs_t :: enum c.int {
	ADOBE,  // AdobeRGB 1998
	P3_D65, // Display P3
	SRGB,   // sRGB
}

linecap_t :: enum c.int {
	BUTT,   // Butt ends
	ROUND,  // Round ends
	SQUARE, // Square ends
}

linejoin_t :: enum c.int {
	MITER, // Miter joint
	ROUND, // Round joint
	BEVEL, // Bevel joint
}

matrix_t :: [3][2]c.double // Transform matrix

textrendering_t :: enum c.int {
	FILL,            // Fill text
	STROKE,          // Stroke text
	FILL_AND_STROKE, // Fill then stroke text
	INVISIBLE,       // Don't fill or stroke (invisible)
	FILL_PATH,       // Fill text and add to path
	STROKE_PATH,     // Stroke text and add to path
	FILL_AND_STROKE_PATH,
	TEXT_PATH,       // Add text to path (invisible)
}

@(default_calling_convention="c", link_prefix="pdfio")
foreign lib {
	// Color array functions...
	ArrayCreateColorFromICCObj    :: proc(pdf: ^file_t, icc_object: ^obj_t) -> ^array_t ---
	ArrayCreateColorFromMatrix    :: proc(pdf: ^file_t, num_colors: c.size_t, gamma: c.double, _matrix: [^][3]c.double, white_point: ^c.double) -> ^array_t ---
	ArrayCreateColorFromPalette   :: proc(pdf: ^file_t, num_colors: c.size_t, colors: ^c.uchar) -> ^array_t ---
	ArrayCreateColorFromPrimaries :: proc(pdf: ^file_t, num_colors: c.size_t, gamma: c.double, wx: c.double, wy: c.double, rx: c.double, ry: c.double, gx: c.double, gy: c.double, bx: c.double, by: c.double) -> ^array_t ---
	ArrayCreateColorFromStandard  :: proc(pdf: ^file_t, num_colors: c.size_t, cs: cs_t) -> ^array_t ---

	// PDF content drawing functions...
	ContentClip                     :: proc(st: ^stream_t, even_odd: c.bool) -> c.bool ---
	ContentDrawImage                :: proc(st: ^stream_t, name: cstring, x: c.double, y: c.double, w: c.double, h: c.double) -> c.bool ---
	ContentFill                     :: proc(st: ^stream_t, even_odd: c.bool) -> c.bool ---
	ContentFillAndStroke            :: proc(st: ^stream_t, even_odd: c.bool) -> c.bool ---
	ContentMatrixConcat             :: proc(st: ^stream_t, m: [^][2]c.double) -> c.bool ---
	ContentMatrixRotate             :: proc(st: ^stream_t, degrees: c.double) -> c.bool ---
	ContentMatrixScale              :: proc(st: ^stream_t, sx: c.double, sy: c.double) -> c.bool ---
	ContentMatrixTranslate          :: proc(st: ^stream_t, tx: c.double, ty: c.double) -> c.bool ---
	ContentPathClose                :: proc(st: ^stream_t) -> c.bool ---
	ContentPathCurve                :: proc(st: ^stream_t, x1: c.double, y1: c.double, x2: c.double, y2: c.double, x3: c.double, y3: c.double) -> c.bool ---
	ContentPathCurve13              :: proc(st: ^stream_t, x1: c.double, y1: c.double, x3: c.double, y3: c.double) -> c.bool ---
	ContentPathCurve23              :: proc(st: ^stream_t, x2: c.double, y2: c.double, x3: c.double, y3: c.double) -> c.bool ---
	ContentPathEnd                  :: proc(st: ^stream_t) -> c.bool ---
	ContentPathLineTo               :: proc(st: ^stream_t, x: c.double, y: c.double) -> c.bool ---
	ContentPathMoveTo               :: proc(st: ^stream_t, x: c.double, y: c.double) -> c.bool ---
	ContentPathRect                 :: proc(st: ^stream_t, x: c.double, y: c.double, width: c.double, height: c.double) -> c.bool ---
	ContentRestore                  :: proc(st: ^stream_t) -> c.bool ---
	ContentSave                     :: proc(st: ^stream_t) -> c.bool ---
	ContentSetDashPattern           :: proc(st: ^stream_t, phase: c.double, on: c.double, off: c.double) -> c.bool ---
	ContentSetFillColorDeviceCMYK   :: proc(st: ^stream_t, _c: c.double, m: c.double, y: c.double, k: c.double) -> c.bool ---
	ContentSetFillColorDeviceGray   :: proc(st: ^stream_t, g: c.double) -> c.bool ---
	ContentSetFillColorDeviceRGB    :: proc(st: ^stream_t, r: c.double, g: c.double, b: c.double) -> c.bool ---
	ContentSetFillColorGray         :: proc(st: ^stream_t, g: c.double) -> c.bool ---
	ContentSetFillColorRGB          :: proc(st: ^stream_t, r: c.double, g: c.double, b: c.double) -> c.bool ---
	ContentSetFillColorSpace        :: proc(st: ^stream_t, name: cstring) -> c.bool ---
	ContentSetFlatness              :: proc(st: ^stream_t, f: c.double) -> c.bool ---
	ContentSetLineCap               :: proc(st: ^stream_t, lc: linecap_t) -> c.bool ---
	ContentSetLineJoin              :: proc(st: ^stream_t, lj: linejoin_t) -> c.bool ---
	ContentSetLineWidth             :: proc(st: ^stream_t, width: c.double) -> c.bool ---
	ContentSetMiterLimit            :: proc(st: ^stream_t, limit: c.double) -> c.bool ---
	ContentSetStrokeColorDeviceCMYK :: proc(st: ^stream_t, _c: c.double, m: c.double, y: c.double, k: c.double) -> c.bool ---
	ContentSetStrokeColorDeviceGray :: proc(st: ^stream_t, g: c.double) -> c.bool ---
	ContentSetStrokeColorDeviceRGB  :: proc(st: ^stream_t, r: c.double, g: c.double, b: c.double) -> c.bool ---
	ContentSetStrokeColorGray       :: proc(st: ^stream_t, g: c.double) -> c.bool ---
	ContentSetStrokeColorRGB        :: proc(st: ^stream_t, r: c.double, g: c.double, b: c.double) -> c.bool ---
	ContentSetStrokeColorSpace      :: proc(st: ^stream_t, name: cstring) -> c.bool ---
	ContentSetTextCharacterSpacing  :: proc(st: ^stream_t, spacing: c.double) -> c.bool ---
	ContentSetTextFont              :: proc(st: ^stream_t, name: cstring, size: c.double) -> c.bool ---
	ContentSetTextLeading           :: proc(st: ^stream_t, leading: c.double) -> c.bool ---
	ContentSetTextMatrix            :: proc(st: ^stream_t, m: [^][2]c.double) -> c.bool ---
	ContentSetTextRenderingMode     :: proc(st: ^stream_t, mode: textrendering_t) -> c.bool ---
	ContentSetTextRise              :: proc(st: ^stream_t, rise: c.double) -> c.bool ---
	ContentSetTextWordSpacing       :: proc(st: ^stream_t, spacing: c.double) -> c.bool ---
	ContentSetTextXScaling          :: proc(st: ^stream_t, percent: c.double) -> c.bool ---
	ContentStroke                   :: proc(st: ^stream_t) -> c.bool ---
	ContentTextBegin                :: proc(st: ^stream_t) -> c.bool ---
	ContentTextEnd                  :: proc(st: ^stream_t) -> c.bool ---
	ContentTextMeasure              :: proc(font: ^obj_t, s: cstring, size: c.double) -> c.double ---
	ContentTextMoveLine             :: proc(st: ^stream_t, tx: c.double, ty: c.double) -> c.bool ---
	ContentTextMoveTo               :: proc(st: ^stream_t, tx: c.double, ty: c.double) -> c.bool ---
	ContentTextNewLine              :: proc(st: ^stream_t) -> c.bool ---
	ContentTextNewLineShow          :: proc(st: ^stream_t, ws: c.double, cs: c.double, unicode: c.bool, s: cstring) -> c.bool ---
	ContentTextNewLineShowf         :: proc(st: ^stream_t, ws: c.double, cs: c.double, unicode: c.bool, format: cstring) -> c.bool ---
	ContentTextNextLine             :: proc(st: ^stream_t) -> c.bool ---
	ContentTextShow                 :: proc(st: ^stream_t, unicode: c.bool, s: cstring) -> c.bool ---
	ContentTextShowf                :: proc(st: ^stream_t, unicode: c.bool, format: cstring) -> c.bool ---
	ContentTextShowJustified        :: proc(st: ^stream_t, unicode: c.bool, num_fragments: c.size_t, offsets: ^c.double, fragments: [^]cstring) -> c.bool ---

	// Resource helpers...
	FileCreateFontObjFromBase  :: proc(pdf: ^file_t, name: cstring) -> ^obj_t ---
	FileCreateFontObjFromFile  :: proc(pdf: ^file_t, filename: cstring, unicode: c.bool) -> ^obj_t ---
	FileCreateICCObjFromFile   :: proc(pdf: ^file_t, filename: cstring, num_colors: c.size_t) -> ^obj_t ---
	FileCreateImageObjFromData :: proc(pdf: ^file_t, data: ^c.uchar, width: c.size_t, height: c.size_t, num_colors: c.size_t, color_data: ^array_t, alpha: c.bool, interpolate: c.bool) -> ^obj_t ---
	FileCreateImageObjFromFile :: proc(pdf: ^file_t, filename: cstring, interpolate: c.bool) -> ^obj_t ---

	// Image object helpers...
	ImageGetBytesPerLine :: proc(obj: ^obj_t) -> c.size_t ---
	ImageGetHeight       :: proc(obj: ^obj_t) -> c.double ---
	ImageGetWidth        :: proc(obj: ^obj_t) -> c.double ---

	// Page dictionary helpers...
	PageDictAddColorSpace :: proc(dict: ^dict_t, name: cstring, data: ^array_t) -> c.bool ---
	PageDictAddFont       :: proc(dict: ^dict_t, name: cstring, obj: ^obj_t) -> c.bool ---
	PageDictAddImage      :: proc(dict: ^dict_t, name: cstring, obj: ^obj_t) -> c.bool ---
}
