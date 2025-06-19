package ufbx

import "core:c"

_ :: c

foreign import lib "ufbx.lib"

// Main floating point type used everywhere in ufbx, defaults to `double`.
// If you define `UFBX_REAL_IS_FLOAT` to any value, `ufbx_real` will be defined
// as `float` instead.
// You can also manually define `UFBX_REAL_TYPE` to any floating point type.
Real :: f32

// Null-terminated UTF-8 encoded string within an FBX file
String :: struct {
	data:   cstring,
	length: c.size_t,
}

// Opaque byte buffer blob
Blob :: struct {
	data: rawptr,
	size: c.size_t,
}

// 2D vector
Vec2 :: [2]Real

// 3D vector
Vec3 :: [3]Real

// 4D vector
Vec4 :: [4]Real

// Quaternion
Quat :: quaternion128

// Order in which Euler-angle rotation axes are applied for a transform
// NOTE: The order in the name refers to the order of axes *applied*,
// not the multiplication order: eg. `UFBX_ROTATION_ORDER_XYZ` is `Z*Y*X`
// [TODO: Figure out what the spheric rotation order is...]
Rotation_Order :: enum c.int {
	XYZ         = 0,
	XZY         = 1,
	YZX         = 2,
	YXZ         = 3,
	ZXY         = 4,
	ZYX         = 5,
	SPHERIC     = 6,
	FORCE_32BIT = 2147483647,
}

ROTATION_ORDER_COUNT :: 7

// Explicit translation+rotation+scale transformation.
// NOTE: Rotation is a quaternion, not Euler angles!
Transform :: struct {
	translation: Vec3,
	rotation:    Quat,
	scale:       Vec3,
}

// 4x3 matrix encoding an affine transformation.
// `cols[0..2]` are the X/Y/Z basis vectors, `cols[3]` is the translation
Matrix :: struct {
	using _: struct #raw_union {
		using _: struct {
			m00: Real,
			m10: Real,
			m20: Real,
			m01: Real,
			m11: Real,
			m21: Real,
			m02: Real,
			m12: Real,
			m22: Real,
			m03: Real,
			m13: Real,
			m23: Real,
		},
		cols: [4]Vec3,
		v:    [12]Real,
	},
}

Void_List :: struct {
	data:  [^]rawptr,
	count: c.size_t,
}

Bool_List :: struct {
	data:  [^]bool,
	count: c.size_t,
}

Uint32_List :: struct {
	data:  [^]u32,
	count: c.size_t,
}

Real_List :: struct {
	data:  [^]Real,
	count: c.size_t,
}

Vec2_List :: struct {
	data:  [^]Vec2,
	count: c.size_t,
}

Vec3_List :: struct {
	data:  [^]Vec3,
	count: c.size_t,
}

Vec4_List :: struct {
	data:  [^]Vec4,
	count: c.size_t,
}

String_List :: struct {
	data:  [^]String,
	count: c.size_t,
}

// -- Document object model
Dom_Value_Type :: enum c.int {
	NUMBER           = 0,
	STRING           = 1,
	ARRAY_I8         = 2,
	ARRAY_I32        = 3,
	ARRAY_I64        = 4,
	ARRAY_F32        = 5,
	ARRAY_F64        = 6,
	ARRAY_RAW_STRING = 7,
	ARRAY_IGNORED    = 8,
	TYPE_FORCE_32BIT = 2147483647,
}

DOM_VALUE_TYPE_COUNT :: 9

Dom_Value :: struct {
	type:        Dom_Value_Type,
	value_str:   String,
	value_blob:  Blob,
	value_int:   i64,
	value_float: f64,
}

Dom_Node_List :: struct {
	data:  ^^Dom_Node,
	count: c.size_t,
}

Dom_Value_List :: struct {
	data:  [^]Dom_Value,
	count: c.size_t,
}

Dom_Node :: struct {
	name:     String,
	children: Dom_Node_List,
	values:   Dom_Value_List,
}

// Data type contained within the property. All the data fields are always
// populated regardless of type, so there's no need to switch by type usually
// eg. `prop->value_real` and `prop->value_int` have the same value (well, close)
// if `prop->type == UFBX_PROP_INTEGER`. String values are not converted from/to.
Prop_Type :: enum c.int {
	UNKNOWN          = 0,
	BOOLEAN          = 1,
	INTEGER          = 2,
	NUMBER           = 3,
	VECTOR           = 4,
	COLOR            = 5,
	COLOR_WITH_ALPHA = 6,
	STRING           = 7,
	DATE_TIME        = 8,
	TRANSLATION      = 9,
	ROTATION         = 10,
	SCALING          = 11,
	DISTANCE         = 12,
	COMPOUND         = 13,
	BLOB             = 14,
	REFERENCE        = 15,
	TYPE_FORCE_32BIT = 2147483647,
}

PROP_TYPE_COUNT :: 16

// Property flags: Advanced information about properties, not usually needed.
Prop_Flag :: enum c.int {
	ANIMATABLE   = 0,  // Supports animation.
	// NOTE: ufbx ignores this and allows animations on non-animatable properties.
	USER_DEFINED = 1,  // User defined (custom) property.
	HIDDEN       = 2,  // Hidden in UI.
	LOCK_X       = 4,  // Disallow modification from UI for components.
	LOCK_Y       = 5,  // Disallow modification from UI for components.
	LOCK_Z       = 6,  // Disallow modification from UI for components.
	LOCK_W       = 7,  // Disallow modification from UI for components.
	MUTE_X       = 8,  // Disable animation from components.
	MUTE_Y       = 9,  // Disable animation from components.
	MUTE_Z       = 10, // Disable animation from components.
	MUTE_W       = 11, // Disable animation from components.
	SYNTHETIC    = 12, // Property created by ufbx when an element has a connected `ufbx_anim_prop`
	// but doesn't contain the `ufbx_prop` it's referring to.
	// NOTE: The property may have been found in the templated defaults.
	ANIMATED     = 13, // The property has at least one `ufbx_anim_prop` in some layer.
	NOT_FOUND    = 14, // Used by `ufbx_evaluate_prop()` to indicate the the property was not found.
	CONNECTED    = 15, // The property is connected to another one.
	// This use case is relatively rare so `ufbx_prop` does not track connections
	// directly. You can find connections from `ufbx_element.connections_dst` where
	// `ufbx_connection.dst_prop` is this property and `ufbx_connection.src_prop` is defined.
	NO_VALUE     = 16, // The value of this property is undefined (represented as zero).
	OVERRIDDEN   = 17, // This property has been overridden by the user.
	// See `ufbx_anim.prop_overrides` for more information.
	VALUE_REAL   = 20, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
	VALUE_VEC2   = 21, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
	VALUE_VEC3   = 22, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
	VALUE_VEC4   = 23, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
	VALUE_INT    = 24, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
	VALUE_STR    = 25, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
	VALUE_BLOB   = 26, // Value type.
	// `REAL/VEC2/VEC3/VEC4` are mutually exclusive but may coexist with eg. `STRING`
	// in some rare cases where the string defines the unit for the vector.
}

Prop_Flags :: distinct bit_set[Prop_Flag; c.int]

PROP_FLAGS_FORCE_32BIT :: Prop_Flags { .ANIMATABLE, .USER_DEFINED, .HIDDEN, .LOCK_X, .LOCK_Y, .LOCK_Z, .LOCK_W, .MUTE_X, .MUTE_Y, .MUTE_Z, .MUTE_W, .SYNTHETIC, .ANIMATED, .NOT_FOUND, .CONNECTED, .NO_VALUE, .OVERRIDDEN, .VALUE_REAL, .VALUE_VEC2, .VALUE_VEC3, .VALUE_VEC4, .VALUE_INT, .VALUE_STR, .VALUE_BLOB }

// Single property with name/type/value.
Prop :: struct {
	name:          String,
	_internal_key: u32,
	type:          Prop_Type,
	flags:         Prop_Flag,
	value_str:     String,
	value_blob:    Blob,
	value_int:     i64,
	using _: struct #raw_union {
		value_real_arr: [4]Real,
		value_real:     Real,
		value_vec2:     Vec2,
		value_vec3:     Vec3,
		value_vec4:     Vec4,
	},
}

Prop_List :: struct {
	data:  ^Prop,
	count: c.size_t,
}

// List of alphabetically sorted properties with potential defaults.
// For animated objects in as scene from `ufbx_evaluate_scene()` this list
// only has the animated properties, the originals are stored under `defaults`.
Props :: struct {
	props:        Prop_List,
	num_animated: c.size_t,
	defaults:     ^Props,
}

Element_List :: struct {
	data:  ^^Element,
	count: c.size_t,
}

Unknown_List :: struct {
	data:  ^^Unknown,
	count: c.size_t,
}

Node_List :: struct {
	data:  [^]^Node,
	count: c.size_t,
}

Mesh_List :: struct {
	data:  ^^Mesh,
	count: c.size_t,
}

Light_List :: struct {
	data:  ^^Light,
	count: c.size_t,
}

Camera_List :: struct {
	data:  ^^Camera,
	count: c.size_t,
}

Bone_List :: struct {
	data:  ^^Bone,
	count: c.size_t,
}

Empty_List :: struct {
	data:  ^^Empty,
	count: c.size_t,
}

Line_Curve_List :: struct {
	data:  ^^Line_Curve,
	count: c.size_t,
}

Nurbs_Curve_List :: struct {
	data:  ^^Nurbs_Curve,
	count: c.size_t,
}

Nurbs_Surface_List :: struct {
	data:  ^^Nurbs_Surface,
	count: c.size_t,
}

Nurbs_Trim_Surface_List :: struct {
	data:  ^^Nurbs_Trim_Surface,
	count: c.size_t,
}

Nurbs_Trim_Boundary_List :: struct {
	data:  ^^Nurbs_Trim_Boundary,
	count: c.size_t,
}

Procedural_Geometry_List :: struct {
	data:  ^^Procedural_Geometry,
	count: c.size_t,
}

Stereo_Camera_List :: struct {
	data:  ^^Stereo_Camera,
	count: c.size_t,
}

Camera_Switcher_List :: struct {
	data:  ^^Camera_Switcher,
	count: c.size_t,
}

Marker_List :: struct {
	data:  ^^Marker,
	count: c.size_t,
}

Lod_Group_List :: struct {
	data:  ^^Lod_Group,
	count: c.size_t,
}

Skin_Deformer_List :: struct {
	data:  ^^Skin_Deformer,
	count: c.size_t,
}

Skin_Cluster_List :: struct {
	data:  ^^Skin_Cluster,
	count: c.size_t,
}

Blend_Deformer_List :: struct {
	data:  ^^Blend_Deformer,
	count: c.size_t,
}

Blend_Channel_List :: struct {
	data:  ^^Blend_Channel,
	count: c.size_t,
}

Blend_Shape_List :: struct {
	data:  ^^Blend_Shape,
	count: c.size_t,
}

Cache_Deformer_List :: struct {
	data:  ^^Cache_Deformer,
	count: c.size_t,
}

Cache_File_List :: struct {
	data:  ^^Cache_File,
	count: c.size_t,
}

Material_List :: struct {
	data:  ^^Material,
	count: c.size_t,
}

Texture_List :: struct {
	data:  ^^Texture,
	count: c.size_t,
}

Video_List :: struct {
	data:  ^^Video,
	count: c.size_t,
}

Shader_List :: struct {
	data:  ^^Shader,
	count: c.size_t,
}

Shader_Binding_List :: struct {
	data:  ^^Shader_Binding,
	count: c.size_t,
}

Anim_Stack_List :: struct {
	data:  ^^Anim_Stack,
	count: c.size_t,
}

Anim_Layer_List :: struct {
	data:  ^^Anim_Layer,
	count: c.size_t,
}

Anim_Value_List :: struct {
	data:  ^^Anim_Value,
	count: c.size_t,
}

Anim_Curve_List :: struct {
	data:  ^^Anim_Curve,
	count: c.size_t,
}

Display_Layer_List :: struct {
	data:  ^^Display_Layer,
	count: c.size_t,
}

Selection_Set_List :: struct {
	data:  ^^Selection_Set,
	count: c.size_t,
}

Selection_Node_List :: struct {
	data:  ^^Selection_Node,
	count: c.size_t,
}

Character_List :: struct {
	data:  ^^Character,
	count: c.size_t,
}

Constraint_List :: struct {
	data:  ^^Constraint,
	count: c.size_t,
}

Audio_Layer_List :: struct {
	data:  ^^Audio_Layer,
	count: c.size_t,
}

Audio_Clip_List :: struct {
	data:  ^^Audio_Clip,
	count: c.size_t,
}

Pose_List :: struct {
	data:  ^^Pose,
	count: c.size_t,
}

Metadata_Object_List :: struct {
	data:  ^^Metadata_Object,
	count: c.size_t,
}

Element_Type :: enum c.int {
	UNKNOWN             = 0,  // < `ufbx_unknown`
	NODE                = 1,  // < `ufbx_node`
	MESH                = 2,  // < `ufbx_mesh`
	LIGHT               = 3,  // < `ufbx_light`
	CAMERA              = 4,  // < `ufbx_camera`
	BONE                = 5,  // < `ufbx_bone`
	EMPTY               = 6,  // < `ufbx_empty`
	LINE_CURVE          = 7,  // < `ufbx_line_curve`
	NURBS_CURVE         = 8,  // < `ufbx_nurbs_curve`
	NURBS_SURFACE       = 9,  // < `ufbx_nurbs_surface`
	NURBS_TRIM_SURFACE  = 10, // < `ufbx_nurbs_trim_surface`
	NURBS_TRIM_BOUNDARY = 11, // < `ufbx_nurbs_trim_boundary`
	PROCEDURAL_GEOMETRY = 12, // < `ufbx_procedural_geometry`
	STEREO_CAMERA       = 13, // < `ufbx_stereo_camera`
	CAMERA_SWITCHER     = 14, // < `ufbx_camera_switcher`
	MARKER              = 15, // < `ufbx_marker`
	LOD_GROUP           = 16, // < `ufbx_lod_group`
	SKIN_DEFORMER       = 17, // < `ufbx_skin_deformer`
	SKIN_CLUSTER        = 18, // < `ufbx_skin_cluster`
	BLEND_DEFORMER      = 19, // < `ufbx_blend_deformer`
	BLEND_CHANNEL       = 20, // < `ufbx_blend_channel`
	BLEND_SHAPE         = 21, // < `ufbx_blend_shape`
	CACHE_DEFORMER      = 22, // < `ufbx_cache_deformer`
	CACHE_FILE          = 23, // < `ufbx_cache_file`
	MATERIAL            = 24, // < `ufbx_material`
	TEXTURE             = 25, // < `ufbx_texture`
	VIDEO               = 26, // < `ufbx_video`
	SHADER              = 27, // < `ufbx_shader`
	SHADER_BINDING      = 28, // < `ufbx_shader_binding`
	ANIM_STACK          = 29, // < `ufbx_anim_stack`
	ANIM_LAYER          = 30, // < `ufbx_anim_layer`
	ANIM_VALUE          = 31, // < `ufbx_anim_value`
	ANIM_CURVE          = 32, // < `ufbx_anim_curve`
	DISPLAY_LAYER       = 33, // < `ufbx_display_layer`
	SELECTION_SET       = 34, // < `ufbx_selection_set`
	SELECTION_NODE      = 35, // < `ufbx_selection_node`
	CHARACTER           = 36, // < `ufbx_character`
	CONSTRAINT          = 37, // < `ufbx_constraint`
	AUDIO_LAYER         = 38, // < `ufbx_audio_layer`
	AUDIO_CLIP          = 39, // < `ufbx_audio_clip`
	POSE                = 40, // < `ufbx_pose`
	METADATA_OBJECT     = 41, // < `ufbx_metadata_object`
	TYPE_FIRST_ATTRIB   = 2,
	TYPE_LAST_ATTRIB    = 16,
	TYPE_FORCE_32BIT    = 2147483647,
}

ELEMENT_TYPE_COUNT :: 42

// Connection between two elements.
// Source and destination are somewhat arbitrary but the destination is
// often the "container" like a parent node or mesh containing a deformer.
Connection :: struct {
	src:      ^Element,
	dst:      ^Element,
	src_prop: String,
	dst_prop: String,
}

Connection_List :: struct {
	data:  ^Connection,
	count: c.size_t,
}

// Element "base-class" common to each element.
// Some fields (like `connections_src`) are advanced and not visible
// in the specialized element structs.
// NOTE: The `element_id` value is consistent when loading the
// _same_ file, but re-exporting the file will invalidate them.
Element :: struct {
	name:            String,
	props:           Props,
	element_id:      u32,
	typed_id:        u32,
	instances:       Node_List,
	type:            Element_Type,
	connections_src: Connection_List,
	connections_dst: Connection_List,
	dom_node:        ^Dom_Node,
	scene:           ^Scene,
}

// -- Unknown
Unknown :: struct {
	// Shared "base-class" header, see `ufbx_element`.
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	type, super_type, sub_type: String, // FBX format specific type information.
	// In ASCII FBX format:
	//   super_type: ID, "type::name", "sub_type" { ... }
}

// Inherit type specifies how hierarchial node transforms are combined.
// This only affects the final scaling, as rotation and translation are always
// inherited correctly.
// NOTE: These don't map to `"InheritType"` property as there may be new ones for
// compatibility with various exporters.
Inherit_Mode :: enum c.int {
	NORMAL              = 0,          // Normal matrix composition of hierarchy: `R*S*r*s`.
	//   child.node_to_world = parent.node_to_world * child.node_to_parent;
	IGNORE_PARENT_SCALE = 1,          // Ignore parent scale when computing the transform: `R*r*s`.
	//   ufbx_transform t = node.local_transform;
	//   t.translation *= parent.inherit_scale;
	//   t.scale *= node.inherit_scale_node.inherit_scale;
	//   child.node_to_world = parent.unscaled_node_to_world * t;
	// Also known as "Segment scale compensate" in some software.
	COMPONENTWISE_SCALE = 2,          // Apply parent scale component-wise: `R*r*S*s`.
	//   ufbx_transform t = node.local_transform;
	//   t.translation *= parent.inherit_scale;
	//   t.scale *= node.inherit_scale_node.inherit_scale;
	//   child.node_to_world = parent.unscaled_node_to_world * t;
	FORCE_32BIT         = 2147483647, // Apply parent scale component-wise: `R*r*S*s`.
	//   ufbx_transform t = node.local_transform;
	//   t.translation *= parent.inherit_scale;
	//   t.scale *= node.inherit_scale_node.inherit_scale;
	//   child.node_to_world = parent.unscaled_node_to_world * t;
}

INHERIT_MODE_COUNT :: 3

// Axis used to mirror transformations for handedness conversion.
Mirror_Axis :: enum c.int {
	NONE        = 0,
	X           = 1,
	Y           = 2,
	Z           = 3,
	FORCE_32BIT = 2147483647,
}

MIRROR_AXIS_COUNT :: 4

// Nodes form the scene transformation hierarchy and can contain attached
// elements such as meshes or lights. In normal cases a single `ufbx_node`
// contains only a single attached element, so using `type/mesh/...` is safe.
Node :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	parent:                                                                                                                                                               ^Node,          // Parent node containing this one if not root.
	//
	// Always non-`NULL` for non-root nodes unless
	// `ufbx_load_opts.allow_nodes_out_of_root` is enabled.
	children:                                                                                                                                                             Node_List,      // List of child nodes parented to this node.
	mesh:                                                                                                                                                                 ^Mesh,          // Common attached element type and typed pointers. Set to `NULL` if not in
	// use, so checking `attrib_type` is not required.
	//
	// HINT: If you need less common attributes access `ufbx_node.attrib`, you
	// can use utility functions like `ufbx_as_nurbs_curve(attrib)` to convert
	// and check the attribute in one step.
	light:                                                                                                                                                                ^Light,
	camera:                                                                                                                                                               ^Camera,
	bone:                                                                                                                                                                 ^Bone,
	attrib:                                                                                                                                                               ^Element,       // Less common attributes use these fields.
	//
	// Defined even if it is one of the above, eg. `ufbx_mesh`. In case there
	// is multiple attributes this will be the first one.
	geometry_transform_helper, scale_helper:                                                                                                                              ^Node,          // Geometry transform helper if one exists.
	// See `UFBX_GEOMETRY_TRANSFORM_HANDLING_HELPER_NODES`.
	attrib_type:                                                                                                                                                          Element_Type,   // `attrib->type` if `attrib` is defined, otherwise `UFBX_ELEMENT_UNKNOWN`.
	all_attribs:                                                                                                                                                          Element_List,   // List of _all_ attached attribute elements.
	//
	// In most cases there is only zero or one attributes per node, but if you
	// have a very exotic FBX file nodes may have multiple attributes.
	inherit_mode, original_inherit_mode:                                                                                                                                  Inherit_Mode,   // Local transform in parent, geometry transform is a non-inherited
	// transform applied only to attachments like meshes
	local_transform:                                                                                                                                                      Transform,
	geometry_transform:                                                                                                                                                   Transform,
	inherit_scale:                                                                                                                                                        Vec3,           // Combined scale when using `UFBX_INHERIT_MODE_COMPONENTWISE_SCALE`.
	// Contains `local_transform.scale` otherwise.
	inherit_scale_node:                                                                                                                                                   ^Node,          // Node where scale is inherited from for `UFBX_INHERIT_MODE_COMPONENTWISE_SCALE`
	// and even for `UFBX_INHERIT_MODE_IGNORE_PARENT_SCALE`.
	// For componentwise-scale nodes, this will point to `parent`, for scale ignoring
	// nodes this will point to the parent of the nearest componentwise-scaled node
	// in the parent chain.
	rotation_order:                                                                                                                                                       Rotation_Order, // Specifies the axis order `euler_rotation` is applied in.
	euler_rotation:                                                                                                                                                       Vec3,           // Rotation around the local X/Y/Z axes in `rotation_order`.
	// The angles are specified in degrees.
	node_to_parent, node_to_world, geometry_to_node, geometry_to_world, unscaled_node_to_world:                                                                           Matrix,         // Transform from this node to `parent` space.
	// Equivalent to `ufbx_transform_to_matrix(&local_transform)`.
	adjust_pre_translation:                                                                                                                                               Vec3,           // < Translation applied between parent and self
	adjust_pre_rotation:                                                                                                                                                  Quat,           // < Rotation applied between parent and self
	adjust_pre_scale:                                                                                                                                                     Real,           // < Scaling applied between parent and self
	adjust_post_rotation:                                                                                                                                                 Quat,           // < Rotation applied in local space at the end
	adjust_post_scale, adjust_translation_scale:                                                                                                                          Real,           // < Scaling applied in local space at the end
	adjust_mirror_axis:                                                                                                                                                   Mirror_Axis,    // < Mirror translation and rotation on this axis
	materials:                                                                                                                                                            Material_List,  // Materials used by `mesh` or other `attrib`.
	// There may be multiple copies of a single `ufbx_mesh` with different materials
	// in the `ufbx_node` instances.
	bind_pose:                                                                                                                                                            ^Pose,          // Bind pose
	visible, is_root, has_geometry_transform, has_adjust_transform, has_root_adjust_transform, is_geometry_transform_helper, is_scale_helper, is_scale_compensate_parent: bool,           // Visibility state.
	node_depth:                                                                                                                                                           u32,            // How deep is this node in the parent hierarchy. Root node is at depth `0`
	// and the immediate children of root at `1`.
}

