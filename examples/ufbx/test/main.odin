package ufbx_test

import "../ufbx"
import "core:fmt"
import rl "vendor:raylib"
import "core:math"

main :: proc() {
	rl.InitWindow(1280, 720, "ufbx test")
	meshes := load_fbx_meshes("box.fbx")

	camera := rl.Camera3D {
		position = {2, 2, -5},
		target = {0, 0, 0},
		up = {0, 1, 0},
		fovy = 70,
		projection = .PERSPECTIVE,
	}

	default_material := rl.LoadMaterialDefault()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.SKYBLUE)
		rl.BeginMode3D(camera)
		t := f32(rl.GetTime())
 
		for m in meshes {
			pos := rl.MatrixTranslate(math.cos(t), math.sin(t*2+20), 0)
			rot := rl.MatrixRotate({1, 2, 3}, t*3)
			scl := rl.MatrixScale(1 + math.cos(t) * 0.5, 1 + math.sin(t*5+123) * 0.5, 1)
			rl.DrawMesh(m, default_material, pos * rot * scl)
		}

		rl.EndMode3D()
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}

	for m in meshes {
		rl.UnloadMesh(m)
	}

	delete(meshes)
	rl.CloseWindow()
}

/*
Loads raylib meshes using ufbx.

The returned array is allocated using `allocator`. The meshes themselves are
allocated using raylib's allocator, destroy each using `rl.UnloadMesh(mesh)`.

Does triangulation using `ufbx.triangulate_face`. In order to do that it turns
each mesh into an intermediate representation. It then calculates the indices
and de-duplicates the vertices using `ufbx.generate_indices`.
*/
load_fbx_meshes :: proc(filename: string, allocator := context.allocator, loc := #caller_location) -> []rl.Mesh {
	opts: ufbx.Load_Opts
	error: ufbx.Error
	scene := ufbx.load_file(fmt.ctprint(filename), &opts, &error)

	if scene == nil {
		fmt.eprintf("Failed loading model %v, error: %v", filename, error.description.data)
		return {}
	}

	res := make([dynamic]rl.Mesh, allocator, loc)

	for i in 0..<scene.nodes.count {
		node := scene.nodes.data[i]

		if node.mesh == nil {
			continue
		}

		m := node.mesh

		Vertex :: struct {
			pos: [3]f32,
			normal: [3]f32,
			texcoord: [2]f32,
			color: [4]f32,
		}

		vertices := make([]Vertex, m.num_triangles * 3, context.temp_allocator)
		num_vertices := 0
		face_indices := make([]u32, m.max_face_triangles * 3, context.temp_allocator)

		for fidx in 0..<m.faces.count {
			f := m.faces.data[fidx]
			num_face_triangles := ufbx.triangulate_face(raw_data(face_indices), len(face_indices), m, f)

			for tidx in 0..<num_face_triangles*3 {
				tris_idx := face_indices[tidx]

				get_or_default :: proc(vertex: $T, idx: u32, default: $R) -> R {
					if !vertex.exists {
						return default
					}

					return vertex.values.data[vertex.indices.data[idx]]
				}

				vertices[num_vertices] = {
					pos = m.vertex_position.values.data[m.vertex_position.indices.data[tris_idx]],
					color = get_or_default(m.vertex_color, tris_idx, [4]f32 {1, 1, 1, 1}),
					texcoord = get_or_default(m.vertex_uv, tris_idx, [2]f32 {0, 0}),
					normal = get_or_default(m.vertex_normal, tris_idx, [3]f32 {0, 0, 0}),
				}

				num_vertices += 1
			}
		}

		vertex_stream := ufbx.Vertex_Stream {
			data = raw_data(vertices),
			vertex_count = len(vertices),
			vertex_size = size_of(Vertex),
		}

		num_indices := m.num_triangles * 3
		indices := make([]u32, num_indices, context.temp_allocator)
		num_vertices = int(ufbx.generate_indices(&vertex_stream, 1, raw_data(indices), num_indices, nil, nil))
		vertices = vertices[:num_vertices]

		rm := rl.Mesh {
			triangleCount = i32(m.num_triangles),
			vertexCount = i32(len(vertices)),
			indices = ([^]u16)(rl.MemAlloc(u32(size_of(u16) * num_indices))),
			vertices = ([^]f32)(rl.MemAlloc(u32(size_of(f32) * 3 * len(vertices)))),
			colors = ([^]u8)(rl.MemAlloc(u32(size_of(u8) * 4 * len(vertices)))),
			normals = ([^]f32)(rl.MemAlloc(u32(size_of(f32) * 3 * len(vertices)))),
			texcoords = ([^]f32)(rl.MemAlloc(u32(size_of(f32) * 2 * len(vertices)))),
		}

		for i, iidx in indices {
			rm.indices[iidx] = u16(i)
		}

		for v, vidx in vertices {
			rm.vertices[vidx * 3 + 0] = v.pos.x
			rm.vertices[vidx * 3 + 1] = v.pos.y
			rm.vertices[vidx * 3 + 2] = v.pos.z

			rm.normals[vidx * 3 + 0] = v.normal.x
			rm.normals[vidx * 3 + 1] = v.normal.y
			rm.normals[vidx * 3 + 2] = v.normal.z

			rm.texcoords[vidx * 2 + 0] = v.texcoord.x
			rm.texcoords[vidx * 2 + 1] = v.texcoord.y

			rm.colors[vidx * 4 + 0] = u8(v.color.r*255)
			rm.colors[vidx * 4 + 1] = u8(v.color.g*255)
			rm.colors[vidx * 4 + 2] = u8(v.color.b*255)
			rm.colors[vidx * 4 + 3] = u8(v.color.a*255)
		}

		rl.UploadMesh(&rm, false)
		append(&res, rm)
	}

	ufbx.free_scene(scene)
	return res[:]
}
