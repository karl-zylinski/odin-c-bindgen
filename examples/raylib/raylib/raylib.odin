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

// RAYLIB_H :: 

RAYLIB_VERSION_MAJOR :: 5
RAYLIB_VERSION_MINOR :: 6
RAYLIB_VERSION_PATCH :: 0
RAYLIB_VERSION  :: "5.6-dev"

// RLAPI ::        // Functions defined as 'extern' by default (implicit specifiers)

PI :: 3.14159265358979323846

DEG2RAD :: (PI/180.0)

RAD2DEG :: (180.0/PI)

// NOTE: We set some defines with some data types declared by raylib
// Other modules (raymath, rlgl) also require some of those types, so,
// to be able to use those other modules as standalone (not depending on raylib)
// this defines are very useful for internal check and avoid type (re)definitions
// RL_COLOR_TYPE :: 
// RL_RECTANGLE_TYPE :: 
// RL_VECTOR2_TYPE :: 
// RL_VECTOR3_TYPE :: 
// RL_VECTOR4_TYPE :: 
// RL_QUATERNION_TYPE :: 
// RL_MATRIX_TYPE :: 

// Some Basic Colors
// NOTE: Custom raylib color palette for amazing visuals on WHITE background
LIGHTGRAY  :: (Color){200, 200, 200, 255}   // Light Gray
GRAY       :: (Color){130, 130, 130, 255}   // Gray
DARKGRAY   :: (Color){80, 80, 80, 255}      // Dark Gray
YELLOW     :: (Color){253, 249, 0, 255}     // Yellow
GOLD       :: (Color){255, 203, 0, 255}     // Gold
ORANGE     :: (Color){255, 161, 0, 255}     // Orange
PINK       :: (Color){255, 109, 194, 255}   // Pink
RED        :: (Color){230, 41, 55, 255}     // Red
MAROON     :: (Color){190, 33, 55, 255}     // Maroon
GREEN      :: (Color){0, 228, 48, 255}      // Green
LIME       :: (Color){0, 158, 47, 255}      // Lime
DARKGREEN  :: (Color){0, 117, 44, 255}      // Dark Green
SKYBLUE    :: (Color){102, 191, 255, 255}   // Sky Blue
BLUE       :: (Color){0, 121, 241, 255}     // Blue
DARKBLUE   :: (Color){0, 82, 172, 255}      // Dark Blue
PURPLE     :: (Color){200, 122, 255, 255}   // Purple
VIOLET     :: (Color){135, 60, 190, 255}    // Violet
DARKPURPLE :: (Color){112, 31, 126, 255}    // Dark Purple
BEIGE      :: (Color){211, 176, 131, 255}   // Beige
BROWN      :: (Color){127, 106, 79, 255}    // Brown
DARKBROWN  :: (Color){76, 63, 47, 255}      // Dark Brown

WHITE      :: (Color){255, 255, 255, 255}   // White
BLACK      :: (Color){0, 0, 0, 255}         // Black
BLANK      :: (Color){0, 0, 0, 0}           // Blank (Transparent)
MAGENTA    :: (Color){255, 0, 255, 255}     // Magenta
RAYWHITE   :: (Color){245, 245, 245, 255}   // My own White (raylib logo)

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
	width:   i32,         // Image base width
	height:  i32,         // Image base height
	mipmaps: i32,         // Mipmap levels, 1 by default
	format:  PixelFormat, // Data format (PixelFormat type)
}

// Texture, tex data stored in GPU memory (VRAM)
Texture :: struct {
	id:      u32,         // OpenGL texture id
	width:   i32,         // Texture base width
	height:  i32,         // Texture base height
	mipmaps: i32,         // Mipmap levels, 1 by default
	format:  PixelFormat, // Data format (PixelFormat type)
}

// Texture2D, same as Texture
Texture2D :: Texture

// TextureCubemap, same as Texture
TextureCubemap :: Texture

// RenderTexture, fbo for texture rendering
RenderTexture :: struct {
	id:      u32,     // OpenGL framebuffer object id
	texture: Texture, // Color buffer attachment texture
	depth:   Texture, // Depth buffer attachment texture
}

// RenderTexture2D, same as RenderTexture
RenderTexture2D :: RenderTexture

// NPatchInfo, n-patch layout info
NPatchInfo :: struct {
	source: Rectangle,    // Texture source rectangle
	left:   i32,          // Left border offset
	top:    i32,          // Top border offset
	right:  i32,          // Right border offset
	bottom: i32,          // Bottom border offset
	layout: NPatchLayout, // Layout of the n-patch: 3x3, 1x3 or 3x1
}

// GlyphInfo, font characters glyphs info
GlyphInfo :: struct {
	value:    rune,  // Character value (Unicode)
	offsetX:  i32,   // Character offset X when drawing
	offsetY:  i32,   // Character offset Y when drawing
	advanceX: i32,   // Character advance position X
	image:    Image, // Character image data
}

