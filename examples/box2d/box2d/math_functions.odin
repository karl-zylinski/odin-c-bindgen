// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d

import "core:c"

_ :: c

foreign import lib "box2d.lib"

B2_PI :: 3.14159265359


/// 2D vector
/// This can be used to represent a point or free vector
Vec2 :: struct {
	/// coordinates
	x, y: f32,
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
	_c, s: f32,
}

/// A 2D rigid transform
Transform :: struct {
	p: Vec2,
	q: Rot,
}

/// A 2-by-2 Matrix
Mat22 :: struct {
	/// columns
	cx, cy: Vec2,
}

/// Axis-aligned bounding box
AABB :: struct {
	lowerBound: Vec2,
	upperBound: Vec2,
}

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// @return the minimum of two integers
	MinInt :: proc(a: i32, b: i32) -> i32 ---

	/// @return the maximum of two integers
	MaxInt :: proc(a: i32, b: i32) -> i32 ---

	/// @return the absolute value of an integer
	AbsInt :: proc(a: i32) -> i32 ---

	/// @return an integer clamped between a lower and upper bound
	ClampInt :: proc(a: i32, lower: i32, upper: i32) -> i32 ---

	/// @return the minimum of two floats
	MinFloat :: proc(a: f32, b: f32) -> f32 ---

	/// @return the maximum of two floats
	MaxFloat :: proc(a: f32, b: f32) -> f32 ---

	/// @return the absolute value of a float
	AbsFloat :: proc(a: f32) -> f32 ---

	/// @return a float clamped between a lower and upper bound
	ClampFloat :: proc(a: f32, lower: f32, upper: f32) -> f32 ---

	/// Compute an approximate arctangent in the range [-pi, pi]
	/// This is hand coded for cross-platform determinism. The atan2f
	/// function in the standard library is not cross-platform deterministic.
	///	Accurate to around 0.0023 degrees
	Atan2 :: proc(y: f32, x: f32) -> f32 ---

	/// Compute the cosine and sine of an angle in radians. Implemented
	/// for cross-platform determinism.
	ComputeCosSin :: proc(radians: f32) -> CosSin ---

	/// Vector dot product
	Dot :: proc(a: Vec2, b: Vec2) -> f32 ---

	/// Vector cross product. In 2D this yields a scalar.
	Cross :: proc(a: Vec2, b: Vec2) -> f32 ---

	/// Perform the cross product on a vector and a scalar. In 2D this produces a vector.
	CrossVS :: proc(v: Vec2, s: f32) -> Vec2 ---

	/// Perform the cross product on a scalar and a vector. In 2D this produces a vector.
	CrossSV :: proc(s: f32, v: Vec2) -> Vec2 ---

	/// Get a left pointing perpendicular vector. Equivalent to b2CrossSV(1.0f, v)
	LeftPerp :: proc(v: Vec2) -> Vec2 ---

	/// Get a right pointing perpendicular vector. Equivalent to b2CrossVS(v, 1.0f)
	RightPerp :: proc(v: Vec2) -> Vec2 ---

	/// Vector addition
	Add :: proc(a: Vec2, b: Vec2) -> Vec2 ---

	/// Vector subtraction
	Sub :: proc(a: Vec2, b: Vec2) -> Vec2 ---

	/// Vector negation
	Neg :: proc(a: Vec2) -> Vec2 ---

	/// Vector linear interpolation
	/// https://fgiesen.wordpress.com/2012/08/15/linear-interpolation-past-present-and-future/
	Lerp :: proc(a: Vec2, b: Vec2, t: f32) -> Vec2 ---

	/// Component-wise multiplication
	Mul :: proc(a: Vec2, b: Vec2) -> Vec2 ---

	/// Multiply a scalar and vector
	MulSV :: proc(s: f32, v: Vec2) -> Vec2 ---

	/// a + s * b
	MulAdd :: proc(a: Vec2, s: f32, b: Vec2) -> Vec2 ---

	/// a - s * b
	MulSub :: proc(a: Vec2, s: f32, b: Vec2) -> Vec2 ---

	/// Component-wise absolute vector
	Abs :: proc(a: Vec2) -> Vec2 ---

	/// Component-wise minimum vector
	Min :: proc(a: Vec2, b: Vec2) -> Vec2 ---

	/// Component-wise maximum vector
	Max :: proc(a: Vec2, b: Vec2) -> Vec2 ---

	/// Component-wise clamp vector v into the range [a, b]
	Clamp :: proc(v: Vec2, a: Vec2, b: Vec2) -> Vec2 ---

	/// Get the length of this vector (the norm)
	Length :: proc(v: Vec2) -> f32 ---

	/// Get the distance between two points
	Distance :: proc(a: Vec2, b: Vec2) -> f32 ---

	/// Convert a vector into a unit vector if possible, otherwise returns the zero vector.
	Normalize :: proc(v: Vec2) -> Vec2 ---

	/// Convert a vector into a unit vector if possible, otherwise returns the zero vector. Also
	/// outputs the length.
	GetLengthAndNormalize :: proc(length: ^f32, v: Vec2) -> Vec2 ---

	/// Normalize rotation
	NormalizeRot :: proc(q: Rot) -> Rot ---

	/// Integrate rotation from angular velocity
	/// @param q1 initial rotation
	/// @param deltaAngle the angular displacement in radians
	IntegrateRotation :: proc(q1: Rot, deltaAngle: f32) -> Rot ---

	/// Get the length squared of this vector
	LengthSquared :: proc(v: Vec2) -> f32 ---

	/// Get the distance squared between points
	DistanceSquared :: proc(a: Vec2, b: Vec2) -> f32 ---

	/// Make a rotation using an angle in radians
	MakeRot :: proc(radians: f32) -> Rot ---

	/// Compute the rotation between two unit vectors
	ComputeRotationBetweenUnitVectors :: proc(v1: Vec2, v2: Vec2) -> Rot ---

	/// Is this rotation normalized?
	IsNormalized :: proc(q: Rot) -> bool ---

	/// Normalized linear interpolation
	/// https://fgiesen.wordpress.com/2012/08/15/linear-interpolation-past-present-and-future/
	///	https://web.archive.org/web/20170825184056/http://number-none.com/product/Understanding%20Slerp,%20Then%20Not%20Using%20It/
	NLerp :: proc(q1: Rot, q2: Rot, t: f32) -> Rot ---

	/// Compute the angular velocity necessary to rotate between two rotations over a give time
	/// @param q1 initial rotation
	/// @param q2 final rotation
	/// @param inv_h inverse time step
	ComputeAngularVelocity :: proc(q1: Rot, q2: Rot, inv_h: f32) -> f32 ---

	/// Get the angle in radians in the range [-pi, pi]
	Rot_GetAngle :: proc(q: Rot) -> f32 ---

	/// Get the x-axis
	Rot_GetXAxis :: proc(q: Rot) -> Vec2 ---

	/// Get the y-axis
	Rot_GetYAxis :: proc(q: Rot) -> Vec2 ---

	/// Multiply two rotations: q * r
	MulRot :: proc(q: Rot, r: Rot) -> Rot ---

	/// Transpose multiply two rotations: qT * r
	InvMulRot :: proc(q: Rot, r: Rot) -> Rot ---

	/// relative angle between b and a (rot_b * inv(rot_a))
	RelativeAngle :: proc(b: Rot, a: Rot) -> f32 ---

	/// Convert an angle in the range [-2*pi, 2*pi] into the range [-pi, pi]
	UnwindAngle :: proc(radians: f32) -> f32 ---

	/// Convert any into the range [-pi, pi] (slow)
	UnwindLargeAngle :: proc(radians: f32) -> f32 ---

	/// Rotate a vector
	RotateVector :: proc(q: Rot, v: Vec2) -> Vec2 ---

	/// Inverse rotate a vector
	InvRotateVector :: proc(q: Rot, v: Vec2) -> Vec2 ---

	/// Transform a point (e.g. local space to world space)
	TransformPoint :: proc(t: Transform, p: Vec2) -> Vec2 ---

	/// Inverse transform a point (e.g. world space to local space)
	InvTransformPoint :: proc(t: Transform, p: Vec2) -> Vec2 ---

	/// Multiply two transforms. If the result is applied to a point p local to frame B,
	/// the transform would first convert p to a point local to frame A, then into a point
	/// in the world frame.
	/// v2 = A.q.Rot(B.q.Rot(v1) + B.p) + A.p
	///    = (A.q * B.q).Rot(v1) + A.q.Rot(B.p) + A.p
	MulTransforms :: proc(A: Transform, B: Transform) -> Transform ---

	/// Creates a transform that converts a local point in frame B to a local point in frame A.
	/// v2 = A.q' * (B.q * v1 + B.p - A.p)
	///    = A.q' * B.q * v1 + A.q' * (B.p - A.p)
	InvMulTransforms :: proc(A: Transform, B: Transform) -> Transform ---

	/// Multiply a 2-by-2 matrix times a 2D vector
	MulMV :: proc(A: Mat22, v: Vec2) -> Vec2 ---

	/// Get the inverse of a 2-by-2 matrix
	GetInverse22 :: proc(A: Mat22) -> Mat22 ---

	/// Solve A * x = b, where b is a column vector. This is more efficient
	/// than computing the inverse in one-shot cases.
	Solve22 :: proc(A: Mat22, b: Vec2) -> Vec2 ---

	/// Does a fully contain b
	AABB_Contains :: proc(a: AABB, b: AABB) -> bool ---

	/// Get the center of the AABB.
	AABB_Center :: proc(a: AABB) -> Vec2 ---

	/// Get the extents of the AABB (half-widths).
	AABB_Extents :: proc(a: AABB) -> Vec2 ---

	/// Union of two AABBs
	AABB_Union :: proc(a: AABB, b: AABB) -> AABB ---

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
