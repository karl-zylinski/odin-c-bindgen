package ufbx_test

import "../ufbx"
import "core:fmt"

main :: proc() {
	opts: ufbx.Load_Opts
	error: ufbx.Error

	scene := ufbx.load_file("thing.fbx", &opts, &error)
	fmt.ensuref(scene != nil, "Failed to load %s", error.description.data)

	for i in 0..<scene.nodes.count {
		node := scene.nodes.data[i]

		if node.is_root {
			continue
		}

		fmt.printfln("Object: %s", node.name.data)

		if node.mesh != nil {
			fmt.printfln("-> mesh with %v faces", node.mesh.faces.count);
		}
	}
	
	ufbx.free_scene(scene)
}