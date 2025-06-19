package box2d

import "core:c"

_ :: c

foreign import lib "box2d.lib"

/// 2D vector
/// This can be used to represent a point or free vector
Vec2 :: struct {
	/// coordinates
	x: f32,

	/// coordinates
	y: f32,
}

/// Cosine and sine pair
/// This uses a custom implementation designed for cross-platform determinism
CosSin :: struct {
	/// cosine and sine
	cosine: f32,
	sine: f32,
}

/// 2D rotation
/// This is similar to using a complex number for rotation
Rot :: struct {
	/// cosine and sine
	_c: f32,

	/// cosine and sine
	s: f32,
}

/// A 2D rigid transform
Transform :: struct {
	p: Vec2,
	q: Rot,
}

/// A 2-by-2 Matrix
Mat22 :: struct {
	/// columns
	cx: Vec2,

	/// columns
	cy: Vec2,
}

/// Axis-aligned bounding box
AABB :: struct {
	lowerBound, upperBound: Vec2,
}

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// Compute an approximate arctangent in the range [-pi, pi]
	/// This is hand coded for cross-platform determinism. The atan2f
	/// function in the standard library is not cross-platform deterministic.
	///	Accurate to around 0.0023 degrees
	Atan2 :: proc(y: f32, x: f32) -> f32 ---

	/// Compute the cosine and sine of an angle in radians. Implemented
	/// for cross-platform determinism.
	ComputeCosSin :: proc(radians: f32) -> CosSin ---

	/// Compute the rotation between two unit vectors
	ComputeRotationBetweenUnitVectors :: proc(v1: Vec2, v2: Vec2) -> Rot ---

	/// Is this a valid number? Not NaN or infinity.
	IsValidFloat :: proc(a: f32) -> bool ---

	/// Is this a valid vector? Not NaN or infinity.
	IsValidVec2 :: proc(v: Vec2) -> bool ---

	/// Is this a valid rotation? Not NaN or infinity. Is normalized.
	IsValidRotation :: proc(q: Rot) -> bool ---

	/// Is this a valid bounding box? Not Nan or infinity. Upper bound greater than or equal to lower bound.
	IsValidAABB :: proc(aabb: AABB) -> bool ---

	/// Box2D bases all length units on meters, but you may need different units for your game.
	/// You can set this value to use different units. This should be done at application startup
	/// and only modified once. Default value is 1.
	/// For example, if your game uses pixels for units you can use pixels for all length values
	/// sent to Box2D. There should be no extra cost. However, Box2D has some internal tolerances
	/// and thresholds that have been tuned for meters. By calling this function, Box2D is able
	/// to adjust those tolerances and thresholds to improve accuracy.
	/// A good rule of thumb is to pass the height of your player character to this function. So
	/// if your player character is 32 pixels high, then pass 32 to this function. Then you may
	/// confidently use pixels for all the length values sent to Box2D. All length values returned
	/// from Box2D will also be pixels because Box2D does not do any scaling internally.
	/// However, you are now on the hook for coming up with good values for gravity, density, and
	/// forces.
	/// @warning This must be modified before any calls to Box2D
	SetLengthUnitsPerMeter :: proc(lengthUnits: f32) ---

	/// Get the current length units per meter.
	GetLengthUnitsPerMeter :: proc() -> f32 ---
}