// Vertex attribute: All attributes are stored in a consistent indexed format
// regardless of how it's actually stored in the file.
//
// `values` is a contiguous array of attribute values.
// `indices` maps each mesh index into a value in the `values` array.
//
// If `unique_per_vertex` is set then the attribute is guaranteed to have a
// single defined value per vertex accessible via:
//   attrib.values.data[attrib.indices.data[mesh->vertex_first_index[vertex_ix]]
Vertex_Attrib :: struct {
	exists:            bool,        // Is this attribute defined by the mesh.
	values:            Void_List,   // List of values the attribute uses.
	indices:           Uint32_List, // Indices into `values[]`, indexed up to `ufbx_mesh.num_indices`.
	value_reals:       c.size_t,    // Number of `ufbx_real` entries per value.
	unique_per_vertex: bool,        // `true` if this attribute is defined per vertex, instead of per index.
	values_w:          Real_List,   // Optional 4th 'W' component for the attribute.
	// May be defined for the following:
	//   ufbx_mesh.vertex_normal
	//   ufbx_mesh.vertex_tangent / ufbx_uv_set.vertex_tangent
	//   ufbx_mesh.vertex_bitangent / ufbx_uv_set.vertex_bitangent
	// NOTE: This is not loaded by default, set `ufbx_load_opts.retain_vertex_attrib_w`.
}

// 1D vertex attribute, see `ufbx_vertex_attrib` for information
Vertex_Real :: struct {
	exists:            bool,
	values:            Real_List,
	indices:           Uint32_List,
	value_reals:       c.size_t,
	unique_per_vertex: bool,
	values_w:          Real_List,
}

// 2D vertex attribute, see `ufbx_vertex_attrib` for information
Vertex_Vec2 :: struct {
	exists:            bool,
	values:            Vec2_List,
	indices:           Uint32_List,
	value_reals:       c.size_t,
	unique_per_vertex: bool,
	values_w:          Real_List,
}

// 3D vertex attribute, see `ufbx_vertex_attrib` for information
Vertex_Vec3 :: struct {
	exists:            bool,
	values:            Vec3_List,
	indices:           Uint32_List,
	value_reals:       c.size_t,
	unique_per_vertex: bool,
	values_w:          Real_List,
}

// 4D vertex attribute, see `ufbx_vertex_attrib` for information
Vertex_Vec4 :: struct {
	exists:            bool,
	values:            Vec4_List,
	indices:           Uint32_List,
	value_reals:       c.size_t,
	unique_per_vertex: bool,
	values_w:          Real_List,
}

// Vertex UV set/layer
Uv_Set :: struct {
	name:                             String,
	index:                            u32,
	vertex_uv:                        Vertex_Vec2, // < UV / texture coordinates
	vertex_tangent, vertex_bitangent: Vertex_Vec3, // < (optional) Tangent vector in UV.x direction
}

// Vertex color set/layer
Color_Set :: struct {
	name:         String,
	index:        u32,
	vertex_color: Vertex_Vec4, // < Per-vertex RGBA color
}

Uv_Set_List :: struct {
	data:  ^Uv_Set,
	count: c.size_t,
}

Color_Set_List :: struct {
	data:  ^Color_Set,
	count: c.size_t,
}

// Edge between two _indices_ in a mesh
Edge :: struct {
	using _: struct #raw_union {
		using _: struct {
			a: u32,
			b: u32,
		},
		indices: [2]u32,
	},
}

Edge_List :: struct {
	data:  ^Edge,
	count: c.size_t,
}

// Polygonal face with arbitrary number vertices, a single face contains a
// contiguous range of mesh indices, eg. `{5,3}` would have indices 5, 6, 7
//
// NOTE: `num_indices` maybe less than 3 in which case the face is invalid!
// [TODO #23: should probably remove the bad faces at load time]
Face :: struct {
	index_begin: u32,
	num_indices: u32,
}

Face_List :: struct {
	data:  [^]Face,
	count: c.size_t,
}

// Subset of mesh faces used by a single material or group.
Mesh_Part :: struct {
	index:                                                                      u32,         // Index of the mesh part.
	num_faces, num_triangles, num_empty_faces, num_point_faces, num_line_faces: c.size_t,    // < Number of faces (polygons)
	face_indices:                                                               Uint32_List, // Indices to `ufbx_mesh.faces[]`.
	// Always contains `num_faces` elements.
}

Mesh_Part_List :: struct {
	data:  ^Mesh_Part,
	count: c.size_t,
}

Face_Group :: struct {
	id:   i32,    // < Numerical ID for this group.
	name: String, // < Name for the face group.
}

Face_Group_List :: struct {
	data:  ^Face_Group,
	count: c.size_t,
}

Subdivision_Weight_Range :: struct {
	weight_begin: u32,
	num_weights:  u32,
}

Subdivision_Weight_Range_List :: struct {
	data:  ^Subdivision_Weight_Range,
	count: c.size_t,
}

Subdivision_Weight :: struct {
	weight: Real,
	index:  u32,
}

Subdivision_Weight_List :: struct {
	data:  ^Subdivision_Weight,
	count: c.size_t,
}

Subdivision_Result :: struct {
	result_memory_used:    c.size_t,
	temp_memory_used:      c.size_t,
	result_allocs:         c.size_t,
	temp_allocs:           c.size_t,
	source_vertex_ranges:  Subdivision_Weight_Range_List, // Weights of vertices in the source model.
	// Defined if `ufbx_subdivide_opts.evaluate_source_vertices` is set.
	source_vertex_weights: Subdivision_Weight_List,
	skin_cluster_ranges:   Subdivision_Weight_Range_List, // Weights of skin clusters in the source model.
	// Defined if `ufbx_subdivide_opts.evaluate_skin_weights` is set.
	skin_cluster_weights:  Subdivision_Weight_List,
}

Subdivision_Display_Mode :: enum c.int {
	DISABLED         = 0,
	HULL             = 1,
	HULL_AND_SMOOTH  = 2,
	SMOOTH           = 3,
	MODE_FORCE_32BIT = 2147483647,
}

SUBDIVISION_DISPLAY_MODE_COUNT :: 4

Subdivision_Boundary :: enum c.int {
	DEFAULT        = 0,
	LEGACY         = 1,
	SHARP_CORNERS  = 2,          // OpenSubdiv: `VTX_BOUNDARY_EDGE_AND_CORNER` / `FVAR_LINEAR_CORNERS_ONLY`
	SHARP_NONE     = 3,          // OpenSubdiv: `VTX_BOUNDARY_EDGE_ONLY` / `FVAR_LINEAR_NONE`
	SHARP_BOUNDARY = 4,          // OpenSubdiv: `FVAR_LINEAR_BOUNDARIES`
	SHARP_INTERIOR = 5,          // OpenSubdiv: `FVAR_LINEAR_ALL`
	FORCE_32BIT    = 2147483647, // OpenSubdiv: `FVAR_LINEAR_ALL`
}

SUBDIVISION_BOUNDARY_COUNT :: 6

// Polygonal mesh geometry.
//
// Example mesh with two triangles (x, z) and a quad (y).
// The faces have a constant UV coordinate x/y/z.
// The vertices have _per vertex_ normals that point up/down.
//
//     ^   ^     ^
//     A---B-----C
//     |x /     /|
//     | /  y  / |
//     |/     / z|
//     D-----E---F
//     v     v   v
//
// Attributes may have multiple values within a single vertex, for example a
// UV seam vertex has two UV coordinates. Thus polygons are defined using
// an index that counts each corner of each face polygon. If an attribute is
// defined (even per-vertex) it will always have a valid `indices` array.
//
//   {0,3}    {3,4}    {7,3}   faces ({ index_begin, num_indices })
//   0 1 2   3 4 5 6   7 8 9   index
//
//   0 1 3   1 2 4 3   2 4 5   vertex_indices[index]
//   A B D   B C E D   C E F   vertices[vertex_indices[index]]
//
//   0 0 1   0 0 1 1   0 1 1   vertex_normal.indices[index]
//   ^ ^ v   ^ ^ v v   ^ v v   vertex_normal.data[vertex_normal.indices[index]]
//
//   0 0 0   1 1 1 1   2 2 2   vertex_uv.indices[index]
//   x x x   y y y y   z z z   vertex_uv.data[vertex_uv.indices[index]]
//
// Vertex position can also be accessed uniformly through an accessor:
//   0 1 3   1 2 4 3   2 4 5   vertex_position.indices[index]
//   A B D   B C E D   C E F   vertex_position.data[vertex_position.indices[index]]
//
// Some geometry data is specified per logical vertex. Vertex positions are
// the only attribute that is guaranteed to be defined _uniquely_ per vertex.
// Vertex attributes _may_ be defined per vertex if `unique_per_vertex == true`.
// You can access the per-vertex values by first finding the first index that
// refers to the given vertex.
//
//   0 1 2 3 4 5  vertex
//   A B C D E F  vertices[vertex]
//
//   0 1 4 2 5 9  vertex_first_index[vertex]
//   0 0 0 1 1 1  vertex_normal.indices[vertex_first_index[vertex]]
//   ^ ^ ^ v v v  vertex_normal.data[vertex_normal.indices[vertex_first_index[vertex]]]
//
Mesh :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	num_vertices, num_indices, num_faces, num_triangles, num_edges, max_face_triangles, num_empty_faces, num_point_faces, num_line_faces: c.size_t,           // < Number of logical "vertex" points
	faces:                                                                                                                                Face_List,          // < Face index range
	face_smoothing:                                                                                                                       Bool_List,          // < Should the face have soft normals
	face_material, face_group:                                                                                                            Uint32_List,        // < Indices to `ufbx_mesh.materials[]` and `ufbx_node.materials[]`
	face_hole:                                                                                                                            Bool_List,          // < Should the face be hidden as a "hole"
	edges:                                                                                                                                Edge_List,          // < Edge index range
	edge_smoothing:                                                                                                                       Bool_List,          // < Should the edge have soft normals
	edge_crease:                                                                                                                          Real_List,          // < Crease value for subdivision surfaces
	edge_visibility:                                                                                                                      Bool_List,          // < Should the edge be visible
	vertex_indices:                                                                                                                       Uint32_List,        // Logical vertices and positions, alternatively you can use
	// `vertex_position` for consistent interface with other attributes.
	vertices:                                                                                                                             Vec3_List,
	vertex_first_index:                                                                                                                   Uint32_List,        // First index referring to a given vertex, `UFBX_NO_INDEX` if the vertex is unused.
	vertex_position, vertex_normal:                                                                                                       Vertex_Vec3,        // < Vertex positions
	vertex_uv:                                                                                                                            Vertex_Vec2,        // < (optional) UV / texture coordinates
	vertex_tangent, vertex_bitangent:                                                                                                     Vertex_Vec3,        // < (optional) Tangent vector in UV.x direction
	vertex_color:                                                                                                                         Vertex_Vec4,        // < (optional) Per-vertex RGBA color
	vertex_crease:                                                                                                                        Vertex_Real,        // < (optional) Crease value for subdivision surfaces
	uv_sets:                                                                                                                              Uv_Set_List,        // Multiple named UV/color sets
	// NOTE: The first set contains the same data as `vertex_uv/color`!
	color_sets:                                                                                                                           Color_Set_List,
	materials:                                                                                                                            Material_List,      // Materials used by the mesh.
	// NOTE: These can be wrong if you want to support per-instance materials!
	// Use `ufbx_node.materials[]` to get the per-instance materials at the same indices.
	face_groups:                                                                                                                          Face_Group_List,    // Face groups for this mesh.
	material_parts, face_group_parts:                                                                                                     Mesh_Part_List,     // Segments that use a given material.
	// Defined even if the mesh doesn't have any materials.
	material_part_usage_order:                                                                                                            Uint32_List,        // Order of `material_parts` by first face that refers to it.
	// Useful for compatibility with FBX SDK and various importers using it,
	// as they use this material order by default.
	skinned_is_local:                                                                                                                     bool,               // Skinned vertex positions, for efficiency the skinned positions are the
	// same as the static ones for non-skinned meshes and `skinned_is_local`
	// is set to true meaning you need to transform them manually using
	// `ufbx_transform_position(&node->geometry_to_world, skinned_pos)`!
	skinned_position:                                                                                                                     Vertex_Vec3,
	skinned_normal:                                                                                                                       Vertex_Vec3,
	skin_deformers:                                                                                                                       Skin_Deformer_List, // Deformers
	blend_deformers:                                                                                                                      Blend_Deformer_List,
	cache_deformers:                                                                                                                      Cache_Deformer_List,
	all_deformers:                                                                                                                        Element_List,
	subdivision_preview_levels, subdivision_render_levels:                                                                                u32,                // Subdivision
	subdivision_display_mode:                                                                                                             Subdivision_Display_Mode,
	subdivision_boundary:                                                                                                                 Subdivision_Boundary,
	subdivision_uv_boundary:                                                                                                              Subdivision_Boundary,
	reversed_winding, generated_normals, subdivision_evaluated:                                                                           bool,               // The winding of the faces has been reversed.
	subdivision_result:                                                                                                                   ^Subdivision_Result,
	from_tessellated_nurbs:                                                                                                               bool,               // Tessellation (result)
}

// The kind of light source
Light_Type :: enum c.int {
	POINT            = 0,          // Single point at local origin, at `node->world_transform.position`
	DIRECTIONAL      = 1,          // Infinite directional light pointing locally towards `light->local_direction`
	// For global: `ufbx_transform_direction(&node->node_to_world, light->local_direction)`
	SPOT             = 2,          // Cone shaped light towards `light->local_direction`, between `light->inner/outer_angle`.
	// For global: `ufbx_transform_direction(&node->node_to_world, light->local_direction)`
	AREA             = 3,          // Area light, shape specified by `light->area_shape`
	// TODO: Units?
	VOLUME           = 4,          // Volumetric light source
	// TODO: How does this work
	TYPE_FORCE_32BIT = 2147483647, // Volumetric light source
	// TODO: How does this work
}

LIGHT_TYPE_COUNT :: 5

// How fast does the light intensity decay at a distance
Light_Decay :: enum c.int {
	NONE        = 0, // < 1 (no decay)
	LINEAR      = 1, // < 1 / d
	QUADRATIC   = 2, // < 1 / d^2 (physically accurate)
	CUBIC       = 3, // < 1 / d^3
	FORCE_32BIT = 2147483647,
}

LIGHT_DECAY_COUNT :: 4

Light_Area_Shape :: enum c.int {
	RECTANGLE   = 0,
	SPHERE      = 1,
	FORCE_32BIT = 2147483647,
}

LIGHT_AREA_SHAPE_COUNT :: 2

// Light source attached to a `ufbx_node`
Light :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	color:           Vec3,       // Color and intensity of the light, usually you want to use `color * intensity`
	// NOTE: `intensity` is 0.01x of the property `"Intensity"` as that matches
	// matches values in DCC programs before exporting.
	intensity:       Real,
	local_direction: Vec3,       // Direction the light is aimed at in node's local space, usually -Y
	type:            Light_Type, // Type of the light and shape parameters
	decay:           Light_Decay,
	area_shape:      Light_Area_Shape,
	inner_angle:     Real,
	outer_angle:     Real,
	cast_light:      bool,
	cast_shadows:    bool,
}

Projection_Mode :: enum c.int {
	PERSPECTIVE  = 0,          // Perspective projection.
	ORTHOGRAPHIC = 1,          // Orthographic projection.
	FORCE_32BIT  = 2147483647, // Orthographic projection.
}

PROJECTION_MODE_COUNT :: 2

// Method of specifying the rendering resolution from properties
// NOTE: Handled internally by ufbx, ignore unless you interpret `ufbx_props` directly!
Aspect_Mode :: enum c.int {
	WINDOW_SIZE      = 0,          // No defined resolution
	FIXED_RATIO      = 1,          // `"AspectWidth"` and `"AspectHeight"` are relative to each other
	FIXED_RESOLUTION = 2,          // `"AspectWidth"` and `"AspectHeight"` are both pixels
	FIXED_WIDTH      = 3,          // `"AspectWidth"` is pixels, `"AspectHeight"` is relative to width
	FIXED_HEIGHT     = 4,          // < `"AspectHeight"` is pixels, `"AspectWidth"` is relative to height
	FORCE_32BIT      = 2147483647, // < `"AspectHeight"` is pixels, `"AspectWidth"` is relative to height
}

ASPECT_MODE_COUNT :: 5

// Method of specifying the field of view from properties
// NOTE: Handled internally by ufbx, ignore unless you interpret `ufbx_props` directly!
Aperture_Mode :: enum c.int {
	HORIZONTAL_AND_VERTICAL = 0,          // Use separate `"FieldOfViewX"` and `"FieldOfViewY"` as horizontal/vertical FOV angles
	HORIZONTAL              = 1,          // Use `"FieldOfView"` as horizontal FOV angle, derive vertical angle via aspect ratio
	VERTICAL                = 2,          // Use `"FieldOfView"` as vertical FOV angle, derive horizontal angle via aspect ratio
	FOCAL_LENGTH            = 3,          // Compute the field of view from the render gate size and focal length
	FORCE_32BIT             = 2147483647, // Compute the field of view from the render gate size and focal length
}

APERTURE_MODE_COUNT :: 4

// Method of specifying the render gate size from properties
// NOTE: Handled internally by ufbx, ignore unless you interpret `ufbx_props` directly!
Gate_Fit :: enum c.int {
	NONE        = 0,          // Use the film/aperture size directly as the render gate
	VERTICAL    = 1,          // Fit the render gate to the height of the film, derive width from aspect ratio
	HORIZONTAL  = 2,          // Fit the render gate to the width of the film, derive height from aspect ratio
	FILL        = 3,          // Fit the render gate so that it is fully contained within the film gate
	OVERSCAN    = 4,          // Fit the render gate so that it fully contains the film gate
	STRETCH     = 5,          // Stretch the render gate to match the film gate
	// TODO: Does this differ from `UFBX_GATE_FIT_NONE`?
	FORCE_32BIT = 2147483647, // Stretch the render gate to match the film gate
	// TODO: Does this differ from `UFBX_GATE_FIT_NONE`?
}

GATE_FIT_COUNT :: 6

// Camera film/aperture size defaults
// NOTE: Handled internally by ufbx, ignore unless you interpret `ufbx_props` directly!
Aperture_Format :: enum c.int {
	CUSTOM              = 0,  // < Use `"FilmWidth"` and `"FilmHeight"`
	_16MM_THEATRICAL    = 1,  // < 0.404 x 0.295 inches
	SUPER_16MM          = 2,  // < 0.493 x 0.292 inches
	_35MM_ACADEMY       = 3,  // < 0.864 x 0.630 inches
	_35MM_TV_PROJECTION = 4,  // < 0.816 x 0.612 inches
	_35MM_FULL_APERTURE = 5,  // < 0.980 x 0.735 inches
	_35MM_185_PROJECTION = 6, // < 0.825 x 0.446 inches
	_35MM_ANAMORPHIC    = 7,  // < 0.864 x 0.732 inches (squeeze ratio: 2)
	_70MM_PROJECTION    = 8,  // < 2.066 x 0.906 inches
	VISTAVISION         = 9,  // < 1.485 x 0.991 inches
	DYNAVISION          = 10, // < 2.080 x 1.480 inches
	IMAX                = 11, // < 2.772 x 2.072 inches
	FORCE_32BIT         = 2147483647,
}

APERTURE_FORMAT_COUNT :: 12

Coordinate_Axis :: enum c.int {
	POSITIVE_X  = 0,
	NEGATIVE_X  = 1,
	POSITIVE_Y  = 2,
	NEGATIVE_Y  = 3,
	POSITIVE_Z  = 4,
	NEGATIVE_Z  = 5,
	UNKNOWN     = 6,
	FORCE_32BIT = 2147483647,
}

COORDINATE_AXIS_COUNT :: 7

// Coordinate axes the scene is represented in.
// NOTE: `front` is the _opposite_ from forward!
Coordinate_Axes :: struct {
	right: Coordinate_Axis,
	up:    Coordinate_Axis,
	front: Coordinate_Axis,
}

// Camera attached to a `ufbx_node`
Camera :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	projection_mode:                                  Projection_Mode, // Projection mode (perspective/orthographic).
	resolution_is_pixels:                             bool,            // If set to `true`, `resolution` represents actual pixel values, otherwise
	// it's only useful for its aspect ratio.
	resolution, field_of_view_deg, field_of_view_tan: Vec2,            // Render resolution, either in pixels or arbitrary units, depending on above
	orthographic_extent:                              Real,            // Orthographic camera extents.
	// Valid if `projection_mode == UFBX_PROJECTION_MODE_ORTHOGRAPHIC`.
	orthographic_size, projection_plane:              Vec2,            // Orthographic camera size.
	// Valid if `projection_mode == UFBX_PROJECTION_MODE_ORTHOGRAPHIC`.
	aspect_ratio, near_plane, far_plane:              Real,            // Aspect ratio of the camera.
	projection_axes:                                  Coordinate_Axes, // Coordinate system that the projection uses.
	// FBX saves cameras with +X forward and +Y up, but you can override this using
	// `ufbx_load_opts.target_camera_axes` and it will be reflected here.
	aspect_mode:                                      Aspect_Mode,     // Advanced properties used to compute the above
	aperture_mode:                                    Aperture_Mode,
	gate_fit:                                         Gate_Fit,
	aperture_format:                                  Aperture_Format,
	focal_length_mm:                                  Real,            // < Focal length in millimeters
	film_size_inch, aperture_size_inch:               Vec2,            // < Film size in inches
	squeeze_ratio:                                    Real,            // < Anamoprhic stretch ratio
}

// Bone attached to a `ufbx_node`, provides the logical length of the bone
// but most interesting information is directly in `ufbx_node`.
Bone :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	radius, relative_length: Real, // Visual radius of the bone
	is_root:                 bool, // Is the bone a root bone
}

// Empty/NULL/locator connected to a node, actual details in `ufbx_node`
Empty :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
}

// Segment of a `ufbx_line_curve`, indices refer to `ufbx_line_curve.point_indices[]`
Line_Segment :: struct {
	index_begin: u32,
	num_indices: u32,
}

Line_Segment_List :: struct {
	data:  ^Line_Segment,
	count: c.size_t,
}

Line_Curve :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	color:                  Vec3,
	control_points:         Vec3_List,   // < List of possible values the line passes through
	point_indices:          Uint32_List, // < Indices to `control_points[]` the line goes through
	segments:               Line_Segment_List,
	from_tessellated_nurbs: bool,        // Tessellation (result)
}

