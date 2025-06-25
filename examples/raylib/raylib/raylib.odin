/**********************************************************************************************
*
*   raylib v5.6-dev - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
*
*   FEATURES:
*       - NO external dependencies, all required libraries included with raylib
*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly,
*                        MacOS, Haiku, Android, Raspberry Pi, DRM native, HTML5.
*       - Written in plain C code (C99) in PascalCase/camelCase notation
*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3, 4.3, ES2, ES3 - choose at compile)
*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
*       - Multiple Fonts formats supported (TTF, OTF, FNT, BDF, Sprite fonts)
*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
*       - Flexible Materials system, supporting classic maps and PBR maps
*       - Animated 3D models supported (skeletal bones animation) (IQM, M3D, GLTF)
*       - Shaders support, including Model shaders and Postprocessing shaders
*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, QOA, XM, MOD)
*       - VR stereo rendering with configurable HMD device parameters
*       - Bindings to multiple programming languages available!
*
*   NOTES:
*       - One default Font is loaded on InitWindow()->LoadFontDefault() [core, text]
*       - One default Texture2D is loaded on rlglInit(), 1x1 white pixel R8G8B8A8 [rlgl] (OpenGL 3.3 or ES2)
*       - One default Shader is loaded on rlglInit()->rlLoadShaderDefault() [rlgl] (OpenGL 3.3 or ES2)
*       - One default RenderBatch is loaded on rlglInit()->rlLoadRenderBatch() [rlgl] (OpenGL 3.3 or ES2)
*
*   DEPENDENCIES (included):
*       [rcore][GLFW] rglfw (Camilla Löwy - github.com/glfw/glfw) for window/context management and input
*       [rcore][RGFW] rgfw (ColleagueRiley - github.com/ColleagueRiley/RGFW) for window/context management and input
*       [rlgl] glad/glad_gles2 (David Herberth - github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading
*       [raudio] miniaudio (David Reid - github.com/mackron/miniaudio) for audio device/context management
*
*   OPTIONAL DEPENDENCIES (included):
*       [rcore] msf_gif (Miles Fogle) for GIF recording
*       [rcore] sinfl (Micha Mettke) for DEFLATE decompression algorithm
*       [rcore] sdefl (Micha Mettke) for DEFLATE compression algorithm
*       [rcore] rprand (Ramon Snatamaria) for pseudo-random numbers generation
*       [rtextures] qoi (Dominic Szablewski - https://phoboslab.org) for QOI image manage
*       [rtextures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
*       [rtextures] stb_image_write (Sean Barret) for image writing (BMP, TGA, PNG, JPG)
*       [rtextures] stb_image_resize2 (Sean Barret) for image resizing algorithms
*       [rtextures] stb_perlin (Sean Barret) for Perlin Noise image generation
*       [rtext] stb_truetype (Sean Barret) for ttf fonts loading
*       [rtext] stb_rect_pack (Sean Barret) for rectangles packing
*       [rmodels] par_shapes (Philip Rideout) for parametric 3d shapes generation
*       [rmodels] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
*       [rmodels] cgltf (Johannes Kuhlmann) for models loading (glTF)
*       [rmodels] m3d (bzt) for models loading (M3D, https://bztsrc.gitlab.io/model3d)
*       [rmodels] vox_loader (Johann Nadalutti) for models loading (VOX)
*       [raudio] dr_wav (David Reid) for WAV audio file loading
*       [raudio] dr_flac (David Reid) for FLAC audio file loading
*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
*       [raudio] qoa (Dominic Szablewski - https://phoboslab.org) for QOA audio manage
*
*
*   LICENSE: zlib/libpng
*
*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software:
*
*   Copyright (c) 2013-2025 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/
package raylib

import "core:c"

_ :: c

@(extra_linker_flags="/NODEFAULTLIB:libcmt")
foreign import lib {
	"raylib.lib",
	"system:Winmm.lib",
	"system:Gdi32.lib",
	"system:User32.lib",
	"system:Shell32.lib",
}

// Vector2, 2 components
Vector2 :: [2]f32

// Vector3, 3 components
Vector3 :: [3]f32

// Vector4, 4 components
Vector4 :: [4]f32

// Quaternion, 4 components (Vector4 alias)
Quaternion :: Vector4

// Matrix, 4x4 components, column major, OpenGL style, right-handed
Matrix :: #row_major matrix[4, 4]f32

// Color, 4 components, R8G8B8A8 (32bit)
Color :: distinct [4]u8

// Rectangle, 4 components
Rectangle :: struct {
	x:      f32, // Rectangle top-left corner position x
	y:      f32, // Rectangle top-left corner position y
	width:  f32, // Rectangle width
	height: f32, // Rectangle height
}

// Image, pixel data stored in CPU memory (RAM)
Image :: struct {
	data:    rawptr,      // Image raw data
	width:   c.int,       // Image base width
	height:  c.int,       // Image base height
	mipmaps: c.int,       // Mipmap levels, 1 by default
	format:  PixelFormat, // Data format (PixelFormat type)
}

// Texture, tex data stored in GPU memory (VRAM)
Texture :: struct {
	id:      c.uint,      // OpenGL texture id
	width:   c.int,       // Texture base width
	height:  c.int,       // Texture base height
	mipmaps: c.int,       // Mipmap levels, 1 by default
	format:  PixelFormat, // Data format (PixelFormat type)
}

// Texture2D, same as Texture
Texture2D :: Texture

// TextureCubemap, same as Texture
TextureCubemap :: Texture

// RenderTexture, fbo for texture rendering
RenderTexture :: struct {
	id:      c.uint,  // OpenGL framebuffer object id
	texture: Texture, // Color buffer attachment texture
	depth:   Texture, // Depth buffer attachment texture
}

// RenderTexture2D, same as RenderTexture
RenderTexture2D :: RenderTexture

// NPatchInfo, n-patch layout info
NPatchInfo :: struct {
	source: Rectangle,    // Texture source rectangle
	left:   c.int,        // Left border offset
	top:    c.int,        // Top border offset
	right:  c.int,        // Right border offset
	bottom: c.int,        // Bottom border offset
	layout: NPatchLayout, // Layout of the n-patch: 3x3, 1x3 or 3x1
}

// GlyphInfo, font characters glyphs info
GlyphInfo :: struct {
	value:    rune,  // Character value (Unicode)
	offsetX:  c.int, // Character offset X when drawing
	offsetY:  c.int, // Character offset Y when drawing
	advanceX: c.int, // Character advance position X
	image:    Image, // Character image data
}

// Font, font texture and GlyphInfo array data
Font :: struct {
	baseSize:     c.int,      // Base size (default chars height)
	glyphCount:   c.int,      // Number of glyph characters
	glyphPadding: c.int,      // Padding around the glyph characters
	texture:      Texture2D,  // Texture atlas containing the glyphs
	recs:         ^Rectangle, // Rectangles in texture for the glyphs
	glyphs:       ^GlyphInfo, // Glyphs info data
}

// Camera, defines position/orientation in 3d space
Camera3D :: struct {
	position:   Vector3, // Camera position
	target:     Vector3, // Camera target it looks-at
	up:         Vector3, // Camera up vector (rotation over its axis)
	fovy:       f32,     // Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
	projection: c.int,   // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

Camera :: Camera3D

// Camera2D, defines position/orientation in 2d space
Camera2D :: struct {
	offset:   Vector2, // Camera offset (displacement from target)
	target:   Vector2, // Camera target (rotation and zoom origin)
	rotation: f32,     // Camera rotation in degrees
	zoom:     f32,     // Camera zoom (scaling), should be 1.0f by default
}

// Mesh, vertex data and vao/vbo
Mesh :: struct {
	vertexCount:   c.int,       // Number of vertices stored in arrays
	triangleCount: c.int,       // Number of triangles stored (indexed or not)
	vertices:      [^]f32,      // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
	texcoords:     [^]f32,      // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
	texcoords2:    [^]f32,      // Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
	normals:       [^]f32,      // Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
	tangents:      [^]f32,      // Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
	colors:        [^]c.uchar,  // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
	indices:       [^]c.ushort, // Vertex indices (in case vertex data comes indexed)
	animVertices:  [^]f32,      // Animated vertex positions (after bones transformations)
	animNormals:   [^]f32,      // Animated normals (after bones transformations)
	boneIds:       [^]c.uchar,  // Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
	boneWeights:   [^]f32,      // Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
	boneMatrices:  [^]Matrix,   // Bones animated transformation matrices
	boneCount:     c.int,       // Number of bones
	vaoId:         c.uint,      // OpenGL Vertex Array Object id
	vboId:         [^]c.uint,   // OpenGL Vertex Buffer Objects id (default vertex data)
}

// Shader
Shader :: struct {
	id:   c.uint,   // Shader program id
	locs: [^]c.int, // Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

// MaterialMap
MaterialMap :: struct {
	texture: Texture2D, // Material map texture
	color:   Color,     // Material map color
	value:   f32,       // Material map value
}

// Material, includes shader and maps
Material :: struct {
	shader: Shader,         // Material shader
	maps:   [^]MaterialMap, // Material maps array (MAX_MATERIAL_MAPS)
	params: [4]f32,         // Material generic parameters (if required)
}

// Transform, vertex transformation data
Transform :: struct {
	translation: Vector3,    // Translation
	rotation:    Quaternion, // Rotation
	scale:       Vector3,    // Scale
}

// Bone, skeletal animation bone
BoneInfo :: struct {
	name:   [32]c.char, // Bone name
	parent: c.int,      // Bone parent
}

// Model, meshes, materials and animation data
Model :: struct {
	transform:     Matrix,       // Local transform matrix
	meshCount:     c.int,        // Number of meshes
	materialCount: c.int,        // Number of materials
	meshes:        [^]Mesh,      // Meshes array
	materials:     [^]Material,  // Materials array
	meshMaterial:  ^c.int,       // Mesh material number
	boneCount:     c.int,        // Number of bones
	bones:         [^]BoneInfo,  // Bones information (skeleton)
	bindPose:      [^]Transform, // Bones base transformation (pose)
}

// ModelAnimation
ModelAnimation :: struct {
	boneCount:  c.int,           // Number of bones
	frameCount: c.int,           // Number of animation frames
	bones:      [^]BoneInfo,     // Bones information (skeleton)
	framePoses: [^][^]Transform, // Poses array by frame
	name:       [32]c.char,      // Animation name
}

// Ray, ray for raycasting
Ray :: struct {
	position:  Vector3, // Ray position (origin)
	direction: Vector3, // Ray direction (normalized)
}

// RayCollision, ray hit information
RayCollision :: struct {
	hit:      bool,    // Did the ray hit something?
	distance: f32,     // Distance to the nearest hit
	point:    Vector3, // Point of the nearest hit
	normal:   Vector3, // Surface normal of hit
}

// BoundingBox
BoundingBox :: struct {
	min: Vector3, // Minimum vertex box-corner
	max: Vector3, // Maximum vertex box-corner
}

// Wave, audio wave data
Wave :: struct {
	frameCount: c.uint, // Total number of frames (considering channels)
	sampleRate: c.uint, // Frequency (samples per second)
	sampleSize: c.uint, // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
	channels:   c.uint, // Number of channels (1-mono, 2-stereo, ...)
	data:       rawptr, // Buffer data pointer
}

// AudioStream, custom audio stream
AudioStream :: struct {
	buffer:     rawptr, // Pointer to internal data used by the audio system
	processor:  rawptr, // Pointer to internal data processor, useful for audio effects
	sampleRate: c.uint, // Frequency (samples per second)
	sampleSize: c.uint, // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
	channels:   c.uint, // Number of channels (1-mono, 2-stereo, ...)
}

// Sound
Sound :: struct {
	stream:     AudioStream, // Audio stream
	frameCount: c.uint,      // Total number of frames (considering channels)
}

// Music, audio stream, anything longer than ~10 seconds should be streamed
Music :: struct {
	stream:     AudioStream, // Audio stream
	frameCount: c.uint,      // Total number of frames (considering channels)
	looping:    bool,        // Music looping enable
	ctxType:    c.int,       // Type of music context (audio filetype)
	ctxData:    rawptr,      // Audio context data, depends on type
}

// VrDeviceInfo, Head-Mounted-Display device parameters
VrDeviceInfo :: struct {
	hResolution:            c.int,  // Horizontal resolution in pixels
	vResolution:            c.int,  // Vertical resolution in pixels
	hScreenSize:            f32,    // Horizontal size in meters
	vScreenSize:            f32,    // Vertical size in meters
	eyeToScreenDistance:    f32,    // Distance between eye and display in meters
	lensSeparationDistance: f32,    // Lens separation distance in meters
	interpupillaryDistance: f32,    // IPD (distance between pupils) in meters
	lensDistortionValues:   [4]f32, // Lens distortion constant parameters
	chromaAbCorrection:     [4]f32, // Chromatic aberration correction parameters
}

// VrStereoConfig, VR stereo rendering configuration for simulator
VrStereoConfig :: struct {
	projection:        [2]Matrix, // VR projection matrices (per eye)
	viewOffset:        [2]Matrix, // VR view offset matrices (per eye)
	leftLensCenter:    [2]f32,    // VR left lens center
	rightLensCenter:   [2]f32,    // VR right lens center
	leftScreenCenter:  [2]f32,    // VR left screen center
	rightScreenCenter: [2]f32,    // VR right screen center
	scale:             [2]f32,    // VR distortion scale
	scaleIn:           [2]f32,    // VR distortion scale in
}

// File path list
FilePathList :: struct {
	capacity: c.uint,     // Filepaths max entries
	count:    c.uint,     // Filepaths entries count
	paths:    [^]cstring, // Filepaths entries
}

// Automation event
AutomationEvent :: struct {
	frame:  c.uint,   // Event frame
	type:   c.uint,   // Event type (AutomationEventType)
	params: [4]c.int, // Event parameters (if required)
}

// Automation event list
AutomationEventList :: struct {
	capacity: c.uint,           // Events max entries (MAX_AUTOMATION_EVENTS)
	count:    c.uint,           // Events entries count
	events:   ^AutomationEvent, // Events entries
}

//----------------------------------------------------------------------------------
// Enumerators Definition
//----------------------------------------------------------------------------------
// System/Window config flags
// NOTE: Every bit registers one state (use it with bit masks)
// By default all flags are set to 0
ConfigFlag :: enum c.int {
	// Set to try enabling V-Sync on GPU
	VSYNC_HINT = 6,

	// Set to run program in fullscreen
	FULLSCREEN_MODE = 1,

	// Set to allow resizable window
	WINDOW_RESIZABLE = 2,

	// Set to disable window decoration (frame and buttons)
	WINDOW_UNDECORATED = 3,

	// Set to hide window
	WINDOW_HIDDEN = 7,

	// Set to minimize window (iconify)
	WINDOW_MINIMIZED = 9,

	// Set to maximize window (expanded to monitor)
	WINDOW_MAXIMIZED = 10,

	// Set to window non focused
	WINDOW_UNFOCUSED = 11,

	// Set to window always on top
	WINDOW_TOPMOST = 12,

	// Set to allow windows running while minimized
	WINDOW_ALWAYS_RUN = 8,

	// Set to allow transparent framebuffer
	WINDOW_TRANSPARENT = 4,

	// Set to support HighDPI
	WINDOW_HIGHDPI = 13,

	// Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
	WINDOW_MOUSE_PASSTHROUGH = 14,

	// Set to run program in borderless windowed mode
	BORDERLESS_WINDOWED_MODE = 15,

	// Set to try enabling MSAA 4X
	MSAA_4X_HINT = 5,

	// Set to try enabling interlaced video format (for V3D)
	INTERLACED_HINT = 16,
}

ConfigFlags :: distinct bit_set[ConfigFlag; int]

// Trace log level
// NOTE: Organized by priority level
TraceLogLevel :: enum c.int {
	// Display all logs
	ALL,

	// Trace logging, intended for internal use only
	TRACE,

	// Debug logging, used for internal debugging, it should be disabled on release builds
	DEBUG,

	// Info logging, used for program execution info
	INFO,

	// Warning logging, used on recoverable failures
	WARNING,

	// Error logging, used on unrecoverable failures
	ERROR,

	// Fatal logging, used to abort program: exit(EXIT_FAILURE)
	FATAL,

	// Disable logging
	NONE,
}

// Keyboard keys (US keyboard layout)
// NOTE: Use GetKeyPressed() to allow redefining
// required keys for alternative layouts
KeyboardKey :: enum c.int {
	// Key: NULL, used for no key pressed
	NULL = 0,

	// Key: '
	APOSTROPHE = 39,

	// Key: ,
	COMMA = 44,

	// Key: -
	MINUS = 45,

	// Key: .
	PERIOD = 46,

	// Key: /
	SLASH = 47,

	// Key: 0
	ZERO = 48,

	// Key: 1
	ONE = 49,

	// Key: 2
	TWO = 50,

	// Key: 3
	THREE = 51,

	// Key: 4
	FOUR = 52,

	// Key: 5
	FIVE = 53,

	// Key: 6
	SIX = 54,

	// Key: 7
	SEVEN = 55,

	// Key: 8
	EIGHT = 56,

	// Key: 9
	NINE = 57,

	// Key: ;
	SEMICOLON = 59,

	// Key: =
	EQUAL = 61,

	// Key: A | a
	A = 65,

	// Key: B | b
	B = 66,

	// Key: C | c
	C = 67,

	// Key: D | d
	D = 68,

	// Key: E | e
	E = 69,

	// Key: F | f
	F = 70,

	// Key: G | g
	G = 71,

	// Key: H | h
	H = 72,

	// Key: I | i
	I = 73,

	// Key: J | j
	J = 74,

	// Key: K | k
	K = 75,

	// Key: L | l
	L = 76,

	// Key: M | m
	M = 77,

	// Key: N | n
	N = 78,

	// Key: O | o
	O = 79,

	// Key: P | p
	P = 80,

	// Key: Q | q
	Q = 81,

	// Key: R | r
	R = 82,

	// Key: S | s
	S = 83,

	// Key: T | t
	T = 84,

	// Key: U | u
	U = 85,

	// Key: V | v
	V = 86,

	// Key: W | w
	W = 87,

	// Key: X | x
	X = 88,

	// Key: Y | y
	Y = 89,

	// Key: Z | z
	Z = 90,

	// Key: [
	LEFT_BRACKET = 91,

	// Key: '\'
	BACKSLASH = 92,

	// Key: ]
	RIGHT_BRACKET = 93,

	// Key: `
	GRAVE = 96,

	// Key: Space
	SPACE = 32,

	// Key: Esc
	ESCAPE = 256,

	// Key: Enter
	ENTER = 257,

	// Key: Tab
	TAB = 258,

	// Key: Backspace
	BACKSPACE = 259,

	// Key: Ins
	INSERT = 260,

	// Key: Del
	DELETE = 261,

	// Key: Cursor right
	RIGHT = 262,

	// Key: Cursor left
	LEFT = 263,

	// Key: Cursor down
	DOWN = 264,

	// Key: Cursor up
	UP = 265,

	// Key: Page up
	PAGE_UP = 266,

	// Key: Page down
	PAGE_DOWN = 267,

	// Key: Home
	HOME = 268,

	// Key: End
	END = 269,

	// Key: Caps lock
	CAPS_LOCK = 280,

	// Key: Scroll down
	SCROLL_LOCK = 281,

	// Key: Num lock
	NUM_LOCK = 282,

	// Key: Print screen
	PRINT_SCREEN = 283,

	// Key: Pause
	PAUSE = 284,

	// Key: F1
	F1 = 290,

	// Key: F2
	F2 = 291,

	// Key: F3
	F3 = 292,

	// Key: F4
	F4 = 293,

	// Key: F5
	F5 = 294,

	// Key: F6
	F6 = 295,

	// Key: F7
	F7 = 296,

	// Key: F8
	F8 = 297,

	// Key: F9
	F9 = 298,

	// Key: F10
	F10 = 299,

	// Key: F11
	F11 = 300,

	// Key: F12
	F12 = 301,

	// Key: Shift left
	LEFT_SHIFT = 340,

	// Key: Control left
	LEFT_CONTROL = 341,

	// Key: Alt left
	LEFT_ALT = 342,

	// Key: Super left
	LEFT_SUPER = 343,

	// Key: Shift right
	RIGHT_SHIFT = 344,

	// Key: Control right
	RIGHT_CONTROL = 345,

	// Key: Alt right
	RIGHT_ALT = 346,

	// Key: Super right
	RIGHT_SUPER = 347,

	// Key: KB menu
	KB_MENU = 348,

	// Key: Keypad 0
	KP_0 = 320,

	// Key: Keypad 1
	KP_1 = 321,

	// Key: Keypad 2
	KP_2 = 322,

	// Key: Keypad 3
	KP_3 = 323,

	// Key: Keypad 4
	KP_4 = 324,

	// Key: Keypad 5
	KP_5 = 325,

	// Key: Keypad 6
	KP_6 = 326,

	// Key: Keypad 7
	KP_7 = 327,

	// Key: Keypad 8
	KP_8 = 328,

	// Key: Keypad 9
	KP_9 = 329,

	// Key: Keypad .
	KP_DECIMAL = 330,

	// Key: Keypad /
	KP_DIVIDE = 331,

	// Key: Keypad *
	KP_MULTIPLY = 332,

	// Key: Keypad -
	KP_SUBTRACT = 333,

	// Key: Keypad +
	KP_ADD = 334,

	// Key: Keypad Enter
	KP_ENTER = 335,

	// Key: Keypad =
	KP_EQUAL = 336,

	// Key: Android back button
	BACK = 4,

	// Key: Android menu button
	MENU = 5,

	// Key: Android volume up button
	VOLUME_UP = 24,

	// Key: Android volume down button
	VOLUME_DOWN = 25,
}

// Mouse buttons
MouseButton :: enum c.int {
	// Mouse button left
	LEFT,

	// Mouse button right
	RIGHT,

	// Mouse button middle (pressed wheel)
	MIDDLE,

	// Mouse button side (advanced mouse device)
	SIDE,

	// Mouse button extra (advanced mouse device)
	EXTRA,

	// Mouse button forward (advanced mouse device)
	FORWARD,

	// Mouse button back (advanced mouse device)
	BACK,
}

// Mouse cursor
MouseCursor :: enum c.int {
	// Default pointer shape
	DEFAULT,

	// Arrow shape
	ARROW,

	// Text writing cursor shape
	IBEAM,

	// Cross shape
	CROSSHAIR,

	// Pointing hand cursor
	POINTING_HAND,

	// Horizontal resize/move arrow shape
	RESIZE_EW,

	// Vertical resize/move arrow shape
	RESIZE_NS,

	// Top-left to bottom-right diagonal resize/move arrow shape
	RESIZE_NWSE,

	// The top-right to bottom-left diagonal resize/move arrow shape
	RESIZE_NESW,

	// The omnidirectional resize/move cursor shape
	RESIZE_ALL,

	// The operation-not-allowed shape
	NOT_ALLOWED,
}

// Gamepad buttons
GamepadButton :: enum c.int {
	// Unknown button, just for error checking
	UNKNOWN,

	// Gamepad left DPAD up button
	LEFT_FACE_UP,

	// Gamepad left DPAD right button
	LEFT_FACE_RIGHT,

	// Gamepad left DPAD down button
	LEFT_FACE_DOWN,

	// Gamepad left DPAD left button
	LEFT_FACE_LEFT,

	// Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
	RIGHT_FACE_UP,

	// Gamepad right button right (i.e. PS3: Circle, Xbox: B)
	RIGHT_FACE_RIGHT,

	// Gamepad right button down (i.e. PS3: Cross, Xbox: A)
	RIGHT_FACE_DOWN,

	// Gamepad right button left (i.e. PS3: Square, Xbox: X)
	RIGHT_FACE_LEFT,

	// Gamepad top/back trigger left (first), it could be a trailing button
	LEFT_TRIGGER_1,

	// Gamepad top/back trigger left (second), it could be a trailing button
	LEFT_TRIGGER_2,

	// Gamepad top/back trigger right (first), it could be a trailing button
	RIGHT_TRIGGER_1,

	// Gamepad top/back trigger right (second), it could be a trailing button
	RIGHT_TRIGGER_2,

	// Gamepad center buttons, left one (i.e. PS3: Select)
	MIDDLE_LEFT,

	// Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
	MIDDLE,

	// Gamepad center buttons, right one (i.e. PS3: Start)
	MIDDLE_RIGHT,

	// Gamepad joystick pressed button left
	LEFT_THUMB,

	// Gamepad joystick pressed button right
	RIGHT_THUMB,
}

// Gamepad axis
GamepadAxis :: enum c.int {
	// Gamepad left stick X axis
	LEFT_X,

	// Gamepad left stick Y axis
	LEFT_Y,

	// Gamepad right stick X axis
	RIGHT_X,

	// Gamepad right stick Y axis
	RIGHT_Y,

	// Gamepad back trigger left, pressure level: [1..-1]
	LEFT_TRIGGER,

	// Gamepad back trigger right, pressure level: [1..-1]
	RIGHT_TRIGGER,
}

// Material map index
MaterialMapIndex :: enum c.int {
	// Albedo material (same as: MATERIAL_MAP_DIFFUSE)
	ALBEDO,

	// Metalness material (same as: MATERIAL_MAP_SPECULAR)
	METALNESS,

	// Normal material
	NORMAL,

	// Roughness material
	ROUGHNESS,

	// Ambient occlusion material
	OCCLUSION,

	// Emission material
	EMISSION,

	// Heightmap material
	HEIGHT,

	// Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	CUBEMAP,

	// Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	IRRADIANCE,

	// Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	PREFILTER,

	// Brdf material
	BRDF,
}

// Shader location index
ShaderLocationIndex :: enum c.int {
	// Shader location: vertex attribute: position
	VERTEX_POSITION,

	// Shader location: vertex attribute: texcoord01
	VERTEX_TEXCOORD01,

	// Shader location: vertex attribute: texcoord02
	VERTEX_TEXCOORD02,

	// Shader location: vertex attribute: normal
	VERTEX_NORMAL,

	// Shader location: vertex attribute: tangent
	VERTEX_TANGENT,

	// Shader location: vertex attribute: color
	VERTEX_COLOR,

	// Shader location: matrix uniform: model-view-projection
	MATRIX_MVP,

	// Shader location: matrix uniform: view (camera transform)
	MATRIX_VIEW,

	// Shader location: matrix uniform: projection
	MATRIX_PROJECTION,

	// Shader location: matrix uniform: model (transform)
	MATRIX_MODEL,

	// Shader location: matrix uniform: normal
	MATRIX_NORMAL,

	// Shader location: vector uniform: view
	VECTOR_VIEW,

	// Shader location: vector uniform: diffuse color
	COLOR_DIFFUSE,

	// Shader location: vector uniform: specular color
	COLOR_SPECULAR,

	// Shader location: vector uniform: ambient color
	COLOR_AMBIENT,

	// Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
	MAP_ALBEDO,

	// Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
	MAP_METALNESS,

	// Shader location: sampler2d texture: normal
	MAP_NORMAL,

	// Shader location: sampler2d texture: roughness
	MAP_ROUGHNESS,

	// Shader location: sampler2d texture: occlusion
	MAP_OCCLUSION,

	// Shader location: sampler2d texture: emission
	MAP_EMISSION,

	// Shader location: sampler2d texture: height
	MAP_HEIGHT,

	// Shader location: samplerCube texture: cubemap
	MAP_CUBEMAP,

	// Shader location: samplerCube texture: irradiance
	MAP_IRRADIANCE,

	// Shader location: samplerCube texture: prefilter
	MAP_PREFILTER,

	// Shader location: sampler2d texture: brdf
	MAP_BRDF,

	// Shader location: vertex attribute: boneIds
	VERTEX_BONEIDS,

	// Shader location: vertex attribute: boneWeights
	VERTEX_BONEWEIGHTS,

	// Shader location: array of matrices uniform: boneMatrices
	BONE_MATRICES,

	// Shader location: vertex attribute: instanceTransform
	VERTEX_INSTANCE_TX,
}

// Shader uniform data type
ShaderUniformDataType :: enum c.int {
	// Shader uniform type: float
	FLOAT,

	// Shader uniform type: vec2 (2 float)
	VEC2,

	// Shader uniform type: vec3 (3 float)
	VEC3,

	// Shader uniform type: vec4 (4 float)
	VEC4,

	// Shader uniform type: int
	INT,

	// Shader uniform type: ivec2 (2 int)
	IVEC2,

	// Shader uniform type: ivec3 (3 int)
	IVEC3,

	// Shader uniform type: ivec4 (4 int)
	IVEC4,

	// Shader uniform type: unsigned int
	UINT,

	// Shader uniform type: uivec2 (2 unsigned int)
	UIVEC2,

	// Shader uniform type: uivec3 (3 unsigned int)
	UIVEC3,

	// Shader uniform type: uivec4 (4 unsigned int)
	UIVEC4,

	// Shader uniform type: sampler2d
	SAMPLER2D,
}

// Shader attribute data types
ShaderAttributeDataType :: enum c.int {
	// Shader attribute type: float
	FLOAT,

	// Shader attribute type: vec2 (2 float)
	VEC2,

	// Shader attribute type: vec3 (3 float)
	VEC3,

	// Shader attribute type: vec4 (4 float)
	VEC4,
}

// Pixel formats
// NOTE: Support depends on OpenGL version and platform
PixelFormat :: enum c.int {
	// 8 bit per pixel (no alpha)
	UNCOMPRESSED_GRAYSCALE = 1,

	// 8*2 bpp (2 channels)
	UNCOMPRESSED_GRAY_ALPHA = 2,

	// 16 bpp
	UNCOMPRESSED_R5G6B5 = 3,

	// 24 bpp
	UNCOMPRESSED_R8G8B8 = 4,

	// 16 bpp (1 bit alpha)
	UNCOMPRESSED_R5G5B5A1 = 5,

	// 16 bpp (4 bit alpha)
	UNCOMPRESSED_R4G4B4A4 = 6,

	// 32 bpp
	UNCOMPRESSED_R8G8B8A8 = 7,

	// 32 bpp (1 channel - float)
	UNCOMPRESSED_R32 = 8,

	// 32*3 bpp (3 channels - float)
	UNCOMPRESSED_R32G32B32 = 9,

	// 32*4 bpp (4 channels - float)
	UNCOMPRESSED_R32G32B32A32 = 10,

	// 16 bpp (1 channel - half float)
	UNCOMPRESSED_R16 = 11,

	// 16*3 bpp (3 channels - half float)
	UNCOMPRESSED_R16G16B16 = 12,

	// 16*4 bpp (4 channels - half float)
	UNCOMPRESSED_R16G16B16A16 = 13,

	// 4 bpp (no alpha)
	COMPRESSED_DXT1_RGB = 14,

	// 4 bpp (1 bit alpha)
	COMPRESSED_DXT1_RGBA = 15,

	// 8 bpp
	COMPRESSED_DXT3_RGBA = 16,

	// 8 bpp
	COMPRESSED_DXT5_RGBA = 17,

	// 4 bpp
	COMPRESSED_ETC1_RGB = 18,

	// 4 bpp
	COMPRESSED_ETC2_RGB = 19,

	// 8 bpp
	COMPRESSED_ETC2_EAC_RGBA = 20,

	// 4 bpp
	COMPRESSED_PVRT_RGB = 21,

	// 4 bpp
	COMPRESSED_PVRT_RGBA = 22,

	// 8 bpp
	COMPRESSED_ASTC_4x4_RGBA = 23,

	// 2 bpp
	COMPRESSED_ASTC_8x8_RGBA = 24,
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
TextureFilter :: enum c.int {
	// No filter, just pixel approximation
	POINT,

	// Linear filtering
	BILINEAR,

	// Trilinear filtering (linear with mipmaps)
	TRILINEAR,

	// Anisotropic filtering 4x
	ANISOTROPIC_4X,

	// Anisotropic filtering 8x
	ANISOTROPIC_8X,

	// Anisotropic filtering 16x
	ANISOTROPIC_16X,
}

// Texture parameters: wrap mode
TextureWrap :: enum c.int {
	// Repeats texture in tiled mode
	REPEAT,

	// Clamps texture to edge pixel in tiled mode
	CLAMP,

	// Mirrors and repeats the texture in tiled mode
	MIRROR_REPEAT,

	// Mirrors and clamps to border the texture in tiled mode
	MIRROR_CLAMP,
}

// Cubemap layouts
CubemapLayout :: enum c.int {
	// Automatically detect layout type
	AUTO_DETECT,

	// Layout is defined by a vertical line with faces
	LINE_VERTICAL,

	// Layout is defined by a horizontal line with faces
	LINE_HORIZONTAL,

	// Layout is defined by a 3x4 cross with cubemap faces
	CROSS_THREE_BY_FOUR,

	// Layout is defined by a 4x3 cross with cubemap faces
	CROSS_FOUR_BY_THREE,
}

// Font type, defines generation method
FontType :: enum c.int {
	// Default font generation, anti-aliased
	DEFAULT,

	// Bitmap font generation, no anti-aliasing
	BITMAP,

	// SDF font generation, requires external shader
	SDF,
}

// Color blending modes (pre-defined)
BlendMode :: enum c.int {
	// Blend textures considering alpha (default)
	ALPHA,

	// Blend textures adding colors
	ADDITIVE,

	// Blend textures multiplying colors
	MULTIPLIED,

	// Blend textures adding colors (alternative)
	ADD_COLORS,

	// Blend textures subtracting colors (alternative)
	SUBTRACT_COLORS,

	// Blend premultiplied textures considering alpha
	ALPHA_PREMULTIPLY,

	// Blend textures using custom src/dst factors (use rlSetBlendFactors())
	CUSTOM,

	// Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
	CUSTOM_SEPARATE,
}

// Gesture
// NOTE: Provided as bit-wise flags to enable only desired gestures
Gesture :: enum c.int {
	// Tap gesture
	TAP,

	// Double tap gesture
	DOUBLETAP,

	// Hold gesture
	HOLD,

	// Drag gesture
	DRAG,

	// Swipe right gesture
	SWIPE_RIGHT,

	// Swipe left gesture
	SWIPE_LEFT,

	// Swipe up gesture
	SWIPE_UP,

	// Swipe down gesture
	SWIPE_DOWN,

	// Pinch in gesture
	PINCH_IN,

	// Pinch out gesture
	PINCH_OUT,
}

Gestures :: distinct bit_set[Gesture; int]

// Camera system modes
CameraMode :: enum c.int {
	// Camera custom, controlled by user (UpdateCamera() does nothing)
	CUSTOM,

	// Camera free mode
	FREE,

	// Camera orbital, around target, zoom supported
	ORBITAL,

	// Camera first person
	FIRST_PERSON,

	// Camera third person
	THIRD_PERSON,
}

// Camera projection
CameraProjection :: enum c.int {
	// Perspective projection
	PERSPECTIVE,

	// Orthographic projection
	ORTHOGRAPHIC,
}

// N-patch layout
NPatchLayout :: enum c.int {
	// Npatch layout: 3x3 tiles
	NINE_PATCH,

	// Npatch layout: 1x3 tiles
	THREE_PATCH_VERTICAL,

	// Npatch layout: 3x1 tiles
	THREE_PATCH_HORIZONTAL,
}

// Callbacks to hook some internal functions
// WARNING: These callbacks are intended for advanced users
TraceLogCallback :: proc "c" (c.int, cstring, ^c.va_list)

LoadFileDataCallback :: proc "c" (cstring, ^c.int) -> ^c.uchar

SaveFileDataCallback :: proc "c" (cstring, rawptr, c.int) -> bool

LoadFileTextCallback :: proc "c" (cstring) -> cstring

SaveFileTextCallback :: proc "c" (cstring, cstring) -> bool

//------------------------------------------------------------------------------------
// Audio Loading and Playing Functions (Module: audio)
//------------------------------------------------------------------------------------
AudioCallback :: proc "c" (rawptr, c.uint)

@(default_calling_convention="c", link_prefix="")
foreign lib {
	// Window-related functions
	InitWindow               :: proc(width: c.int, height: c.int, title: cstring) ---
	CloseWindow              :: proc() ---
	WindowShouldClose        :: proc() -> bool ---
	IsWindowReady            :: proc() -> bool ---
	IsWindowFullscreen       :: proc() -> bool ---
	IsWindowHidden           :: proc() -> bool ---
	IsWindowMinimized        :: proc() -> bool ---
	IsWindowMaximized        :: proc() -> bool ---
	IsWindowFocused          :: proc() -> bool ---
	IsWindowResized          :: proc() -> bool ---
	IsWindowState            :: proc(flag: c.uint) -> bool ---
	SetWindowState           :: proc(flags: c.uint) ---
	ClearWindowState         :: proc(flags: c.uint) ---
	ToggleFullscreen         :: proc() ---
	ToggleBorderlessWindowed :: proc() ---
	MaximizeWindow           :: proc() ---
	MinimizeWindow           :: proc() ---
	RestoreWindow            :: proc() ---
	SetWindowIcon            :: proc(image: Image) ---
	SetWindowIcons           :: proc(images: ^Image, count: c.int) ---
	SetWindowTitle           :: proc(title: cstring) ---
	SetWindowPosition        :: proc(x: c.int, y: c.int) ---
	SetWindowMonitor         :: proc(monitor: c.int) ---
	SetWindowMinSize         :: proc(width: c.int, height: c.int) ---
	SetWindowMaxSize         :: proc(width: c.int, height: c.int) ---
	SetWindowSize            :: proc(width: c.int, height: c.int) ---
	SetWindowOpacity         :: proc(opacity: f32) ---
	SetWindowFocused         :: proc() ---
	GetWindowHandle          :: proc() -> rawptr ---
	GetScreenWidth           :: proc() -> c.int ---
	GetScreenHeight          :: proc() -> c.int ---
	GetRenderWidth           :: proc() -> c.int ---
	GetRenderHeight          :: proc() -> c.int ---
	GetMonitorCount          :: proc() -> c.int ---
	GetCurrentMonitor        :: proc() -> c.int ---
	GetMonitorPosition       :: proc(monitor: c.int) -> Vector2 ---
	GetMonitorWidth          :: proc(monitor: c.int) -> c.int ---
	GetMonitorHeight         :: proc(monitor: c.int) -> c.int ---
	GetMonitorPhysicalWidth  :: proc(monitor: c.int) -> c.int ---
	GetMonitorPhysicalHeight :: proc(monitor: c.int) -> c.int ---
	GetMonitorRefreshRate    :: proc(monitor: c.int) -> c.int ---
	GetWindowPosition        :: proc() -> Vector2 ---
	GetWindowScaleDPI        :: proc() -> Vector2 ---
	GetMonitorName           :: proc(monitor: c.int) -> cstring ---
	SetClipboardText         :: proc(text: cstring) ---
	GetClipboardText         :: proc() -> cstring ---
	GetClipboardImage        :: proc() -> Image ---
	EnableEventWaiting       :: proc() ---
	DisableEventWaiting      :: proc() ---

	// Cursor-related functions
	ShowCursor       :: proc() ---
	HideCursor       :: proc() ---
	IsCursorHidden   :: proc() -> bool ---
	EnableCursor     :: proc() ---
	DisableCursor    :: proc() ---
	IsCursorOnScreen :: proc() -> bool ---

	// Drawing-related functions
	ClearBackground   :: proc(color: Color) ---
	BeginDrawing      :: proc() ---
	EndDrawing        :: proc() ---
	BeginMode2D       :: proc(camera: Camera2D) ---
	EndMode2D         :: proc() ---
	BeginMode3D       :: proc(camera: Camera3D) ---
	EndMode3D         :: proc() ---
	BeginTextureMode  :: proc(target: RenderTexture2D) ---
	EndTextureMode    :: proc() ---
	BeginShaderMode   :: proc(shader: Shader) ---
	EndShaderMode     :: proc() ---
	BeginBlendMode    :: proc(mode: c.int) ---
	EndBlendMode      :: proc() ---
	BeginScissorMode  :: proc(x: c.int, y: c.int, width: c.int, height: c.int) ---
	EndScissorMode    :: proc() ---
	BeginVrStereoMode :: proc(config: VrStereoConfig) ---
	EndVrStereoMode   :: proc() ---

	// VR stereo config functions for VR simulator
	LoadVrStereoConfig   :: proc(device: VrDeviceInfo) -> VrStereoConfig ---
	UnloadVrStereoConfig :: proc(config: VrStereoConfig) ---

	// Shader management functions
	// NOTE: Shader functionality is not available on OpenGL 1.1
	LoadShader              :: proc(vsFileName: cstring, fsFileName: cstring) -> Shader ---
	LoadShaderFromMemory    :: proc(vsCode: cstring, fsCode: cstring) -> Shader ---
	IsShaderValid           :: proc(shader: Shader) -> bool ---
	GetShaderLocation       :: proc(shader: Shader, uniformName: cstring) -> c.int ---
	GetShaderLocationAttrib :: proc(shader: Shader, attribName: cstring) -> c.int ---
	SetShaderValue          :: proc(shader: Shader, locIndex: c.int, value: rawptr, uniformType: ShaderUniformDataType) ---
	SetShaderValueV         :: proc(shader: Shader, locIndex: c.int, value: rawptr, uniformType: ShaderUniformDataType, count: c.int) ---
	SetShaderValueMatrix    :: proc(shader: Shader, locIndex: c.int, mat: Matrix) ---
	SetShaderValueTexture   :: proc(shader: Shader, locIndex: c.int, texture: Texture2D) ---
	UnloadShader            :: proc(shader: Shader) ---
	GetScreenToWorldRay     :: proc(position: Vector2, camera: Camera) -> Ray ---
	GetScreenToWorldRayEx   :: proc(position: Vector2, camera: Camera, width: c.int, height: c.int) -> Ray ---
	GetWorldToScreen        :: proc(position: Vector3, camera: Camera) -> Vector2 ---
	GetWorldToScreenEx      :: proc(position: Vector3, camera: Camera, width: c.int, height: c.int) -> Vector2 ---
	GetWorldToScreen2D      :: proc(position: Vector2, camera: Camera2D) -> Vector2 ---
	GetScreenToWorld2D      :: proc(position: Vector2, camera: Camera2D) -> Vector2 ---
	GetCameraMatrix         :: proc(camera: Camera) -> Matrix ---
	GetCameraMatrix2D       :: proc(camera: Camera2D) -> Matrix ---

	// Timing-related functions
	SetTargetFPS :: proc(fps: c.int) ---
	GetFrameTime :: proc() -> f32 ---
	GetTime      :: proc() -> f64 ---
	GetFPS       :: proc() -> c.int ---

	// Custom frame control functions
	// NOTE: Those functions are intended for advanced users that want full control over the frame processing
	// By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
	// To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
	SwapScreenBuffer :: proc() ---
	PollInputEvents  :: proc() ---
	WaitTime         :: proc(seconds: f64) ---

	// Random values generation functions
	SetRandomSeed        :: proc(seed: c.uint) ---
	GetRandomValue       :: proc(min: c.int, max: c.int) -> c.int ---
	LoadRandomSequence   :: proc(count: c.uint, min: c.int, max: c.int) -> ^c.int ---
	UnloadRandomSequence :: proc(sequence: ^c.int) ---

	// Misc. functions
	TakeScreenshot :: proc(fileName: cstring) ---
	SetConfigFlags :: proc(flags: ConfigFlags) ---
	OpenURL        :: proc(url: cstring) ---

	// NOTE: Following functions implemented in module [utils]
	//------------------------------------------------------------------
	TraceLog         :: proc(logLevel: c.int, text: cstring, #c_vararg _: ..any) ---
	SetTraceLogLevel :: proc(logLevel: c.int) ---
	MemAlloc         :: proc(size: c.uint) -> rawptr ---
	MemRealloc       :: proc(ptr: rawptr, size: c.uint) -> rawptr ---
	MemFree          :: proc(ptr: rawptr) ---

	// Set custom callbacks
	// WARNING: Callbacks setup is intended for advanced users
	SetTraceLogCallback     :: proc(callback: TraceLogCallback) ---
	SetLoadFileDataCallback :: proc(callback: LoadFileDataCallback) ---
	SetSaveFileDataCallback :: proc(callback: SaveFileDataCallback) ---
	SetLoadFileTextCallback :: proc(callback: LoadFileTextCallback) ---
	SetSaveFileTextCallback :: proc(callback: SaveFileTextCallback) ---

	// Files management functions
	LoadFileData     :: proc(fileName: cstring, dataSize: ^c.int) -> ^c.uchar ---
	UnloadFileData   :: proc(data: ^c.uchar) ---
	SaveFileData     :: proc(fileName: cstring, data: rawptr, dataSize: c.int) -> bool ---
	ExportDataAsCode :: proc(data: ^c.uchar, dataSize: c.int, fileName: cstring) -> bool ---
	LoadFileText     :: proc(fileName: cstring) -> cstring ---
	UnloadFileText   :: proc(text: cstring) ---
	SaveFileText     :: proc(fileName: cstring, text: cstring) -> bool ---

	// File system functions
	FileExists              :: proc(fileName: cstring) -> bool ---
	DirectoryExists         :: proc(dirPath: cstring) -> bool ---
	IsFileExtension         :: proc(fileName: cstring, ext: cstring) -> bool ---
	GetFileLength           :: proc(fileName: cstring) -> c.int ---
	GetFileExtension        :: proc(fileName: cstring) -> cstring ---
	GetFileName             :: proc(filePath: cstring) -> cstring ---
	GetFileNameWithoutExt   :: proc(filePath: cstring) -> cstring ---
	GetDirectoryPath        :: proc(filePath: cstring) -> cstring ---
	GetPrevDirectoryPath    :: proc(dirPath: cstring) -> cstring ---
	GetWorkingDirectory     :: proc() -> cstring ---
	GetApplicationDirectory :: proc() -> cstring ---
	MakeDirectory           :: proc(dirPath: cstring) -> c.int ---
	ChangeDirectory         :: proc(dir: cstring) -> bool ---
	IsPathFile              :: proc(path: cstring) -> bool ---
	IsFileNameValid         :: proc(fileName: cstring) -> bool ---
	LoadDirectoryFiles      :: proc(dirPath: cstring) -> FilePathList ---
	LoadDirectoryFilesEx    :: proc(basePath: cstring, filter: cstring, scanSubdirs: bool) -> FilePathList ---
	UnloadDirectoryFiles    :: proc(files: FilePathList) ---
	IsFileDropped           :: proc() -> bool ---
	LoadDroppedFiles        :: proc() -> FilePathList ---
	UnloadDroppedFiles      :: proc(files: FilePathList) ---
	GetFileModTime          :: proc(fileName: cstring) -> c.long ---

	// Compression/Encoding functionality
	CompressData     :: proc(data: ^c.uchar, dataSize: c.int, compDataSize: ^c.int) -> ^c.uchar ---
	DecompressData   :: proc(compData: ^c.uchar, compDataSize: c.int, dataSize: ^c.int) -> ^c.uchar ---
	EncodeDataBase64 :: proc(data: ^c.uchar, dataSize: c.int, outputSize: ^c.int) -> cstring ---
	DecodeDataBase64 :: proc(data: ^c.uchar, outputSize: ^c.int) -> ^c.uchar ---
	ComputeCRC32     :: proc(data: ^c.uchar, dataSize: c.int) -> c.uint ---
	ComputeMD5       :: proc(data: ^c.uchar, dataSize: c.int) -> ^c.uint ---
	ComputeSHA1      :: proc(data: ^c.uchar, dataSize: c.int) -> ^c.uint ---

	// Automation events functionality
	LoadAutomationEventList       :: proc(fileName: cstring) -> AutomationEventList ---
	UnloadAutomationEventList     :: proc(list: AutomationEventList) ---
	ExportAutomationEventList     :: proc(list: AutomationEventList, fileName: cstring) -> bool ---
	SetAutomationEventList        :: proc(list: ^AutomationEventList) ---
	SetAutomationEventBaseFrame   :: proc(frame: c.int) ---
	StartAutomationEventRecording :: proc() ---
	StopAutomationEventRecording  :: proc() ---
	PlayAutomationEvent           :: proc(event: AutomationEvent) ---

	// Input-related functions: keyboard
	IsKeyPressed       :: proc(key: KeyboardKey) -> bool ---
	IsKeyPressedRepeat :: proc(key: KeyboardKey) -> bool ---
	IsKeyDown          :: proc(key: KeyboardKey) -> bool ---
	IsKeyReleased      :: proc(key: KeyboardKey) -> bool ---
	IsKeyUp            :: proc(key: KeyboardKey) -> bool ---
	GetKeyPressed      :: proc() -> KeyboardKey ---
	GetCharPressed     :: proc() -> c.int ---
	GetKeyName         :: proc(key: KeyboardKey) -> cstring ---
	SetExitKey         :: proc(key: KeyboardKey) ---

	// Input-related functions: gamepads
	IsGamepadAvailable      :: proc(gamepad: c.int) -> bool ---
	GetGamepadName          :: proc(gamepad: c.int) -> cstring ---
	IsGamepadButtonPressed  :: proc(gamepad: c.int, button: c.int) -> bool ---
	IsGamepadButtonDown     :: proc(gamepad: c.int, button: c.int) -> bool ---
	IsGamepadButtonReleased :: proc(gamepad: c.int, button: c.int) -> bool ---
	IsGamepadButtonUp       :: proc(gamepad: c.int, button: c.int) -> bool ---
	GetGamepadButtonPressed :: proc() -> c.int ---
	GetGamepadAxisCount     :: proc(gamepad: c.int) -> c.int ---
	GetGamepadAxisMovement  :: proc(gamepad: c.int, axis: c.int) -> f32 ---
	SetGamepadMappings      :: proc(mappings: cstring) -> c.int ---
	SetGamepadVibration     :: proc(gamepad: c.int, leftMotor: f32, rightMotor: f32, duration: f32) ---

	// Input-related functions: mouse
	IsMouseButtonPressed  :: proc(button: MouseButton) -> bool ---
	IsMouseButtonDown     :: proc(button: MouseButton) -> bool ---
	IsMouseButtonReleased :: proc(button: MouseButton) -> bool ---
	IsMouseButtonUp       :: proc(button: MouseButton) -> bool ---
	GetMouseX             :: proc() -> c.int ---
	GetMouseY             :: proc() -> c.int ---
	GetMousePosition      :: proc() -> Vector2 ---
	GetMouseDelta         :: proc() -> Vector2 ---
	SetMousePosition      :: proc(x: c.int, y: c.int) ---
	SetMouseOffset        :: proc(offsetX: c.int, offsetY: c.int) ---
	SetMouseScale         :: proc(scaleX: f32, scaleY: f32) ---
	GetMouseWheelMove     :: proc() -> f32 ---
	GetMouseWheelMoveV    :: proc() -> Vector2 ---
	SetMouseCursor        :: proc(cursor: c.int) ---

	// Input-related functions: touch
	GetTouchX          :: proc() -> c.int ---
	GetTouchY          :: proc() -> c.int ---
	GetTouchPosition   :: proc(index: c.int) -> Vector2 ---
	GetTouchPointId    :: proc(index: c.int) -> c.int ---
	GetTouchPointCount :: proc() -> c.int ---

	//------------------------------------------------------------------------------------
	// Gestures and Touch Handling Functions (Module: rgestures)
	//------------------------------------------------------------------------------------
	SetGesturesEnabled     :: proc(flags: Gestures) ---
	IsGestureDetected      :: proc(gesture: Gestures) -> bool ---
	GetGestureDetected     :: proc() -> c.int ---
	GetGestureHoldDuration :: proc() -> f32 ---
	GetGestureDragVector   :: proc() -> Vector2 ---
	GetGestureDragAngle    :: proc() -> f32 ---
	GetGesturePinchVector  :: proc() -> Vector2 ---
	GetGesturePinchAngle   :: proc() -> f32 ---

	//------------------------------------------------------------------------------------
	// Camera System Functions (Module: rcamera)
	//------------------------------------------------------------------------------------
	UpdateCamera    :: proc(camera: ^Camera, mode: c.int) ---
	UpdateCameraPro :: proc(camera: ^Camera, movement: Vector3, rotation: Vector3, zoom: f32) ---

	//------------------------------------------------------------------------------------
	// Basic Shapes Drawing Functions (Module: shapes)
	//------------------------------------------------------------------------------------
	// Set texture and rectangle to be used on shapes drawing
	// NOTE: It can be useful when using basic shapes and one single font,
	// defining a font char white rectangle would allow drawing everything in a single draw call
	SetShapesTexture          :: proc(texture: Texture2D, source: Rectangle) ---
	GetShapesTexture          :: proc() -> Texture2D ---
	GetShapesTextureRectangle :: proc() -> Rectangle ---

	// Basic shapes drawing functions
	DrawPixel                   :: proc(posX: c.int, posY: c.int, color: Color) ---
	DrawPixelV                  :: proc(position: Vector2, color: Color) ---
	DrawLine                    :: proc(startPosX: c.int, startPosY: c.int, endPosX: c.int, endPosY: c.int, color: Color) ---
	DrawLineV                   :: proc(startPos: Vector2, endPos: Vector2, color: Color) ---
	DrawLineEx                  :: proc(startPos: Vector2, endPos: Vector2, thick: f32, color: Color) ---
	DrawLineStrip               :: proc(points: ^Vector2, pointCount: c.int, color: Color) ---
	DrawLineBezier              :: proc(startPos: Vector2, endPos: Vector2, thick: f32, color: Color) ---
	DrawCircle                  :: proc(centerX: c.int, centerY: c.int, radius: f32, color: Color) ---
	DrawCircleSector            :: proc(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: c.int, color: Color) ---
	DrawCircleSectorLines       :: proc(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: c.int, color: Color) ---
	DrawCircleGradient          :: proc(centerX: c.int, centerY: c.int, radius: f32, inner: Color, outer: Color) ---
	DrawCircleV                 :: proc(center: Vector2, radius: f32, color: Color) ---
	DrawCircleLines             :: proc(centerX: c.int, centerY: c.int, radius: f32, color: Color) ---
	DrawCircleLinesV            :: proc(center: Vector2, radius: f32, color: Color) ---
	DrawEllipse                 :: proc(centerX: c.int, centerY: c.int, radiusH: f32, radiusV: f32, color: Color) ---
	DrawEllipseLines            :: proc(centerX: c.int, centerY: c.int, radiusH: f32, radiusV: f32, color: Color) ---
	DrawRing                    :: proc(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: c.int, color: Color) ---
	DrawRingLines               :: proc(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: c.int, color: Color) ---
	DrawRectangle               :: proc(posX: c.int, posY: c.int, width: c.int, height: c.int, color: Color) ---
	DrawRectangleV              :: proc(position: Vector2, size: Vector2, color: Color) ---
	DrawRectangleRec            :: proc(rec: Rectangle, color: Color) ---
	DrawRectanglePro            :: proc(rec: Rectangle, origin: Vector2, rotation: f32, color: Color) ---
	DrawRectangleGradientV      :: proc(posX: c.int, posY: c.int, width: c.int, height: c.int, top: Color, bottom: Color) ---
	DrawRectangleGradientH      :: proc(posX: c.int, posY: c.int, width: c.int, height: c.int, left: Color, right: Color) ---
	DrawRectangleGradientEx     :: proc(rec: Rectangle, topLeft: Color, bottomLeft: Color, topRight: Color, bottomRight: Color) ---
	DrawRectangleLines          :: proc(posX: c.int, posY: c.int, width: c.int, height: c.int, color: Color) ---
	DrawRectangleLinesEx        :: proc(rec: Rectangle, lineThick: f32, color: Color) ---
	DrawRectangleRounded        :: proc(rec: Rectangle, roundness: f32, segments: c.int, color: Color) ---
	DrawRectangleRoundedLines   :: proc(rec: Rectangle, roundness: f32, segments: c.int, color: Color) ---
	DrawRectangleRoundedLinesEx :: proc(rec: Rectangle, roundness: f32, segments: c.int, lineThick: f32, color: Color) ---
	DrawTriangle                :: proc(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) ---
	DrawTriangleLines           :: proc(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) ---
	DrawTriangleFan             :: proc(points: ^Vector2, pointCount: c.int, color: Color) ---
	DrawTriangleStrip           :: proc(points: ^Vector2, pointCount: c.int, color: Color) ---
	DrawPoly                    :: proc(center: Vector2, sides: c.int, radius: f32, rotation: f32, color: Color) ---
	DrawPolyLines               :: proc(center: Vector2, sides: c.int, radius: f32, rotation: f32, color: Color) ---
	DrawPolyLinesEx             :: proc(center: Vector2, sides: c.int, radius: f32, rotation: f32, lineThick: f32, color: Color) ---

	// Splines drawing functions
	DrawSplineLinear                 :: proc(points: ^Vector2, pointCount: c.int, thick: f32, color: Color) ---
	DrawSplineBasis                  :: proc(points: ^Vector2, pointCount: c.int, thick: f32, color: Color) ---
	DrawSplineCatmullRom             :: proc(points: ^Vector2, pointCount: c.int, thick: f32, color: Color) ---
	DrawSplineBezierQuadratic        :: proc(points: ^Vector2, pointCount: c.int, thick: f32, color: Color) ---
	DrawSplineBezierCubic            :: proc(points: ^Vector2, pointCount: c.int, thick: f32, color: Color) ---
	DrawSplineSegmentLinear          :: proc(p1: Vector2, p2: Vector2, thick: f32, color: Color) ---
	DrawSplineSegmentBasis           :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: f32, color: Color) ---
	DrawSplineSegmentCatmullRom      :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: f32, color: Color) ---
	DrawSplineSegmentBezierQuadratic :: proc(p1: Vector2, c2: Vector2, p3: Vector2, thick: f32, color: Color) ---
	DrawSplineSegmentBezierCubic     :: proc(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, thick: f32, color: Color) ---

	// Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]
	GetSplinePointLinear      :: proc(startPos: Vector2, endPos: Vector2, t: f32) -> Vector2 ---
	GetSplinePointBasis       :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: f32) -> Vector2 ---
	GetSplinePointCatmullRom  :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: f32) -> Vector2 ---
	GetSplinePointBezierQuad  :: proc(p1: Vector2, c2: Vector2, p3: Vector2, t: f32) -> Vector2 ---
	GetSplinePointBezierCubic :: proc(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, t: f32) -> Vector2 ---

	// Basic shapes collision detection functions
	CheckCollisionRecs          :: proc(rec1: Rectangle, rec2: Rectangle) -> bool ---
	CheckCollisionCircles       :: proc(center1: Vector2, radius1: f32, center2: Vector2, radius2: f32) -> bool ---
	CheckCollisionCircleRec     :: proc(center: Vector2, radius: f32, rec: Rectangle) -> bool ---
	CheckCollisionCircleLine    :: proc(center: Vector2, radius: f32, p1: Vector2, p2: Vector2) -> bool ---
	CheckCollisionPointRec      :: proc(point: Vector2, rec: Rectangle) -> bool ---
	CheckCollisionPointCircle   :: proc(point: Vector2, center: Vector2, radius: f32) -> bool ---
	CheckCollisionPointTriangle :: proc(point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) -> bool ---
	CheckCollisionPointLine     :: proc(point: Vector2, p1: Vector2, p2: Vector2, threshold: c.int) -> bool ---
	CheckCollisionPointPoly     :: proc(point: Vector2, points: ^Vector2, pointCount: c.int) -> bool ---
	CheckCollisionLines         :: proc(startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2, collisionPoint: ^Vector2) -> bool ---
	GetCollisionRec             :: proc(rec1: Rectangle, rec2: Rectangle) -> Rectangle ---

	// Image loading functions
	// NOTE: These functions do not require GPU access
	LoadImage               :: proc(fileName: cstring) -> Image ---
	LoadImageRaw            :: proc(fileName: cstring, width: c.int, height: c.int, format: c.int, headerSize: c.int) -> Image ---
	LoadImageAnim           :: proc(fileName: cstring, frames: ^c.int) -> Image ---
	LoadImageAnimFromMemory :: proc(fileType: cstring, fileData: ^c.uchar, dataSize: c.int, frames: ^c.int) -> Image ---
	LoadImageFromMemory     :: proc(fileType: cstring, fileData: ^c.uchar, dataSize: c.int) -> Image ---
	LoadImageFromTexture    :: proc(texture: Texture2D) -> Image ---
	LoadImageFromScreen     :: proc() -> Image ---
	IsImageValid            :: proc(image: Image) -> bool ---
	UnloadImage             :: proc(image: Image) ---
	ExportImage             :: proc(image: Image, fileName: cstring) -> bool ---
	ExportImageToMemory     :: proc(image: Image, fileType: cstring, fileSize: ^c.int) -> ^c.uchar ---
	ExportImageAsCode       :: proc(image: Image, fileName: cstring) -> bool ---

	// Image generation functions
	GenImageColor          :: proc(width: c.int, height: c.int, color: Color) -> Image ---
	GenImageGradientLinear :: proc(width: c.int, height: c.int, direction: c.int, start: Color, end: Color) -> Image ---
	GenImageGradientRadial :: proc(width: c.int, height: c.int, density: f32, inner: Color, outer: Color) -> Image ---
	GenImageGradientSquare :: proc(width: c.int, height: c.int, density: f32, inner: Color, outer: Color) -> Image ---
	GenImageChecked        :: proc(width: c.int, height: c.int, checksX: c.int, checksY: c.int, col1: Color, col2: Color) -> Image ---
	GenImageWhiteNoise     :: proc(width: c.int, height: c.int, factor: f32) -> Image ---
	GenImagePerlinNoise    :: proc(width: c.int, height: c.int, offsetX: c.int, offsetY: c.int, scale: f32) -> Image ---
	GenImageCellular       :: proc(width: c.int, height: c.int, tileSize: c.int) -> Image ---
	GenImageText           :: proc(width: c.int, height: c.int, text: cstring) -> Image ---

	// Image manipulation functions
	ImageCopy              :: proc(image: Image) -> Image ---
	ImageFromImage         :: proc(image: Image, rec: Rectangle) -> Image ---
	ImageFromChannel       :: proc(image: Image, selectedChannel: c.int) -> Image ---
	ImageText              :: proc(text: cstring, fontSize: c.int, color: Color) -> Image ---
	ImageTextEx            :: proc(font: Font, text: cstring, fontSize: f32, spacing: f32, tint: Color) -> Image ---
	ImageFormat            :: proc(image: ^Image, newFormat: c.int) ---
	ImageToPOT             :: proc(image: ^Image, fill: Color) ---
	ImageCrop              :: proc(image: ^Image, crop: Rectangle) ---
	ImageAlphaCrop         :: proc(image: ^Image, threshold: f32) ---
	ImageAlphaClear        :: proc(image: ^Image, color: Color, threshold: f32) ---
	ImageAlphaMask         :: proc(image: ^Image, alphaMask: Image) ---
	ImageAlphaPremultiply  :: proc(image: ^Image) ---
	ImageBlurGaussian      :: proc(image: ^Image, blurSize: c.int) ---
	ImageKernelConvolution :: proc(image: ^Image, kernel: ^f32, kernelSize: c.int) ---
	ImageResize            :: proc(image: ^Image, newWidth: c.int, newHeight: c.int) ---
	ImageResizeNN          :: proc(image: ^Image, newWidth: c.int, newHeight: c.int) ---
	ImageResizeCanvas      :: proc(image: ^Image, newWidth: c.int, newHeight: c.int, offsetX: c.int, offsetY: c.int, fill: Color) ---
	ImageMipmaps           :: proc(image: ^Image) ---
	ImageDither            :: proc(image: ^Image, rBpp: c.int, gBpp: c.int, bBpp: c.int, aBpp: c.int) ---
	ImageFlipVertical      :: proc(image: ^Image) ---
	ImageFlipHorizontal    :: proc(image: ^Image) ---
	ImageRotate            :: proc(image: ^Image, degrees: c.int) ---
	ImageRotateCW          :: proc(image: ^Image) ---
	ImageRotateCCW         :: proc(image: ^Image) ---
	ImageColorTint         :: proc(image: ^Image, color: Color) ---
	ImageColorInvert       :: proc(image: ^Image) ---
	ImageColorGrayscale    :: proc(image: ^Image) ---
	ImageColorContrast     :: proc(image: ^Image, contrast: f32) ---
	ImageColorBrightness   :: proc(image: ^Image, brightness: c.int) ---
	ImageColorReplace      :: proc(image: ^Image, color: Color, replace: Color) ---
	LoadImageColors        :: proc(image: Image) -> ^Color ---
	LoadImagePalette       :: proc(image: Image, maxPaletteSize: c.int, colorCount: ^c.int) -> ^Color ---
	UnloadImageColors      :: proc(colors: ^Color) ---
	UnloadImagePalette     :: proc(colors: ^Color) ---
	GetImageAlphaBorder    :: proc(image: Image, threshold: f32) -> Rectangle ---
	GetImageColor          :: proc(image: Image, x: c.int, y: c.int) -> Color ---

	// Image drawing functions
	// NOTE: Image software-rendering functions (CPU)
	ImageClearBackground    :: proc(dst: ^Image, color: Color) ---
	ImageDrawPixel          :: proc(dst: ^Image, posX: c.int, posY: c.int, color: Color) ---
	ImageDrawPixelV         :: proc(dst: ^Image, position: Vector2, color: Color) ---
	ImageDrawLine           :: proc(dst: ^Image, startPosX: c.int, startPosY: c.int, endPosX: c.int, endPosY: c.int, color: Color) ---
	ImageDrawLineV          :: proc(dst: ^Image, start: Vector2, end: Vector2, color: Color) ---
	ImageDrawLineEx         :: proc(dst: ^Image, start: Vector2, end: Vector2, thick: c.int, color: Color) ---
	ImageDrawCircle         :: proc(dst: ^Image, centerX: c.int, centerY: c.int, radius: c.int, color: Color) ---
	ImageDrawCircleV        :: proc(dst: ^Image, center: Vector2, radius: c.int, color: Color) ---
	ImageDrawCircleLines    :: proc(dst: ^Image, centerX: c.int, centerY: c.int, radius: c.int, color: Color) ---
	ImageDrawCircleLinesV   :: proc(dst: ^Image, center: Vector2, radius: c.int, color: Color) ---
	ImageDrawRectangle      :: proc(dst: ^Image, posX: c.int, posY: c.int, width: c.int, height: c.int, color: Color) ---
	ImageDrawRectangleV     :: proc(dst: ^Image, position: Vector2, size: Vector2, color: Color) ---
	ImageDrawRectangleRec   :: proc(dst: ^Image, rec: Rectangle, color: Color) ---
	ImageDrawRectangleLines :: proc(dst: ^Image, rec: Rectangle, thick: c.int, color: Color) ---
	ImageDrawTriangle       :: proc(dst: ^Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) ---
	ImageDrawTriangleEx     :: proc(dst: ^Image, v1: Vector2, v2: Vector2, v3: Vector2, c1: Color, c2: Color, c3: Color) ---
	ImageDrawTriangleLines  :: proc(dst: ^Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) ---
	ImageDrawTriangleFan    :: proc(dst: ^Image, points: ^Vector2, pointCount: c.int, color: Color) ---
	ImageDrawTriangleStrip  :: proc(dst: ^Image, points: ^Vector2, pointCount: c.int, color: Color) ---
	ImageDraw               :: proc(dst: ^Image, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) ---
	ImageDrawText           :: proc(dst: ^Image, text: cstring, posX: c.int, posY: c.int, fontSize: c.int, color: Color) ---
	ImageDrawTextEx         :: proc(dst: ^Image, font: Font, text: cstring, position: Vector2, fontSize: f32, spacing: f32, tint: Color) ---

	// Texture loading functions
	// NOTE: These functions require GPU access
	LoadTexture          :: proc(fileName: cstring) -> Texture2D ---
	LoadTextureFromImage :: proc(image: Image) -> Texture2D ---
	LoadTextureCubemap   :: proc(image: Image, layout: c.int) -> TextureCubemap ---
	LoadRenderTexture    :: proc(width: c.int, height: c.int) -> RenderTexture2D ---
	IsTextureValid       :: proc(texture: Texture2D) -> bool ---
	UnloadTexture        :: proc(texture: Texture2D) ---
	IsRenderTextureValid :: proc(target: RenderTexture2D) -> bool ---
	UnloadRenderTexture  :: proc(target: RenderTexture2D) ---
	UpdateTexture        :: proc(texture: Texture2D, pixels: rawptr) ---
	UpdateTextureRec     :: proc(texture: Texture2D, rec: Rectangle, pixels: rawptr) ---

	// Texture configuration functions
	GenTextureMipmaps :: proc(texture: ^Texture2D) ---
	SetTextureFilter  :: proc(texture: Texture2D, filter: c.int) ---
	SetTextureWrap    :: proc(texture: Texture2D, wrap: c.int) ---

	// Texture drawing functions
	DrawTexture       :: proc(texture: Texture2D, posX: c.int, posY: c.int, tint: Color) ---
	DrawTextureV      :: proc(texture: Texture2D, position: Vector2, tint: Color) ---
	DrawTextureEx     :: proc(texture: Texture2D, position: Vector2, rotation: f32, scale: f32, tint: Color) ---
	DrawTextureRec    :: proc(texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) ---
	DrawTexturePro    :: proc(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: f32, tint: Color) ---
	DrawTextureNPatch :: proc(texture: Texture2D, nPatchInfo: NPatchInfo, dest: Rectangle, origin: Vector2, rotation: f32, tint: Color) ---

	// Color/pixel related functions
	ColorIsEqual        :: proc(col1: Color, col2: Color) -> bool ---
	Fade                :: proc(color: Color, alpha: f32) -> Color ---
	ColorToInt          :: proc(color: Color) -> c.int ---
	ColorNormalize      :: proc(color: Color) -> Vector4 ---
	ColorFromNormalized :: proc(normalized: Vector4) -> Color ---
	ColorToHSV          :: proc(color: Color) -> Vector3 ---
	ColorFromHSV        :: proc(hue: f32, saturation: f32, value: f32) -> Color ---
	ColorTint           :: proc(color: Color, tint: Color) -> Color ---
	ColorBrightness     :: proc(color: Color, factor: f32) -> Color ---
	ColorContrast       :: proc(color: Color, contrast: f32) -> Color ---
	ColorAlpha          :: proc(color: Color, alpha: f32) -> Color ---
	ColorAlphaBlend     :: proc(dst: Color, src: Color, tint: Color) -> Color ---
	ColorLerp           :: proc(color1: Color, color2: Color, factor: f32) -> Color ---
	GetColor            :: proc(hexValue: c.uint) -> Color ---
	GetPixelColor       :: proc(srcPtr: rawptr, format: c.int) -> Color ---
	SetPixelColor       :: proc(dstPtr: rawptr, color: Color, format: c.int) ---
	GetPixelDataSize    :: proc(width: c.int, height: c.int, format: c.int) -> c.int ---

	// Font loading/unloading functions
	GetFontDefault     :: proc() -> Font ---
	LoadFont           :: proc(fileName: cstring) -> Font ---
	LoadFontEx         :: proc(fileName: cstring, fontSize: c.int, codepoints: ^c.int, codepointCount: c.int) -> Font ---
	LoadFontFromImage  :: proc(image: Image, key: Color, firstChar: c.int) -> Font ---
	LoadFontFromMemory :: proc(fileType: cstring, fileData: ^c.uchar, dataSize: c.int, fontSize: c.int, codepoints: ^c.int, codepointCount: c.int) -> Font ---
	IsFontValid        :: proc(font: Font) -> bool ---
	LoadFontData       :: proc(fileData: ^c.uchar, dataSize: c.int, fontSize: c.int, codepoints: ^c.int, codepointCount: c.int, type: c.int) -> ^GlyphInfo ---
	GenImageFontAtlas  :: proc(glyphs: ^GlyphInfo, glyphRecs: ^^Rectangle, glyphCount: c.int, fontSize: c.int, padding: c.int, packMethod: c.int) -> Image ---
	UnloadFontData     :: proc(glyphs: ^GlyphInfo, glyphCount: c.int) ---
	UnloadFont         :: proc(font: Font) ---
	ExportFontAsCode   :: proc(font: Font, fileName: cstring) -> bool ---

	// Text drawing functions
	DrawFPS            :: proc(posX: c.int, posY: c.int) ---
	DrawText           :: proc(text: cstring, posX: c.int, posY: c.int, fontSize: c.int, color: Color) ---
	DrawTextEx         :: proc(font: Font, text: cstring, position: Vector2, fontSize: f32, spacing: f32, tint: Color) ---
	DrawTextPro        :: proc(font: Font, text: cstring, position: Vector2, origin: Vector2, rotation: f32, fontSize: f32, spacing: f32, tint: Color) ---
	DrawTextCodepoint  :: proc(font: Font, codepoint: c.int, position: Vector2, fontSize: f32, tint: Color) ---
	DrawTextCodepoints :: proc(font: Font, codepoints: ^c.int, codepointCount: c.int, position: Vector2, fontSize: f32, spacing: f32, tint: Color) ---

	// Text font info functions
	SetTextLineSpacing :: proc(spacing: c.int) ---
	MeasureText        :: proc(text: cstring, fontSize: c.int) -> c.int ---
	MeasureTextEx      :: proc(font: Font, text: cstring, fontSize: f32, spacing: f32) -> Vector2 ---
	GetGlyphIndex      :: proc(font: Font, codepoint: c.int) -> c.int ---
	GetGlyphInfo       :: proc(font: Font, codepoint: c.int) -> GlyphInfo ---
	GetGlyphAtlasRec   :: proc(font: Font, codepoint: c.int) -> Rectangle ---

	// Text codepoints management functions (unicode characters)
	LoadUTF8             :: proc(codepoints: ^c.int, length: c.int) -> cstring ---
	UnloadUTF8           :: proc(text: cstring) ---
	LoadCodepoints       :: proc(text: cstring, count: ^c.int) -> ^c.int ---
	UnloadCodepoints     :: proc(codepoints: ^c.int) ---
	GetCodepointCount    :: proc(text: cstring) -> c.int ---
	GetCodepoint         :: proc(text: cstring, codepointSize: ^c.int) -> c.int ---
	GetCodepointNext     :: proc(text: cstring, codepointSize: ^c.int) -> c.int ---
	GetCodepointPrevious :: proc(text: cstring, codepointSize: ^c.int) -> c.int ---
	CodepointToUTF8      :: proc(codepoint: c.int, utf8Size: ^c.int) -> cstring ---

	// Text strings management functions (no UTF-8 strings, only byte chars)
	// WARNING 1: Most of these functions use internal static buffers, it's recommended to store returned data on user-side for re-use
	// WARNING 2: Some strings allocate memory internally for the returned strings, those strings must be free by user using MemFree()
	TextCopy      :: proc(dst: cstring, src: cstring) -> c.int ---
	TextIsEqual   :: proc(text1: cstring, text2: cstring) -> bool ---
	TextLength    :: proc(text: cstring) -> c.uint ---
	TextFormat    :: proc(text: cstring, #c_vararg _: ..any) -> cstring ---
	TextSubtext   :: proc(text: cstring, position: c.int, length: c.int) -> cstring ---
	TextReplace   :: proc(text: cstring, replace: cstring, by: cstring) -> cstring ---
	TextInsert    :: proc(text: cstring, insert: cstring, position: c.int) -> cstring ---
	TextJoin      :: proc(textList: [^]cstring, count: c.int, delimiter: cstring) -> cstring ---
	TextSplit     :: proc(text: cstring, delimiter: c.char, count: ^c.int) -> [^]cstring ---
	TextAppend    :: proc(text: cstring, append: cstring, position: ^c.int) ---
	TextFindIndex :: proc(text: cstring, find: cstring) -> c.int ---
	TextToUpper   :: proc(text: cstring) -> cstring ---
	TextToLower   :: proc(text: cstring) -> cstring ---
	TextToPascal  :: proc(text: cstring) -> cstring ---
	TextToSnake   :: proc(text: cstring) -> cstring ---
	TextToCamel   :: proc(text: cstring) -> cstring ---
	TextToInteger :: proc(text: cstring) -> c.int ---
	TextToFloat   :: proc(text: cstring) -> f32 ---

	// Basic geometric 3D shapes drawing functions
	DrawLine3D          :: proc(startPos: Vector3, endPos: Vector3, color: Color) ---
	DrawPoint3D         :: proc(position: Vector3, color: Color) ---
	DrawCircle3D        :: proc(center: Vector3, radius: f32, rotationAxis: Vector3, rotationAngle: f32, color: Color) ---
	DrawTriangle3D      :: proc(v1: Vector3, v2: Vector3, v3: Vector3, color: Color) ---
	DrawTriangleStrip3D :: proc(points: ^Vector3, pointCount: c.int, color: Color) ---
	DrawCube            :: proc(position: Vector3, width: f32, height: f32, length: f32, color: Color) ---
	DrawCubeV           :: proc(position: Vector3, size: Vector3, color: Color) ---
	DrawCubeWires       :: proc(position: Vector3, width: f32, height: f32, length: f32, color: Color) ---
	DrawCubeWiresV      :: proc(position: Vector3, size: Vector3, color: Color) ---
	DrawSphere          :: proc(centerPos: Vector3, radius: f32, color: Color) ---
	DrawSphereEx        :: proc(centerPos: Vector3, radius: f32, rings: c.int, slices: c.int, color: Color) ---
	DrawSphereWires     :: proc(centerPos: Vector3, radius: f32, rings: c.int, slices: c.int, color: Color) ---
	DrawCylinder        :: proc(position: Vector3, radiusTop: f32, radiusBottom: f32, height: f32, slices: c.int, color: Color) ---
	DrawCylinderEx      :: proc(startPos: Vector3, endPos: Vector3, startRadius: f32, endRadius: f32, sides: c.int, color: Color) ---
	DrawCylinderWires   :: proc(position: Vector3, radiusTop: f32, radiusBottom: f32, height: f32, slices: c.int, color: Color) ---
	DrawCylinderWiresEx :: proc(startPos: Vector3, endPos: Vector3, startRadius: f32, endRadius: f32, sides: c.int, color: Color) ---
	DrawCapsule         :: proc(startPos: Vector3, endPos: Vector3, radius: f32, slices: c.int, rings: c.int, color: Color) ---
	DrawCapsuleWires    :: proc(startPos: Vector3, endPos: Vector3, radius: f32, slices: c.int, rings: c.int, color: Color) ---
	DrawPlane           :: proc(centerPos: Vector3, size: Vector2, color: Color) ---
	DrawRay             :: proc(ray: Ray, color: Color) ---
	DrawGrid            :: proc(slices: c.int, spacing: f32) ---

	// Model management functions
	LoadModel           :: proc(fileName: cstring) -> Model ---
	LoadModelFromMesh   :: proc(mesh: Mesh) -> Model ---
	IsModelValid        :: proc(model: Model) -> bool ---
	UnloadModel         :: proc(model: Model) ---
	GetModelBoundingBox :: proc(model: Model) -> BoundingBox ---

	// Model drawing functions
	DrawModel         :: proc(model: Model, position: Vector3, scale: f32, tint: Color) ---
	DrawModelEx       :: proc(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) ---
	DrawModelWires    :: proc(model: Model, position: Vector3, scale: f32, tint: Color) ---
	DrawModelWiresEx  :: proc(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) ---
	DrawModelPoints   :: proc(model: Model, position: Vector3, scale: f32, tint: Color) ---
	DrawModelPointsEx :: proc(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) ---
	DrawBoundingBox   :: proc(box: BoundingBox, color: Color) ---
	DrawBillboard     :: proc(camera: Camera, texture: Texture2D, position: Vector3, scale: f32, tint: Color) ---
	DrawBillboardRec  :: proc(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, size: Vector2, tint: Color) ---
	DrawBillboardPro  :: proc(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: f32, tint: Color) ---

	// Mesh management functions
	UploadMesh         :: proc(mesh: ^Mesh, _dynamic: bool) ---
	UpdateMeshBuffer   :: proc(mesh: Mesh, index: c.int, data: rawptr, dataSize: c.int, offset: c.int) ---
	UnloadMesh         :: proc(mesh: Mesh) ---
	DrawMesh           :: proc(mesh: Mesh, material: Material, transform: Matrix) ---
	DrawMeshInstanced  :: proc(mesh: Mesh, material: Material, transforms: ^Matrix, instances: c.int) ---
	GetMeshBoundingBox :: proc(mesh: Mesh) -> BoundingBox ---
	GenMeshTangents    :: proc(mesh: ^Mesh) ---
	ExportMesh         :: proc(mesh: Mesh, fileName: cstring) -> bool ---
	ExportMeshAsCode   :: proc(mesh: Mesh, fileName: cstring) -> bool ---

	// Mesh generation functions
	GenMeshPoly       :: proc(sides: c.int, radius: f32) -> Mesh ---
	GenMeshPlane      :: proc(width: f32, length: f32, resX: c.int, resZ: c.int) -> Mesh ---
	GenMeshCube       :: proc(width: f32, height: f32, length: f32) -> Mesh ---
	GenMeshSphere     :: proc(radius: f32, rings: c.int, slices: c.int) -> Mesh ---
	GenMeshHemiSphere :: proc(radius: f32, rings: c.int, slices: c.int) -> Mesh ---
	GenMeshCylinder   :: proc(radius: f32, height: f32, slices: c.int) -> Mesh ---
	GenMeshCone       :: proc(radius: f32, height: f32, slices: c.int) -> Mesh ---
	GenMeshTorus      :: proc(radius: f32, size: f32, radSeg: c.int, sides: c.int) -> Mesh ---
	GenMeshKnot       :: proc(radius: f32, size: f32, radSeg: c.int, sides: c.int) -> Mesh ---
	GenMeshHeightmap  :: proc(heightmap: Image, size: Vector3) -> Mesh ---
	GenMeshCubicmap   :: proc(cubicmap: Image, cubeSize: Vector3) -> Mesh ---

	// Material loading/unloading functions
	LoadMaterials        :: proc(fileName: cstring, materialCount: ^c.int) -> ^Material ---
	LoadMaterialDefault  :: proc() -> Material ---
	IsMaterialValid      :: proc(material: Material) -> bool ---
	UnloadMaterial       :: proc(material: Material) ---
	SetMaterialTexture   :: proc(material: ^Material, mapType: c.int, texture: Texture2D) ---
	SetModelMeshMaterial :: proc(model: ^Model, meshId: c.int, materialId: c.int) ---

	// Model animations loading/unloading functions
	LoadModelAnimations       :: proc(fileName: cstring, animCount: ^c.int) -> ^ModelAnimation ---
	UpdateModelAnimation      :: proc(model: Model, anim: ModelAnimation, frame: c.int) ---
	UpdateModelAnimationBones :: proc(model: Model, anim: ModelAnimation, frame: c.int) ---
	UnloadModelAnimation      :: proc(anim: ModelAnimation) ---
	UnloadModelAnimations     :: proc(animations: ^ModelAnimation, animCount: c.int) ---
	IsModelAnimationValid     :: proc(model: Model, anim: ModelAnimation) -> bool ---

	// Collision detection functions
	CheckCollisionSpheres   :: proc(center1: Vector3, radius1: f32, center2: Vector3, radius2: f32) -> bool ---
	CheckCollisionBoxes     :: proc(box1: BoundingBox, box2: BoundingBox) -> bool ---
	CheckCollisionBoxSphere :: proc(box: BoundingBox, center: Vector3, radius: f32) -> bool ---
	GetRayCollisionSphere   :: proc(ray: Ray, center: Vector3, radius: f32) -> RayCollision ---
	GetRayCollisionBox      :: proc(ray: Ray, box: BoundingBox) -> RayCollision ---
	GetRayCollisionMesh     :: proc(ray: Ray, mesh: Mesh, transform: Matrix) -> RayCollision ---
	GetRayCollisionTriangle :: proc(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3) -> RayCollision ---
	GetRayCollisionQuad     :: proc(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) -> RayCollision ---

	// Audio device management functions
	InitAudioDevice    :: proc() ---
	CloseAudioDevice   :: proc() ---
	IsAudioDeviceReady :: proc() -> bool ---
	SetMasterVolume    :: proc(volume: f32) ---
	GetMasterVolume    :: proc() -> f32 ---

	// Wave/Sound loading/unloading functions
	LoadWave           :: proc(fileName: cstring) -> Wave ---
	LoadWaveFromMemory :: proc(fileType: cstring, fileData: ^c.uchar, dataSize: c.int) -> Wave ---
	IsWaveValid        :: proc(wave: Wave) -> bool ---
	LoadSound          :: proc(fileName: cstring) -> Sound ---
	LoadSoundFromWave  :: proc(wave: Wave) -> Sound ---
	LoadSoundAlias     :: proc(source: Sound) -> Sound ---
	IsSoundValid       :: proc(sound: Sound) -> bool ---
	UpdateSound        :: proc(sound: Sound, data: rawptr, sampleCount: c.int) ---
	UnloadWave         :: proc(wave: Wave) ---
	UnloadSound        :: proc(sound: Sound) ---
	UnloadSoundAlias   :: proc(alias: Sound) ---
	ExportWave         :: proc(wave: Wave, fileName: cstring) -> bool ---
	ExportWaveAsCode   :: proc(wave: Wave, fileName: cstring) -> bool ---

	// Wave/Sound management functions
	PlaySound         :: proc(sound: Sound) ---
	StopSound         :: proc(sound: Sound) ---
	PauseSound        :: proc(sound: Sound) ---
	ResumeSound       :: proc(sound: Sound) ---
	IsSoundPlaying    :: proc(sound: Sound) -> bool ---
	SetSoundVolume    :: proc(sound: Sound, volume: f32) ---
	SetSoundPitch     :: proc(sound: Sound, pitch: f32) ---
	SetSoundPan       :: proc(sound: Sound, pan: f32) ---
	WaveCopy          :: proc(wave: Wave) -> Wave ---
	WaveCrop          :: proc(wave: ^Wave, initFrame: c.int, finalFrame: c.int) ---
	WaveFormat        :: proc(wave: ^Wave, sampleRate: c.int, sampleSize: c.int, channels: c.int) ---
	LoadWaveSamples   :: proc(wave: Wave) -> ^f32 ---
	UnloadWaveSamples :: proc(samples: ^f32) ---

	// Music management functions
	LoadMusicStream           :: proc(fileName: cstring) -> Music ---
	LoadMusicStreamFromMemory :: proc(fileType: cstring, data: ^c.uchar, dataSize: c.int) -> Music ---
	IsMusicValid              :: proc(music: Music) -> bool ---
	UnloadMusicStream         :: proc(music: Music) ---
	PlayMusicStream           :: proc(music: Music) ---
	IsMusicStreamPlaying      :: proc(music: Music) -> bool ---
	UpdateMusicStream         :: proc(music: Music) ---
	StopMusicStream           :: proc(music: Music) ---
	PauseMusicStream          :: proc(music: Music) ---
	ResumeMusicStream         :: proc(music: Music) ---
	SeekMusicStream           :: proc(music: Music, position: f32) ---
	SetMusicVolume            :: proc(music: Music, volume: f32) ---
	SetMusicPitch             :: proc(music: Music, pitch: f32) ---
	SetMusicPan               :: proc(music: Music, pan: f32) ---
	GetMusicTimeLength        :: proc(music: Music) -> f32 ---
	GetMusicTimePlayed        :: proc(music: Music) -> f32 ---

	// AudioStream management functions
	LoadAudioStream                 :: proc(sampleRate: c.uint, sampleSize: c.uint, channels: c.uint) -> AudioStream ---
	IsAudioStreamValid              :: proc(stream: AudioStream) -> bool ---
	UnloadAudioStream               :: proc(stream: AudioStream) ---
	UpdateAudioStream               :: proc(stream: AudioStream, data: rawptr, frameCount: c.int) ---
	IsAudioStreamProcessed          :: proc(stream: AudioStream) -> bool ---
	PlayAudioStream                 :: proc(stream: AudioStream) ---
	PauseAudioStream                :: proc(stream: AudioStream) ---
	ResumeAudioStream               :: proc(stream: AudioStream) ---
	IsAudioStreamPlaying            :: proc(stream: AudioStream) -> bool ---
	StopAudioStream                 :: proc(stream: AudioStream) ---
	SetAudioStreamVolume            :: proc(stream: AudioStream, volume: f32) ---
	SetAudioStreamPitch             :: proc(stream: AudioStream, pitch: f32) ---
	SetAudioStreamPan               :: proc(stream: AudioStream, pan: f32) ---
	SetAudioStreamBufferSizeDefault :: proc(size: c.int) ---
	SetAudioStreamCallback          :: proc(stream: AudioStream, callback: AudioCallback) ---
	AttachAudioStreamProcessor      :: proc(stream: AudioStream, processor: AudioCallback) ---
	DetachAudioStreamProcessor      :: proc(stream: AudioStream, processor: AudioCallback) ---
	AttachAudioMixedProcessor       :: proc(processor: AudioCallback) ---
	DetachAudioMixedProcessor       :: proc(processor: AudioCallback) ---
}
