package box2d

import "core:c"

_ :: c

foreign import lib "box2d.lib"

/// Task interface
/// This is prototype for a Box2D task. Your task system is expected to invoke the Box2D task with these arguments.
/// The task spans a range of the parallel-for: [startIndex, endIndex)
/// The worker index must correctly identify each worker in the user thread pool, expected in [0, workerCount).
/// A worker must only exist on only one thread at a time and is analogous to the thread index.
/// The task context is the context pointer sent from Box2D when it is enqueued.
/// The startIndex and endIndex are expected in the range [0, itemCount) where itemCount is the argument to b2EnqueueTaskCallback
/// below. Box2D expects startIndex < endIndex and will execute a loop like this:
///
/// @code{.c}
/// for (int i = startIndex; i < endIndex; ++i)
/// {
/// 	DoWork();
/// }
/// @endcode
/// @ingroup world
TaskCallback :: proc "c" (c.int, c.int, u32, rawptr)

/// These functions can be provided to Box2D to invoke a task system. These are designed to work well with enkiTS.
/// Returns a pointer to the user's task object. May be nullptr. A nullptr indicates to Box2D that the work was executed
/// serially within the callback and there is no need to call b2FinishTaskCallback.
/// The itemCount is the number of Box2D work items that are to be partitioned among workers by the user's task system.
/// This is essentially a parallel-for. The minRange parameter is a suggestion of the minimum number of items to assign
/// per worker to reduce overhead. For example, suppose the task is small and that itemCount is 16. A minRange of 8 suggests
/// that your task system should split the work items among just two workers, even if you have more available.
/// In general the range [startIndex, endIndex) send to b2TaskCallback should obey:
/// endIndex - startIndex >= minRange
/// The exception of course is when itemCount < minRange.
/// @ingroup world
EnqueueTaskCallback :: proc "c" (TaskCallback, c.int, c.int, rawptr, rawptr) -> rawptr

/// Finishes a user task object that wraps a Box2D task.
/// @ingroup world
FinishTaskCallback :: proc "c" (rawptr, rawptr)

/// Optional friction mixing callback. This intentionally provides no context objects because this is called
/// from a worker thread.
/// @warning This function should not attempt to modify Box2D state or user application state.
FrictionCallback :: proc "c" (f32, c.int, f32, c.int) -> f32

/// Optional restitution mixing callback. This intentionally provides no context objects because this is called
/// from a worker thread.
/// @warning This function should not attempt to modify Box2D state or user application state.
RestitutionCallback :: proc "c" (f32, c.int, f32, c.int) -> f32

/// Result from b2World_RayCastClosest
/// @ingroup world
RayResult :: struct {
	shapeId:    ShapeId,
	point:      Vec2,
	normal:     Vec2,
	fraction:   f32,
	nodeVisits: c.int,
	leafVisits: c.int,
	hit:        bool,
}

/// World definition used to create a simulation world.
/// Must be initialized using b2DefaultWorldDef().
/// @ingroup world
WorldDef :: struct {
	gravity:                                                                                                                                            Vec2,                /// Gravity vector. Box2D has no up-vector defined.
	restitutionThreshold, hitEventThreshold, contactHertz, contactDampingRatio, contactPushMaxSpeed, jointHertz, jointDampingRatio, maximumLinearSpeed: f32,                 /// Restitution speed threshold, usually in m/s. Collisions above this
	/// speed have restitution applied (will bounce).
	frictionCallback:                                                                                                                                   FrictionCallback,    /// Optional mixing callback for friction. The default uses sqrt(frictionA * frictionB).
	restitutionCallback:                                                                                                                                RestitutionCallback, /// Optional mixing callback for restitution. The default uses max(restitutionA, restitutionB).
	enableSleep, enableContinuous:                                                                                                                      bool,                /// Can bodies go to sleep to improve performance
	workerCount:                                                                                                                                        c.int,               /// Number of workers to use with the provided task system. Box2D performs best when using only
	/// performance cores and accessing a single L2 cache. Efficiency cores and hyper-threading provide
	/// little benefit and may even harm performance.
	/// @note Box2D does not create threads. This is the number of threads your applications has created
	/// that you are allocating to b2World_Step.
	/// @warning Do not modify the default value unless you are also providing a task system and providing
	/// task callbacks (enqueueTask and finishTask).
	enqueueTask:                                                                                                                                        EnqueueTaskCallback, /// Function to spawn tasks
	finishTask:                                                                                                                                         FinishTaskCallback,  /// Function to finish a task
	userTaskContext, userData:                                                                                                                          rawptr,              /// User context that is provided to enqueueTask and finishTask
	internalValue:                                                                                                                                      c.int,               /// Used internally to detect a valid definition. DO NOT SET.
}