Nurbs_Topology :: enum c.int {
	OPEN        = 0,          // The endpoints are not connected.
	PERIODIC    = 1,          // Repeats first `ufbx_nurbs_basis.order - 1` control points after the end.
	CLOSED      = 2,          // Repeats the first control point after the end.
	FORCE_32BIT = 2147483647, // Repeats the first control point after the end.
}

NURBS_TOPOLOGY_COUNT :: 3

// NURBS basis functions for an axis
Nurbs_Basis :: struct {
	order:                   u32,            // Number of control points influencing a point on the curve/surface.
	// Equal to the degree plus one.
	topology:                Nurbs_Topology, // Topology (periodicity) of the dimension.
	knot_vector:             Real_List,      // Subdivision of the parameter range to control points.
	t_min, t_max:            Real,           // Range for the parameter value.
	spans:                   Real_List,      // Parameter values of control points.
	is_2d:                   bool,           // `true` if this axis is two-dimensional.
	num_wrap_control_points: c.size_t,       // Number of control points that need to be copied to the end.
	// This is just for convenience as it could be derived from `topology` and
	// `order`. If for example `num_wrap_control_points == 3` you should repeat
	// the first 3 control points after the end.
	// HINT: You don't need to worry about this if you use ufbx functions
	// like `ufbx_evaluate_nurbs_curve()` as they handle this internally.
	valid:                   bool,           // `true` if the parametrization is well defined.
}

Nurbs_Curve :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	basis:          Nurbs_Basis, // Basis in the U axis
	control_points: Vec4_List,   // Linear array of control points
	// NOTE: The control points are _not_ homogeneous, meaning you have to multiply
	// them by `w` before evaluating the surface.
}

Nurbs_Surface :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	basis_u, basis_v:                           Nurbs_Basis, // Basis in the U/V axes
	num_control_points_u, num_control_points_v: c.size_t,    // Number of control points for the U/V axes
	control_points:                             Vec4_List,   // 2D array of control points.
	// Memory layout: `V * num_control_points_u + U`
	// NOTE: The control points are _not_ homogeneous, meaning you have to multiply
	// them by `w` before evaluating the surface.
	span_subdivision_u, span_subdivision_v:     u32,         // How many segments tessellate each span in `ufbx_nurbs_basis.spans`.
	flip_normals:                               bool,        // If `true` the resulting normals should be flipped when evaluated.
	material:                                   ^Material,   // Material for the whole surface.
	// NOTE: May be `NULL`!
}

Nurbs_Trim_Surface :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
}

Nurbs_Trim_Boundary :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
}

// -- Node attributes (advanced)
Procedural_Geometry :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
}

Stereo_Camera :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	left:  ^Camera,
	right: ^Camera,
}

Camera_Switcher :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
}

Marker_Type :: enum c.int {
	UNKNOWN          = 0, // < Unknown marker type
	FK_EFFECTOR      = 1, // < FK (Forward Kinematics) effector
	IK_EFFECTOR      = 2, // < IK (Inverse Kinematics) effector
	TYPE_FORCE_32BIT = 2147483647,
}

MARKER_TYPE_COUNT :: 3

// Tracking marker for effectors
Marker :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	type: Marker_Type, // Type of the marker
}

// LOD level display mode.
Lod_Display :: enum c.int {
	USE_LOD     = 0, // < Display the LOD level if the distance is appropriate.
	SHOW        = 1, // < Always display the LOD level.
	HIDE        = 2, // < Never display the LOD level.
	FORCE_32BIT = 2147483647,
}

LOD_DISPLAY_COUNT :: 3

// Single LOD level within an LOD group.
// Specifies properties of the Nth child of the _node_ containing the LOD group.
Lod_Level :: struct {
	distance: Real,        // Minimum distance to show this LOD level.
	// NOTE: In world units by default, or in screen percentage if
	// `ufbx_lod_group.relative_distances` is set.
	display:  Lod_Display, // LOD display mode.
	// NOTE: Mostly for editing, you should probably ignore this
	// unless making a modeling program.
}

Lod_Level_List :: struct {
	data:  ^Lod_Level,
	count: c.size_t,
}

// Group of LOD (Level of Detail) levels for an object.
// The actual LOD models are defined in the parent `ufbx_node.children`.
Lod_Group :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
			instances:  Node_List,
		},
	},
	relative_distances:                          bool,           // If set to `true`, `ufbx_lod_level.distance` represents a screen size percentage.
	lod_levels:                                  Lod_Level_List, // LOD levels matching in order to `ufbx_node.children`.
	ignore_parent_transform, use_distance_limit: bool,           // If set to `true` don't account for parent transform when computing the distance.
	distance_limit_min:                          Real,
	distance_limit_max:                          Real,
}

// Method to evaluate the skinning on a per-vertex level
Skinning_Method :: enum c.int {
	LINEAR            = 0,          // Linear blend skinning: Blend transformation matrices by vertex weights
	RIGID             = 1,          // One vertex should have only one bone attached
	DUAL_QUATERNION   = 2,          // Convert the transformations to dual quaternions and blend in that space
	BLENDED_DQ_LINEAR = 3,          // Blend between `UFBX_SKINNING_METHOD_LINEAR` and `UFBX_SKINNING_METHOD_BLENDED_DQ_LINEAR`
	// The blend weight can be found either per-vertex in `ufbx_skin_vertex.dq_weight`
	// or in `ufbx_skin_deformer.dq_vertices/dq_weights` (indexed by vertex).
	FORCE_32BIT       = 2147483647, // Blend between `UFBX_SKINNING_METHOD_LINEAR` and `UFBX_SKINNING_METHOD_BLENDED_DQ_LINEAR`
	// The blend weight can be found either per-vertex in `ufbx_skin_vertex.dq_weight`
	// or in `ufbx_skin_deformer.dq_vertices/dq_weights` (indexed by vertex).
}

SKINNING_METHOD_COUNT :: 4

// Skin weight information for a single mesh vertex
Skin_Vertex :: struct {
	weight_begin, num_weights: u32,  // < Index to start from in the `weights[]` array
	dq_weight:                 Real, // Blend weight between Linear Blend Skinning (0.0) and Dual Quaternion (1.0).
	// Should be used if `skinning_method == UFBX_SKINNING_METHOD_BLENDED_DQ_LINEAR`
}

Skin_Vertex_List :: struct {
	data:  ^Skin_Vertex,
	count: c.size_t,
}

// Single per-vertex per-cluster weight, see `ufbx_skin_vertex`
Skin_Weight :: struct {
	cluster_index: u32,  // < Index into `ufbx_skin_deformer.clusters[]`
	weight:        Real, // < Amount this bone influence the vertex
}

Skin_Weight_List :: struct {
	data:  ^Skin_Weight,
	count: c.size_t,
}

// Skin deformer specifies a binding between a logical set of bones (a skeleton)
// and a mesh. Each bone is represented by a `ufbx_skin_cluster` that contains
// the binding matrix and a `ufbx_node *bone` that has the current transformation.
Skin_Deformer :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	skinning_method:                        Skinning_Method,
	clusters:                               Skin_Cluster_List, // Clusters (bones) in the skin
	vertices:                               Skin_Vertex_List,  // Per-vertex weight information
	weights:                                Skin_Weight_List,
	max_weights_per_vertex, num_dq_weights: c.size_t,          // Largest amount of weights a single vertex can have
	dq_vertices:                            Uint32_List,
	dq_weights:                             Real_List,
}

// Cluster of vertices bound to a single bone.
Skin_Cluster :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	bone_node:                                                             ^Node,       // The bone node the cluster is attached to
	// NOTE: Always valid if found from `ufbx_skin_deformer.clusters[]` unless
	// `ufbx_load_opts.connect_broken_elements` is `true`.
	geometry_to_bone, mesh_node_to_bone, bind_to_world, geometry_to_world: Matrix,      // Binding matrix from local mesh vertices to the bone
	geometry_to_world_transform:                                           Transform,
	num_weights:                                                           c.size_t,    // < Number of vertices in the cluster
	vertices:                                                              Uint32_List, // < Vertex indices in `ufbx_mesh.vertices[]`
	weights:                                                               Real_List,   // < Per-vertex weight values
}

// Blend shape deformer can contain multiple channels (think of sliders between morphs)
// that may optionally have in-between keyframes.
Blend_Deformer :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	channels: Blend_Channel_List, // Independent morph targets of the deformer.
}

// Blend shape associated with a target weight in a series of morphs
Blend_Keyframe :: struct {
	shape:                           ^Blend_Shape, // The target blend shape offsets.
	target_weight, effective_weight: Real,         // Weight value at which to apply the keyframe at full strength
}

Blend_Keyframe_List :: struct {
	data:  ^Blend_Keyframe,
	count: c.size_t,
}

// Blend channel consists of multiple morph-key targets that are interpolated.
// In simple cases there will be only one keyframe that is the target shape.
Blend_Channel :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	weight:       Real,                // Current weight of the channel
	keyframes:    Blend_Keyframe_List, // Key morph targets to blend between depending on `weight`
	// In usual cases there's only one target per channel
	target_shape: ^Blend_Shape,        // Final blend shape ignoring any intermediate blend shapes.
}

// Blend shape target containing the actual vertex offsets
Blend_Shape :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	num_offsets:                      c.size_t,    // < Number of vertex offsets in the following arrays
	offset_vertices:                  Uint32_List, // < Indices to `ufbx_mesh.vertices[]`
	position_offsets, normal_offsets: Vec3_List,   // < Always specified per-vertex offsets
}

Cache_File_Format :: enum c.int {
	UNKNOWN     = 0, // < Unknown cache file format
	PC2         = 1, // < .pc2 Point cache file
	MC          = 2, // < .mc/.mcx Maya cache file
	FORCE_32BIT = 2147483647,
}

CACHE_FILE_FORMAT_COUNT :: 3

Cache_Data_Format :: enum c.int {
	UNKNOWN     = 0, // < Unknown data format
	REAL_FLOAT  = 1, // < `float data[]`
	VEC3_FLOAT  = 2, // < `struct { float x, y, z; } data[]`
	REAL_DOUBLE = 3, // < `double data[]`
	VEC3_DOUBLE = 4, // < `struct { double x, y, z; } data[]`
	FORCE_32BIT = 2147483647,
}

CACHE_DATA_FORMAT_COUNT :: 5

Cache_Data_Encoding :: enum c.int {
	UNKNOWN       = 0, // < Unknown data encoding
	LITTLE_ENDIAN = 1, // < Contiguous little-endian array
	BIG_ENDIAN    = 2, // < Contiguous big-endian array
	FORCE_32BIT   = 2147483647,
}

CACHE_DATA_ENCODING_COUNT :: 3

// Known interpretations of geometry cache data.
Cache_Interpretation :: enum c.int {
	UNKNOWN         = 0,          // Unknown interpretation, see `ufbx_cache_channel.interpretation_name` for more information.
	POINTS          = 1,          // Generic "points" interpretation, FBX SDK default. Usually fine to interpret
	// as vertex positions if no other cache channels are specified.
	VERTEX_POSITION = 2,          // Vertex positions.
	VERTEX_NORMAL   = 3,          // Vertex normals.
	FORCE_32BIT     = 2147483647, // Vertex normals.
}

CACHE_INTERPRETATION_COUNT :: 4

Cache_Frame :: struct {
	channel:                        String,              // Name of the channel this frame belongs to.
	time:                           f64,                 // Time of this frame in seconds.
	filename:                       String,              // Name of the file containing the data.
	// The specified file may contain multiple frames, use `data_offset` etc. to
	// read at the right position.
	file_format:                    Cache_File_Format,   // Format of the wrapper file.
	mirror_axis:                    Mirror_Axis,         // Axis to mirror the read data by.
	scale_factor:                   Real,                // Factor to scale the geometry by.
	data_format:                    Cache_Data_Format,   // < Format of the data in the file
	data_encoding:                  Cache_Data_Encoding, // < Binary encoding of the data
	data_offset:                    u64,                 // < Byte offset into the file
	data_count, data_element_bytes: u32,                 // < Number of data elements
	data_total_bytes:               u64,                 // < Size of the whole data blob in bytes
}

Cache_Frame_List :: struct {
	data:  ^Cache_Frame,
	count: c.size_t,
}

Cache_Channel :: struct {
	name:                String,               // Name of the geometry cache channel.
	interpretation:      Cache_Interpretation, // What does the data in this channel represent.
	interpretation_name: String,               // Source name for `interpretation`, especially useful if `interpretation` is
	// `UFBX_CACHE_INTERPRETATION_UNKNOWN`.
	frames:              Cache_Frame_List,     // List of frames belonging to this channel.
	// Sorted by time (`ufbx_cache_frame.time`).
	mirror_axis:         Mirror_Axis,          // Axis to mirror the frames by.
	scale_factor:        Real,                 // Factor to scale the geometry by.
}

Cache_Channel_List :: struct {
	data:  ^Cache_Channel,
	count: c.size_t,
}

Geometry_Cache :: struct {
	root_filename: String,
	channels:      Cache_Channel_List,
	frames:        Cache_Frame_List,
	extra_info:    String_List,
}

Cache_Deformer :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	channel:          String,
	file:             ^Cache_File,
	external_cache:   ^Geometry_Cache, // Only valid if `ufbx_load_opts.load_external_files` is set!
	external_channel: ^Cache_Channel,
}

Cache_File :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	filename, absolute_filename, relative_filename:             String,          // Filename relative to the currently loaded file.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	raw_filename, raw_absolute_filename, raw_relative_filename: Blob,            // Filename relative to the loaded file, non-UTF-8 encoded.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	format:                                                     Cache_File_Format,
	external_cache:                                             ^Geometry_Cache, // Only valid if `ufbx_load_opts.load_external_files` is set!
}

// Material property, either specified with a constant value or a mapped texture
Material_Map :: struct {
	// Constant value or factor for the map.
	// May be specified simultaneously with a texture, in this case most shading models
	// use multiplicative tinting of the texture values.
	using _: struct #raw_union {
		value_real: Real,
		value_vec2: Vec2,
		value_vec3: Vec3,
		value_vec4: Vec4,
	},
	value_int:                                    i64,
	texture:                                      ^Texture, // Texture if connected, otherwise `NULL`.
	// May be valid but "disabled" (application specific) if `texture_enabled == false`.
	has_value, texture_enabled, feature_disabled: bool,     // `true` if the file has specified any of the values above.
	// NOTE: The value may be set to a non-zero default even if `has_value == false`,
	// for example missing factors are set to `1.0` if a color is defined.
	value_components:                             u8,       // Number of components in the value from 1 to 4 if defined, 0 if not.
}

// Material feature
Material_Feature_Info :: struct {
	enabled, is_explicit: bool, // Whether the material model uses this feature or not.
	// NOTE: The feature can be enabled but still not used if eg. the corresponding factor is at zero!
}

// Texture attached to an FBX property
Material_Texture :: struct {
	material_prop, shader_prop: String,   // < Name of the property in `ufbx_material.props`
	texture:                    ^Texture, // Texture attached to the property.
}

Material_Texture_List :: struct {
	data:  ^Material_Texture,
	count: c.size_t,
}

// Shading model type
Shader_Type :: enum c.int {
	UNKNOWN                   = 0,          // Unknown shading model
	FBX_LAMBERT               = 1,          // FBX builtin diffuse material
	FBX_PHONG                 = 2,          // FBX builtin diffuse+specular material
	OSL_STANDARD_SURFACE      = 3,          // Open Shading Language standard surface
	// https://github.com/Autodesk/standard-surface
	ARNOLD_STANDARD_SURFACE   = 4,          // Arnold standard surface
	// https://docs.arnoldrenderer.com/display/A5AFMUG/Standard+Surface
	_3DS_MAX_PHYSICAL_MATERIAL = 5,         // 3ds Max Physical Material
	// https://knowledge.autodesk.com/support/3ds-max/learn-explore/caas/CloudHelp/cloudhelp/2022/ENU/3DSMax-Lighting-Shading/files/GUID-C1328905-7783-4917-AB86-FC3CC19E8972-htm.html
	_3DS_MAX_PBR_METAL_ROUGH  = 6,          // 3ds Max PBR (Metal/Rough) material
	// https://knowledge.autodesk.com/support/3ds-max/learn-explore/caas/CloudHelp/cloudhelp/2021/ENU/3DSMax-Lighting-Shading/files/GUID-A16234A5-6500-4662-8B20-A5EC9FE1B255-htm.html
	_3DS_MAX_PBR_SPEC_GLOSS   = 7,          // 3ds Max PBR (Spec/Gloss) material
	// https://knowledge.autodesk.com/support/3ds-max/learn-explore/caas/CloudHelp/cloudhelp/2021/ENU/3DSMax-Lighting-Shading/files/GUID-18087194-B2A6-43EF-9B80-8FD1736FAE52-htm.html
	GLTF_MATERIAL             = 8,          // 3ds glTF Material
	// https://help.autodesk.com/view/3DSMAX/2023/ENU/?guid=GUID-7ABFB805-1D9F-417E-9C22-704BFDF160FA
	OPENPBR_MATERIAL          = 9,          // 3ds OpenPBR Material
	// https://help.autodesk.com/view/3DSMAX/2025/ENU/?guid=GUID-CD90329C-1E2B-4BBA-9285-3BB46253B9C2
	SHADERFX_GRAPH            = 10,         // Stingray ShaderFX shader graph.
	// Contains a serialized `"ShaderGraph"` in `ufbx_props`.
	BLENDER_PHONG             = 11,         // Variation of the FBX phong shader that can recover PBR properties like
	// `metalness` or `roughness` from the FBX non-physical values.
	// NOTE: Enable `ufbx_load_opts.use_blender_pbr_material`.
	WAVEFRONT_MTL             = 12,         // Wavefront .mtl format shader (used by .obj files)
	TYPE_FORCE_32BIT          = 2147483647, // Wavefront .mtl format shader (used by .obj files)
}

SHADER_TYPE_COUNT :: 13

// FBX builtin material properties, matches maps in `ufbx_material_fbx_maps`
Material_Fbx_Map :: enum c.int {
	DIFFUSE_FACTOR             = 0,
	DIFFUSE_COLOR              = 1,
	SPECULAR_FACTOR            = 2,
	SPECULAR_COLOR             = 3,
	SPECULAR_EXPONENT          = 4,
	REFLECTION_FACTOR          = 5,
	REFLECTION_COLOR           = 6,
	TRANSPARENCY_FACTOR        = 7,
	TRANSPARENCY_COLOR         = 8,
	EMISSION_FACTOR            = 9,
	EMISSION_COLOR             = 10,
	AMBIENT_FACTOR             = 11,
	AMBIENT_COLOR              = 12,
	NORMAL_MAP                 = 13,
	BUMP                       = 14,
	BUMP_FACTOR                = 15,
	DISPLACEMENT_FACTOR        = 16,
	DISPLACEMENT               = 17,
	VECTOR_DISPLACEMENT_FACTOR = 18,
	VECTOR_DISPLACEMENT        = 19,
	MAP_FORCE_32BIT            = 2147483647,
}

MATERIAL_FBX_MAP_COUNT :: 20

// Known PBR material properties, matches maps in `ufbx_material_pbr_maps`
Material_Pbr_Map :: enum c.int {
	BASE_FACTOR                     = 0,
	BASE_COLOR                      = 1,
	ROUGHNESS                       = 2,
	METALNESS                       = 3,
	DIFFUSE_ROUGHNESS               = 4,
	SPECULAR_FACTOR                 = 5,
	SPECULAR_COLOR                  = 6,
	SPECULAR_IOR                    = 7,
	SPECULAR_ANISOTROPY             = 8,
	SPECULAR_ROTATION               = 9,
	TRANSMISSION_FACTOR             = 10,
	TRANSMISSION_COLOR              = 11,
	TRANSMISSION_DEPTH              = 12,
	TRANSMISSION_SCATTER            = 13,
	TRANSMISSION_SCATTER_ANISOTROPY = 14,
	TRANSMISSION_DISPERSION         = 15,
	TRANSMISSION_ROUGHNESS          = 16,
	TRANSMISSION_EXTRA_ROUGHNESS    = 17,
	TRANSMISSION_PRIORITY           = 18,
	TRANSMISSION_ENABLE_IN_AOV      = 19,
	SUBSURFACE_FACTOR               = 20,
	SUBSURFACE_COLOR                = 21,
	SUBSURFACE_RADIUS               = 22,
	SUBSURFACE_SCALE                = 23,
	SUBSURFACE_ANISOTROPY           = 24,
	SUBSURFACE_TINT_COLOR           = 25,
	SUBSURFACE_TYPE                 = 26,
	SHEEN_FACTOR                    = 27,
	SHEEN_COLOR                     = 28,
	SHEEN_ROUGHNESS                 = 29,
	COAT_FACTOR                     = 30,
	COAT_COLOR                      = 31,
	COAT_ROUGHNESS                  = 32,
	COAT_IOR                        = 33,
	COAT_ANISOTROPY                 = 34,
	COAT_ROTATION                   = 35,
	COAT_NORMAL                     = 36,
	COAT_AFFECT_BASE_COLOR          = 37,
	COAT_AFFECT_BASE_ROUGHNESS      = 38,
	THIN_FILM_FACTOR                = 39,
	THIN_FILM_THICKNESS             = 40,
	THIN_FILM_IOR                   = 41,
	EMISSION_FACTOR                 = 42,
	EMISSION_COLOR                  = 43,
	OPACITY                         = 44,
	INDIRECT_DIFFUSE                = 45,
	INDIRECT_SPECULAR               = 46,
	NORMAL_MAP                      = 47,
	TANGENT_MAP                     = 48,
	DISPLACEMENT_MAP                = 49,
	MATTE_FACTOR                    = 50,
	MATTE_COLOR                     = 51,
	AMBIENT_OCCLUSION               = 52,
	GLOSSINESS                      = 53,
	COAT_GLOSSINESS                 = 54,
	TRANSMISSION_GLOSSINESS         = 55,
	MAP_FORCE_32BIT                 = 2147483647,
}

MATERIAL_PBR_MAP_COUNT :: 56

// Known material features
Material_Feature :: enum c.int {
	PBR                                  = 0,
	METALNESS                            = 1,
	DIFFUSE                              = 2,
	SPECULAR                             = 3,
	EMISSION                             = 4,
	TRANSMISSION                         = 5,
	COAT                                 = 6,
	SHEEN                                = 7,
	OPACITY                              = 8,
	AMBIENT_OCCLUSION                    = 9,
	MATTE                                = 10,
	UNLIT                                = 11,
	IOR                                  = 12,
	DIFFUSE_ROUGHNESS                    = 13,
	TRANSMISSION_ROUGHNESS               = 14,
	THIN_WALLED                          = 15,
	CAUSTICS                             = 16,
	EXIT_TO_BACKGROUND                   = 17,
	INTERNAL_REFLECTIONS                 = 18,
	DOUBLE_SIDED                         = 19,
	ROUGHNESS_AS_GLOSSINESS              = 20,
	COAT_ROUGHNESS_AS_GLOSSINESS         = 21,
	TRANSMISSION_ROUGHNESS_AS_GLOSSINESS = 22,
	FORCE_32BIT                          = 2147483647,
}

