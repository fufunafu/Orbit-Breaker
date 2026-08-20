class_name OrbitHazard
extends Node2D

@export var radius: float = 32.0
var spin: float = 0.0
var points: PackedVector2Array = PackedVector2Array()


func configure(new_radius: float, seed_value: int) -> void:
	radius = new_radius
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = seed_value
	points.clear()
	var count := 9
	for index in count:
		var angle := TAU * float(index) / float(count)
		var point_radius := radius * local_rng.randf_range(0.78, 1.1)
		points.append(Vector2.from_angle(angle) * point_radius)
	queue_redraw()


func _process(delta: float) -> void:
	spin += delta * 0.85
	rotation = spin
	queue_redraw()


func _draw() -> void:
	if points.is_empty():
		configure(radius, 1)
	for glow_index in range(4, 0, -1):
		draw_circle(Vector2.ZERO, radius + glow_index * 8.0, Color("ff315f", 0.025 * glow_index))
	draw_colored_polygon(points, Color("2a0a24"))
	draw_polyline(points + PackedVector2Array([points[0]]), Color("ff315f", 0.95), 4.0, true)
	draw_line(Vector2(-radius * 0.45, 0.0), Vector2(radius * 0.45, 0.0), Color("ff8aa2", 0.75), 3.0, true)
	draw_line(Vector2(0.0, -radius * 0.45), Vector2(0.0, radius * 0.45), Color("ff8aa2", 0.75), 3.0, true)