// Font, font texture and GlyphInfo array data
Font :: struct {
	baseSize:     i32,        // Base size (default chars height)
	glyphCount:   i32,        // Number of glyph characters
	glyphPadding: i32,        // Padding around the glyph characters
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
	projection: i32,     // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

Camera :: Camera3D // Camera type fallback, defaults to Camera3D

// Camera2D, defines position/orientation in 2d space
Camera2D :: struct {
	offset:   Vector2, // Camera offset (displacement from target)
	target:   Vector2, // Camera target (rotation and zoom origin)
	rotation: f32,     // Camera rotation in degrees
	zoom:     f32,     // Camera zoom (scaling), should be 1.0f by default
}

// Mesh, vertex data and vao/vbo
Mesh :: struct {
	vertexCount:   i32,       // Number of vertices stored in arrays
	triangleCount: i32,       // Number of triangles stored (indexed or not)
	vertices:      [^]f32,    // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
	texcoords:     [^]f32,    // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
	texcoords2:    [^]f32,    // Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
	normals:       [^]f32,    // Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
	tangents:      [^]f32,    // Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
	colors:        [^]u8,     // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
	indices:       [^]u16,    // Vertex indices (in case vertex data comes indexed)
	animVertices:  [^]f32,    // Animated vertex positions (after bones transformations)
	animNormals:   [^]f32,    // Animated normals (after bones transformations)
	boneIds:       [^]u8,     // Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
	boneWeights:   [^]f32,    // Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
	boneMatrices:  [^]Matrix, // Bones animated transformation matrices
	boneCount:     i32,       // Number of bones
	vaoId:         u32,       // OpenGL Vertex Array Object id
	vboId:         [^]u32,    // OpenGL Vertex Buffer Objects id (default vertex data)
}

// Shader
Shader :: struct {
	id:   u32,    // Shader program id
	locs: [^]i32, // Shader locations array (RL_MAX_SHADER_LOCATIONS)
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
	name:   [32]i8, // Bone name
	parent: i32,    // Bone parent
}

// Model, meshes, materials and animation data
Model :: struct {
	transform:     Matrix,       // Local transform matrix
	meshCount:     i32,          // Number of meshes
	materialCount: i32,          // Number of materials
	meshes:        [^]Mesh,      // Meshes array
	materials:     [^]Material,  // Materials array
	meshMaterial:  ^i32,         // Mesh material number
	boneCount:     i32,          // Number of bones
	bones:         [^]BoneInfo,  // Bones information (skeleton)
	bindPose:      [^]Transform, // Bones base transformation (pose)
}

// ModelAnimation
ModelAnimation :: struct {
	boneCount:  i32,             // Number of bones
	frameCount: i32,             // Number of animation frames
	bones:      [^]BoneInfo,     // Bones information (skeleton)
	framePoses: [^][^]Transform, // Poses array by frame
	name:       [32]i8,          // Animation name
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
	frameCount: u32,    // Total number of frames (considering channels)
	sampleRate: u32,    // Frequency (samples per second)
	sampleSize: u32,    // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
	channels:   u32,    // Number of channels (1-mono, 2-stereo, ...)
	data:       rawptr, // Buffer data pointer
}

// AudioStream, custom audio stream
AudioStream :: struct {
	buffer:     rawptr, // Pointer to internal data used by the audio system
	processor:  rawptr, // Pointer to internal data processor, useful for audio effects
	sampleRate: u32,    // Frequency (samples per second)
	sampleSize: u32,    // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
	channels:   u32,    // Number of channels (1-mono, 2-stereo, ...)
}

// Sound
Sound :: struct {
	stream:     AudioStream, // Audio stream
	frameCount: u32,         // Total number of frames (considering channels)
}

// Music, audio stream, anything longer than ~10 seconds should be streamed
Music :: struct {
	stream:     AudioStream, // Audio stream
	frameCount: u32,         // Total number of frames (considering channels)
	looping:    bool,        // Music looping enable
	ctxType:    i32,         // Type of music context (audio filetype)
	ctxData:    rawptr,      // Audio context data, depends on type
}

// VrDeviceInfo, Head-Mounted-Display device parameters
VrDeviceInfo :: struct {
	hResolution:            i32,    // Horizontal resolution in pixels
	vResolution:            i32,    // Vertical resolution in pixels
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
	capacity: u32,        // Filepaths max entries
	count:    u32,        // Filepaths entries count
	paths:    [^]cstring, // Filepaths entries
}

// Automation event
AutomationEvent :: struct {
	frame:  u32,    // Event frame
	type:   u32,    // Event type (AutomationEventType)
	params: [4]i32, // Event parameters (if required)
}

// Automation event list
AutomationEventList :: struct {
	capacity: u32,              // Events max entries (MAX_AUTOMATION_EVENTS)
	count:    u32,              // Events entries count
	events:   ^AutomationEvent, // Events entries
}

//----------------------------------------------------------------------------------
// Enumerators Definition
//----------------------------------------------------------------------------------
// System/Window config flags
// NOTE: Every bit registers one state (use it with bit masks)
// By default all flags are set to 0
ConfigFlag :: enum i32 {
	VSYNC_HINT               = 6,  // Set to try enabling V-Sync on GPU
	FULLSCREEN_MODE          = 1,  // Set to run program in fullscreen
	WINDOW_RESIZABLE         = 2,  // Set to allow resizable window
	WINDOW_UNDECORATED       = 3,  // Set to disable window decoration (frame and buttons)
	WINDOW_HIDDEN            = 7,  // Set to hide window
	WINDOW_MINIMIZED         = 9,  // Set to minimize window (iconify)
	WINDOW_MAXIMIZED         = 10, // Set to maximize window (expanded to monitor)
	WINDOW_UNFOCUSED         = 11, // Set to window non focused
	WINDOW_TOPMOST           = 12, // Set to window always on top
	WINDOW_ALWAYS_RUN        = 8,  // Set to allow windows running while minimized
	WINDOW_TRANSPARENT       = 4,  // Set to allow transparent framebuffer
	WINDOW_HIGHDPI           = 13, // Set to support HighDPI
	WINDOW_MOUSE_PASSTHROUGH = 14, // Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
	BORDERLESS_WINDOWED_MODE = 15, // Set to run program in borderless windowed mode
	MSAA_4X_HINT             = 5,  // Set to try enabling MSAA 4X
	INTERLACED_HINT          = 16, // Set to try enabling interlaced video format (for V3D)
}

ConfigFlags :: distinct bit_set[ConfigFlag; i32]

// Trace log level
// NOTE: Organized by priority level
TraceLogLevel :: enum i32 {
	ALL,     // Display all logs
	TRACE,   // Trace logging, intended for internal use only
	DEBUG,   // Debug logging, used for internal debugging, it should be disabled on release builds
	INFO,    // Info logging, used for program execution info
	WARNING, // Warning logging, used on recoverable failures
	ERROR,   // Error logging, used on unrecoverable failures
	FATAL,   // Fatal logging, used to abort program: exit(EXIT_FAILURE)
	NONE,    // Disable logging
}

// Keyboard keys (US keyboard layout)
// NOTE: Use GetKeyPressed() to allow redefining
// required keys for alternative layouts
KeyboardKey :: enum i32 {
	NULL          = 0,   // Key: NULL, used for no key pressed
	APOSTROPHE    = 39,  // Key: '
	COMMA         = 44,  // Key: ,
	MINUS         = 45,  // Key: -
	PERIOD        = 46,  // Key: .
	SLASH         = 47,  // Key: /
	ZERO          = 48,  // Key: 0
	ONE           = 49,  // Key: 1
	TWO           = 50,  // Key: 2
	THREE         = 51,  // Key: 3
	FOUR          = 52,  // Key: 4
	FIVE          = 53,  // Key: 5
	SIX           = 54,  // Key: 6
	SEVEN         = 55,  // Key: 7
	EIGHT         = 56,  // Key: 8
	NINE          = 57,  // Key: 9
	SEMICOLON     = 59,  // Key: ;
	EQUAL         = 61,  // Key: =
	A             = 65,  // Key: A | a
	B             = 66,  // Key: B | b
	C             = 67,  // Key: C | c
	D             = 68,  // Key: D | d
	E             = 69,  // Key: E | e
	F             = 70,  // Key: F | f
	G             = 71,  // Key: G | g
	H             = 72,  // Key: H | h
	I             = 73,  // Key: I | i
	J             = 74,  // Key: J | j
	K             = 75,  // Key: K | k
	L             = 76,  // Key: L | l
	M             = 77,  // Key: M | m
	N             = 78,  // Key: N | n
	O             = 79,  // Key: O | o
	P             = 80,  // Key: P | p
	Q             = 81,  // Key: Q | q
	R             = 82,  // Key: R | r
	S             = 83,  // Key: S | s
	T             = 84,  // Key: T | t
	U             = 85,  // Key: U | u
	V             = 86,  // Key: V | v
	W             = 87,  // Key: W | w
	X             = 88,  // Key: X | x
	Y             = 89,  // Key: Y | y
	Z             = 90,  // Key: Z | z
	LEFT_BRACKET  = 91,  // Key: [
	BACKSLASH     = 92,  // Key: '\'
	RIGHT_BRACKET = 93,  // Key: ]
	GRAVE         = 96,  // Key: `
	SPACE         = 32,  // Key: Space
	ESCAPE        = 256, // Key: Esc
	ENTER         = 257, // Key: Enter
	TAB           = 258, // Key: Tab
	BACKSPACE     = 259, // Key: Backspace
	INSERT        = 260, // Key: Ins
	DELETE        = 261, // Key: Del
	RIGHT         = 262, // Key: Cursor right
	LEFT          = 263, // Key: Cursor left
	DOWN          = 264, // Key: Cursor down
	UP            = 265, // Key: Cursor up
	PAGE_UP       = 266, // Key: Page up
	PAGE_DOWN     = 267, // Key: Page down
	HOME          = 268, // Key: Home
	END           = 269, // Key: End
	CAPS_LOCK     = 280, // Key: Caps lock
	SCROLL_LOCK   = 281, // Key: Scroll down
	NUM_LOCK      = 282, // Key: Num lock
	PRINT_SCREEN  = 283, // Key: Print screen
	PAUSE         = 284, // Key: Pause
	F1            = 290, // Key: F1
	F2            = 291, // Key: F2
	F3            = 292, // Key: F3
	F4            = 293, // Key: F4
	F5            = 294, // Key: F5
	F6            = 295, // Key: F6
	F7            = 296, // Key: F7
	F8            = 297, // Key: F8
	F9            = 298, // Key: F9
	F10           = 299, // Key: F10
	F11           = 300, // Key: F11
	F12           = 301, // Key: F12
	LEFT_SHIFT    = 340, // Key: Shift left
	LEFT_CONTROL  = 341, // Key: Control left
	LEFT_ALT      = 342, // Key: Alt left
	LEFT_SUPER    = 343, // Key: Super left
	RIGHT_SHIFT   = 344, // Key: Shift right
	RIGHT_CONTROL = 345, // Key: Control right
	RIGHT_ALT     = 346, // Key: Alt right
	RIGHT_SUPER   = 347, // Key: Super right
	KB_MENU       = 348, // Key: KB menu
	KP_0          = 320, // Key: Keypad 0
	KP_1          = 321, // Key: Keypad 1
	KP_2          = 322, // Key: Keypad 2
	KP_3          = 323, // Key: Keypad 3
	KP_4          = 324, // Key: Keypad 4
	KP_5          = 325, // Key: Keypad 5
	KP_6          = 326, // Key: Keypad 6
	KP_7          = 327, // Key: Keypad 7
	KP_8          = 328, // Key: Keypad 8
	KP_9          = 329, // Key: Keypad 9
	KP_DECIMAL    = 330, // Key: Keypad .
	KP_DIVIDE     = 331, // Key: Keypad /
	KP_MULTIPLY   = 332, // Key: Keypad *
	KP_SUBTRACT   = 333, // Key: Keypad -
	KP_ADD        = 334, // Key: Keypad +
	KP_ENTER      = 335, // Key: Keypad Enter
	KP_EQUAL      = 336, // Key: Keypad =
	BACK          = 4,   // Key: Android back button
	MENU          = 5,   // Key: Android menu button
	VOLUME_UP     = 24,  // Key: Android volume up button
	VOLUME_DOWN   = 25,  // Key: Android volume down button
}

// Add backwards compatibility support for deprecated names
// MOUSE_LEFT_BUTTON   :: MOUSE_BUTTON_LEFT
// MOUSE_RIGHT_BUTTON  :: MOUSE_BUTTON_RIGHT
// MOUSE_MIDDLE_BUTTON :: MOUSE_BUTTON_MIDDLE

// Mouse buttons
MouseButton :: enum i32 {
	LEFT,    // Mouse button left
	RIGHT,   // Mouse button right
	MIDDLE,  // Mouse button middle (pressed wheel)
	SIDE,    // Mouse button side (advanced mouse device)
	EXTRA,   // Mouse button extra (advanced mouse device)
	FORWARD, // Mouse button forward (advanced mouse device)
	BACK,    // Mouse button back (advanced mouse device)
}

// Mouse cursor
MouseCursor :: enum i32 {
	DEFAULT,       // Default pointer shape
	ARROW,         // Arrow shape
	IBEAM,         // Text writing cursor shape
	CROSSHAIR,     // Cross shape
	POINTING_HAND, // Pointing hand cursor
	RESIZE_EW,     // Horizontal resize/move arrow shape
	RESIZE_NS,     // Vertical resize/move arrow shape
	RESIZE_NWSE,   // Top-left to bottom-right diagonal resize/move arrow shape
	RESIZE_NESW,   // The top-right to bottom-left diagonal resize/move arrow shape
	RESIZE_ALL,    // The omnidirectional resize/move cursor shape
	NOT_ALLOWED,   // The operation-not-allowed shape
}

// Gamepad buttons
GamepadButton :: enum i32 {
	UNKNOWN,          // Unknown button, just for error checking
	LEFT_FACE_UP,     // Gamepad left DPAD up button
	LEFT_FACE_RIGHT,  // Gamepad left DPAD right button
	LEFT_FACE_DOWN,   // Gamepad left DPAD down button
	LEFT_FACE_LEFT,   // Gamepad left DPAD left button
	RIGHT_FACE_UP,    // Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
	RIGHT_FACE_RIGHT, // Gamepad right button right (i.e. PS3: Circle, Xbox: B)
	RIGHT_FACE_DOWN,  // Gamepad right button down (i.e. PS3: Cross, Xbox: A)
	RIGHT_FACE_LEFT,  // Gamepad right button left (i.e. PS3: Square, Xbox: X)
	LEFT_TRIGGER_1,   // Gamepad top/back trigger left (first), it could be a trailing button
	LEFT_TRIGGER_2,   // Gamepad top/back trigger left (second), it could be a trailing button
	RIGHT_TRIGGER_1,  // Gamepad top/back trigger right (first), it could be a trailing button
	RIGHT_TRIGGER_2,  // Gamepad top/back trigger right (second), it could be a trailing button
	MIDDLE_LEFT,      // Gamepad center buttons, left one (i.e. PS3: Select)
	MIDDLE,           // Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
	MIDDLE_RIGHT,     // Gamepad center buttons, right one (i.e. PS3: Start)
	LEFT_THUMB,       // Gamepad joystick pressed button left
	RIGHT_THUMB,      // Gamepad joystick pressed button right
}

// Gamepad axis
GamepadAxis :: enum i32 {
	LEFT_X,        // Gamepad left stick X axis
	LEFT_Y,        // Gamepad left stick Y axis
	RIGHT_X,       // Gamepad right stick X axis
	RIGHT_Y,       // Gamepad right stick Y axis
	LEFT_TRIGGER,  // Gamepad back trigger left, pressure level: [1..-1]
	RIGHT_TRIGGER, // Gamepad back trigger right, pressure level: [1..-1]
}

// Material map index
MaterialMapIndex :: enum i32 {
	ALBEDO,     // Albedo material (same as: MATERIAL_MAP_DIFFUSE)
	METALNESS,  // Metalness material (same as: MATERIAL_MAP_SPECULAR)
	NORMAL,     // Normal material
	ROUGHNESS,  // Roughness material
	OCCLUSION,  // Ambient occlusion material
	EMISSION,   // Emission material
	HEIGHT,     // Heightmap material
	CUBEMAP,    // Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	IRRADIANCE, // Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	PREFILTER,  // Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	BRDF,       // Brdf material
}

// MATERIAL_MAP_DIFFUSE      :: MATERIAL_MAP_ALBEDO
// MATERIAL_MAP_SPECULAR     :: MATERIAL_MAP_METALNESS

// Shader location index
ShaderLocationIndex :: enum i32 {
	VERTEX_POSITION,    // Shader location: vertex attribute: position
	VERTEX_TEXCOORD01,  // Shader location: vertex attribute: texcoord01
	VERTEX_TEXCOORD02,  // Shader location: vertex attribute: texcoord02
	VERTEX_NORMAL,      // Shader location: vertex attribute: normal
	VERTEX_TANGENT,     // Shader location: vertex attribute: tangent
	VERTEX_COLOR,       // Shader location: vertex attribute: color
	MATRIX_MVP,         // Shader location: matrix uniform: model-view-projection
	MATRIX_VIEW,        // Shader location: matrix uniform: view (camera transform)
	MATRIX_PROJECTION,  // Shader location: matrix uniform: projection
	MATRIX_MODEL,       // Shader location: matrix uniform: model (transform)
	MATRIX_NORMAL,      // Shader location: matrix uniform: normal
	VECTOR_VIEW,        // Shader location: vector uniform: view
	COLOR_DIFFUSE,      // Shader location: vector uniform: diffuse color
	COLOR_SPECULAR,     // Shader location: vector uniform: specular color
	COLOR_AMBIENT,      // Shader location: vector uniform: ambient color
	MAP_ALBEDO,         // Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
	MAP_METALNESS,      // Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
	MAP_NORMAL,         // Shader location: sampler2d texture: normal
	MAP_ROUGHNESS,      // Shader location: sampler2d texture: roughness
	MAP_OCCLUSION,      // Shader location: sampler2d texture: occlusion
	MAP_EMISSION,       // Shader location: sampler2d texture: emission
	MAP_HEIGHT,         // Shader location: sampler2d texture: height
	MAP_CUBEMAP,        // Shader location: samplerCube texture: cubemap
	MAP_IRRADIANCE,     // Shader location: samplerCube texture: irradiance
	MAP_PREFILTER,      // Shader location: samplerCube texture: prefilter
	MAP_BRDF,           // Shader location: sampler2d texture: brdf
	VERTEX_BONEIDS,     // Shader location: vertex attribute: boneIds
	VERTEX_BONEWEIGHTS, // Shader location: vertex attribute: boneWeights
	BONE_MATRICES,      // Shader location: array of matrices uniform: boneMatrices
	VERTEX_INSTANCE_TX, // Shader location: vertex attribute: instanceTransform
}

// SHADER_LOC_MAP_DIFFUSE      :: SHADER_LOC_MAP_ALBEDO
// SHADER_LOC_MAP_SPECULAR     :: SHADER_LOC_MAP_METALNESS

// Shader uniform data type
ShaderUniformDataType :: enum i32 {
	FLOAT,     // Shader uniform type: float
	VEC2,      // Shader uniform type: vec2 (2 float)
	VEC3,      // Shader uniform type: vec3 (3 float)
	VEC4,      // Shader uniform type: vec4 (4 float)
	INT,       // Shader uniform type: int
	IVEC2,     // Shader uniform type: ivec2 (2 int)
	IVEC3,     // Shader uniform type: ivec3 (3 int)
	IVEC4,     // Shader uniform type: ivec4 (4 int)
	UINT,      // Shader uniform type: unsigned int
	UIVEC2,    // Shader uniform type: uivec2 (2 unsigned int)
	UIVEC3,    // Shader uniform type: uivec3 (3 unsigned int)
	UIVEC4,    // Shader uniform type: uivec4 (4 unsigned int)
	SAMPLER2D, // Shader uniform type: sampler2d
}

// Shader attribute data types
ShaderAttributeDataType :: enum i32 {
	FLOAT, // Shader attribute type: float
	VEC2,  // Shader attribute type: vec2 (2 float)
	VEC3,  // Shader attribute type: vec3 (3 float)
	VEC4,  // Shader attribute type: vec4 (4 float)
}

// Pixel formats
// NOTE: Support depends on OpenGL version and platform
PixelFormat :: enum i32 {
	UNCOMPRESSED_GRAYSCALE    = 1,  // 8 bit per pixel (no alpha)
	UNCOMPRESSED_GRAY_ALPHA   = 2,  // 8*2 bpp (2 channels)
	UNCOMPRESSED_R5G6B5       = 3,  // 16 bpp
	UNCOMPRESSED_R8G8B8       = 4,  // 24 bpp
	UNCOMPRESSED_R5G5B5A1     = 5,  // 16 bpp (1 bit alpha)
	UNCOMPRESSED_R4G4B4A4     = 6,  // 16 bpp (4 bit alpha)
	UNCOMPRESSED_R8G8B8A8     = 7,  // 32 bpp
	UNCOMPRESSED_R32          = 8,  // 32 bpp (1 channel - float)
	UNCOMPRESSED_R32G32B32    = 9,  // 32*3 bpp (3 channels - float)
	UNCOMPRESSED_R32G32B32A32 = 10, // 32*4 bpp (4 channels - float)
	UNCOMPRESSED_R16          = 11, // 16 bpp (1 channel - half float)
	UNCOMPRESSED_R16G16B16    = 12, // 16*3 bpp (3 channels - half float)
	UNCOMPRESSED_R16G16B16A16 = 13, // 16*4 bpp (4 channels - half float)
	COMPRESSED_DXT1_RGB       = 14, // 4 bpp (no alpha)
	COMPRESSED_DXT1_RGBA      = 15, // 4 bpp (1 bit alpha)
	COMPRESSED_DXT3_RGBA      = 16, // 8 bpp
	COMPRESSED_DXT5_RGBA      = 17, // 8 bpp
	COMPRESSED_ETC1_RGB       = 18, // 4 bpp
	COMPRESSED_ETC2_RGB       = 19, // 4 bpp
	COMPRESSED_ETC2_EAC_RGBA  = 20, // 8 bpp
	COMPRESSED_PVRT_RGB       = 21, // 4 bpp
	COMPRESSED_PVRT_RGBA      = 22, // 4 bpp
	COMPRESSED_ASTC_4x4_RGBA  = 23, // 8 bpp
	COMPRESSED_ASTC_8x8_RGBA  = 24, // 2 bpp
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
TextureFilter :: enum i32 {
	POINT,           // No filter, just pixel approximation
	BILINEAR,        // Linear filtering
	TRILINEAR,       // Trilinear filtering (linear with mipmaps)
	ANISOTROPIC_4X,  // Anisotropic filtering 4x
	ANISOTROPIC_8X,  // Anisotropic filtering 8x
	ANISOTROPIC_16X, // Anisotropic filtering 16x
}

// Texture parameters: wrap mode
TextureWrap :: enum i32 {
	REPEAT,        // Repeats texture in tiled mode
	CLAMP,         // Clamps texture to edge pixel in tiled mode
	MIRROR_REPEAT, // Mirrors and repeats the texture in tiled mode
	MIRROR_CLAMP,  // Mirrors and clamps to border the texture in tiled mode
}

// Cubemap layouts
CubemapLayout :: enum i32 {
	AUTO_DETECT,         // Automatically detect layout type
	LINE_VERTICAL,       // Layout is defined by a vertical line with faces
	LINE_HORIZONTAL,     // Layout is defined by a horizontal line with faces
	CROSS_THREE_BY_FOUR, // Layout is defined by a 3x4 cross with cubemap faces
	CROSS_FOUR_BY_THREE, // Layout is defined by a 4x3 cross with cubemap faces
}

// Font type, defines generation method
FontType :: enum i32 {
	DEFAULT, // Default font generation, anti-aliased
	BITMAP,  // Bitmap font generation, no anti-aliasing
	SDF,     // SDF font generation, requires external shader
}

// Color blending modes (pre-defined)
BlendMode :: enum i32 {
	ALPHA,             // Blend textures considering alpha (default)
	ADDITIVE,          // Blend textures adding colors
	MULTIPLIED,        // Blend textures multiplying colors
	ADD_COLORS,        // Blend textures adding colors (alternative)
	SUBTRACT_COLORS,   // Blend textures subtracting colors (alternative)
	ALPHA_PREMULTIPLY, // Blend premultiplied textures considering alpha
	CUSTOM,            // Blend textures using custom src/dst factors (use rlSetBlendFactors())
	CUSTOM_SEPARATE,   // Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
}

// Gesture
// NOTE: Provided as bit-wise flags to enable only desired gestures
Gesture :: enum i32 {
	TAP,         // Tap gesture
	DOUBLETAP,   // Double tap gesture
	HOLD,        // Hold gesture
	DRAG,        // Drag gesture
	SWIPE_RIGHT, // Swipe right gesture
	SWIPE_LEFT,  // Swipe left gesture
	SWIPE_UP,    // Swipe up gesture
	SWIPE_DOWN,  // Swipe down gesture
	PINCH_IN,    // Pinch in gesture
	PINCH_OUT,   // Pinch out gesture
}

Gestures :: distinct bit_set[Gesture; i32]

// Camera system modes
CameraMode :: enum i32 {
	CUSTOM,       // Camera custom, controlled by user (UpdateCamera() does nothing)
	FREE,         // Camera free mode
	ORBITAL,      // Camera orbital, around target, zoom supported
	FIRST_PERSON, // Camera first person
	THIRD_PERSON, // Camera third person
}

// Camera projection
CameraProjection :: enum i32 {
	PERSPECTIVE,  // Perspective projection
	ORTHOGRAPHIC, // Orthographic projection
}

// N-patch layout
NPatchLayout :: enum i32 {
	NINE_PATCH,             // Npatch layout: 3x3 tiles
	THREE_PATCH_VERTICAL,   // Npatch layout: 1x3 tiles
	THREE_PATCH_HORIZONTAL, // Npatch layout: 3x1 tiles
}

// Callbacks to hook some internal functions
// WARNING: These callbacks are intended for advanced users
TraceLogCallback :: proc "c" (i32, cstring, c.va_list) // Logging: Redirect trace log messages

LoadFileDataCallback :: proc "c" (cstring, ^i32) -> ^u8 // FileIO: Load binary data

SaveFileDataCallback :: proc "c" (cstring, rawptr, i32) -> bool // FileIO: Save binary data

LoadFileTextCallback :: proc "c" (cstring) -> cstring // FileIO: Load text data

SaveFileTextCallback :: proc "c" (cstring, cstring) -> bool // FileIO: Save text data

// Screen-space-related functions
GetMouseRay :: GetScreenToWorldRay     // Compatibility hack for previous raylib versions

//------------------------------------------------------------------------------------
// Audio Loading and Playing Functions (Module: audio)
//------------------------------------------------------------------------------------
AudioCallback :: proc "c" (rawptr, u32)

@(default_calling_convention="c", link_prefix="")
foreign lib {
	// Window-related functions
	InitWindow               :: proc(width: i32, height: i32, title: cstring) --- // Initialize window and OpenGL context
	CloseWindow              :: proc() ---                                        // Close window and unload OpenGL context
	WindowShouldClose        :: proc() -> bool ---                                // Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
	IsWindowReady            :: proc() -> bool ---                                // Check if window has been initialized successfully
	IsWindowFullscreen       :: proc() -> bool ---                                // Check if window is currently fullscreen
	IsWindowHidden           :: proc() -> bool ---                                // Check if window is currently hidden
	IsWindowMinimized        :: proc() -> bool ---                                // Check if window is currently minimized
	IsWindowMaximized        :: proc() -> bool ---                                // Check if window is currently maximized
	IsWindowFocused          :: proc() -> bool ---                                // Check if window is currently focused
	IsWindowResized          :: proc() -> bool ---                                // Check if window has been resized last frame
	IsWindowState            :: proc(flag: u32) -> bool ---                       // Check if one specific window flag is enabled
	SetWindowState           :: proc(flags: u32) ---                              // Set window configuration state using flags
	ClearWindowState         :: proc(flags: u32) ---                              // Clear window configuration state flags
	ToggleFullscreen         :: proc() ---                                        // Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
	ToggleBorderlessWindowed :: proc() ---                                        // Toggle window state: borderless windowed, resizes window to match monitor resolution
	MaximizeWindow           :: proc() ---                                        // Set window state: maximized, if resizable
	MinimizeWindow           :: proc() ---                                        // Set window state: minimized, if resizable
	RestoreWindow            :: proc() ---                                        // Set window state: not minimized/maximized
	SetWindowIcon            :: proc(image: Image) ---                            // Set icon for window (single image, RGBA 32bit)
	SetWindowIcons           :: proc(images: ^Image, count: i32) ---              // Set icon for window (multiple images, RGBA 32bit)
	SetWindowTitle           :: proc(title: cstring) ---                          // Set title for window
	SetWindowPosition        :: proc(x: i32, y: i32) ---                          // Set window position on screen
	SetWindowMonitor         :: proc(monitor: i32) ---                            // Set monitor for the current window
	SetWindowMinSize         :: proc(width: i32, height: i32) ---                 // Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
	SetWindowMaxSize         :: proc(width: i32, height: i32) ---                 // Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
	SetWindowSize            :: proc(width: i32, height: i32) ---                 // Set window dimensions
	SetWindowOpacity         :: proc(opacity: f32) ---                            // Set window opacity [0.0f..1.0f]
	SetWindowFocused         :: proc() ---                                        // Set window focused
	GetWindowHandle          :: proc() -> rawptr ---                              // Get native window handle
	GetScreenWidth           :: proc() -> i32 ---                                 // Get current screen width
	GetScreenHeight          :: proc() -> i32 ---                                 // Get current screen height
	GetRenderWidth           :: proc() -> i32 ---                                 // Get current render width (it considers HiDPI)
	GetRenderHeight          :: proc() -> i32 ---                                 // Get current render height (it considers HiDPI)
	GetMonitorCount          :: proc() -> i32 ---                                 // Get number of connected monitors
	GetCurrentMonitor        :: proc() -> i32 ---                                 // Get current monitor where window is placed
	GetMonitorPosition       :: proc(monitor: i32) -> Vector2 ---                 // Get specified monitor position
	GetMonitorWidth          :: proc(monitor: i32) -> i32 ---                     // Get specified monitor width (current video mode used by monitor)
	GetMonitorHeight         :: proc(monitor: i32) -> i32 ---                     // Get specified monitor height (current video mode used by monitor)
	GetMonitorPhysicalWidth  :: proc(monitor: i32) -> i32 ---                     // Get specified monitor physical width in millimetres
	GetMonitorPhysicalHeight :: proc(monitor: i32) -> i32 ---                     // Get specified monitor physical height in millimetres
	GetMonitorRefreshRate    :: proc(monitor: i32) -> i32 ---                     // Get specified monitor refresh rate
	GetWindowPosition        :: proc() -> Vector2 ---                             // Get window position XY on monitor
	GetWindowScaleDPI        :: proc() -> Vector2 ---                             // Get window scale DPI factor
	GetMonitorName           :: proc(monitor: i32) -> cstring ---                 // Get the human-readable, UTF-8 encoded name of the specified monitor
	SetClipboardText         :: proc(text: cstring) ---                           // Set clipboard text content
	GetClipboardText         :: proc() -> cstring ---                             // Get clipboard text content
	GetClipboardImage        :: proc() -> Image ---                               // Get clipboard image content
	EnableEventWaiting       :: proc() ---                                        // Enable waiting for events on EndDrawing(), no automatic event polling
	DisableEventWaiting      :: proc() ---                                        // Disable waiting for events on EndDrawing(), automatic events polling

	// Cursor-related functions
	ShowCursor       :: proc() ---         // Shows cursor
	HideCursor       :: proc() ---         // Hides cursor
	IsCursorHidden   :: proc() -> bool --- // Check if cursor is not visible
	EnableCursor     :: proc() ---         // Enables cursor (unlock cursor)
	DisableCursor    :: proc() ---         // Disables cursor (lock cursor)
	IsCursorOnScreen :: proc() -> bool --- // Check if cursor is on the screen

	// Drawing-related functions
	ClearBackground   :: proc(color: Color) ---                            // Set background color (framebuffer clear color)
	BeginDrawing      :: proc() ---                                        // Setup canvas (framebuffer) to start drawing
	EndDrawing        :: proc() ---                                        // End canvas drawing and swap buffers (double buffering)
	BeginMode2D       :: proc(camera: Camera2D) ---                        // Begin 2D mode with custom camera (2D)
	EndMode2D         :: proc() ---                                        // Ends 2D mode with custom camera
	BeginMode3D       :: proc(camera: Camera3D) ---                        // Begin 3D mode with custom camera (3D)
	EndMode3D         :: proc() ---                                        // Ends 3D mode and returns to default 2D orthographic mode
	BeginTextureMode  :: proc(target: RenderTexture2D) ---                 // Begin drawing to render texture
	EndTextureMode    :: proc() ---                                        // Ends drawing to render texture
	BeginShaderMode   :: proc(shader: Shader) ---                          // Begin custom shader drawing
	EndShaderMode     :: proc() ---                                        // End custom shader drawing (use default shader)
	BeginBlendMode    :: proc(mode: i32) ---                               // Begin blending mode (alpha, additive, multiplied, subtract, custom)
	EndBlendMode      :: proc() ---                                        // End blending mode (reset to default: alpha blending)
	BeginScissorMode  :: proc(x: i32, y: i32, width: i32, height: i32) --- // Begin scissor mode (define screen area for following drawing)
	EndScissorMode    :: proc() ---                                        // End scissor mode
	BeginVrStereoMode :: proc(config: VrStereoConfig) ---                  // Begin stereo rendering (requires VR simulator)
	EndVrStereoMode   :: proc() ---                                        // End stereo rendering (requires VR simulator)

	// VR stereo config functions for VR simulator
	LoadVrStereoConfig   :: proc(device: VrDeviceInfo) -> VrStereoConfig --- // Load VR stereo config for VR simulator device parameters
	UnloadVrStereoConfig :: proc(config: VrStereoConfig) ---                 // Unload VR stereo config

	// Shader management functions
	// NOTE: Shader functionality is not available on OpenGL 1.1
	LoadShader              :: proc(vsFileName: cstring, fsFileName: cstring) -> Shader --- // Load shader from files and bind default locations
	LoadShaderFromMemory    :: proc(vsCode: cstring, fsCode: cstring) -> Shader ---         // Load shader from code strings and bind default locations
	IsShaderValid           :: proc(shader: Shader) -> bool ---                             // Check if a shader is valid (loaded on GPU)
	GetShaderLocation       :: proc(shader: Shader, uniformName: cstring) -> i32 ---        // Get shader uniform location
	GetShaderLocationAttrib :: proc(shader: Shader, attribName: cstring) -> i32 ---         // Get shader attribute location
	SetShaderValue          :: proc(shader: Shader, locIndex: i32, value: rawptr, uniformType: ShaderUniformDataType) --- // Set shader uniform value
	SetShaderValueV         :: proc(shader: Shader, locIndex: i32, value: rawptr, uniformType: ShaderUniformDataType, count: i32) --- // Set shader uniform value vector
	SetShaderValueMatrix    :: proc(shader: Shader, locIndex: i32, mat: Matrix) ---         // Set shader uniform value (matrix 4x4)
	SetShaderValueTexture   :: proc(shader: Shader, locIndex: i32, texture: Texture2D) ---  // Set shader uniform value and bind the texture (sampler2d)
	UnloadShader            :: proc(shader: Shader) ---                                     // Unload shader from GPU memory (VRAM)
	GetScreenToWorldRay     :: proc(position: Vector2, camera: Camera) -> Ray ---           // Get a ray trace from screen position (i.e mouse)
	GetScreenToWorldRayEx   :: proc(position: Vector2, camera: Camera, width: i32, height: i32) -> Ray --- // Get a ray trace from screen position (i.e mouse) in a viewport
	GetWorldToScreen        :: proc(position: Vector3, camera: Camera) -> Vector2 ---       // Get the screen space position for a 3d world space position
	GetWorldToScreenEx      :: proc(position: Vector3, camera: Camera, width: i32, height: i32) -> Vector2 --- // Get size position for a 3d world space position
	GetWorldToScreen2D      :: proc(position: Vector2, camera: Camera2D) -> Vector2 ---     // Get the screen space position for a 2d camera world space position
	GetScreenToWorld2D      :: proc(position: Vector2, camera: Camera2D) -> Vector2 ---     // Get the world space position for a 2d camera screen space position
	GetCameraMatrix         :: proc(camera: Camera) -> Matrix ---                           // Get camera transform matrix (view matrix)
	GetCameraMatrix2D       :: proc(camera: Camera2D) -> Matrix ---                         // Get camera 2d transform matrix

	// Timing-related functions
	SetTargetFPS :: proc(fps: i32) --- // Set target FPS (maximum)
	GetFrameTime :: proc() -> f32 ---  // Get time in seconds for last frame drawn (delta time)
	GetTime      :: proc() -> f64 ---  // Get elapsed time in seconds since InitWindow()
	GetFPS       :: proc() -> i32 ---  // Get current FPS

	// Custom frame control functions
	// NOTE: Those functions are intended for advanced users that want full control over the frame processing
	// By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
	// To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
	SwapScreenBuffer :: proc() ---             // Swap back buffer with front buffer (screen drawing)
	PollInputEvents  :: proc() ---             // Register all input events
	WaitTime         :: proc(seconds: f64) --- // Wait for some time (halt program execution)

	// Random values generation functions
	SetRandomSeed        :: proc(seed: u32) ---                              // Set the seed for the random number generator
	GetRandomValue       :: proc(min: i32, max: i32) -> i32 ---              // Get a random value between min and max (both included)
	LoadRandomSequence   :: proc(count: u32, min: i32, max: i32) -> ^i32 --- // Load random values sequence, no values repeated
	UnloadRandomSequence :: proc(sequence: ^i32) ---                         // Unload random values sequence

	// Misc. functions
	TakeScreenshot :: proc(fileName: cstring) ---  // Takes a screenshot of current screen (filename extension defines format)
	SetConfigFlags :: proc(flags: ConfigFlags) --- // Setup init configuration flags (view FLAGS)
	OpenURL        :: proc(url: cstring) ---       // Open URL with default system browser (if available)

	// NOTE: Following functions implemented in module [utils]
	//------------------------------------------------------------------
	TraceLog         :: proc(logLevel: i32, text: cstring, #c_vararg _: ..any) --- // Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
	SetTraceLogLevel :: proc(logLevel: i32) ---                                    // Set the current threshold (minimum) log level
	MemAlloc         :: proc(size: u32) -> rawptr ---                              // Internal memory allocator
	MemRealloc       :: proc(ptr: rawptr, size: u32) -> rawptr ---                 // Internal memory reallocator
	MemFree          :: proc(ptr: rawptr) ---                                      // Internal memory free

	// Set custom callbacks
	// WARNING: Callbacks setup is intended for advanced users
	SetTraceLogCallback     :: proc(callback: TraceLogCallback) ---     // Set custom trace log
	SetLoadFileDataCallback :: proc(callback: LoadFileDataCallback) --- // Set custom file binary data loader
	SetSaveFileDataCallback :: proc(callback: SaveFileDataCallback) --- // Set custom file binary data saver
	SetLoadFileTextCallback :: proc(callback: LoadFileTextCallback) --- // Set custom file text data loader
	SetSaveFileTextCallback :: proc(callback: SaveFileTextCallback) --- // Set custom file text data saver

	// Files management functions
	LoadFileData     :: proc(fileName: cstring, dataSize: ^i32) -> ^u8 ---               // Load file data as byte array (read)
	UnloadFileData   :: proc(data: ^u8) ---                                              // Unload file data allocated by LoadFileData()
	SaveFileData     :: proc(fileName: cstring, data: rawptr, dataSize: i32) -> bool --- // Save data to file from byte array (write), returns true on success
	ExportDataAsCode :: proc(data: ^u8, dataSize: i32, fileName: cstring) -> bool ---    // Export data to code (.h), returns true on success
	LoadFileText     :: proc(fileName: cstring) -> cstring ---                           // Load text data from file (read), returns a '\0' terminated string
	UnloadFileText   :: proc(text: cstring) ---                                          // Unload file text data allocated by LoadFileText()
	SaveFileText     :: proc(fileName: cstring, text: cstring) -> bool ---               // Save text data to file (write), string must be '\0' terminated, returns true on success

	// File system functions
	FileExists              :: proc(fileName: cstring) -> bool ---               // Check if file exists
	DirectoryExists         :: proc(dirPath: cstring) -> bool ---                // Check if a directory path exists
	IsFileExtension         :: proc(fileName: cstring, ext: cstring) -> bool --- // Check file extension (including point: .png, .wav)
	GetFileLength           :: proc(fileName: cstring) -> i32 ---                // Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
	GetFileExtension        :: proc(fileName: cstring) -> cstring ---            // Get pointer to extension for a filename string (includes dot: '.png')
	GetFileName             :: proc(filePath: cstring) -> cstring ---            // Get pointer to filename for a path string
	GetFileNameWithoutExt   :: proc(filePath: cstring) -> cstring ---            // Get filename string without extension (uses static string)
	GetDirectoryPath        :: proc(filePath: cstring) -> cstring ---            // Get full path for a given fileName with path (uses static string)
	GetPrevDirectoryPath    :: proc(dirPath: cstring) -> cstring ---             // Get previous directory path for a given path (uses static string)
	GetWorkingDirectory     :: proc() -> cstring ---                             // Get current working directory (uses static string)
	GetApplicationDirectory :: proc() -> cstring ---                             // Get the directory of the running application (uses static string)
	MakeDirectory           :: proc(dirPath: cstring) -> i32 ---                 // Create directories (including full path requested), returns 0 on success
	ChangeDirectory         :: proc(dir: cstring) -> bool ---                    // Change working directory, return true on success
	IsPathFile              :: proc(path: cstring) -> bool ---                   // Check if a given path is a file or a directory
	IsFileNameValid         :: proc(fileName: cstring) -> bool ---               // Check if fileName is valid for the platform/OS
	LoadDirectoryFiles      :: proc(dirPath: cstring) -> FilePathList ---        // Load directory filepaths
	LoadDirectoryFilesEx    :: proc(basePath: cstring, filter: cstring, scanSubdirs: bool) -> FilePathList --- // Load directory filepaths with extension filtering and recursive directory scan. Use 'DIR' in the filter string to include directories in the result
	UnloadDirectoryFiles    :: proc(files: FilePathList) ---                     // Unload filepaths
	IsFileDropped           :: proc() -> bool ---                                // Check if a file has been dropped into window
	LoadDroppedFiles        :: proc() -> FilePathList ---                        // Load dropped filepaths
	UnloadDroppedFiles      :: proc(files: FilePathList) ---                     // Unload dropped filepaths
	GetFileModTime          :: proc(fileName: cstring) -> c.long ---             // Get file modification time (last write time)

	// Compression/Encoding functionality
	CompressData     :: proc(data: ^u8, dataSize: i32, compDataSize: ^i32) -> ^u8 ---     // Compress data (DEFLATE algorithm), memory must be MemFree()
	DecompressData   :: proc(compData: ^u8, compDataSize: i32, dataSize: ^i32) -> ^u8 --- // Decompress data (DEFLATE algorithm), memory must be MemFree()
	EncodeDataBase64 :: proc(data: ^u8, dataSize: i32, outputSize: ^i32) -> cstring ---   // Encode data to Base64 string, memory must be MemFree()
	DecodeDataBase64 :: proc(data: ^u8, outputSize: ^i32) -> ^u8 ---                      // Decode Base64 string data, memory must be MemFree()
	ComputeCRC32     :: proc(data: ^u8, dataSize: i32) -> u32 ---                         // Compute CRC32 hash code
	ComputeMD5       :: proc(data: ^u8, dataSize: i32) -> ^u32 ---                        // Compute MD5 hash code, returns static int[4] (16 bytes)
	ComputeSHA1      :: proc(data: ^u8, dataSize: i32) -> ^u32 ---                        // Compute SHA1 hash code, returns static int[5] (20 bytes)

	// Automation events functionality
	LoadAutomationEventList       :: proc(fileName: cstring) -> AutomationEventList --- // Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS
	UnloadAutomationEventList     :: proc(list: AutomationEventList) ---                // Unload automation events list from file
	ExportAutomationEventList     :: proc(list: AutomationEventList, fileName: cstring) -> bool --- // Export automation events list as text file
	SetAutomationEventList        :: proc(list: ^AutomationEventList) ---               // Set automation event list to record to
	SetAutomationEventBaseFrame   :: proc(frame: i32) ---                               // Set automation event internal base frame to start recording
	StartAutomationEventRecording :: proc() ---                                         // Start recording automation events (AutomationEventList must be set)
	StopAutomationEventRecording  :: proc() ---                                         // Stop recording automation events
	PlayAutomationEvent           :: proc(event: AutomationEvent) ---                   // Play a recorded automation event

	// Input-related functions: keyboard
	IsKeyPressed       :: proc(key: KeyboardKey) -> bool ---    // Check if a key has been pressed once
	IsKeyPressedRepeat :: proc(key: KeyboardKey) -> bool ---    // Check if a key has been pressed again
	IsKeyDown          :: proc(key: KeyboardKey) -> bool ---    // Check if a key is being pressed
	IsKeyReleased      :: proc(key: KeyboardKey) -> bool ---    // Check if a key has been released once
	IsKeyUp            :: proc(key: KeyboardKey) -> bool ---    // Check if a key is NOT being pressed
	GetKeyPressed      :: proc() -> KeyboardKey ---             // Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
	GetCharPressed     :: proc() -> i32 ---                     // Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
	GetKeyName         :: proc(key: KeyboardKey) -> cstring --- // Get name of a QWERTY key on the current keyboard layout (eg returns string 'q' for KEY_A on an AZERTY keyboard)
	SetExitKey         :: proc(key: KeyboardKey) ---            // Set a custom key to exit program (default is ESC)

	// Input-related functions: gamepads
	IsGamepadAvailable      :: proc(gamepad: i32) -> bool ---              // Check if a gamepad is available
	GetGamepadName          :: proc(gamepad: i32) -> cstring ---           // Get gamepad internal name id
	IsGamepadButtonPressed  :: proc(gamepad: i32, button: i32) -> bool --- // Check if a gamepad button has been pressed once
	IsGamepadButtonDown     :: proc(gamepad: i32, button: i32) -> bool --- // Check if a gamepad button is being pressed
	IsGamepadButtonReleased :: proc(gamepad: i32, button: i32) -> bool --- // Check if a gamepad button has been released once
	IsGamepadButtonUp       :: proc(gamepad: i32, button: i32) -> bool --- // Check if a gamepad button is NOT being pressed
	GetGamepadButtonPressed :: proc() -> i32 ---                           // Get the last gamepad button pressed
	GetGamepadAxisCount     :: proc(gamepad: i32) -> i32 ---               // Get gamepad axis count for a gamepad
	GetGamepadAxisMovement  :: proc(gamepad: i32, axis: i32) -> f32 ---    // Get axis movement value for a gamepad axis
	SetGamepadMappings      :: proc(mappings: cstring) -> i32 ---          // Set internal gamepad mappings (SDL_GameControllerDB)
	SetGamepadVibration     :: proc(gamepad: i32, leftMotor: f32, rightMotor: f32, duration: f32) --- // Set gamepad vibration for both motors (duration in seconds)

	// Input-related functions: mouse
	IsMouseButtonPressed  :: proc(button: MouseButton) -> bool --- // Check if a mouse button has been pressed once
	IsMouseButtonDown     :: proc(button: MouseButton) -> bool --- // Check if a mouse button is being pressed
	IsMouseButtonReleased :: proc(button: MouseButton) -> bool --- // Check if a mouse button has been released once
	IsMouseButtonUp       :: proc(button: MouseButton) -> bool --- // Check if a mouse button is NOT being pressed
	GetMouseX             :: proc() -> i32 ---                     // Get mouse position X
	GetMouseY             :: proc() -> i32 ---                     // Get mouse position Y
	GetMousePosition      :: proc() -> Vector2 ---                 // Get mouse position XY
	GetMouseDelta         :: proc() -> Vector2 ---                 // Get mouse delta between frames
	SetMousePosition      :: proc(x: i32, y: i32) ---              // Set mouse position XY
	SetMouseOffset        :: proc(offsetX: i32, offsetY: i32) ---  // Set mouse offset
	SetMouseScale         :: proc(scaleX: f32, scaleY: f32) ---    // Set mouse scaling
	GetMouseWheelMove     :: proc() -> f32 ---                     // Get mouse wheel movement for X or Y, whichever is larger
	GetMouseWheelMoveV    :: proc() -> Vector2 ---                 // Get mouse wheel movement for both X and Y
	SetMouseCursor        :: proc(cursor: i32) ---                 // Set mouse cursor

	// Input-related functions: touch
	GetTouchX          :: proc() -> i32 ---               // Get touch position X for touch point 0 (relative to screen size)
	GetTouchY          :: proc() -> i32 ---               // Get touch position Y for touch point 0 (relative to screen size)
	GetTouchPosition   :: proc(index: i32) -> Vector2 --- // Get touch position XY for a touch point index (relative to screen size)
	GetTouchPointId    :: proc(index: i32) -> i32 ---     // Get touch point identifier for given index
	GetTouchPointCount :: proc() -> i32 ---               // Get number of touch points

	//------------------------------------------------------------------------------------
	// Gestures and Touch Handling Functions (Module: rgestures)
	//------------------------------------------------------------------------------------
	SetGesturesEnabled     :: proc(flags: Gestures) ---           // Enable a set of gestures using flags
	IsGestureDetected      :: proc(gesture: Gestures) -> bool --- // Check if a gesture have been detected
	GetGestureDetected     :: proc() -> i32 ---                   // Get latest detected gesture
	GetGestureHoldDuration :: proc() -> f32 ---                   // Get gesture hold time in seconds
	GetGestureDragVector   :: proc() -> Vector2 ---               // Get gesture drag vector
	GetGestureDragAngle    :: proc() -> f32 ---                   // Get gesture drag angle
	GetGesturePinchVector  :: proc() -> Vector2 ---               // Get gesture pinch delta
	GetGesturePinchAngle   :: proc() -> f32 ---                   // Get gesture pinch angle

	//------------------------------------------------------------------------------------
	// Camera System Functions (Module: rcamera)
	//------------------------------------------------------------------------------------
	UpdateCamera    :: proc(camera: ^Camera, mode: i32) --- // Update camera position for selected mode
	UpdateCameraPro :: proc(camera: ^Camera, movement: Vector3, rotation: Vector3, zoom: f32) --- // Update camera movement/rotation

	//------------------------------------------------------------------------------------
	// Basic Shapes Drawing Functions (Module: shapes)
	//------------------------------------------------------------------------------------
	// Set texture and rectangle to be used on shapes drawing
	// NOTE: It can be useful when using basic shapes and one single font,
	// defining a font char white rectangle would allow drawing everything in a single draw call
	SetShapesTexture          :: proc(texture: Texture2D, source: Rectangle) --- // Set texture and rectangle to be used on shapes drawing
	GetShapesTexture          :: proc() -> Texture2D ---                         // Get texture that is used for shapes drawing
	GetShapesTextureRectangle :: proc() -> Rectangle ---                         // Get texture source rectangle that is used for shapes drawing

	// Basic shapes drawing functions
	DrawPixel                   :: proc(posX: i32, posY: i32, color: Color) ---               // Draw a pixel using geometry [Can be slow, use with care]
	DrawPixelV                  :: proc(position: Vector2, color: Color) ---                  // Draw a pixel using geometry (Vector version) [Can be slow, use with care]
	DrawLine                    :: proc(startPosX: i32, startPosY: i32, endPosX: i32, endPosY: i32, color: Color) --- // Draw a line
	DrawLineV                   :: proc(startPos: Vector2, endPos: Vector2, color: Color) --- // Draw a line (using gl lines)
	DrawLineEx                  :: proc(startPos: Vector2, endPos: Vector2, thick: f32, color: Color) --- // Draw a line (using triangles/quads)
	DrawLineStrip               :: proc(points: ^Vector2, pointCount: i32, color: Color) ---  // Draw lines sequence (using gl lines)
	DrawLineBezier              :: proc(startPos: Vector2, endPos: Vector2, thick: f32, color: Color) --- // Draw line segment cubic-bezier in-out interpolation
	DrawCircle                  :: proc(centerX: i32, centerY: i32, radius: f32, color: Color) --- // Draw a color-filled circle
	DrawCircleSector            :: proc(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) --- // Draw a piece of a circle
	DrawCircleSectorLines       :: proc(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) --- // Draw circle sector outline
	DrawCircleGradient          :: proc(centerX: i32, centerY: i32, radius: f32, inner: Color, outer: Color) --- // Draw a gradient-filled circle
	DrawCircleV                 :: proc(center: Vector2, radius: f32, color: Color) ---       // Draw a color-filled circle (Vector version)
	DrawCircleLines             :: proc(centerX: i32, centerY: i32, radius: f32, color: Color) --- // Draw circle outline
	DrawCircleLinesV            :: proc(center: Vector2, radius: f32, color: Color) ---       // Draw circle outline (Vector version)
	DrawEllipse                 :: proc(centerX: i32, centerY: i32, radiusH: f32, radiusV: f32, color: Color) --- // Draw ellipse
	DrawEllipseLines            :: proc(centerX: i32, centerY: i32, radiusH: f32, radiusV: f32, color: Color) --- // Draw ellipse outline
	DrawRing                    :: proc(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) --- // Draw ring
	DrawRingLines               :: proc(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) --- // Draw ring outline
	DrawRectangle               :: proc(posX: i32, posY: i32, width: i32, height: i32, color: Color) --- // Draw a color-filled rectangle
	DrawRectangleV              :: proc(position: Vector2, size: Vector2, color: Color) ---   // Draw a color-filled rectangle (Vector version)
	DrawRectangleRec            :: proc(rec: Rectangle, color: Color) ---                     // Draw a color-filled rectangle
	DrawRectanglePro            :: proc(rec: Rectangle, origin: Vector2, rotation: f32, color: Color) --- // Draw a color-filled rectangle with pro parameters
	DrawRectangleGradientV      :: proc(posX: i32, posY: i32, width: i32, height: i32, top: Color, bottom: Color) --- // Draw a vertical-gradient-filled rectangle
	DrawRectangleGradientH      :: proc(posX: i32, posY: i32, width: i32, height: i32, left: Color, right: Color) --- // Draw a horizontal-gradient-filled rectangle
	DrawRectangleGradientEx     :: proc(rec: Rectangle, topLeft: Color, bottomLeft: Color, topRight: Color, bottomRight: Color) --- // Draw a gradient-filled rectangle with custom vertex colors
	DrawRectangleLines          :: proc(posX: i32, posY: i32, width: i32, height: i32, color: Color) --- // Draw rectangle outline
	DrawRectangleLinesEx        :: proc(rec: Rectangle, lineThick: f32, color: Color) ---     // Draw rectangle outline with extended parameters
	DrawRectangleRounded        :: proc(rec: Rectangle, roundness: f32, segments: i32, color: Color) --- // Draw rectangle with rounded edges
	DrawRectangleRoundedLines   :: proc(rec: Rectangle, roundness: f32, segments: i32, color: Color) --- // Draw rectangle lines with rounded edges
	DrawRectangleRoundedLinesEx :: proc(rec: Rectangle, roundness: f32, segments: i32, lineThick: f32, color: Color) --- // Draw rectangle with rounded edges outline
	DrawTriangle                :: proc(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) --- // Draw a color-filled triangle (vertex in counter-clockwise order!)
	DrawTriangleLines           :: proc(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) --- // Draw triangle outline (vertex in counter-clockwise order!)
	DrawTriangleFan             :: proc(points: ^Vector2, pointCount: i32, color: Color) ---  // Draw a triangle fan defined by points (first vertex is the center)
	DrawTriangleStrip           :: proc(points: ^Vector2, pointCount: i32, color: Color) ---  // Draw a triangle strip defined by points
	DrawPoly                    :: proc(center: Vector2, sides: i32, radius: f32, rotation: f32, color: Color) --- // Draw a regular polygon (Vector version)
	DrawPolyLines               :: proc(center: Vector2, sides: i32, radius: f32, rotation: f32, color: Color) --- // Draw a polygon outline of n sides
	DrawPolyLinesEx             :: proc(center: Vector2, sides: i32, radius: f32, rotation: f32, lineThick: f32, color: Color) --- // Draw a polygon outline of n sides with extended parameters

	// Splines drawing functions
	DrawSplineLinear                 :: proc(points: ^Vector2, pointCount: i32, thick: f32, color: Color) --- // Draw spline: Linear, minimum 2 points
	DrawSplineBasis                  :: proc(points: ^Vector2, pointCount: i32, thick: f32, color: Color) --- // Draw spline: B-Spline, minimum 4 points
	DrawSplineCatmullRom             :: proc(points: ^Vector2, pointCount: i32, thick: f32, color: Color) --- // Draw spline: Catmull-Rom, minimum 4 points
	DrawSplineBezierQuadratic        :: proc(points: ^Vector2, pointCount: i32, thick: f32, color: Color) --- // Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
	DrawSplineBezierCubic            :: proc(points: ^Vector2, pointCount: i32, thick: f32, color: Color) --- // Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
	DrawSplineSegmentLinear          :: proc(p1: Vector2, p2: Vector2, thick: f32, color: Color) --- // Draw spline segment: Linear, 2 points
	DrawSplineSegmentBasis           :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: f32, color: Color) --- // Draw spline segment: B-Spline, 4 points
	DrawSplineSegmentCatmullRom      :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: f32, color: Color) --- // Draw spline segment: Catmull-Rom, 4 points
	DrawSplineSegmentBezierQuadratic :: proc(p1: Vector2, c2: Vector2, p3: Vector2, thick: f32, color: Color) --- // Draw spline segment: Quadratic Bezier, 2 points, 1 control point
	DrawSplineSegmentBezierCubic     :: proc(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, thick: f32, color: Color) --- // Draw spline segment: Cubic Bezier, 2 points, 2 control points

	// Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]
	GetSplinePointLinear      :: proc(startPos: Vector2, endPos: Vector2, t: f32) -> Vector2 --- // Get (evaluate) spline point: Linear
	GetSplinePointBasis       :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: f32) -> Vector2 --- // Get (evaluate) spline point: B-Spline
	GetSplinePointCatmullRom  :: proc(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: f32) -> Vector2 --- // Get (evaluate) spline point: Catmull-Rom
	GetSplinePointBezierQuad  :: proc(p1: Vector2, c2: Vector2, p3: Vector2, t: f32) -> Vector2 --- // Get (evaluate) spline point: Quadratic Bezier
	GetSplinePointBezierCubic :: proc(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, t: f32) -> Vector2 --- // Get (evaluate) spline point: Cubic Bezier

	// Basic shapes collision detection functions
	CheckCollisionRecs          :: proc(rec1: Rectangle, rec2: Rectangle) -> bool ---      // Check collision between two rectangles
	CheckCollisionCircles       :: proc(center1: Vector2, radius1: f32, center2: Vector2, radius2: f32) -> bool --- // Check collision between two circles
	CheckCollisionCircleRec     :: proc(center: Vector2, radius: f32, rec: Rectangle) -> bool --- // Check collision between circle and rectangle
	CheckCollisionCircleLine    :: proc(center: Vector2, radius: f32, p1: Vector2, p2: Vector2) -> bool --- // Check if circle collides with a line created betweeen two points [p1] and [p2]
	CheckCollisionPointRec      :: proc(point: Vector2, rec: Rectangle) -> bool ---        // Check if point is inside rectangle
	CheckCollisionPointCircle   :: proc(point: Vector2, center: Vector2, radius: f32) -> bool --- // Check if point is inside circle
	CheckCollisionPointTriangle :: proc(point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) -> bool --- // Check if point is inside a triangle
	CheckCollisionPointLine     :: proc(point: Vector2, p1: Vector2, p2: Vector2, threshold: i32) -> bool --- // Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
	CheckCollisionPointPoly     :: proc(point: Vector2, points: ^Vector2, pointCount: i32) -> bool --- // Check if point is within a polygon described by array of vertices
	CheckCollisionLines         :: proc(startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2, collisionPoint: ^Vector2) -> bool --- // Check the collision between two lines defined by two points each, returns collision point by reference
	GetCollisionRec             :: proc(rec1: Rectangle, rec2: Rectangle) -> Rectangle --- // Get collision rectangle for two rectangles collision

	// Image loading functions
	// NOTE: These functions do not require GPU access
	LoadImage               :: proc(fileName: cstring) -> Image ---               // Load image from file into CPU memory (RAM)
	LoadImageRaw            :: proc(fileName: cstring, width: i32, height: i32, format: i32, headerSize: i32) -> Image --- // Load image from RAW file data
	LoadImageAnim           :: proc(fileName: cstring, frames: ^i32) -> Image --- // Load image sequence from file (frames appended to image.data)
	LoadImageAnimFromMemory :: proc(fileType: cstring, fileData: ^u8, dataSize: i32, frames: ^i32) -> Image --- // Load image sequence from memory buffer
	LoadImageFromMemory     :: proc(fileType: cstring, fileData: ^u8, dataSize: i32) -> Image --- // Load image from memory buffer, fileType refers to extension: i.e. '.png'
	LoadImageFromTexture    :: proc(texture: Texture2D) -> Image ---              // Load image from GPU texture data
	LoadImageFromScreen     :: proc() -> Image ---                                // Load image from screen buffer and (screenshot)
	IsImageValid            :: proc(image: Image) -> bool ---                     // Check if an image is valid (data and parameters)
	UnloadImage             :: proc(image: Image) ---                             // Unload image from CPU memory (RAM)
	ExportImage             :: proc(image: Image, fileName: cstring) -> bool ---  // Export image data to file, returns true on success
	ExportImageToMemory     :: proc(image: Image, fileType: cstring, fileSize: ^i32) -> ^u8 --- // Export image to memory buffer
	ExportImageAsCode       :: proc(image: Image, fileName: cstring) -> bool ---  // Export image as code file defining an array of bytes, returns true on success

	// Image generation functions
	GenImageColor          :: proc(width: i32, height: i32, color: Color) -> Image ---  // Generate image: plain color
	GenImageGradientLinear :: proc(width: i32, height: i32, direction: i32, start: Color, end: Color) -> Image --- // Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
	GenImageGradientRadial :: proc(width: i32, height: i32, density: f32, inner: Color, outer: Color) -> Image --- // Generate image: radial gradient
	GenImageGradientSquare :: proc(width: i32, height: i32, density: f32, inner: Color, outer: Color) -> Image --- // Generate image: square gradient
	GenImageChecked        :: proc(width: i32, height: i32, checksX: i32, checksY: i32, col1: Color, col2: Color) -> Image --- // Generate image: checked
	GenImageWhiteNoise     :: proc(width: i32, height: i32, factor: f32) -> Image ---   // Generate image: white noise
	GenImagePerlinNoise    :: proc(width: i32, height: i32, offsetX: i32, offsetY: i32, scale: f32) -> Image --- // Generate image: perlin noise
	GenImageCellular       :: proc(width: i32, height: i32, tileSize: i32) -> Image --- // Generate image: cellular algorithm, bigger tileSize means bigger cells
	GenImageText           :: proc(width: i32, height: i32, text: cstring) -> Image --- // Generate image: grayscale image from text data

	// Image manipulation functions
	ImageCopy              :: proc(image: Image) -> Image ---                               // Create an image duplicate (useful for transformations)
	ImageFromImage         :: proc(image: Image, rec: Rectangle) -> Image ---               // Create an image from another image piece
	ImageFromChannel       :: proc(image: Image, selectedChannel: i32) -> Image ---         // Create an image from a selected channel of another image (GRAYSCALE)
	ImageText              :: proc(text: cstring, fontSize: i32, color: Color) -> Image --- // Create an image from text (default font)
	ImageTextEx            :: proc(font: Font, text: cstring, fontSize: f32, spacing: f32, tint: Color) -> Image --- // Create an image from text (custom sprite font)
	ImageFormat            :: proc(image: ^Image, newFormat: i32) ---                       // Convert image data to desired format
	ImageToPOT             :: proc(image: ^Image, fill: Color) ---                          // Convert image to POT (power-of-two)
	ImageCrop              :: proc(image: ^Image, crop: Rectangle) ---                      // Crop an image to a defined rectangle
	ImageAlphaCrop         :: proc(image: ^Image, threshold: f32) ---                       // Crop image depending on alpha value
	ImageAlphaClear        :: proc(image: ^Image, color: Color, threshold: f32) ---         // Clear alpha channel to desired color
	ImageAlphaMask         :: proc(image: ^Image, alphaMask: Image) ---                     // Apply alpha mask to image
	ImageAlphaPremultiply  :: proc(image: ^Image) ---                                       // Premultiply alpha channel
	ImageBlurGaussian      :: proc(image: ^Image, blurSize: i32) ---                        // Apply Gaussian blur using a box blur approximation
	ImageKernelConvolution :: proc(image: ^Image, kernel: ^f32, kernelSize: i32) ---        // Apply custom square convolution kernel to image
	ImageResize            :: proc(image: ^Image, newWidth: i32, newHeight: i32) ---        // Resize image (Bicubic scaling algorithm)
	ImageResizeNN          :: proc(image: ^Image, newWidth: i32, newHeight: i32) ---        // Resize image (Nearest-Neighbor scaling algorithm)
	ImageResizeCanvas      :: proc(image: ^Image, newWidth: i32, newHeight: i32, offsetX: i32, offsetY: i32, fill: Color) --- // Resize canvas and fill with color
	ImageMipmaps           :: proc(image: ^Image) ---                                       // Compute all mipmap levels for a provided image
	ImageDither            :: proc(image: ^Image, rBpp: i32, gBpp: i32, bBpp: i32, aBpp: i32) --- // Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
	ImageFlipVertical      :: proc(image: ^Image) ---                                       // Flip image vertically
	ImageFlipHorizontal    :: proc(image: ^Image) ---                                       // Flip image horizontally
	ImageRotate            :: proc(image: ^Image, degrees: i32) ---                         // Rotate image by input angle in degrees (-359 to 359)
	ImageRotateCW          :: proc(image: ^Image) ---                                       // Rotate image clockwise 90deg
	ImageRotateCCW         :: proc(image: ^Image) ---                                       // Rotate image counter-clockwise 90deg
	ImageColorTint         :: proc(image: ^Image, color: Color) ---                         // Modify image color: tint
	ImageColorInvert       :: proc(image: ^Image) ---                                       // Modify image color: invert
	ImageColorGrayscale    :: proc(image: ^Image) ---                                       // Modify image color: grayscale
	ImageColorContrast     :: proc(image: ^Image, contrast: f32) ---                        // Modify image color: contrast (-100 to 100)
	ImageColorBrightness   :: proc(image: ^Image, brightness: i32) ---                      // Modify image color: brightness (-255 to 255)
	ImageColorReplace      :: proc(image: ^Image, color: Color, replace: Color) ---         // Modify image color: replace color
	LoadImageColors        :: proc(image: Image) -> ^Color ---                              // Load color data from image as a Color array (RGBA - 32bit)
	LoadImagePalette       :: proc(image: Image, maxPaletteSize: i32, colorCount: ^i32) -> ^Color --- // Load colors palette from image as a Color array (RGBA - 32bit)
	UnloadImageColors      :: proc(colors: ^Color) ---                                      // Unload color data loaded with LoadImageColors()
	UnloadImagePalette     :: proc(colors: ^Color) ---                                      // Unload colors palette loaded with LoadImagePalette()
	GetImageAlphaBorder    :: proc(image: Image, threshold: f32) -> Rectangle ---           // Get image alpha border rectangle
	GetImageColor          :: proc(image: Image, x: i32, y: i32) -> Color ---               // Get image pixel color at (x, y) position

	// Image drawing functions
	// NOTE: Image software-rendering functions (CPU)
	ImageClearBackground    :: proc(dst: ^Image, color: Color) ---                       // Clear image background with given color
	ImageDrawPixel          :: proc(dst: ^Image, posX: i32, posY: i32, color: Color) --- // Draw pixel within an image
	ImageDrawPixelV         :: proc(dst: ^Image, position: Vector2, color: Color) ---    // Draw pixel within an image (Vector version)
	ImageDrawLine           :: proc(dst: ^Image, startPosX: i32, startPosY: i32, endPosX: i32, endPosY: i32, color: Color) --- // Draw line within an image
	ImageDrawLineV          :: proc(dst: ^Image, start: Vector2, end: Vector2, color: Color) --- // Draw line within an image (Vector version)
	ImageDrawLineEx         :: proc(dst: ^Image, start: Vector2, end: Vector2, thick: i32, color: Color) --- // Draw a line defining thickness within an image
	ImageDrawCircle         :: proc(dst: ^Image, centerX: i32, centerY: i32, radius: i32, color: Color) --- // Draw a filled circle within an image
	ImageDrawCircleV        :: proc(dst: ^Image, center: Vector2, radius: i32, color: Color) --- // Draw a filled circle within an image (Vector version)
	ImageDrawCircleLines    :: proc(dst: ^Image, centerX: i32, centerY: i32, radius: i32, color: Color) --- // Draw circle outline within an image
	ImageDrawCircleLinesV   :: proc(dst: ^Image, center: Vector2, radius: i32, color: Color) --- // Draw circle outline within an image (Vector version)
	ImageDrawRectangle      :: proc(dst: ^Image, posX: i32, posY: i32, width: i32, height: i32, color: Color) --- // Draw rectangle within an image
	ImageDrawRectangleV     :: proc(dst: ^Image, position: Vector2, size: Vector2, color: Color) --- // Draw rectangle within an image (Vector version)
	ImageDrawRectangleRec   :: proc(dst: ^Image, rec: Rectangle, color: Color) ---       // Draw rectangle within an image
	ImageDrawRectangleLines :: proc(dst: ^Image, rec: Rectangle, thick: i32, color: Color) --- // Draw rectangle lines within an image
	ImageDrawTriangle       :: proc(dst: ^Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) --- // Draw triangle within an image
	ImageDrawTriangleEx     :: proc(dst: ^Image, v1: Vector2, v2: Vector2, v3: Vector2, c1: Color, c2: Color, c3: Color) --- // Draw triangle with interpolated colors within an image
	ImageDrawTriangleLines  :: proc(dst: ^Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) --- // Draw triangle outline within an image
	ImageDrawTriangleFan    :: proc(dst: ^Image, points: ^Vector2, pointCount: i32, color: Color) --- // Draw a triangle fan defined by points within an image (first vertex is the center)
	ImageDrawTriangleStrip  :: proc(dst: ^Image, points: ^Vector2, pointCount: i32, color: Color) --- // Draw a triangle strip defined by points within an image
	ImageDraw               :: proc(dst: ^Image, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) --- // Draw a source image within a destination image (tint applied to source)
	ImageDrawText           :: proc(dst: ^Image, text: cstring, posX: i32, posY: i32, fontSize: i32, color: Color) --- // Draw text (using default font) within an image (destination)
	ImageDrawTextEx         :: proc(dst: ^Image, font: Font, text: cstring, position: Vector2, fontSize: f32, spacing: f32, tint: Color) --- // Draw text (custom sprite font) within an image (destination)

	// Texture loading functions
	// NOTE: These functions require GPU access
	LoadTexture          :: proc(fileName: cstring) -> Texture2D ---                     // Load texture from file into GPU memory (VRAM)
	LoadTextureFromImage :: proc(image: Image) -> Texture2D ---                          // Load texture from image data
	LoadTextureCubemap   :: proc(image: Image, layout: i32) -> TextureCubemap ---        // Load cubemap from image, multiple image cubemap layouts supported
	LoadRenderTexture    :: proc(width: i32, height: i32) -> RenderTexture2D ---         // Load texture for rendering (framebuffer)
	IsTextureValid       :: proc(texture: Texture2D) -> bool ---                         // Check if a texture is valid (loaded in GPU)
	UnloadTexture        :: proc(texture: Texture2D) ---                                 // Unload texture from GPU memory (VRAM)
	IsRenderTextureValid :: proc(target: RenderTexture2D) -> bool ---                    // Check if a render texture is valid (loaded in GPU)
	UnloadRenderTexture  :: proc(target: RenderTexture2D) ---                            // Unload render texture from GPU memory (VRAM)
	UpdateTexture        :: proc(texture: Texture2D, pixels: rawptr) ---                 // Update GPU texture with new data
	UpdateTextureRec     :: proc(texture: Texture2D, rec: Rectangle, pixels: rawptr) --- // Update GPU texture rectangle with new data

	// Texture configuration functions
	GenTextureMipmaps :: proc(texture: ^Texture2D) ---             // Generate GPU mipmaps for a texture
	SetTextureFilter  :: proc(texture: Texture2D, filter: i32) --- // Set texture scaling filter mode
	SetTextureWrap    :: proc(texture: Texture2D, wrap: i32) ---   // Set texture wrapping mode

	// Texture drawing functions
	DrawTexture       :: proc(texture: Texture2D, posX: i32, posY: i32, tint: Color) --- // Draw a Texture2D
	DrawTextureV      :: proc(texture: Texture2D, position: Vector2, tint: Color) ---    // Draw a Texture2D with position defined as Vector2
	DrawTextureEx     :: proc(texture: Texture2D, position: Vector2, rotation: f32, scale: f32, tint: Color) --- // Draw a Texture2D with extended parameters
	DrawTextureRec    :: proc(texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) --- // Draw a part of a texture defined by a rectangle
	DrawTexturePro    :: proc(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: f32, tint: Color) --- // Draw a part of a texture defined by a rectangle with 'pro' parameters
	DrawTextureNPatch :: proc(texture: Texture2D, nPatchInfo: NPatchInfo, dest: Rectangle, origin: Vector2, rotation: f32, tint: Color) --- // Draws a texture (or part of it) that stretches or shrinks nicely

	// Color/pixel related functions
	ColorIsEqual        :: proc(col1: Color, col2: Color) -> bool ---                   // Check if two colors are equal
	Fade                :: proc(color: Color, alpha: f32) -> Color ---                  // Get color with alpha applied, alpha goes from 0.0f to 1.0f
	ColorToInt          :: proc(color: Color) -> i32 ---                                // Get hexadecimal value for a Color (0xRRGGBBAA)
	ColorNormalize      :: proc(color: Color) -> Vector4 ---                            // Get Color normalized as float [0..1]
	ColorFromNormalized :: proc(normalized: Vector4) -> Color ---                       // Get Color from normalized values [0..1]
	ColorToHSV          :: proc(color: Color) -> Vector3 ---                            // Get HSV values for a Color, hue [0..360], saturation/value [0..1]
	ColorFromHSV        :: proc(hue: f32, saturation: f32, value: f32) -> Color ---     // Get a Color from HSV values, hue [0..360], saturation/value [0..1]
	ColorTint           :: proc(color: Color, tint: Color) -> Color ---                 // Get color multiplied with another color
	ColorBrightness     :: proc(color: Color, factor: f32) -> Color ---                 // Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
	ColorContrast       :: proc(color: Color, contrast: f32) -> Color ---               // Get color with contrast correction, contrast values between -1.0f and 1.0f
	ColorAlpha          :: proc(color: Color, alpha: f32) -> Color ---                  // Get color with alpha applied, alpha goes from 0.0f to 1.0f
	ColorAlphaBlend     :: proc(dst: Color, src: Color, tint: Color) -> Color ---       // Get src alpha-blended into dst color with tint
	ColorLerp           :: proc(color1: Color, color2: Color, factor: f32) -> Color --- // Get color lerp interpolation between two colors, factor [0.0f..1.0f]
	GetColor            :: proc(hexValue: u32) -> Color ---                             // Get Color structure from hexadecimal value
	GetPixelColor       :: proc(srcPtr: rawptr, format: i32) -> Color ---               // Get Color from a source pixel pointer of certain format
	SetPixelColor       :: proc(dstPtr: rawptr, color: Color, format: i32) ---          // Set color formatted into destination pixel pointer
	GetPixelDataSize    :: proc(width: i32, height: i32, format: i32) -> i32 ---        // Get pixel data size in bytes for certain format

	// Font loading/unloading functions
	GetFontDefault     :: proc() -> Font ---                                         // Get the default Font
	LoadFont           :: proc(fileName: cstring) -> Font ---                        // Load font from file into GPU memory (VRAM)
	LoadFontEx         :: proc(fileName: cstring, fontSize: i32, codepoints: ^i32, codepointCount: i32) -> Font --- // Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
	LoadFontFromImage  :: proc(image: Image, key: Color, firstChar: i32) -> Font --- // Load font from Image (XNA style)
	LoadFontFromMemory :: proc(fileType: cstring, fileData: ^u8, dataSize: i32, fontSize: i32, codepoints: ^i32, codepointCount: i32) -> Font --- // Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
	IsFontValid        :: proc(font: Font) -> bool ---                               // Check if a font is valid (font data loaded, WARNING: GPU texture not checked)
	LoadFontData       :: proc(fileData: ^u8, dataSize: i32, fontSize: i32, codepoints: ^i32, codepointCount: i32, type: i32) -> ^GlyphInfo --- // Load font data for further use
	GenImageFontAtlas  :: proc(glyphs: ^GlyphInfo, glyphRecs: ^^Rectangle, glyphCount: i32, fontSize: i32, padding: i32, packMethod: i32) -> Image --- // Generate image font atlas using chars info
	UnloadFontData     :: proc(glyphs: ^GlyphInfo, glyphCount: i32) ---              // Unload font chars info data (RAM)
	UnloadFont         :: proc(font: Font) ---                                       // Unload font from GPU memory (VRAM)
	ExportFontAsCode   :: proc(font: Font, fileName: cstring) -> bool ---            // Export font as code file, returns true on success

	// Text drawing functions
	DrawFPS            :: proc(posX: i32, posY: i32) --- // Draw current FPS
	DrawText           :: proc(text: cstring, posX: i32, posY: i32, fontSize: i32, color: Color) --- // Draw text (using default font)
	DrawTextEx         :: proc(font: Font, text: cstring, position: Vector2, fontSize: f32, spacing: f32, tint: Color) --- // Draw text using font and additional parameters
	DrawTextPro        :: proc(font: Font, text: cstring, position: Vector2, origin: Vector2, rotation: f32, fontSize: f32, spacing: f32, tint: Color) --- // Draw text using Font and pro parameters (rotation)
	DrawTextCodepoint  :: proc(font: Font, codepoint: i32, position: Vector2, fontSize: f32, tint: Color) --- // Draw one character (codepoint)
	DrawTextCodepoints :: proc(font: Font, codepoints: ^i32, codepointCount: i32, position: Vector2, fontSize: f32, spacing: f32, tint: Color) --- // Draw multiple character (codepoint)

	// Text font info functions
	SetTextLineSpacing :: proc(spacing: i32) ---                            // Set vertical line spacing when drawing with line-breaks
	MeasureText        :: proc(text: cstring, fontSize: i32) -> i32 ---     // Measure string width for default font
	MeasureTextEx      :: proc(font: Font, text: cstring, fontSize: f32, spacing: f32) -> Vector2 --- // Measure string size for Font
	GetGlyphIndex      :: proc(font: Font, codepoint: i32) -> i32 ---       // Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
	GetGlyphInfo       :: proc(font: Font, codepoint: i32) -> GlyphInfo --- // Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
	GetGlyphAtlasRec   :: proc(font: Font, codepoint: i32) -> Rectangle --- // Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found

	// Text codepoints management functions (unicode characters)
	LoadUTF8             :: proc(codepoints: ^i32, length: i32) -> cstring ---  // Load UTF-8 text encoded from codepoints array
	UnloadUTF8           :: proc(text: cstring) ---                             // Unload UTF-8 text encoded from codepoints array
	LoadCodepoints       :: proc(text: cstring, count: ^i32) -> ^i32 ---        // Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
	UnloadCodepoints     :: proc(codepoints: ^i32) ---                          // Unload codepoints data from memory
	GetCodepointCount    :: proc(text: cstring) -> i32 ---                      // Get total number of codepoints in a UTF-8 encoded string
	GetCodepoint         :: proc(text: cstring, codepointSize: ^i32) -> i32 --- // Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
	GetCodepointNext     :: proc(text: cstring, codepointSize: ^i32) -> i32 --- // Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
	GetCodepointPrevious :: proc(text: cstring, codepointSize: ^i32) -> i32 --- // Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
	CodepointToUTF8      :: proc(codepoint: i32, utf8Size: ^i32) -> cstring --- // Encode one codepoint into UTF-8 byte array (array length returned as parameter)

	// Text strings management functions (no UTF-8 strings, only byte chars)
	// WARNING 1: Most of these functions use internal static buffers, it's recommended to store returned data on user-side for re-use
	// WARNING 2: Some strings allocate memory internally for the returned strings, those strings must be free by user using MemFree()
	TextCopy      :: proc(dst: cstring, src: cstring) -> i32 ---                        // Copy one string to another, returns bytes copied
	TextIsEqual   :: proc(text1: cstring, text2: cstring) -> bool ---                   // Check if two text string are equal
	TextLength    :: proc(text: cstring) -> u32 ---                                     // Get text length, checks for '\0' ending
	TextFormat    :: proc(text: cstring, #c_vararg _: ..any) -> cstring ---             // Text formatting with variables (sprintf() style)
	TextSubtext   :: proc(text: cstring, position: i32, length: i32) -> cstring ---     // Get a piece of a text string
	TextReplace   :: proc(text: cstring, replace: cstring, by: cstring) -> cstring ---  // Replace text string (WARNING: memory must be freed!)
	TextInsert    :: proc(text: cstring, insert: cstring, position: i32) -> cstring --- // Insert text in a position (WARNING: memory must be freed!)
	TextJoin      :: proc(textList: [^]cstring, count: i32, delimiter: cstring) -> cstring --- // Join text strings with delimiter
	TextSplit     :: proc(text: cstring, delimiter: i8, count: ^i32) -> [^]cstring ---  // Split text into multiple strings
	TextAppend    :: proc(text: cstring, append: cstring, position: ^i32) ---           // Append text at specific position and move cursor!
	TextFindIndex :: proc(text: cstring, find: cstring) -> i32 ---                      // Find first text occurrence within a string
	TextToUpper   :: proc(text: cstring) -> cstring ---                                 // Get upper case version of provided string
	TextToLower   :: proc(text: cstring) -> cstring ---                                 // Get lower case version of provided string
	TextToPascal  :: proc(text: cstring) -> cstring ---                                 // Get Pascal case notation version of provided string
	TextToSnake   :: proc(text: cstring) -> cstring ---                                 // Get Snake case notation version of provided string
	TextToCamel   :: proc(text: cstring) -> cstring ---                                 // Get Camel case notation version of provided string
	TextToInteger :: proc(text: cstring) -> i32 ---                                     // Get integer value from text
	TextToFloat   :: proc(text: cstring) -> f32 ---                                     // Get float value from text

	// Basic geometric 3D shapes drawing functions
	DrawLine3D          :: proc(startPos: Vector3, endPos: Vector3, color: Color) ---    // Draw a line in 3D world space
	DrawPoint3D         :: proc(position: Vector3, color: Color) ---                     // Draw a point in 3D space, actually a small line
	DrawCircle3D        :: proc(center: Vector3, radius: f32, rotationAxis: Vector3, rotationAngle: f32, color: Color) --- // Draw a circle in 3D world space
	DrawTriangle3D      :: proc(v1: Vector3, v2: Vector3, v3: Vector3, color: Color) --- // Draw a color-filled triangle (vertex in counter-clockwise order!)
	DrawTriangleStrip3D :: proc(points: ^Vector3, pointCount: i32, color: Color) ---     // Draw a triangle strip defined by points
	DrawCube            :: proc(position: Vector3, width: f32, height: f32, length: f32, color: Color) --- // Draw cube
	DrawCubeV           :: proc(position: Vector3, size: Vector3, color: Color) ---      // Draw cube (Vector version)
	DrawCubeWires       :: proc(position: Vector3, width: f32, height: f32, length: f32, color: Color) --- // Draw cube wires
	DrawCubeWiresV      :: proc(position: Vector3, size: Vector3, color: Color) ---      // Draw cube wires (Vector version)
	DrawSphere          :: proc(centerPos: Vector3, radius: f32, color: Color) ---       // Draw sphere
	DrawSphereEx        :: proc(centerPos: Vector3, radius: f32, rings: i32, slices: i32, color: Color) --- // Draw sphere with extended parameters
	DrawSphereWires     :: proc(centerPos: Vector3, radius: f32, rings: i32, slices: i32, color: Color) --- // Draw sphere wires
	DrawCylinder        :: proc(position: Vector3, radiusTop: f32, radiusBottom: f32, height: f32, slices: i32, color: Color) --- // Draw a cylinder/cone
	DrawCylinderEx      :: proc(startPos: Vector3, endPos: Vector3, startRadius: f32, endRadius: f32, sides: i32, color: Color) --- // Draw a cylinder with base at startPos and top at endPos
	DrawCylinderWires   :: proc(position: Vector3, radiusTop: f32, radiusBottom: f32, height: f32, slices: i32, color: Color) --- // Draw a cylinder/cone wires
	DrawCylinderWiresEx :: proc(startPos: Vector3, endPos: Vector3, startRadius: f32, endRadius: f32, sides: i32, color: Color) --- // Draw a cylinder wires with base at startPos and top at endPos
	DrawCapsule         :: proc(startPos: Vector3, endPos: Vector3, radius: f32, slices: i32, rings: i32, color: Color) --- // Draw a capsule with the center of its sphere caps at startPos and endPos
	DrawCapsuleWires    :: proc(startPos: Vector3, endPos: Vector3, radius: f32, slices: i32, rings: i32, color: Color) --- // Draw capsule wireframe with the center of its sphere caps at startPos and endPos
	DrawPlane           :: proc(centerPos: Vector3, size: Vector2, color: Color) ---     // Draw a plane XZ
	DrawRay             :: proc(ray: Ray, color: Color) ---                              // Draw a ray line
	DrawGrid            :: proc(slices: i32, spacing: f32) ---                           // Draw a grid (centered at (0, 0, 0))

	// Model management functions
	LoadModel           :: proc(fileName: cstring) -> Model ---  // Load model from files (meshes and materials)
	LoadModelFromMesh   :: proc(mesh: Mesh) -> Model ---         // Load model from generated mesh (default material)
	IsModelValid        :: proc(model: Model) -> bool ---        // Check if a model is valid (loaded in GPU, VAO/VBOs)
	UnloadModel         :: proc(model: Model) ---                // Unload model (including meshes) from memory (RAM and/or VRAM)
	GetModelBoundingBox :: proc(model: Model) -> BoundingBox --- // Compute model bounding box limits (considers all meshes)

	// Model drawing functions
	DrawModel         :: proc(model: Model, position: Vector3, scale: f32, tint: Color) --- // Draw a model (with texture if set)
	DrawModelEx       :: proc(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) --- // Draw a model with extended parameters
	DrawModelWires    :: proc(model: Model, position: Vector3, scale: f32, tint: Color) --- // Draw a model wires (with texture if set)
	DrawModelWiresEx  :: proc(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) --- // Draw a model wires (with texture if set) with extended parameters
	DrawModelPoints   :: proc(model: Model, position: Vector3, scale: f32, tint: Color) --- // Draw a model as points
	DrawModelPointsEx :: proc(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) --- // Draw a model as points with extended parameters
	DrawBoundingBox   :: proc(box: BoundingBox, color: Color) ---                           // Draw bounding box (wires)
	DrawBillboard     :: proc(camera: Camera, texture: Texture2D, position: Vector3, scale: f32, tint: Color) --- // Draw a billboard texture
	DrawBillboardRec  :: proc(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, size: Vector2, tint: Color) --- // Draw a billboard texture defined by source
	DrawBillboardPro  :: proc(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: f32, tint: Color) --- // Draw a billboard texture defined by source and rotation

	// Mesh management functions
	UploadMesh         :: proc(mesh: ^Mesh, _dynamic: bool) ---                       // Upload mesh vertex data in GPU and provide VAO/VBO ids
	UpdateMeshBuffer   :: proc(mesh: Mesh, index: i32, data: rawptr, dataSize: i32, offset: i32) --- // Update mesh vertex data in GPU for a specific buffer index
	UnloadMesh         :: proc(mesh: Mesh) ---                                        // Unload mesh data from CPU and GPU
	DrawMesh           :: proc(mesh: Mesh, material: Material, transform: Matrix) --- // Draw a 3d mesh with material and transform
	DrawMeshInstanced  :: proc(mesh: Mesh, material: Material, transforms: ^Matrix, instances: i32) --- // Draw multiple mesh instances with material and different transforms
	GetMeshBoundingBox :: proc(mesh: Mesh) -> BoundingBox ---                         // Compute mesh bounding box limits
	GenMeshTangents    :: proc(mesh: ^Mesh) ---                                       // Compute mesh tangents
	ExportMesh         :: proc(mesh: Mesh, fileName: cstring) -> bool ---             // Export mesh data to file, returns true on success
	ExportMeshAsCode   :: proc(mesh: Mesh, fileName: cstring) -> bool ---             // Export mesh as code file (.h) defining multiple arrays of vertex attributes

	// Mesh generation functions
	GenMeshPoly       :: proc(sides: i32, radius: f32) -> Mesh ---                         // Generate polygonal mesh
	GenMeshPlane      :: proc(width: f32, length: f32, resX: i32, resZ: i32) -> Mesh ---   // Generate plane mesh (with subdivisions)
	GenMeshCube       :: proc(width: f32, height: f32, length: f32) -> Mesh ---            // Generate cuboid mesh
	GenMeshSphere     :: proc(radius: f32, rings: i32, slices: i32) -> Mesh ---            // Generate sphere mesh (standard sphere)
	GenMeshHemiSphere :: proc(radius: f32, rings: i32, slices: i32) -> Mesh ---            // Generate half-sphere mesh (no bottom cap)
	GenMeshCylinder   :: proc(radius: f32, height: f32, slices: i32) -> Mesh ---           // Generate cylinder mesh
	GenMeshCone       :: proc(radius: f32, height: f32, slices: i32) -> Mesh ---           // Generate cone/pyramid mesh
	GenMeshTorus      :: proc(radius: f32, size: f32, radSeg: i32, sides: i32) -> Mesh --- // Generate torus mesh
	GenMeshKnot       :: proc(radius: f32, size: f32, radSeg: i32, sides: i32) -> Mesh --- // Generate trefoil knot mesh
	GenMeshHeightmap  :: proc(heightmap: Image, size: Vector3) -> Mesh ---                 // Generate heightmap mesh from image data
	GenMeshCubicmap   :: proc(cubicmap: Image, cubeSize: Vector3) -> Mesh ---              // Generate cubes-based map mesh from image data

	// Material loading/unloading functions
	LoadMaterials        :: proc(fileName: cstring, materialCount: ^i32) -> ^Material ---   // Load materials from model file
	LoadMaterialDefault  :: proc() -> Material ---                                          // Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
	IsMaterialValid      :: proc(material: Material) -> bool ---                            // Check if a material is valid (shader assigned, map textures loaded in GPU)
	UnloadMaterial       :: proc(material: Material) ---                                    // Unload material from GPU memory (VRAM)
	SetMaterialTexture   :: proc(material: ^Material, mapType: i32, texture: Texture2D) --- // Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
	SetModelMeshMaterial :: proc(model: ^Model, meshId: i32, materialId: i32) ---           // Set material for a mesh

	// Model animations loading/unloading functions
	LoadModelAnimations       :: proc(fileName: cstring, animCount: ^i32) -> ^ModelAnimation --- // Load model animations from file
	UpdateModelAnimation      :: proc(model: Model, anim: ModelAnimation, frame: i32) --- // Update model animation pose (CPU)
	UpdateModelAnimationBones :: proc(model: Model, anim: ModelAnimation, frame: i32) --- // Update model animation mesh bone matrices (GPU skinning)
	UnloadModelAnimation      :: proc(anim: ModelAnimation) ---                           // Unload animation data
	UnloadModelAnimations     :: proc(animations: ^ModelAnimation, animCount: i32) ---    // Unload animation array data
	IsModelAnimationValid     :: proc(model: Model, anim: ModelAnimation) -> bool ---     // Check model animation skeleton match

	// Collision detection functions
	CheckCollisionSpheres   :: proc(center1: Vector3, radius1: f32, center2: Vector3, radius2: f32) -> bool --- // Check collision between two spheres
	CheckCollisionBoxes     :: proc(box1: BoundingBox, box2: BoundingBox) -> bool --- // Check collision between two bounding boxes
	CheckCollisionBoxSphere :: proc(box: BoundingBox, center: Vector3, radius: f32) -> bool --- // Check collision between box and sphere
	GetRayCollisionSphere   :: proc(ray: Ray, center: Vector3, radius: f32) -> RayCollision --- // Get collision info between ray and sphere
	GetRayCollisionBox      :: proc(ray: Ray, box: BoundingBox) -> RayCollision ---   // Get collision info between ray and box
	GetRayCollisionMesh     :: proc(ray: Ray, mesh: Mesh, transform: Matrix) -> RayCollision --- // Get collision info between ray and mesh
	GetRayCollisionTriangle :: proc(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3) -> RayCollision --- // Get collision info between ray and triangle
	GetRayCollisionQuad     :: proc(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) -> RayCollision --- // Get collision info between ray and quad

	// Audio device management functions
	InitAudioDevice    :: proc() ---            // Initialize audio device and context
	CloseAudioDevice   :: proc() ---            // Close the audio device and context
	IsAudioDeviceReady :: proc() -> bool ---    // Check if audio device has been initialized successfully
	SetMasterVolume    :: proc(volume: f32) --- // Set master volume (listener)
	GetMasterVolume    :: proc() -> f32 ---     // Get master volume (listener)

	// Wave/Sound loading/unloading functions
	LoadWave           :: proc(fileName: cstring) -> Wave ---                               // Load wave data from file
	LoadWaveFromMemory :: proc(fileType: cstring, fileData: ^u8, dataSize: i32) -> Wave --- // Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
	IsWaveValid        :: proc(wave: Wave) -> bool ---                                      // Checks if wave data is valid (data loaded and parameters)
	LoadSound          :: proc(fileName: cstring) -> Sound ---                              // Load sound from file
	LoadSoundFromWave  :: proc(wave: Wave) -> Sound ---                                     // Load sound from wave data
	LoadSoundAlias     :: proc(source: Sound) -> Sound ---                                  // Create a new sound that shares the same sample data as the source sound, does not own the sound data
	IsSoundValid       :: proc(sound: Sound) -> bool ---                                    // Checks if a sound is valid (data loaded and buffers initialized)
	UpdateSound        :: proc(sound: Sound, data: rawptr, sampleCount: i32) ---            // Update sound buffer with new data
	UnloadWave         :: proc(wave: Wave) ---                                              // Unload wave data
	UnloadSound        :: proc(sound: Sound) ---                                            // Unload sound
	UnloadSoundAlias   :: proc(alias: Sound) ---                                            // Unload a sound alias (does not deallocate sample data)
	ExportWave         :: proc(wave: Wave, fileName: cstring) -> bool ---                   // Export wave data to file, returns true on success
	ExportWaveAsCode   :: proc(wave: Wave, fileName: cstring) -> bool ---                   // Export wave sample data to code (.h), returns true on success

	// Wave/Sound management functions
	PlaySound         :: proc(sound: Sound) ---                                 // Play a sound
	StopSound         :: proc(sound: Sound) ---                                 // Stop playing a sound
	PauseSound        :: proc(sound: Sound) ---                                 // Pause a sound
	ResumeSound       :: proc(sound: Sound) ---                                 // Resume a paused sound
	IsSoundPlaying    :: proc(sound: Sound) -> bool ---                         // Check if a sound is currently playing
	SetSoundVolume    :: proc(sound: Sound, volume: f32) ---                    // Set volume for a sound (1.0 is max level)
	SetSoundPitch     :: proc(sound: Sound, pitch: f32) ---                     // Set pitch for a sound (1.0 is base level)
	SetSoundPan       :: proc(sound: Sound, pan: f32) ---                       // Set pan for a sound (0.5 is center)
	WaveCopy          :: proc(wave: Wave) -> Wave ---                           // Copy a wave to a new wave
	WaveCrop          :: proc(wave: ^Wave, initFrame: i32, finalFrame: i32) --- // Crop a wave to defined frames range
	WaveFormat        :: proc(wave: ^Wave, sampleRate: i32, sampleSize: i32, channels: i32) --- // Convert wave data to desired format
	LoadWaveSamples   :: proc(wave: Wave) -> ^f32 ---                           // Load samples data from wave as a 32bit float data array
	UnloadWaveSamples :: proc(samples: ^f32) ---                                // Unload samples data loaded with LoadWaveSamples()

	// Music management functions
	LoadMusicStream           :: proc(fileName: cstring) -> Music ---  // Load music stream from file
	LoadMusicStreamFromMemory :: proc(fileType: cstring, data: ^u8, dataSize: i32) -> Music --- // Load music stream from data
	IsMusicValid              :: proc(music: Music) -> bool ---        // Checks if a music stream is valid (context and buffers initialized)
	UnloadMusicStream         :: proc(music: Music) ---                // Unload music stream
	PlayMusicStream           :: proc(music: Music) ---                // Start music playing
	IsMusicStreamPlaying      :: proc(music: Music) -> bool ---        // Check if music is playing
	UpdateMusicStream         :: proc(music: Music) ---                // Updates buffers for music streaming
	StopMusicStream           :: proc(music: Music) ---                // Stop music playing
	PauseMusicStream          :: proc(music: Music) ---                // Pause music playing
	ResumeMusicStream         :: proc(music: Music) ---                // Resume playing paused music
	SeekMusicStream           :: proc(music: Music, position: f32) --- // Seek music to a position (in seconds)
	SetMusicVolume            :: proc(music: Music, volume: f32) ---   // Set volume for music (1.0 is max level)
	SetMusicPitch             :: proc(music: Music, pitch: f32) ---    // Set pitch for a music (1.0 is base level)
	SetMusicPan               :: proc(music: Music, pan: f32) ---      // Set pan for a music (0.5 is center)
	GetMusicTimeLength        :: proc(music: Music) -> f32 ---         // Get music time length (in seconds)
	GetMusicTimePlayed        :: proc(music: Music) -> f32 ---         // Get current music time played (in seconds)

	// AudioStream management functions
	LoadAudioStream                 :: proc(sampleRate: u32, sampleSize: u32, channels: u32) -> AudioStream --- // Load audio stream (to stream raw audio pcm data)
	IsAudioStreamValid              :: proc(stream: AudioStream) -> bool ---                  // Checks if an audio stream is valid (buffers initialized)
	UnloadAudioStream               :: proc(stream: AudioStream) ---                          // Unload audio stream and free memory
	UpdateAudioStream               :: proc(stream: AudioStream, data: rawptr, frameCount: i32) --- // Update audio stream buffers with data
	IsAudioStreamProcessed          :: proc(stream: AudioStream) -> bool ---                  // Check if any audio stream buffers requires refill
	PlayAudioStream                 :: proc(stream: AudioStream) ---                          // Play audio stream
	PauseAudioStream                :: proc(stream: AudioStream) ---                          // Pause audio stream
	ResumeAudioStream               :: proc(stream: AudioStream) ---                          // Resume audio stream
	IsAudioStreamPlaying            :: proc(stream: AudioStream) -> bool ---                  // Check if audio stream is playing
	StopAudioStream                 :: proc(stream: AudioStream) ---                          // Stop audio stream
	SetAudioStreamVolume            :: proc(stream: AudioStream, volume: f32) ---             // Set volume for audio stream (1.0 is max level)
	SetAudioStreamPitch             :: proc(stream: AudioStream, pitch: f32) ---              // Set pitch for audio stream (1.0 is base level)
	SetAudioStreamPan               :: proc(stream: AudioStream, pan: f32) ---                // Set pan for audio stream (0.5 is centered)
	SetAudioStreamBufferSizeDefault :: proc(size: i32) ---                                    // Default size for new audio streams
	SetAudioStreamCallback          :: proc(stream: AudioStream, callback: AudioCallback) --- // Audio thread callback to request new data
	AttachAudioStreamProcessor      :: proc(stream: AudioStream, processor: AudioCallback) --- // Attach audio stream processor to stream, receives the samples as 'float'
	DetachAudioStreamProcessor      :: proc(stream: AudioStream, processor: AudioCallback) --- // Detach audio stream processor from stream
	AttachAudioMixedProcessor       :: proc(processor: AudioCallback) ---                     // Attach audio stream processor to the entire audio pipeline, receives the samples as 'float'
	DetachAudioMixedProcessor       :: proc(processor: AudioCallback) ---                     // Detach audio stream processor from the entire audio pipeline
}