MATERIAL_FEATURE_COUNT :: 23

Material_Fbx_Maps :: struct {
	using _: struct #raw_union {
		maps: [20]Material_Map,
		using _: struct {
			diffuse_factor:             Material_Map,
			diffuse_color:              Material_Map,
			specular_factor:            Material_Map,
			specular_color:             Material_Map,
			specular_exponent:          Material_Map,
			reflection_factor:          Material_Map,
			reflection_color:           Material_Map,
			transparency_factor:        Material_Map,
			transparency_color:         Material_Map,
			emission_factor:            Material_Map,
			emission_color:             Material_Map,
			ambient_factor:             Material_Map,
			ambient_color:              Material_Map,
			normal_map:                 Material_Map,
			bump:                       Material_Map,
			bump_factor:                Material_Map,
			displacement_factor:        Material_Map,
			displacement:               Material_Map,
			vector_displacement_factor: Material_Map,
			vector_displacement:        Material_Map,
		},
	},
}

Material_Pbr_Maps :: struct {
	using _: struct #raw_union {
		maps: [56]Material_Map,
		using _: struct {
			base_factor:                     Material_Map,
			base_color:                      Material_Map,
			roughness:                       Material_Map,
			metalness:                       Material_Map,
			diffuse_roughness:               Material_Map,
			specular_factor:                 Material_Map,
			specular_color:                  Material_Map,
			specular_ior:                    Material_Map,
			specular_anisotropy:             Material_Map,
			specular_rotation:               Material_Map,
			transmission_factor:             Material_Map,
			transmission_color:              Material_Map,
			transmission_depth:              Material_Map,
			transmission_scatter:            Material_Map,
			transmission_scatter_anisotropy: Material_Map,
			transmission_dispersion:         Material_Map,
			transmission_roughness:          Material_Map,
			transmission_extra_roughness:    Material_Map,
			transmission_priority:           Material_Map,
			transmission_enable_in_aov:      Material_Map,
			subsurface_factor:               Material_Map,
			subsurface_color:                Material_Map,
			subsurface_radius:               Material_Map,
			subsurface_scale:                Material_Map,
			subsurface_anisotropy:           Material_Map,
			subsurface_tint_color:           Material_Map,
			subsurface_type:                 Material_Map,
			sheen_factor:                    Material_Map,
			sheen_color:                     Material_Map,
			sheen_roughness:                 Material_Map,
			coat_factor:                     Material_Map,
			coat_color:                      Material_Map,
			coat_roughness:                  Material_Map,
			coat_ior:                        Material_Map,
			coat_anisotropy:                 Material_Map,
			coat_rotation:                   Material_Map,
			coat_normal:                     Material_Map,
			coat_affect_base_color:          Material_Map,
			coat_affect_base_roughness:      Material_Map,
			thin_film_factor:                Material_Map,
			thin_film_thickness:             Material_Map,
			thin_film_ior:                   Material_Map,
			emission_factor:                 Material_Map,
			emission_color:                  Material_Map,
			opacity:                         Material_Map,
			indirect_diffuse:                Material_Map,
			indirect_specular:               Material_Map,
			normal_map:                      Material_Map,
			tangent_map:                     Material_Map,
			displacement_map:                Material_Map,
			matte_factor:                    Material_Map,
			matte_color:                     Material_Map,
			ambient_occlusion:               Material_Map,
			glossiness:                      Material_Map,
			coat_glossiness:                 Material_Map,
			transmission_glossiness:         Material_Map,
		},
	},
}

Material_Features :: struct {
	using _: struct #raw_union {
		features: [23]Material_Feature_Info,
		using _: struct {
			pbr:                                  Material_Feature_Info,
			metalness:                            Material_Feature_Info,
			diffuse:                              Material_Feature_Info,
			specular:                             Material_Feature_Info,
			emission:                             Material_Feature_Info,
			transmission:                         Material_Feature_Info,
			coat:                                 Material_Feature_Info,
			sheen:                                Material_Feature_Info,
			opacity:                              Material_Feature_Info,
			ambient_occlusion:                    Material_Feature_Info,
			matte:                                Material_Feature_Info,
			unlit:                                Material_Feature_Info,
			ior:                                  Material_Feature_Info,
			diffuse_roughness:                    Material_Feature_Info,
			transmission_roughness:               Material_Feature_Info,
			thin_walled:                          Material_Feature_Info,
			caustics:                             Material_Feature_Info,
			exit_to_background:                   Material_Feature_Info,
			internal_reflections:                 Material_Feature_Info,
			double_sided:                         Material_Feature_Info,
			roughness_as_glossiness:              Material_Feature_Info,
			coat_roughness_as_glossiness:         Material_Feature_Info,
			transmission_roughness_as_glossiness: Material_Feature_Info,
		},
	},
}

// Surface material properties such as color, roughness, etc. Each property may
// be optionally bound to an `ufbx_texture`.
Material :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	fbx:                                    Material_Fbx_Maps,     // FBX builtin properties
	// NOTE: These may be empty if the material is using a custom shader
	pbr:                                    Material_Pbr_Maps,     // PBR material properties, defined for all shading models but may be
	// somewhat approximate if `shader == NULL`.
	features:                               Material_Features,     // Material features, primarily applies to `pbr`.
	shader_type:                            Shader_Type,           // < Always defined
	shader:                                 ^Shader,               // < Optional extended shader information
	shading_model_name, shader_prop_prefix: String,                // < Often one of `{ "lambert", "phong", "unknown" }`
	textures:                               Material_Texture_List, // < Sorted by `material_prop`
}

Texture_Type :: enum c.int {
	FILE             = 0,          // Texture associated with an image file/sequence. `texture->filename` and
	// and `texture->relative_filename` contain the texture's path. If the file
	// has embedded content `texture->content` may hold `texture->content_size`
	// bytes of raw image data.
	LAYERED          = 1,          // The texture consists of multiple texture layers blended together.
	PROCEDURAL       = 2,          // Reserved as these _should_ exist in FBX files.
	SHADER           = 3,          // Node in a shader graph.
	// Use `ufbx_texture.shader` for more information.
	TYPE_FORCE_32BIT = 2147483647, // Node in a shader graph.
	// Use `ufbx_texture.shader` for more information.
}

TEXTURE_TYPE_COUNT :: 4

// Blend modes to combine layered textures with, compatible with common blend
// mode definitions in many art programs. Simpler blend modes have equations
// specified below where `src` is the layer to composite over `dst`.
// See eg. https://www.w3.org/TR/2013/WD-compositing-1-20131010/#blendingseparable
Blend_Mode :: enum c.int {
	TRANSLUCENT      = 0,  // < `src` effects result alpha
	ADDITIVE         = 1,  // < `src + dst`
	MULTIPLY         = 2,  // < `src * dst`
	MULTIPLY_2X      = 3,  // < `2 * src * dst`
	OVER             = 4,  // < `src * src_alpha + dst * (1-src_alpha)`
	REPLACE          = 5,  // < `src` Replace the contents
	DISSOLVE         = 6,  // < `random() + src_alpha >= 1.0 ? src : dst`
	DARKEN           = 7,  // < `min(src, dst)`
	COLOR_BURN       = 8,  // < `src > 0 ? 1 - min(1, (1-dst) / src) : 0`
	LINEAR_BURN      = 9,  // < `src + dst - 1`
	DARKER_COLOR     = 10, // < `value(src) < value(dst) ? src : dst`
	LIGHTEN          = 11, // < `max(src, dst)`
	SCREEN           = 12, // < `1 - (1-src)*(1-dst)`
	COLOR_DODGE      = 13, // < `src < 1 ? dst / (1 - src)` : (dst>0?1:0)`
	LINEAR_DODGE     = 14, // < `src + dst`
	LIGHTER_COLOR    = 15, // < `value(src) > value(dst) ? src : dst`
	SOFT_LIGHT       = 16, // < https://www.w3.org/TR/2013/WD-compositing-1-20131010/#blendingsoftlight
	HARD_LIGHT       = 17, // < https://www.w3.org/TR/2013/WD-compositing-1-20131010/#blendinghardlight
	VIVID_LIGHT      = 18, // < Combination of `COLOR_DODGE` and `COLOR_BURN`
	LINEAR_LIGHT     = 19, // < Combination of `LINEAR_DODGE` and `LINEAR_BURN`
	PIN_LIGHT        = 20, // < Combination of `DARKEN` and `LIGHTEN`
	HARD_MIX         = 21, // < Produces primary colors depending on similarity
	DIFFERENCE       = 22, // < `abs(src - dst)`
	EXCLUSION        = 23, // < `dst + src - 2 * src * dst`
	SUBTRACT         = 24, // < `dst - src`
	DIVIDE           = 25, // < `dst / src`
	HUE              = 26, // < Replace hue
	SATURATION       = 27, // < Replace saturation
	COLOR            = 28, // < Replace hue and saturatio
	LUMINOSITY       = 29, // < Replace value
	OVERLAY          = 30, // < Same as `HARD_LIGHT` but with `src` and `dst` swapped
	MODE_FORCE_32BIT = 2147483647,
}

BLEND_MODE_COUNT :: 31

// Blend modes to combine layered textures with, compatible with common blend
Wrap_Mode :: enum c.int {
	REPEAT           = 0, // < Repeat the texture past the [0,1] range
	CLAMP            = 1, // < Clamp the normalized texture coordinates to [0,1]
	MODE_FORCE_32BIT = 2147483647,
}

WRAP_MODE_COUNT :: 2

// Single layer in a layered texture
Texture_Layer :: struct {
	texture:    ^Texture,   // < The inner texture to evaluate, never `NULL`
	blend_mode: Blend_Mode, // < Equation to combine the layer to the background
	alpha:      Real,       // < Blend weight of this layer
}

Texture_Layer_List :: struct {
	data:  ^Texture_Layer,
	count: c.size_t,
}

Shader_Texture_Type :: enum c.int {
	UNKNOWN          = 0,
	SELECT_OUTPUT    = 1,          // Select an output of a multi-output shader.
	// HINT: If this type is used the `ufbx_shader_texture.main_texture` and
	// `ufbx_shader_texture.main_texture_output_index` fields are set.
	OSL              = 2,          // Open Shading Language (OSL) shader.
	// https://github.com/AcademySoftwareFoundation/OpenShadingLanguage
	TYPE_FORCE_32BIT = 2147483647, // Open Shading Language (OSL) shader.
	// https://github.com/AcademySoftwareFoundation/OpenShadingLanguage
}

SHADER_TEXTURE_TYPE_COUNT :: 3

// Input to a shader texture, see `ufbx_shader_texture`.
Shader_Texture_Input :: struct {
	name:                                     String,   // Name of the input.

	// Constant value of the input.
	using _: struct #raw_union {
		value_real: Real,
		value_vec2: Vec2,
		value_vec3: Vec3,
		value_vec4: Vec4,
	},
	value_int:                                i64,
	value_str:                                String,
	value_blob:                               Blob,
	texture:                                  ^Texture, // Texture connected to this input.
	texture_output_index:                     i64,      // Index of the output to use if `texture` is a multi-output shader node.
	texture_enabled:                          bool,     // Controls whether shading should use `texture`.
	// NOTE: Some shading models allow this to be `true` even if `texture == NULL`.
	prop, texture_prop, texture_enabled_prop: ^Prop,    // Property representing this input.
}

Shader_Texture_Input_List :: struct {
	data:  ^Shader_Texture_Input,
	count: c.size_t,
}

// Texture that emulates a shader graph node.
// 3ds Max exports some materials as node graphs serialized to textures.
// ufbx can parse a small subset of these, as normal maps are often hidden behind
// some kind of bump node.
// NOTE: These encode a lot of details of 3ds Max internals, not recommended for direct use.
// HINT: `ufbx_texture.file_textures[]` contains a list of "real" textures that are connected
// to the `ufbx_texture` that is pretending to be a shader node.
Shader_Texture :: struct {
	type:                      Shader_Texture_Type,       // Type of this shader node.
	shader_name:               String,                    // Name of the shader to use.
	shader_type_id:            u64,                       // 64-bit opaque identifier for the shader type.
	inputs:                    Shader_Texture_Input_List, // Input values/textures (possibly further shader textures) to the shader.
	// Sorted by `ufbx_shader_texture_input.name`.
	shader_source:             String,                    // Shader source code if found.
	raw_shader_source:         Blob,
	main_texture:              ^Texture,                  // Representative texture for this shader.
	// Only specified if `main_texture.outputs[main_texture_output_index]` is semantically
	// equivalent to this texture.
	main_texture_output_index: i64,                       // Output index of `main_texture` if it is a multi-output shader.
	prop_prefix:               String,                    // Prefix for properties related to this shader in `ufbx_texture`.
	// NOTE: Contains the trailing '|' if not empty.
}

// Unique texture within the file.
Texture_File :: struct {
	index:                                                               u32,    // Index in `ufbx_scene.texture_files[]`.
	filename, absolute_filename, relative_filename:                      String, // Filename relative to the currently loaded file.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	raw_filename, raw_absolute_filename, raw_relative_filename, content: Blob,   // Filename relative to the loaded file, non-UTF-8 encoded.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
}

Texture_File_List :: struct {
	data:  ^Texture_File,
	count: c.size_t,
}

// Texture that controls material appearance
Texture :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	type:                                                                Texture_Type,       // Texture type (file / layered / procedural / shader)
	filename, absolute_filename, relative_filename:                      String,             // Filename relative to the currently loaded file.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	raw_filename, raw_absolute_filename, raw_relative_filename, content: Blob,               // Filename relative to the loaded file, non-UTF-8 encoded.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	video:                                                               ^Video,             // FILE: Optional video texture
	file_index:                                                          u32,                // FILE: Index into `ufbx_scene.texture_files[]` or `UFBX_NO_INDEX`.
	has_file:                                                            bool,               // FILE: True if `file_index` has a valid value.
	layers:                                                              Texture_Layer_List, // LAYERED: Inner texture layers, ordered from _bottom_ to _top_
	shader:                                                              ^Shader_Texture,    // SHADER: Shader information
	// NOTE: May be specified even if `type == UFBX_TEXTURE_FILE` if `ufbx_load_opts.disable_quirks`
	// is _not_ specified. Some known shaders that represent files are interpreted as `UFBX_TEXTURE_FILE`.
	file_textures:                                                       Texture_List,       // List of file textures representing this texture.
	// Defined even if `type == UFBX_TEXTURE_FILE` in which case the array contains only itself.
	uv_set:                                                              String,             // Name of the UV set to use
	wrap_u, wrap_v:                                                      Wrap_Mode,          // Wrapping mode
	has_uv_transform:                                                    bool,               // < Has a non-identity `transform` and derived matrices.
	uv_transform:                                                        Transform,          // < Texture transformation in UV space
	texture_to_uv, uv_to_texture:                                        Matrix,             // < Matrix representation of `transform`
}

// TODO: Video textures
Video :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	filename, absolute_filename, relative_filename:                      String, // Filename relative to the currently loaded file.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	raw_filename, raw_absolute_filename, raw_relative_filename, content: Blob,   // Filename relative to the loaded file, non-UTF-8 encoded.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
}

// Shader specifies a shading model and contains `ufbx_shader_binding` elements
// that define how to interpret FBX properties in the shader.
Shader :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	type:     Shader_Type,         // Known shading model
	bindings: Shader_Binding_List, // Bindings from FBX properties to the shader
	// HINT: `ufbx_find_shader_prop()` translates shader properties to FBX properties
}

// Binding from a material property to shader implementation
Shader_Prop_Binding :: struct {
	shader_prop, material_prop: String, // < Property name used by the shader implementation
}

Shader_Prop_Binding_List :: struct {
	data:  ^Shader_Prop_Binding,
	count: c.size_t,
}

// Shader binding table
Shader_Binding :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	prop_bindings: Shader_Prop_Binding_List, // < Sorted by `shader_prop`
}

// -- Animation
Prop_Override :: struct {
	element_id:    u32,
	_internal_key: u32,
	prop_name:     String,
	value:         Vec4,
	value_str:     String,
	value_int:     i64,
}

Prop_Override_List :: struct {
	data:  ^Prop_Override,
	count: c.size_t,
}

Transform_Override :: struct {
	node_id:   u32,
	transform: Transform,
}

Transform_Override_List :: struct {
	data:  ^Transform_Override,
	count: c.size_t,
}

// Animation descriptor used for evaluating animation.
// Usually obtained from `ufbx_scene` via either global animation `ufbx_scene.anim`,
// per-stack animation `ufbx_anim_stack.anim` or per-layer animation `ufbx_anim_layer.anim`.
//
// For advanced usage you can use `ufbx_create_anim()` to create animation descriptors
// with custom layers, property overrides, special flags, etc.
Anim :: struct {
	time_begin, time_end:       f64,                     // Time begin/end for the animation, both may be zero if absent.
	layers:                     Anim_Layer_List,         // List of layers in the animation.
	override_layer_weights:     Real_List,               // Optional overrides for weights for each layer in `layers[]`.
	prop_overrides:             Prop_Override_List,      // Sorted by `element_id, prop_name`
	transform_overrides:        Transform_Override_List, // Sorted by `node_id`
	ignore_connections, custom: bool,                    // Evaluate connected properties as if they would not be connected.
}

Anim_Stack :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	time_begin: f64,
	time_end:   f64,
	layers:     Anim_Layer_List,
	anim:       ^Anim,
}

Anim_Prop :: struct {
	element:       ^Element,
	_internal_key: u32,
	prop_name:     String,
	anim_value:    ^Anim_Value,
}

Anim_Prop_List :: struct {
	data:  ^Anim_Prop,
	count: c.size_t,
}

Anim_Layer :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	weight:              Real,
	weight_is_animated:  bool,
	blended:             bool,
	additive:            bool,
	compose_rotation:    bool,
	compose_scale:       bool,
	anim_values:         Anim_Value_List,
	anim_props:          Anim_Prop_List, // < Sorted by `element,prop_name`
	anim:                ^Anim,
	_min_element_id:     u32,
	_max_element_id:     u32,
	_element_id_bitmask: [4]u32,
}

Anim_Value :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	default_value: Vec3,
	curves:        [3]^Anim_Curve,
}

// Animation curve segment interpolation mode between two keyframes
Interpolation :: enum c.int {
	CONSTANT_PREV = 0, // < Hold previous key value
	CONSTANT_NEXT = 1, // < Hold next key value
	LINEAR        = 2, // < Linear interpolation between two keys
	CUBIC         = 3, // < Cubic interpolation, see `ufbx_tangent`
	FORCE_32BIT   = 2147483647,
}

INTERPOLATION_COUNT :: 4

Extrapolation_Mode :: enum c.int {
	CONSTANT        = 0, // < Use the value of the first/last keyframe
	REPEAT          = 1, // < Repeat the whole animation curve
	MIRROR          = 2, // < Repeat with mirroring
	SLOPE           = 3, // < Use the tangent of the last keyframe to linearly extrapolate
	REPEAT_RELATIVE = 4, // < Repeat the animation curve but connect the first and last keyframe values
	FORCE_32BIT     = 2147483647,
}

EXTRAPOLATION_MODE_COUNT :: 5

Extrapolation :: struct {
	mode:         Extrapolation_Mode,
	repeat_count: i32, // Count used for repeating modes.
	// Negative values mean infinite repetition.
}

// Tangent vector at a keyframe, may be split into left/right
Tangent :: struct {
	dx, dy: f32, // < Derivative in the time axis
}

// Single real `value` at a specified `time`, interpolation between two keyframes
// is determined by the `interpolation` field of the _previous_ key.
// If `interpolation == UFBX_INTERPOLATION_CUBIC` the span is evaluated as a
// cubic bezier curve through the following points:
//
//   (prev->time, prev->value)
//   (prev->time + prev->right.dx, prev->value + prev->right.dy)
//   (next->time - next->left.dx, next->value - next->left.dy)
//   (next->time, next->value)
//
// HINT: You can use `ufbx_evaluate_curve(ufbx_anim_curve *curve, double time)`
// rather than trying to manually handle all the interpolation modes.
Keyframe :: struct {
	time:          f64,
	value:         Real,
	interpolation: Interpolation,
	left:          Tangent,
	right:         Tangent,
}

Keyframe_List :: struct {
	data:  ^Keyframe,
	count: c.size_t,
}

Anim_Curve :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	keyframes:                             Keyframe_List, // List of keyframes that define the curve.
	pre_extrapolation, post_extrapolation: Extrapolation, // Extrapolation before the curve.
	min_value, max_value:                  Real,          // Value range for all the keyframes.
	min_time, max_time:                    f64,           // Time range for all the keyframes.
}

// Collection of nodes to hide/freeze
Display_Layer :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	nodes:           Node_List, // Nodes included in the layer (exclusively at most one layer per node)
	visible, frozen: bool,      // < Contained nodes are visible
	ui_color:        Vec3,      // < Visual color for UI
}

// Named set of nodes/geometry features to select.
Selection_Set :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	nodes: Selection_Node_List, // Included nodes and geometry features
}

// Selection state of a node, potentially contains vertex/edge/face selection as well.
Selection_Node :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	target_node:            ^Node,       // Selection targets, possibly `NULL`
	target_mesh:            ^Mesh,
	include_node:           bool,        // < Is `target_node` included in the selection
	vertices, edges, faces: Uint32_List, // < Indices to `ufbx_mesh.vertices`
}

// -- Constraints
Character :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
}

// Type of property constrain eg. position or look-at
Constraint_Type :: enum c.int {
	UNKNOWN          = 0,
	AIM              = 1,
	PARENT           = 2,
	POSITION         = 3,
	ROTATION         = 4,
	SCALE            = 5,
	SINGLE_CHAIN_IK  = 6,          // Inverse kinematic chain to a single effector `ufbx_constraint.ik_effector`
	// `targets` optionally contains a list of pole targets!
	TYPE_FORCE_32BIT = 2147483647, // Inverse kinematic chain to a single effector `ufbx_constraint.ik_effector`
	// `targets` optionally contains a list of pole targets!
}

CONSTRAINT_TYPE_COUNT :: 7

// Target to follow with a constraint
Constraint_Target :: struct {
	node:      ^Node,     // < Target node reference
	weight:    Real,      // < Relative weight to other targets (does not always sum to 1)
	transform: Transform, // < Offset from the actual target
}

Constraint_Target_List :: struct {
	data:  ^Constraint_Target,
	count: c.size_t,
}

// Method to determine the up vector in aim constraints
Constraint_Aim_Up_Type :: enum c.int {
	SCENE            = 0, // < Align the up vector to the scene global up vector
	TO_NODE          = 1, // < Aim the up vector at `ufbx_constraint.aim_up_node`
	ALIGN_NODE       = 2, // < Copy the up vector from `ufbx_constraint.aim_up_node`
	VECTOR           = 3, // < Use `ufbx_constraint.aim_up_vector` as the up vector
	NONE             = 4, // < Don't align the up vector to anything
	TYPE_FORCE_32BIT = 2147483647,
}

CONSTRAINT_AIM_UP_TYPE_COUNT :: 5

