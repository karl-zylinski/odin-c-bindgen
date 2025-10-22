// Copyright (c) Amer Koleci and Contributors.
// Licensed under the MIT License (MIT). See LICENSE in the repository root for more information.
package jolt

when ODIN_OS == .Windows {
	foreign import lib "joltc.lib"
} else when ODIN_OS == .Darwin {
	foreign import lib "libjoltc.dylib"
} else when ODIN_OS == .Linux {
	foreign import lib "libjoltc.so"
}

DEFAULT_COLLISION_TOLERANCE   :: (1.0e-4)                 // float cDefaultCollisionTolerance = 1.0e-4f
DEFAULT_PENETRATION_TOLERANCE :: (1.0e-4)                 // float cDefaultPenetrationTolerance = 1.0e-4f
DEFAULT_CONVEX_RADIUS         :: (0.05)                   // float cDefaultConvexRadius = 0.05f
CAPSULE_PROJECTION_SLOP       :: (0.02)                   // float cCapsuleProjectionSlop = 0.02f
MAX_PHYSICS_JOBS              :: (2048)                   // int cMaxPhysicsJobs = 2048
MAX_PHYSICS_BARRIERS          :: (8)                      // int cMaxPhysicsBarriers = 8
INVALID_COLLISION_GROUP_ID    :: max(u32)
INVALID_COLLISION_SUBGROUP_ID :: max(u32)
M_PI                          :: (3.14159265358979323846) // To avoid collision with JPH_PI

Bool                            :: u32
BodyID                          :: u32
SubShapeID                      :: u32
ObjectLayer                     :: u32
BroadPhaseLayer                 :: u8
CollisionGroupID                :: u32
CollisionSubGroupID             :: u32
CharacterID                     :: u32
BroadPhaseLayerInterface        :: struct {}
ObjectVsBroadPhaseLayerFilter   :: struct {}
ObjectLayerPairFilter           :: struct {}
BroadPhaseLayerFilter           :: struct {}
ObjectLayerFilter               :: struct {}
BodyFilter                      :: struct {}
ShapeFilter                     :: struct {}
SimShapeFilter                  :: struct {}
PhysicsStepListener             :: struct {}
PhysicsSystem                   :: struct {}
PhysicsMaterial                 :: struct {}
ShapeSettings                   :: struct {}
ConvexShapeSettings             :: struct {}
SphereShapeSettings             :: struct {}
BoxShapeSettings                :: struct {}
PlaneShapeSettings              :: struct {}
TriangleShapeSettings           :: struct {}
CapsuleShapeSettings            :: struct {}
TaperedCapsuleShapeSettings     :: struct {}
CylinderShapeSettings           :: struct {}
TaperedCylinderShapeSettings    :: struct {}
ConvexHullShapeSettings         :: struct {}
CompoundShapeSettings           :: struct {}
StaticCompoundShapeSettings     :: struct {}
MutableCompoundShapeSettings    :: struct {}
MeshShapeSettings               :: struct {}
HeightFieldShapeSettings        :: struct {}
RotatedTranslatedShapeSettings  :: struct {}
ScaledShapeSettings             :: struct {}
OffsetCenterOfMassShapeSettings :: struct {}
EmptyShapeSettings              :: struct {}
Shape                           :: struct {}
ConvexShape                     :: struct {}
SphereShape                     :: struct {}
BoxShape                        :: struct {}
PlaneShape                      :: struct {}
CapsuleShape                    :: struct {}
CylinderShape                   :: struct {}
TaperedCylinderShape            :: struct {}
TriangleShape                   :: struct {}
TaperedCapsuleShape             :: struct {}
ConvexHullShape                 :: struct {}
CompoundShape                   :: struct {}
StaticCompoundShape             :: struct {}
MutableCompoundShape            :: struct {}
MeshShape                       :: struct {}
HeightFieldShape                :: struct {}
DecoratedShape                  :: struct {}
RotatedTranslatedShape          :: struct {}
ScaledShape                     :: struct {}
OffsetCenterOfMassShape         :: struct {}
EmptyShape                      :: struct {}
BodyCreationSettings            :: struct {}
SoftBodyCreationSettings        :: struct {}
BodyInterface                   :: struct {}
BodyLockInterface               :: struct {}
BroadPhaseQuery                 :: struct {}
NarrowPhaseQuery                :: struct {}
MotionProperties                :: struct {}
Body                            :: struct {}
ContactListener                 :: struct {}
ContactManifold                 :: struct {}
GroupFilter                     :: struct {}
GroupFilterTable                :: struct {} /* Inherits JPH_GroupFilter */

/* Enums */
PhysicsUpdateError :: enum i32 {
	None                   = 0,
	ManifoldCacheFull      = 1,
	BodyPairCacheFull      = 2,
	ContactConstraintsFull = 4,
}

BodyType :: enum i32 {
	Rigid = 0,
	Soft  = 1,
}

MotionType :: enum i32 {
	Static    = 0,
	Kinematic = 1,
	Dynamic   = 2,
}

Activation :: enum i32 {
	Activate     = 0,
	DontActivate = 1,
}

ValidateResult :: enum i32 {
	AcceptAllContactsForThisBodyPair = 0,
	AcceptContact                    = 1,
	RejectContact                    = 2,
	RejectAllContactsForThisBodyPair = 3,
}

ShapeType :: enum i32 {
	Convex      = 0,
	Compound    = 1,
	Decorated   = 2,
	Mesh        = 3,
	HeightField = 4,
	SoftBody    = 5,
	User1       = 6,
	User2       = 7,
	User3       = 8,
	User4       = 9,
}

ShapeSubType :: enum i32 {
	Sphere             = 0,
	Box                = 1,
	Triangle           = 2,
	Capsule            = 3,
	TaperedCapsule     = 4,
	Cylinder           = 5,
	ConvexHull         = 6,
	StaticCompound     = 7,
	MutableCompound    = 8,
	RotatedTranslated  = 9,
	Scaled             = 10,
	OffsetCenterOfMass = 11,
	Mesh               = 12,
	HeightField        = 13,
	SoftBody           = 14,
}

ConstraintType :: enum i32 {
	Constraint        = 0,
	TwoBodyConstraint = 1,
}

ConstraintSubType :: enum i32 {
	Fixed         = 0,
	Point         = 1,
	Hinge         = 2,
	Slider        = 3,
	Distance      = 4,
	Cone          = 5,
	SwingTwist    = 6,
	SixDOF        = 7,
	Path          = 8,
	Vehicle       = 9,
	RackAndPinion = 10,
	Gear          = 11,
	Pulley        = 12,
	User1         = 13,
	User2         = 14,
	User3         = 15,
	User4         = 16,
}

ConstraintSpace :: enum i32 {
	LocalToBodyCOM = 0,
	WorldSpace     = 1,
}

MotionQuality :: enum i32 {
	Discrete   = 0,
	LinearCast = 1,
}

OverrideMassProperties :: enum i32 {
	CalculateMassAndInertia = 0,
	CalculateInertia        = 1,
	MassAndInertiaProvided  = 2,
}

AllowedDOFs :: enum i32 {
	All          = 63,
	TranslationX = 1,
	TranslationY = 2,
	TranslationZ = 4,
	RotationX    = 8,
	RotationY    = 16,
	RotationZ    = 32,
	Plane2D      = 35,
}

GroundState :: enum i32 {
	OnGround      = 0,
	OnSteepGround = 1,
	NotSupported  = 2,
	InAir         = 3,
}

BackFaceMode :: enum i32 {
	IgnoreBackFaces      = 0,
	CollideWithBackFaces = 1,
}

ActiveEdgeMode :: enum i32 {
	CollideOnlyWithActive = 0,
	CollideWithAll        = 1,
}

CollectFacesMode :: enum i32 {
	CollectFaces = 0,
	NoFaces      = 1,
}

MotorState :: enum i32 {
	Off      = 0,
	Velocity = 1,
	Position = 2,
}

CollisionCollectorType :: enum i32 {
	AllHit       = 0,
	AllHitSorted = 1,
	ClosestHit   = 2,
	AnyHit       = 3,
}

SwingType :: enum i32 {
	Cone    = 0,
	Pyramid = 1,
}

SixDOFConstraintAxis :: enum i32 {
	TranslationX = 0,
	TranslationY = 1,
	TranslationZ = 2,
	RotationX    = 3,
	RotationY    = 4,
	RotationZ    = 5,
}

SpringMode :: enum i32 {
	FrequencyAndDamping = 0,
	StiffnessAndDamping = 1,
}

/// Defines how to color soft body constraints
SoftBodyConstraintColor :: enum i32 {
	ConstraintType  = 0, /// Draw different types of constraints in different colors
	ConstraintGroup = 1, /// Draw constraints in the same group in the same color, non-parallel group will be red
	ConstraintOrder = 2, /// Draw constraints in the same group in the same color, non-parallel group will be red, and order within each group will be indicated with gradient
}

BodyManager_ShapeColor :: enum i32 {
	InstanceColor   = 0, ///< Random color per instance
	ShapeTypeColor  = 1, ///< Convex = green, scaled = yellow, compound = orange, mesh = red
	MotionTypeColor = 2, ///< Static = grey, keyframed = green, dynamic = random color per instance
	SleepColor      = 3, ///< Static = grey, keyframed = green, dynamic = yellow, sleeping = red
	IslandColor     = 4, ///< Static = grey, active = random color per island, sleeping = light grey
	MaterialColor   = 5, ///< Color as defined by the PhysicsMaterial of the shape
}

DebugRenderer_CastShadow :: enum i32 {
	On  = 0, ///< This shape should cast a shadow
	Off = 1, ///< This shape should not cast a shadow
}

DebugRenderer_DrawMode :: enum i32 {
	Solid     = 0, ///< Draw as a solid shape
	Wireframe = 1, ///< Draw as wireframe
}

Mesh_Shape_BuildQuality :: enum i32 {
	FavorRuntimePerformance = 0,
	FavorBuildSpeed         = 1,
}

TransmissionMode :: enum i32 {
	Auto   = 0,
	Manual = 1,
}

Vec3 :: [3]f32
Vec4 :: [4]f32
Quat :: quaternion128

Plane :: struct {
	normal:   Vec3,
	distance: f32,
}

Mat4  :: matrix[4,4]f32
RVec3 :: Vec3
RMat4 :: Mat4
Color :: u32

AABox :: struct {
	min: Vec3,
	max: Vec3,
}

Triangle :: struct {
	v1:            Vec3,
	v2:            Vec3,
	v3:            Vec3,
	materialIndex: u32,
}

IndexedTriangleNoMaterial :: struct {
	i1: u32,
	i2: u32,
	i3: u32,
}

IndexedTriangle :: struct {
	i1:            u32,
	i2:            u32,
	i3:            u32,
	materialIndex: u32,
	userData:      u32,
}

MassProperties :: struct {
	mass:    f32,
	inertia: Mat4,
}

ContactSettings :: struct {
	combinedFriction:               f32,
	combinedRestitution:            f32,
	invMassScale1:                  f32,
	invInertiaScale1:               f32,
	invMassScale2:                  f32,
	invInertiaScale2:               f32,
	isSensor:                       Bool,
	relativeLinearSurfaceVelocity:  Vec3,
	relativeAngularSurfaceVelocity: Vec3,
}

CollideSettingsBase :: struct {
	/// How active edges (edges that a moving object should bump into) are handled
	activeEdgeMode: ActiveEdgeMode, /* = JPH_ActiveEdgeMode_CollideOnlyWithActive*/

	/// If colliding faces should be collected or only the collision point
	collectFacesMode: CollectFacesMode, /* = JPH_CollectFacesMode_NoFaces*/

	/// If objects are closer than this distance, they are considered to be colliding (used for GJK) (unit: meter)
	collisionTolerance: f32, /* = JPH_DEFAULT_COLLISION_TOLERANCE*/

	/// A factor that determines the accuracy of the penetration depth calculation. If the change of the squared distance is less than tolerance * current_penetration_depth^2 the algorithm will terminate. (unit: dimensionless)
	penetrationTolerance: f32, /* = JPH_DEFAULT_PENETRATION_TOLERANCE*/

	/// When mActiveEdgeMode is CollideOnlyWithActive a movement direction can be provided. When hitting an inactive edge, the system will select the triangle normal as penetration depth only if it impedes the movement less than with the calculated penetration depth.
	activeEdgeMovementDirection: Vec3, /* = Vec3::sZero()*/
}

/* CollideShapeSettings */
CollideShapeSettings :: struct {
	base: CollideSettingsBase, /* Inherits JPH_CollideSettingsBase */

	/// When > 0 contacts in the vicinity of the query shape can be found. All nearest contacts that are not further away than this distance will be found (unit: meter)
	maxSeparationDistance: f32, /* = 0.0f*/

	/// How backfacing triangles should be treated
	backFaceMode: BackFaceMode, /* = JPH_BackFaceMode_IgnoreBackFaces*/
}

/* ShapeCastSettings */
ShapeCastSettings :: struct {
	base: CollideSettingsBase, /* Inherits JPH_CollideSettingsBase */

	/// How backfacing triangles should be treated (should we report moving from back to front for triangle based shapes, e.g. for MeshShape/HeightFieldShape?)
	backFaceModeTriangles: BackFaceMode, /* = JPH_BackFaceMode_IgnoreBackFaces*/

	/// How backfacing convex objects should be treated (should we report starting inside an object and moving out?)
	backFaceModeConvex: BackFaceMode, /* = JPH_BackFaceMode_IgnoreBackFaces*/

	/// Indicates if we want to shrink the shape by the convex radius and then expand it again. This speeds up collision detection and gives a more accurate normal at the cost of a more 'rounded' shape.
	useShrunkenShapeAndConvexRadius: bool, /* = false*/

	/// When true, and the shape is intersecting at the beginning of the cast (fraction = 0) then this will calculate the deepest penetration point (costing additional CPU time)
	returnDeepestPoint: bool, /* = false*/
}

RayCastSettings :: struct {
	/// How backfacing triangles should be treated (should we report back facing hits for triangle based shapes, e.g. MeshShape/HeightFieldShape?)
	backFaceModeTriangles: BackFaceMode, /* = JPH_BackFaceMode_IgnoreBackFaces*/

	/// How backfacing convex objects should be treated (should we report back facing hits for convex shapes?)
	backFaceModeConvex: BackFaceMode, /* = JPH_BackFaceMode_IgnoreBackFaces*/

	/// If convex shapes should be treated as solid. When true, a ray starting inside a convex shape will generate a hit at fraction 0.
	treatConvexAsSolid: bool, /* = true*/
}

SpringSettings :: struct {
	mode:                 SpringMode,
	frequencyOrStiffness: f32,
	damping:              f32,
}

MotorSettings :: struct {
	springSettings: SpringSettings,
	minForceLimit:  f32,
	maxForceLimit:  f32,
	minTorqueLimit: f32,
	maxTorqueLimit: f32,
}

SubShapeIDPair :: struct {
	Body1ID:     BodyID,
	subShapeID1: SubShapeID,
	Body2ID:     BodyID,
	subShapeID2: SubShapeID,
}

BroadPhaseCastResult :: struct {
	bodyID:   BodyID,
	fraction: f32,
}

RayCastResult :: struct {
	bodyID:      BodyID,
	fraction:    f32,
	subShapeID2: SubShapeID,
}

CollidePointResult :: struct {
	bodyID:      BodyID,
	subShapeID2: SubShapeID,
}

CollideShapeResult :: struct {
	contactPointOn1:  Vec3,
	contactPointOn2:  Vec3,
	penetrationAxis:  Vec3,
	penetrationDepth: f32,
	subShapeID1:      SubShapeID,
	subShapeID2:      SubShapeID,
	bodyID2:          BodyID,
	shape1FaceCount:  u32,
	shape1Faces:      ^Vec3,
	shape2FaceCount:  u32,
	shape2Faces:      ^Vec3,
}

ShapeCastResult :: struct {
	contactPointOn1:  Vec3,
	contactPointOn2:  Vec3,
	penetrationAxis:  Vec3,
	penetrationDepth: f32,
	subShapeID1:      SubShapeID,
	subShapeID2:      SubShapeID,
	bodyID2:          BodyID,
	fraction:         f32,
	isBackFaceHit:    bool,
}

DrawSettings :: struct {
	drawGetSupportFunction:        bool,                    ///< Draw the GetSupport() function, used for convex collision detection
	drawSupportDirection:          bool,                    ///< When drawing the support function, also draw which direction mapped to a specific support point
	drawGetSupportingFace:         bool,                    ///< Draw the faces that were found colliding during collision detection
	drawShape:                     bool,                    ///< Draw the shapes of all bodies
	drawShapeWireframe:            bool,                    ///< When mDrawShape is true and this is true, the shapes will be drawn in wireframe instead of solid.
	drawShapeColor:                BodyManager_ShapeColor,  ///< Coloring scheme to use for shapes
	drawBoundingBox:               bool,                    ///< Draw a bounding box per body
	drawCenterOfMassTransform:     bool,                    ///< Draw the center of mass for each body
	drawWorldTransform:            bool,                    ///< Draw the world transform (which may differ from its center of mass) of each body
	drawVelocity:                  bool,                    ///< Draw the velocity vector for each body
	drawMassAndInertia:            bool,                    ///< Draw the mass and inertia (as the box equivalent) for each body
	drawSleepStats:                bool,                    ///< Draw stats regarding the sleeping algorithm of each body
	drawSoftBodyVertices:          bool,                    ///< Draw the vertices of soft bodies
	drawSoftBodyVertexVelocities:  bool,                    ///< Draw the velocities of the vertices of soft bodies
	drawSoftBodyEdgeConstraints:   bool,                    ///< Draw the edge constraints of soft bodies
	drawSoftBodyBendConstraints:   bool,                    ///< Draw the bend constraints of soft bodies
	drawSoftBodyVolumeConstraints: bool,                    ///< Draw the volume constraints of soft bodies
	drawSoftBodySkinConstraints:   bool,                    ///< Draw the skin constraints of soft bodies
	drawSoftBodyLRAConstraints:    bool,                    ///< Draw the LRA constraints of soft bodies
	drawSoftBodyPredictedBounds:   bool,                    ///< Draw the predicted bounds of soft bodies
	drawSoftBodyConstraintColor:   SoftBodyConstraintColor, ///< Coloring scheme to use for soft body constraints
}

SupportingFace :: struct {
	count:    u32,
	vertices: [32]Vec3,
}

CollisionGroup :: struct {
	groupFilter: ^GroupFilter,
	groupID:     CollisionGroupID,
	subGroupID:  CollisionSubGroupID,
}

CastRayResultCallback             :: proc "c" (_context: rawptr, result: ^RayCastResult)
RayCastBodyResultCallback         :: proc "c" (_context: rawptr, result: ^BroadPhaseCastResult)
CollideShapeBodyResultCallback    :: proc "c" (_context: rawptr, result: BodyID)
CollidePointResultCallback        :: proc "c" (_context: rawptr, result: ^CollidePointResult)
CollideShapeResultCallback        :: proc "c" (_context: rawptr, result: ^CollideShapeResult)
CastShapeResultCallback           :: proc "c" (_context: rawptr, result: ^ShapeCastResult)
CastRayCollectorCallback          :: proc "c" (_context: rawptr, result: ^RayCastResult) -> f32
RayCastBodyCollectorCallback      :: proc "c" (_context: rawptr, result: ^BroadPhaseCastResult) -> f32
CollideShapeBodyCollectorCallback :: proc "c" (_context: rawptr, result: BodyID) -> f32
CollidePointCollectorCallback     :: proc "c" (_context: rawptr, result: ^CollidePointResult) -> f32
CollideShapeCollectorCallback     :: proc "c" (_context: rawptr, result: ^CollideShapeResult) -> f32
CastShapeCollectorCallback        :: proc "c" (_context: rawptr, result: ^ShapeCastResult) -> f32

CollisionEstimationResultImpulse :: struct {
	contactImpulse:   f32,
	frictionImpulse1: f32,
	frictionImpulse2: f32,
}

CollisionEstimationResult :: struct {
	linearVelocity1:  Vec3,
	angularVelocity1: Vec3,
	linearVelocity2:  Vec3,
	angularVelocity2: Vec3,
	tangent1:         Vec3,
	tangent2:         Vec3,
	impulseCount:     u32,
	impulses:         ^CollisionEstimationResultImpulse,
}

BodyActivationListener        :: struct {}
BodyDrawFilter                :: struct {}
SharedMutex                   :: struct {}
DebugRenderer                 :: struct {}
Constraint                    :: struct {}
TwoBodyConstraint             :: struct {}
FixedConstraint               :: struct {}
DistanceConstraint            :: struct {}
PointConstraint               :: struct {}
HingeConstraint               :: struct {}
SliderConstraint              :: struct {}
ConeConstraint                :: struct {}
SwingTwistConstraint          :: struct {}
SixDOFConstraint              :: struct {}
GearConstraint                :: struct {}
CharacterBase                 :: struct {}
Character                     :: struct {} /* Inherits JPH_CharacterBase */
CharacterVirtual              :: struct {} /* Inherits JPH_CharacterBase */
CharacterContactListener      :: struct {}
CharacterVsCharacterCollision :: struct {}
Skeleton                      :: struct {}
RagdollSettings               :: struct {}
Ragdoll                       :: struct {}

ConstraintSettings :: struct {
	enabled:                  bool,
	constraintPriority:       u32,
	numVelocityStepsOverride: u32,
	numPositionStepsOverride: u32,
	drawConstraintSize:       f32,
	userData:                 u64,
}

FixedConstraintSettings :: struct {
	base:            ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:           ConstraintSpace,
	autoDetectPoint: bool,
	point1:          RVec3,
	axisX1:          Vec3,
	axisY1:          Vec3,
	point2:          RVec3,
	axisX2:          Vec3,
	axisY2:          Vec3,
}

