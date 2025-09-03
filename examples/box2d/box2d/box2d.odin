// SPDX-FileCopyrightText: 2023 Erin Catto
// SPDX-License-Identifier: MIT
package box2d



foreign import lib "box2d.lib"

@(default_calling_convention="c", link_prefix="b2")
foreign lib {
	/// Create a world for rigid body simulation. A world contains bodies, shapes, and constraints. You make create
	/// up to 128 worlds. Each world is completely independent and may be simulated in parallel.
	/// @return the world id.
	CreateWorld :: proc(#by_ptr def: WorldDef) -> WorldId ---

	/// Destroy a world
	DestroyWorld :: proc(worldId: WorldId) ---

	/// World id validation. Provides validation for up to 64K allocations.
	World_IsValid :: proc(id: WorldId) -> bool ---

	/// Simulate a world for one time step. This performs collision detection, integration, and constraint solution.
	/// @param worldId The world to simulate
	/// @param timeStep The amount of time to simulate, this should be a fixed number. Usually 1/60.
	/// @param subStepCount The number of sub-steps, increasing the sub-step count can increase accuracy. Usually 4.
	World_Step :: proc(worldId: WorldId, timeStep: f32, subStepCount: i32) ---

	/// Call this to draw shapes and other debug draw data
	World_Draw :: proc(worldId: WorldId, draw: ^DebugDraw) ---

	/// Get the body events for the current time step. The event data is transient. Do not store a reference to this data.
	World_GetBodyEvents :: proc(worldId: WorldId) -> BodyEvents ---

	/// Get sensor events for the current time step. The event data is transient. Do not store a reference to this data.
	World_GetSensorEvents :: proc(worldId: WorldId) -> SensorEvents ---

	/// Get contact events for this current time step. The event data is transient. Do not store a reference to this data.
	World_GetContactEvents :: proc(worldId: WorldId) -> ContactEvents ---

	/// Overlap test for all shapes that *potentially* overlap the provided AABB
	World_OverlapAABB :: proc(worldId: WorldId, aabb: AABB, filter: QueryFilter, fcn: ^OverlapResultFcn, _context: rawptr) -> TreeStats ---

	/// Overlap test for for all shapes that overlap the provided point.
	World_OverlapPoint :: proc(worldId: WorldId, point: Vec2, transform: Transform, filter: QueryFilter, fcn: ^OverlapResultFcn, _context: rawptr) -> TreeStats ---

	/// Overlap test for for all shapes that overlap the provided circle. A zero radius may be used for a point query.
	World_OverlapCircle :: proc(worldId: WorldId, circle: ^Circle, transform: Transform, filter: QueryFilter, fcn: ^OverlapResultFcn, _context: rawptr) -> TreeStats ---

	/// Overlap test for all shapes that overlap the provided capsule
	World_OverlapCapsule :: proc(worldId: WorldId, capsule: ^Capsule, transform: Transform, filter: QueryFilter, fcn: ^OverlapResultFcn, _context: rawptr) -> TreeStats ---

	/// Overlap test for all shapes that overlap the provided polygon
	World_OverlapPolygon :: proc(worldId: WorldId, polygon: ^Polygon, transform: Transform, filter: QueryFilter, fcn: ^OverlapResultFcn, _context: rawptr) -> TreeStats ---

	/// Cast a ray into the world to collect shapes in the path of the ray.
	/// Your callback function controls whether you get the closest point, any point, or n-points.
	/// The ray-cast ignores shapes that contain the starting point.
	/// @note The callback function may receive shapes in any order
	/// @param worldId The world to cast the ray against
	/// @param origin The start point of the ray
	/// @param translation The translation of the ray from the start point to the end point
	/// @param filter Contains bit flags to filter unwanted shapes from the results
	/// @param fcn A user implemented callback function
	/// @param context A user context that is passed along to the callback function
	///	@return traversal performance counters
	World_CastRay :: proc(worldId: WorldId, origin: Vec2, translation: Vec2, filter: QueryFilter, fcn: ^CastResultFcn, _context: rawptr) -> TreeStats ---

	/// Cast a ray into the world to collect the closest hit. This is a convenience function.
	/// This is less general than b2World_CastRay() and does not allow for custom filtering.
	World_CastRayClosest :: proc(worldId: WorldId, origin: Vec2, translation: Vec2, filter: QueryFilter) -> RayResult ---

	/// Cast a circle through the world. Similar to a cast ray except that a circle is cast instead of a point.
	///	@see b2World_CastRay
	World_CastCircle :: proc(worldId: WorldId, circle: ^Circle, originTransform: Transform, translation: Vec2, filter: QueryFilter, fcn: ^CastResultFcn, _context: rawptr) -> TreeStats ---

	/// Cast a capsule through the world. Similar to a cast ray except that a capsule is cast instead of a point.
	///	@see b2World_CastRay
	World_CastCapsule :: proc(worldId: WorldId, capsule: ^Capsule, originTransform: Transform, translation: Vec2, filter: QueryFilter, fcn: ^CastResultFcn, _context: rawptr) -> TreeStats ---

	/// Cast a polygon through the world. Similar to a cast ray except that a polygon is cast instead of a point.
	///	@see b2World_CastRay
	World_CastPolygon :: proc(worldId: WorldId, polygon: ^Polygon, originTransform: Transform, translation: Vec2, filter: QueryFilter, fcn: ^CastResultFcn, _context: rawptr) -> TreeStats ---

	/// Enable/disable sleep. If your application does not need sleeping, you can gain some performance
	/// by disabling sleep completely at the world level.
	/// @see b2WorldDef
	World_EnableSleeping :: proc(worldId: WorldId, flag: bool) ---

	/// Is body sleeping enabled?
	World_IsSleepingEnabled :: proc(worldId: WorldId) -> bool ---

	/// Enable/disable continuous collision between dynamic and static bodies. Generally you should keep continuous
	/// collision enabled to prevent fast moving objects from going through static objects. The performance gain from
	/// disabling continuous collision is minor.
	/// @see b2WorldDef
	World_EnableContinuous :: proc(worldId: WorldId, flag: bool) ---

	/// Is continuous collision enabled?
	World_IsContinuousEnabled :: proc(worldId: WorldId) -> bool ---

	/// Adjust the restitution threshold. It is recommended not to make this value very small
	/// because it will prevent bodies from sleeping. Usually in meters per second.
	/// @see b2WorldDef
	World_SetRestitutionThreshold :: proc(worldId: WorldId, value: f32) ---

	/// Get the the restitution speed threshold. Usually in meters per second.
	World_GetRestitutionThreshold :: proc(worldId: WorldId) -> f32 ---

	/// Adjust the hit event threshold. This controls the collision speed needed to generate a b2ContactHitEvent.
	/// Usually in meters per second.
	/// @see b2WorldDef::hitEventThreshold
	World_SetHitEventThreshold :: proc(worldId: WorldId, value: f32) ---

	/// Get the the hit event speed threshold. Usually in meters per second.
	World_GetHitEventThreshold :: proc(worldId: WorldId) -> f32 ---

	/// Register the custom filter callback. This is optional.
	World_SetCustomFilterCallback :: proc(worldId: WorldId, fcn: ^CustomFilterFcn, _context: rawptr) ---

	/// Register the pre-solve callback. This is optional.
	World_SetPreSolveCallback :: proc(worldId: WorldId, fcn: ^PreSolveFcn, _context: rawptr) ---

	/// Set the gravity vector for the entire world. Box2D has no concept of an up direction and this
	/// is left as a decision for the application. Usually in m/s^2.
	/// @see b2WorldDef
	World_SetGravity :: proc(worldId: WorldId, gravity: Vec2) ---

	/// Get the gravity vector
	World_GetGravity :: proc(worldId: WorldId) -> Vec2 ---

	/// Apply a radial explosion
	/// @param worldId The world id
	/// @param explosionDef The explosion definition
	World_Explode :: proc(worldId: WorldId, explosionDef: ^ExplosionDef) ---

	/// Adjust contact tuning parameters
	/// @param worldId The world id
	/// @param hertz The contact stiffness (cycles per second)
	/// @param dampingRatio The contact bounciness with 1 being critical damping (non-dimensional)
	/// @param pushSpeed The maximum contact constraint push out speed (meters per second)
	/// @note Advanced feature
	World_SetContactTuning :: proc(worldId: WorldId, hertz: f32, dampingRatio: f32, pushSpeed: f32) ---

	/// Adjust joint tuning parameters
	/// @param worldId The world id
	/// @param hertz The contact stiffness (cycles per second)
	/// @param dampingRatio The contact bounciness with 1 being critical damping (non-dimensional)
	/// @note Advanced feature
	World_SetJointTuning :: proc(worldId: WorldId, hertz: f32, dampingRatio: f32) ---

	/// Set the maximum linear speed. Usually in m/s.
	World_SetMaximumLinearSpeed :: proc(worldId: WorldId, maximumLinearSpeed: f32) ---

	/// Get the maximum linear speed. Usually in m/s.
	World_GetMaximumLinearSpeed :: proc(worldId: WorldId) -> f32 ---

	/// Enable/disable constraint warm starting. Advanced feature for testing. Disabling
	/// sleeping greatly reduces stability and provides no performance gain.
	World_EnableWarmStarting :: proc(worldId: WorldId, flag: bool) ---

	/// Is constraint warm starting enabled?
	World_IsWarmStartingEnabled :: proc(worldId: WorldId) -> bool ---

	/// Get the number of awake bodies.
	World_GetAwakeBodyCount :: proc(worldId: WorldId) -> i32 ---

	/// Get the current world performance profile
	World_GetProfile :: proc(worldId: WorldId) -> Profile ---

	/// Get world counters and sizes
	World_GetCounters :: proc(worldId: WorldId) -> Counters ---

	/// Set the user data pointer.
	World_SetUserData :: proc(worldId: WorldId, userData: rawptr) ---

	/// Get the user data pointer.
	World_GetUserData :: proc(worldId: WorldId) -> rawptr ---

	/// Set the friction callback. Passing NULL resets to default.
	World_SetFrictionCallback :: proc(worldId: WorldId, callback: ^FrictionCallback) ---

	/// Set the restitution callback. Passing NULL resets to default.
	World_SetRestitutionCallback :: proc(worldId: WorldId, callback: ^RestitutionCallback) ---

	/// Dump memory stats to box2d_memory.txt
	World_DumpMemoryStats :: proc(worldId: WorldId) ---

	/// This is for internal testing
	World_RebuildStaticTree :: proc(worldId: WorldId) ---

	/// This is for internal testing
	World_EnableSpeculative :: proc(worldId: WorldId, flag: bool) ---

	/// Create a rigid body given a definition. No reference to the definition is retained. So you can create the definition
	/// on the stack and pass it as a pointer.
	/// @code{.c}
	/// b2BodyDef bodyDef = b2DefaultBodyDef();
	/// b2BodyId myBodyId = b2CreateBody(myWorldId, &bodyDef);
	/// @endcode
	/// @warning This function is locked during callbacks.
	CreateBody :: proc(worldId: WorldId, #by_ptr def: BodyDef) -> BodyId ---

	/// Destroy a rigid body given an id. This destroys all shapes and joints attached to the body.
	/// Do not keep references to the associated shapes and joints.
	DestroyBody :: proc(bodyId: BodyId) ---

	/// Body identifier validation. Can be used to detect orphaned ids. Provides validation for up to 64K allocations.
	Body_IsValid :: proc(id: BodyId) -> bool ---

	/// Get the body type: static, kinematic, or dynamic
	Body_GetType :: proc(bodyId: BodyId) -> BodyType ---

	/// Change the body type. This is an expensive operation. This automatically updates the mass
	/// properties regardless of the automatic mass setting.
	Body_SetType :: proc(bodyId: BodyId, type: BodyType) ---

	/// Set the body name. Up to 31 characters excluding 0 termination.
	Body_SetName :: proc(bodyId: BodyId, name: cstring) ---

	/// Get the body name. May be null.
	Body_GetName :: proc(bodyId: BodyId) -> cstring ---

	/// Set the user data for a body
	Body_SetUserData :: proc(bodyId: BodyId, userData: rawptr) ---

	/// Get the user data stored in a body
	Body_GetUserData :: proc(bodyId: BodyId) -> rawptr ---

	/// Get the world position of a body. This is the location of the body origin.
	Body_GetPosition :: proc(bodyId: BodyId) -> Vec2 ---

	/// Get the world rotation of a body as a cosine/sine pair (complex number)
	Body_GetRotation :: proc(bodyId: BodyId) -> Rot ---

	/// Get the world transform of a body.
	Body_GetTransform :: proc(bodyId: BodyId) -> Transform ---

	/// Set the world transform of a body. This acts as a teleport and is fairly expensive.
	/// @note Generally you should create a body with then intended transform.
	/// @see b2BodyDef::position and b2BodyDef::angle
	Body_SetTransform :: proc(bodyId: BodyId, position: Vec2, rotation: Rot) ---

	/// Get a local point on a body given a world point
	Body_GetLocalPoint :: proc(bodyId: BodyId, worldPoint: Vec2) -> Vec2 ---

	/// Get a world point on a body given a local point
	Body_GetWorldPoint :: proc(bodyId: BodyId, localPoint: Vec2) -> Vec2 ---

	/// Get a local vector on a body given a world vector
	Body_GetLocalVector :: proc(bodyId: BodyId, worldVector: Vec2) -> Vec2 ---

	/// Get a world vector on a body given a local vector
	Body_GetWorldVector :: proc(bodyId: BodyId, localVector: Vec2) -> Vec2 ---

	/// Get the linear velocity of a body's center of mass. Usually in meters per second.
	Body_GetLinearVelocity :: proc(bodyId: BodyId) -> Vec2 ---

	/// Get the angular velocity of a body in radians per second
	Body_GetAngularVelocity :: proc(bodyId: BodyId) -> f32 ---

	/// Set the linear velocity of a body. Usually in meters per second.
	Body_SetLinearVelocity :: proc(bodyId: BodyId, linearVelocity: Vec2) ---

	/// Set the angular velocity of a body in radians per second
	Body_SetAngularVelocity :: proc(bodyId: BodyId, angularVelocity: f32) ---

	/// Get the linear velocity of a local point attached to a body. Usually in meters per second.
	Body_GetLocalPointVelocity :: proc(bodyId: BodyId, localPoint: Vec2) -> Vec2 ---

	/// Get the linear velocity of a world point attached to a body. Usually in meters per second.
	Body_GetWorldPointVelocity :: proc(bodyId: BodyId, worldPoint: Vec2) -> Vec2 ---

	/// Apply a force at a world point. If the force is not applied at the center of mass,
	/// it will generate a torque and affect the angular velocity. This optionally wakes up the body.
	/// The force is ignored if the body is not awake.
	/// @param bodyId The body id
	/// @param force The world force vector, usually in newtons (N)
	/// @param point The world position of the point of application
	/// @param wake Option to wake up the body
	Body_ApplyForce :: proc(bodyId: BodyId, force: Vec2, point: Vec2, wake: bool) ---

	/// Apply a force to the center of mass. This optionally wakes up the body.
	/// The force is ignored if the body is not awake.
	/// @param bodyId The body id
	/// @param force the world force vector, usually in newtons (N).
	/// @param wake also wake up the body
	Body_ApplyForceToCenter :: proc(bodyId: BodyId, force: Vec2, wake: bool) ---

	/// Apply a torque. This affects the angular velocity without affecting the linear velocity.
	/// This optionally wakes the body. The torque is ignored if the body is not awake.
	/// @param bodyId The body id
	/// @param torque about the z-axis (out of the screen), usually in N*m.
	/// @param wake also wake up the body
	Body_ApplyTorque :: proc(bodyId: BodyId, torque: f32, wake: bool) ---

	/// Apply an impulse at a point. This immediately modifies the velocity.
	/// It also modifies the angular velocity if the point of application
	/// is not at the center of mass. This optionally wakes the body.
	/// The impulse is ignored if the body is not awake.
	/// @param bodyId The body id
	/// @param impulse the world impulse vector, usually in N*s or kg*m/s.
	/// @param point the world position of the point of application.
	/// @param wake also wake up the body
	/// @warning This should be used for one-shot impulses. If you need a steady force,
	/// use a force instead, which will work better with the sub-stepping solver.
	Body_ApplyLinearImpulse :: proc(bodyId: BodyId, impulse: Vec2, point: Vec2, wake: bool) ---

	/// Apply an impulse to the center of mass. This immediately modifies the velocity.
	/// The impulse is ignored if the body is not awake. This optionally wakes the body.
	/// @param bodyId The body id
	/// @param impulse the world impulse vector, usually in N*s or kg*m/s.
	/// @param wake also wake up the body
	/// @warning This should be used for one-shot impulses. If you need a steady force,
	/// use a force instead, which will work better with the sub-stepping solver.
	Body_ApplyLinearImpulseToCenter :: proc(bodyId: BodyId, impulse: Vec2, wake: bool) ---

	/// Apply an angular impulse. The impulse is ignored if the body is not awake.
	/// This optionally wakes the body.
	/// @param bodyId The body id
	/// @param impulse the angular impulse, usually in units of kg*m*m/s
	/// @param wake also wake up the body
	/// @warning This should be used for one-shot impulses. If you need a steady force,
	/// use a force instead, which will work better with the sub-stepping solver.
	Body_ApplyAngularImpulse :: proc(bodyId: BodyId, impulse: f32, wake: bool) ---

	/// Get the mass of the body, usually in kilograms
	Body_GetMass :: proc(bodyId: BodyId) -> f32 ---

	/// Get the rotational inertia of the body, usually in kg*m^2
	Body_GetRotationalInertia :: proc(bodyId: BodyId) -> f32 ---

	/// Get the center of mass position of the body in local space
	Body_GetLocalCenterOfMass :: proc(bodyId: BodyId) -> Vec2 ---

	/// Get the center of mass position of the body in world space
	Body_GetWorldCenterOfMass :: proc(bodyId: BodyId) -> Vec2 ---

	/// Override the body's mass properties. Normally this is computed automatically using the
	/// shape geometry and density. This information is lost if a shape is added or removed or if the
	/// body type changes.
	Body_SetMassData :: proc(bodyId: BodyId, massData: MassData) ---

	/// Get the mass data for a body
	Body_GetMassData :: proc(bodyId: BodyId) -> MassData ---

	/// This update the mass properties to the sum of the mass properties of the shapes.
	/// This normally does not need to be called unless you called SetMassData to override
	/// the mass and you later want to reset the mass.
	/// You may also use this when automatic mass computation has been disabled.
	/// You should call this regardless of body type.
	Body_ApplyMassFromShapes :: proc(bodyId: BodyId) ---

	/// Adjust the linear damping. Normally this is set in b2BodyDef before creation.
	Body_SetLinearDamping :: proc(bodyId: BodyId, linearDamping: f32) ---

	/// Get the current linear damping.
	Body_GetLinearDamping :: proc(bodyId: BodyId) -> f32 ---

	/// Adjust the angular damping. Normally this is set in b2BodyDef before creation.
	Body_SetAngularDamping :: proc(bodyId: BodyId, angularDamping: f32) ---

	/// Get the current angular damping.
	Body_GetAngularDamping :: proc(bodyId: BodyId) -> f32 ---

	/// Adjust the gravity scale. Normally this is set in b2BodyDef before creation.
	/// @see b2BodyDef::gravityScale
	Body_SetGravityScale :: proc(bodyId: BodyId, gravityScale: f32) ---

	/// Get the current gravity scale
	Body_GetGravityScale :: proc(bodyId: BodyId) -> f32 ---

	/// @return true if this body is awake
	Body_IsAwake :: proc(bodyId: BodyId) -> bool ---

	/// Wake a body from sleep. This wakes the entire island the body is touching.
	/// @warning Putting a body to sleep will put the entire island of bodies touching this body to sleep,
	/// which can be expensive and possibly unintuitive.
	Body_SetAwake :: proc(bodyId: BodyId, awake: bool) ---

	/// Enable or disable sleeping for this body. If sleeping is disabled the body will wake.
	Body_EnableSleep :: proc(bodyId: BodyId, enableSleep: bool) ---

	/// Returns true if sleeping is enabled for this body
	Body_IsSleepEnabled :: proc(bodyId: BodyId) -> bool ---

	/// Set the sleep threshold, usually in meters per second
	Body_SetSleepThreshold :: proc(bodyId: BodyId, sleepThreshold: f32) ---

	/// Get the sleep threshold, usually in meters per second.
	Body_GetSleepThreshold :: proc(bodyId: BodyId) -> f32 ---

	/// Returns true if this body is enabled
	Body_IsEnabled :: proc(bodyId: BodyId) -> bool ---

	/// Disable a body by removing it completely from the simulation. This is expensive.
	Body_Disable :: proc(bodyId: BodyId) ---

	/// Enable a body by adding it to the simulation. This is expensive.
	Body_Enable :: proc(bodyId: BodyId) ---

	/// Set this body to have fixed rotation. This causes the mass to be reset in all cases.
	Body_SetFixedRotation :: proc(bodyId: BodyId, flag: bool) ---

	/// Does this body have fixed rotation?
	Body_IsFixedRotation :: proc(bodyId: BodyId) -> bool ---

	/// Set this body to be a bullet. A bullet does continuous collision detection
	/// against dynamic bodies (but not other bullets).
	Body_SetBullet :: proc(bodyId: BodyId, flag: bool) ---

	/// Is this body a bullet?
	Body_IsBullet :: proc(bodyId: BodyId) -> bool ---

	/// Enable/disable contact events on all shapes.
	/// @see b2ShapeDef::enableContactEvents
	/// @warning changing this at runtime may cause mismatched begin/end touch events
	Body_EnableContactEvents :: proc(bodyId: BodyId, flag: bool) ---

	/// Enable/disable hit events on all shapes
	/// @see b2ShapeDef::enableHitEvents
	Body_EnableHitEvents :: proc(bodyId: BodyId, flag: bool) ---

	/// Get the world that owns this body
	Body_GetWorld :: proc(bodyId: BodyId) -> WorldId ---

	/// Get the number of shapes on this body
	Body_GetShapeCount :: proc(bodyId: BodyId) -> i32 ---

	/// Get the shape ids for all shapes on this body, up to the provided capacity.
	/// @returns the number of shape ids stored in the user array
	Body_GetShapes :: proc(bodyId: BodyId, shapeArray: ^ShapeId, capacity: i32) -> i32 ---

	/// Get the number of joints on this body
	Body_GetJointCount :: proc(bodyId: BodyId) -> i32 ---

	/// Get the joint ids for all joints on this body, up to the provided capacity
	/// @returns the number of joint ids stored in the user array
	Body_GetJoints :: proc(bodyId: BodyId, jointArray: ^JointId, capacity: i32) -> i32 ---

	/// Get the maximum capacity required for retrieving all the touching contacts on a body
	Body_GetContactCapacity :: proc(bodyId: BodyId) -> i32 ---

	/// Get the touching contact data for a body.
	/// @note Box2D uses speculative collision so some contact points may be separated.
	/// @returns the number of elements filled in the provided array
	/// @warning do not ignore the return value, it specifies the valid number of elements
	Body_GetContactData :: proc(bodyId: BodyId, contactData: ^ContactData, capacity: i32) -> i32 ---

	/// Get the current world AABB that contains all the attached shapes. Note that this may not encompass the body origin.
	/// If there are no shapes attached then the returned AABB is empty and centered on the body origin.
	Body_ComputeAABB :: proc(bodyId: BodyId) -> AABB ---

	/// Create a circle shape and attach it to a body. The shape definition and geometry are fully cloned.
	/// Contacts are not created until the next time step.
	/// @return the shape id for accessing the shape
	CreateCircleShape :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, #by_ptr circle: Circle) -> ShapeId ---

	/// Create a line segment shape and attach it to a body. The shape definition and geometry are fully cloned.
	/// Contacts are not created until the next time step.
	/// @return the shape id for accessing the shape
	CreateSegmentShape :: proc(bodyId: BodyId, def: ^ShapeDef, segment: ^Segment) -> ShapeId ---

	/// Create a capsule shape and attach it to a body. The shape definition and geometry are fully cloned.
	/// Contacts are not created until the next time step.
	/// @return the shape id for accessing the shape
	CreateCapsuleShape :: proc(bodyId: BodyId, def: ^ShapeDef, capsule: ^Capsule) -> ShapeId ---

	/// Create a polygon shape and attach it to a body. The shape definition and geometry are fully cloned.
	/// Contacts are not created until the next time step.
	/// @return the shape id for accessing the shape
	CreatePolygonShape :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, #by_ptr polygon: Polygon) -> ShapeId ---

	/// Destroy a shape. You may defer the body mass update which can improve performance if several shapes on a
	///	body are destroyed at once.
	///	@see b2Body_ApplyMassFromShapes
	DestroyShape :: proc(shapeId: ShapeId, updateBodyMass: bool) ---

	/// Shape identifier validation. Provides validation for up to 64K allocations.
	Shape_IsValid :: proc(id: ShapeId) -> bool ---

	/// Get the type of a shape
	Shape_GetType :: proc(shapeId: ShapeId) -> ShapeType ---

	/// Get the id of the body that a shape is attached to
	Shape_GetBody :: proc(shapeId: ShapeId) -> BodyId ---

	/// Get the world that owns this shape
	Shape_GetWorld :: proc(shapeId: ShapeId) -> WorldId ---

	/// Returns true If the shape is a sensor
	Shape_IsSensor :: proc(shapeId: ShapeId) -> bool ---

	/// Set the user data for a shape
	Shape_SetUserData :: proc(shapeId: ShapeId, userData: rawptr) ---

	/// Get the user data for a shape. This is useful when you get a shape id
	/// from an event or query.
	Shape_GetUserData :: proc(shapeId: ShapeId) -> rawptr ---

	/// Set the mass density of a shape, usually in kg/m^2.
	/// This will optionally update the mass properties on the parent body.
	/// @see b2ShapeDef::density, b2Body_ApplyMassFromShapes
	Shape_SetDensity :: proc(shapeId: ShapeId, density: f32, updateBodyMass: bool) ---

	/// Get the density of a shape, usually in kg/m^2
	Shape_GetDensity :: proc(shapeId: ShapeId) -> f32 ---

	/// Set the friction on a shape
	/// @see b2ShapeDef::friction
	Shape_SetFriction :: proc(shapeId: ShapeId, friction: f32) ---

	/// Get the friction of a shape
	Shape_GetFriction :: proc(shapeId: ShapeId) -> f32 ---

	/// Set the shape restitution (bounciness)
	/// @see b2ShapeDef::restitution
	Shape_SetRestitution :: proc(shapeId: ShapeId, restitution: f32) ---

	/// Get the shape restitution
	Shape_GetRestitution :: proc(shapeId: ShapeId) -> f32 ---

	/// Set the shape material identifier
	/// @see b2ShapeDef::material
	Shape_SetMaterial :: proc(shapeId: ShapeId, material: i32) ---

	/// Get the shape material identifier
	Shape_GetMaterial :: proc(shapeId: ShapeId) -> i32 ---

	/// Get the shape filter
	Shape_GetFilter :: proc(shapeId: ShapeId) -> Filter ---

	/// Set the current filter. This is almost as expensive as recreating the shape. This may cause
	/// contacts to be immediately destroyed. However contacts are not created until the next world step.
	/// Sensor overlap state is also not updated until the next world step.
	/// @see b2ShapeDef::filter
	Shape_SetFilter :: proc(shapeId: ShapeId, filter: Filter) ---

	/// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	/// @see b2ShapeDef::enableContactEvents
	/// @warning changing this at run-time may lead to lost begin/end events
	Shape_EnableContactEvents :: proc(shapeId: ShapeId, flag: bool) ---

	/// Returns true if contact events are enabled
	Shape_AreContactEventsEnabled :: proc(shapeId: ShapeId) -> bool ---

	/// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
	/// and must be carefully handled due to multithreading. Ignored for sensors.
	/// @see b2PreSolveFcn
	Shape_EnablePreSolveEvents :: proc(shapeId: ShapeId, flag: bool) ---

	/// Returns true if pre-solve events are enabled
	Shape_ArePreSolveEventsEnabled :: proc(shapeId: ShapeId) -> bool ---

	/// Enable contact hit events for this shape. Ignored for sensors.
	/// @see b2WorldDef.hitEventThreshold
	Shape_EnableHitEvents :: proc(shapeId: ShapeId, flag: bool) ---

	/// Returns true if hit events are enabled
	Shape_AreHitEventsEnabled :: proc(shapeId: ShapeId) -> bool ---

	/// Test a point for overlap with a shape
	Shape_TestPoint :: proc(shapeId: ShapeId, point: Vec2) -> bool ---

	/// Ray cast a shape directly
	Shape_RayCast :: proc(shapeId: ShapeId, input: ^RayCastInput) -> CastOutput ---

	/// Get a copy of the shape's circle. Asserts the type is correct.
	Shape_GetCircle :: proc(shapeId: ShapeId) -> Circle ---

	/// Get a copy of the shape's line segment. Asserts the type is correct.
	Shape_GetSegment :: proc(shapeId: ShapeId) -> Segment ---

	/// Get a copy of the shape's chain segment. These come from chain shapes.
	/// Asserts the type is correct.
	Shape_GetChainSegment :: proc(shapeId: ShapeId) -> ChainSegment ---

	/// Get a copy of the shape's capsule. Asserts the type is correct.
	Shape_GetCapsule :: proc(shapeId: ShapeId) -> Capsule ---

	/// Get a copy of the shape's convex polygon. Asserts the type is correct.
	Shape_GetPolygon :: proc(shapeId: ShapeId) -> Polygon ---

	/// Allows you to change a shape to be a circle or update the current circle.
	/// This does not modify the mass properties.
	/// @see b2Body_ApplyMassFromShapes
	Shape_SetCircle :: proc(shapeId: ShapeId, circle: ^Circle) ---

	/// Allows you to change a shape to be a capsule or update the current capsule.
	/// This does not modify the mass properties.
	/// @see b2Body_ApplyMassFromShapes
	Shape_SetCapsule :: proc(shapeId: ShapeId, capsule: ^Capsule) ---

	/// Allows you to change a shape to be a segment or update the current segment.
	Shape_SetSegment :: proc(shapeId: ShapeId, segment: ^Segment) ---

	/// Allows you to change a shape to be a polygon or update the current polygon.
	/// This does not modify the mass properties.
	/// @see b2Body_ApplyMassFromShapes
	Shape_SetPolygon :: proc(shapeId: ShapeId, polygon: ^Polygon) ---

	/// Get the parent chain id if the shape type is a chain segment, otherwise
	/// returns b2_nullChainId.
	Shape_GetParentChain :: proc(shapeId: ShapeId) -> ChainId ---

	/// Get the maximum capacity required for retrieving all the touching contacts on a shape
	Shape_GetContactCapacity :: proc(shapeId: ShapeId) -> i32 ---

	/// Get the touching contact data for a shape. The provided shapeId will be either shapeIdA or shapeIdB on the contact data.
	/// @note Box2D uses speculative collision so some contact points may be separated.
	/// @returns the number of elements filled in the provided array
	/// @warning do not ignore the return value, it specifies the valid number of elements
	Shape_GetContactData :: proc(shapeId: ShapeId, contactData: ^ContactData, capacity: i32) -> i32 ---

	/// Get the maximum capacity required for retrieving all the overlapped shapes on a sensor shape.
	/// This returns 0 if the provided shape is not a sensor.
	/// @param shapeId the id of a sensor shape
	/// @returns the required capacity to get all the overlaps in b2Shape_GetSensorOverlaps
	Shape_GetSensorCapacity :: proc(shapeId: ShapeId) -> i32 ---

	/// Get the overlapped shapes for a sensor shape.
	/// @param shapeId the id of a sensor shape
	/// @param overlaps a user allocated array that is filled with the overlapping shapes
	/// @param capacity the capacity of overlappedShapes
	/// @returns the number of elements filled in the provided array
	/// @warning do not ignore the return value, it specifies the valid number of elements
	/// @warning overlaps may contain destroyed shapes so use b2Shape_IsValid to confirm each overlap
	Shape_GetSensorOverlaps :: proc(shapeId: ShapeId, overlaps: ^ShapeId, capacity: i32) -> i32 ---

	/// Get the current world AABB
	Shape_GetAABB :: proc(shapeId: ShapeId) -> AABB ---

	/// Get the mass data for a shape
	Shape_GetMassData :: proc(shapeId: ShapeId) -> MassData ---

	/// Get the closest point on a shape to a target point. Target and result are in world space.
	/// todo need sample
	Shape_GetClosestPoint :: proc(shapeId: ShapeId, target: Vec2) -> Vec2 ---

	/// Create a chain shape
	/// @see b2ChainDef for details
	CreateChain :: proc(bodyId: BodyId, def: ^ChainDef) -> ChainId ---

	/// Destroy a chain shape
	DestroyChain :: proc(chainId: ChainId) ---

	/// Get the world that owns this chain shape
	Chain_GetWorld :: proc(chainId: ChainId) -> WorldId ---

	/// Get the number of segments on this chain
	Chain_GetSegmentCount :: proc(chainId: ChainId) -> i32 ---

	/// Fill a user array with chain segment shape ids up to the specified capacity. Returns
	/// the actual number of segments returned.
	Chain_GetSegments :: proc(chainId: ChainId, segmentArray: ^ShapeId, capacity: i32) -> i32 ---

	/// Set the chain friction
	/// @see b2ChainDef::friction
	Chain_SetFriction :: proc(chainId: ChainId, friction: f32) ---

	/// Get the chain friction
	Chain_GetFriction :: proc(chainId: ChainId) -> f32 ---

	/// Set the chain restitution (bounciness)
	/// @see b2ChainDef::restitution
	Chain_SetRestitution :: proc(chainId: ChainId, restitution: f32) ---

	/// Get the chain restitution
	Chain_GetRestitution :: proc(chainId: ChainId) -> f32 ---

	/// Set the chain material
	/// @see b2ChainDef::material
	Chain_SetMaterial :: proc(chainId: ChainId, material: i32) ---

	/// Get the chain material
	Chain_GetMaterial :: proc(chainId: ChainId) -> i32 ---

	/// Chain identifier validation. Provides validation for up to 64K allocations.
	Chain_IsValid :: proc(id: ChainId) -> bool ---

	/// Destroy a joint
	DestroyJoint :: proc(jointId: JointId) ---

	/// Joint identifier validation. Provides validation for up to 64K allocations.
	Joint_IsValid :: proc(id: JointId) -> bool ---

	/// Get the joint type
	Joint_GetType :: proc(jointId: JointId) -> JointType ---

	/// Get body A id on a joint
	Joint_GetBodyA :: proc(jointId: JointId) -> BodyId ---

	/// Get body B id on a joint
	Joint_GetBodyB :: proc(jointId: JointId) -> BodyId ---

	/// Get the world that owns this joint
	Joint_GetWorld :: proc(jointId: JointId) -> WorldId ---

	/// Get the local anchor on bodyA
	Joint_GetLocalAnchorA :: proc(jointId: JointId) -> Vec2 ---

	/// Get the local anchor on bodyB
	Joint_GetLocalAnchorB :: proc(jointId: JointId) -> Vec2 ---

	/// Toggle collision between connected bodies
	Joint_SetCollideConnected :: proc(jointId: JointId, shouldCollide: bool) ---

	/// Is collision allowed between connected bodies?
	Joint_GetCollideConnected :: proc(jointId: JointId) -> bool ---

	/// Set the user data on a joint
	Joint_SetUserData :: proc(jointId: JointId, userData: rawptr) ---

	/// Get the user data on a joint
	Joint_GetUserData :: proc(jointId: JointId) -> rawptr ---

	/// Wake the bodies connect to this joint
	Joint_WakeBodies :: proc(jointId: JointId) ---

	/// Get the current constraint force for this joint. Usually in Newtons.
	Joint_GetConstraintForce :: proc(jointId: JointId) -> Vec2 ---

	/// Get the current constraint torque for this joint. Usually in Newton * meters.
	Joint_GetConstraintTorque :: proc(jointId: JointId) -> f32 ---

	/// Create a distance joint
	/// @see b2DistanceJointDef for details
	CreateDistanceJoint :: proc(worldId: WorldId, def: ^DistanceJointDef) -> JointId ---

	/// Set the rest length of a distance joint
	/// @param jointId The id for a distance joint
	/// @param length The new distance joint length
	DistanceJoint_SetLength :: proc(jointId: JointId, length: f32) ---

	/// Get the rest length of a distance joint
	DistanceJoint_GetLength :: proc(jointId: JointId) -> f32 ---

	/// Enable/disable the distance joint spring. When disabled the distance joint is rigid.
	DistanceJoint_EnableSpring :: proc(jointId: JointId, enableSpring: bool) ---

	/// Is the distance joint spring enabled?
	DistanceJoint_IsSpringEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the spring stiffness in Hertz
	DistanceJoint_SetSpringHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Set the spring damping ratio, non-dimensional
	DistanceJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the spring Hertz
	DistanceJoint_GetSpringHertz :: proc(jointId: JointId) -> f32 ---

	/// Get the spring damping ratio
	DistanceJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Enable joint limit. The limit only works if the joint spring is enabled. Otherwise the joint is rigid
	/// and the limit has no effect.
	DistanceJoint_EnableLimit :: proc(jointId: JointId, enableLimit: bool) ---

	/// Is the distance joint limit enabled?
	DistanceJoint_IsLimitEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the minimum and maximum length parameters of a distance joint
	DistanceJoint_SetLengthRange :: proc(jointId: JointId, minLength: f32, maxLength: f32) ---

	/// Get the distance joint minimum length
	DistanceJoint_GetMinLength :: proc(jointId: JointId) -> f32 ---

	/// Get the distance joint maximum length
	DistanceJoint_GetMaxLength :: proc(jointId: JointId) -> f32 ---

	/// Get the current length of a distance joint
	DistanceJoint_GetCurrentLength :: proc(jointId: JointId) -> f32 ---

	/// Enable/disable the distance joint motor
	DistanceJoint_EnableMotor :: proc(jointId: JointId, enableMotor: bool) ---

	/// Is the distance joint motor enabled?
	DistanceJoint_IsMotorEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the distance joint motor speed, usually in meters per second
	DistanceJoint_SetMotorSpeed :: proc(jointId: JointId, motorSpeed: f32) ---

	/// Get the distance joint motor speed, usually in meters per second
	DistanceJoint_GetMotorSpeed :: proc(jointId: JointId) -> f32 ---

	/// Set the distance joint maximum motor force, usually in newtons
	DistanceJoint_SetMaxMotorForce :: proc(jointId: JointId, force: f32) ---

	/// Get the distance joint maximum motor force, usually in newtons
	DistanceJoint_GetMaxMotorForce :: proc(jointId: JointId) -> f32 ---

	/// Get the distance joint current motor force, usually in newtons
	DistanceJoint_GetMotorForce :: proc(jointId: JointId) -> f32 ---

	/// Create a motor joint
	/// @see b2MotorJointDef for details
	CreateMotorJoint :: proc(worldId: WorldId, def: ^MotorJointDef) -> JointId ---

	/// Set the motor joint linear offset target
	MotorJoint_SetLinearOffset :: proc(jointId: JointId, linearOffset: Vec2) ---

	/// Get the motor joint linear offset target
	MotorJoint_GetLinearOffset :: proc(jointId: JointId) -> Vec2 ---

	/// Set the motor joint angular offset target in radians
	MotorJoint_SetAngularOffset :: proc(jointId: JointId, angularOffset: f32) ---

	/// Get the motor joint angular offset target in radians
	MotorJoint_GetAngularOffset :: proc(jointId: JointId) -> f32 ---

	/// Set the motor joint maximum force, usually in newtons
	MotorJoint_SetMaxForce :: proc(jointId: JointId, maxForce: f32) ---

	/// Get the motor joint maximum force, usually in newtons
	MotorJoint_GetMaxForce :: proc(jointId: JointId) -> f32 ---

	/// Set the motor joint maximum torque, usually in newton-meters
	MotorJoint_SetMaxTorque :: proc(jointId: JointId, maxTorque: f32) ---

	/// Get the motor joint maximum torque, usually in newton-meters
	MotorJoint_GetMaxTorque :: proc(jointId: JointId) -> f32 ---

	/// Set the motor joint correction factor, usually in [0, 1]
	MotorJoint_SetCorrectionFactor :: proc(jointId: JointId, correctionFactor: f32) ---

	/// Get the motor joint correction factor, usually in [0, 1]
	MotorJoint_GetCorrectionFactor :: proc(jointId: JointId) -> f32 ---

	/// Create a mouse joint
	/// @see b2MouseJointDef for details
	CreateMouseJoint :: proc(worldId: WorldId, def: ^MouseJointDef) -> JointId ---

	/// Set the mouse joint target
	MouseJoint_SetTarget :: proc(jointId: JointId, target: Vec2) ---

	/// Get the mouse joint target
	MouseJoint_GetTarget :: proc(jointId: JointId) -> Vec2 ---

	/// Set the mouse joint spring stiffness in Hertz
	MouseJoint_SetSpringHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Get the mouse joint spring stiffness in Hertz
	MouseJoint_GetSpringHertz :: proc(jointId: JointId) -> f32 ---

	/// Set the mouse joint spring damping ratio, non-dimensional
	MouseJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the mouse joint damping ratio, non-dimensional
	MouseJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Set the mouse joint maximum force, usually in newtons
	MouseJoint_SetMaxForce :: proc(jointId: JointId, maxForce: f32) ---

	/// Get the mouse joint maximum force, usually in newtons
	MouseJoint_GetMaxForce :: proc(jointId: JointId) -> f32 ---

	/// Create a null joint.
	/// @see b2NullJointDef for details
	CreateNullJoint :: proc(worldId: WorldId, def: ^NullJointDef) -> JointId ---

	/// Create a prismatic (slider) joint.
	/// @see b2PrismaticJointDef for details
	CreatePrismaticJoint :: proc(worldId: WorldId, def: ^PrismaticJointDef) -> JointId ---

	/// Enable/disable the joint spring.
	PrismaticJoint_EnableSpring :: proc(jointId: JointId, enableSpring: bool) ---

	/// Is the prismatic joint spring enabled or not?
	PrismaticJoint_IsSpringEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the prismatic joint stiffness in Hertz.
	/// This should usually be less than a quarter of the simulation rate. For example, if the simulation
	/// runs at 60Hz then the joint stiffness should be 15Hz or less.
	PrismaticJoint_SetSpringHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Get the prismatic joint stiffness in Hertz
	PrismaticJoint_GetSpringHertz :: proc(jointId: JointId) -> f32 ---

	/// Set the prismatic joint damping ratio (non-dimensional)
	PrismaticJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the prismatic spring damping ratio (non-dimensional)
	PrismaticJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Enable/disable a prismatic joint limit
	PrismaticJoint_EnableLimit :: proc(jointId: JointId, enableLimit: bool) ---

	/// Is the prismatic joint limit enabled?
	PrismaticJoint_IsLimitEnabled :: proc(jointId: JointId) -> bool ---

	/// Get the prismatic joint lower limit
	PrismaticJoint_GetLowerLimit :: proc(jointId: JointId) -> f32 ---

	/// Get the prismatic joint upper limit
	PrismaticJoint_GetUpperLimit :: proc(jointId: JointId) -> f32 ---

	/// Set the prismatic joint limits
	PrismaticJoint_SetLimits :: proc(jointId: JointId, lower: f32, upper: f32) ---

	/// Enable/disable a prismatic joint motor
	PrismaticJoint_EnableMotor :: proc(jointId: JointId, enableMotor: bool) ---

	/// Is the prismatic joint motor enabled?
	PrismaticJoint_IsMotorEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the prismatic joint motor speed, usually in meters per second
	PrismaticJoint_SetMotorSpeed :: proc(jointId: JointId, motorSpeed: f32) ---

	/// Get the prismatic joint motor speed, usually in meters per second
	PrismaticJoint_GetMotorSpeed :: proc(jointId: JointId) -> f32 ---

	/// Set the prismatic joint maximum motor force, usually in newtons
	PrismaticJoint_SetMaxMotorForce :: proc(jointId: JointId, force: f32) ---

	/// Get the prismatic joint maximum motor force, usually in newtons
	PrismaticJoint_GetMaxMotorForce :: proc(jointId: JointId) -> f32 ---

	/// Get the prismatic joint current motor force, usually in newtons
	PrismaticJoint_GetMotorForce :: proc(jointId: JointId) -> f32 ---

	/// Get the current joint translation, usually in meters.
	PrismaticJoint_GetTranslation :: proc(jointId: JointId) -> f32 ---

	/// Get the current joint translation speed, usually in meters per second.
	PrismaticJoint_GetSpeed :: proc(jointId: JointId) -> f32 ---

	/// Create a revolute joint
	/// @see b2RevoluteJointDef for details
	CreateRevoluteJoint :: proc(worldId: WorldId, def: ^RevoluteJointDef) -> JointId ---

	/// Enable/disable the revolute joint spring
	RevoluteJoint_EnableSpring :: proc(jointId: JointId, enableSpring: bool) ---

	/// It the revolute angular spring enabled?
	RevoluteJoint_IsSpringEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the revolute joint spring stiffness in Hertz
	RevoluteJoint_SetSpringHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Get the revolute joint spring stiffness in Hertz
	RevoluteJoint_GetSpringHertz :: proc(jointId: JointId) -> f32 ---

	/// Set the revolute joint spring damping ratio, non-dimensional
	RevoluteJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the revolute joint spring damping ratio, non-dimensional
	RevoluteJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Get the revolute joint current angle in radians relative to the reference angle
	/// @see b2RevoluteJointDef::referenceAngle
	RevoluteJoint_GetAngle :: proc(jointId: JointId) -> f32 ---

	/// Enable/disable the revolute joint limit
	RevoluteJoint_EnableLimit :: proc(jointId: JointId, enableLimit: bool) ---

	/// Is the revolute joint limit enabled?
	RevoluteJoint_IsLimitEnabled :: proc(jointId: JointId) -> bool ---

	/// Get the revolute joint lower limit in radians
	RevoluteJoint_GetLowerLimit :: proc(jointId: JointId) -> f32 ---

	/// Get the revolute joint upper limit in radians
	RevoluteJoint_GetUpperLimit :: proc(jointId: JointId) -> f32 ---

	/// Set the revolute joint limits in radians
	RevoluteJoint_SetLimits :: proc(jointId: JointId, lower: f32, upper: f32) ---

	/// Enable/disable a revolute joint motor
	RevoluteJoint_EnableMotor :: proc(jointId: JointId, enableMotor: bool) ---

	/// Is the revolute joint motor enabled?
	RevoluteJoint_IsMotorEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the revolute joint motor speed in radians per second
	RevoluteJoint_SetMotorSpeed :: proc(jointId: JointId, motorSpeed: f32) ---

	/// Get the revolute joint motor speed in radians per second
	RevoluteJoint_GetMotorSpeed :: proc(jointId: JointId) -> f32 ---

	/// Get the revolute joint current motor torque, usually in newton-meters
	RevoluteJoint_GetMotorTorque :: proc(jointId: JointId) -> f32 ---

	/// Set the revolute joint maximum motor torque, usually in newton-meters
	RevoluteJoint_SetMaxMotorTorque :: proc(jointId: JointId, torque: f32) ---

	/// Get the revolute joint maximum motor torque, usually in newton-meters
	RevoluteJoint_GetMaxMotorTorque :: proc(jointId: JointId) -> f32 ---

	/// Create a weld joint
	/// @see b2WeldJointDef for details
	CreateWeldJoint :: proc(worldId: WorldId, def: ^WeldJointDef) -> JointId ---

	/// Get the weld joint reference angle in radians
	WeldJoint_GetReferenceAngle :: proc(jointId: JointId) -> f32 ---

	/// Set the weld joint reference angle in radians, must be in [-pi,pi].
	WeldJoint_SetReferenceAngle :: proc(jointId: JointId, angleInRadians: f32) ---

	/// Set the weld joint linear stiffness in Hertz. 0 is rigid.
	WeldJoint_SetLinearHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Get the weld joint linear stiffness in Hertz
	WeldJoint_GetLinearHertz :: proc(jointId: JointId) -> f32 ---

	/// Set the weld joint linear damping ratio (non-dimensional)
	WeldJoint_SetLinearDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the weld joint linear damping ratio (non-dimensional)
	WeldJoint_GetLinearDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Set the weld joint angular stiffness in Hertz. 0 is rigid.
	WeldJoint_SetAngularHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Get the weld joint angular stiffness in Hertz
	WeldJoint_GetAngularHertz :: proc(jointId: JointId) -> f32 ---

	/// Set weld joint angular damping ratio, non-dimensional
	WeldJoint_SetAngularDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the weld joint angular damping ratio, non-dimensional
	WeldJoint_GetAngularDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Create a wheel joint
	/// @see b2WheelJointDef for details
	CreateWheelJoint :: proc(worldId: WorldId, def: ^WheelJointDef) -> JointId ---

	/// Enable/disable the wheel joint spring
	WheelJoint_EnableSpring :: proc(jointId: JointId, enableSpring: bool) ---

	/// Is the wheel joint spring enabled?
	WheelJoint_IsSpringEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the wheel joint stiffness in Hertz
	WheelJoint_SetSpringHertz :: proc(jointId: JointId, hertz: f32) ---

	/// Get the wheel joint stiffness in Hertz
	WheelJoint_GetSpringHertz :: proc(jointId: JointId) -> f32 ---

	/// Set the wheel joint damping ratio, non-dimensional
	WheelJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	/// Get the wheel joint damping ratio, non-dimensional
	WheelJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	/// Enable/disable the wheel joint limit
	WheelJoint_EnableLimit :: proc(jointId: JointId, enableLimit: bool) ---

	/// Is the wheel joint limit enabled?
	WheelJoint_IsLimitEnabled :: proc(jointId: JointId) -> bool ---

	/// Get the wheel joint lower limit
	WheelJoint_GetLowerLimit :: proc(jointId: JointId) -> f32 ---

	/// Get the wheel joint upper limit
	WheelJoint_GetUpperLimit :: proc(jointId: JointId) -> f32 ---

	/// Set the wheel joint limits
	WheelJoint_SetLimits :: proc(jointId: JointId, lower: f32, upper: f32) ---

	/// Enable/disable the wheel joint motor
	WheelJoint_EnableMotor :: proc(jointId: JointId, enableMotor: bool) ---

	/// Is the wheel joint motor enabled?
	WheelJoint_IsMotorEnabled :: proc(jointId: JointId) -> bool ---

	/// Set the wheel joint motor speed in radians per second
	WheelJoint_SetMotorSpeed :: proc(jointId: JointId, motorSpeed: f32) ---

	/// Get the wheel joint motor speed in radians per second
	WheelJoint_GetMotorSpeed :: proc(jointId: JointId) -> f32 ---

	/// Set the wheel joint maximum motor torque, usually in newton-meters
	WheelJoint_SetMaxMotorTorque :: proc(jointId: JointId, torque: f32) ---

	/// Get the wheel joint maximum motor torque, usually in newton-meters
	WheelJoint_GetMaxMotorTorque :: proc(jointId: JointId) -> f32 ---

	/// Get the wheel joint current motor torque, usually in newton-meters
	WheelJoint_GetMotorTorque :: proc(jointId: JointId) -> f32 ---
}