// Method to determine the up vector in aim constraints
Constraint_Ik_Pole_Type :: enum c.int {
	VECTOR           = 0, // < Use towards calculated from `ufbx_constraint.targets`
	NODE             = 1, // < Use `ufbx_constraint.ik_pole_vector` directly
	TYPE_FORCE_32BIT = 2147483647,
}

CONSTRAINT_IK_POLE_TYPE_COUNT :: 2

Constraint :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	type:                                                       Constraint_Type,        // Type of constraint to use
	type_name:                                                  String,
	node:                                                       ^Node,                  // Node to be constrained
	targets:                                                    Constraint_Target_List, // List of weighted targets for the constraint (pole vectors for IK)
	weight:                                                     Real,                   // State of the constraint
	active:                                                     bool,
	constrain_translation, constrain_rotation, constrain_scale: [3]bool,                // Translation/rotation/scale axes the constraint is applied to
	transform_offset:                                           Transform,              // Offset from the constrained position
	aim_vector:                                                 Vec3,                   // AIM: Target and up vectors
	aim_up_type:                                                Constraint_Aim_Up_Type,
	aim_up_node:                                                ^Node,
	aim_up_vector:                                              Vec3,
	ik_effector, ik_end_node:                                   ^Node,                  // SINGLE_CHAIN_IK: Target for the IK, `targets` contains pole vectors!
	ik_pole_vector:                                             Vec3,
}

// -- Audio
Audio_Layer :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	clips: Audio_Clip_List, // Clips contained in this layer.
}

Audio_Clip :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	filename, absolute_filename, relative_filename:                      String, // Filename relative to the currently loaded file.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
	raw_filename, raw_absolute_filename, raw_relative_filename, content: Blob,   // Filename relative to the loaded file, non-UTF-8 encoded.
	// HINT: If using functions other than `ufbx_load_file()`, you can provide
	// `ufbx_load_opts.filename/raw_filename` to let ufbx resolve this.
}

// -- Miscellaneous
Bone_Pose :: struct {
	bone_node:                     ^Node,  // Node to apply the pose to.
	bone_to_world, bone_to_parent: Matrix, // Matrix from node local space to world space.
}

Bone_Pose_List :: struct {
	data:  ^Bone_Pose,
	count: c.size_t,
}

Pose :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
	is_bind_pose: bool,           // Set if this pose is marked as a bind pose.
	bone_poses:   Bone_Pose_List, // List of bone poses.
	// Sorted by `ufbx_node.typed_id`.
}

Metadata_Object :: struct {
	using _: struct #raw_union {
		element: Element,
		using _: struct {
			name:       String,
			props:      Props,
			element_id: u32,
			typed_id:   u32,
		},
	},
}

// -- Named elements
Name_Element :: struct {
	name:          String,
	type:          Element_Type,
	_internal_key: u32,
	element:       ^Element,
}

Name_Element_List :: struct {
	data:  ^Name_Element,
	count: c.size_t,
}

// Scene is the root object loaded by ufbx that everything is accessed from.
Exporter :: enum c.int {
	UNKNOWN        = 0,
	FBX_SDK        = 1,
	BLENDER_BINARY = 2,
	BLENDER_ASCII  = 3,
	MOTION_BUILDER = 4,
	FORCE_32BIT    = 2147483647,
}

EXPORTER_COUNT :: 5

Application :: struct {
	vendor:  String,
	name:    String,
	version: String,
}

File_Format :: enum c.int {
	UNKNOWN     = 0, // < Unknown file format
	FBX         = 1, // < .fbx Kaydara/Autodesk FBX file
	OBJ         = 2, // < .obj Wavefront OBJ file
	MTL         = 3, // < .mtl Wavefront MTL (Material template library) file
	FORCE_32BIT = 2147483647,
}

FILE_FORMAT_COUNT :: 4

Warning_Type :: enum c.int {
	MISSING_EXTERNAL_FILE         = 0,          // Missing external file file (for example .mtl for Wavefront .obj file or a
	// geometry cache)
	IMPLICIT_MTL                  = 1,          // Loaded a Wavefront .mtl file derived from the filename instead of a proper
	// `mtllib` statement.
	TRUNCATED_ARRAY               = 2,          // Truncated array has been auto-expanded.
	MISSING_GEOMETRY_DATA         = 3,          // Geometry data has been defined but has no data.
	DUPLICATE_CONNECTION          = 4,          // Duplicated connection between two elements that shouldn't have.
	BAD_VERTEX_W_ATTRIBUTE        = 5,          // Vertex 'W' attribute length differs from main attribute.
	MISSING_POLYGON_MAPPING       = 6,          // Missing polygon mapping type.
	UNSUPPORTED_VERSION           = 7,          // Unsupported version, loaded but may be incorrect.
	// If the loading fails `UFBX_ERROR_UNSUPPORTED_VERSION` is issued instead.
	INDEX_CLAMPED                 = 8,          // Out-of-bounds index has been clamped to be in-bounds.
	// HINT: You can use `ufbx_index_error_handling` to adjust behavior.
	BAD_UNICODE                   = 9,          // Non-UTF8 encoded strings.
	// HINT: You can use `ufbx_unicode_error_handling` to adjust behavior.
	BAD_BASE64_CONTENT            = 10,         // Invalid base64-encoded embedded content ignored.
	BAD_ELEMENT_CONNECTED_TO_ROOT = 11,         // Non-node element connected to root.
	DUPLICATE_OBJECT_ID           = 12,         // Duplicated object ID in the file, connections will be wrong.
	EMPTY_FACE_REMOVED            = 13,         // Empty face has been removed.
	// Use `ufbx_load_opts.allow_empty_faces` if you want to allow them.
	UNKNOWN_OBJ_DIRECTIVE         = 14,         // Unknown .obj file directive.
	TYPE_FIRST_DEDUPLICATED       = 8,          // Warnings after this one are deduplicated.
	// See `ufbx_warning.count` for how many times they happened.
	TYPE_FORCE_32BIT              = 2147483647, // Warnings after this one are deduplicated.
	// See `ufbx_warning.count` for how many times they happened.
}

WARNING_TYPE_COUNT :: 15

// Warning about a non-fatal issue in the file.
// Often contains information about issues that ufbx has corrected about the
// file but it might indicate something is not working properly.
Warning :: struct {
	type:        Warning_Type, // Type of the warning.
	description: String,       // Description of the warning.
	element_id:  u32,          // The element related to this warning or `UFBX_NO_INDEX` if not related to a specific element.
	count:       c.size_t,     // Number of times this warning was encountered.
}

Warning_List :: struct {
	data:  ^Warning,
	count: c.size_t,
}

Thumbnail_Format :: enum c.int {
	UNKNOWN     = 0, // < Unknown format
	RGB_24      = 1, // < 8-bit RGB pixels, in memory R,G,B
	RGBA_32     = 2, // < 8-bit RGBA pixels, in memory R,G,B,A
	FORCE_32BIT = 2147483647,
}

THUMBNAIL_FORMAT_COUNT :: 3

// Specify how unit / coordinate system conversion should be performed.
// Affects how `ufbx_load_opts.target_axes` and `ufbx_load_opts.target_unit_meters` work,
// has no effect if neither is specified.
Space_Conversion :: enum c.int {
	TRANSFORM_ROOT    = 0,          // Store the space conversion transform in the root node.
	// Sets `ufbx_node.local_transform` of the root node.
	ADJUST_TRANSFORMS = 1,          // Perform the conversion by using "adjust" transforms.
	// Compensates for the transforms using `ufbx_node.adjust_pre_rotation` and
	// `ufbx_node.adjust_pre_scale`. You don't need to account for these unless
	// you are manually building transforms from `ufbx_props`.
	MODIFY_GEOMETRY   = 2,          // Perform the conversion by scaling geometry in addition to adjusting transforms.
	// Compensates transforms like `UFBX_SPACE_CONVERSION_ADJUST_TRANSFORMS` but
	// applies scaling to geometry as well.
	FORCE_32BIT       = 2147483647, // Perform the conversion by scaling geometry in addition to adjusting transforms.
	// Compensates transforms like `UFBX_SPACE_CONVERSION_ADJUST_TRANSFORMS` but
	// applies scaling to geometry as well.
}

SPACE_CONVERSION_COUNT :: 3

// Embedded thumbnail in the file, valid if the dimensions are non-zero.
Thumbnail :: struct {
	props:         Props,
	width, height: u32,              // Extents of the thumbnail
	format:        Thumbnail_Format, // Format of `ufbx_thumbnail.data`.
	data:          Blob,             // Thumbnail pixel data, layout as contiguous rows from bottom to top.
	// See `ufbx_thumbnail.format` for the pixel format.
}

// Miscellaneous data related to the loaded file
Metadata :: struct {
	warnings:                                                                                          Warning_List,     // List of non-fatal warnings about the file.
	// If you need to only check whether a specific warning was triggered you
	// can use `ufbx_metadata.has_warning[]`.
	ascii:                                                                                             bool,             // FBX ASCII file format.
	version:                                                                                           u32,              // FBX version in integer format, eg. 7400 for 7.4.
	file_format:                                                                                       File_Format,      // File format of the source file.
	may_contain_no_index, may_contain_missing_vertex_position, may_contain_broken_elements, is_unsafe: bool,             // Index arrays may contain `UFBX_NO_INDEX` instead of a valid index
	// to indicate gaps.
	has_warning:                                                                                       [15]bool,         // Flag for each possible warning type.
	// See `ufbx_metadata.warnings[]` for detailed warning information.
	creator:                                                                                           String,
	big_endian:                                                                                        bool,
	filename:                                                                                          String,
	relative_root:                                                                                     String,
	raw_filename:                                                                                      Blob,
	raw_relative_root:                                                                                 Blob,
	exporter:                                                                                          Exporter,
	exporter_version:                                                                                  u32,
	scene_props:                                                                                       Props,
	original_application:                                                                              Application,
	latest_application:                                                                                Application,
	thumbnail:                                                                                         Thumbnail,
	geometry_ignored:                                                                                  bool,
	animation_ignored:                                                                                 bool,
	embedded_ignored:                                                                                  bool,
	max_face_triangles:                                                                                c.size_t,
	result_memory_used:                                                                                c.size_t,
	temp_memory_used:                                                                                  c.size_t,
	result_allocs:                                                                                     c.size_t,
	temp_allocs:                                                                                       c.size_t,
	element_buffer_size:                                                                               c.size_t,
	num_shader_textures:                                                                               c.size_t,
	bone_prop_size_unit:                                                                               Real,
	bone_prop_limb_length_relative:                                                                    bool,
	ortho_size_unit:                                                                                   Real,
	ktime_second:                                                                                      i64,              // < One second in internal KTime units
	original_file_path:                                                                                String,
	raw_original_file_path:                                                                            Blob,
	space_conversion:                                                                                  Space_Conversion, // Space conversion method used on the scene.
	root_rotation:                                                                                     Quat,             // Transform that has been applied to root for axis/unit conversion.
	root_scale:                                                                                        Real,
	mirror_axis:                                                                                       Mirror_Axis,      // Axis that the scene has been mirrored by.
	// All geometry has been mirrored in this axis.
	geometry_scale:                                                                                    Real,             // Amount geometry has been scaled.
	// See `UFBX_SPACE_CONVERSION_MODIFY_GEOMETRY`.
}

Time_Mode :: enum c.int {
	DEFAULT         = 0,
	_120_FPS        = 1,
	_100_FPS        = 2,
	_60_FPS         = 3,
	_50_FPS         = 4,
	_48_FPS         = 5,
	_30_FPS         = 6,
	_30_FPS_DROP    = 7,
	NTSC_DROP_FRAME = 8,
	NTSC_FULL_FRAME = 9,
	PAL             = 10,
	_24_FPS         = 11,
	_1000_FPS       = 12,
	FILM_FULL_FRAME = 13,
	CUSTOM          = 14,
	_96_FPS         = 15,
	_72_FPS         = 16,
	_59_94_FPS      = 17,
	FORCE_32BIT     = 2147483647,
}

TIME_MODE_COUNT :: 18

Time_Protocol :: enum c.int {
	SMPTE       = 0,
	FRAME_COUNT = 1,
	DEFAULT     = 2,
	FORCE_32BIT = 2147483647,
}

TIME_PROTOCOL_COUNT :: 3

Snap_Mode :: enum c.int {
	NONE          = 0,
	SNAP          = 1,
	PLAY          = 2,
	SNAP_AND_PLAY = 3,
	FORCE_32BIT   = 2147483647,
}

SNAP_MODE_COUNT :: 4

// Global settings: Axes and time/unit scales
Scene_Settings :: struct {
	props:                Props,
	axes:                 Coordinate_Axes, // Mapping of X/Y/Z axes to world-space directions.
	// HINT: Use `ufbx_load_opts.target_axes` to normalize this.
	// NOTE: This contains the _original_ axes even if you supply `ufbx_load_opts.target_axes`.
	unit_meters:          Real,            // How many meters does a single world-space unit represent.
	// FBX files usually default to centimeters, reported as `0.01` here.
	// HINT: Use `ufbx_load_opts.target_unit_meters` to normalize this.
	frames_per_second:    f64,             // Frames per second the animation is defined at.
	ambient_color:        Vec3,
	default_camera:       String,
	time_mode:            Time_Mode,       // Animation user interface settings.
	// HINT: Use `ufbx_scene_settings.frames_per_second` instead of interpreting these yourself.
	time_protocol:        Time_Protocol,
	snap_mode:            Snap_Mode,
	original_axis_up:     Coordinate_Axis, // Original settings (?)
	original_unit_meters: Real,
}

Scene :: struct {
	metadata:                         Metadata,
	settings:                         Scene_Settings,    // Global settings
	root_node:                        ^Node,             // Node instances in the scene
	anim:                             ^Anim,             // Default animation descriptor
	using _: struct #raw_union {
		using _: struct {
			unknowns:              Unknown_List,
			nodes:                 Node_List,                // Nodes
			meshes:                Mesh_List,                // Node attributes (common)
			lights:                Light_List,
			cameras:               Camera_List,
			bones:                 Bone_List,
			empties:               Empty_List,
			line_curves:           Line_Curve_List,          // Node attributes (curves/surfaces)
			nurbs_curves:          Nurbs_Curve_List,
			nurbs_surfaces:        Nurbs_Surface_List,
			nurbs_trim_surfaces:   Nurbs_Trim_Surface_List,
			nurbs_trim_boundaries: Nurbs_Trim_Boundary_List,
			procedural_geometries: Procedural_Geometry_List, // Node attributes (advanced)
			stereo_cameras:        Stereo_Camera_List,
			camera_switchers:      Camera_Switcher_List,
			markers:               Marker_List,
			lod_groups:            Lod_Group_List,
			skin_deformers:        Skin_Deformer_List,       // Deformers
			skin_clusters:         Skin_Cluster_List,
			blend_deformers:       Blend_Deformer_List,
			blend_channels:        Blend_Channel_List,
			blend_shapes:          Blend_Shape_List,
			cache_deformers:       Cache_Deformer_List,
			cache_files:           Cache_File_List,
			materials:             Material_List,            // Materials
			textures:              Texture_List,
			videos:                Video_List,
			shaders:               Shader_List,
			shader_bindings:       Shader_Binding_List,
			anim_stacks:           Anim_Stack_List,          // Animation
			anim_layers:           Anim_Layer_List,
			anim_values:           Anim_Value_List,
			anim_curves:           Anim_Curve_List,
			display_layers:        Display_Layer_List,       // Collections
			selection_sets:        Selection_Set_List,
			selection_nodes:       Selection_Node_List,
			characters:            Character_List,           // Constraints
			constraints:           Constraint_List,
			audio_layers:          Audio_Layer_List,         // Audio
			audio_clips:           Audio_Clip_List,
			poses:                 Pose_List,                // Miscellaneous
			metadata_objects:      Metadata_Object_List,
		},
		elements_by_type: [42]Element_List,
	},
	texture_files:                    Texture_File_List, // Unique texture files referenced by the scene.
	elements:                         Element_List,      // < Sorted by `id`
	connections_src, connections_dst: Connection_List,   // < Sorted by `src,src_prop`
	elements_by_name:                 Name_Element_List, // Elements sorted by name, type
	dom_root:                         ^Dom_Node,         // Enabled if `ufbx_load_opts.retain_dom == true`.
}

// -- Curves
Curve_Point :: struct {
	valid:      bool,
	position:   Vec3,
	derivative: Vec3,
}

Surface_Point :: struct {
	valid:        bool,
	position:     Vec3,
	derivative_u: Vec3,
	derivative_v: Vec3,
}

// -- Mesh topology
Topo_Flags :: enum c.int {
	NON_MANIFOLD      = 1, // < Edge with three or more faces
	FLAGS_FORCE_32BIT = 2147483647,
}

Topo_Edge :: struct {
	index, next, prev, twin, face, edge: u32, // < Starting index of the edge, always defined
	flags:                               Topo_Flags,
}

// Vertex data array for `ufbx_generate_indices()`.
// NOTE: `ufbx_generate_indices()` compares the vertices using `memcmp()`, so
// any padding should be cleared to zero.
Vertex_Stream :: struct {
	data:                      rawptr,   // < Data pointer of shape `char[vertex_count][vertex_size]`.
	vertex_count, vertex_size: c.size_t, // < Number of vertices in this stream, for sanity checking.
}

// Allocate `size` bytes, must be at least 8 byte aligned
Alloc_Fn :: proc "c" (rawptr, c.size_t) -> rawptr

// Reallocate `old_ptr` from `old_size` to `new_size`
// NOTE: If omit `alloc_fn` and `free_fn` they will be translated to:
//   `alloc(size)` -> `realloc_fn(user, NULL, 0, size)`
//   `free_fn(ptr, size)` ->  `realloc_fn(user, ptr, size, 0)`
Realloc_Fn :: proc "c" (rawptr, rawptr, c.size_t, c.size_t) -> rawptr

// Free pointer `ptr` (of `size` bytes) returned by `alloc_fn` or `realloc_fn`
Free_Fn :: proc "c" (rawptr, rawptr, c.size_t)

// Free the allocator itself
Free_Allocator_Fn :: proc "c" (rawptr)

// Allocator callbacks and user context
// NOTE: The allocator will be stored to the loaded scene and will be called
// again from `ufbx_free_scene()` so make sure `user` outlives that!
// You can use `free_allocator_fn()` to free the allocator yourself.
Allocator :: struct {
	alloc_fn:          Alloc_Fn, // Callback functions, see `typedef`s above for information
	realloc_fn:        Realloc_Fn,
	free_fn:           Free_Fn,
	free_allocator_fn: Free_Allocator_Fn,
	user:              rawptr,
}

Allocator_Opts :: struct {
	allocator:                                                      Allocator, // Allocator callbacks
	memory_limit, allocation_limit, huge_threshold, max_chunk_size: c.size_t,  // Maximum number of bytes to allocate before failing
}

// Try to read up to `size` bytes to `data`, return the amount of read bytes.
// Return `SIZE_MAX` to indicate an IO error.
Read_Fn :: proc "c" (rawptr, rawptr, c.size_t) -> c.size_t

// Skip `size` bytes in the file.
Skip_Fn :: proc "c" (rawptr, c.size_t) -> bool

// Get the size of the file.
// Return `0` if unknown, `UINT64_MAX` if error.
Size_Fn :: proc "c" (rawptr) -> u64

// Close the file
Close_Fn :: proc "c" (rawptr)

Stream :: struct {
	read_fn:  Read_Fn,  // < Required
	skip_fn:  Skip_Fn,  // < Optional: Will use `read_fn()` if missing
	size_fn:  Size_Fn,  // < Optional
	close_fn: Close_Fn, // < Optional
	user:     rawptr,   // Context passed to other functions
}

Open_File_Type :: enum c.int {
	MAIN_MODEL       = 0, // < Main model file
	GEOMETRY_CACHE   = 1, // < Unknown geometry cache file
	OBJ_MTL          = 2, // < .mtl material library file
	TYPE_FORCE_32BIT = 2147483647,
}

OPEN_FILE_TYPE_COUNT :: 3

Open_File_Context :: c.uintptr_t

Open_File_Info :: struct {
	_context:          Open_File_Context, // Context that can be passed to the following functions to use a shared allocator:
	//   ufbx_open_file_ctx()
	//   ufbx_open_memory_ctx()
	type:              Open_File_Type,    // Kind of file to load.
	original_filename: Blob,              // Original filename in the file, not resolved or UTF-8 encoded.
	// NOTE: Not necessarily NULL-terminated!
}

// Callback for opening an external file from the filesystem
Open_File_Fn :: proc "c" (rawptr, ^Stream, cstring, c.size_t, ^Open_File_Info) -> bool

Open_File_Cb :: struct {
	fn:   Open_File_Fn,
	user: rawptr,
}

// Options for `ufbx_open_file()`.
Open_File_Opts :: struct {
	_begin_zero:              u32,
	allocator:                Allocator_Opts, // Allocator to allocate the memory with.
	filename_null_terminated: bool,           // The filename is guaranteed to be NULL-terminated.
	_end_zero:                u32,
}

// Memory stream options
Close_Memory_Fn :: proc "c" (rawptr, rawptr, c.size_t)

Close_Memory_Cb :: struct {
	fn:   Close_Memory_Fn,
	user: rawptr,
}

// Options for `ufbx_open_memory()`.
Open_Memory_Opts :: struct {
	_begin_zero: u32,
	allocator:   Allocator_Opts,  // Allocator to allocate the memory with.
	// NOTE: Used even if no copy is made to allocate a small metadata block.
	no_copy:     bool,            // Do not copy the memory.
	// You can use `close_cb` to free the memory when the stream is closed.
	// NOTE: This means the provided data pointer is referenced after creating
	// the memory stream, make sure the data stays valid until the stream is closed!
	close_cb:    Close_Memory_Cb, // Callback to free the memory blob.
	_end_zero:   u32,
}

// Detailed error stack frame.
// NOTE: You must compile `ufbx.c` with `UFBX_ENABLE_ERROR_STACK` to enable the error stack.
Error_Frame :: struct {
	source_line: u32,
	function:    String,
	description: String,
}