DistanceConstraintSettings :: struct {
	base:                 ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:                ConstraintSpace,
	point1:               RVec3,
	point2:               RVec3,
	minDistance:          f32,
	maxDistance:          f32,
	limitsSpringSettings: SpringSettings,
}

PointConstraintSettings :: struct {
	base:   ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:  ConstraintSpace,
	point1: RVec3,
	point2: RVec3,
}

HingeConstraintSettings :: struct {
	base:                 ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:                ConstraintSpace,
	point1:               RVec3,
	hingeAxis1:           Vec3,
	normalAxis1:          Vec3,
	point2:               RVec3,
	hingeAxis2:           Vec3,
	normalAxis2:          Vec3,
	limitsMin:            f32,
	limitsMax:            f32,
	limitsSpringSettings: SpringSettings,
	maxFrictionTorque:    f32,
	motorSettings:        MotorSettings,
}

SliderConstraintSettings :: struct {
	base:                 ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:                ConstraintSpace,
	autoDetectPoint:      bool,
	point1:               RVec3,
	sliderAxis1:          Vec3,
	normalAxis1:          Vec3,
	point2:               RVec3,
	sliderAxis2:          Vec3,
	normalAxis2:          Vec3,
	limitsMin:            f32,
	limitsMax:            f32,
	limitsSpringSettings: SpringSettings,
	maxFrictionForce:     f32,
	motorSettings:        MotorSettings,
}

ConeConstraintSettings :: struct {
	base:          ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:         ConstraintSpace,
	point1:        RVec3,
	twistAxis1:    Vec3,
	point2:        RVec3,
	twistAxis2:    Vec3,
	halfConeAngle: f32,
}

SwingTwistConstraintSettings :: struct {
	base:                ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:               ConstraintSpace,
	position1:           RVec3,
	twistAxis1:          Vec3,
	planeAxis1:          Vec3,
	position2:           RVec3,
	twistAxis2:          Vec3,
	planeAxis2:          Vec3,
	swingType:           SwingType,
	normalHalfConeAngle: f32,
	planeHalfConeAngle:  f32,
	twistMinAngle:       f32,
	twistMaxAngle:       f32,
	maxFrictionTorque:   f32,
	swingMotorSettings:  MotorSettings,
	twistMotorSettings:  MotorSettings,
}

SixDOFConstraintSettings :: struct {
	base:                 ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:                ConstraintSpace,
	position1:            RVec3,
	axisX1:               Vec3,
	axisY1:               Vec3,
	position2:            RVec3,
	axisX2:               Vec3,
	axisY2:               Vec3,
	maxFriction:          [6]f32,
	swingType:            SwingType,
	limitMin:             [6]f32,
	limitMax:             [6]f32,
	limitsSpringSettings: [3]SpringSettings,
	motorSettings:        [6]MotorSettings,
}

GearConstraintSettings :: struct {
	base:       ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	space:      ConstraintSpace,
	hingeAxis1: Vec3,
	hingeAxis2: Vec3,
	ratio:      f32,
}

BodyLockRead :: struct {
	lockInterface: ^BodyLockInterface,
	mutex:         ^SharedMutex,
	body:          ^Body,
}

BodyLockWrite :: struct {
	lockInterface: ^BodyLockInterface,
	mutex:         ^SharedMutex,
	body:          ^Body,
}

BodyLockMultiRead  :: struct {}
BodyLockMultiWrite :: struct {}

ExtendedUpdateSettings :: struct {
	stickToFloorStepDown:             Vec3,
	walkStairsStepUp:                 Vec3,
	walkStairsMinStepForward:         f32,
	walkStairsStepForwardTest:        f32,
	walkStairsCosAngleForwardContact: f32,
	walkStairsStepDownExtra:          Vec3,
}

CharacterBaseSettings :: struct {
	up:                          Vec3,
	supportingVolume:            Plane,
	maxSlopeAngle:               f32,
	enhancedInternalEdgeRemoval: bool,
	shape:                       ^Shape,
}

/* Character */
CharacterSettings :: struct {
	base:          CharacterBaseSettings, /* Inherits JPH_CharacterBaseSettings */
	layer:         ObjectLayer,
	mass:          f32,
	friction:      f32,
	gravityFactor: f32,
	allowedDOFs:   AllowedDOFs,
}

/* CharacterVirtual */
CharacterVirtualSettings :: struct {
	base:                      CharacterBaseSettings, /* Inherits JPH_CharacterBaseSettings */
	ID:                        CharacterID,
	mass:                      f32,
	maxStrength:               f32,
	shapeOffset:               Vec3,
	backFaceMode:              BackFaceMode,
	predictiveContactDistance: f32,
	maxCollisionIterations:    u32,
	maxConstraintIterations:   u32,
	minTimeRemaining:          f32,
	collisionTolerance:        f32,
	characterPadding:          f32,
	maxNumHits:                u32,
	hitReductionCosMaxAngle:   f32,
	penetrationRecoverySpeed:  f32,
	innerBodyShape:            ^Shape,
	innerBodyIDOverride:       BodyID,
	innerBodyLayer:            ObjectLayer,
}

CharacterContactSettings :: struct {
	canPushCharacter:   bool,
	canReceiveImpulses: bool,
}

CharacterVirtualContact :: struct {
	hash:             u64,
	bodyB:            BodyID,
	characterIDB:     CharacterID,
	subShapeIDB:      SubShapeID,
	position:         RVec3,
	linearVelocity:   Vec3,
	contactNormal:    Vec3,
	surfaceNormal:    Vec3,
	distance:         f32,
	fraction:         f32,
	motionTypeB:      MotionType,
	isSensorB:        bool,
	characterB:       ^CharacterVirtual,
	userData:         u64,
	material:         ^PhysicsMaterial,
	hadCollision:     bool,
	wasDiscarded:     bool,
	canPushCharacter: bool,
}

TraceFunc         :: proc "c" (message: cstring)
AssertFailureFunc :: proc "c" (expression: cstring, message: cstring, file: cstring, line: u32) -> bool
JobFunction       :: proc "c" (arg: rawptr)
QueueJobCallback  :: proc "c" (_context: rawptr, job: JobFunction, arg: rawptr)
QueueJobsCallback :: proc "c" (_context: rawptr, job: JobFunction, args: ^rawptr, count: u32)

JobSystemThreadPoolConfig :: struct {
	maxJobs:     u32,
	maxBarriers: u32,
	numThreads:  i32,
}

JobSystemConfig :: struct {
	_context:       rawptr,
	queueJob:       QueueJobCallback,
	queueJobs:      QueueJobsCallback,
	maxConcurrency: u32,
	maxBarriers:    u32,
}

JobSystem :: struct {}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	JobSystemThreadPool_Create :: proc(config: ^JobSystemThreadPoolConfig) -> ^JobSystem ---
	JobSystemCallback_Create   :: proc(config: ^JobSystemConfig) -> ^JobSystem ---
	JobSystem_Destroy          :: proc(jobSystem: ^JobSystem) ---
	Init                       :: proc() -> bool ---
	Shutdown                   :: proc() ---
	SetTraceHandler            :: proc(handler: TraceFunc) ---
	SetAssertFailureHandler    :: proc(handler: AssertFailureFunc) ---

	/* Structs free members */
	CollideShapeResult_FreeMembers        :: proc(result: ^CollideShapeResult) ---
	CollisionEstimationResult_FreeMembers :: proc(result: ^CollisionEstimationResult) ---

	/* JPH_BroadPhaseLayerInterface */
	BroadPhaseLayerInterfaceMask_Create                      :: proc(numBroadPhaseLayers: u32) -> ^BroadPhaseLayerInterface ---
	BroadPhaseLayerInterfaceMask_ConfigureLayer              :: proc(bpInterface: ^BroadPhaseLayerInterface, broadPhaseLayer: BroadPhaseLayer, groupsToInclude: u32, groupsToExclude: u32) ---
	BroadPhaseLayerInterfaceTable_Create                     :: proc(numObjectLayers: u32, numBroadPhaseLayers: u32) -> ^BroadPhaseLayerInterface ---
	BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer :: proc(bpInterface: ^BroadPhaseLayerInterface, objectLayer: ObjectLayer, broadPhaseLayer: BroadPhaseLayer) ---

	/* JPH_ObjectLayerPairFilter */
	ObjectLayerPairFilterMask_Create            :: proc() -> ^ObjectLayerPairFilter ---
	ObjectLayerPairFilterMask_GetObjectLayer    :: proc(group: u32, mask: u32) -> ObjectLayer ---
	ObjectLayerPairFilterMask_GetGroup          :: proc(layer: ObjectLayer) -> u32 ---
	ObjectLayerPairFilterMask_GetMask           :: proc(layer: ObjectLayer) -> u32 ---
	ObjectLayerPairFilterTable_Create           :: proc(numObjectLayers: u32) -> ^ObjectLayerPairFilter ---
	ObjectLayerPairFilterTable_DisableCollision :: proc(objectFilter: ^ObjectLayerPairFilter, layer1: ObjectLayer, layer2: ObjectLayer) ---
	ObjectLayerPairFilterTable_EnableCollision  :: proc(objectFilter: ^ObjectLayerPairFilter, layer1: ObjectLayer, layer2: ObjectLayer) ---
	ObjectLayerPairFilterTable_ShouldCollide    :: proc(objectFilter: ^ObjectLayerPairFilter, layer1: ObjectLayer, layer2: ObjectLayer) -> bool ---

	/* JPH_ObjectVsBroadPhaseLayerFilter */
	ObjectVsBroadPhaseLayerFilterMask_Create  :: proc(broadPhaseLayerInterface: ^BroadPhaseLayerInterface) -> ^ObjectVsBroadPhaseLayerFilter ---
	ObjectVsBroadPhaseLayerFilterTable_Create :: proc(broadPhaseLayerInterface: ^BroadPhaseLayerInterface, numBroadPhaseLayers: u32, objectLayerPairFilter: ^ObjectLayerPairFilter, numObjectLayers: u32) -> ^ObjectVsBroadPhaseLayerFilter ---
	DrawSettings_InitDefault                  :: proc(settings: ^DrawSettings) ---
}

/* JPH_PhysicsSystem */
PhysicsSystemSettings :: struct {
	maxBodies:                     u32, /* 10240 */
	numBodyMutexes:                u32, /* 0 */
	maxBodyPairs:                  u32, /* 65536 */
	maxContactConstraints:         u32, /* 10240 */
	_padding:                      u32,
	broadPhaseLayerInterface:      ^BroadPhaseLayerInterface,
	objectLayerPairFilter:         ^ObjectLayerPairFilter,
	objectVsBroadPhaseLayerFilter: ^ObjectVsBroadPhaseLayerFilter,
}

PhysicsSettings :: struct {
	maxInFlightBodyPairs:                 i32,
	stepListenersBatchSize:               i32,
	stepListenerBatchesPerJob:            i32,
	baumgarte:                            f32,
	speculativeContactDistance:           f32,
	penetrationSlop:                      f32,
	linearCastThreshold:                  f32,
	linearCastMaxPenetration:             f32,
	manifoldTolerance:                    f32,
	maxPenetrationDistance:               f32,
	bodyPairCacheMaxDeltaPositionSq:      f32,
	bodyPairCacheCosMaxDeltaRotationDiv2: f32,
	contactNormalCosMaxDeltaRotation:     f32,
	contactPointPreserveLambdaMaxDistSq:  f32,
	numVelocitySteps:                     u32,
	numPositionSteps:                     u32,
	minVelocityForRestitution:            f32,
	timeBeforeSleep:                      f32,
	pointVelocitySleepThreshold:          f32,
	deterministicSimulation:              bool,
	constraintWarmStart:                  bool,
	useBodyPairContactCache:              bool,
	useManifoldReduction:                 bool,
	useLargeIslandSplitter:               bool,
	allowSleeping:                        bool,
	checkActiveEdges:                     bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	PhysicsSystem_Create                       :: proc(settings: ^PhysicsSystemSettings) -> ^PhysicsSystem ---
	PhysicsSystem_Destroy                      :: proc(system: ^PhysicsSystem) ---
	PhysicsSystem_SetPhysicsSettings           :: proc(system: ^PhysicsSystem, settings: ^PhysicsSettings) ---
	PhysicsSystem_GetPhysicsSettings           :: proc(system: ^PhysicsSystem, result: ^PhysicsSettings) ---
	PhysicsSystem_OptimizeBroadPhase           :: proc(system: ^PhysicsSystem) ---
	PhysicsSystem_Update                       :: proc(system: ^PhysicsSystem, deltaTime: f32, collisionSteps: i32, jobSystem: ^JobSystem) -> PhysicsUpdateError ---
	PhysicsSystem_GetBodyInterface             :: proc(system: ^PhysicsSystem) -> ^BodyInterface ---
	PhysicsSystem_GetBodyInterfaceNoLock       :: proc(system: ^PhysicsSystem) -> ^BodyInterface ---
	PhysicsSystem_GetBodyLockInterface         :: proc(system: ^PhysicsSystem) -> ^BodyLockInterface ---
	PhysicsSystem_GetBodyLockInterfaceNoLock   :: proc(system: ^PhysicsSystem) -> ^BodyLockInterface ---
	PhysicsSystem_GetBroadPhaseQuery           :: proc(system: ^PhysicsSystem) -> ^BroadPhaseQuery ---
	PhysicsSystem_GetNarrowPhaseQuery          :: proc(system: ^PhysicsSystem) -> ^NarrowPhaseQuery ---
	PhysicsSystem_GetNarrowPhaseQueryNoLock    :: proc(system: ^PhysicsSystem) -> ^NarrowPhaseQuery ---
	PhysicsSystem_SetContactListener           :: proc(system: ^PhysicsSystem, listener: ^ContactListener) ---
	PhysicsSystem_SetBodyActivationListener    :: proc(system: ^PhysicsSystem, listener: ^BodyActivationListener) ---
	PhysicsSystem_SetSimShapeFilter            :: proc(system: ^PhysicsSystem, filter: ^SimShapeFilter) ---
	PhysicsSystem_WereBodiesInContact          :: proc(system: ^PhysicsSystem, body1: BodyID, body2: BodyID) -> bool ---
	PhysicsSystem_GetNumBodies                 :: proc(system: ^PhysicsSystem) -> u32 ---
	PhysicsSystem_GetNumActiveBodies           :: proc(system: ^PhysicsSystem, type: BodyType) -> u32 ---
	PhysicsSystem_GetMaxBodies                 :: proc(system: ^PhysicsSystem) -> u32 ---
	PhysicsSystem_GetNumConstraints            :: proc(system: ^PhysicsSystem) -> u32 ---
	PhysicsSystem_SetGravity                   :: proc(system: ^PhysicsSystem, value: ^Vec3) ---
	PhysicsSystem_GetGravity                   :: proc(system: ^PhysicsSystem, result: ^Vec3) ---
	PhysicsSystem_AddConstraint                :: proc(system: ^PhysicsSystem, constraint: ^Constraint) ---
	PhysicsSystem_RemoveConstraint             :: proc(system: ^PhysicsSystem, constraint: ^Constraint) ---
	PhysicsSystem_AddConstraints               :: proc(system: ^PhysicsSystem, constraints: ^^Constraint, count: u32) ---
	PhysicsSystem_RemoveConstraints            :: proc(system: ^PhysicsSystem, constraints: ^^Constraint, count: u32) ---
	PhysicsSystem_AddStepListener              :: proc(system: ^PhysicsSystem, listener: ^PhysicsStepListener) ---
	PhysicsSystem_RemoveStepListener           :: proc(system: ^PhysicsSystem, listener: ^PhysicsStepListener) ---
	PhysicsSystem_GetBodies                    :: proc(system: ^PhysicsSystem, ids: ^BodyID, count: u32) ---
	PhysicsSystem_GetConstraints               :: proc(system: ^PhysicsSystem, constraints: ^^Constraint, count: u32) ---
	PhysicsSystem_ActivateBodiesInAABox        :: proc(system: ^PhysicsSystem, box: ^AABox, layer: ObjectLayer) ---
	PhysicsSystem_DrawBodies                   :: proc(system: ^PhysicsSystem, settings: ^DrawSettings, renderer: ^DebugRenderer, bodyFilter: ^BodyDrawFilter) --- /* = nullptr */
	PhysicsSystem_DrawConstraints              :: proc(system: ^PhysicsSystem, renderer: ^DebugRenderer) ---
	PhysicsSystem_DrawConstraintLimits         :: proc(system: ^PhysicsSystem, renderer: ^DebugRenderer) ---
	PhysicsSystem_DrawConstraintReferenceFrame :: proc(system: ^PhysicsSystem, renderer: ^DebugRenderer) ---
}

/* PhysicsStepListener */
PhysicsStepListenerContext :: struct {
	deltaTime:     f32,
	isFirstStep:   Bool,
	isLastStep:    Bool,
	physicsSystem: ^PhysicsSystem,
}