/// The body simulation type.
/// Each body is one of these three types. The type determines how the body behaves in the simulation.
/// @ingroup body
BodyType :: enum c.int {
	staticBody    = 0, /// zero mass, zero velocity, may be manually moved
	kinematicBody = 1, /// zero mass, velocity set by user, moved by solver
	dynamicBody   = 2, /// positive mass, velocity determined by forces, moved by solver
	bodyTypeCount = 3, /// number of body types
}

/// A body definition holds all the data needed to construct a rigid body.
/// You can safely re-use body definitions. Shapes are added to a body after construction.
/// Body definitions are temporary objects used to bundle creation parameters.
/// Must be initialized using b2DefaultBodyDef().
/// @ingroup body
BodyDef :: struct {
	type:                                                                         BodyType, /// The body type: static, kinematic, or dynamic.
	position:                                                                     Vec2,     /// The initial world position of the body. Bodies should be created with the desired position.
	/// @note Creating bodies at the origin and then moving them nearly doubles the cost of body creation, especially
	/// if the body is moved after shapes have been added.
	rotation:                                                                     Rot,      /// The initial world rotation of the body. Use b2MakeRot() if you have an angle.
	linearVelocity:                                                               Vec2,     /// The initial linear velocity of the body's origin. Usually in meters per second.
	angularVelocity, linearDamping, angularDamping, gravityScale, sleepThreshold: f32,      /// The initial angular velocity of the body. Radians per second.
	name:                                                                         cstring,  /// Optional body name for debugging. Up to 31 characters (excluding null termination)
	userData:                                                                     rawptr,   /// Use this to store application specific body data.
	enableSleep, isAwake, fixedRotation, isBullet, isEnabled, allowFastRotation:  bool,     /// Set this flag to false if this body should never fall asleep.
	internalValue:                                                                c.int,    /// Used internally to detect a valid definition. DO NOT SET.
}

/// This is used to filter collision on shapes. It affects shape-vs-shape collision
/// and shape-versus-query collision (such as b2World_CastRay).
/// @ingroup shape
Filter :: struct {
	categoryBits, maskBits: u64,   /// The collision category bits. Normally you would just set one bit. The category bits should
	/// represent your application object types. For example:
	/// @code{.cpp}
	/// enum MyCategories
	/// {
	///    Static  = 0x00000001,
	///    Dynamic = 0x00000002,
	///    Debris  = 0x00000004,
	///    Player  = 0x00000008,
	///    // etc
	/// };
	/// @endcode
	groupIndex:             c.int, /// Collision groups allow a certain group of objects to never collide (negative)
	/// or always collide (positive). A group index of zero has no effect. Non-zero group filtering
	/// always wins against the mask bits.
	/// For example, you may want ragdolls to collide with other ragdolls but you don't want
	/// ragdoll self-collision. In this case you would give each ragdoll a unique negative group index
	/// and apply that group index to all shapes on the ragdoll.
}

/// The query filter is used to filter collisions between queries and shapes. For example,
/// you may want a ray-cast representing a projectile to hit players and the static environment
/// but not debris.
/// @ingroup shape
QueryFilter :: struct {
	categoryBits, maskBits: u64, /// The collision category bits of this query. Normally you would just set one bit.
}

/// Shape type
/// @ingroup shape
ShapeType :: enum c.int {
	circleShape       = 0, /// A circle with an offset
	capsuleShape      = 1, /// A capsule is an extruded circle
	segmentShape      = 2, /// A line segment
	polygonShape      = 3, /// A convex polygon
	chainSegmentShape = 4, /// A line segment owned by a chain shape
	shapeTypeCount    = 5, /// The number of shape types
}