// Error causes (and `UFBX_ERROR_NONE` for no error).
Error_Type :: enum c.int {
	NONE                     = 0,          // No error, operation has been performed successfully.
	UNKNOWN                  = 1,          // Unspecified error, most likely caused by an invalid FBX file or a file
	// that contains something ufbx can't handle.
	FILE_NOT_FOUND           = 2,          // File not found.
	EMPTY_FILE               = 3,          // Empty file.
	EXTERNAL_FILE_NOT_FOUND  = 4,          // External file not found.
	// See `ufbx_load_opts.load_external_files` for more information.
	OUT_OF_MEMORY            = 5,          // Out of memory (allocator returned `NULL`).
	MEMORY_LIMIT             = 6,          // `ufbx_allocator_opts.memory_limit` exhausted.
	ALLOCATION_LIMIT         = 7,          // `ufbx_allocator_opts.allocation_limit` exhausted.
	TRUNCATED_FILE           = 8,          // File ended abruptly.
	IO                       = 9,          // IO read error.
	// eg. returning `SIZE_MAX` from `ufbx_stream.read_fn` or stdio `ferror()` condition.
	CANCELLED                = 10,         // User cancelled the loading via `ufbx_load_opts.progress_cb` returning `UFBX_PROGRESS_CANCEL`.
	UNRECOGNIZED_FILE_FORMAT = 11,         // Could not detect file format from file data or filename.
	// HINT: You can supply it manually using `ufbx_load_opts.file_format` or use `ufbx_load_opts.filename`
	// when using `ufbx_load_memory()` to let ufbx guess the format from the extension.
	UNINITIALIZED_OPTIONS    = 12,         // Options struct (eg. `ufbx_load_opts`) is not cleared to zero.
	// Make sure you initialize the structure to zero via eg.
	//   ufbx_load_opts opts = { 0 }; // C
	//   ufbx_load_opts opts = { }; // C++
	ZERO_VERTEX_SIZE         = 13,         // The vertex streams in `ufbx_generate_indices()` are empty.
	TRUNCATED_VERTEX_STREAM  = 14,         // Vertex stream passed to `ufbx_generate_indices()`.
	INVALID_UTF8             = 15,         // Invalid UTF-8 encountered in a file when loading with `UFBX_UNICODE_ERROR_HANDLING_ABORT_LOADING`.
	FEATURE_DISABLED         = 16,         // Feature needed for the operation has been compiled out.
	BAD_NURBS                = 17,         // Attempting to tessellate an invalid NURBS object.
	// See `ufbx_nurbs_basis.valid`.
	BAD_INDEX                = 18,         // Out of bounds index in the file when loading with `UFBX_INDEX_ERROR_HANDLING_ABORT_LOADING`.
	NODE_DEPTH_LIMIT         = 19,         // Node is deeper than `ufbx_load_opts.node_depth_limit` in the hierarchy.
	THREADED_ASCII_PARSE     = 20,         // Error parsing ASCII array in a thread.
	// Threaded ASCII parsing is slightly more strict than non-threaded, for cursed files,
	// set `ufbx_load_opts.force_single_thread_ascii_parsing` to `true`.
	UNSAFE_OPTIONS           = 21,         // Unsafe options specified without enabling `ufbx_load_opts.allow_unsafe`.
	DUPLICATE_OVERRIDE       = 22,         // Duplicated override property in `ufbx_create_anim()`
	UNSUPPORTED_VERSION      = 23,         // Unsupported file format version.
	// ufbx still tries to load files with unsupported versions, see `UFBX_WARNING_UNSUPPORTED_VERSION`.
	TYPE_FORCE_32BIT         = 2147483647, // Unsupported file format version.
	// ufbx still tries to load files with unsupported versions, see `UFBX_WARNING_UNSUPPORTED_VERSION`.
}

ERROR_TYPE_COUNT :: 24

// Error description with detailed stack trace
// HINT: You can use `ufbx_format_error()` for formatting the error
Error :: struct {
	type:        Error_Type, // Type of the error, or `UFBX_ERROR_NONE` if successful.
	description: String,     // Description of the error type.
	stack_size:  u32,        // Internal error stack.
	// NOTE: You must compile `ufbx.c` with `UFBX_ENABLE_ERROR_STACK` to enable the error stack.
	stack:       [8]Error_Frame,
	info_length: c.size_t,   // Additional error information, such as missing file filename.
	// `info` is a NULL-terminated UTF-8 string containing `info_length` bytes, excluding the trailing `'\0'`.
	info:        [256]c.char,
}

// Loading progress information.
Progress :: struct {
	bytes_read:  u64,
	bytes_total: u64,
}

// Progress result returned from `ufbx_progress_fn()` callback.
// Determines whether ufbx should continue or abort the loading.
Progress_Result :: enum c.int {
	CONTINUE           = 256,        // Continue loading the file.
	CANCEL             = 512,        // Cancel loading and fail with `UFBX_ERROR_CANCELLED`.
	RESULT_FORCE_32BIT = 2147483647, // Cancel loading and fail with `UFBX_ERROR_CANCELLED`.
}

// Called periodically with the current progress.
// Return `UFBX_PROGRESS_CANCEL` to cancel further processing.
Progress_Fn :: proc "c" (rawptr, ^Progress) -> Progress_Result

Progress_Cb :: struct {
	fn:   Progress_Fn,
	user: rawptr,
}

// Source data/stream to decompress with `ufbx_inflate()`
Inflate_Input :: struct {
	total_size:                                                        c.size_t,    // Total size of the data in bytes
	data:                                                              rawptr,      // (optional) Initial or complete data chunk
	data_size:                                                         c.size_t,
	buffer:                                                            rawptr,      // (optional) Temporary buffer, defaults to 256b stack buffer
	buffer_size:                                                       c.size_t,
	read_fn:                                                           Read_Fn,     // (optional) Streaming read function, concatenated after `data`
	read_user:                                                         rawptr,
	progress_cb:                                                       Progress_Cb, // (optional) Progress reporting
	progress_interval_hint, progress_size_before, progress_size_after: u64,         // < Bytes between progress report calls
	no_header, no_checksum:                                            bool,        // (optional) No the DEFLATE header
	internal_fast_bits:                                                c.size_t,    // (optional) Force internal fast lookup bit amount
}

// Persistent data between `ufbx_inflate()` calls
// NOTE: You must set `initialized` to `false`, but `data` may be uninitialized
Inflate_Retain :: struct {
	initialized: bool,
	data:        [1024]u64,
}

Index_Error_Handling :: enum c.int {
	CLAMP         = 0,          // Clamp to a valid value.
	NO_INDEX      = 1,          // Set bad indices to `UFBX_NO_INDEX`.
	// This is the recommended way if you need to deal with files with gaps in information.
	// HINT: If you use this `ufbx_get_vertex_TYPE()` functions will return zero
	// on invalid indices instead of failing.
	ABORT_LOADING = 2,          // Fail loading entierely when encountering a bad index.
	UNSAFE_IGNORE = 3,          // Pass bad indices through as-is.
	// Requires `ufbx_load_opts.allow_unsafe`.
	// UNSAFE: Breaks any API guarantees regarding indexes being in bounds and makes
	// `ufbx_get_vertex_TYPE()` memory-unsafe to use.
	FORCE_32BIT   = 2147483647, // Pass bad indices through as-is.
	// Requires `ufbx_load_opts.allow_unsafe`.
	// UNSAFE: Breaks any API guarantees regarding indexes being in bounds and makes
	// `ufbx_get_vertex_TYPE()` memory-unsafe to use.
}

INDEX_ERROR_HANDLING_COUNT :: 4

Unicode_Error_Handling :: enum c.int {
	REPLACEMENT_CHARACTER = 0,          // Replace errors with U+FFFD "Replacement Character"
	UNDERSCORE            = 1,          // Replace errors with '_' U+5F "Low Line"
	QUESTION_MARK         = 2,          // Replace errors with '?' U+3F "Question Mark"
	REMOVE                = 3,          // Remove errors from the output
	ABORT_LOADING         = 4,          // Fail loading on encountering an Unicode error
	UNSAFE_IGNORE         = 5,          // Ignore and pass-through non-UTF-8 string data.
	// Requires `ufbx_load_opts.allow_unsafe`.
	// UNSAFE: Breaks API guarantee that `ufbx_string` is UTF-8 encoded.
	FORCE_32BIT           = 2147483647, // Ignore and pass-through non-UTF-8 string data.
	// Requires `ufbx_load_opts.allow_unsafe`.
	// UNSAFE: Breaks API guarantee that `ufbx_string` is UTF-8 encoded.
}

UNICODE_ERROR_HANDLING_COUNT :: 6

// How to handle FBX node geometry transforms.
// FBX nodes can have "geometry transforms" that affect only the attached meshes,
// but not the children. This is not allowed in many scene representations so
// ufbx provides some ways to simplify them.
// Geometry transforms can also be used to transform any other attributes such
// as lights or cameras.
Geometry_Transform_Handling :: enum c.int {
	PRESERVE                    = 0,          // Preserve the geometry transforms as-is.
	// To be correct for all files you have to use `ufbx_node.geometry_transform`,
	// `ufbx_node.geometry_to_node`, or `ufbx_node.geometry_to_world` to compensate
	// for any potential geometry transforms.
	HELPER_NODES                = 1,          // Add helper nodes between the nodes and geometry where needed.
	// The created nodes have `ufbx_node.is_geometry_transform_helper` set and are
	// named `ufbx_load_opts.geometry_transform_helper_name`.
	MODIFY_GEOMETRY             = 2,          // Modify the geometry of meshes attached to nodes with geometry transforms.
	// Will add helper nodes like `UFBX_GEOMETRY_TRANSFORM_HANDLING_HELPER_NODES` if
	// necessary, for example if there are multiple instances of the same mesh with
	// geometry transforms.
	MODIFY_GEOMETRY_NO_FALLBACK = 3,          // Modify the geometry of meshes attached to nodes with geometry transforms.
	// NOTE: This will not work correctly for instanced geometry.
	FORCE_32BIT                 = 2147483647, // Modify the geometry of meshes attached to nodes with geometry transforms.
	// NOTE: This will not work correctly for instanced geometry.
}

GEOMETRY_TRANSFORM_HANDLING_COUNT :: 4

// How to handle FBX transform inherit modes.
Inherit_Mode_Handling :: enum c.int {
	PRESERVE               = 0,          // Preserve inherit mode in `ufbx_node.inherit_mode`.
	// NOTE: To correctly handle all scenes you would need to handle the
	// non-standard inherit modes.
	HELPER_NODES           = 1,          // Create scale helper nodes parented to nodes that need special inheritance.
	// Scale helper nodes will have `ufbx_node.is_scale_helper` and parents of
	// scale helpers will have `ufbx_node.scale_helper` pointing to it.
	COMPENSATE             = 2,          // Attempt to compensate for bone scale by inversely scaling children.
	// NOTE: This only works for uniform non-animated scaling, if scale is
	// non-uniform or animated, ufbx will add scale helpers in the same way
	// as `UFBX_INHERIT_MODE_HANDLING_HELPER_NODES`.
	COMPENSATE_NO_FALLBACK = 3,          // Attempt to compensate for bone scale by inversely scaling children.
	// Will never create helper nodes.
	IGNORE                 = 4,          // Ignore non-standard inheritance modes.
	// Forces all nodes to have `UFBX_INHERIT_MODE_NORMAL` regardless of the
	// inherit mode specified in the file. This can be useful for emulating
	// results from importers/programs that don't support inherit modes.
	FORCE_32BIT            = 2147483647, // Ignore non-standard inheritance modes.
	// Forces all nodes to have `UFBX_INHERIT_MODE_NORMAL` regardless of the
	// inherit mode specified in the file. This can be useful for emulating
	// results from importers/programs that don't support inherit modes.
}

INHERIT_MODE_HANDLING_COUNT :: 5

// How to handle FBX transform pivots.
Pivot_Handling :: enum c.int {
	RETAIN          = 0,          // Take pivots into account when computing the transform.
	ADJUST_TO_PIVOT = 1,          // Translate objects to be located at their pivot.
	// NOTE: Only applied if rotation and scaling pivots are equal.
	// NOTE: Results in geometric translation. Use `ufbx_geometry_transform_handling`
	// to interpret these in a standard scene graph.
	FORCE_32BIT     = 2147483647, // Translate objects to be located at their pivot.
	// NOTE: Only applied if rotation and scaling pivots are equal.
	// NOTE: Results in geometric translation. Use `ufbx_geometry_transform_handling`
	// to interpret these in a standard scene graph.
}

PIVOT_HANDLING_COUNT :: 2

Baked_Key_Flag :: enum c.int {
	STEP_LEFT  = 0, // This keyframe represents a constant step from the left side
	STEP_RIGHT = 1, // This keyframe represents a constant step from the right side
	STEP_KEY   = 2, // This keyframe is the main part of a step
	// Bordering either `UFBX_BAKED_KEY_STEP_LEFT` or `UFBX_BAKED_KEY_STEP_RIGHT`.
	KEYFRAME   = 3, // This keyframe is a real keyframe in the source animation
	REDUCED    = 4, // This keyframe has been reduced by maximum sample rate.
	// See `ufbx_bake_opts.maximum_sample_rate`.
}

Baked_Key_Flags :: distinct bit_set[Baked_Key_Flag; c.int]

BAKED_KEY_FORCE_32BIT :: Baked_Key_Flags { .STEP_LEFT, .STEP_RIGHT, .STEP_KEY, .KEYFRAME, .REDUCED }

Baked_Vec3 :: struct {
	time:  f64,            // < Time of the keyframe, in seconds
	value: Vec3,           // < Value at `time`, can be linearly interpolated
	flags: Baked_Key_Flag, // < Additional information about the keyframe
}

Baked_Vec3_List :: struct {
	data:  ^Baked_Vec3,
	count: c.size_t,
}

Baked_Quat :: struct {
	time:  f64,            // < Time of the keyframe, in seconds
	value: Quat,           // < Value at `time`, can be (spherically) linearly interpolated
	flags: Baked_Key_Flag, // < Additional information about the keyframe
}

Baked_Quat_List :: struct {
	data:  ^Baked_Quat,
	count: c.size_t,
}

// Baked transform animation for a single node.
Baked_Node :: struct {
	typed_id, element_id:                                    u32,             // Typed ID of the node, maps to `ufbx_scene.nodes[]`.
	constant_translation, constant_rotation, constant_scale: bool,            // The translation channel has constant values for the whole animation.
	translation_keys:                                        Baked_Vec3_List, // Translation keys for the animation, maps to `ufbx_node.local_transform.translation`.
	rotation_keys:                                           Baked_Quat_List, // Rotation keyframes, maps to `ufbx_node.local_transform.rotation`.
	scale_keys:                                              Baked_Vec3_List, // Scale keyframes, maps to `ufbx_node.local_transform.scale`.
}

Baked_Node_List :: struct {
	data:  ^Baked_Node,
	count: c.size_t,
}

// Baked property animation.
Baked_Prop :: struct {
	name:           String,          // Name of the property, eg. `"Visibility"`.
	constant_value: bool,            // The value of the property is constant for the whole animation.
	keys:           Baked_Vec3_List, // Property value keys.
}

Baked_Prop_List :: struct {
	data:  ^Baked_Prop,
	count: c.size_t,
}

// Baked property animation for a single element.
Baked_Element :: struct {
	element_id: u32,             // Element ID of the element, maps to `ufbx_scene.elements[]`.
	props:      Baked_Prop_List, // List of properties the animation modifies.
}

Baked_Element_List :: struct {
	data:  ^Baked_Element,
	count: c.size_t,
}

Baked_Anim_Metadata :: struct {
	result_memory_used, temp_memory_used, result_allocs, temp_allocs: c.size_t, // Memory statistics
}

// Animation baked into linearly interpolated keyframes.
// See `ufbx_bake_anim()`.
Baked_Anim :: struct {
	nodes:                                                                                 Baked_Node_List,     // Nodes that are modified by the animation.
	// Some nodes may be missing if the specified animation does not transform them.
	// Conversely, some non-obviously animated nodes may be included as exporters
	// often may add dummy keyframes for objects.
	elements:                                                                              Baked_Element_List,  // Element properties modified by the animation.
	playback_time_begin, playback_time_end, playback_duration, key_time_min, key_time_max: f64,                 // Playback time range for the animation.
	metadata:                                                                              Baked_Anim_Metadata, // Additional bake information.
}

// Internal thread pool handle.
// Passed to `ufbx_thread_pool_run_task()` from an user thread to run ufbx tasks.
// HINT: This context can store a user pointer via `ufbx_thread_pool_set_user_ptr()`.
Thread_Pool_Context :: c.uintptr_t

// Thread pool creation information from ufbx.
Thread_Pool_Info :: struct {
	max_concurrent_tasks: u32,
}

// Initialize the thread pool.
// Return `true` on success.
Thread_Pool_Init_Fn :: proc "c" (rawptr, Thread_Pool_Context, ^Thread_Pool_Info) -> bool

// Run tasks `count` tasks in threads.
// You must call `ufbx_thread_pool_run_task()` with indices `[start_index, start_index + count)`.
// The threads are launched in batches indicated by `group`, see `UFBX_THREAD_GROUP_COUNT` for more information.
// Ideally, you should run all the task indices in parallel within each `ufbx_thread_pool_run_fn()` call.
Thread_Pool_Run_Fn :: proc "c" (rawptr, Thread_Pool_Context, u32, u32, u32)

// Wait for previous tasks spawned in `ufbx_thread_pool_run_fn()` to finish.
// `group` specifies the batch to wait for, `max_index` contains `start_index + count` from that group instance.
Thread_Pool_Wait_Fn :: proc "c" (rawptr, Thread_Pool_Context, u32, u32)

// Free the thread pool.
Thread_Pool_Free_Fn :: proc "c" (rawptr, Thread_Pool_Context)

// Thread pool interface.
// See functions above for more information.
//
// Hypothetical example of calls, where `UFBX_THREAD_GROUP_COUNT=2` for simplicity:
//
//   run_fn(group=0, start_index=0, count=4)   -> t0 := threaded { ufbx_thread_pool_run_task(0..3) }
//   run_fn(group=1, start_index=4, count=10)  -> t1 := threaded { ufbx_thread_pool_run_task(4..10) }
//   wait_fn(group=0, max_index=4)             -> wait_threads(t0)
//   run_fn(group=0, start_index=10, count=15) -> t0 := threaded { ufbx_thread_pool_run_task(10..14) }
//   wait_fn(group=1, max_index=10)            -> wait_threads(t1)
//   wait_fn(group=0, max_index=15)            -> wait_threads(t0)
//
Thread_Pool :: struct {
	init_fn: Thread_Pool_Init_Fn, // < Optional
	run_fn:  Thread_Pool_Run_Fn,  // < Required
	wait_fn: Thread_Pool_Wait_Fn, // < Required
	free_fn: Thread_Pool_Free_Fn, // < Optional
	user:    rawptr,
}

// Thread pool options.
Thread_Opts :: struct {
	pool:                    Thread_Pool, // Thread pool interface.
	// HINT: You can use `extra/ufbx_os.h` to provide a thread pool.
	num_tasks, memory_limit: c.size_t,    // Maximum of tasks to have in-flight.
	// Default: 2048
}

// Flags to control nanimation evaluation functions.
Evaluate_Flags :: enum c.int {
	UFBX_EVALUATE_FLAG_NO_EXTRAPOLATION = 1,          // Do not extrapolate past the keyframes.
	ufbx_evaluate_flags_FORCE_32BIT     = 2147483647, // Do not extrapolate past the keyframes.
}

// Options for `ufbx_load_file/memory/stream/stdio()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Load_Opts :: struct {
	_begin_zero:                                                                                                                                                                                                                                                                                                                u32,
	temp_allocator, result_allocator:                                                                                                                                                                                                                                                                                           Allocator_Opts,              // < Allocator used during loading
	thread_opts:                                                                                                                                                                                                                                                                                                                Thread_Opts,                 // < Threading options
	ignore_geometry, ignore_animation, ignore_embedded, ignore_all_content, evaluate_skinning, evaluate_caches, load_external_files, ignore_missing_external_files, skip_skin_vertices, skip_mesh_parts, clean_skin_weights, use_blender_pbr_material, disable_quirks, strict, force_single_thread_ascii_parsing, allow_unsafe: bool,                        // < Do not load geometry datsa (vertices, indices, etc)
	index_error_handling:                                                                                                                                                                                                                                                                                                       Index_Error_Handling,        // Specify how to handle broken indices.
	connect_broken_elements, allow_nodes_out_of_root, allow_missing_vertex_position, allow_empty_faces, generate_missing_normals, open_main_file_with_default:                                                                                                                                                                  bool,                        // Connect related elements even if they are broken. If `false` (default)
	// `ufbx_skin_cluster` with a missing `bone` field are _not_ included in
	// the `ufbx_skin_deformer.clusters[]` array for example.
	path_separator:                                                                                                                                                                                                                                                                                                             c.char,                      // Path separator character, defaults to '\' on Windows and '/' otherwise.
	node_depth_limit:                                                                                                                                                                                                                                                                                                           u32,                         // Maximum depth of the node hirerachy.
	// Will fail with `UFBX_ERROR_NODE_DEPTH_LIMIT` if a node is deeper than this limit.
	// NOTE: The default of 0 allows arbitrarily deep hierarchies. Be careful if using
	// recursive algorithms without setting this limit.
	file_size_estimate:                                                                                                                                                                                                                                                                                                         u64,                         // Estimated file size for progress reporting
	read_buffer_size:                                                                                                                                                                                                                                                                                                           c.size_t,                    // Buffer size in bytes to use for reading from files or IO callbacks
	filename:                                                                                                                                                                                                                                                                                                                   String,                      // Filename to use as a base for relative file paths if not specified using
	// `ufbx_load_file()`. Use `length = SIZE_MAX` for NULL-terminated strings.
	// `raw_filename` will be derived from this if empty.
	raw_filename:                                                                                                                                                                                                                                                                                                               Blob,                        // Raw non-UTF8 filename. Does not support NULL termination.
	// `filename` will be derived from this if empty.
	progress_cb:                                                                                                                                                                                                                                                                                                                Progress_Cb,                 // Progress reporting
	progress_interval_hint:                                                                                                                                                                                                                                                                                                     u64,                         // < Bytes between progress report calls
	open_file_cb:                                                                                                                                                                                                                                                                                                               Open_File_Cb,                // External file callbacks (defaults to stdio.h)
	geometry_transform_handling:                                                                                                                                                                                                                                                                                                Geometry_Transform_Handling, // How to handle geometry transforms in the nodes.
	// See `ufbx_geometry_transform_handling` for an explanation.
	inherit_mode_handling:                                                                                                                                                                                                                                                                                                      Inherit_Mode_Handling,       // How to handle unconventional transform inherit modes.
	// See `ufbx_inherit_mode_handling` for an explanation.
	pivot_handling:                                                                                                                                                                                                                                                                                                             Pivot_Handling,              // How to handle pivots.
	// See `ufbx_pivot_handling` for an explanation.
	space_conversion:                                                                                                                                                                                                                                                                                                           Space_Conversion,            // How to perform space conversion by `target_axes` and `target_unit_meters`.
	// See `ufbx_space_conversion` for an explanation.
	handedness_conversion_axis:                                                                                                                                                                                                                                                                                                 Mirror_Axis,                 // Axis used to mirror for conversion between left-handed and right-handed coordinates.
	handedness_conversion_retain_winding, reverse_winding:                                                                                                                                                                                                                                                                      bool,                        // Do not change winding of faces when converting handedness.
	target_axes:                                                                                                                                                                                                                                                                                                                Coordinate_Axes,             // Apply an implicit root transformation to match axes.
	// Used if `ufbx_coordinate_axes_valid(target_axes)`.
	target_unit_meters:                                                                                                                                                                                                                                                                                                         Real,                        // Scale the scene so that one world-space unit is `target_unit_meters` meters.
	// By default units are not scaled.
	target_camera_axes, target_light_axes:                                                                                                                                                                                                                                                                                      Coordinate_Axes,             // Target space for camera.
	// By default FBX cameras point towards the positive X axis.
	// Used if `ufbx_coordinate_axes_valid(target_camera_axes)`.
	geometry_transform_helper_name, scale_helper_name:                                                                                                                                                                                                                                                                          String,                      // Name for dummy geometry transform helper nodes.
	// See `UFBX_GEOMETRY_TRANSFORM_HANDLING_HELPER_NODES`.
	normalize_normals, normalize_tangents, use_root_transform:                                                                                                                                                                                                                                                                  bool,                        // Normalize vertex normals.
	root_transform:                                                                                                                                                                                                                                                                                                             Transform,
	key_clamp_threshold:                                                                                                                                                                                                                                                                                                        f64,                         // Animation keyframe clamp threshold, only applies to specific interpolation modes.
	unicode_error_handling:                                                                                                                                                                                                                                                                                                     Unicode_Error_Handling,      // Specify how to handle Unicode errors in strings.
	retain_vertex_attrib_w, retain_dom:                                                                                                                                                                                                                                                                                         bool,                        // Retain the 'W' component of mesh normal/tangent/bitangent.
	// See `ufbx_vertex_attrib.values_w`.
	file_format:                                                                                                                                                                                                                                                                                                                File_Format,                 // Force a specific file format instead of detecting it.
	file_format_lookahead:                                                                                                                                                                                                                                                                                                      c.size_t,                    // How far to read into the file to determine the file format.
	// Default: 16kB
	no_format_from_content, no_format_from_extension, obj_search_mtl_by_filename, obj_merge_objects, obj_merge_groups, obj_split_groups:                                                                                                                                                                                        bool,                        // Do not attempt to detect file format from file content.
	obj_mtl_path:                                                                                                                                                                                                                                                                                                               String,                      // (.obj) Path to the .mtl file.
	// Use `length = SIZE_MAX` for NULL-terminated strings.
	// NOTE: This is used _instead_ of the one in the file even if not found
	// and sidesteps `load_external_files` as it's _explicitly_ requested.
	obj_mtl_data:                                                                                                                                                                                                                                                                                                               Blob,                        // (.obj) Data for the .mtl file.
	obj_unit_meters:                                                                                                                                                                                                                                                                                                            Real,                        // The world unit in meters that .obj files are assumed to be in.
	// .obj files do not define the working units. By default the unit scale
	// is read as zero, and no unit conversion is performed.
	obj_axes:                                                                                                                                                                                                                                                                                                                   Coordinate_Axes,             // Coordinate space .obj files are assumed to be in.
	// .obj files do not define the coordinate space they use. By default no
	// coordinate space is assumed and no conversion is performed.
	_end_zero:                                                                                                                                                                                                                                                                                                                  u32,
}