PhysicsStepListener_Procs :: struct {
	OnStep: proc "c" (userData: rawptr, _context: ^PhysicsStepListenerContext),
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	PhysicsStepListener_SetProcs :: proc(procs: ^PhysicsStepListener_Procs) ---
	PhysicsStepListener_Create   :: proc(userData: rawptr) -> ^PhysicsStepListener ---
	PhysicsStepListener_Destroy  :: proc(listener: ^PhysicsStepListener) ---

	/* Math */
	Math_Sin                        :: proc(value: f32) -> f32 ---
	Math_Cos                        :: proc(value: f32) -> f32 ---
	Quat_FromTo                     :: proc(from: ^Vec3, to: ^Vec3, quat: ^Quat) ---
	Quat_GetAxisAngle               :: proc(quat: ^Quat, outAxis: ^Vec3, outAngle: ^f32) ---
	Quat_GetEulerAngles             :: proc(quat: ^Quat, result: ^Vec3) ---
	Quat_RotateAxisX                :: proc(quat: ^Quat, result: ^Vec3) ---
	Quat_RotateAxisY                :: proc(quat: ^Quat, result: ^Vec3) ---
	Quat_RotateAxisZ                :: proc(quat: ^Quat, result: ^Vec3) ---
	Quat_Inversed                   :: proc(quat: ^Quat, result: ^Quat) ---
	Quat_GetPerpendicular           :: proc(quat: ^Quat, result: ^Quat) ---
	Quat_GetRotationAngle           :: proc(quat: ^Quat, axis: ^Vec3) -> f32 ---
	Quat_FromEulerAngles            :: proc(angles: ^Vec3, result: ^Quat) ---
	Quat_Add                        :: proc(q1: ^Quat, q2: ^Quat, result: ^Quat) ---
	Quat_Subtract                   :: proc(q1: ^Quat, q2: ^Quat, result: ^Quat) ---
	Quat_Multiply                   :: proc(q1: ^Quat, q2: ^Quat, result: ^Quat) ---
	Quat_MultiplyScalar             :: proc(q: ^Quat, scalar: f32, result: ^Quat) ---
	Quat_DivideScalar               :: proc(q: ^Quat, scalar: f32, result: ^Quat) ---
	Quat_Dot                        :: proc(q1: ^Quat, q2: ^Quat, result: ^f32) ---
	Quat_Conjugated                 :: proc(quat: ^Quat, result: ^Quat) ---
	Quat_GetTwist                   :: proc(quat: ^Quat, axis: ^Vec3, result: ^Quat) ---
	Quat_GetSwingTwist              :: proc(quat: ^Quat, outSwing: ^Quat, outTwist: ^Quat) ---
	Quat_Lerp                       :: proc(from: ^Quat, to: ^Quat, fraction: f32, result: ^Quat) ---
	Quat_Slerp                      :: proc(from: ^Quat, to: ^Quat, fraction: f32, result: ^Quat) ---
	Quat_Rotate                     :: proc(quat: ^Quat, vec: ^Vec3, result: ^Vec3) ---
	Quat_InverseRotate              :: proc(quat: ^Quat, vec: ^Vec3, result: ^Vec3) ---
	Vec3_AxisX                      :: proc(result: ^Vec3) ---
	Vec3_AxisY                      :: proc(result: ^Vec3) ---
	Vec3_AxisZ                      :: proc(result: ^Vec3) ---
	Vec3_IsClose                    :: proc(v1: ^Vec3, v2: ^Vec3, maxDistSq: f32) -> bool ---
	Vec3_IsNearZero                 :: proc(v: ^Vec3, maxDistSq: f32) -> bool ---
	Vec3_IsNormalized               :: proc(v: ^Vec3, tolerance: f32) -> bool ---
	Vec3_IsNaN                      :: proc(v: ^Vec3) -> bool ---
	Vec3_Negate                     :: proc(v: ^Vec3, result: ^Vec3) ---
	Vec3_Normalized                 :: proc(v: ^Vec3, result: ^Vec3) ---
	Vec3_Cross                      :: proc(v1: ^Vec3, v2: ^Vec3, result: ^Vec3) ---
	Vec3_Abs                        :: proc(v: ^Vec3, result: ^Vec3) ---
	Vec3_Length                     :: proc(v: ^Vec3) -> f32 ---
	Vec3_LengthSquared              :: proc(v: ^Vec3) -> f32 ---
	Vec3_DotProduct                 :: proc(v1: ^Vec3, v2: ^Vec3, result: ^f32) ---
	Vec3_Normalize                  :: proc(v: ^Vec3, result: ^Vec3) ---
	Vec3_Add                        :: proc(v1: ^Vec3, v2: ^Vec3, result: ^Vec3) ---
	Vec3_Subtract                   :: proc(v1: ^Vec3, v2: ^Vec3, result: ^Vec3) ---
	Vec3_Multiply                   :: proc(v1: ^Vec3, v2: ^Vec3, result: ^Vec3) ---
	Vec3_MultiplyScalar             :: proc(v: ^Vec3, scalar: f32, result: ^Vec3) ---
	Vec3_MultiplyMatrix             :: proc(left: ^Mat4, right: ^Vec3, result: ^Vec3) ---
	Vec3_Divide                     :: proc(v1: ^Vec3, v2: ^Vec3, result: ^Vec3) ---
	Vec3_DivideScalar               :: proc(v: ^Vec3, scalar: f32, result: ^Vec3) ---
	Mat4_Add                        :: proc(m1: ^Mat4, m2: ^Mat4, result: ^Mat4) ---
	Mat4_Subtract                   :: proc(m1: ^Mat4, m2: ^Mat4, result: ^Mat4) ---
	Mat4_Multiply                   :: proc(m1: ^Mat4, m2: ^Mat4, result: ^Mat4) ---
	Mat4_MultiplyScalar             :: proc(m: ^Mat4, scalar: f32, result: ^Mat4) ---
	Mat4_Zero                       :: proc(result: ^Mat4) ---
	Mat4_Identity                   :: proc(result: ^Mat4) ---
	Mat4_Rotation                   :: proc(result: ^Mat4, rotation: ^Quat) ---
	Mat4_Rotation2                  :: proc(result: ^Mat4, axis: ^Vec3, angle: f32) ---
	Mat4_Translation                :: proc(result: ^Mat4, translation: ^Vec3) ---
	Mat4_RotationTranslation        :: proc(result: ^Mat4, rotation: ^Quat, translation: ^Vec3) ---
	Mat4_InverseRotationTranslation :: proc(result: ^Mat4, rotation: ^Quat, translation: ^Vec3) ---
	Mat4_Scale                      :: proc(result: ^Mat4, scale: ^Vec3) ---
	Mat4_Transposed                 :: proc(m: ^Mat4, result: ^Mat4) ---
	Mat4_Inversed                   :: proc(_matrix: ^Mat4, result: ^Mat4) ---
	Mat4_GetAxisX                   :: proc(_matrix: ^Mat4, result: ^Vec3) ---
	Mat4_GetAxisY                   :: proc(_matrix: ^Mat4, result: ^Vec3) ---
	Mat4_GetAxisZ                   :: proc(_matrix: ^Mat4, result: ^Vec3) ---
	Mat4_GetTranslation             :: proc(_matrix: ^Mat4, result: ^Vec3) ---
	Mat4_GetQuaternion              :: proc(_matrix: ^Mat4, result: ^Quat) ---

	/* Material */
	PhysicsMaterial_Create        :: proc(name: cstring, color: u32) -> ^PhysicsMaterial ---
	PhysicsMaterial_Destroy       :: proc(material: ^PhysicsMaterial) ---
	PhysicsMaterial_GetDebugName  :: proc(material: ^PhysicsMaterial) -> cstring ---
	PhysicsMaterial_GetDebugColor :: proc(material: ^PhysicsMaterial) -> u32 ---

	/* GroupFilter/GroupFilterTable */
	GroupFilter_Destroy                 :: proc(groupFilter: ^GroupFilter) ---
	GroupFilter_CanCollide              :: proc(groupFilter: ^GroupFilter, group1: ^CollisionGroup, group2: ^CollisionGroup) -> bool ---
	GroupFilterTable_Create             :: proc(numSubGroups: u32) -> ^GroupFilterTable --- /* = 0*/
	GroupFilterTable_DisableCollision   :: proc(table: ^GroupFilterTable, subGroup1: CollisionSubGroupID, subGroup2: CollisionSubGroupID) ---
	GroupFilterTable_EnableCollision    :: proc(table: ^GroupFilterTable, subGroup1: CollisionSubGroupID, subGroup2: CollisionSubGroupID) ---
	GroupFilterTable_IsCollisionEnabled :: proc(table: ^GroupFilterTable, subGroup1: CollisionSubGroupID, subGroup2: CollisionSubGroupID) -> bool ---

	/* ShapeSettings */
	ShapeSettings_Destroy     :: proc(settings: ^ShapeSettings) ---
	ShapeSettings_GetUserData :: proc(settings: ^ShapeSettings) -> u64 ---
	ShapeSettings_SetUserData :: proc(settings: ^ShapeSettings, userData: u64) ---

	/* Shape */
	Shape_Destroy                    :: proc(shape: ^Shape) ---
	Shape_GetType                    :: proc(shape: ^Shape) -> ShapeType ---
	Shape_GetSubType                 :: proc(shape: ^Shape) -> ShapeSubType ---
	Shape_GetUserData                :: proc(shape: ^Shape) -> u64 ---
	Shape_SetUserData                :: proc(shape: ^Shape, userData: u64) ---
	Shape_MustBeStatic               :: proc(shape: ^Shape) -> bool ---
	Shape_GetCenterOfMass            :: proc(shape: ^Shape, result: ^Vec3) ---
	Shape_GetLocalBounds             :: proc(shape: ^Shape, result: ^AABox) ---
	Shape_GetSubShapeIDBitsRecursive :: proc(shape: ^Shape) -> u32 ---
	Shape_GetWorldSpaceBounds        :: proc(shape: ^Shape, centerOfMassTransform: ^RMat4, scale: ^Vec3, result: ^AABox) ---
	Shape_GetInnerRadius             :: proc(shape: ^Shape) -> f32 ---
	Shape_GetMassProperties          :: proc(shape: ^Shape, result: ^MassProperties) ---
	Shape_GetLeafShape               :: proc(shape: ^Shape, subShapeID: SubShapeID, remainder: ^SubShapeID) -> ^Shape ---
	Shape_GetMaterial                :: proc(shape: ^Shape, subShapeID: SubShapeID) -> ^PhysicsMaterial ---
	Shape_GetSurfaceNormal           :: proc(shape: ^Shape, subShapeID: SubShapeID, localPosition: ^Vec3, normal: ^Vec3) ---
	Shape_GetSupportingFace          :: proc(shape: ^Shape, subShapeID: SubShapeID, direction: ^Vec3, scale: ^Vec3, centerOfMassTransform: ^Mat4, outVertices: ^SupportingFace) ---
	Shape_GetVolume                  :: proc(shape: ^Shape) -> f32 ---
	Shape_IsValidScale               :: proc(shape: ^Shape, scale: ^Vec3) -> bool ---
	Shape_MakeScaleValid             :: proc(shape: ^Shape, scale: ^Vec3, result: ^Vec3) ---
	Shape_ScaleShape                 :: proc(shape: ^Shape, scale: ^Vec3) -> ^Shape ---
	Shape_CastRay                    :: proc(shape: ^Shape, origin: ^Vec3, direction: ^Vec3, hit: ^RayCastResult) -> bool ---
	Shape_CastRay2                   :: proc(shape: ^Shape, origin: ^Vec3, direction: ^Vec3, rayCastSettings: ^RayCastSettings, collectorType: CollisionCollectorType, callback: CastRayResultCallback, userData: rawptr, shapeFilter: ^ShapeFilter) -> bool ---
	Shape_CollidePoint               :: proc(shape: ^Shape, point: ^Vec3, shapeFilter: ^ShapeFilter) -> bool ---
	Shape_CollidePoint2              :: proc(shape: ^Shape, point: ^Vec3, collectorType: CollisionCollectorType, callback: CollidePointResultCallback, userData: rawptr, shapeFilter: ^ShapeFilter) -> bool ---

	/* JPH_ConvexShape */
	ConvexShapeSettings_GetDensity :: proc(shape: ^ConvexShapeSettings) -> f32 ---
	ConvexShapeSettings_SetDensity :: proc(shape: ^ConvexShapeSettings, value: f32) ---
	ConvexShape_GetDensity         :: proc(shape: ^ConvexShape) -> f32 ---
	ConvexShape_SetDensity         :: proc(shape: ^ConvexShape, inDensity: f32) ---

	/* BoxShape */
	BoxShapeSettings_Create      :: proc(halfExtent: ^Vec3, convexRadius: f32) -> ^BoxShapeSettings ---
	BoxShapeSettings_CreateShape :: proc(settings: ^BoxShapeSettings) -> ^BoxShape ---
	BoxShape_Create              :: proc(halfExtent: ^Vec3, convexRadius: f32) -> ^BoxShape ---
	BoxShape_GetHalfExtent       :: proc(shape: ^BoxShape, halfExtent: ^Vec3) ---
	BoxShape_GetConvexRadius     :: proc(shape: ^BoxShape) -> f32 ---

	/* SphereShape */
	SphereShapeSettings_Create      :: proc(radius: f32) -> ^SphereShapeSettings ---
	SphereShapeSettings_CreateShape :: proc(settings: ^SphereShapeSettings) -> ^SphereShape ---
	SphereShapeSettings_GetRadius   :: proc(settings: ^SphereShapeSettings) -> f32 ---
	SphereShapeSettings_SetRadius   :: proc(settings: ^SphereShapeSettings, radius: f32) ---
	SphereShape_Create              :: proc(radius: f32) -> ^SphereShape ---
	SphereShape_GetRadius           :: proc(shape: ^SphereShape) -> f32 ---

	/* PlaneShape */
	PlaneShapeSettings_Create      :: proc(plane: ^Plane, material: ^PhysicsMaterial, halfExtent: f32) -> ^PlaneShapeSettings ---
	PlaneShapeSettings_CreateShape :: proc(settings: ^PlaneShapeSettings) -> ^PlaneShape ---
	PlaneShape_Create              :: proc(plane: ^Plane, material: ^PhysicsMaterial, halfExtent: f32) -> ^PlaneShape ---
	PlaneShape_GetPlane            :: proc(shape: ^PlaneShape, result: ^Plane) ---
	PlaneShape_GetHalfExtent       :: proc(shape: ^PlaneShape) -> f32 ---

	/* TriangleShape */
	TriangleShapeSettings_Create      :: proc(v1: ^Vec3, v2: ^Vec3, v3: ^Vec3, convexRadius: f32) -> ^TriangleShapeSettings ---
	TriangleShapeSettings_CreateShape :: proc(settings: ^TriangleShapeSettings) -> ^TriangleShape ---
	TriangleShape_Create              :: proc(v1: ^Vec3, v2: ^Vec3, v3: ^Vec3, convexRadius: f32) -> ^TriangleShape ---
	TriangleShape_GetConvexRadius     :: proc(shape: ^TriangleShape) -> f32 ---
	TriangleShape_GetVertex1          :: proc(shape: ^TriangleShape, result: ^Vec3) ---
	TriangleShape_GetVertex2          :: proc(shape: ^TriangleShape, result: ^Vec3) ---
	TriangleShape_GetVertex3          :: proc(shape: ^TriangleShape, result: ^Vec3) ---

	/* CapsuleShape */
	CapsuleShapeSettings_Create          :: proc(halfHeightOfCylinder: f32, radius: f32) -> ^CapsuleShapeSettings ---
	CapsuleShapeSettings_CreateShape     :: proc(settings: ^CapsuleShapeSettings) -> ^CapsuleShape ---
	CapsuleShape_Create                  :: proc(halfHeightOfCylinder: f32, radius: f32) -> ^CapsuleShape ---
	CapsuleShape_GetRadius               :: proc(shape: ^CapsuleShape) -> f32 ---
	CapsuleShape_GetHalfHeightOfCylinder :: proc(shape: ^CapsuleShape) -> f32 ---

	/* CylinderShape */
	CylinderShapeSettings_Create      :: proc(halfHeight: f32, radius: f32, convexRadius: f32) -> ^CylinderShapeSettings ---
	CylinderShapeSettings_CreateShape :: proc(settings: ^CylinderShapeSettings) -> ^CylinderShape ---
	CylinderShape_Create              :: proc(halfHeight: f32, radius: f32) -> ^CylinderShape ---
	CylinderShape_GetRadius           :: proc(shape: ^CylinderShape) -> f32 ---
	CylinderShape_GetHalfHeight       :: proc(shape: ^CylinderShape) -> f32 ---

	/* TaperedCylinderShape */
	TaperedCylinderShapeSettings_Create      :: proc(halfHeightOfTaperedCylinder: f32, topRadius: f32, bottomRadius: f32, convexRadius: f32, material: ^PhysicsMaterial) -> ^TaperedCylinderShapeSettings --- /* = cDefaultConvexRadius*/
	TaperedCylinderShapeSettings_CreateShape :: proc(settings: ^TaperedCylinderShapeSettings) -> ^TaperedCylinderShape ---
	TaperedCylinderShape_GetTopRadius        :: proc(shape: ^TaperedCylinderShape) -> f32 ---
	TaperedCylinderShape_GetBottomRadius     :: proc(shape: ^TaperedCylinderShape) -> f32 ---
	TaperedCylinderShape_GetConvexRadius     :: proc(shape: ^TaperedCylinderShape) -> f32 ---
	TaperedCylinderShape_GetHalfHeight       :: proc(shape: ^TaperedCylinderShape) -> f32 ---

	/* ConvexHullShape */
	ConvexHullShapeSettings_Create       :: proc(points: ^Vec3, pointsCount: u32, maxConvexRadius: f32) -> ^ConvexHullShapeSettings ---
	ConvexHullShapeSettings_CreateShape  :: proc(settings: ^ConvexHullShapeSettings) -> ^ConvexHullShape ---
	ConvexHullShape_GetNumPoints         :: proc(shape: ^ConvexHullShape) -> u32 ---
	ConvexHullShape_GetPoint             :: proc(shape: ^ConvexHullShape, index: u32, result: ^Vec3) ---
	ConvexHullShape_GetNumFaces          :: proc(shape: ^ConvexHullShape) -> u32 ---
	ConvexHullShape_GetNumVerticesInFace :: proc(shape: ^ConvexHullShape, faceIndex: u32) -> u32 ---
	ConvexHullShape_GetFaceVertices      :: proc(shape: ^ConvexHullShape, faceIndex: u32, maxVertices: u32, vertices: ^u32) -> u32 ---

	/* MeshShape */
	MeshShapeSettings_Create                         :: proc(triangles: ^Triangle, triangleCount: u32) -> ^MeshShapeSettings ---
	MeshShapeSettings_Create2                        :: proc(vertices: ^Vec3, verticesCount: u32, triangles: ^IndexedTriangle, triangleCount: u32) -> ^MeshShapeSettings ---
	MeshShapeSettings_GetMaxTrianglesPerLeaf         :: proc(settings: ^MeshShapeSettings) -> u32 ---
	MeshShapeSettings_SetMaxTrianglesPerLeaf         :: proc(settings: ^MeshShapeSettings, value: u32) ---
	MeshShapeSettings_GetActiveEdgeCosThresholdAngle :: proc(settings: ^MeshShapeSettings) -> f32 ---
	MeshShapeSettings_SetActiveEdgeCosThresholdAngle :: proc(settings: ^MeshShapeSettings, value: f32) ---
	MeshShapeSettings_GetPerTriangleUserData         :: proc(settings: ^MeshShapeSettings) -> bool ---
	MeshShapeSettings_SetPerTriangleUserData         :: proc(settings: ^MeshShapeSettings, value: bool) ---
	MeshShapeSettings_GetBuildQuality                :: proc(settings: ^MeshShapeSettings) -> Mesh_Shape_BuildQuality ---
	MeshShapeSettings_SetBuildQuality                :: proc(settings: ^MeshShapeSettings, value: Mesh_Shape_BuildQuality) ---
	MeshShapeSettings_Sanitize                       :: proc(settings: ^MeshShapeSettings) ---
	MeshShapeSettings_CreateShape                    :: proc(settings: ^MeshShapeSettings) -> ^MeshShape ---
	MeshShape_GetTriangleUserData                    :: proc(shape: ^MeshShape, id: SubShapeID) -> u32 ---

	/* HeightFieldShape */
	HeightFieldShapeSettings_Create                         :: proc(samples: ^f32, offset: ^Vec3, scale: ^Vec3, sampleCount: u32, materialIndices: ^u8) -> ^HeightFieldShapeSettings ---
	HeightFieldShapeSettings_DetermineMinAndMaxSample       :: proc(settings: ^HeightFieldShapeSettings, pOutMinValue: ^f32, pOutMaxValue: ^f32, pOutQuantizationScale: ^f32) ---
	HeightFieldShapeSettings_CalculateBitsPerSampleForError :: proc(settings: ^HeightFieldShapeSettings, maxError: f32) -> u32 ---
	HeightFieldShapeSettings_GetOffset                      :: proc(shape: ^HeightFieldShapeSettings, result: ^Vec3) ---
	HeightFieldShapeSettings_SetOffset                      :: proc(settings: ^HeightFieldShapeSettings, value: ^Vec3) ---
	HeightFieldShapeSettings_GetScale                       :: proc(shape: ^HeightFieldShapeSettings, result: ^Vec3) ---
	HeightFieldShapeSettings_SetScale                       :: proc(settings: ^HeightFieldShapeSettings, value: ^Vec3) ---
	HeightFieldShapeSettings_GetSampleCount                 :: proc(settings: ^HeightFieldShapeSettings) -> u32 ---
	HeightFieldShapeSettings_SetSampleCount                 :: proc(settings: ^HeightFieldShapeSettings, value: u32) ---
	HeightFieldShapeSettings_GetMinHeightValue              :: proc(settings: ^HeightFieldShapeSettings) -> f32 ---
	HeightFieldShapeSettings_SetMinHeightValue              :: proc(settings: ^HeightFieldShapeSettings, value: f32) ---
	HeightFieldShapeSettings_GetMaxHeightValue              :: proc(settings: ^HeightFieldShapeSettings) -> f32 ---
	HeightFieldShapeSettings_SetMaxHeightValue              :: proc(settings: ^HeightFieldShapeSettings, value: f32) ---
	HeightFieldShapeSettings_GetBlockSize                   :: proc(settings: ^HeightFieldShapeSettings) -> u32 ---
	HeightFieldShapeSettings_SetBlockSize                   :: proc(settings: ^HeightFieldShapeSettings, value: u32) ---
	HeightFieldShapeSettings_GetBitsPerSample               :: proc(settings: ^HeightFieldShapeSettings) -> u32 ---
	HeightFieldShapeSettings_SetBitsPerSample               :: proc(settings: ^HeightFieldShapeSettings, value: u32) ---
	HeightFieldShapeSettings_GetActiveEdgeCosThresholdAngle :: proc(settings: ^HeightFieldShapeSettings) -> f32 ---
	HeightFieldShapeSettings_SetActiveEdgeCosThresholdAngle :: proc(settings: ^HeightFieldShapeSettings, value: f32) ---
	HeightFieldShapeSettings_CreateShape                    :: proc(settings: ^HeightFieldShapeSettings) -> ^HeightFieldShape ---
	HeightFieldShape_GetSampleCount                         :: proc(shape: ^HeightFieldShape) -> u32 ---
	HeightFieldShape_GetBlockSize                           :: proc(shape: ^HeightFieldShape) -> u32 ---
	HeightFieldShape_GetMaterial                            :: proc(shape: ^HeightFieldShape, x: u32, y: u32) -> ^PhysicsMaterial ---
	HeightFieldShape_GetPosition                            :: proc(shape: ^HeightFieldShape, x: u32, y: u32, result: ^Vec3) ---
	HeightFieldShape_IsNoCollision                          :: proc(shape: ^HeightFieldShape, x: u32, y: u32) -> bool ---
	HeightFieldShape_ProjectOntoSurface                     :: proc(shape: ^HeightFieldShape, localPosition: ^Vec3, outSurfacePosition: ^Vec3, outSubShapeID: ^SubShapeID) -> bool ---
	HeightFieldShape_GetMinHeightValue                      :: proc(shape: ^HeightFieldShape) -> f32 ---
	HeightFieldShape_GetMaxHeightValue                      :: proc(shape: ^HeightFieldShape) -> f32 ---

	/* TaperedCapsuleShape */
	TaperedCapsuleShapeSettings_Create      :: proc(halfHeightOfTaperedCylinder: f32, topRadius: f32, bottomRadius: f32) -> ^TaperedCapsuleShapeSettings ---
	TaperedCapsuleShapeSettings_CreateShape :: proc(settings: ^TaperedCapsuleShapeSettings) -> ^TaperedCapsuleShape ---
	TaperedCapsuleShape_GetTopRadius        :: proc(shape: ^TaperedCapsuleShape) -> f32 ---
	TaperedCapsuleShape_GetBottomRadius     :: proc(shape: ^TaperedCapsuleShape) -> f32 ---
	TaperedCapsuleShape_GetHalfHeight       :: proc(shape: ^TaperedCapsuleShape) -> f32 ---

	/* CompoundShape */
	CompoundShapeSettings_AddShape       :: proc(settings: ^CompoundShapeSettings, position: ^Vec3, rotation: ^Quat, shapeSettings: ^ShapeSettings, userData: u32) ---
	CompoundShapeSettings_AddShape2      :: proc(settings: ^CompoundShapeSettings, position: ^Vec3, rotation: ^Quat, shape: ^Shape, userData: u32) ---
	CompoundShape_GetNumSubShapes        :: proc(shape: ^CompoundShape) -> u32 ---
	CompoundShape_GetSubShape            :: proc(shape: ^CompoundShape, index: u32, subShape: ^^Shape, positionCOM: ^Vec3, rotation: ^Quat, userData: ^u32) ---
	CompoundShape_GetSubShapeIndexFromID :: proc(shape: ^CompoundShape, id: SubShapeID, remainder: ^SubShapeID) -> u32 ---

	/* StaticCompoundShape */
	StaticCompoundShapeSettings_Create :: proc() -> ^StaticCompoundShapeSettings ---
	StaticCompoundShape_Create         :: proc(settings: ^StaticCompoundShapeSettings) -> ^StaticCompoundShape ---

	/* MutableCompoundShape */
	MutableCompoundShapeSettings_Create     :: proc() -> ^MutableCompoundShapeSettings ---
	MutableCompoundShape_Create             :: proc(settings: ^MutableCompoundShapeSettings) -> ^MutableCompoundShape ---
	MutableCompoundShape_AddShape           :: proc(shape: ^MutableCompoundShape, position: ^Vec3, rotation: ^Quat, child: ^Shape, userData: u32, index: u32) -> u32 --- /* = 0 */
	MutableCompoundShape_RemoveShape        :: proc(shape: ^MutableCompoundShape, index: u32) ---
	MutableCompoundShape_ModifyShape        :: proc(shape: ^MutableCompoundShape, index: u32, position: ^Vec3, rotation: ^Quat) ---
	MutableCompoundShape_ModifyShape2       :: proc(shape: ^MutableCompoundShape, index: u32, position: ^Vec3, rotation: ^Quat, newShape: ^Shape) ---
	MutableCompoundShape_AdjustCenterOfMass :: proc(shape: ^MutableCompoundShape) ---

	/* DecoratedShape */
	DecoratedShape_GetInnerShape :: proc(shape: ^DecoratedShape) -> ^Shape ---

	/* RotatedTranslatedShape */
	RotatedTranslatedShapeSettings_Create      :: proc(position: ^Vec3, rotation: ^Quat, shapeSettings: ^ShapeSettings) -> ^RotatedTranslatedShapeSettings ---
	RotatedTranslatedShapeSettings_Create2     :: proc(position: ^Vec3, rotation: ^Quat, shape: ^Shape) -> ^RotatedTranslatedShapeSettings ---
	RotatedTranslatedShapeSettings_CreateShape :: proc(settings: ^RotatedTranslatedShapeSettings) -> ^RotatedTranslatedShape ---
	RotatedTranslatedShape_Create              :: proc(position: ^Vec3, rotation: ^Quat, shape: ^Shape) -> ^RotatedTranslatedShape ---
	RotatedTranslatedShape_GetPosition         :: proc(shape: ^RotatedTranslatedShape, position: ^Vec3) ---
	RotatedTranslatedShape_GetRotation         :: proc(shape: ^RotatedTranslatedShape, rotation: ^Quat) ---

	/* ScaledShape */
	ScaledShapeSettings_Create      :: proc(shapeSettings: ^ShapeSettings, scale: ^Vec3) -> ^ScaledShapeSettings ---
	ScaledShapeSettings_Create2     :: proc(shape: ^Shape, scale: ^Vec3) -> ^ScaledShapeSettings ---
	ScaledShapeSettings_CreateShape :: proc(settings: ^ScaledShapeSettings) -> ^ScaledShape ---
	ScaledShape_Create              :: proc(shape: ^Shape, scale: ^Vec3) -> ^ScaledShape ---
	ScaledShape_GetScale            :: proc(shape: ^ScaledShape, result: ^Vec3) ---

	/* OffsetCenterOfMassShape */
	OffsetCenterOfMassShapeSettings_Create      :: proc(offset: ^Vec3, shapeSettings: ^ShapeSettings) -> ^OffsetCenterOfMassShapeSettings ---
	OffsetCenterOfMassShapeSettings_Create2     :: proc(offset: ^Vec3, shape: ^Shape) -> ^OffsetCenterOfMassShapeSettings ---
	OffsetCenterOfMassShapeSettings_CreateShape :: proc(settings: ^OffsetCenterOfMassShapeSettings) -> ^OffsetCenterOfMassShape ---
	OffsetCenterOfMassShape_Create              :: proc(offset: ^Vec3, shape: ^Shape) -> ^OffsetCenterOfMassShape ---
	OffsetCenterOfMassShape_GetOffset           :: proc(shape: ^OffsetCenterOfMassShape, result: ^Vec3) ---

	/* EmptyShape */
	EmptyShapeSettings_Create      :: proc(centerOfMass: ^Vec3) -> ^EmptyShapeSettings ---
	EmptyShapeSettings_CreateShape :: proc(settings: ^EmptyShapeSettings) -> ^EmptyShape ---

	/* JPH_BodyCreationSettings */
	BodyCreationSettings_Create                          :: proc() -> ^BodyCreationSettings ---
	BodyCreationSettings_Create2                         :: proc(settings: ^ShapeSettings, position: ^RVec3, rotation: ^Quat, motionType: MotionType, objectLayer: ObjectLayer) -> ^BodyCreationSettings ---
	BodyCreationSettings_Create3                         :: proc(shape: ^Shape, position: ^RVec3, rotation: ^Quat, motionType: MotionType, objectLayer: ObjectLayer) -> ^BodyCreationSettings ---
	BodyCreationSettings_Destroy                         :: proc(settings: ^BodyCreationSettings) ---
	BodyCreationSettings_GetPosition                     :: proc(settings: ^BodyCreationSettings, result: ^RVec3) ---
	BodyCreationSettings_SetPosition                     :: proc(settings: ^BodyCreationSettings, value: ^RVec3) ---
	BodyCreationSettings_GetRotation                     :: proc(settings: ^BodyCreationSettings, result: ^Quat) ---
	BodyCreationSettings_SetRotation                     :: proc(settings: ^BodyCreationSettings, value: ^Quat) ---
	BodyCreationSettings_GetLinearVelocity               :: proc(settings: ^BodyCreationSettings, velocity: ^Vec3) ---
	BodyCreationSettings_SetLinearVelocity               :: proc(settings: ^BodyCreationSettings, velocity: ^Vec3) ---
	BodyCreationSettings_GetAngularVelocity              :: proc(settings: ^BodyCreationSettings, velocity: ^Vec3) ---
	BodyCreationSettings_SetAngularVelocity              :: proc(settings: ^BodyCreationSettings, velocity: ^Vec3) ---
	BodyCreationSettings_GetUserData                     :: proc(settings: ^BodyCreationSettings) -> u64 ---
	BodyCreationSettings_SetUserData                     :: proc(settings: ^BodyCreationSettings, value: u64) ---
	BodyCreationSettings_GetObjectLayer                  :: proc(settings: ^BodyCreationSettings) -> ObjectLayer ---
	BodyCreationSettings_SetObjectLayer                  :: proc(settings: ^BodyCreationSettings, value: ObjectLayer) ---
	BodyCreationSettings_GetCollisionGroup               :: proc(settings: ^BodyCreationSettings, result: ^CollisionGroup) ---
	BodyCreationSettings_SetCollisionGroup               :: proc(settings: ^BodyCreationSettings, value: ^CollisionGroup) ---
	BodyCreationSettings_GetMotionType                   :: proc(settings: ^BodyCreationSettings) -> MotionType ---
	BodyCreationSettings_SetMotionType                   :: proc(settings: ^BodyCreationSettings, value: MotionType) ---
	BodyCreationSettings_GetAllowedDOFs                  :: proc(settings: ^BodyCreationSettings) -> AllowedDOFs ---
	BodyCreationSettings_SetAllowedDOFs                  :: proc(settings: ^BodyCreationSettings, value: AllowedDOFs) ---
	BodyCreationSettings_GetAllowDynamicOrKinematic      :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetAllowDynamicOrKinematic      :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetIsSensor                     :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetIsSensor                     :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetCollideKinematicVsNonDynamic :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetCollideKinematicVsNonDynamic :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetUseManifoldReduction         :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetUseManifoldReduction         :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetApplyGyroscopicForce         :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetApplyGyroscopicForce         :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetMotionQuality                :: proc(settings: ^BodyCreationSettings) -> MotionQuality ---
	BodyCreationSettings_SetMotionQuality                :: proc(settings: ^BodyCreationSettings, value: MotionQuality) ---
	BodyCreationSettings_GetEnhancedInternalEdgeRemoval  :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetEnhancedInternalEdgeRemoval  :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetAllowSleeping                :: proc(settings: ^BodyCreationSettings) -> bool ---
	BodyCreationSettings_SetAllowSleeping                :: proc(settings: ^BodyCreationSettings, value: bool) ---
	BodyCreationSettings_GetFriction                     :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetFriction                     :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetRestitution                  :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetRestitution                  :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetLinearDamping                :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetLinearDamping                :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetAngularDamping               :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetAngularDamping               :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetMaxLinearVelocity            :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetMaxLinearVelocity            :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetMaxAngularVelocity           :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetMaxAngularVelocity           :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetGravityFactor                :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetGravityFactor                :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetNumVelocityStepsOverride     :: proc(settings: ^BodyCreationSettings) -> u32 ---
	BodyCreationSettings_SetNumVelocityStepsOverride     :: proc(settings: ^BodyCreationSettings, value: u32) ---
	BodyCreationSettings_GetNumPositionStepsOverride     :: proc(settings: ^BodyCreationSettings) -> u32 ---
	BodyCreationSettings_SetNumPositionStepsOverride     :: proc(settings: ^BodyCreationSettings, value: u32) ---
	BodyCreationSettings_GetOverrideMassProperties       :: proc(settings: ^BodyCreationSettings) -> OverrideMassProperties ---
	BodyCreationSettings_SetOverrideMassProperties       :: proc(settings: ^BodyCreationSettings, value: OverrideMassProperties) ---
	BodyCreationSettings_GetInertiaMultiplier            :: proc(settings: ^BodyCreationSettings) -> f32 ---
	BodyCreationSettings_SetInertiaMultiplier            :: proc(settings: ^BodyCreationSettings, value: f32) ---
	BodyCreationSettings_GetMassPropertiesOverride       :: proc(settings: ^BodyCreationSettings, result: ^MassProperties) ---
	BodyCreationSettings_SetMassPropertiesOverride       :: proc(settings: ^BodyCreationSettings, massProperties: ^MassProperties) ---

	/* JPH_SoftBodyCreationSettings */
	SoftBodyCreationSettings_Create  :: proc() -> ^SoftBodyCreationSettings ---
	SoftBodyCreationSettings_Destroy :: proc(settings: ^SoftBodyCreationSettings) ---

	/* JPH_Constraint */
	Constraint_Destroy                     :: proc(constraint: ^Constraint) ---
	Constraint_GetType                     :: proc(constraint: ^Constraint) -> ConstraintType ---
	Constraint_GetSubType                  :: proc(constraint: ^Constraint) -> ConstraintSubType ---
	Constraint_GetConstraintPriority       :: proc(constraint: ^Constraint) -> u32 ---
	Constraint_SetConstraintPriority       :: proc(constraint: ^Constraint, priority: u32) ---
	Constraint_GetNumVelocityStepsOverride :: proc(constraint: ^Constraint) -> u32 ---
	Constraint_SetNumVelocityStepsOverride :: proc(constraint: ^Constraint, value: u32) ---
	Constraint_GetNumPositionStepsOverride :: proc(constraint: ^Constraint) -> u32 ---
	Constraint_SetNumPositionStepsOverride :: proc(constraint: ^Constraint, value: u32) ---
	Constraint_GetEnabled                  :: proc(constraint: ^Constraint) -> bool ---
	Constraint_SetEnabled                  :: proc(constraint: ^Constraint, enabled: bool) ---
	Constraint_GetUserData                 :: proc(constraint: ^Constraint) -> u64 ---
	Constraint_SetUserData                 :: proc(constraint: ^Constraint, userData: u64) ---
	Constraint_NotifyShapeChanged          :: proc(constraint: ^Constraint, bodyID: BodyID, deltaCOM: ^Vec3) ---
	Constraint_ResetWarmStart              :: proc(constraint: ^Constraint) ---
	Constraint_IsActive                    :: proc(constraint: ^Constraint) -> bool ---
	Constraint_SetupVelocityConstraint     :: proc(constraint: ^Constraint, deltaTime: f32) ---
	Constraint_WarmStartVelocityConstraint :: proc(constraint: ^Constraint, warmStartImpulseRatio: f32) ---
	Constraint_SolveVelocityConstraint     :: proc(constraint: ^Constraint, deltaTime: f32) -> bool ---
	Constraint_SolvePositionConstraint     :: proc(constraint: ^Constraint, deltaTime: f32, baumgarte: f32) -> bool ---

	/* JPH_TwoBodyConstraint */
	TwoBodyConstraint_GetBody1                   :: proc(constraint: ^TwoBodyConstraint) -> ^Body ---
	TwoBodyConstraint_GetBody2                   :: proc(constraint: ^TwoBodyConstraint) -> ^Body ---
	TwoBodyConstraint_GetConstraintToBody1Matrix :: proc(constraint: ^TwoBodyConstraint, result: ^Mat4) ---
	TwoBodyConstraint_GetConstraintToBody2Matrix :: proc(constraint: ^TwoBodyConstraint, result: ^Mat4) ---

	/* JPH_FixedConstraint */
	FixedConstraintSettings_Init           :: proc(settings: ^FixedConstraintSettings) ---
	FixedConstraint_Create                 :: proc(settings: ^FixedConstraintSettings, body1: ^Body, body2: ^Body) -> ^FixedConstraint ---
	FixedConstraint_GetSettings            :: proc(constraint: ^FixedConstraint, settings: ^FixedConstraintSettings) ---
	FixedConstraint_GetTotalLambdaPosition :: proc(constraint: ^FixedConstraint, result: ^Vec3) ---
	FixedConstraint_GetTotalLambdaRotation :: proc(constraint: ^FixedConstraint, result: ^Vec3) ---

	/* JPH_DistanceConstraint */
	DistanceConstraintSettings_Init            :: proc(settings: ^DistanceConstraintSettings) ---
	DistanceConstraint_Create                  :: proc(settings: ^DistanceConstraintSettings, body1: ^Body, body2: ^Body) -> ^DistanceConstraint ---
	DistanceConstraint_GetSettings             :: proc(constraint: ^DistanceConstraint, settings: ^DistanceConstraintSettings) ---
	DistanceConstraint_SetDistance             :: proc(constraint: ^DistanceConstraint, minDistance: f32, maxDistance: f32) ---
	DistanceConstraint_GetMinDistance          :: proc(constraint: ^DistanceConstraint) -> f32 ---
	DistanceConstraint_GetMaxDistance          :: proc(constraint: ^DistanceConstraint) -> f32 ---
	DistanceConstraint_GetLimitsSpringSettings :: proc(constraint: ^DistanceConstraint, result: ^SpringSettings) ---
	DistanceConstraint_SetLimitsSpringSettings :: proc(constraint: ^DistanceConstraint, settings: ^SpringSettings) ---
	DistanceConstraint_GetTotalLambdaPosition  :: proc(constraint: ^DistanceConstraint) -> f32 ---

	/* JPH_PointConstraint */
	PointConstraintSettings_Init           :: proc(settings: ^PointConstraintSettings) ---
	PointConstraint_Create                 :: proc(settings: ^PointConstraintSettings, body1: ^Body, body2: ^Body) -> ^PointConstraint ---
	PointConstraint_GetSettings            :: proc(constraint: ^PointConstraint, settings: ^PointConstraintSettings) ---
	PointConstraint_SetPoint1              :: proc(constraint: ^PointConstraint, space: ConstraintSpace, value: ^RVec3) ---
	PointConstraint_SetPoint2              :: proc(constraint: ^PointConstraint, space: ConstraintSpace, value: ^RVec3) ---
	PointConstraint_GetLocalSpacePoint1    :: proc(constraint: ^PointConstraint, result: ^Vec3) ---
	PointConstraint_GetLocalSpacePoint2    :: proc(constraint: ^PointConstraint, result: ^Vec3) ---
	PointConstraint_GetTotalLambdaPosition :: proc(constraint: ^PointConstraint, result: ^Vec3) ---

	/* JPH_HingeConstraint */
	HingeConstraintSettings_Init                 :: proc(settings: ^HingeConstraintSettings) ---
	HingeConstraint_Create                       :: proc(settings: ^HingeConstraintSettings, body1: ^Body, body2: ^Body) -> ^HingeConstraint ---
	HingeConstraint_GetSettings                  :: proc(constraint: ^HingeConstraint, settings: ^HingeConstraintSettings) ---
	HingeConstraint_GetLocalSpacePoint1          :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetLocalSpacePoint2          :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetLocalSpaceHingeAxis1      :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetLocalSpaceHingeAxis2      :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetLocalSpaceNormalAxis1     :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetLocalSpaceNormalAxis2     :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetCurrentAngle              :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_SetMaxFrictionTorque         :: proc(constraint: ^HingeConstraint, frictionTorque: f32) ---
	HingeConstraint_GetMaxFrictionTorque         :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_SetMotorSettings             :: proc(constraint: ^HingeConstraint, settings: ^MotorSettings) ---
	HingeConstraint_GetMotorSettings             :: proc(constraint: ^HingeConstraint, result: ^MotorSettings) ---
	HingeConstraint_SetMotorState                :: proc(constraint: ^HingeConstraint, state: MotorState) ---
	HingeConstraint_GetMotorState                :: proc(constraint: ^HingeConstraint) -> MotorState ---
	HingeConstraint_SetTargetAngularVelocity     :: proc(constraint: ^HingeConstraint, angularVelocity: f32) ---
	HingeConstraint_GetTargetAngularVelocity     :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_SetTargetAngle               :: proc(constraint: ^HingeConstraint, angle: f32) ---
	HingeConstraint_GetTargetAngle               :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_SetLimits                    :: proc(constraint: ^HingeConstraint, inLimitsMin: f32, inLimitsMax: f32) ---
	HingeConstraint_GetLimitsMin                 :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_GetLimitsMax                 :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_HasLimits                    :: proc(constraint: ^HingeConstraint) -> bool ---
	HingeConstraint_GetLimitsSpringSettings      :: proc(constraint: ^HingeConstraint, result: ^SpringSettings) ---
	HingeConstraint_SetLimitsSpringSettings      :: proc(constraint: ^HingeConstraint, settings: ^SpringSettings) ---
	HingeConstraint_GetTotalLambdaPosition       :: proc(constraint: ^HingeConstraint, result: ^Vec3) ---
	HingeConstraint_GetTotalLambdaRotation       :: proc(constraint: ^HingeConstraint, rotation: [2]f32) ---
	HingeConstraint_GetTotalLambdaRotationLimits :: proc(constraint: ^HingeConstraint) -> f32 ---
	HingeConstraint_GetTotalLambdaMotor          :: proc(constraint: ^HingeConstraint) -> f32 ---

	/* JPH_SliderConstraint */
	SliderConstraintSettings_Init                 :: proc(settings: ^SliderConstraintSettings) ---
	SliderConstraintSettings_SetSliderAxis        :: proc(settings: ^SliderConstraintSettings, axis: ^Vec3) ---
	SliderConstraint_Create                       :: proc(settings: ^SliderConstraintSettings, body1: ^Body, body2: ^Body) -> ^SliderConstraint ---
	SliderConstraint_GetSettings                  :: proc(constraint: ^SliderConstraint, settings: ^SliderConstraintSettings) ---
	SliderConstraint_GetCurrentPosition           :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_SetMaxFrictionForce          :: proc(constraint: ^SliderConstraint, frictionForce: f32) ---
	SliderConstraint_GetMaxFrictionForce          :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_SetMotorSettings             :: proc(constraint: ^SliderConstraint, settings: ^MotorSettings) ---
	SliderConstraint_GetMotorSettings             :: proc(constraint: ^SliderConstraint, result: ^MotorSettings) ---
	SliderConstraint_SetMotorState                :: proc(constraint: ^SliderConstraint, state: MotorState) ---
	SliderConstraint_GetMotorState                :: proc(constraint: ^SliderConstraint) -> MotorState ---
	SliderConstraint_SetTargetVelocity            :: proc(constraint: ^SliderConstraint, velocity: f32) ---
	SliderConstraint_GetTargetVelocity            :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_SetTargetPosition            :: proc(constraint: ^SliderConstraint, position: f32) ---
	SliderConstraint_GetTargetPosition            :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_SetLimits                    :: proc(constraint: ^SliderConstraint, inLimitsMin: f32, inLimitsMax: f32) ---
	SliderConstraint_GetLimitsMin                 :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_GetLimitsMax                 :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_HasLimits                    :: proc(constraint: ^SliderConstraint) -> bool ---
	SliderConstraint_GetLimitsSpringSettings      :: proc(constraint: ^SliderConstraint, result: ^SpringSettings) ---
	SliderConstraint_SetLimitsSpringSettings      :: proc(constraint: ^SliderConstraint, settings: ^SpringSettings) ---
	SliderConstraint_GetTotalLambdaPosition       :: proc(constraint: ^SliderConstraint, position: [2]f32) ---
	SliderConstraint_GetTotalLambdaPositionLimits :: proc(constraint: ^SliderConstraint) -> f32 ---
	SliderConstraint_GetTotalLambdaRotation       :: proc(constraint: ^SliderConstraint, result: ^Vec3) ---
	SliderConstraint_GetTotalLambdaMotor          :: proc(constraint: ^SliderConstraint) -> f32 ---

	/* JPH_ConeConstraint */
	ConeConstraintSettings_Init           :: proc(settings: ^ConeConstraintSettings) ---
	ConeConstraint_Create                 :: proc(settings: ^ConeConstraintSettings, body1: ^Body, body2: ^Body) -> ^ConeConstraint ---
	ConeConstraint_GetSettings            :: proc(constraint: ^ConeConstraint, settings: ^ConeConstraintSettings) ---
	ConeConstraint_SetHalfConeAngle       :: proc(constraint: ^ConeConstraint, halfConeAngle: f32) ---
	ConeConstraint_GetCosHalfConeAngle    :: proc(constraint: ^ConeConstraint) -> f32 ---
	ConeConstraint_GetTotalLambdaPosition :: proc(constraint: ^ConeConstraint, result: ^Vec3) ---
	ConeConstraint_GetTotalLambdaRotation :: proc(constraint: ^ConeConstraint) -> f32 ---

	/* JPH_SwingTwistConstraint */
	SwingTwistConstraintSettings_Init           :: proc(settings: ^SwingTwistConstraintSettings) ---
	SwingTwistConstraint_Create                 :: proc(settings: ^SwingTwistConstraintSettings, body1: ^Body, body2: ^Body) -> ^SwingTwistConstraint ---
	SwingTwistConstraint_GetSettings            :: proc(constraint: ^SwingTwistConstraint, settings: ^SwingTwistConstraintSettings) ---
	SwingTwistConstraint_GetNormalHalfConeAngle :: proc(constraint: ^SwingTwistConstraint) -> f32 ---
	SwingTwistConstraint_GetTotalLambdaPosition :: proc(constraint: ^SwingTwistConstraint, result: ^Vec3) ---
	SwingTwistConstraint_GetTotalLambdaTwist    :: proc(constraint: ^SwingTwistConstraint) -> f32 ---
	SwingTwistConstraint_GetTotalLambdaSwingY   :: proc(constraint: ^SwingTwistConstraint) -> f32 ---
	SwingTwistConstraint_GetTotalLambdaSwingZ   :: proc(constraint: ^SwingTwistConstraint) -> f32 ---
	SwingTwistConstraint_GetTotalLambdaMotor    :: proc(constraint: ^SwingTwistConstraint, result: ^Vec3) ---

	/* JPH_SixDOFConstraint */
	SixDOFConstraintSettings_Init                   :: proc(settings: ^SixDOFConstraintSettings) ---
	SixDOFConstraintSettings_MakeFreeAxis           :: proc(settings: ^SixDOFConstraintSettings, axis: SixDOFConstraintAxis) ---
	SixDOFConstraintSettings_IsFreeAxis             :: proc(settings: ^SixDOFConstraintSettings, axis: SixDOFConstraintAxis) -> bool ---
	SixDOFConstraintSettings_MakeFixedAxis          :: proc(settings: ^SixDOFConstraintSettings, axis: SixDOFConstraintAxis) ---
	SixDOFConstraintSettings_IsFixedAxis            :: proc(settings: ^SixDOFConstraintSettings, axis: SixDOFConstraintAxis) -> bool ---
	SixDOFConstraintSettings_SetLimitedAxis         :: proc(settings: ^SixDOFConstraintSettings, axis: SixDOFConstraintAxis, min: f32, max: f32) ---
	SixDOFConstraint_Create                         :: proc(settings: ^SixDOFConstraintSettings, body1: ^Body, body2: ^Body) -> ^SixDOFConstraint ---
	SixDOFConstraint_GetSettings                    :: proc(constraint: ^SixDOFConstraint, settings: ^SixDOFConstraintSettings) ---
	SixDOFConstraint_GetLimitsMin                   :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis) -> f32 ---
	SixDOFConstraint_GetLimitsMax                   :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis) -> f32 ---
	SixDOFConstraint_GetTotalLambdaPosition         :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetTotalLambdaRotation         :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetTotalLambdaMotorTranslation :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetTotalLambdaMotorRotation    :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetTranslationLimitsMin        :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetTranslationLimitsMax        :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetRotationLimitsMin           :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_GetRotationLimitsMax           :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_IsFixedAxis                    :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis) -> bool ---
	SixDOFConstraint_IsFreeAxis                     :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis) -> bool ---
	SixDOFConstraint_GetLimitsSpringSettings        :: proc(constraint: ^SixDOFConstraint, result: ^SpringSettings, axis: SixDOFConstraintAxis) ---
	SixDOFConstraint_SetLimitsSpringSettings        :: proc(constraint: ^SixDOFConstraint, settings: ^SpringSettings, axis: SixDOFConstraintAxis) ---
	SixDOFConstraint_SetMaxFriction                 :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis, inFriction: f32) ---
	SixDOFConstraint_GetMaxFriction                 :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis) -> f32 ---
	SixDOFConstraint_GetRotationInConstraintSpace   :: proc(constraint: ^SixDOFConstraint, result: ^Quat) ---
	SixDOFConstraint_GetMotorSettings               :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis, settings: ^MotorSettings) ---
	SixDOFConstraint_SetMotorState                  :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis, state: MotorState) ---
	SixDOFConstraint_GetMotorState                  :: proc(constraint: ^SixDOFConstraint, axis: SixDOFConstraintAxis) -> MotorState ---
	SixDOFConstraint_SetTargetVelocityCS            :: proc(constraint: ^SixDOFConstraint, inVelocity: ^Vec3) ---
	SixDOFConstraint_GetTargetVelocityCS            :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_SetTargetAngularVelocityCS     :: proc(constraint: ^SixDOFConstraint, inAngularVelocity: ^Vec3) ---
	SixDOFConstraint_GetTargetAngularVelocityCS     :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_SetTargetPositionCS            :: proc(constraint: ^SixDOFConstraint, inPosition: ^Vec3) ---
	SixDOFConstraint_GetTargetPositionCS            :: proc(constraint: ^SixDOFConstraint, result: ^Vec3) ---
	SixDOFConstraint_SetTargetOrientationCS         :: proc(constraint: ^SixDOFConstraint, inOrientation: ^Quat) ---
	SixDOFConstraint_GetTargetOrientationCS         :: proc(constraint: ^SixDOFConstraint, result: ^Quat) ---
	SixDOFConstraint_SetTargetOrientationBS         :: proc(constraint: ^SixDOFConstraint, inOrientation: ^Quat) ---

	/* JPH_GearConstraint */
	GearConstraintSettings_Init   :: proc(settings: ^GearConstraintSettings) ---
	GearConstraint_Create         :: proc(settings: ^GearConstraintSettings, body1: ^Body, body2: ^Body) -> ^GearConstraint ---
	GearConstraint_GetSettings    :: proc(constraint: ^GearConstraint, settings: ^GearConstraintSettings) ---
	GearConstraint_SetConstraints :: proc(constraint: ^GearConstraint, gear1: ^Constraint, gear2: ^Constraint) ---
	GearConstraint_GetTotalLambda :: proc(constraint: ^GearConstraint) -> f32 ---

	/* BodyInterface */
	BodyInterface_DestroyBody                       :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) ---
	BodyInterface_CreateAndAddBody                  :: proc(bodyInterface: ^BodyInterface, settings: ^BodyCreationSettings, activationMode: Activation) -> BodyID ---
	BodyInterface_CreateBody                        :: proc(bodyInterface: ^BodyInterface, settings: ^BodyCreationSettings) -> ^Body ---
	BodyInterface_CreateBodyWithID                  :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, settings: ^BodyCreationSettings) -> ^Body ---
	BodyInterface_CreateBodyWithoutID               :: proc(bodyInterface: ^BodyInterface, settings: ^BodyCreationSettings) -> ^Body ---
	BodyInterface_DestroyBodyWithoutID              :: proc(bodyInterface: ^BodyInterface, body: ^Body) ---
	BodyInterface_AssignBodyID                      :: proc(bodyInterface: ^BodyInterface, body: ^Body) -> bool ---
	BodyInterface_AssignBodyID2                     :: proc(bodyInterface: ^BodyInterface, body: ^Body, bodyID: BodyID) -> bool ---
	BodyInterface_UnassignBodyID                    :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> ^Body ---
	BodyInterface_CreateSoftBody                    :: proc(bodyInterface: ^BodyInterface, settings: ^SoftBodyCreationSettings) -> ^Body ---
	BodyInterface_CreateSoftBodyWithID              :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, settings: ^SoftBodyCreationSettings) -> ^Body ---
	BodyInterface_CreateSoftBodyWithoutID           :: proc(bodyInterface: ^BodyInterface, settings: ^SoftBodyCreationSettings) -> ^Body ---
	BodyInterface_CreateAndAddSoftBody              :: proc(bodyInterface: ^BodyInterface, settings: ^SoftBodyCreationSettings, activationMode: Activation) -> BodyID ---
	BodyInterface_AddBody                           :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, activationMode: Activation) ---
	BodyInterface_RemoveBody                        :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) ---
	BodyInterface_RemoveAndDestroyBody              :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) ---
	BodyInterface_IsAdded                           :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> bool ---
	BodyInterface_GetBodyType                       :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> BodyType ---
	BodyInterface_SetLinearVelocity                 :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, velocity: ^Vec3) ---
	BodyInterface_GetLinearVelocity                 :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, velocity: ^Vec3) ---
	BodyInterface_GetCenterOfMassPosition           :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, position: ^RVec3) ---
	BodyInterface_GetMotionType                     :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> MotionType ---
	BodyInterface_SetMotionType                     :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, motionType: MotionType, activationMode: Activation) ---
	BodyInterface_GetRestitution                    :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> f32 ---
	BodyInterface_SetRestitution                    :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, restitution: f32) ---
	BodyInterface_GetFriction                       :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> f32 ---
	BodyInterface_SetFriction                       :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID, friction: f32) ---
	BodyInterface_SetPosition                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, position: ^RVec3, activationMode: Activation) ---
	BodyInterface_GetPosition                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, result: ^RVec3) ---
	BodyInterface_SetRotation                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, rotation: ^Quat, activationMode: Activation) ---
	BodyInterface_GetRotation                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, result: ^Quat) ---
	BodyInterface_SetPositionAndRotation            :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, position: ^RVec3, rotation: ^Quat, activationMode: Activation) ---
	BodyInterface_SetPositionAndRotationWhenChanged :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, position: ^RVec3, rotation: ^Quat, activationMode: Activation) ---
	BodyInterface_GetPositionAndRotation            :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, position: ^RVec3, rotation: ^Quat) ---
	BodyInterface_SetPositionRotationAndVelocity    :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, position: ^RVec3, rotation: ^Quat, linearVelocity: ^Vec3, angularVelocity: ^Vec3) ---
	BodyInterface_GetCollisionGroup                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, result: ^CollisionGroup) ---
	BodyInterface_SetCollisionGroup                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, group: ^CollisionGroup) ---
	BodyInterface_GetShape                          :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> ^Shape ---
	BodyInterface_SetShape                          :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, shape: ^Shape, updateMassProperties: bool, activationMode: Activation) ---
	BodyInterface_NotifyShapeChanged                :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, previousCenterOfMass: ^Vec3, updateMassProperties: bool, activationMode: Activation) ---
	BodyInterface_ActivateBody                      :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) ---
	BodyInterface_ActivateBodies                    :: proc(bodyInterface: ^BodyInterface, bodyIDs: ^BodyID, count: u32) ---
	BodyInterface_ActivateBodiesInAABox             :: proc(bodyInterface: ^BodyInterface, box: ^AABox, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter) ---
	BodyInterface_DeactivateBody                    :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) ---
	BodyInterface_DeactivateBodies                  :: proc(bodyInterface: ^BodyInterface, bodyIDs: ^BodyID, count: u32) ---
	BodyInterface_IsActive                          :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) -> bool ---
	BodyInterface_ResetSleepTimer                   :: proc(bodyInterface: ^BodyInterface, bodyID: BodyID) ---
	BodyInterface_GetObjectLayer                    :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> ObjectLayer ---
	BodyInterface_SetObjectLayer                    :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, layer: ObjectLayer) ---
	BodyInterface_GetWorldTransform                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, result: ^RMat4) ---
	BodyInterface_GetCenterOfMassTransform          :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, result: ^RMat4) ---
	BodyInterface_MoveKinematic                     :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, targetPosition: ^RVec3, targetRotation: ^Quat, deltaTime: f32) ---
	BodyInterface_ApplyBuoyancyImpulse              :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, surfacePosition: ^RVec3, surfaceNormal: ^Vec3, buoyancy: f32, linearDrag: f32, angularDrag: f32, fluidVelocity: ^Vec3, gravity: ^Vec3, deltaTime: f32) -> bool ---
	BodyInterface_SetLinearAndAngularVelocity       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, linearVelocity: ^Vec3, angularVelocity: ^Vec3) ---
	BodyInterface_GetLinearAndAngularVelocity       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, linearVelocity: ^Vec3, angularVelocity: ^Vec3) ---
	BodyInterface_AddLinearVelocity                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, linearVelocity: ^Vec3) ---
	BodyInterface_AddLinearAndAngularVelocity       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, linearVelocity: ^Vec3, angularVelocity: ^Vec3) ---
	BodyInterface_SetAngularVelocity                :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, angularVelocity: ^Vec3) ---
	BodyInterface_GetAngularVelocity                :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, angularVelocity: ^Vec3) ---
	BodyInterface_GetPointVelocity                  :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, point: ^RVec3, velocity: ^Vec3) ---
	BodyInterface_AddForce                          :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, force: ^Vec3) ---
	BodyInterface_AddForce2                         :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, force: ^Vec3, point: ^RVec3) ---
	BodyInterface_AddTorque                         :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, torque: ^Vec3) ---
	BodyInterface_AddForceAndTorque                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, force: ^Vec3, torque: ^Vec3) ---
	BodyInterface_AddImpulse                        :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, impulse: ^Vec3) ---
	BodyInterface_AddImpulse2                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, impulse: ^Vec3, point: ^RVec3) ---
	BodyInterface_AddAngularImpulse                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, angularImpulse: ^Vec3) ---
	BodyInterface_SetMotionQuality                  :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, quality: MotionQuality) ---
	BodyInterface_GetMotionQuality                  :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> MotionQuality ---
	BodyInterface_GetInverseInertia                 :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, result: ^Mat4) ---
	BodyInterface_SetGravityFactor                  :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, value: f32) ---
	BodyInterface_GetGravityFactor                  :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> f32 ---
	BodyInterface_SetUseManifoldReduction           :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, value: bool) ---
	BodyInterface_GetUseManifoldReduction           :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> bool ---
	BodyInterface_SetUserData                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, inUserData: u64) ---
	BodyInterface_GetUserData                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> u64 ---
	BodyInterface_SetIsSensor                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, value: bool) ---
	BodyInterface_IsSensor                          :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) -> bool ---
	BodyInterface_GetMaterial                       :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID, subShapeID: SubShapeID) -> ^PhysicsMaterial ---
	BodyInterface_InvalidateContactCache            :: proc(bodyInterface: ^BodyInterface, bodyId: BodyID) ---

	//--------------------------------------------------------------------------------------------------
	// JPH_BodyLockInterface
	//--------------------------------------------------------------------------------------------------
	BodyLockInterface_LockRead       :: proc(lockInterface: ^BodyLockInterface, bodyID: BodyID, outLock: ^BodyLockRead) ---
	BodyLockInterface_UnlockRead     :: proc(lockInterface: ^BodyLockInterface, ioLock: ^BodyLockRead) ---
	BodyLockInterface_LockWrite      :: proc(lockInterface: ^BodyLockInterface, bodyID: BodyID, outLock: ^BodyLockWrite) ---
	BodyLockInterface_UnlockWrite    :: proc(lockInterface: ^BodyLockInterface, ioLock: ^BodyLockWrite) ---
	BodyLockInterface_LockMultiRead  :: proc(lockInterface: ^BodyLockInterface, bodyIDs: ^BodyID, count: u32) -> ^BodyLockMultiRead ---
	BodyLockMultiRead_Destroy        :: proc(ioLock: ^BodyLockMultiRead) ---
	BodyLockMultiRead_GetBody        :: proc(ioLock: ^BodyLockMultiRead, bodyIndex: u32) -> ^Body ---
	BodyLockInterface_LockMultiWrite :: proc(lockInterface: ^BodyLockInterface, bodyIDs: ^BodyID, count: u32) -> ^BodyLockMultiWrite ---
	BodyLockMultiWrite_Destroy       :: proc(ioLock: ^BodyLockMultiWrite) ---
	BodyLockMultiWrite_GetBody       :: proc(ioLock: ^BodyLockMultiWrite, bodyIndex: u32) -> ^Body ---

	//--------------------------------------------------------------------------------------------------
	// JPH_MotionProperties
	//--------------------------------------------------------------------------------------------------
	MotionProperties_GetAllowedDOFs            :: proc(properties: ^MotionProperties) -> AllowedDOFs ---
	MotionProperties_SetLinearDamping          :: proc(properties: ^MotionProperties, damping: f32) ---
	MotionProperties_GetLinearDamping          :: proc(properties: ^MotionProperties) -> f32 ---
	MotionProperties_SetAngularDamping         :: proc(properties: ^MotionProperties, damping: f32) ---
	MotionProperties_GetAngularDamping         :: proc(properties: ^MotionProperties) -> f32 ---
	MotionProperties_SetMassProperties         :: proc(properties: ^MotionProperties, allowedDOFs: AllowedDOFs, massProperties: ^MassProperties) ---
	MotionProperties_GetInverseMassUnchecked   :: proc(properties: ^MotionProperties) -> f32 ---
	MotionProperties_SetInverseMass            :: proc(properties: ^MotionProperties, inverseMass: f32) ---
	MotionProperties_GetInverseInertiaDiagonal :: proc(properties: ^MotionProperties, result: ^Vec3) ---
	MotionProperties_GetInertiaRotation        :: proc(properties: ^MotionProperties, result: ^Quat) ---
	MotionProperties_SetInverseInertia         :: proc(properties: ^MotionProperties, diagonal: ^Vec3, rot: ^Quat) ---
	MotionProperties_ScaleToMass               :: proc(properties: ^MotionProperties, mass: f32) ---

	//--------------------------------------------------------------------------------------------------
	// JPH_RayCast
	//--------------------------------------------------------------------------------------------------
	RayCast_GetPointOnRay  :: proc(origin: ^Vec3, direction: ^Vec3, fraction: f32, result: ^Vec3) ---
	RRayCast_GetPointOnRay :: proc(origin: ^RVec3, direction: ^Vec3, fraction: f32, result: ^RVec3) ---

	//--------------------------------------------------------------------------------------------------
	// JPH_MassProperties
	//--------------------------------------------------------------------------------------------------
	MassProperties_DecomposePrincipalMomentsOfInertia :: proc(properties: ^MassProperties, rotation: ^Mat4, diagonal: ^Vec3) ---
	MassProperties_ScaleToMass                        :: proc(properties: ^MassProperties, mass: f32) ---
	MassProperties_GetEquivalentSolidBoxSize          :: proc(mass: f32, inertiaDiagonal: ^Vec3, result: ^Vec3) ---

	//--------------------------------------------------------------------------------------------------
	// JPH_CollideShapeSettings
	//--------------------------------------------------------------------------------------------------
	CollideShapeSettings_Init :: proc(settings: ^CollideShapeSettings) ---

	//--------------------------------------------------------------------------------------------------
	// JPH_ShapeCastSettings
	//--------------------------------------------------------------------------------------------------
	ShapeCastSettings_Init :: proc(settings: ^ShapeCastSettings) ---

	//--------------------------------------------------------------------------------------------------
	// JPH_BroadPhaseQuery
	//--------------------------------------------------------------------------------------------------
	BroadPhaseQuery_CastRay       :: proc(query: ^BroadPhaseQuery, origin: ^Vec3, direction: ^Vec3, callback: RayCastBodyCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter) -> bool ---
	BroadPhaseQuery_CastRay2      :: proc(query: ^BroadPhaseQuery, origin: ^Vec3, direction: ^Vec3, collectorType: CollisionCollectorType, callback: RayCastBodyResultCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter) -> bool ---
	BroadPhaseQuery_CollideAABox  :: proc(query: ^BroadPhaseQuery, box: ^AABox, callback: CollideShapeBodyCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter) -> bool ---
	BroadPhaseQuery_CollideSphere :: proc(query: ^BroadPhaseQuery, center: ^Vec3, radius: f32, callback: CollideShapeBodyCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter) -> bool ---
	BroadPhaseQuery_CollidePoint  :: proc(query: ^BroadPhaseQuery, point: ^Vec3, callback: CollideShapeBodyCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter) -> bool ---

	//--------------------------------------------------------------------------------------------------
	// JPH_NarrowPhaseQuery
	//--------------------------------------------------------------------------------------------------
	NarrowPhaseQuery_CastRay       :: proc(query: ^NarrowPhaseQuery, origin: ^RVec3, direction: ^Vec3, hit: ^RayCastResult, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter) -> bool ---
	NarrowPhaseQuery_CastRay2      :: proc(query: ^NarrowPhaseQuery, origin: ^RVec3, direction: ^Vec3, rayCastSettings: ^RayCastSettings, callback: CastRayCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CastRay3      :: proc(query: ^NarrowPhaseQuery, origin: ^RVec3, direction: ^Vec3, rayCastSettings: ^RayCastSettings, collectorType: CollisionCollectorType, callback: CastRayResultCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CollidePoint  :: proc(query: ^NarrowPhaseQuery, point: ^RVec3, callback: CollidePointCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CollidePoint2 :: proc(query: ^NarrowPhaseQuery, point: ^RVec3, collectorType: CollisionCollectorType, callback: CollidePointResultCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CollideShape  :: proc(query: ^NarrowPhaseQuery, shape: ^Shape, scale: ^Vec3, centerOfMassTransform: ^RMat4, settings: ^CollideShapeSettings, baseOffset: ^RVec3, callback: CollideShapeCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CollideShape2 :: proc(query: ^NarrowPhaseQuery, shape: ^Shape, scale: ^Vec3, centerOfMassTransform: ^RMat4, settings: ^CollideShapeSettings, baseOffset: ^RVec3, collectorType: CollisionCollectorType, callback: CollideShapeResultCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CastShape     :: proc(query: ^NarrowPhaseQuery, shape: ^Shape, worldTransform: ^RMat4, direction: ^Vec3, settings: ^ShapeCastSettings, baseOffset: ^RVec3, callback: CastShapeCollectorCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	NarrowPhaseQuery_CastShape2    :: proc(query: ^NarrowPhaseQuery, shape: ^Shape, worldTransform: ^RMat4, direction: ^Vec3, settings: ^ShapeCastSettings, baseOffset: ^RVec3, collectorType: CollisionCollectorType, callback: CastShapeResultCallback, userData: rawptr, broadPhaseLayerFilter: ^BroadPhaseLayerFilter, objectLayerFilter: ^ObjectLayerFilter, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---

	//--------------------------------------------------------------------------------------------------
	// JPH_Body
	//--------------------------------------------------------------------------------------------------
	Body_GetID                                  :: proc(body: ^Body) -> BodyID ---
	Body_GetBodyType                            :: proc(body: ^Body) -> BodyType ---
	Body_IsRigidBody                            :: proc(body: ^Body) -> bool ---
	Body_IsSoftBody                             :: proc(body: ^Body) -> bool ---
	Body_IsActive                               :: proc(body: ^Body) -> bool ---
	Body_IsStatic                               :: proc(body: ^Body) -> bool ---
	Body_IsKinematic                            :: proc(body: ^Body) -> bool ---
	Body_IsDynamic                              :: proc(body: ^Body) -> bool ---
	Body_CanBeKinematicOrDynamic                :: proc(body: ^Body) -> bool ---
	Body_SetIsSensor                            :: proc(body: ^Body, value: bool) ---
	Body_IsSensor                               :: proc(body: ^Body) -> bool ---
	Body_SetCollideKinematicVsNonDynamic        :: proc(body: ^Body, value: bool) ---
	Body_GetCollideKinematicVsNonDynamic        :: proc(body: ^Body) -> bool ---
	Body_SetUseManifoldReduction                :: proc(body: ^Body, value: bool) ---
	Body_GetUseManifoldReduction                :: proc(body: ^Body) -> bool ---
	Body_GetUseManifoldReductionWithBody        :: proc(body: ^Body, other: ^Body) -> bool ---
	Body_SetApplyGyroscopicForce                :: proc(body: ^Body, value: bool) ---
	Body_GetApplyGyroscopicForce                :: proc(body: ^Body) -> bool ---
	Body_SetEnhancedInternalEdgeRemoval         :: proc(body: ^Body, value: bool) ---
	Body_GetEnhancedInternalEdgeRemoval         :: proc(body: ^Body) -> bool ---
	Body_GetEnhancedInternalEdgeRemovalWithBody :: proc(body: ^Body, other: ^Body) -> bool ---
	Body_GetMotionType                          :: proc(body: ^Body) -> MotionType ---
	Body_SetMotionType                          :: proc(body: ^Body, motionType: MotionType) ---
	Body_GetBroadPhaseLayer                     :: proc(body: ^Body) -> BroadPhaseLayer ---
	Body_GetObjectLayer                         :: proc(body: ^Body) -> ObjectLayer ---
	Body_GetCollisionGroup                      :: proc(body: ^Body, result: ^CollisionGroup) ---
	Body_SetCollisionGroup                      :: proc(body: ^Body, value: ^CollisionGroup) ---
	Body_GetAllowSleeping                       :: proc(body: ^Body) -> bool ---
	Body_SetAllowSleeping                       :: proc(body: ^Body, allowSleeping: bool) ---
	Body_ResetSleepTimer                        :: proc(body: ^Body) ---
	Body_GetFriction                            :: proc(body: ^Body) -> f32 ---
	Body_SetFriction                            :: proc(body: ^Body, friction: f32) ---
	Body_GetRestitution                         :: proc(body: ^Body) -> f32 ---
	Body_SetRestitution                         :: proc(body: ^Body, restitution: f32) ---
	Body_GetLinearVelocity                      :: proc(body: ^Body, velocity: ^Vec3) ---
	Body_SetLinearVelocity                      :: proc(body: ^Body, velocity: ^Vec3) ---
	Body_SetLinearVelocityClamped               :: proc(body: ^Body, velocity: ^Vec3) ---
	Body_GetAngularVelocity                     :: proc(body: ^Body, velocity: ^Vec3) ---
	Body_SetAngularVelocity                     :: proc(body: ^Body, velocity: ^Vec3) ---
	Body_SetAngularVelocityClamped              :: proc(body: ^Body, velocity: ^Vec3) ---
	Body_GetPointVelocityCOM                    :: proc(body: ^Body, pointRelativeToCOM: ^Vec3, velocity: ^Vec3) ---
	Body_GetPointVelocity                       :: proc(body: ^Body, point: ^RVec3, velocity: ^Vec3) ---
	Body_AddForce                               :: proc(body: ^Body, force: ^Vec3) ---
	Body_AddForceAtPosition                     :: proc(body: ^Body, force: ^Vec3, position: ^RVec3) ---
	Body_AddTorque                              :: proc(body: ^Body, force: ^Vec3) ---
	Body_GetAccumulatedForce                    :: proc(body: ^Body, force: ^Vec3) ---
	Body_GetAccumulatedTorque                   :: proc(body: ^Body, force: ^Vec3) ---
	Body_ResetForce                             :: proc(body: ^Body) ---
	Body_ResetTorque                            :: proc(body: ^Body) ---
	Body_ResetMotion                            :: proc(body: ^Body) ---
	Body_GetInverseInertia                      :: proc(body: ^Body, result: ^Mat4) ---
	Body_AddImpulse                             :: proc(body: ^Body, impulse: ^Vec3) ---
	Body_AddImpulseAtPosition                   :: proc(body: ^Body, impulse: ^Vec3, position: ^RVec3) ---
	Body_AddAngularImpulse                      :: proc(body: ^Body, angularImpulse: ^Vec3) ---
	Body_MoveKinematic                          :: proc(body: ^Body, targetPosition: ^RVec3, targetRotation: ^Quat, deltaTime: f32) ---
	Body_ApplyBuoyancyImpulse                   :: proc(body: ^Body, surfacePosition: ^RVec3, surfaceNormal: ^Vec3, buoyancy: f32, linearDrag: f32, angularDrag: f32, fluidVelocity: ^Vec3, gravity: ^Vec3, deltaTime: f32) -> bool ---
	Body_IsInBroadPhase                         :: proc(body: ^Body) -> bool ---
	Body_IsCollisionCacheInvalid                :: proc(body: ^Body) -> bool ---
	Body_GetShape                               :: proc(body: ^Body) -> ^Shape ---
	Body_GetPosition                            :: proc(body: ^Body, result: ^RVec3) ---
	Body_GetRotation                            :: proc(body: ^Body, result: ^Quat) ---
	Body_GetWorldTransform                      :: proc(body: ^Body, result: ^RMat4) ---
	Body_GetCenterOfMassPosition                :: proc(body: ^Body, result: ^RVec3) ---
	Body_GetCenterOfMassTransform               :: proc(body: ^Body, result: ^RMat4) ---
	Body_GetInverseCenterOfMassTransform        :: proc(body: ^Body, result: ^RMat4) ---
	Body_GetWorldSpaceBounds                    :: proc(body: ^Body, result: ^AABox) ---
	Body_GetWorldSpaceSurfaceNormal             :: proc(body: ^Body, subShapeID: SubShapeID, position: ^RVec3, normal: ^Vec3) ---
	Body_GetMotionProperties                    :: proc(body: ^Body) -> ^MotionProperties ---
	Body_GetMotionPropertiesUnchecked           :: proc(body: ^Body) -> ^MotionProperties ---
	Body_SetUserData                            :: proc(body: ^Body, userData: u64) ---
	Body_GetUserData                            :: proc(body: ^Body) -> u64 ---
	Body_GetFixedToWorldBody                    :: proc() -> ^Body ---
}

/* JPH_BroadPhaseLayerFilter_Procs */
BroadPhaseLayerFilter_Procs :: struct {
	ShouldCollide: proc "c" (userData: rawptr, layer: BroadPhaseLayer) -> bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	BroadPhaseLayerFilter_SetProcs :: proc(procs: ^BroadPhaseLayerFilter_Procs) ---
	BroadPhaseLayerFilter_Create   :: proc(userData: rawptr) -> ^BroadPhaseLayerFilter ---
	BroadPhaseLayerFilter_Destroy  :: proc(filter: ^BroadPhaseLayerFilter) ---
}

/* JPH_ObjectLayerFilter */
ObjectLayerFilter_Procs :: struct {
	ShouldCollide: proc "c" (userData: rawptr, layer: ObjectLayer) -> bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	ObjectLayerFilter_SetProcs :: proc(procs: ^ObjectLayerFilter_Procs) ---
	ObjectLayerFilter_Create   :: proc(userData: rawptr) -> ^ObjectLayerFilter ---
	ObjectLayerFilter_Destroy  :: proc(filter: ^ObjectLayerFilter) ---
}

/* JPH_BodyFilter */
BodyFilter_Procs :: struct {
	ShouldCollide:       proc "c" (userData: rawptr, bodyID: BodyID) -> bool,
	ShouldCollideLocked: proc "c" (userData: rawptr, bodyID: ^Body) -> bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	BodyFilter_SetProcs :: proc(procs: ^BodyFilter_Procs) ---
	BodyFilter_Create   :: proc(userData: rawptr) -> ^BodyFilter ---
	BodyFilter_Destroy  :: proc(filter: ^BodyFilter) ---
}

/* JPH_ShapeFilter */
ShapeFilter_Procs :: struct {
	ShouldCollide:  proc "c" (userData: rawptr, shape2: ^Shape, subShapeIDOfShape2: ^SubShapeID) -> bool,
	ShouldCollide2: proc "c" (userData: rawptr, shape1: ^Shape, subShapeIDOfShape1: ^SubShapeID, shape2: ^Shape, subShapeIDOfShape2: ^SubShapeID) -> bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	ShapeFilter_SetProcs   :: proc(procs: ^ShapeFilter_Procs) ---
	ShapeFilter_Create     :: proc(userData: rawptr) -> ^ShapeFilter ---
	ShapeFilter_Destroy    :: proc(filter: ^ShapeFilter) ---
	ShapeFilter_GetBodyID2 :: proc(filter: ^ShapeFilter) -> BodyID ---
	ShapeFilter_SetBodyID2 :: proc(filter: ^ShapeFilter, id: BodyID) ---
}

/* JPH_SimShapeFilter */
SimShapeFilter_Procs :: struct {
	ShouldCollide: proc "c" (userData: rawptr, body1: ^Body, shape1: ^Shape, subShapeIDOfShape1: ^SubShapeID, body2: ^Body, shape2: ^Shape, subShapeIDOfShape2: ^SubShapeID) -> bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	SimShapeFilter_SetProcs :: proc(procs: ^SimShapeFilter_Procs) ---
	SimShapeFilter_Create   :: proc(userData: rawptr) -> ^SimShapeFilter ---
	SimShapeFilter_Destroy  :: proc(filter: ^SimShapeFilter) ---
}

/* Contact listener */
ContactListener_Procs :: struct {
	OnContactValidate:  proc "c" (userData: rawptr, body1: ^Body, body2: ^Body, baseOffset: ^RVec3, collisionResult: ^CollideShapeResult) -> ValidateResult,
	OnContactAdded:     proc "c" (userData: rawptr, body1: ^Body, body2: ^Body, manifold: ^ContactManifold, settings: ^ContactSettings),
	OnContactPersisted: proc "c" (userData: rawptr, body1: ^Body, body2: ^Body, manifold: ^ContactManifold, settings: ^ContactSettings),
	OnContactRemoved:   proc "c" (userData: rawptr, subShapePair: ^SubShapeIDPair),
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	ContactListener_SetProcs :: proc(procs: ^ContactListener_Procs) ---
	ContactListener_Create   :: proc(userData: rawptr) -> ^ContactListener ---
	ContactListener_Destroy  :: proc(listener: ^ContactListener) ---
}

/* BodyActivationListener */
BodyActivationListener_Procs :: struct {
	OnBodyActivated:   proc "c" (userData: rawptr, bodyID: BodyID, bodyUserData: u64),
	OnBodyDeactivated: proc "c" (userData: rawptr, bodyID: BodyID, bodyUserData: u64),
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	BodyActivationListener_SetProcs :: proc(procs: ^BodyActivationListener_Procs) ---
	BodyActivationListener_Create   :: proc(userData: rawptr) -> ^BodyActivationListener ---
	BodyActivationListener_Destroy  :: proc(listener: ^BodyActivationListener) ---
}

/* JPH_BodyDrawFilter */
BodyDrawFilter_Procs :: struct {
	ShouldDraw: proc "c" (userData: rawptr, body: ^Body) -> bool,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	BodyDrawFilter_SetProcs :: proc(procs: ^BodyDrawFilter_Procs) ---
	BodyDrawFilter_Create   :: proc(userData: rawptr) -> ^BodyDrawFilter ---
	BodyDrawFilter_Destroy  :: proc(filter: ^BodyDrawFilter) ---

	/* ContactManifold */
	ContactManifold_GetWorldSpaceNormal          :: proc(manifold: ^ContactManifold, result: ^Vec3) ---
	ContactManifold_GetPenetrationDepth          :: proc(manifold: ^ContactManifold) -> f32 ---
	ContactManifold_GetSubShapeID1               :: proc(manifold: ^ContactManifold) -> SubShapeID ---
	ContactManifold_GetSubShapeID2               :: proc(manifold: ^ContactManifold) -> SubShapeID ---
	ContactManifold_GetPointCount                :: proc(manifold: ^ContactManifold) -> u32 ---
	ContactManifold_GetWorldSpaceContactPointOn1 :: proc(manifold: ^ContactManifold, index: u32, result: ^RVec3) ---
	ContactManifold_GetWorldSpaceContactPointOn2 :: proc(manifold: ^ContactManifold, index: u32, result: ^RVec3) ---

	/* CharacterBase */
	CharacterBase_Destroy             :: proc(character: ^CharacterBase) ---
	CharacterBase_GetCosMaxSlopeAngle :: proc(character: ^CharacterBase) -> f32 ---
	CharacterBase_SetMaxSlopeAngle    :: proc(character: ^CharacterBase, maxSlopeAngle: f32) ---
	CharacterBase_GetUp               :: proc(character: ^CharacterBase, result: ^Vec3) ---
	CharacterBase_SetUp               :: proc(character: ^CharacterBase, value: ^Vec3) ---
	CharacterBase_IsSlopeTooSteep     :: proc(character: ^CharacterBase, value: ^Vec3) -> bool ---
	CharacterBase_GetShape            :: proc(character: ^CharacterBase) -> ^Shape ---
	CharacterBase_GetGroundState      :: proc(character: ^CharacterBase) -> GroundState ---
	CharacterBase_IsSupported         :: proc(character: ^CharacterBase) -> bool ---
	CharacterBase_GetGroundPosition   :: proc(character: ^CharacterBase, position: ^RVec3) ---
	CharacterBase_GetGroundNormal     :: proc(character: ^CharacterBase, normal: ^Vec3) ---
	CharacterBase_GetGroundVelocity   :: proc(character: ^CharacterBase, velocity: ^Vec3) ---
	CharacterBase_GetGroundMaterial   :: proc(character: ^CharacterBase) -> ^PhysicsMaterial ---
	CharacterBase_GetGroundBodyId     :: proc(character: ^CharacterBase) -> BodyID ---
	CharacterBase_GetGroundSubShapeId :: proc(character: ^CharacterBase) -> SubShapeID ---
	CharacterBase_GetGroundUserData   :: proc(character: ^CharacterBase) -> u64 ---

	/* CharacterSettings */
	CharacterSettings_Init :: proc(settings: ^CharacterSettings) ---

	/* Character */
	Character_Create                      :: proc(settings: ^CharacterSettings, position: ^RVec3, rotation: ^Quat, userData: u64, system: ^PhysicsSystem) -> ^Character ---
	Character_AddToPhysicsSystem          :: proc(character: ^Character, activationMode: Activation, lockBodies: bool) --- /*= JPH_ActivationActivate */
	Character_RemoveFromPhysicsSystem     :: proc(character: ^Character, lockBodies: bool) --- /* = true */
	Character_Activate                    :: proc(character: ^Character, lockBodies: bool) --- /* = true */
	Character_PostSimulation              :: proc(character: ^Character, maxSeparationDistance: f32, lockBodies: bool) --- /* = true */
	Character_SetLinearAndAngularVelocity :: proc(character: ^Character, linearVelocity: ^Vec3, angularVelocity: ^Vec3, lockBodies: bool) --- /* = true */
	Character_GetLinearVelocity           :: proc(character: ^Character, result: ^Vec3) ---
	Character_SetLinearVelocity           :: proc(character: ^Character, value: ^Vec3, lockBodies: bool) --- /* = true */
	Character_AddLinearVelocity           :: proc(character: ^Character, value: ^Vec3, lockBodies: bool) --- /* = true */
	Character_AddImpulse                  :: proc(character: ^Character, value: ^Vec3, lockBodies: bool) --- /* = true */
	Character_GetBodyID                   :: proc(character: ^Character) -> BodyID ---
	Character_GetPositionAndRotation      :: proc(character: ^Character, position: ^RVec3, rotation: ^Quat, lockBodies: bool) --- /* = true */
	Character_SetPositionAndRotation      :: proc(character: ^Character, position: ^RVec3, rotation: ^Quat, activationMode: Activation, lockBodies: bool) --- /* = true */
	Character_GetPosition                 :: proc(character: ^Character, position: ^RVec3, lockBodies: bool) --- /* = true */
	Character_SetPosition                 :: proc(character: ^Character, position: ^RVec3, activationMode: Activation, lockBodies: bool) --- /* = true */
	Character_GetRotation                 :: proc(character: ^Character, rotation: ^Quat, lockBodies: bool) --- /* = true */
	Character_SetRotation                 :: proc(character: ^Character, rotation: ^Quat, activationMode: Activation, lockBodies: bool) --- /* = true */
	Character_GetCenterOfMassPosition     :: proc(character: ^Character, result: ^RVec3, lockBodies: bool) --- /* = true */
	Character_GetWorldTransform           :: proc(character: ^Character, result: ^RMat4, lockBodies: bool) --- /* = true */
	Character_GetLayer                    :: proc(character: ^Character) -> ObjectLayer ---
	Character_SetLayer                    :: proc(character: ^Character, value: ObjectLayer, lockBodies: bool) --- /*= true*/
	Character_SetShape                    :: proc(character: ^Character, shape: ^Shape, maxPenetrationDepth: f32, lockBodies: bool) --- /*= true*/

	/* CharacterVirtualSettings */
	CharacterVirtualSettings_Init :: proc(settings: ^CharacterVirtualSettings) ---

	/* CharacterVirtual */
	CharacterVirtual_Create                           :: proc(settings: ^CharacterVirtualSettings, position: ^RVec3, rotation: ^Quat, userData: u64, system: ^PhysicsSystem) -> ^CharacterVirtual ---
	CharacterVirtual_GetID                            :: proc(character: ^CharacterVirtual) -> CharacterID ---
	CharacterVirtual_SetListener                      :: proc(character: ^CharacterVirtual, listener: ^CharacterContactListener) ---
	CharacterVirtual_SetCharacterVsCharacterCollision :: proc(character: ^CharacterVirtual, characterVsCharacterCollision: ^CharacterVsCharacterCollision) ---
	CharacterVirtual_GetLinearVelocity                :: proc(character: ^CharacterVirtual, velocity: ^Vec3) ---
	CharacterVirtual_SetLinearVelocity                :: proc(character: ^CharacterVirtual, velocity: ^Vec3) ---
	CharacterVirtual_GetPosition                      :: proc(character: ^CharacterVirtual, position: ^RVec3) ---
	CharacterVirtual_SetPosition                      :: proc(character: ^CharacterVirtual, position: ^RVec3) ---
	CharacterVirtual_GetRotation                      :: proc(character: ^CharacterVirtual, rotation: ^Quat) ---
	CharacterVirtual_SetRotation                      :: proc(character: ^CharacterVirtual, rotation: ^Quat) ---
	CharacterVirtual_GetWorldTransform                :: proc(character: ^CharacterVirtual, result: ^RMat4) ---
	CharacterVirtual_GetCenterOfMassTransform         :: proc(character: ^CharacterVirtual, result: ^RMat4) ---
	CharacterVirtual_GetMass                          :: proc(character: ^CharacterVirtual) -> f32 ---
	CharacterVirtual_SetMass                          :: proc(character: ^CharacterVirtual, value: f32) ---
	CharacterVirtual_GetMaxStrength                   :: proc(character: ^CharacterVirtual) -> f32 ---
	CharacterVirtual_SetMaxStrength                   :: proc(character: ^CharacterVirtual, value: f32) ---
	CharacterVirtual_GetPenetrationRecoverySpeed      :: proc(character: ^CharacterVirtual) -> f32 ---
	CharacterVirtual_SetPenetrationRecoverySpeed      :: proc(character: ^CharacterVirtual, value: f32) ---
	CharacterVirtual_GetEnhancedInternalEdgeRemoval   :: proc(character: ^CharacterVirtual) -> bool ---
	CharacterVirtual_SetEnhancedInternalEdgeRemoval   :: proc(character: ^CharacterVirtual, value: bool) ---
	CharacterVirtual_GetCharacterPadding              :: proc(character: ^CharacterVirtual) -> f32 ---
	CharacterVirtual_GetMaxNumHits                    :: proc(character: ^CharacterVirtual) -> u32 ---
	CharacterVirtual_SetMaxNumHits                    :: proc(character: ^CharacterVirtual, value: u32) ---
	CharacterVirtual_GetHitReductionCosMaxAngle       :: proc(character: ^CharacterVirtual) -> f32 ---
	CharacterVirtual_SetHitReductionCosMaxAngle       :: proc(character: ^CharacterVirtual, value: f32) ---
	CharacterVirtual_GetMaxHitsExceeded               :: proc(character: ^CharacterVirtual) -> bool ---
	CharacterVirtual_GetShapeOffset                   :: proc(character: ^CharacterVirtual, result: ^Vec3) ---
	CharacterVirtual_SetShapeOffset                   :: proc(character: ^CharacterVirtual, value: ^Vec3) ---
	CharacterVirtual_GetUserData                      :: proc(character: ^CharacterVirtual) -> u64 ---
	CharacterVirtual_SetUserData                      :: proc(character: ^CharacterVirtual, value: u64) ---
	CharacterVirtual_GetInnerBodyID                   :: proc(character: ^CharacterVirtual) -> BodyID ---
	CharacterVirtual_CancelVelocityTowardsSteepSlopes :: proc(character: ^CharacterVirtual, desiredVelocity: ^Vec3, velocity: ^Vec3) ---
	CharacterVirtual_StartTrackingContactChanges      :: proc(character: ^CharacterVirtual) ---
	CharacterVirtual_FinishTrackingContactChanges     :: proc(character: ^CharacterVirtual) ---
	CharacterVirtual_Update                           :: proc(character: ^CharacterVirtual, deltaTime: f32, layer: ObjectLayer, system: ^PhysicsSystem, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) ---
	CharacterVirtual_ExtendedUpdate                   :: proc(character: ^CharacterVirtual, deltaTime: f32, settings: ^ExtendedUpdateSettings, layer: ObjectLayer, system: ^PhysicsSystem, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) ---
	CharacterVirtual_RefreshContacts                  :: proc(character: ^CharacterVirtual, layer: ObjectLayer, system: ^PhysicsSystem, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) ---
	CharacterVirtual_CanWalkStairs                    :: proc(character: ^CharacterVirtual, linearVelocity: ^Vec3) -> bool ---
	CharacterVirtual_WalkStairs                       :: proc(character: ^CharacterVirtual, deltaTime: f32, stepUp: ^Vec3, stepForward: ^Vec3, stepForwardTest: ^Vec3, stepDownExtra: ^Vec3, layer: ObjectLayer, system: ^PhysicsSystem, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	CharacterVirtual_StickToFloor                     :: proc(character: ^CharacterVirtual, stepDown: ^Vec3, layer: ObjectLayer, system: ^PhysicsSystem, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	CharacterVirtual_UpdateGroundVelocity             :: proc(character: ^CharacterVirtual) ---
	CharacterVirtual_SetShape                         :: proc(character: ^CharacterVirtual, shape: ^Shape, maxPenetrationDepth: f32, layer: ObjectLayer, system: ^PhysicsSystem, bodyFilter: ^BodyFilter, shapeFilter: ^ShapeFilter) -> bool ---
	CharacterVirtual_SetInnerBodyShape                :: proc(character: ^CharacterVirtual, shape: ^Shape) ---
	CharacterVirtual_GetNumActiveContacts             :: proc(character: ^CharacterVirtual) -> u32 ---
	CharacterVirtual_GetActiveContact                 :: proc(character: ^CharacterVirtual, index: u32, result: ^CharacterVirtualContact) ---
	CharacterVirtual_HasCollidedWithBody              :: proc(character: ^CharacterVirtual, body: BodyID) -> bool ---
	CharacterVirtual_HasCollidedWith                  :: proc(character: ^CharacterVirtual, other: CharacterID) -> bool ---
	CharacterVirtual_HasCollidedWithCharacter         :: proc(character: ^CharacterVirtual, other: ^CharacterVirtual) -> bool ---
}

/* CharacterContactListener */
CharacterContactListener_Procs :: struct {
	OnAdjustBodyVelocity:        proc "c" (userData: rawptr, character: ^CharacterVirtual, body2: ^Body, ioLinearVelocity: ^Vec3, ioAngularVelocity: ^Vec3),
	OnContactValidate:           proc "c" (userData: rawptr, character: ^CharacterVirtual, bodyID2: BodyID, subShapeID2: SubShapeID) -> bool,
	OnCharacterContactValidate:  proc "c" (userData: rawptr, character: ^CharacterVirtual, otherCharacter: ^CharacterVirtual, subShapeID2: SubShapeID) -> bool,
	OnContactAdded:              proc "c" (userData: rawptr, character: ^CharacterVirtual, bodyID2: BodyID, subShapeID2: SubShapeID, contactPosition: ^RVec3, contactNormal: ^Vec3, ioSettings: ^CharacterContactSettings),
	OnContactPersisted:          proc "c" (userData: rawptr, character: ^CharacterVirtual, bodyID2: BodyID, subShapeID2: SubShapeID, contactPosition: ^RVec3, contactNormal: ^Vec3, ioSettings: ^CharacterContactSettings),
	OnContactRemoved:            proc "c" (userData: rawptr, character: ^CharacterVirtual, bodyID2: BodyID, subShapeID2: SubShapeID),
	OnCharacterContactAdded:     proc "c" (userData: rawptr, character: ^CharacterVirtual, otherCharacter: ^CharacterVirtual, subShapeID2: SubShapeID, contactPosition: ^RVec3, contactNormal: ^Vec3, ioSettings: ^CharacterContactSettings),
	OnCharacterContactPersisted: proc "c" (userData: rawptr, character: ^CharacterVirtual, otherCharacter: ^CharacterVirtual, subShapeID2: SubShapeID, contactPosition: ^RVec3, contactNormal: ^Vec3, ioSettings: ^CharacterContactSettings),
	OnCharacterContactRemoved:   proc "c" (userData: rawptr, character: ^CharacterVirtual, otherCharacterID: CharacterID, subShapeID2: SubShapeID),
	OnContactSolve:              proc "c" (userData: rawptr, character: ^CharacterVirtual, bodyID2: BodyID, subShapeID2: SubShapeID, contactPosition: ^RVec3, contactNormal: ^Vec3, contactVelocity: ^Vec3, contactMaterial: ^PhysicsMaterial, characterVelocity: ^Vec3, newCharacterVelocity: ^Vec3),
	OnCharacterContactSolve:     proc "c" (userData: rawptr, character: ^CharacterVirtual, otherCharacter: ^CharacterVirtual, subShapeID2: SubShapeID, contactPosition: ^RVec3, contactNormal: ^Vec3, contactVelocity: ^Vec3, contactMaterial: ^PhysicsMaterial, characterVelocity: ^Vec3, newCharacterVelocity: ^Vec3),
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	CharacterContactListener_SetProcs :: proc(procs: ^CharacterContactListener_Procs) ---
	CharacterContactListener_Create   :: proc(userData: rawptr) -> ^CharacterContactListener ---
	CharacterContactListener_Destroy  :: proc(listener: ^CharacterContactListener) ---
}

/* JPH_CharacterVsCharacterCollision */
CharacterVsCharacterCollision_Procs :: struct {
	CollideCharacter: proc "c" (userData: rawptr, character: ^CharacterVirtual, centerOfMassTransform: ^RMat4, collideShapeSettings: ^CollideShapeSettings, baseOffset: ^RVec3),
	CastCharacter:    proc "c" (userData: rawptr, character: ^CharacterVirtual, centerOfMassTransform: ^RMat4, direction: ^Vec3, shapeCastSettings: ^ShapeCastSettings, baseOffset: ^RVec3),
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	CharacterVsCharacterCollision_SetProcs              :: proc(procs: ^CharacterVsCharacterCollision_Procs) ---
	CharacterVsCharacterCollision_Create                :: proc(userData: rawptr) -> ^CharacterVsCharacterCollision ---
	CharacterVsCharacterCollision_CreateSimple          :: proc() -> ^CharacterVsCharacterCollision ---
	CharacterVsCharacterCollisionSimple_AddCharacter    :: proc(characterVsCharacter: ^CharacterVsCharacterCollision, character: ^CharacterVirtual) ---
	CharacterVsCharacterCollisionSimple_RemoveCharacter :: proc(characterVsCharacter: ^CharacterVsCharacterCollision, character: ^CharacterVirtual) ---
	CharacterVsCharacterCollision_Destroy               :: proc(listener: ^CharacterVsCharacterCollision) ---

	/* CollisionDispatch */
	CollisionDispatch_CollideShapeVsShape        :: proc(shape1: ^Shape, shape2: ^Shape, scale1: ^Vec3, scale2: ^Vec3, centerOfMassTransform1: ^Mat4, centerOfMassTransform2: ^Mat4, collideShapeSettings: ^CollideShapeSettings, callback: CollideShapeCollectorCallback, userData: rawptr, shapeFilter: ^ShapeFilter) -> bool ---
	CollisionDispatch_CastShapeVsShapeLocalSpace :: proc(direction: ^Vec3, shape1: ^Shape, shape2: ^Shape, scale1InShape2LocalSpace: ^Vec3, scale2: ^Vec3, centerOfMassTransform1InShape2LocalSpace: ^Mat4, centerOfMassWorldTransform2: ^Mat4, shapeCastSettings: ^ShapeCastSettings, callback: CastShapeCollectorCallback, userData: rawptr, shapeFilter: ^ShapeFilter) -> bool ---
	CollisionDispatch_CastShapeVsShapeWorldSpace :: proc(direction: ^Vec3, shape1: ^Shape, shape2: ^Shape, scale1: ^Vec3, inScale2: ^Vec3, centerOfMassWorldTransform1: ^Mat4, centerOfMassWorldTransform2: ^Mat4, shapeCastSettings: ^ShapeCastSettings, callback: CastShapeCollectorCallback, userData: rawptr, shapeFilter: ^ShapeFilter) -> bool ---
}

/* DebugRenderer */
DebugRenderer_Procs :: struct {
	DrawLine:     proc "c" (userData: rawptr, from: ^RVec3, to: ^RVec3, color: Color),
	DrawTriangle: proc "c" (userData: rawptr, v1: ^RVec3, v2: ^RVec3, v3: ^RVec3, color: Color, castShadow: DebugRenderer_CastShadow),
	DrawText3D:   proc "c" (userData: rawptr, position: ^RVec3, str: cstring, color: Color, height: f32),
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	DebugRenderer_SetProcs               :: proc(procs: ^DebugRenderer_Procs) ---
	DebugRenderer_Create                 :: proc(userData: rawptr) -> ^DebugRenderer ---
	DebugRenderer_Destroy                :: proc(renderer: ^DebugRenderer) ---
	DebugRenderer_NextFrame              :: proc(renderer: ^DebugRenderer) ---
	DebugRenderer_SetCameraPos           :: proc(renderer: ^DebugRenderer, position: ^RVec3) ---
	DebugRenderer_DrawLine               :: proc(renderer: ^DebugRenderer, from: ^RVec3, to: ^RVec3, color: Color) ---
	DebugRenderer_DrawWireBox            :: proc(renderer: ^DebugRenderer, box: ^AABox, color: Color) ---
	DebugRenderer_DrawWireBox2           :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, box: ^AABox, color: Color) ---
	DebugRenderer_DrawMarker             :: proc(renderer: ^DebugRenderer, position: ^RVec3, color: Color, size: f32) ---
	DebugRenderer_DrawArrow              :: proc(renderer: ^DebugRenderer, from: ^RVec3, to: ^RVec3, color: Color, size: f32) ---
	DebugRenderer_DrawCoordinateSystem   :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, size: f32) ---
	DebugRenderer_DrawPlane              :: proc(renderer: ^DebugRenderer, point: ^RVec3, normal: ^Vec3, color: Color, size: f32) ---
	DebugRenderer_DrawWireTriangle       :: proc(renderer: ^DebugRenderer, v1: ^RVec3, v2: ^RVec3, v3: ^RVec3, color: Color) ---
	DebugRenderer_DrawWireSphere         :: proc(renderer: ^DebugRenderer, center: ^RVec3, radius: f32, color: Color, level: i32) ---
	DebugRenderer_DrawWireUnitSphere     :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, color: Color, level: i32) ---
	DebugRenderer_DrawTriangle           :: proc(renderer: ^DebugRenderer, v1: ^RVec3, v2: ^RVec3, v3: ^RVec3, color: Color, castShadow: DebugRenderer_CastShadow) ---
	DebugRenderer_DrawBox                :: proc(renderer: ^DebugRenderer, box: ^AABox, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawBox2               :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, box: ^AABox, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawSphere             :: proc(renderer: ^DebugRenderer, center: ^RVec3, radius: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawUnitSphere         :: proc(renderer: ^DebugRenderer, _matrix: RMat4, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawCapsule            :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, halfHeightOfCylinder: f32, radius: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawCylinder           :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, halfHeight: f32, radius: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawOpenCone           :: proc(renderer: ^DebugRenderer, top: ^RVec3, axis: ^Vec3, perpendicular: ^Vec3, halfAngle: f32, length: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawSwingConeLimits    :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, swingYHalfAngle: f32, swingZHalfAngle: f32, edgeLength: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawSwingPyramidLimits :: proc(renderer: ^DebugRenderer, _matrix: ^RMat4, minSwingYAngle: f32, maxSwingYAngle: f32, minSwingZAngle: f32, maxSwingZAngle: f32, edgeLength: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawPie                :: proc(renderer: ^DebugRenderer, center: ^RVec3, radius: f32, normal: ^Vec3, axis: ^Vec3, minAngle: f32, maxAngle: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
	DebugRenderer_DrawTaperedCylinder    :: proc(renderer: ^DebugRenderer, inMatrix: ^RMat4, top: f32, bottom: f32, topRadius: f32, bottomRadius: f32, color: Color, castShadow: DebugRenderer_CastShadow, drawMode: DebugRenderer_DrawMode) ---
}

/* Skeleton */
SkeletonJoint :: struct {
	name:             cstring,
	parentName:       cstring,
	parentJointIndex: i32,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	Skeleton_Create                      :: proc() -> ^Skeleton ---
	Skeleton_Destroy                     :: proc(skeleton: ^Skeleton) ---
	Skeleton_AddJoint                    :: proc(skeleton: ^Skeleton, name: cstring) -> u32 ---
	Skeleton_AddJoint2                   :: proc(skeleton: ^Skeleton, name: cstring, parentIndex: i32) -> u32 ---
	Skeleton_AddJoint3                   :: proc(skeleton: ^Skeleton, name: cstring, parentName: cstring) -> u32 ---
	Skeleton_GetJointCount               :: proc(skeleton: ^Skeleton) -> i32 ---
	Skeleton_GetJoint                    :: proc(skeleton: ^Skeleton, index: i32, joint: ^SkeletonJoint) ---
	Skeleton_GetJointIndex               :: proc(skeleton: ^Skeleton, name: cstring) -> i32 ---
	Skeleton_CalculateParentJointIndices :: proc(skeleton: ^Skeleton) ---
	Skeleton_AreJointsCorrectlyOrdered   :: proc(skeleton: ^Skeleton) -> bool ---

	/* Ragdoll */
	RagdollSettings_Create                                :: proc() -> ^RagdollSettings ---
	RagdollSettings_Destroy                               :: proc(settings: ^RagdollSettings) ---
	RagdollSettings_GetSkeleton                           :: proc(character: ^RagdollSettings) -> ^Skeleton ---
	RagdollSettings_SetSkeleton                           :: proc(character: ^RagdollSettings, skeleton: ^Skeleton) ---
	RagdollSettings_Stabilize                             :: proc(settings: ^RagdollSettings) -> bool ---
	RagdollSettings_DisableParentChildCollisions          :: proc(settings: ^RagdollSettings, jointMatrices: ^Mat4, minSeparationDistance: f32) --- /*=nullptr*/
	RagdollSettings_CalculateBodyIndexToConstraintIndex   :: proc(settings: ^RagdollSettings) ---
	RagdollSettings_GetConstraintIndexForBodyIndex        :: proc(settings: ^RagdollSettings, bodyIndex: i32) -> i32 ---
	RagdollSettings_CalculateConstraintIndexToBodyIdxPair :: proc(settings: ^RagdollSettings) ---
	RagdollSettings_CreateRagdoll                         :: proc(settings: ^RagdollSettings, system: ^PhysicsSystem, collisionGroup: CollisionGroupID, userData: u64) -> ^Ragdoll --- /*=0*/
	Ragdoll_Destroy                                       :: proc(ragdoll: ^Ragdoll) ---
	Ragdoll_AddToPhysicsSystem                            :: proc(ragdoll: ^Ragdoll, activationMode: Activation, lockBodies: bool) --- /*= JPH_ActivationActivate */
	Ragdoll_RemoveFromPhysicsSystem                       :: proc(ragdoll: ^Ragdoll, lockBodies: bool) --- /* = true */
	Ragdoll_Activate                                      :: proc(ragdoll: ^Ragdoll, lockBodies: bool) --- /* = true */
	Ragdoll_IsActive                                      :: proc(ragdoll: ^Ragdoll, lockBodies: bool) -> bool --- /* = true */
	Ragdoll_ResetWarmStart                                :: proc(ragdoll: ^Ragdoll) ---

	/* JPH_EstimateCollisionResponse */
	EstimateCollisionResponse :: proc(body1: ^Body, body2: ^Body, manifold: ^ContactManifold, combinedFriction: f32, combinedRestitution: f32, minVelocityForRestitution: f32, numIterations: u32, result: ^CollisionEstimationResult) ---
}

WheelSettings                      :: struct {}
WheelSettingsWV                    :: struct {} /* Inherits JPH_WheelSettings */
WheelSettingsTV                    :: struct {} /* Inherits JPH_WheelSettings */
Wheel                              :: struct {}
WheelWV                            :: struct {} /* Inherits JPH_Wheel */
WheelTV                            :: struct {} /* Inherits JPH_Wheel */
VehicleTransmissionSettings        :: struct {}
VehicleCollisionTester             :: struct {}
VehicleCollisionTesterRay          :: struct {} /* Inherits JPH_VehicleCollisionTester */
VehicleCollisionTesterCastSphere   :: struct {} /* Inherits JPH_VehicleCollisionTester */
VehicleCollisionTesterCastCylinder :: struct {} /* Inherits JPH_VehicleCollisionTester */
VehicleConstraint                  :: struct {} /* Inherits JPH_Constraint */
VehicleControllerSettings          :: struct {}
WheeledVehicleControllerSettings   :: struct {} /* Inherits JPH_VehicleControllerSettings */
MotorcycleControllerSettings       :: struct {} /* Inherits JPH_WheeledVehicleControllerSettings */
TrackedVehicleControllerSettings   :: struct {} /* Inherits JPH_VehicleControllerSettings */
WheeledVehicleController           :: struct {} /* Inherits JPH_VehicleController */
MotorcycleController               :: struct {} /* Inherits JPH_WheeledVehicleController */
TrackedVehicleController           :: struct {} /* Inherits JPH_VehicleController */
VehicleController                  :: struct {}

VehicleAntiRollBar :: struct {
	leftWheel:  i32,
	rightWheel: i32,
	stiffness:  f32,
}

VehicleConstraintSettings :: struct {
	base:              ConstraintSettings, /* Inherits JPH_ConstraintSettings */
	up:                Vec3,
	forward:           Vec3,
	maxPitchRollAngle: f32,
	wheelsCount:       u32,
	wheels:            ^^WheelSettings,
	antiRollBarsCount: u32,
	antiRollBars:      ^VehicleAntiRollBar,
	controller:        ^VehicleControllerSettings,
}

VehicleEngineSettings :: struct {
	maxTorque: f32,
	minRPM:    f32,
	maxRPM:    f32,

	//LinearCurve			normalizedTorque;
	inertia:        f32,
	angularDamping: f32,
}

VehicleDifferentialSettings :: struct {
	leftWheel:         i32,
	rightWheel:        i32,
	differentialRatio: f32,
	leftRightSplit:    f32,
	limitedSlipRatio:  f32,
	engineTorqueRatio: f32,
}

@(default_calling_convention="c", link_prefix="JPH_")
foreign lib {
	VehicleConstraintSettings_Init              :: proc(settings: ^VehicleConstraintSettings) ---
	VehicleConstraint_Create                    :: proc(body: ^Body, settings: ^VehicleConstraintSettings) -> ^VehicleConstraint ---
	VehicleConstraint_AsPhysicsStepListener     :: proc(constraint: ^VehicleConstraint) -> ^PhysicsStepListener ---
	VehicleConstraint_SetMaxPitchRollAngle      :: proc(constraint: ^VehicleConstraint, maxPitchRollAngle: f32) ---
	VehicleConstraint_SetVehicleCollisionTester :: proc(constraint: ^VehicleConstraint, tester: ^VehicleCollisionTester) ---
	VehicleConstraint_OverrideGravity           :: proc(constraint: ^VehicleConstraint, value: ^Vec3) ---
	VehicleConstraint_IsGravityOverridden       :: proc(constraint: ^VehicleConstraint) -> bool ---
	VehicleConstraint_GetGravityOverride        :: proc(constraint: ^VehicleConstraint, result: ^Vec3) ---
	VehicleConstraint_ResetGravityOverride      :: proc(constraint: ^VehicleConstraint) ---
	VehicleConstraint_GetLocalForward           :: proc(constraint: ^VehicleConstraint, result: ^Vec3) ---
	VehicleConstraint_GetLocalUp                :: proc(constraint: ^VehicleConstraint, result: ^Vec3) ---
	VehicleConstraint_GetWorldUp                :: proc(constraint: ^VehicleConstraint, result: ^Vec3) ---
	VehicleConstraint_GetVehicleBody            :: proc(constraint: ^VehicleConstraint) -> ^Body ---
	VehicleConstraint_GetController             :: proc(constraint: ^VehicleConstraint) -> ^VehicleController ---
	VehicleConstraint_GetWheelsCount            :: proc(constraint: ^VehicleConstraint) -> u32 ---
	VehicleConstraint_GetWheel                  :: proc(constraint: ^VehicleConstraint, index: u32) -> ^Wheel ---
	VehicleConstraint_GetWheelLocalBasis        :: proc(constraint: ^VehicleConstraint, wheel: ^Wheel, outForward: ^Vec3, outUp: ^Vec3, outRight: ^Vec3) ---
	VehicleConstraint_GetWheelLocalTransform    :: proc(constraint: ^VehicleConstraint, wheelIndex: u32, wheelRight: ^Vec3, wheelUp: ^Vec3, result: ^Mat4) ---
	VehicleConstraint_GetWheelWorldTransform    :: proc(constraint: ^VehicleConstraint, wheelIndex: u32, wheelRight: ^Vec3, wheelUp: ^Vec3, result: ^RMat4) ---

	/* Wheel */
	WheelSettings_Create                        :: proc() -> ^WheelSettings ---
	WheelSettings_Destroy                       :: proc(settings: ^WheelSettings) ---
	WheelSettings_GetPosition                   :: proc(settings: ^WheelSettings, result: ^Vec3) ---
	WheelSettings_SetPosition                   :: proc(settings: ^WheelSettings, value: ^Vec3) ---
	WheelSettings_GetSuspensionForcePoint       :: proc(settings: ^WheelSettings, result: ^Vec3) ---
	WheelSettings_SetSuspensionForcePoint       :: proc(settings: ^WheelSettings, value: ^Vec3) ---
	WheelSettings_GetSuspensionDirection        :: proc(settings: ^WheelSettings, result: ^Vec3) ---
	WheelSettings_SetSuspensionDirection        :: proc(settings: ^WheelSettings, value: ^Vec3) ---
	WheelSettings_GetSteeringAxis               :: proc(settings: ^WheelSettings, result: ^Vec3) ---
	WheelSettings_SetSteeringAxis               :: proc(settings: ^WheelSettings, value: ^Vec3) ---
	WheelSettings_GetWheelUp                    :: proc(settings: ^WheelSettings, result: ^Vec3) ---
	WheelSettings_SetWheelUp                    :: proc(settings: ^WheelSettings, value: ^Vec3) ---
	WheelSettings_GetWheelForward               :: proc(settings: ^WheelSettings, result: ^Vec3) ---
	WheelSettings_SetWheelForward               :: proc(settings: ^WheelSettings, value: ^Vec3) ---
	WheelSettings_GetSuspensionMinLength        :: proc(settings: ^WheelSettings) -> f32 ---
	WheelSettings_SetSuspensionMinLength        :: proc(settings: ^WheelSettings, value: f32) ---
	WheelSettings_GetSuspensionMaxLength        :: proc(settings: ^WheelSettings) -> f32 ---
	WheelSettings_SetSuspensionMaxLength        :: proc(settings: ^WheelSettings, value: f32) ---
	WheelSettings_GetSuspensionPreloadLength    :: proc(settings: ^WheelSettings) -> f32 ---
	WheelSettings_SetSuspensionPreloadLength    :: proc(settings: ^WheelSettings, value: f32) ---
	WheelSettings_GetSuspensionSpring           :: proc(settings: ^WheelSettings, result: ^SpringSettings) ---
	WheelSettings_SetSuspensionSpring           :: proc(settings: ^WheelSettings, springSettings: ^SpringSettings) ---
	WheelSettings_GetRadius                     :: proc(settings: ^WheelSettings) -> f32 ---
	WheelSettings_SetRadius                     :: proc(settings: ^WheelSettings, value: f32) ---
	WheelSettings_GetWidth                      :: proc(settings: ^WheelSettings) -> f32 ---
	WheelSettings_SetWidth                      :: proc(settings: ^WheelSettings, value: f32) ---
	WheelSettings_GetEnableSuspensionForcePoint :: proc(settings: ^WheelSettings) -> bool ---
	WheelSettings_SetEnableSuspensionForcePoint :: proc(settings: ^WheelSettings, value: bool) ---
	Wheel_Create                                :: proc(settings: ^WheelSettings) -> ^Wheel ---
	Wheel_Destroy                               :: proc(wheel: ^Wheel) ---
	Wheel_GetSettings                           :: proc(wheel: ^Wheel) -> ^WheelSettings ---
	Wheel_GetAngularVelocity                    :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_SetAngularVelocity                    :: proc(wheel: ^Wheel, value: f32) ---
	Wheel_GetRotationAngle                      :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_SetRotationAngle                      :: proc(wheel: ^Wheel, value: f32) ---
	Wheel_GetSteerAngle                         :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_SetSteerAngle                         :: proc(wheel: ^Wheel, value: f32) ---
	Wheel_HasContact                            :: proc(wheel: ^Wheel) -> bool ---
	Wheel_GetContactBodyID                      :: proc(wheel: ^Wheel) -> BodyID ---
	Wheel_GetContactSubShapeID                  :: proc(wheel: ^Wheel) -> SubShapeID ---
	Wheel_GetContactPosition                    :: proc(wheel: ^Wheel, result: ^RVec3) ---
	Wheel_GetContactPointVelocity               :: proc(wheel: ^Wheel, result: ^Vec3) ---
	Wheel_GetContactNormal                      :: proc(wheel: ^Wheel, result: ^Vec3) ---
	Wheel_GetContactLongitudinal                :: proc(wheel: ^Wheel, result: ^Vec3) ---
	Wheel_GetContactLateral                     :: proc(wheel: ^Wheel, result: ^Vec3) ---
	Wheel_GetSuspensionLength                   :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_GetSuspensionLambda                   :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_GetLongitudinalLambda                 :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_GetLateralLambda                      :: proc(wheel: ^Wheel) -> f32 ---
	Wheel_HasHitHardPoint                       :: proc(wheel: ^Wheel) -> bool ---

	/* VehicleAntiRollBar */
	VehicleAntiRollBar_Init :: proc(antiRollBar: ^VehicleAntiRollBar) ---

	/* VehicleEngine */
	VehicleEngineSettings_Init :: proc(settings: ^VehicleEngineSettings) ---

	/* VehicleDifferentialSettings */
	VehicleDifferentialSettings_Init :: proc(settings: ^VehicleDifferentialSettings) ---

	/* VehicleTransmission */
	VehicleTransmissionSettings_Create                   :: proc() -> ^VehicleTransmissionSettings ---
	VehicleTransmissionSettings_Destroy                  :: proc(settings: ^VehicleTransmissionSettings) ---
	VehicleTransmissionSettings_GetMode                  :: proc(settings: ^VehicleTransmissionSettings) -> TransmissionMode ---
	VehicleTransmissionSettings_SetMode                  :: proc(settings: ^VehicleTransmissionSettings, value: TransmissionMode) ---
	VehicleTransmissionSettings_GetGearRatioCount        :: proc(settings: ^VehicleTransmissionSettings) -> u32 ---
	VehicleTransmissionSettings_GetGearRatio             :: proc(settings: ^VehicleTransmissionSettings, index: u32) -> f32 ---
	VehicleTransmissionSettings_SetGearRatio             :: proc(settings: ^VehicleTransmissionSettings, index: u32, value: f32) ---
	VehicleTransmissionSettings_GetGearRatios            :: proc(settings: ^VehicleTransmissionSettings) -> ^f32 ---
	VehicleTransmissionSettings_SetGearRatios            :: proc(settings: ^VehicleTransmissionSettings, values: ^f32, count: u32) ---
	VehicleTransmissionSettings_GetReverseGearRatioCount :: proc(settings: ^VehicleTransmissionSettings) -> u32 ---
	VehicleTransmissionSettings_GetReverseGearRatio      :: proc(settings: ^VehicleTransmissionSettings, index: u32) -> f32 ---
	VehicleTransmissionSettings_SetReverseGearRatio      :: proc(settings: ^VehicleTransmissionSettings, index: u32, value: f32) ---
	VehicleTransmissionSettings_GetReverseGearRatios     :: proc(settings: ^VehicleTransmissionSettings) -> ^f32 ---
	VehicleTransmissionSettings_SetReverseGearRatios     :: proc(settings: ^VehicleTransmissionSettings, values: ^f32, count: u32) ---
	VehicleTransmissionSettings_GetSwitchTime            :: proc(settings: ^VehicleTransmissionSettings) -> f32 ---
	VehicleTransmissionSettings_SetSwitchTime            :: proc(settings: ^VehicleTransmissionSettings, value: f32) ---
	VehicleTransmissionSettings_GetClutchReleaseTime     :: proc(settings: ^VehicleTransmissionSettings) -> f32 ---
	VehicleTransmissionSettings_SetClutchReleaseTime     :: proc(settings: ^VehicleTransmissionSettings, value: f32) ---
	VehicleTransmissionSettings_GetSwitchLatency         :: proc(settings: ^VehicleTransmissionSettings) -> f32 ---
	VehicleTransmissionSettings_SetSwitchLatency         :: proc(settings: ^VehicleTransmissionSettings, value: f32) ---
	VehicleTransmissionSettings_GetShiftUpRPM            :: proc(settings: ^VehicleTransmissionSettings) -> f32 ---
	VehicleTransmissionSettings_SetShiftUpRPM            :: proc(settings: ^VehicleTransmissionSettings, value: f32) ---
	VehicleTransmissionSettings_GetShiftDownRPM          :: proc(settings: ^VehicleTransmissionSettings) -> f32 ---
	VehicleTransmissionSettings_SetShiftDownRPM          :: proc(settings: ^VehicleTransmissionSettings, value: f32) ---
	VehicleTransmissionSettings_GetClutchStrength        :: proc(settings: ^VehicleTransmissionSettings) -> f32 ---
	VehicleTransmissionSettings_SetClutchStrength        :: proc(settings: ^VehicleTransmissionSettings, value: f32) ---

	/* VehicleCollisionTester */
	VehicleCollisionTester_Destroy            :: proc(tester: ^VehicleCollisionTester) ---
	VehicleCollisionTester_GetObjectLayer     :: proc(tester: ^VehicleCollisionTester) -> ObjectLayer ---
	VehicleCollisionTester_SetObjectLayer     :: proc(tester: ^VehicleCollisionTester, value: ObjectLayer) ---
	VehicleCollisionTesterRay_Create          :: proc(layer: ObjectLayer, up: ^Vec3, maxSlopeAngle: f32) -> ^VehicleCollisionTesterRay ---
	VehicleCollisionTesterCastSphere_Create   :: proc(layer: ObjectLayer, radius: f32, up: ^Vec3, maxSlopeAngle: f32) -> ^VehicleCollisionTesterCastSphere ---
	VehicleCollisionTesterCastCylinder_Create :: proc(layer: ObjectLayer, convexRadiusFraction: f32) -> ^VehicleCollisionTesterCastCylinder ---

	/* VehicleControllerSettings/VehicleController */
	VehicleControllerSettings_Destroy :: proc(settings: ^VehicleControllerSettings) ---
	VehicleController_GetConstraint   :: proc(controller: ^VehicleController) -> ^VehicleConstraint ---

	/* ---- WheelSettingsWV - WheelWV - WheeledVehicleController ---- */
	WheelSettingsWV_Create            :: proc() -> ^WheelSettingsWV ---
	WheelSettingsWV_GetInertia        :: proc(settings: ^WheelSettingsWV) -> f32 ---
	WheelSettingsWV_SetInertia        :: proc(settings: ^WheelSettingsWV, value: f32) ---
	WheelSettingsWV_GetAngularDamping :: proc(settings: ^WheelSettingsWV) -> f32 ---
	WheelSettingsWV_SetAngularDamping :: proc(settings: ^WheelSettingsWV, value: f32) ---
	WheelSettingsWV_GetMaxSteerAngle  :: proc(settings: ^WheelSettingsWV) -> f32 ---
	WheelSettingsWV_SetMaxSteerAngle  :: proc(settings: ^WheelSettingsWV, value: f32) ---

	//JPH_CAPI JPH_LinearCurve* JPH_WheelSettingsWV_GetLongitudinalFriction(const JPH_WheelSettingsWV* settings);
	//JPH_CAPI void JPH_WheelSettingsWV_SetLongitudinalFriction(JPH_WheelSettingsWV* settings, const JPH_LinearCurve* value);
	//JPH_CAPI JPH_LinearCurve* JPH_WheelSettingsWV_GetLateralFriction(const JPH_WheelSettingsWV* settings);
	//JPH_CAPI void JPH_WheelSettingsWV_SetLateralFriction(JPH_WheelSettingsWV* settings, const JPH_LinearCurve* value);
	WheelSettingsWV_GetMaxBrakeTorque                                :: proc(settings: ^WheelSettingsWV) -> f32 ---
	WheelSettingsWV_SetMaxBrakeTorque                                :: proc(settings: ^WheelSettingsWV, value: f32) ---
	WheelSettingsWV_GetMaxHandBrakeTorque                            :: proc(settings: ^WheelSettingsWV) -> f32 ---
	WheelSettingsWV_SetMaxHandBrakeTorque                            :: proc(settings: ^WheelSettingsWV, value: f32) ---
	WheelWV_Create                                                   :: proc(settings: ^WheelSettingsWV) -> ^WheelWV ---
	WheelWV_GetSettings                                              :: proc(wheel: ^WheelWV) -> ^WheelSettingsWV ---
	WheelWV_ApplyTorque                                              :: proc(wheel: ^WheelWV, torque: f32, deltaTime: f32) ---
	WheeledVehicleControllerSettings_Create                          :: proc() -> ^WheeledVehicleControllerSettings ---
	WheeledVehicleControllerSettings_GetEngine                       :: proc(settings: ^WheeledVehicleControllerSettings, result: ^VehicleEngineSettings) ---
	WheeledVehicleControllerSettings_SetEngine                       :: proc(settings: ^WheeledVehicleControllerSettings, value: ^VehicleEngineSettings) ---
	WheeledVehicleControllerSettings_GetTransmission                 :: proc(settings: ^WheeledVehicleControllerSettings) -> ^VehicleTransmissionSettings ---
	WheeledVehicleControllerSettings_SetTransmission                 :: proc(settings: ^WheeledVehicleControllerSettings, value: ^VehicleTransmissionSettings) ---
	WheeledVehicleControllerSettings_GetDifferentialsCount           :: proc(settings: ^WheeledVehicleControllerSettings) -> u32 ---
	WheeledVehicleControllerSettings_SetDifferentialsCount           :: proc(settings: ^WheeledVehicleControllerSettings, count: u32) ---
	WheeledVehicleControllerSettings_GetDifferential                 :: proc(settings: ^WheeledVehicleControllerSettings, index: u32, result: ^VehicleDifferentialSettings) ---
	WheeledVehicleControllerSettings_SetDifferential                 :: proc(settings: ^WheeledVehicleControllerSettings, index: u32, value: ^VehicleDifferentialSettings) ---
	WheeledVehicleControllerSettings_SetDifferentials                :: proc(settings: ^WheeledVehicleControllerSettings, values: ^VehicleDifferentialSettings, count: u32) ---
	WheeledVehicleControllerSettings_GetDifferentialLimitedSlipRatio :: proc(settings: ^WheeledVehicleControllerSettings) -> f32 ---
	WheeledVehicleControllerSettings_SetDifferentialLimitedSlipRatio :: proc(settings: ^WheeledVehicleControllerSettings, value: f32) ---
	WheeledVehicleController_SetDriverInput                          :: proc(controller: ^WheeledVehicleController, forward: f32, right: f32, brake: f32, handBrake: f32) ---
	WheeledVehicleController_SetForwardInput                         :: proc(controller: ^WheeledVehicleController, forward: f32) ---
	WheeledVehicleController_GetForwardInput                         :: proc(controller: ^WheeledVehicleController) -> f32 ---
	WheeledVehicleController_SetRightInput                           :: proc(controller: ^WheeledVehicleController, rightRatio: f32) ---
	WheeledVehicleController_GetRightInput                           :: proc(controller: ^WheeledVehicleController) -> f32 ---
	WheeledVehicleController_SetBrakeInput                           :: proc(controller: ^WheeledVehicleController, brakeInput: f32) ---
	WheeledVehicleController_GetBrakeInput                           :: proc(controller: ^WheeledVehicleController) -> f32 ---
	WheeledVehicleController_SetHandBrakeInput                       :: proc(controller: ^WheeledVehicleController, handBrakeInput: f32) ---
	WheeledVehicleController_GetHandBrakeInput                       :: proc(controller: ^WheeledVehicleController) -> f32 ---
	WheeledVehicleController_GetWheelSpeedAtClutch                   :: proc(controller: ^WheeledVehicleController) -> f32 ---

	/* WheelSettingsTV - WheelTV - TrackedVehicleController */
	/* TODO: Add VehicleTrack and VehicleTrackSettings */
	WheelSettingsTV_Create                           :: proc() -> ^WheelSettingsTV ---
	WheelSettingsTV_GetLongitudinalFriction          :: proc(settings: ^WheelSettingsTV) -> f32 ---
	WheelSettingsTV_SetLongitudinalFriction          :: proc(settings: ^WheelSettingsTV, value: f32) ---
	WheelSettingsTV_GetLateralFriction               :: proc(settings: ^WheelSettingsTV) -> f32 ---
	WheelSettingsTV_SetLateralFriction               :: proc(settings: ^WheelSettingsTV, value: f32) ---
	WheelTV_Create                                   :: proc(settings: ^WheelSettingsTV) -> ^WheelTV ---
	WheelTV_GetSettings                              :: proc(wheel: ^WheelTV) -> ^WheelSettingsTV ---
	TrackedVehicleControllerSettings_Create          :: proc() -> ^TrackedVehicleControllerSettings ---
	TrackedVehicleControllerSettings_GetEngine       :: proc(settings: ^TrackedVehicleControllerSettings, result: ^VehicleEngineSettings) ---
	TrackedVehicleControllerSettings_SetEngine       :: proc(settings: ^TrackedVehicleControllerSettings, value: ^VehicleEngineSettings) ---
	TrackedVehicleControllerSettings_GetTransmission :: proc(settings: ^TrackedVehicleControllerSettings) -> ^VehicleTransmissionSettings ---
	TrackedVehicleControllerSettings_SetTransmission :: proc(settings: ^TrackedVehicleControllerSettings, value: ^VehicleTransmissionSettings) ---
	TrackedVehicleController_SetDriverInput          :: proc(controller: ^TrackedVehicleController, forward: f32, leftRatio: f32, rightRatio: f32, brake: f32) ---
	TrackedVehicleController_GetForwardInput         :: proc(controller: ^TrackedVehicleController) -> f32 ---
	TrackedVehicleController_SetForwardInput         :: proc(controller: ^TrackedVehicleController, value: f32) ---
	TrackedVehicleController_GetLeftRatio            :: proc(controller: ^TrackedVehicleController) -> f32 ---
	TrackedVehicleController_SetLeftRatio            :: proc(controller: ^TrackedVehicleController, value: f32) ---
	TrackedVehicleController_GetRightRatio           :: proc(controller: ^TrackedVehicleController) -> f32 ---
	TrackedVehicleController_SetRightRatio           :: proc(controller: ^TrackedVehicleController, value: f32) ---
	TrackedVehicleController_GetBrakeInput           :: proc(controller: ^TrackedVehicleController) -> f32 ---
	TrackedVehicleController_SetBrakeInput           :: proc(controller: ^TrackedVehicleController, value: f32) ---

	/* MotorcycleController */
	MotorcycleControllerSettings_Create                                   :: proc() -> ^MotorcycleControllerSettings ---
	MotorcycleControllerSettings_GetMaxLeanAngle                          :: proc(settings: ^MotorcycleControllerSettings) -> f32 ---
	MotorcycleControllerSettings_SetMaxLeanAngle                          :: proc(settings: ^MotorcycleControllerSettings, value: f32) ---
	MotorcycleControllerSettings_GetLeanSpringConstant                    :: proc(settings: ^MotorcycleControllerSettings) -> f32 ---
	MotorcycleControllerSettings_SetLeanSpringConstant                    :: proc(settings: ^MotorcycleControllerSettings, value: f32) ---
	MotorcycleControllerSettings_GetLeanSpringDamping                     :: proc(settings: ^MotorcycleControllerSettings) -> f32 ---
	MotorcycleControllerSettings_SetLeanSpringDamping                     :: proc(settings: ^MotorcycleControllerSettings, value: f32) ---
	MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficient      :: proc(settings: ^MotorcycleControllerSettings) -> f32 ---
	MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficient      :: proc(settings: ^MotorcycleControllerSettings, value: f32) ---
	MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficientDecay :: proc(settings: ^MotorcycleControllerSettings) -> f32 ---
	MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficientDecay :: proc(settings: ^MotorcycleControllerSettings, value: f32) ---
	MotorcycleControllerSettings_GetLeanSmoothingFactor                   :: proc(settings: ^MotorcycleControllerSettings) -> f32 ---
	MotorcycleControllerSettings_SetLeanSmoothingFactor                   :: proc(settings: ^MotorcycleControllerSettings, value: f32) ---
	MotorcycleController_GetWheelBase                                     :: proc(controller: ^MotorcycleController) -> f32 ---
	MotorcycleController_IsLeanControllerEnabled                          :: proc(controller: ^MotorcycleController) -> bool ---
	MotorcycleController_EnableLeanController                             :: proc(controller: ^MotorcycleController, value: bool) ---
	MotorcycleController_IsLeanSteeringLimitEnabled                       :: proc(controller: ^MotorcycleController) -> bool ---
	MotorcycleController_EnableLeanSteeringLimit                          :: proc(controller: ^MotorcycleController, value: bool) ---
	MotorcycleController_GetLeanSpringConstant                            :: proc(controller: ^MotorcycleController) -> f32 ---
	MotorcycleController_SetLeanSpringConstant                            :: proc(controller: ^MotorcycleController, value: f32) ---
	MotorcycleController_GetLeanSpringDamping                             :: proc(controller: ^MotorcycleController) -> f32 ---
	MotorcycleController_SetLeanSpringDamping                             :: proc(controller: ^MotorcycleController, value: f32) ---
	MotorcycleController_GetLeanSpringIntegrationCoefficient              :: proc(controller: ^MotorcycleController) -> f32 ---
	MotorcycleController_SetLeanSpringIntegrationCoefficient              :: proc(controller: ^MotorcycleController, value: f32) ---
	MotorcycleController_GetLeanSpringIntegrationCoefficientDecay         :: proc(controller: ^MotorcycleController) -> f32 ---
	MotorcycleController_SetLeanSpringIntegrationCoefficientDecay         :: proc(controller: ^MotorcycleController, value: f32) ---
	MotorcycleController_GetLeanSmoothingFactor                           :: proc(controller: ^MotorcycleController) -> f32 ---
	MotorcycleController_SetLeanSmoothingFactor                           :: proc(controller: ^MotorcycleController, value: f32) ---
}

