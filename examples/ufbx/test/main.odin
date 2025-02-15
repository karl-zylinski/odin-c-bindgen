package ufbx_test

import "../ufbx"
import "core:fmt"

main :: proc() {
	opts: ufbx.Load_Opts
	error: ufbx.Error

	scene := ufbx.load_file("thing.fbx", &opts, &error)
	fmt.ensuref(scene != nil, "Failed to load %s", error.description.data)

	// Does not yet work because scene is missing an anonymous union, due to
	// a missing feature in bindgen (hopefully coming soon).
	/*for i in 0..<scene.nodes.count {
		ufbx_node *node = scene->nodes.data[i];
		if (node->is_root) continue;

		printf("Object: %s\n", node->name.data);
		if (node->mesh) {
			printf("-> mesh with %zu faces\n", node->mesh->faces.count);
		}
	}*/
	
	ufbx.free_scene(scene)
}