// Options for `ufbx_evaluate_scene()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Evaluate_Opts :: struct {
	_begin_zero:                        u32,
	temp_allocator, result_allocator:   Allocator_Opts, // < Allocator used during evaluation
	evaluate_skinning, evaluate_caches: bool,           // < Evaluate skinning (see ufbx_mesh.skinned_vertices)
	evaluate_flags:                     u32,            // Evaluation flags.
	// See `ufbx_evaluate_flags` for information.
	load_external_files:                bool,           // WARNING: Potentially unsafe! Try to open external files such as geometry caches
	open_file_cb:                       Open_File_Cb,   // External file callbacks (defaults to stdio.h)
	_end_zero:                          u32,
}

Const_Uint32_List :: struct {
	data:  ^u32,
	count: c.size_t,
}

Const_Real_List :: struct {
	data:  ^Real,
	count: c.size_t,
}

Prop_Override_Desc :: struct {
	element_id: u32,    // Element (`ufbx_element.element_id`) to override the property from
	prop_name:  String, // Property name to override.
	value:      Vec4,   // Override value, use `value.x` for scalars. `value_int` is initialized
	// from `value.x` if zero so keep `value` zeroed even if you don't need it!
	value_str:  String,
	value_int:  i64,
}

Const_Prop_Override_Desc_List :: struct {
	data:  ^Prop_Override_Desc,
	count: c.size_t,
}

Const_Transform_Override_List :: struct {
	data:  ^Transform_Override,
	count: c.size_t,
}

Anim_Opts :: struct {
	_begin_zero:            u32,
	layer_ids:              Const_Uint32_List,             // Animation layers indices.
	// Corresponding to `ufbx_scene.anim_layers[]`, aka `ufbx_anim_layer.typed_id`.
	override_layer_weights: Const_Real_List,               // Override layer weights, parallel to `ufbx_anim_opts.layer_ids[]`.
	prop_overrides:         Const_Prop_Override_Desc_List, // Property overrides.
	// These allow you to override FBX properties, such as 'UFBX_Lcl_Rotation`.
	transform_overrides:    Const_Transform_Override_List, // Transform overrides.
	// These allow you to override individual nodes' `ufbx_node.local_transform`.
	ignore_connections:     bool,                          // Ignore connected properties
	result_allocator:       Allocator_Opts,                // < Allocator used to create the `ufbx_anim`
	_end_zero:              u32,
}

// Specifies how to handle stepped tangents.
Bake_Step_Handling :: enum c.int {
	UFBX_BAKE_STEP_HANDLING_DEFAULT         = 0,          // One millisecond default step duration, with potential extra slack for converting to `float`.
	UFBX_BAKE_STEP_HANDLING_CUSTOM_DURATION = 1,          // Use a custom interpolation duration for the constant step.
	// See `ufbx_bake_opts.step_custom_duration` and optionally `ufbx_bake_opts.step_custom_epsilon`.
	UFBX_BAKE_STEP_HANDLING_IDENTICAL_TIME  = 2,          // Stepped keyframes are represented as keyframes at the exact same time.
	// Use flags `UFBX_BAKED_KEY_STEP_LEFT` and `UFBX_BAKED_KEY_STEP_RIGHT` to differentiate
	// between the primary key and edge limits.
	UFBX_BAKE_STEP_HANDLING_ADJACENT_DOUBLE = 3,          // Represent stepped keyframe times as the previous/next representable `double` value.
	// Using this and robust linear interpolation will handle stepped tangents correctly
	// without having to look at the key flags.
	// NOTE: Casting these values to `float` or otherwise modifying them can collapse
	// the keyframes to have the identical time.
	UFBX_BAKE_STEP_HANDLING_IGNORE          = 4,          // Treat all stepped tangents as linearly interpolated.
	ufbx_bake_step_handling_FORCE_32BIT     = 2147483647, // Treat all stepped tangents as linearly interpolated.
}

BAKE_STEP_HANDLING_COUNT :: 5

Bake_Opts :: struct {
	_begin_zero:                                                                                     u32,
	temp_allocator, result_allocator:                                                                Allocator_Opts,     // < Allocator used during loading
	trim_start_time:                                                                                 bool,               // Move the keyframe times to start from zero regardless of the animation start time.
	// For example, for an animation spanning between frames [30, 60] will be moved to
	// [0, 30] in the baked animation.
	// NOTE: This is in general not equivalent to subtracting `ufbx_anim.time_begin`
	// from each keyframe, as this trimming is done exactly using internal FBX ticks.
	resample_rate, minimum_sample_rate, maximum_sample_rate:                                         f64,                // Samples per second to use for resampling non-linear animation.
	// Default: 30
	bake_transform_props, skip_node_transforms, no_resample_rotation, ignore_layer_weight_animation: bool,               // Bake the raw versions of properties related to transforms.
	max_keyframe_segments:                                                                           c.size_t,           // Maximum number of segments to generate from one keyframe.
	// Default: 32
	step_handling:                                                                                   Bake_Step_Handling, // How to handle stepped tangents.
	step_custom_duration, step_custom_epsilon:                                                       f64,                // Interpolation duration used by `UFBX_BAKE_STEP_HANDLING_CUSTOM_DURATION`.
	evaluate_flags:                                                                                  u32,                // Flags passed to animation evaluation functions.
	// See `ufbx_evaluate_flags`.
	key_reduction_enabled, key_reduction_rotation:                                                   bool,               // Enable key reduction.
	key_reduction_threshold:                                                                         f64,                // Threshold for reducing keys for linear segments.
	// Default `0.000001`, use negative to disable.
	key_reduction_passes:                                                                            c.size_t,           // Maximum passes over the keys to reduce.
	// Every pass can potentially halve the the amount of keys.
	// Default: `4`
	_end_zero:                                                                                       u32,
}

// Options for `ufbx_tessellate_nurbs_curve()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Tessellate_Curve_Opts :: struct {
	_begin_zero:                      u32,
	temp_allocator, result_allocator: Allocator_Opts, // < Allocator used during tessellation
	span_subdivision:                 c.size_t,       // How many segments tessellate each span in `ufbx_nurbs_basis.spans`.
	_end_zero:                        u32,
}

// Options for `ufbx_tessellate_nurbs_surface()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Tessellate_Surface_Opts :: struct {
	_begin_zero:                            u32,
	temp_allocator, result_allocator:       Allocator_Opts, // < Allocator used during tessellation
	span_subdivision_u, span_subdivision_v: c.size_t,       // How many segments tessellate each span in `ufbx_nurbs_basis.spans`.
	// NOTE: Default is `4`, _not_ `ufbx_nurbs_surface.span_subdivision_u/v` as that
	// would make it easy to create an FBX file with an absurdly high subdivision
	// rate (similar to mesh subdivision). Please enforce copy the value yourself
	// enforcing whatever limits you deem reasonable.
	skip_mesh_parts:                        bool,           // Skip computing `ufbx_mesh.material_parts[]`
	_end_zero:                              u32,
}

// Options for `ufbx_subdivide_mesh()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Subdivide_Opts :: struct {
	_begin_zero:                                                                         u32,
	temp_allocator, result_allocator:                                                    Allocator_Opts, // < Allocator used during subdivision
	boundary:                                                                            Subdivision_Boundary,
	uv_boundary:                                                                         Subdivision_Boundary,
	ignore_normals, interpolate_normals, interpolate_tangents, evaluate_source_vertices: bool,           // Do not generate normals
	max_source_vertices:                                                                 c.size_t,       // Limit source vertices per subdivided vertex.
	evaluate_skin_weights:                                                               bool,           // Calculate bone influences over subdivided vertices (if applicable).
	// NOTE: May be O(n^2) if `max_skin_weights` is not specified!
	max_skin_weights, skin_deformer_index:                                               c.size_t,       // Limit bone influences per subdivided vertex.
	_end_zero:                                                                           u32,
}

// Options for `ufbx_load_geometry_cache()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Geometry_Cache_Opts :: struct {
	_begin_zero:                      u32,
	temp_allocator, result_allocator: Allocator_Opts, // < Allocator used during loading
	open_file_cb:                     Open_File_Cb,   // External file callbacks (defaults to stdio.h)
	frames_per_second:                f64,            // FPS value for converting frame times to seconds
	mirror_axis:                      Mirror_Axis,    // Axis to mirror the geometry by.
	use_scale_factor:                 bool,           // Enable scaling `scale_factor` all geometry by.
	scale_factor:                     Real,           // Factor to scale the geometry by.
	_end_zero:                        u32,
}

// Options for `ufbx_read_geometry_cache_TYPE()`
// NOTE: Initialize to zero with `{ 0 }` (C) or `{ }` (C++)
Geometry_Cache_Data_Opts :: struct {
	_begin_zero:      u32,
	open_file_cb:     Open_File_Cb, // External file callbacks (defaults to stdio.h)
	additive:         bool,
	use_weight:       bool,
	weight:           Real,
	ignore_transform: bool,         // Ignore scene transform.
	_end_zero:        u32,
}

Panic :: struct {
	did_panic:      bool,
	message_length: c.size_t,
	message:        [128]c.char,
}

// Flags to control `ufbx_evaluate_transform_flags()`.
Transform_Flag :: enum c.int {
	IGNORE_SCALE_HELPER        = 0, // Ignore parent scale helper.
	IGNORE_COMPONENTWISE_SCALE = 1, // Ignore componentwise scale.
	// Note that if you don't specify this, ufbx will have to potentially
	// evaluate the entire parent chain in the worst case.
	EXPLICIT_INCLUDES          = 2, // Require explicit components
	INCLUDE_TRANSLATION        = 4, // If `UFBX_TRANSFORM_FLAG_EXPLICIT_INCLUDES`: Evaluate `ufbx_transform.translation`.
	INCLUDE_ROTATION           = 5, // If `UFBX_TRANSFORM_FLAG_EXPLICIT_INCLUDES`: Evaluate `ufbx_transform.rotation`.
	INCLUDE_SCALE              = 6, // If `UFBX_TRANSFORM_FLAG_EXPLICIT_INCLUDES`: Evaluate `ufbx_transform.scale`.
	NO_EXTRAPOLATION           = 7, // Do not extrapolate keyframes.
	// See `UFBX_EVALUATE_FLAG_NO_EXTRAPOLATION`.
}

Transform_Flags :: distinct bit_set[Transform_Flag; c.int]

TRANSFORM_FLAGS_FORCE_32BIT :: Transform_Flags { .IGNORE_SCALE_HELPER, .IGNORE_COMPONENTWISE_SCALE, .EXPLICIT_INCLUDES, .INCLUDE_TRANSLATION, .INCLUDE_ROTATION, .INCLUDE_SCALE, .NO_EXTRAPOLATION }

