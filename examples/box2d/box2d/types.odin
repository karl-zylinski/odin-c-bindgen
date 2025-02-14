// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d

import "core:c"

_ :: c

foreign import lib "box2d.lib"

TaskCallback :: proc "c" (i32, i32, u32, rawptr)

EnqueueTaskCallback :: proc "c" (TaskCallback, i32, i32, rawptr, rawptr) -> rawptr

FinishTaskCallback :: proc "c" (rawptr, rawptr)

FrictionCallback :: proc "c" (f32, i32, f32, i32) -> f32

RestitutionCallback :: proc "c" (f32, i32, f32, i32) -> f32

/// Result from b2World_RayCastClosest
/// @ingroup world
RayResult :: struct {
	shapeId:    ShapeId,
	point:      Vec2,
	normal:     Vec2,
	fraction:   f32,
	nodeVisits: i32,
	leafVisits: i32,
	hit:        bool,
}

/// World definition used to create a simulation world.
/// Must be initialized using b2DefaultWorldDef().
/// @ingroup world
WorldDef :: struct {
	/// Gravity vector. Box2D has no up-vector defined.
	gravity: Vec2,

	/// Restitution speed threshold, usually in m/s. Collisions above this
	/// speed have restitution applied (will bounce).
	restitutionThreshold: f32,

	/// Threshold speed for hit events. Usually meters per second.
	hitEventThreshold: f32,

	/// Contact stiffness. Cycles per second. Increasing this increases the speed of overlap recovery, but can introduce jitter.
	contactHertz: f32,

	/// Contact bounciness. Non-dimensional. You can speed up overlap recovery by decreasing this with
	/// the trade-off that overlap resolution becomes more energetic.
	contactDampingRatio: f32,

	/// This parameter controls how fast overlap is resolved and usually has units of meters per second. This only
	/// puts a cap on the resolution speed. The resolution speed is increased by increasing the hertz and/or
	/// decreasing the damping ratio.
	contactPushMaxSpeed: f32,

	/// Joint stiffness. Cycles per second.
	jointHertz: f32,

	/// Joint bounciness. Non-dimensional.
	jointDampingRatio: f32,

	/// Maximum linear speed. Usually meters per second.
	maximumLinearSpeed: f32,

	/// Optional mixing callback for friction. The default uses sqrt(frictionA * frictionB).
	frictionCallback: FrictionCallback,

	/// Optional mixing callback for restitution. The default uses max(restitutionA, restitutionB).
	restitutionCallback: RestitutionCallback,

	/// Can bodies go to sleep to improve performance
	enableSleep: bool,

	/// Enable continuous collision
	enableContinuous: bool,

	/// Number of workers to use with the provided task system. Box2D performs best when using only
	/// performance cores and accessing a single L2 cache. Efficiency cores and hyper-threading provide
	/// little benefit and may even harm performance.
	/// @note Box2D does not create threads. This is the number of threads your applications has created
	/// that you are allocating to b2World_Step.
	/// @warning Do not modify the default value unless you are also providing a task system and providing
	/// task callbacks (enqueueTask and finishTask).
	workerCount: i32,

	/// Function to spawn tasks
	enqueueTask: EnqueueTaskCallback,

	/// Function to finish a task
	finishTask: FinishTaskCallback,

	/// User context that is provided to enqueueTask and finishTask
	userTaskContext: rawptr,

	/// User data
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// The body simulation type.
/// Each body is one of these three types. The type determines how the body behaves in the simulation.
/// @ingroup body
BodyType :: enum c.int {
	/// zero mass, zero velocity, may be manually moved
	staticBody = 0,

	/// zero mass, velocity set by user, moved by solver
	kinematicBody = 1,

	/// positive mass, velocity determined by forces, moved by solver
	dynamicBody = 2,

	/// number of body types
	bodyTypeCount,
}

/// A body definition holds all the data needed to construct a rigid body.
/// You can safely re-use body definitions. Shapes are added to a body after construction.
/// Body definitions are temporary objects used to bundle creation parameters.
/// Must be initialized using b2DefaultBodyDef().
/// @ingroup body
BodyDef :: struct {
	/// The body type: static, kinematic, or dynamic.
	type: BodyType,

	/// The initial world position of the body. Bodies should be created with the desired position.
	/// @note Creating bodies at the origin and then moving them nearly doubles the cost of body creation, especially
	/// if the body is moved after shapes have been added.
	position: Vec2,

	/// The initial world rotation of the body. Use b2MakeRot() if you have an angle.
	rotation: Rot,

	/// The initial linear velocity of the body's origin. Usually in meters per second.
	linearVelocity: Vec2,

	/// The initial angular velocity of the body. Radians per second.
	angularVelocity: f32,

	/// Linear damping is used to reduce the linear velocity. The damping parameter
	/// can be larger than 1 but the damping effect becomes sensitive to the
	/// time step when the damping parameter is large.
	/// Generally linear damping is undesirable because it makes objects move slowly
	/// as if they are floating.
	linearDamping: f32,

	/// Angular damping is used to reduce the angular velocity. The damping parameter
	/// can be larger than 1.0f but the damping effect becomes sensitive to the
	/// time step when the damping parameter is large.
	/// Angular damping can be use slow down rotating bodies.
	angularDamping: f32,

	/// Scale the gravity applied to this body. Non-dimensional.
	gravityScale: f32,

	/// Sleep speed threshold, default is 0.05 meters per second
	sleepThreshold: f32,

	/// Optional body name for debugging. Up to 31 characters (excluding null termination)
	name: cstring,

	/// Use this to store application specific body data.
	userData: rawptr,

	/// Set this flag to false if this body should never fall asleep.
	enableSleep: bool,

	/// Is this body initially awake or sleeping?
	isAwake: bool,

	/// Should this body be prevented from rotating? Useful for characters.
	fixedRotation: bool,

	/// Treat this body as high speed object that performs continuous collision detection
	/// against dynamic and kinematic bodies, but not other bullet bodies.
	/// @warning Bullets should be used sparingly. They are not a solution for general dynamic-versus-dynamic
	/// continuous collision. They may interfere with joint constraints.
	isBullet: bool,

	/// Used to disable a body. A disabled body does not move or collide.
	isEnabled: bool,

	/// This allows this body to bypass rotational speed limits. Should only be used
	/// for circular objects, like wheels.
	allowFastRotation: bool,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// This is used to filter collision on shapes. It affects shape-vs-shape collision
/// and shape-versus-query collision (such as b2World_CastRay).
/// @ingroup shape
Filter :: struct {
	/// The collision category bits. Normally you would just set one bit. The category bits should
	/// represent your application object types. For example:
	/// @code{
	categoryBits: u64,

	/// The collision mask bits. This states the categories that this
	/// shape would accept for collision.
	/// For example, you may want your player to only collide with static objects
	/// and other players.
	/// @code{
	maskBits: u64,

	/// Collision groups allow a certain group of objects to never collide (negative)
	/// or always collide (positive). A group index of zero has no effect. Non-zero group filtering
	/// always wins against the mask bits.
	/// For example, you may want ragdolls to collide with other ragdolls but you don't want
	/// ragdoll self-collision. In this case you would give each ragdoll a unique negative group index
	/// and apply that group index to all shapes on the ragdoll.
	groupIndex: i32,
}

/// The query filter is used to filter collisions between queries and shapes. For example,
/// you may want a ray-cast representing a projectile to hit players and the static environment
/// but not debris.
/// @ingroup shape
QueryFilter :: struct {
	/// The collision category bits of this query. Normally you would just set one bit.
	categoryBits: u64,

	/// The collision mask bits. This states the shape categories that this
	/// query would accept for collision.
	maskBits: u64,
}

/// Shape type
/// @ingroup shape
ShapeType :: enum c.int {
	/// A circle with an offset
	circleShape,

	/// A capsule is an extruded circle
	capsuleShape,

	/// A line segment
	segmentShape,

	/// A convex polygon
	polygonShape,

	/// A line segment owned by a chain shape
	chainSegmentShape,

	/// The number of shape types
	shapeTypeCount,
}

/// Used to create a shape.
/// This is a temporary object used to bundle shape creation parameters. You may use
/// the same shape definition to create multiple shapes.
/// Must be initialized using b2DefaultShapeDef().
/// @ingroup shape
ShapeDef :: struct {
	/// Use this to store application specific shape data.
	userData: rawptr,

	/// The Coulomb (dry) friction coefficient, usually in the range [0,1].
	friction: f32,

	/// The coefficient of restitution (bounce) usually in the range [0,1].
	/// https://en.wikipedia.org/wiki/Coefficient_of_restitution
	restitution: f32,

	/// The rolling resistance usually in the range [0,1].
	rollingResistance: f32,

	/// The tangent speed for conveyor belts
	tangentSpeed: f32,

	/// User material identifier. This is passed with query results and to friction and restitution
	/// combining functions. It is not used internally.
	material: i32,

	/// The density, usually in kg/m^2.
	density: f32,

	/// Collision filtering data.
	filter: Filter,

	/// Custom debug draw color.
	customColor: u32,

	/// A sensor shape generates overlap events but never generates a collision response.
	/// Sensors do not collide with other sensors and do not have continuous collision.
	/// Instead, use a ray or shape cast for those scenarios.
	isSensor: bool,

	/// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	enableContactEvents: bool,

	/// Enable hit events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	enableHitEvents: bool,

	/// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
	/// and must be carefully handled due to threading. Ignored for sensors.
	enablePreSolveEvents: bool,

	/// Normally shapes on static bodies don't invoke contact creation when they are added to the world. This overrides
	/// that behavior and causes contact creation. This significantly slows down static body creation which can be important
	/// when there are many static shapes.
	/// This is implicitly always true for sensors, dynamic bodies, and kinematic bodies.
	invokeContactCreation: bool,

	/// Should the body update the mass properties when this shape is created. Default is true.
	updateBodyMass: bool,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// Surface materials allow chain shapes to have per segment surface properties.
/// @ingroup shape
SurfaceMaterial :: struct {
	/// The Coulomb (dry) friction coefficient, usually in the range [0,1].
	friction: f32,

	/// The coefficient of restitution (bounce) usually in the range [0,1].
	/// https://en.wikipedia.org/wiki/Coefficient_of_restitution
	restitution: f32,

	/// The rolling resistance usually in the range [0,1].
	rollingResistance: f32,

	/// The tangent speed for conveyor belts
	tangentSpeed: f32,

	/// User material identifier. This is passed with query results and to friction and restitution
	/// combining functions. It is not used internally.
	material: i32,

	/// Custom debug draw color.
	customColor: u32,
}

/// Used to create a chain of line segments. This is designed to eliminate ghost collisions with some limitations.
/// - chains are one-sided
/// - chains have no mass and should be used on static bodies
/// - chains have a counter-clockwise winding order
/// - chains are either a loop or open
/// - a chain must have at least 4 points
/// - the distance between any two points must be greater than B2_LINEAR_SLOP
/// - a chain shape should not self intersect (this is not validated)
/// - an open chain shape has NO COLLISION on the first and final edge
/// - you may overlap two open chains on their first three and/or last three points to get smooth collision
/// - a chain shape creates multiple line segment shapes on the body
/// https://en.wikipedia.org/wiki/Polygonal_chain
/// Must be initialized using b2DefaultChainDef().
/// @warning Do not use chain shapes unless you understand the limitations. This is an advanced feature.
/// @ingroup shape
ChainDef :: struct {
	/// Use this to store application specific shape data.
	userData: rawptr,

	/// An array of at least 4 points. These are cloned and may be temporary.
	points: [^]Vec2,

	/// The point count, must be 4 or more.
	count: i32,

	/// Surface materials for each segment. These are cloned.
	materials: [^]SurfaceMaterial,

	/// The material count. Must be 1 or count. This allows you to provide one
	/// material for all segments or a unique material per segment.
	materialCount: i32,

	/// Contact filtering data.
	filter: Filter,

	/// Indicates a closed chain formed by connecting the first and last points
	isLoop: bool,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

//! @cond
/// Profiling data. Times are in milliseconds.
Profile :: struct {
	step:                f32,
	pairs:               f32,
	collide:             f32,
	solve:               f32,
	mergeIslands:        f32,
	prepareStages:       f32,
	solveConstraints:    f32,
	prepareConstraints:  f32,
	integrateVelocities: f32,
	warmStart:           f32,
	solveImpulses:       f32,
	integratePositions:  f32,
	relaxImpulses:       f32,
	applyRestitution:    f32,
	storeImpulses:       f32,
	splitIslands:        f32,
	transforms:          f32,
	hitEvents:           f32,
	refit:               f32,
	bullets:             f32,
	sleepIslands:        f32,
	sensors:             f32,
}

/// Counters that give details of the simulation size.
Counters :: struct {
	bodyCount:        i32,
	shapeCount:       i32,
	contactCount:     i32,
	jointCount:       i32,
	islandCount:      i32,
	stackUsed:        i32,
	staticTreeHeight: i32,
	treeHeight:       i32,
	byteCount:        i32,
	taskCount:        i32,
	colorCounts:      [12]i32,
}

/// Joint type enumeration
///
/// This is useful because all joint types use b2JointId and sometimes you
/// want to get the type of a joint.
/// @ingroup joint
JointType :: enum c.int {
	distanceJoint,
	motorJoint,
	mouseJoint,
	nullJoint,
	prismaticJoint,
	revoluteJoint,
	weldJoint,
	wheelJoint,
}

/// Distance joint definition
///
/// This requires defining an anchor point on both
/// bodies and the non-zero distance of the distance joint. The definition uses
/// local anchor points so that the initial configuration can violate the
/// constraint slightly. This helps when saving and loading a game.
/// @ingroup distance_joint
DistanceJointDef :: struct {
	/// The first attached body
	bodyIdA: BodyId,

	/// The second attached body
	bodyIdB: BodyId,

	/// The local anchor point relative to bodyA's origin
	localAnchorA: Vec2,

	/// The local anchor point relative to bodyB's origin
	localAnchorB: Vec2,

	/// The rest length of this joint. Clamped to a stable minimum value.
	length: f32,

	/// Enable the distance constraint to behave like a spring. If false
	/// then the distance joint will be rigid, overriding the limit and motor.
	enableSpring: bool,

	/// The spring linear stiffness Hertz, cycles per second
	hertz: f32,

	/// The spring linear damping ratio, non-dimensional
	dampingRatio: f32,

	/// Enable/disable the joint limit
	enableLimit: bool,

	/// Minimum length. Clamped to a stable minimum value.
	minLength: f32,

	/// Maximum length. Must be greater than or equal to the minimum length.
	maxLength: f32,

	/// Enable/disable the joint motor
	enableMotor: bool,

	/// The maximum motor force, usually in newtons
	maxMotorForce: f32,

	/// The desired motor speed, usually in meters per second
	motorSpeed: f32,

	/// Set this flag to true if the attached bodies should collide
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// A motor joint is used to control the relative motion between two bodies
///
/// A typical usage is to control the movement of a dynamic body with respect to the ground.
/// @ingroup motor_joint
MotorJointDef :: struct {
	/// The first attached body
	bodyIdA: BodyId,

	/// The second attached body
	bodyIdB: BodyId,

	/// Position of bodyB minus the position of bodyA, in bodyA's frame
	linearOffset: Vec2,

	/// The bodyB angle minus bodyA angle in radians
	angularOffset: f32,

	/// The maximum motor force in newtons
	maxForce: f32,

	/// The maximum motor torque in newton-meters
	maxTorque: f32,

	/// Position correction factor in the range [0,1]
	correctionFactor: f32,

	/// Set this flag to true if the attached bodies should collide
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// A mouse joint is used to make a point on a body track a specified world point.
///
/// This a soft constraint and allows the constraint to stretch without
/// applying huge forces. This also applies rotation constraint heuristic to improve control.
/// @ingroup mouse_joint
MouseJointDef :: struct {
	/// The first attached body. This is assumed to be static.
	bodyIdA: BodyId,

	/// The second attached body.
	bodyIdB: BodyId,

	/// The initial target point in world space
	target: Vec2,

	/// Stiffness in hertz
	hertz: f32,

	/// Damping ratio, non-dimensional
	dampingRatio: f32,

	/// Maximum force, typically in newtons
	maxForce: f32,

	/// Set this flag to true if the attached bodies should collide.
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// A null joint is used to disable collision between two specific bodies.
///
/// @ingroup null_joint
NullJointDef :: struct {
	/// The first attached body.
	bodyIdA: BodyId,

	/// The second attached body.
	bodyIdB: BodyId,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// Prismatic joint definition
///
/// This requires defining a line of motion using an axis and an anchor point.
/// The definition uses local anchor points and a local axis so that the initial
/// configuration can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space.
/// @ingroup prismatic_joint
PrismaticJointDef :: struct {
	/// The first attached body
	bodyIdA: BodyId,

	/// The second attached body
	bodyIdB: BodyId,

	/// The local anchor point relative to bodyA's origin
	localAnchorA: Vec2,

	/// The local anchor point relative to bodyB's origin
	localAnchorB: Vec2,

	/// The local translation unit axis in bodyA
	localAxisA: Vec2,

	/// The constrained angle between the bodies: bodyB_angle - bodyA_angle
	referenceAngle: f32,

	/// Enable a linear spring along the prismatic joint axis
	enableSpring: bool,

	/// The spring stiffness Hertz, cycles per second
	hertz: f32,

	/// The spring damping ratio, non-dimensional
	dampingRatio: f32,

	/// Enable/disable the joint limit
	enableLimit: bool,

	/// The lower translation limit
	lowerTranslation: f32,

	/// The upper translation limit
	upperTranslation: f32,

	/// Enable/disable the joint motor
	enableMotor: bool,

	/// The maximum motor force, typically in newtons
	maxMotorForce: f32,

	/// The desired motor speed, typically in meters per second
	motorSpeed: f32,

	/// Set this flag to true if the attached bodies should collide
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// Revolute joint definition
///
/// This requires defining an anchor point where the bodies are joined.
/// The definition uses local anchor points so that the
/// initial configuration can violate the constraint slightly. You also need to
/// specify the initial relative angle for joint limits. This helps when saving
/// and loading a game.
/// The local anchor points are measured from the body's origin
/// rather than the center of mass because:
/// 1. you might not know where the center of mass will be
/// 2. if you add/remove shapes from a body and recompute the mass, the joints will be broken
/// @ingroup revolute_joint
RevoluteJointDef :: struct {
	/// The first attached body
	bodyIdA: BodyId,

	/// The second attached body
	bodyIdB: BodyId,

	/// The local anchor point relative to bodyA's origin
	localAnchorA: Vec2,

	/// The local anchor point relative to bodyB's origin
	localAnchorB: Vec2,

	/// The bodyB angle minus bodyA angle in the reference state (radians).
	/// This defines the zero angle for the joint limit.
	referenceAngle: f32,

	/// Enable a rotational spring on the revolute hinge axis
	enableSpring: bool,

	/// The spring stiffness Hertz, cycles per second
	hertz: f32,

	/// The spring damping ratio, non-dimensional
	dampingRatio: f32,

	/// A flag to enable joint limits
	enableLimit: bool,

	/// The lower angle for the joint limit in radians
	lowerAngle: f32,

	/// The upper angle for the joint limit in radians
	upperAngle: f32,

	/// A flag to enable the joint motor
	enableMotor: bool,

	/// The maximum motor torque, typically in newton-meters
	maxMotorTorque: f32,

	/// The desired motor speed in radians per second
	motorSpeed: f32,

	/// Scale the debug draw
	drawSize: f32,

	/// Set this flag to true if the attached bodies should collide
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// Weld joint definition
///
/// A weld joint connect to bodies together rigidly. This constraint provides springs to mimic
/// soft-body simulation.
/// @note The approximate solver in Box2D cannot hold many bodies together rigidly
/// @ingroup weld_joint
WeldJointDef :: struct {
	/// The first attached body
	bodyIdA: BodyId,

	/// The second attached body
	bodyIdB: BodyId,

	/// The local anchor point relative to bodyA's origin
	localAnchorA: Vec2,

	/// The local anchor point relative to bodyB's origin
	localAnchorB: Vec2,

	/// The bodyB angle minus bodyA angle in the reference state (radians)
	referenceAngle: f32,

	/// Linear stiffness expressed as Hertz (cycles per second). Use zero for maximum stiffness.
	linearHertz: f32,

	/// Angular stiffness as Hertz (cycles per second). Use zero for maximum stiffness.
	angularHertz: f32,

	/// Linear damping ratio, non-dimensional. Use 1 for critical damping.
	linearDampingRatio: f32,

	/// Linear damping ratio, non-dimensional. Use 1 for critical damping.
	angularDampingRatio: f32,

	/// Set this flag to true if the attached bodies should collide
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// Wheel joint definition
///
/// This requires defining a line of motion using an axis and an anchor point.
/// The definition uses local  anchor points and a local axis so that the initial
/// configuration can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space.
/// @ingroup wheel_joint
WheelJointDef :: struct {
	/// The first attached body
	bodyIdA: BodyId,

	/// The second attached body
	bodyIdB: BodyId,

	/// The local anchor point relative to bodyA's origin
	localAnchorA: Vec2,

	/// The local anchor point relative to bodyB's origin
	localAnchorB: Vec2,

	/// The local translation unit axis in bodyA
	localAxisA: Vec2,

	/// Enable a linear spring along the local axis
	enableSpring: bool,

	/// Spring stiffness in Hertz
	hertz: f32,

	/// Spring damping ratio, non-dimensional
	dampingRatio: f32,

	/// Enable/disable the joint linear limit
	enableLimit: bool,

	/// The lower translation limit
	lowerTranslation: f32,

	/// The upper translation limit
	upperTranslation: f32,

	/// Enable/disable the joint rotational motor
	enableMotor: bool,

	/// The maximum motor torque, typically in newton-meters
	maxMotorTorque: f32,

	/// The desired motor speed in radians per second
	motorSpeed: f32,

	/// Set this flag to true if the attached bodies should collide
	collideConnected: bool,

	/// User data pointer
	userData: rawptr,

	/// Used internally to detect a valid definition. DO NOT SET.
	internalValue: i32,
}

/// The explosion definition is used to configure options for explosions. Explosions
/// consider shape geometry when computing the impulse.
/// @ingroup world
ExplosionDef :: struct {
	/// Mask bits to filter shapes
	maskBits: u64,

	/// The center of the explosion in world space
	position: Vec2,

	/// The radius of the explosion
	radius: f32,

	/// The falloff distance beyond the radius. Impulse is reduced to zero at this distance.
	falloff: f32,

	/// Impulse per unit length. This applies an impulse according to the shape perimeter that
	/// is facing the explosion. Explosions only apply to circles, capsules, and polygons. This
	/// may be negative for implosions.
	impulsePerLength: f32,
}

/// A begin touch event is generated when a shape starts to overlap a sensor shape.
SensorBeginTouchEvent :: struct {
	/// The id of the sensor shape
	sensorShapeId: ShapeId,

	/// The id of the dynamic shape that began touching the sensor shape
	visitorShapeId: ShapeId,
}

/// An end touch event is generated when a shape stops overlapping a sensor shape.
///	These include things like setting the transform, destroying a body or shape, or changing
///	a filter. You will also get an end event if the sensor or visitor are destroyed.
///	Therefore you should always confirm the shape id is valid using b2Shape_IsValid.
SensorEndTouchEvent :: struct {
	/// The id of the sensor shape
	///	@warning this shape may have been destroyed
	///	@see b2Shape_IsValid
	sensorShapeId: ShapeId,

	/// The id of the dynamic shape that stopped touching the sensor shape
	///	@warning this shape may have been destroyed
	///	@see b2Shape_IsValid
	visitorShapeId: ShapeId,
}

/// Sensor events are buffered in the Box2D world and are available
/// as begin/end overlap event arrays after the time step is complete.
/// Note: these may become invalid if bodies and/or shapes are destroyed
SensorEvents :: struct {
	/// Array of sensor begin touch events
	beginEvents: ^SensorBeginTouchEvent,

	/// Array of sensor end touch events
	endEvents: ^SensorEndTouchEvent,

	/// The number of begin touch events
	beginCount: i32,

	/// The number of end touch events
	endCount: i32,
}

/// A begin touch event is generated when two shapes begin touching.
ContactBeginTouchEvent :: struct {
	/// Id of the first shape
	shapeIdA: ShapeId,

	/// Id of the second shape
	shapeIdB: ShapeId,

	/// The initial contact manifold. This is recorded before the solver is called,
	/// so all the impulses will be zero.
	manifold: Manifold,
}

/// An end touch event is generated when two shapes stop touching.
///	You will get an end event if you do anything that destroys contacts previous to the last
///	world step. These include things like setting the transform, destroying a body
///	or shape, or changing a filter or body type.
ContactEndTouchEvent :: struct {
	/// Id of the first shape
	///	@warning this shape may have been destroyed
	///	@see b2Shape_IsValid
	shapeIdA: ShapeId,

	/// Id of the second shape
	///	@warning this shape may have been destroyed
	///	@see b2Shape_IsValid
	shapeIdB: ShapeId,
}

/// A hit touch event is generated when two shapes collide with a speed faster than the hit speed threshold.
ContactHitEvent :: struct {
	/// Id of the first shape
	shapeIdA: ShapeId,

	/// Id of the second shape
	shapeIdB: ShapeId,

	/// Point where the shapes hit
	point: Vec2,

	/// Normal vector pointing from shape A to shape B
	normal: Vec2,

	/// The speed the shapes are approaching. Always positive. Typically in meters per second.
	approachSpeed: f32,
}

/// Contact events are buffered in the Box2D world and are available
/// as event arrays after the time step is complete.
/// Note: these may become invalid if bodies and/or shapes are destroyed
ContactEvents :: struct {
	/// Array of begin touch events
	beginEvents: ^ContactBeginTouchEvent,

	/// Array of end touch events
	endEvents: ^ContactEndTouchEvent,

	/// Array of hit events
	hitEvents: ^ContactHitEvent,

	/// Number of begin touch events
	beginCount: i32,

	/// Number of end touch events
	endCount: i32,

	/// Number of hit events
	hitCount: i32,
}

/// Body move events triggered when a body moves.
/// Triggered when a body moves due to simulation. Not reported for bodies moved by the user.
/// This also has a flag to indicate that the body went to sleep so the application can also
/// sleep that actor/entity/object associated with the body.
/// On the other hand if the flag does not indicate the body went to sleep then the application
/// can treat the actor/entity/object associated with the body as awake.
/// This is an efficient way for an application to update game object transforms rather than
/// calling functions such as b2Body_GetTransform() because this data is delivered as a contiguous array
/// and it is only populated with bodies that have moved.
/// @note If sleeping is disabled all dynamic and kinematic bodies will trigger move events.
BodyMoveEvent :: struct {
	transform:  Transform,
	bodyId:     BodyId,
	userData:   rawptr,
	fellAsleep: bool,
}

/// Body events are buffered in the Box2D world and are available
/// as event arrays after the time step is complete.
/// Note: this data becomes invalid if bodies are destroyed
BodyEvents :: struct {
	/// Array of move events
	moveEvents: ^BodyMoveEvent,

	/// Number of move events
	moveCount: i32,
}

/// The contact data for two shapes. By convention the manifold normal points
/// from shape A to shape B.
/// @see b2Shape_GetContactData() and b2Body_GetContactData()
ContactData :: struct {
	shapeIdA: ShapeId,
	shapeIdB: ShapeId,
	manifold: Manifold,
}

CustomFilterFcn :: proc "c" (ShapeId, ShapeId, rawptr) -> bool

PreSolveFcn :: proc "c" (ShapeId, ShapeId, ^Manifold, rawptr) -> bool

OverlapResultFcn :: proc "c" (ShapeId, rawptr) -> bool

CastResultFcn :: proc "c" (ShapeId, Vec2, Vec2, f32, rawptr) -> f32

/// These colors are used for debug draw and mostly match the named SVG colors.
/// See https://www.rapidtables.com/web/color/index.html
/// https://johndecember.com/html/spec/colorsvg.html
/// https://upload.wikimedia.org/wikipedia/commons/2/2b/SVG_Recognized_color_keyword_names.svg
HexColor :: enum c.int {
	AliceBlue            = 15792383,
	AntiqueWhite         = 16444375,
	Aqua                 = 65535,
	Aquamarine           = 8388564,
	Azure                = 15794175,
	Beige                = 16119260,
	Bisque               = 16770244,
	Black                = 0,
	BlanchedAlmond       = 16772045,
	Blue                 = 255,
	BlueViolet           = 9055202,
	Brown                = 10824234,
	Burlywood            = 14596231,
	CadetBlue            = 6266528,
	Chartreuse           = 8388352,
	Chocolate            = 13789470,
	Coral                = 16744272,
	CornflowerBlue       = 6591981,
	Cornsilk             = 16775388,
	Crimson              = 14423100,
	Cyan                 = 65535,
	DarkBlue             = 139,
	DarkCyan             = 35723,
	DarkGoldenRod        = 12092939,
	DarkGray             = 11119017,
	DarkGreen            = 25600,
	DarkKhaki            = 12433259,
	DarkMagenta          = 9109643,
	DarkOliveGreen       = 5597999,
	DarkOrange           = 16747520,
	DarkOrchid           = 10040012,
	DarkRed              = 9109504,
	DarkSalmon           = 15308410,
	DarkSeaGreen         = 9419919,
	DarkSlateBlue        = 4734347,
	DarkSlateGray        = 3100495,
	DarkTurquoise        = 52945,
	DarkViolet           = 9699539,
	DeepPink             = 16716947,
	DeepSkyBlue          = 49151,
	DimGray              = 6908265,
	DodgerBlue           = 2003199,
	FireBrick            = 11674146,
	FloralWhite          = 16775920,
	ForestGreen          = 2263842,
	Fuchsia              = 16711935,
	Gainsboro            = 14474460,
	GhostWhite           = 16316671,
	Gold                 = 16766720,
	GoldenRod            = 14329120,
	Gray                 = 8421504,
	Green                = 32768,
	GreenYellow          = 11403055,
	HoneyDew             = 15794160,
	HotPink              = 16738740,
	IndianRed            = 13458524,
	Indigo               = 4915330,
	Ivory                = 16777200,
	Khaki                = 15787660,
	Lavender             = 15132410,
	LavenderBlush        = 16773365,
	LawnGreen            = 8190976,
	LemonChiffon         = 16775885,
	LightBlue            = 11393254,
	LightCoral           = 15761536,
	LightCyan            = 14745599,
	LightGoldenRodYellow = 16448210,
	LightGray            = 13882323,
	LightGreen           = 9498256,
	LightPink            = 16758465,
	LightSalmon          = 16752762,
	LightSeaGreen        = 2142890,
	LightSkyBlue         = 8900346,
	LightSlateGray       = 7833753,
	LightSteelBlue       = 11584734,
	LightYellow          = 16777184,
	Lime                 = 65280,
	LimeGreen            = 3329330,
	Linen                = 16445670,
	Magenta              = 16711935,
	Maroon               = 8388608,
	MediumAquaMarine     = 6737322,
	MediumBlue           = 205,
	MediumOrchid         = 12211667,
	MediumPurple         = 9662683,
	MediumSeaGreen       = 3978097,
	MediumSlateBlue      = 8087790,
	MediumSpringGreen    = 64154,
	MediumTurquoise      = 4772300,
	MediumVioletRed      = 13047173,
	MidnightBlue         = 1644912,
	MintCream            = 16121850,
	MistyRose            = 16770273,
	Moccasin             = 16770229,
	NavajoWhite          = 16768685,
	Navy                 = 128,
	OldLace              = 16643558,
	Olive                = 8421376,
	OliveDrab            = 7048739,
	Orange               = 16753920,
	OrangeRed            = 16729344,
	Orchid               = 14315734,
	PaleGoldenRod        = 15657130,
	PaleGreen            = 10025880,
	PaleTurquoise        = 11529966,
	PaleVioletRed        = 14381203,
	PapayaWhip           = 16773077,
	PeachPuff            = 16767673,
	Peru                 = 13468991,
	Pink                 = 16761035,
	Plum                 = 14524637,
	PowderBlue           = 11591910,
	Purple               = 8388736,
	RebeccaPurple        = 6697881,
	Red                  = 16711680,
	RosyBrown            = 12357519,
	RoyalBlue            = 4286945,
	SaddleBrown          = 9127187,
	Salmon               = 16416882,
	SandyBrown           = 16032864,
	SeaGreen             = 3050327,
	SeaShell             = 16774638,
	Sienna               = 10506797,
	Silver               = 12632256,
	SkyBlue              = 8900331,
	SlateBlue            = 6970061,
	SlateGray            = 7372944,
	Snow                 = 16775930,
	SpringGreen          = 65407,
	SteelBlue            = 4620980,
	Tan                  = 13808780,
	Teal                 = 32896,
	Thistle              = 14204888,
	Tomato               = 16737095,
	Turquoise            = 4251856,
	Violet               = 15631086,
	Wheat                = 16113331,
	White                = 16777215,
	WhiteSmoke           = 16119285,
	Yellow               = 16776960,
	YellowGreen          = 10145074,
	Box2DRed             = 14430514,
	Box2DBlue            = 3190463,
	Box2DGreen           = 9226532,
	Box2DYellow          = 16772748,
}

/// This struct holds callbacks you can implement to draw a Box2D world.
/// This structure should be zero initialized.
/// @ingroup world
DebugDraw :: struct {
	/// Draw a closed polygon provided in CCW order.
	DrawPolygon: proc "c" (^Vec2, i32, HexColor, rawptr),

	/// Draw a solid closed polygon provided in CCW order.
	DrawSolidPolygon: proc "c" (Transform, ^Vec2, i32, f32, HexColor, rawptr),

	/// Draw a circle.
	DrawCircle: proc "c" (Vec2, f32, HexColor, rawptr),

	/// Draw a solid circle.
	DrawSolidCircle: proc "c" (Transform, f32, HexColor, rawptr),

	/// Draw a solid capsule.
	DrawSolidCapsule: proc "c" (Vec2, Vec2, f32, HexColor, rawptr),

	/// Draw a line segment.
	DrawSegment: proc "c" (Vec2, Vec2, HexColor, rawptr),

	/// Draw a transform. Choose your own length scale.
	DrawTransform: proc "c" (Transform, rawptr),

	/// Draw a point.
	DrawPoint: proc "c" (Vec2, f32, HexColor, rawptr),

	/// Draw a string in world space
	DrawString: proc "c" (Vec2, cstring, HexColor, rawptr),

	/// Bounds to use if restricting drawing to a rectangular region
	drawingBounds: AABB,

	/// Option to restrict drawing to a rectangular region. May suffer from unstable depth sorting.
	useDrawingBounds: bool,

	/// Option to draw shapes
	drawShapes: bool,

	/// Option to draw joints
	drawJoints: bool,

	/// Option to draw additional information for joints
	drawJointExtras: bool,

	/// Option to draw the bounding boxes for shapes
	drawAABBs: bool,

	/// Option to draw the mass and center of mass of dynamic bodies
	drawMass: bool,

	/// Option to draw body names
	drawBodyNames: bool,

	/// Option to draw contact points
	drawContacts: bool,

	/// Option to visualize the graph coloring used for contacts and joints
	drawGraphColors: bool,

	/// Option to draw contact normals
	drawContactNormals: bool,

	/// Option to draw contact normal impulses
	drawContactImpulses: bool,

	/// Option to draw contact friction impulses
	drawFrictionImpulses: bool,

	/// User context that is passed as an argument to drawing callback functions
	_context: rawptr,
}

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// Use this to initialize your world definition
	/// @ingroup world
	DefaultWorldDef :: proc() -> WorldDef ---

	/// Use this to initialize your body definition
	/// @ingroup body
	DefaultBodyDef :: proc() -> BodyDef ---

	/// Use this to initialize your filter
	/// @ingroup shape
	DefaultFilter :: proc() -> Filter ---

	/// Use this to initialize your query filter
	/// @ingroup shape
	DefaultQueryFilter :: proc() -> QueryFilter ---

	/// Use this to initialize your shape definition
	/// @ingroup shape
	DefaultShapeDef :: proc() -> ShapeDef ---

	/// Use this to initialize your surface material
	/// @ingroup shape
	DefaultSurfaceMaterial :: proc() -> SurfaceMaterial ---

	/// Use this to initialize your chain definition
	/// @ingroup shape
	DefaultChainDef :: proc() -> ChainDef ---

	/// Use this to initialize your joint definition
	/// @ingroup distance_joint
	DefaultDistanceJointDef :: proc() -> DistanceJointDef ---

	/// Use this to initialize your joint definition
	/// @ingroup motor_joint
	DefaultMotorJointDef :: proc() -> MotorJointDef ---

	/// Use this to initialize your joint definition
	/// @ingroup mouse_joint
	DefaultMouseJointDef :: proc() -> MouseJointDef ---

	/// Use this to initialize your joint definition
	/// @ingroup null_joint
	DefaultNullJointDef :: proc() -> NullJointDef ---

	/// Use this to initialize your joint definition
	/// @ingroupd prismatic_joint
	DefaultPrismaticJointDef :: proc() -> PrismaticJointDef ---

	/// Use this to initialize your joint definition.
	/// @ingroup revolute_joint
	DefaultRevoluteJointDef :: proc() -> RevoluteJointDef ---

	/// Use this to initialize your joint definition
	/// @ingroup weld_joint
	DefaultWeldJointDef :: proc() -> WeldJointDef ---

	/// Use this to initialize your joint definition
	/// @ingroup wheel_joint
	DefaultWheelJointDef :: proc() -> WheelJointDef ---

	/// Use this to initialize your explosion definition
	/// @ingroup world
	DefaultExplosionDef :: proc() -> ExplosionDef ---

	/// Use this to initialize your drawing interface. This allows you to implement a sub-set
	/// of the drawing functions.
	DefaultDebugDraw :: proc() -> DebugDraw ---
}
