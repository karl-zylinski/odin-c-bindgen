package raylib

Vector2 :: struct{
	x: f32,
	y: f32,
}

Vector3 :: struct{
	x: f32,
	y: f32,
	z: f32,
}

Vector4 :: struct{
	x: f32,
	y: f32,
	z: f32,
	w: f32,
}

Matrix :: struct{
	m0: f32,
	m4: f32,
	m8: f32,
	m12: f32,
	m1: f32,
	m5: f32,
	m9: f32,
	m13: f32,
	m2: f32,
	m6: f32,
	m10: f32,
	m14: f32,
	m3: f32,
	m7: f32,
	m11: f32,
	m15: f32,
}

Color :: struct{
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}

Rectangle :: struct{
	x: f32,
	y: f32,
	width: f32,
	height: f32,
}

Image :: struct{
	data: ,
	width: i32,
	height: i32,
	mipmaps: i32,
	format: i32,
}

Texture :: struct{
	id: u32,
	width: i32,
	height: i32,
	mipmaps: i32,
	format: i32,
}

RenderTexture :: struct{
	id: u32,
	texture: ,
	depth: ,
}

NPatchInfo :: struct{
	source: ,
	left: i32,
	top: i32,
	right: i32,
	bottom: i32,
	layout: i32,
}

GlyphInfo :: struct{
	value: i32,
	offsetX: i32,
	offsetY: i32,
	advanceX: i32,
	image: ,
}

Font :: struct{
	baseSize: i32,
	glyphCount: i32,
	glyphPadding: i32,
	texture: ,
	recs: ,
	glyphs: ,
}

Camera3D :: struct{
	position: ,
	target: ,
	up: ,
	fovy: f32,
	projection: i32,
}

Camera2D :: struct{
	offset: ,
	target: ,
	rotation: f32,
	zoom: f32,
}

Mesh :: struct{
	vertexCount: i32,
	triangleCount: i32,
	vertices: ,
	texcoords: ,
	texcoords2: ,
	normals: ,
	tangents: ,
	colors: ,
	indices: ,
	animVertices: ,
	animNormals: ,
	boneIds: ,
	boneWeights: ,
	boneMatrices: ,
	boneCount: i32,
	vaoId: u32,
	vboId: ,
}

Shader :: struct{
	id: u32,
	locs: ,
}

MaterialMap :: struct{
	texture: ,
	color: ,
	value: f32,
}

Material :: struct{
	shader: ,
	maps: ,
	params: ,
}

Transform :: struct{
	translation: ,
	rotation: ,
	scale: ,
}

BoneInfo :: struct{
	name: ,
	parent: i32,
}

Model :: struct{
	transform: ,
	meshCount: i32,
	materialCount: i32,
	meshes: ,
	materials: ,
	meshMaterial: ,
	boneCount: i32,
	bones: ,
	bindPose: ,
}

ModelAnimation :: struct{
	boneCount: i32,
	frameCount: i32,
	bones: ,
	framePoses: ,
	name: ,
}

Ray :: struct{
	position: ,
	direction: ,
}

RayCollision :: struct{
	hit: bool,
	distance: f32,
	point: ,
	normal: ,
}

BoundingBox :: struct{
	min: ,
	max: ,
}

Wave :: struct{
	frameCount: u32,
	sampleRate: u32,
	sampleSize: u32,
	channels: u32,
	data: ,
}

rAudioBuffer :: struct{
}

rAudioProcessor :: struct{
}

AudioStream :: struct{
	buffer: ,
	processor: ,
	sampleRate: u32,
	sampleSize: u32,
	channels: u32,
}

Sound :: struct{
	stream: ,
	frameCount: u32,
}

Music :: struct{
	stream: ,
	frameCount: u32,
	looping: bool,
	ctxType: i32,
	ctxData: ,
}

VrDeviceInfo :: struct{
	hResolution: i32,
	vResolution: i32,
	hScreenSize: f32,
	vScreenSize: f32,
	eyeToScreenDistance: f32,
	lensSeparationDistance: f32,
	interpupillaryDistance: f32,
	lensDistortionValues: ,
	chromaAbCorrection: ,
}

VrStereoConfig :: struct{
	projection: ,
	viewOffset: ,
	leftLensCenter: ,
	rightLensCenter: ,
	leftScreenCenter: ,
	rightScreenCenter: ,
	scale: ,
	scaleIn: ,
}

FilePathList :: struct{
	capacity: u32,
	count: u32,
	paths: ,
}

AutomationEvent :: struct{
	frame: u32,
	type: u32,
	params: ,
}

AutomationEventList :: struct{
	capacity: u32,
	count: u32,
	events: ,
}