@(default_calling_convention="c", link_prefix="ufbx_")
foreign lib {
	// Practically always `true` (see below), if not you need to be careful with threads.
	//
	// Guaranteed to be `true` in _any_ of the following conditions:
	// - ufbx.c has been compiled using: GCC / Clang / MSVC / ICC / EMCC / TCC
	// - ufbx.c has been compiled as C++11 or later
	// - ufbx.c has been compiled as C11 or later with `<stdatomic.h>` support
	//
	// If `false` you can't call the following functions concurrently:
	//   ufbx_evaluate_scene()
	//   ufbx_free_scene()
	//   ufbx_subdivide_mesh()
	//   ufbx_tessellate_nurbs_surface()
	//   ufbx_free_mesh()
	is_thread_safe :: proc() -> bool ---

	// Load a scene from a `size` byte memory buffer at `data`
	load_memory :: proc(data: rawptr, data_size: c.size_t, opts: ^Load_Opts, error: ^Error) -> ^Scene ---

	// Load a scene by opening a file named `filename`
	load_file     :: proc(filename: cstring, opts: ^Load_Opts, error: ^Error) -> ^Scene ---
	load_file_len :: proc(filename: cstring, filename_len: c.size_t, opts: ^Load_Opts, error: ^Error) -> ^Scene ---

	// Load a scene by reading from an `FILE *file` stream
	// NOTE: `file` is passed as a `void` pointer to avoid including <stdio.h>
	load_stdio :: proc(file: rawptr, opts: ^Load_Opts, error: ^Error) -> ^Scene ---

	// Load a scene by reading from an `FILE *file` stream with a prefix
	// NOTE: `file` is passed as a `void` pointer to avoid including <stdio.h>
	load_stdio_prefix :: proc(file: rawptr, prefix: rawptr, prefix_size: c.size_t, opts: ^Load_Opts, error: ^Error) -> ^Scene ---

	// Load a scene from a user-specified stream
	load_stream :: proc(stream: ^Stream, opts: ^Load_Opts, error: ^Error) -> ^Scene ---

	// Load a scene from a user-specified stream with a prefix
	load_stream_prefix :: proc(stream: ^Stream, prefix: rawptr, prefix_size: c.size_t, opts: ^Load_Opts, error: ^Error) -> ^Scene ---

	// Free a previously loaded or evaluated scene
	free_scene :: proc(scene: ^Scene) ---

	// Increment `scene` refcount
	retain_scene :: proc(scene: ^Scene) ---

	// Format a textual description of `error`.
	// Always produces a NULL-terminated string to `char dst[dst_size]`, truncating if
	// necessary. Returns the number of characters written not including the NULL terminator.
	format_error :: proc(dst: cstring, dst_size: c.size_t, error: ^Error) -> c.size_t ---

	// Find a property `name` from `props`, returns `NULL` if not found.
	// Searches through `ufbx_props.defaults` as well.
	find_prop_len :: proc(props: ^Props, name: cstring, name_len: c.size_t) -> ^Prop ---
	find_prop     :: proc(props: ^Props, name: cstring) -> ^Prop ---

	// Utility functions for finding the value of a property, returns `def` if not found.
	// NOTE: For `ufbx_string` you need to ensure the lifetime of the default is
	// sufficient as no copy is made.
	find_real_len   :: proc(props: ^Props, name: cstring, name_len: c.size_t, def: Real) -> Real ---
	find_real       :: proc(props: ^Props, name: cstring, def: Real) -> Real ---
	find_vec3_len   :: proc(props: ^Props, name: cstring, name_len: c.size_t, def: Vec3) -> Vec3 ---
	find_vec3       :: proc(props: ^Props, name: cstring, def: Vec3) -> Vec3 ---
	find_int_len    :: proc(props: ^Props, name: cstring, name_len: c.size_t, def: i64) -> i64 ---
	find_int        :: proc(props: ^Props, name: cstring, def: i64) -> i64 ---
	find_bool_len   :: proc(props: ^Props, name: cstring, name_len: c.size_t, def: bool) -> bool ---
	find_bool       :: proc(props: ^Props, name: cstring, def: bool) -> bool ---
	find_string_len :: proc(props: ^Props, name: cstring, name_len: c.size_t, def: String) -> String ---
	find_string     :: proc(props: ^Props, name: cstring, def: String) -> String ---
	find_blob_len   :: proc(props: ^Props, name: cstring, name_len: c.size_t, def: Blob) -> Blob ---
	find_blob       :: proc(props: ^Props, name: cstring, def: Blob) -> Blob ---

	// Find property in `props` with concatenated `parts[num_parts]`.
	find_prop_concat :: proc(props: ^Props, parts: ^String, num_parts: c.size_t) -> ^Prop ---

	// Get an element connected to a property.
	get_prop_element :: proc(element: ^Element, prop: ^Prop, type: Element_Type) -> ^Element ---

	// Find an element connected to a property by name.
	find_prop_element_len :: proc(element: ^Element, name: cstring, name_len: c.size_t, type: Element_Type) -> ^Element ---
	find_prop_element     :: proc(element: ^Element, name: cstring, type: Element_Type) -> ^Element ---

	// Find any element of type `type` in `scene` by `name`.
	// For example if you want to find `ufbx_material` named `Mat`:
	//   (ufbx_material*)ufbx_find_element(scene, UFBX_ELEMENT_MATERIAL, "Mat");
	find_element_len :: proc(scene: ^Scene, type: Element_Type, name: cstring, name_len: c.size_t) -> ^Element ---
	find_element     :: proc(scene: ^Scene, type: Element_Type, name: cstring) -> ^Element ---

	// Find node in `scene` by `name` (shorthand for `ufbx_find_element(UFBX_ELEMENT_NODE)`).
	find_node_len :: proc(scene: ^Scene, name: cstring, name_len: c.size_t) -> ^Node ---
	find_node     :: proc(scene: ^Scene, name: cstring) -> ^Node ---

	// Find an animation stack in `scene` by `name` (shorthand for `ufbx_find_element(UFBX_ELEMENT_ANIM_STACK)`)
	find_anim_stack_len :: proc(scene: ^Scene, name: cstring, name_len: c.size_t) -> ^Anim_Stack ---
	find_anim_stack     :: proc(scene: ^Scene, name: cstring) -> ^Anim_Stack ---

	// Find a material in `scene` by `name` (shorthand for `ufbx_find_element(UFBX_ELEMENT_MATERIAL)`).
	find_material_len :: proc(scene: ^Scene, name: cstring, name_len: c.size_t) -> ^Material ---
	find_material     :: proc(scene: ^Scene, name: cstring) -> ^Material ---

	// Find a single animated property `prop` of `element` in `layer`.
	// Returns `NULL` if not found.
	find_anim_prop_len :: proc(layer: ^Anim_Layer, element: ^Element, prop: cstring, prop_len: c.size_t) -> ^Anim_Prop ---
	find_anim_prop     :: proc(layer: ^Anim_Layer, element: ^Element, prop: cstring) -> ^Anim_Prop ---

	// Find all animated properties of `element` in `layer`.
	find_anim_props :: proc(layer: ^Anim_Layer, element: ^Element) -> Anim_Prop_List ---

	// Get a matrix that transforms normals in the same way as Autodesk software.
	// NOTE: The resulting normals are slightly incorrect as this function deliberately
	// inverts geometric transformation wrong. For better results use
	// `ufbx_matrix_for_normals(&node->geometry_to_world)`.
	get_compatible_matrix_for_normals :: proc(node: ^Node) -> Matrix ---

	// Decompress a DEFLATE compressed buffer.
	// Returns the decompressed size or a negative error code (see source for details).
	// NOTE: You must supply a valid `retain` with `ufbx_inflate_retain.initialized == false`
	// but the rest can be uninitialized.
	inflate :: proc(dst: rawptr, dst_size: c.size_t, input: ^Inflate_Input, retain: ^Inflate_Retain) -> c.ptrdiff_t ---

	// Same as `ufbx_open_file()` but compatible with the callback in `ufbx_open_file_fn`.
	// The `user` parameter is actually not used here.
	default_open_file :: proc(user: rawptr, stream: ^Stream, path: cstring, path_len: c.size_t, info: ^Open_File_Info) -> bool ---

	// Open a `ufbx_stream` from a file.
	// Use `path_len == SIZE_MAX` for NULL terminated string.
	open_file     :: proc(stream: ^Stream, path: cstring, path_len: c.size_t, opts: ^Open_File_Opts, error: ^Error) -> bool ---
	open_file_ctx :: proc(stream: ^Stream, ctx: Open_File_Context, path: cstring, path_len: c.size_t, opts: ^Open_File_Opts, error: ^Error) -> bool ---

	// NOTE: Uses the default ufbx allocator!
	open_memory     :: proc(stream: ^Stream, data: rawptr, data_size: c.size_t, opts: ^Open_Memory_Opts, error: ^Error) -> bool ---
	open_memory_ctx :: proc(stream: ^Stream, ctx: Open_File_Context, data: rawptr, data_size: c.size_t, opts: ^Open_Memory_Opts, error: ^Error) -> bool ---

	// Evaluate a single animation `curve` at a `time`.
	// Returns `default_value` only if `curve == NULL` or it has no keyframes.
	evaluate_curve       :: proc(curve: ^Anim_Curve, time: f64, default_value: Real) -> Real ---
	evaluate_curve_flags :: proc(curve: ^Anim_Curve, time: f64, default_value: Real, flags: u32) -> Real ---

	// Evaluate a value from bundled animation curves.
	evaluate_anim_value_real       :: proc(anim_value: ^Anim_Value, time: f64) -> Real ---
	evaluate_anim_value_vec3       :: proc(anim_value: ^Anim_Value, time: f64) -> Vec3 ---
	evaluate_anim_value_real_flags :: proc(anim_value: ^Anim_Value, time: f64, flags: u32) -> Real ---
	evaluate_anim_value_vec3_flags :: proc(anim_value: ^Anim_Value, time: f64, flags: u32) -> Vec3 ---

	// Evaluate an animated property `name` from `element` at `time`.
	// NOTE: If the property is not found it will have the flag `UFBX_PROP_FLAG_NOT_FOUND`.
	evaluate_prop_len       :: proc(anim: ^Anim, element: ^Element, name: cstring, name_len: c.size_t, time: f64) -> Prop ---
	evaluate_prop           :: proc(anim: ^Anim, element: ^Element, name: cstring, time: f64) -> Prop ---
	evaluate_prop_len_flags :: proc(anim: ^Anim, element: ^Element, name: cstring, name_len: c.size_t, time: f64, flags: u32) -> Prop ---
	evaluate_prop_flags     :: proc(anim: ^Anim, element: ^Element, name: cstring, time: f64, flags: u32) -> Prop ---

	// Evaluate all _animated_ properties of `element`.
	// HINT: This function returns an `ufbx_props` structure with the original properties as
	// `ufbx_props.defaults`. This lets you use `ufbx_find_prop/value()` for the results.
	evaluate_props       :: proc(anim: ^Anim, element: ^Element, time: f64, buffer: ^Prop, buffer_size: c.size_t) -> Props ---
	evaluate_props_flags :: proc(anim: ^Anim, element: ^Element, time: f64, buffer: ^Prop, buffer_size: c.size_t, flags: u32) -> Props ---

	// Evaluate the animated transform of a node given a time.
	// The returned transform is the local transform of the node (ie. relative to the parent),
	// comparable to `ufbx_node.local_transform`.
	evaluate_transform       :: proc(anim: ^Anim, node: ^Node, time: f64) -> Transform ---
	evaluate_transform_flags :: proc(anim: ^Anim, node: ^Node, time: f64, flags: u32) -> Transform ---

	// Evaluate the blend shape weight of a blend channel.
	// NOTE: Return value uses `1.0` for full weight, instead of `100.0` that the internal property `UFBX_Weight` uses.
	evaluate_blend_weight       :: proc(anim: ^Anim, channel: ^Blend_Channel, time: f64) -> Real ---
	evaluate_blend_weight_flags :: proc(anim: ^Anim, channel: ^Blend_Channel, time: f64, flags: u32) -> Real ---

	// Evaluate the whole `scene` at a specific `time` in the animation `anim`.
	// The returned scene behaves as if it had been exported at a specific time
	// in the specified animation, except that animated elements' properties contain
	// only the animated values, the original ones are in `props->defaults`.
	//
	// NOTE: The returned scene refers to the original `scene` so the original
	// scene cannot be freed until all evaluated scenes are freed.
	evaluate_scene :: proc(scene: ^Scene, anim: ^Anim, time: f64, opts: ^Evaluate_Opts, error: ^Error) -> ^Scene ---

	// Create a custom animation descriptor.
	// `ufbx_anim_opts` is used to specify animation layers and weights.
	// HINT: You can also leave `ufbx_anim_opts.layer_ids[]` empty and only specify
	// overrides to evaluate the scene with different properties or local transforms.
	create_anim :: proc(scene: ^Scene, opts: ^Anim_Opts, error: ^Error) -> ^Anim ---

	// Free an animation returned by `ufbx_create_anim()`.
	free_anim :: proc(anim: ^Anim) ---

	// Increase the animation reference count.
	retain_anim :: proc(anim: ^Anim) ---

	// "Bake" an animation to linearly interpolated keyframes.
	// Composites the FBX transformation chain into quaternion rotations.
	bake_anim                        :: proc(scene: ^Scene, anim: ^Anim, opts: ^Bake_Opts, error: ^Error) -> ^Baked_Anim ---
	retain_baked_anim                :: proc(bake: ^Baked_Anim) ---
	free_baked_anim                  :: proc(bake: ^Baked_Anim) ---
	find_baked_node_by_typed_id      :: proc(bake: ^Baked_Anim, typed_id: u32) -> ^Baked_Node ---
	find_baked_node                  :: proc(bake: ^Baked_Anim, node: ^Node) -> ^Baked_Node ---
	find_baked_element_by_element_id :: proc(bake: ^Baked_Anim, element_id: u32) -> ^Baked_Element ---
	find_baked_element               :: proc(bake: ^Baked_Anim, element: ^Element) -> ^Baked_Element ---

	// Evaluate baked animation `keyframes` at `time`.
	// Internally linearly interpolates between two adjacent keyframes.
	// Handles stepped tangents cleanly, which is not strictly necessary for custom interpolation.
	evaluate_baked_vec3 :: proc(keyframes: Baked_Vec3_List, time: f64) -> Vec3 ---

	// Evaluate baked animation `keyframes` at `time`.
	// Internally spherically interpolates (`ufbx_quat_slerp()`) between two adjacent keyframes.
	// Handles stepped tangents cleanly, which is not strictly necessary for custom interpolation.
	evaluate_baked_quat :: proc(keyframes: Baked_Quat_List, time: f64) -> Quat ---

	// Retrieve the bone pose for `node`.
	// Returns `NULL` if the pose does not contain `node`.
	get_bone_pose :: proc(pose: ^Pose, node: ^Node) -> ^Bone_Pose ---

	// Find a texture for a given material FBX property.
	find_prop_texture_len :: proc(material: ^Material, name: cstring, name_len: c.size_t) -> ^Texture ---
	find_prop_texture     :: proc(material: ^Material, name: cstring) -> ^Texture ---

	// Find a texture for a given shader property.
	find_shader_prop_len :: proc(shader: ^Shader, name: cstring, name_len: c.size_t) -> String ---
	find_shader_prop     :: proc(shader: ^Shader, name: cstring) -> String ---

	// Map from a shader property to material property.
	find_shader_prop_bindings_len :: proc(shader: ^Shader, name: cstring, name_len: c.size_t) -> Shader_Prop_Binding_List ---
	find_shader_prop_bindings     :: proc(shader: ^Shader, name: cstring) -> Shader_Prop_Binding_List ---

	// Find an input in a shader texture.
	find_shader_texture_input_len :: proc(shader: ^Shader_Texture, name: cstring, name_len: c.size_t) -> ^Shader_Texture_Input ---
	find_shader_texture_input     :: proc(shader: ^Shader_Texture, name: cstring) -> ^Shader_Texture_Input ---

	// Returns `true` if `axes` forms a valid coordinate space.
	coordinate_axes_valid :: proc(axes: Coordinate_Axes) -> bool ---

	// Vector math utility functions.
	vec3_normalize :: proc(v: Vec3) -> Vec3 ---

	// Quaternion math utility functions.
	quat_dot           :: proc(a: Quat, b: Quat) -> Real ---
	quat_mul           :: proc(a: Quat, b: Quat) -> Quat ---
	quat_normalize     :: proc(q: Quat) -> Quat ---
	quat_fix_antipodal :: proc(q: Quat, reference: Quat) -> Quat ---
	quat_slerp         :: proc(a: Quat, b: Quat, t: Real) -> Quat ---
	quat_rotate_vec3   :: proc(q: Quat, v: Vec3) -> Vec3 ---
	quat_to_euler      :: proc(q: Quat, order: Rotation_Order) -> Vec3 ---
	euler_to_quat      :: proc(v: Vec3, order: Rotation_Order) -> Quat ---

	// Matrix math utility functions.
	matrix_mul         :: proc(a: ^Matrix, b: ^Matrix) -> Matrix ---
	matrix_determinant :: proc(m: ^Matrix) -> Real ---
	matrix_invert      :: proc(m: ^Matrix) -> Matrix ---

	// Get a matrix that can be used to transform geometry normals.
	// NOTE: You must normalize the normals after transforming them with this matrix,
	// eg. using `ufbx_vec3_normalize()`.
	// NOTE: This function flips the normals if the determinant is negative.
	matrix_for_normals :: proc(m: ^Matrix) -> Matrix ---

	// Matrix transformation utilities.
	transform_position  :: proc(m: ^Matrix, v: Vec3) -> Vec3 ---
	transform_direction :: proc(m: ^Matrix, v: Vec3) -> Vec3 ---

	// Conversions between `ufbx_matrix` and `ufbx_transform`.
	transform_to_matrix :: proc(t: ^Transform) -> Matrix ---
	matrix_to_transform :: proc(m: ^Matrix) -> Transform ---

	// Get a matrix representing the deformation for a single vertex.
	// Returns `fallback` if the vertex is not skinned.
	catch_get_skin_vertex_matrix :: proc(panic: ^Panic, skin: ^Skin_Deformer, vertex: c.size_t, fallback: ^Matrix) -> Matrix ---
	get_skin_vertex_matrix       :: proc(skin: ^Skin_Deformer, vertex: c.size_t, fallback: ^Matrix) -> Matrix ---

	// Resolve the index into `ufbx_blend_shape.position_offsets[]` given a vertex.
	// Returns `UFBX_NO_INDEX` if the vertex is not included in the blend shape.
	get_blend_shape_offset_index :: proc(shape: ^Blend_Shape, vertex: c.size_t) -> u32 ---

	// Get the offset for a given vertex in the blend shape.
	// Returns `ufbx_zero_vec3` if the vertex is not a included in the blend shape.
	get_blend_shape_vertex_offset :: proc(shape: ^Blend_Shape, vertex: c.size_t) -> Vec3 ---

	// Get the _current_ blend offset given a blend deformer.
	// NOTE: This depends on the current animated blend weight of the deformer.
	get_blend_vertex_offset :: proc(blend: ^Blend_Deformer, vertex: c.size_t) -> Vec3 ---

	// Apply the blend shape with `weight` to given vertices.
	add_blend_shape_vertex_offsets :: proc(shape: ^Blend_Shape, vertices: ^Vec3, num_vertices: c.size_t, weight: Real) ---

	// Apply the blend deformer with `weight` to given vertices.
	// NOTE: This depends on the current animated blend weight of the deformer.
	add_blend_vertex_offsets :: proc(blend: ^Blend_Deformer, vertices: ^Vec3, num_vertices: c.size_t, weight: Real) ---

	// Low-level utility to evaluate NURBS the basis functions.
	evaluate_nurbs_basis :: proc(basis: ^Nurbs_Basis, u: Real, weights: ^Real, num_weights: c.size_t, derivatives: ^Real, num_derivatives: c.size_t) -> c.size_t ---

	// Evaluate a point on a NURBS curve given the parameter `u`.
	evaluate_nurbs_curve :: proc(curve: ^Nurbs_Curve, u: Real) -> Curve_Point ---

	// Evaluate a point on a NURBS surface given the parameter `u` and `v`.
	evaluate_nurbs_surface :: proc(surface: ^Nurbs_Surface, u: Real, v: Real) -> Surface_Point ---

	// Tessellate a NURBS curve into a polyline.
	tessellate_nurbs_curve :: proc(curve: ^Nurbs_Curve, opts: ^Tessellate_Curve_Opts, error: ^Error) -> ^Line_Curve ---

	// Tessellate a NURBS surface into a mesh.
	tessellate_nurbs_surface :: proc(surface: ^Nurbs_Surface, opts: ^Tessellate_Surface_Opts, error: ^Error) -> ^Mesh ---

	// Free a line returned by `ufbx_tessellate_nurbs_curve()`.
	free_line_curve :: proc(curve: ^Line_Curve) ---

	// Increase the refcount of the line.
	retain_line_curve :: proc(curve: ^Line_Curve) ---

	// Find the face that contains a given `index`.
	// Returns `UFBX_NO_INDEX` if out of bounds.
	find_face_index :: proc(mesh: ^Mesh, index: c.size_t) -> u32 ---

	// Triangulate a mesh face, returning the number of triangles.
	// NOTE: You need to space for `(face.num_indices - 2) * 3 - 1` indices!
	// HINT: Using `ufbx_mesh.max_face_triangles * 3` is always safe.
	catch_triangulate_face :: proc(panic: ^Panic, indices: ^u32, num_indices: c.size_t, mesh: ^Mesh, face: Face) -> u32 ---
	triangulate_face       :: proc(indices: ^u32, num_indices: c.size_t, mesh: ^Mesh, face: Face) -> u32 ---

	// Generate the half-edge representation of `mesh` to `topo[mesh->num_indices]`
	catch_compute_topology :: proc(panic: ^Panic, mesh: ^Mesh, topo: ^Topo_Edge, num_topo: c.size_t) ---
	compute_topology       :: proc(mesh: ^Mesh, topo: ^Topo_Edge, num_topo: c.size_t) ---

	// Get the next half-edge in `topo`.
	catch_topo_next_vertex_edge :: proc(panic: ^Panic, topo: ^Topo_Edge, num_topo: c.size_t, index: u32) -> u32 ---
	topo_next_vertex_edge       :: proc(topo: ^Topo_Edge, num_topo: c.size_t, index: u32) -> u32 ---

	// Get the previous half-edge in `topo`.
	catch_topo_prev_vertex_edge :: proc(panic: ^Panic, topo: ^Topo_Edge, num_topo: c.size_t, index: u32) -> u32 ---
	topo_prev_vertex_edge       :: proc(topo: ^Topo_Edge, num_topo: c.size_t, index: u32) -> u32 ---

	// Calculate a normal for a given face.
	// The returned normal is weighted by face area.
	catch_get_weighted_face_normal :: proc(panic: ^Panic, positions: ^Vertex_Vec3, face: Face) -> Vec3 ---
	get_weighted_face_normal       :: proc(positions: ^Vertex_Vec3, face: Face) -> Vec3 ---

	// Generate indices for normals from the topology.
	// Respects smoothing groups.
	catch_generate_normal_mapping :: proc(panic: ^Panic, mesh: ^Mesh, topo: ^Topo_Edge, num_topo: c.size_t, normal_indices: ^u32, num_normal_indices: c.size_t, assume_smooth: bool) -> c.size_t ---
	generate_normal_mapping       :: proc(mesh: ^Mesh, topo: ^Topo_Edge, num_topo: c.size_t, normal_indices: ^u32, num_normal_indices: c.size_t, assume_smooth: bool) -> c.size_t ---

	// Compute normals given normal indices.
	// You can use `ufbx_generate_normal_mapping()` to generate the normal indices.
	catch_compute_normals :: proc(panic: ^Panic, mesh: ^Mesh, positions: ^Vertex_Vec3, normal_indices: ^u32, num_normal_indices: c.size_t, normals: ^Vec3, num_normals: c.size_t) ---
	compute_normals       :: proc(mesh: ^Mesh, positions: ^Vertex_Vec3, normal_indices: ^u32, num_normal_indices: c.size_t, normals: ^Vec3, num_normals: c.size_t) ---

	// Subdivide a mesh using the Catmull-Clark subdivision `level` times.
	subdivide_mesh :: proc(mesh: ^Mesh, level: c.size_t, opts: ^Subdivide_Opts, error: ^Error) -> ^Mesh ---

	// Free a mesh returned from `ufbx_subdivide_mesh()` or `ufbx_tessellate_nurbs_surface()`.
	free_mesh :: proc(mesh: ^Mesh) ---

	// Increase the mesh reference count.
	retain_mesh :: proc(mesh: ^Mesh) ---

	// Load geometry cache information from a file.
	// As geometry caches can be massive, this does not actually read the data, but
	// only seeks through the files to form the metadata.
	load_geometry_cache     :: proc(filename: cstring, opts: ^Geometry_Cache_Opts, error: ^Error) -> ^Geometry_Cache ---
	load_geometry_cache_len :: proc(filename: cstring, filename_len: c.size_t, opts: ^Geometry_Cache_Opts, error: ^Error) -> ^Geometry_Cache ---

	// Free a geometry cache returned from `ufbx_load_geometry_cache()`.
	free_geometry_cache :: proc(cache: ^Geometry_Cache) ---

	// Increase the geometry cache reference count.
	retain_geometry_cache :: proc(cache: ^Geometry_Cache) ---

	// Read a frame from a geometry cache.
	read_geometry_cache_real :: proc(frame: ^Cache_Frame, data: ^Real, num_data: c.size_t, opts: ^Geometry_Cache_Data_Opts) -> c.size_t ---
	read_geometry_cache_vec3 :: proc(frame: ^Cache_Frame, data: ^Vec3, num_data: c.size_t, opts: ^Geometry_Cache_Data_Opts) -> c.size_t ---

	// Sample the a geometry cache channel, linearly blending between adjacent frames.
	sample_geometry_cache_real :: proc(channel: ^Cache_Channel, time: f64, data: ^Real, num_data: c.size_t, opts: ^Geometry_Cache_Data_Opts) -> c.size_t ---
	sample_geometry_cache_vec3 :: proc(channel: ^Cache_Channel, time: f64, data: ^Vec3, num_data: c.size_t, opts: ^Geometry_Cache_Data_Opts) -> c.size_t ---

	// Find a DOM node given a name.
	dom_find_len :: proc(parent: ^Dom_Node, name: cstring, name_len: c.size_t) -> ^Dom_Node ---
	dom_find     :: proc(parent: ^Dom_Node, name: cstring) -> ^Dom_Node ---

	// Generate an index buffer for a flat vertex buffer.
	// `streams` specifies one or more vertex data arrays, each stream must contain `num_indices` vertices.
	// This function compacts the data within `streams` in-place, writing the deduplicated indices to `indices`.
	generate_indices :: proc(streams: [^]Vertex_Stream, num_streams: c.size_t, indices: ^u32, num_indices: c.size_t, allocator: ^Allocator_Opts, error: ^Error) -> c.size_t ---

	// Run a single thread pool task.
	// See `ufbx_thread_pool_run_fn` for more information.
	thread_pool_run_task :: proc(ctx: Thread_Pool_Context, index: u32) ---

	// Get or set an arbitrary user pointer for the thread pool context.
	// `ufbx_thread_pool_get_user_ptr()` returns `NULL` if unset.
	thread_pool_set_user_ptr :: proc(ctx: Thread_Pool_Context, user_ptr: rawptr) ---
	thread_pool_get_user_ptr :: proc(ctx: Thread_Pool_Context) -> rawptr ---

	// Utility functions for reading geometry data for a single index.
	catch_get_vertex_real :: proc(panic: ^Panic, v: ^Vertex_Real, index: c.size_t) -> Real ---
	catch_get_vertex_vec2 :: proc(panic: ^Panic, v: ^Vertex_Vec2, index: c.size_t) -> Vec2 ---
	catch_get_vertex_vec3 :: proc(panic: ^Panic, v: ^Vertex_Vec3, index: c.size_t) -> Vec3 ---
	catch_get_vertex_vec4 :: proc(panic: ^Panic, v: ^Vertex_Vec4, index: c.size_t) -> Vec4 ---

	// Utility functions for reading geometry data for a single index.
	get_vertex_real         :: proc(v: ^Vertex_Real, index: c.size_t) -> Real ---
	get_vertex_vec2         :: proc(v: ^Vertex_Vec2, index: c.size_t) -> Vec2 ---
	get_vertex_vec3         :: proc(v: ^Vertex_Vec3, index: c.size_t) -> Vec3 ---
	get_vertex_vec4         :: proc(v: ^Vertex_Vec4, index: c.size_t) -> Vec4 ---
	catch_get_vertex_w_vec3 :: proc(panic: ^Panic, v: ^Vertex_Vec3, index: c.size_t) -> Real ---
	get_vertex_w_vec3       :: proc(v: ^Vertex_Vec3, index: c.size_t) -> Real ---

	// Functions for converting an untyped `ufbx_element` to a concrete type.
	// Returns `NULL` if the element is not that type.
	as_unknown             :: proc(element: ^Element) -> ^Unknown ---
	as_node                :: proc(element: ^Element) -> ^Node ---
	as_mesh                :: proc(element: ^Element) -> ^Mesh ---
	as_light               :: proc(element: ^Element) -> ^Light ---
	as_camera              :: proc(element: ^Element) -> ^Camera ---
	as_bone                :: proc(element: ^Element) -> ^Bone ---
	as_empty               :: proc(element: ^Element) -> ^Empty ---
	as_line_curve          :: proc(element: ^Element) -> ^Line_Curve ---
	as_nurbs_curve         :: proc(element: ^Element) -> ^Nurbs_Curve ---
	as_nurbs_surface       :: proc(element: ^Element) -> ^Nurbs_Surface ---
	as_nurbs_trim_surface  :: proc(element: ^Element) -> ^Nurbs_Trim_Surface ---
	as_nurbs_trim_boundary :: proc(element: ^Element) -> ^Nurbs_Trim_Boundary ---
	as_procedural_geometry :: proc(element: ^Element) -> ^Procedural_Geometry ---
	as_stereo_camera       :: proc(element: ^Element) -> ^Stereo_Camera ---
	as_camera_switcher     :: proc(element: ^Element) -> ^Camera_Switcher ---
	as_marker              :: proc(element: ^Element) -> ^Marker ---
	as_lod_group           :: proc(element: ^Element) -> ^Lod_Group ---
	as_skin_deformer       :: proc(element: ^Element) -> ^Skin_Deformer ---
	as_skin_cluster        :: proc(element: ^Element) -> ^Skin_Cluster ---
	as_blend_deformer      :: proc(element: ^Element) -> ^Blend_Deformer ---
	as_blend_channel       :: proc(element: ^Element) -> ^Blend_Channel ---
	as_blend_shape         :: proc(element: ^Element) -> ^Blend_Shape ---
	as_cache_deformer      :: proc(element: ^Element) -> ^Cache_Deformer ---
	as_cache_file          :: proc(element: ^Element) -> ^Cache_File ---
	as_material            :: proc(element: ^Element) -> ^Material ---
	as_texture             :: proc(element: ^Element) -> ^Texture ---
	as_video               :: proc(element: ^Element) -> ^Video ---
	as_shader              :: proc(element: ^Element) -> ^Shader ---
	as_shader_binding      :: proc(element: ^Element) -> ^Shader_Binding ---
	as_anim_stack          :: proc(element: ^Element) -> ^Anim_Stack ---
	as_anim_layer          :: proc(element: ^Element) -> ^Anim_Layer ---
	as_anim_value          :: proc(element: ^Element) -> ^Anim_Value ---
	as_anim_curve          :: proc(element: ^Element) -> ^Anim_Curve ---
	as_display_layer       :: proc(element: ^Element) -> ^Display_Layer ---
	as_selection_set       :: proc(element: ^Element) -> ^Selection_Set ---
	as_selection_node      :: proc(element: ^Element) -> ^Selection_Node ---
	as_character           :: proc(element: ^Element) -> ^Character ---
	as_constraint          :: proc(element: ^Element) -> ^Constraint ---
	as_audio_layer         :: proc(element: ^Element) -> ^Audio_Layer ---
	as_audio_clip          :: proc(element: ^Element) -> ^Audio_Clip ---
	as_pose                :: proc(element: ^Element) -> ^Pose ---
	as_metadata_object     :: proc(element: ^Element) -> ^Metadata_Object ---
}
