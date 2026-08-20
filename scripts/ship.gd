class_name OrbitShip
extends Node2D

@export var radius: float = 18.0

var orbit_center: Vector2 = Vector2.ZERO
var orbit_radius: float = 130.0
var orbit_angle: float = 0.0
var orbit_direction: int = 1
var velocity: Vector2 = Vector2.ZERO
var trail_points: PackedVector2Array = PackedVector2Array()
var thruster_time: float = 0.0


func attach_to_planet(center: Vector2, new_orbit_radius: float, contact_angle: float, direction: int) -> void:
	orbit_center = center
	orbit_radius = new_orbit_radius
	orbit_angle = contact_angle
	orbit_direction = signi(direction)
	if orbit_direction == 0:
		orbit_direction = 1
	global_position = OrbitMath.orbit_position(orbit_center, orbit_radius, orbit_angle)
	velocity = Vector2.ZERO
	trail_points.clear()
	_update_rotation()
	queue_redraw()


func update_orbit(delta: float, angular_speed: float) -> void:
	orbit_angle = fposmod(orbit_angle + angular_speed * float(orbit_direction) * delta, TAU)
	global_position = OrbitMath.orbit_position(orbit_center, orbit_radius, orbit_angle)
	_update_rotation()
	thruster_time += delta
	queue_redraw()


func launch(speed: float) -> Vector2:
	var launch_direction := OrbitMath.tangent_for_angle(orbit_angle, orbit_direction)
	velocity = launch_direction * speed
	trail_points.clear()
	trail_points.append(global_position)
	rotation = velocity.angle()
	return launch_direction


func update_flight(delta: float) -> void:
	global_position += velocity * delta
	rotation = velocity.angle()
	thruster_time += delta
	if trail_points.is_empty() or trail_points[-1].distance_to(global_position) > 13.0:
		trail_points.append(global_position)
		if trail_points.size() > 34:
			trail_points.remove_at(0)
	queue_redraw()


func _update_rotation() -> void:
	rotation = OrbitMath.tangent_for_angle(orbit_angle, orbit_direction).angle()


func _draw() -> void:
	if trail_points.size() >= 2:
		var local_trail := PackedVector2Array()
		for point in trail_points:
			local_trail.append(to_local(point))
		for index in range(1, local_trail.size()):
			var alpha := float(index) / float(local_trail.size()) * 0.42
			draw_line(local_trail[index - 1], local_trail[index], Color("6ffcff", alpha), 7.0, true)

	var flame_length := 19.0 + sin(thruster_time * 22.0) * 5.0
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-radius * 0.75, -7.0),
			Vector2(-radius - flame_length, 0.0),
			Vector2(-radius * 0.75, 7.0),
		]),
		Color("ff4fd8", 0.88)
	)
	draw_circle(Vector2.ZERO, radius + 10.0, Color("72faff", 0.08))
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(radius + 8.0, 0.0),
			Vector2(-radius * 0.72, -radius * 0.7),
			Vector2(-radius * 0.38, 0.0),
			Vector2(-radius * 0.72, radius * 0.7),
		]),
		Color("e9feff")
	)
	draw_polyline(
		PackedVector2Array([
			Vector2(radius + 8.0, 0.0),
			Vector2(-radius * 0.72, -radius * 0.7),
			Vector2(-radius * 0.38, 0.0),
			Vector2(-radius * 0.72, radius * 0.7),
			Vector2(radius + 8.0, 0.0),
		]),
		Color("72faff"),
		3.0,
		true
	)
	draw_circle(Vector2(2.0, 0.0), 5.0, Color("ff64db"))