/// Used to create a shape.
/// This is a temporary object used to bundle shape creation parameters. You may use
/// the same shape definition to create multiple shapes.
/// Must be initialized using b2DefaultShapeDef().
/// @ingroup shape
ShapeDef :: struct {
	userData:                                                                                                    rawptr, /// Use this to store application specific shape data.
	friction, restitution, rollingResistance, tangentSpeed:                                                      f32,    /// The Coulomb (dry) friction coefficient, usually in the range [0,1].
	material:                                                                                                    c.int,  /// User material identifier. This is passed with query results and to friction and restitution
	/// combining functions. It is not used internally.
	density:                                                                                                     f32,    /// The density, usually in kg/m^2.
	filter:                                                                                                      Filter, /// Collision filtering data.
	customColor:                                                                                                 u32,    /// Custom debug draw color.
	isSensor, enableContactEvents, enableHitEvents, enablePreSolveEvents, invokeContactCreation, updateBodyMass: bool,   /// A sensor shape generates overlap events but never generates a collision response.
	/// Sensors do not collide with other sensors and do not have continuous collision.
	/// Instead, use a ray or shape cast for those scenarios.
	internalValue:                                                                                               c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// Surface materials allow chain shapes to have per segment surface properties.
/// @ingroup shape
SurfaceMaterial :: struct {
	friction, restitution, rollingResistance, tangentSpeed: f32,   /// The Coulomb (dry) friction coefficient, usually in the range [0,1].
	material:                                               c.int, /// User material identifier. This is passed with query results and to friction and restitution
	/// combining functions. It is not used internally.
	customColor:                                            u32,   /// Custom debug draw color.
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
	userData:      rawptr,             /// Use this to store application specific shape data.
	points:        [^]Vec2,            /// An array of at least 4 points. These are cloned and may be temporary.
	count:         c.int,              /// The point count, must be 4 or more.
	materials:     [^]SurfaceMaterial, /// Surface materials for each segment. These are cloned.
	materialCount: c.int,              /// The material count. Must be 1 or count. This allows you to provide one
	/// material for all segments or a unique material per segment.
	filter:        Filter,             /// Contact filtering data.
	isLoop:        bool,               /// Indicates a closed chain formed by connecting the first and last points
	internalValue: c.int,              /// Used internally to detect a valid definition. DO NOT SET.
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
	bodyCount:        c.int,
	shapeCount:       c.int,
	contactCount:     c.int,
	jointCount:       c.int,
	islandCount:      c.int,
	stackUsed:        c.int,
	staticTreeHeight: c.int,
	treeHeight:       c.int,
	byteCount:        c.int,
	taskCount:        c.int,
	colorCounts:      [12]c.int,
}

/// Joint type enumeration
///
/// This is useful because all joint types use b2JointId and sometimes you
/// want to get the type of a joint.
/// @ingroup joint
JointType :: enum c.int {
	distanceJoint  = 0,
	motorJoint     = 1,
	mouseJoint     = 2,
	nullJoint      = 3,
	prismaticJoint = 4,
	revoluteJoint  = 5,
	weldJoint      = 6,
	wheelJoint     = 7,
}

/// Distance joint definition
///
/// This requires defining an anchor point on both
/// bodies and the non-zero distance of the distance joint. The definition uses
/// local anchor points so that the initial configuration can violate the
/// constraint slightly. This helps when saving and loading a game.
/// @ingroup distance_joint
DistanceJointDef :: struct {
	bodyIdA, bodyIdB:           BodyId, /// The first attached body
	localAnchorA, localAnchorB: Vec2,   /// The local anchor point relative to bodyA's origin
	length:                     f32,    /// The rest length of this joint. Clamped to a stable minimum value.
	enableSpring:               bool,   /// Enable the distance constraint to behave like a spring. If false
	/// then the distance joint will be rigid, overriding the limit and motor.
	hertz, dampingRatio:        f32,    /// The spring linear stiffness Hertz, cycles per second
	enableLimit:                bool,   /// Enable/disable the joint limit
	minLength, maxLength:       f32,    /// Minimum length. Clamped to a stable minimum value.
	enableMotor:                bool,   /// Enable/disable the joint motor
	maxMotorForce, motorSpeed:  f32,    /// The maximum motor force, usually in newtons
	collideConnected:           bool,   /// Set this flag to true if the attached bodies should collide
	userData:                   rawptr, /// User data pointer
	internalValue:              c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// A motor joint is used to control the relative motion between two bodies
///
/// A typical usage is to control the movement of a dynamic body with respect to the ground.
/// @ingroup motor_joint
MotorJointDef :: struct {
	bodyIdA, bodyIdB:                                     BodyId, /// The first attached body
	linearOffset:                                         Vec2,   /// Position of bodyB minus the position of bodyA, in bodyA's frame
	angularOffset, maxForce, maxTorque, correctionFactor: f32,    /// The bodyB angle minus bodyA angle in radians
	collideConnected:                                     bool,   /// Set this flag to true if the attached bodies should collide
	userData:                                             rawptr, /// User data pointer
	internalValue:                                        c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// A mouse joint is used to make a point on a body track a specified world point.
///
/// This a soft constraint and allows the constraint to stretch without
/// applying huge forces. This also applies rotation constraint heuristic to improve control.
/// @ingroup mouse_joint
MouseJointDef :: struct {
	bodyIdA, bodyIdB:              BodyId, /// The first attached body. This is assumed to be static.
	target:                        Vec2,   /// The initial target point in world space
	hertz, dampingRatio, maxForce: f32,    /// Stiffness in hertz
	collideConnected:              bool,   /// Set this flag to true if the attached bodies should collide.
	userData:                      rawptr, /// User data pointer
	internalValue:                 c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// A null joint is used to disable collision between two specific bodies.
///
/// @ingroup null_joint
NullJointDef :: struct {
	bodyIdA, bodyIdB: BodyId, /// The first attached body.
	userData:         rawptr, /// User data pointer
	internalValue:    c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// Prismatic joint definition
///
/// This requires defining a line of motion using an axis and an anchor point.
/// The definition uses local anchor points and a local axis so that the initial
/// configuration can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space.
/// @ingroup prismatic_joint
PrismaticJointDef :: struct {
	bodyIdA, bodyIdB:                       BodyId, /// The first attached body
	localAnchorA, localAnchorB, localAxisA: Vec2,   /// The local anchor point relative to bodyA's origin
	referenceAngle:                         f32,    /// The constrained angle between the bodies: bodyB_angle - bodyA_angle
	enableSpring:                           bool,   /// Enable a linear spring along the prismatic joint axis
	hertz, dampingRatio:                    f32,    /// The spring stiffness Hertz, cycles per second
	enableLimit:                            bool,   /// Enable/disable the joint limit
	lowerTranslation, upperTranslation:     f32,    /// The lower translation limit
	enableMotor:                            bool,   /// Enable/disable the joint motor
	maxMotorForce, motorSpeed:              f32,    /// The maximum motor force, typically in newtons
	collideConnected:                       bool,   /// Set this flag to true if the attached bodies should collide
	userData:                               rawptr, /// User data pointer
	internalValue:                          c.int,  /// Used internally to detect a valid definition. DO NOT SET.
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
	bodyIdA, bodyIdB:                     BodyId, /// The first attached body
	localAnchorA, localAnchorB:           Vec2,   /// The local anchor point relative to bodyA's origin
	referenceAngle:                       f32,    /// The bodyB angle minus bodyA angle in the reference state (radians).
	/// This defines the zero angle for the joint limit.
	enableSpring:                         bool,   /// Enable a rotational spring on the revolute hinge axis
	hertz, dampingRatio:                  f32,    /// The spring stiffness Hertz, cycles per second
	enableLimit:                          bool,   /// A flag to enable joint limits
	lowerAngle, upperAngle:               f32,    /// The lower angle for the joint limit in radians
	enableMotor:                          bool,   /// A flag to enable the joint motor
	maxMotorTorque, motorSpeed, drawSize: f32,    /// The maximum motor torque, typically in newton-meters
	collideConnected:                     bool,   /// Set this flag to true if the attached bodies should collide
	userData:                             rawptr, /// User data pointer
	internalValue:                        c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// Weld joint definition
///
/// A weld joint connect to bodies together rigidly. This constraint provides springs to mimic
/// soft-body simulation.
/// @note The approximate solver in Box2D cannot hold many bodies together rigidly
/// @ingroup weld_joint
WeldJointDef :: struct {
	bodyIdA, bodyIdB:                                                                   BodyId, /// The first attached body
	localAnchorA, localAnchorB:                                                         Vec2,   /// The local anchor point relative to bodyA's origin
	referenceAngle, linearHertz, angularHertz, linearDampingRatio, angularDampingRatio: f32,    /// The bodyB angle minus bodyA angle in the reference state (radians)
	collideConnected:                                                                   bool,   /// Set this flag to true if the attached bodies should collide
	userData:                                                                           rawptr, /// User data pointer
	internalValue:                                                                      c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// Wheel joint definition
///
/// This requires defining a line of motion using an axis and an anchor point.
/// The definition uses local  anchor points and a local axis so that the initial
/// configuration can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space.
/// @ingroup wheel_joint
WheelJointDef :: struct {
	bodyIdA, bodyIdB:                       BodyId, /// The first attached body
	localAnchorA, localAnchorB, localAxisA: Vec2,   /// The local anchor point relative to bodyA's origin
	enableSpring:                           bool,   /// Enable a linear spring along the local axis
	hertz, dampingRatio:                    f32,    /// Spring stiffness in Hertz
	enableLimit:                            bool,   /// Enable/disable the joint linear limit
	lowerTranslation, upperTranslation:     f32,    /// The lower translation limit
	enableMotor:                            bool,   /// Enable/disable the joint rotational motor
	maxMotorTorque, motorSpeed:             f32,    /// The maximum motor torque, typically in newton-meters
	collideConnected:                       bool,   /// Set this flag to true if the attached bodies should collide
	userData:                               rawptr, /// User data pointer
	internalValue:                          c.int,  /// Used internally to detect a valid definition. DO NOT SET.
}

/// The explosion definition is used to configure options for explosions. Explosions
/// consider shape geometry when computing the impulse.
/// @ingroup world
ExplosionDef :: struct {
	maskBits:                          u64,  /// Mask bits to filter shapes
	position:                          Vec2, /// The center of the explosion in world space
	radius, falloff, impulsePerLength: f32,  /// The radius of the explosion
}

/// A begin touch event is generated when a shape starts to overlap a sensor shape.
SensorBeginTouchEvent :: struct {
	sensorShapeId, visitorShapeId: ShapeId, /// The id of the sensor shape
}

/// An end touch event is generated when a shape stops overlapping a sensor shape.
///	These include things like setting the transform, destroying a body or shape, or changing
///	a filter. You will also get an end event if the sensor or visitor are destroyed.
///	Therefore you should always confirm the shape id is valid using b2Shape_IsValid.
SensorEndTouchEvent :: struct {
	sensorShapeId, visitorShapeId: ShapeId, /// The id of the sensor shape
	///	@warning this shape may have been destroyed
	///	@see b2Shape_IsValid
}

/// Sensor events are buffered in the Box2D world and are available
/// as begin/end overlap event arrays after the time step is complete.
/// Note: these may become invalid if bodies and/or shapes are destroyed
SensorEvents :: struct {
	beginEvents:          ^SensorBeginTouchEvent, /// Array of sensor begin touch events
	endEvents:            ^SensorEndTouchEvent,   /// Array of sensor end touch events
	beginCount, endCount: c.int,                  /// The number of begin touch events
}

/// A begin touch event is generated when two shapes begin touching.
ContactBeginTouchEvent :: struct {
	shapeIdA, shapeIdB: ShapeId,  /// Id of the first shape
	manifold:           Manifold, /// The initial contact manifold. This is recorded before the solver is called,
	/// so all the impulses will be zero.
}

/// An end touch event is generated when two shapes stop touching.
///	You will get an end event if you do anything that destroys contacts previous to the last
///	world step. These include things like setting the transform, destroying a body
///	or shape, or changing a filter or body type.
ContactEndTouchEvent :: struct {
	shapeIdA, shapeIdB: ShapeId, /// Id of the first shape
	///	@warning this shape may have been destroyed
	///	@see b2Shape_IsValid
}

/// A hit touch event is generated when two shapes collide with a speed faster than the hit speed threshold.
ContactHitEvent :: struct {
	shapeIdA, shapeIdB: ShapeId, /// Id of the first shape
	point, normal:      Vec2,    /// Point where the shapes hit
	approachSpeed:      f32,     /// The speed the shapes are approaching. Always positive. Typically in meters per second.
}

/// Contact events are buffered in the Box2D world and are available
/// as event arrays after the time step is complete.
/// Note: these may become invalid if bodies and/or shapes are destroyed
ContactEvents :: struct {
	beginEvents:                    ^ContactBeginTouchEvent, /// Array of begin touch events
	endEvents:                      ^ContactEndTouchEvent,   /// Array of end touch events
	hitEvents:                      ^ContactHitEvent,        /// Array of hit events
	beginCount, endCount, hitCount: c.int,                   /// Number of begin touch events
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
	moveEvents: ^BodyMoveEvent, /// Array of move events
	moveCount:  c.int,          /// Number of move events
}

/// The contact data for two shapes. By convention the manifold normal points
/// from shape A to shape B.
/// @see b2Shape_GetContactData() and b2Body_GetContactData()
ContactData :: struct {
	shapeIdA: ShapeId,
	shapeIdB: ShapeId,
	manifold: Manifold,
}

/// Prototype for a contact filter callback.
/// This is called when a contact pair is considered for collision. This allows you to
/// perform custom logic to prevent collision between shapes. This is only called if
/// one of the two shapes has custom filtering enabled.
/// Notes:
/// - this function must be thread-safe
/// - this is only called if one of the two shapes has enabled custom filtering
/// - this is called only for awake dynamic bodies
/// Return false if you want to disable the collision
/// @see b2ShapeDef
/// @warning Do not attempt to modify the world inside this callback
/// @ingroup world
CustomFilterFcn :: proc "c" (ShapeId, ShapeId, rawptr) -> bool

/// Prototype for a pre-solve callback.
/// This is called after a contact is updated. This allows you to inspect a
/// contact before it goes to the solver. If you are careful, you can modify the
/// contact manifold (e.g. modify the normal).
/// Notes:
/// - this function must be thread-safe
/// - this is only called if the shape has enabled pre-solve events
/// - this is called only for awake dynamic bodies
/// - this is not called for sensors
/// - the supplied manifold has impulse values from the previous step
/// Return false if you want to disable the contact this step
/// @warning Do not attempt to modify the world inside this callback
/// @ingroup world
PreSolveFcn :: proc "c" (ShapeId, ShapeId, ^Manifold, rawptr) -> bool

/// Prototype callback for overlap queries.
/// Called for each shape found in the query.
/// @see b2World_OverlapABB
/// @return false to terminate the query.
/// @ingroup world
OverlapResultFcn :: proc "c" (ShapeId, rawptr) -> bool

/// Prototype callback for ray casts.
/// Called for each shape found in the query. You control how the ray cast
/// proceeds by returning a float:
/// return -1: ignore this shape and continue
/// return 0: terminate the ray cast
/// return fraction: clip the ray to this point
/// return 1: don't clip the ray and continue
/// @param shapeId the shape hit by the ray
/// @param point the point of initial intersection
/// @param normal the normal vector at the point of intersection
/// @param fraction the fraction along the ray at the point of intersection
/// @param context the user context
/// @return -1 to filter, 0 to terminate, fraction to clip the ray for closest hit, 1 to continue
/// @see b2World_CastRay
/// @ingroup world
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
	DrawPolygon:                                                                                                                                                                                 proc "c" (^Vec2, c.int, HexColor, rawptr),                 /// Draw a closed polygon provided in CCW order.
	DrawSolidPolygon:                                                                                                                                                                            proc "c" (Transform, ^Vec2, c.int, f32, HexColor, rawptr), /// Draw a solid closed polygon provided in CCW order.
	DrawCircle:                                                                                                                                                                                  proc "c" (Vec2, f32, HexColor, rawptr),                    /// Draw a circle.
	DrawSolidCircle:                                                                                                                                                                             proc "c" (Transform, f32, HexColor, rawptr),               /// Draw a solid circle.
	DrawSolidCapsule:                                                                                                                                                                            proc "c" (Vec2, Vec2, f32, HexColor, rawptr),              /// Draw a solid capsule.
	DrawSegment:                                                                                                                                                                                 proc "c" (Vec2, Vec2, HexColor, rawptr),                   /// Draw a line segment.
	DrawTransform:                                                                                                                                                                               proc "c" (Transform, rawptr),                              /// Draw a transform. Choose your own length scale.
	DrawPoint:                                                                                                                                                                                   proc "c" (Vec2, f32, HexColor, rawptr),                    /// Draw a point.
	DrawString:                                                                                                                                                                                  proc "c" (Vec2, cstring, HexColor, rawptr),                /// Draw a string in world space
	drawingBounds:                                                                                                                                                                               AABB,                                                      /// Bounds to use if restricting drawing to a rectangular region
	useDrawingBounds, drawShapes, drawJoints, drawJointExtras, drawAABBs, drawMass, drawBodyNames, drawContacts, drawGraphColors, drawContactNormals, drawContactImpulses, drawFrictionImpulses: bool,                                                      /// Option to restrict drawing to a rectangular region. May suffer from unstable depth sorting.
	_context:                                                                                                                                                                                    rawptr,                                                    /// User context that is passed as an argument to drawing callback functions
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
