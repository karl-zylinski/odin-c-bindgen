// Odin + Box2D + Raylib example with stacking boxes and a shape attached to the cursor that can smack the shapes.
// Made (mostly) during this stream: https://www.youtube.com/watch?v=LYW7jdwEnaI

// I have updated this to use the `vendor:box2d` bindings instead of the ones I used on the stream.

package game

import b2 "../box2d"
import rl "vendor:raylib"
import "core:math"

create_box :: proc(world_id: b2.WorldId, pos: b2.Vec2) -> b2.BodyId{
	body_def := b2.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.position = pos
	body_id := b2.CreateBody(world_id, body_def)

	shape_def := b2.DefaultShapeDef()
	shape_def.density = 1
	shape_def.friction = 0.3

	box := b2.MakeBox(20, 20)
	box_def := b2.DefaultShapeDef()
	_ = b2.CreatePolygonShape(body_id, box_def, box)

	return body_id
}

main :: proc() {
	rl.InitWindow(1280, 720, "Box2D + Raylib example")

	world_def := b2.DefaultWorldDef()
	world_def.gravity = b2.Vec2{0, -1}
	world_id := b2.CreateWorld(world_def)
	defer b2.DestroyWorld(world_id)

	ground := rl.Rectangle {
		0, 600,
		1280, 120,
	}

	ground_body_def := b2.DefaultBodyDef()
	ground_body_def.position = b2.Vec2{ground.x, -ground.y-ground.height}
	ground_body_id := b2.CreateBody(world_id, ground_body_def)

	ground_box := b2.MakeBox(ground.width, ground.height)
	ground_shape_def := b2.DefaultShapeDef()
	_ = b2.CreatePolygonShape(ground_body_id, ground_shape_def, ground_box)

	bodies: [dynamic]b2.BodyId

	px: f32 = 400
	py: f32 = -400

	num_per_row := 10
	num_in_row := 0

	for _ in 0..<50 {
		b := create_box(world_id, {px, py})
		append(&bodies, b)
		num_in_row += 1

		if num_in_row == num_per_row {
			py += 30
			px = 200
			num_per_row -= 1
			num_in_row = 0
		}

		px += 30
	}

	body_def := b2.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.position = b2.Vec2{0, 4}
	body_id := b2.CreateBody(world_id, body_def)

	shape_def := b2.DefaultShapeDef()
	shape_def.density = 1000
	shape_def.friction = 0.3

	circle: b2.Circle
	circle.radius = 40
	_ = b2.CreateCircleShape(body_id, shape_def, circle)

	time_step: f32 = 1.0 / 60
	sub_steps: i32 = 4

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.DrawRectangleRec(ground, rl.RED)
		mouse_pos := rl.GetMousePosition()

		b2.Body_SetTransform(body_id, {mouse_pos.x, -mouse_pos.y}, {})
		b2.World_Step(world_id, time_step, sub_steps)

		for b in bodies {
			position := b2.Body_GetPosition(b)
			r := b2.Body_GetRotation(b)
			a := math.atan2(r.s, r._c)
			// Y position is flipped because raylib has Y down and box2d has Y up.
			rl.DrawRectanglePro({position.x, -position.y, 40, 40}, {20, 20}, a*(180/3.14), rl.YELLOW)
		}

		rl.DrawCircleV(mouse_pos, 40, rl.MAGENTA)
		rl.EndDrawing()	
	}

	rl.CloseWindow()
}