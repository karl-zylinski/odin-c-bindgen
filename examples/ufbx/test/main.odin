package ufbx_test

import "../ufbx"
import "core:fmt"
import rl "vendor:raylib"
import "core:slice"

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
		}

		vertices := make([]Vertex, m.num_triangles * 3, allocator, loc)
		num_vertices := 0
		face_indices := make([]u32, m.max_face_triangles * 3, context.temp_allocator)

		for fidx in 0..<m.faces.count {
			f := m.faces.data[fidx]
			num_face_triangles := ufbx.triangulate_face(raw_data(face_indices), len(face_indices), m, f)

			for tidx in 0..<num_face_triangles*3 {
				tris_idx := face_indices[tidx]
				pos := m.vertex_position.values.data[m.vertex_position.indices.data[tris_idx]]
				vertices[num_vertices] = { pos = pos }
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

		rindinces := make([]u16, num_indices, allocator, loc)

		for i, idx in indices {
			rindinces[idx] = u16(i)
		}

		rvertices := slice.reinterpret([]f32, vertices)

		rm := rl.Mesh {
			indices = raw_data(rindinces),
			triangleCount = i32(m.num_triangles),
			vertices = raw_data(rvertices),
			vertexCount = i32(len(rvertices)),
		}

		rl.UploadMesh(&rm, false)
		append(&res, rm)
	}

	ufbx.free_scene(scene)
	return res[:]
}

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
		rl.BeginMode3D(camera)
 
		for m in meshes {
			transf: rl.Matrix = 1
			rl.DrawMesh(m, default_material, transf)
		}

		rl.EndMode3D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
	
}