class_name OrbitHazard
extends Node2D

enum Kind { ASTEROID, PULSE_MINE }

@export var radius: float = 32.0
var spin: float = 0.0
var points: PackedVector2Array = PackedVector2Array()
var kind: Kind = Kind.ASTEROID
var pulse_time: float = 0.0


func configure(new_radius: float, seed_value: int, new_kind: Kind = Kind.ASTEROID) -> void:
	radius = new_radius
	kind = new_kind
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
	pulse_time += delta
	rotation = spin
	queue_redraw()


func collision_radius() -> float:
	if kind == Kind.PULSE_MINE:
		return radius * (1.0 + sin(pulse_time * 3.4) * 0.12)
	return radius


func _draw() -> void:
	if points.is_empty():
		configure(radius, 1, kind)
	if kind == Kind.PULSE_MINE:
		_draw_pulse_mine()
		return
	for glow_index in range(4, 0, -1):
		draw_circle(Vector2.ZERO, radius + glow_index * 8.0, Color("ff315f", 0.025 * glow_index))
	draw_colored_polygon(points, Color("2a0a24"))
	draw_polyline(points + PackedVector2Array([points[0]]), Color("ff315f", 0.95), 4.0, true)
	draw_line(Vector2(-radius * 0.45, 0.0), Vector2(radius * 0.45, 0.0), Color("ff8aa2", 0.75), 3.0, true)
	draw_line(Vector2(0.0, -radius * 0.45), Vector2(0.0, radius * 0.45), Color("ff8aa2", 0.75), 3.0, true)


func _draw_pulse_mine() -> void:
	var pulse_radius := collision_radius()
	for ring_index in range(5, 0, -1):
		draw_circle(Vector2.ZERO, pulse_radius + ring_index * 9.0, Color("b86bff", 0.018 * ring_index))
	draw_circle(Vector2.ZERO, radius * 0.72, Color("190b32"))
	draw_arc(Vector2.ZERO, pulse_radius, 0.0, TAU, 64, Color("c77dff"), 4.0, true)
	for index in 8:
		var angle := TAU * float(index) / 8.0
		var inner := Vector2.from_angle(angle) * radius * 0.65
		var outer := Vector2.from_angle(angle) * radius * 1.18
		draw_line(inner, outer, Color("f0a6ff"), 4.0, true)
	draw_circle(Vector2.ZERO, radius * 0.22, Color("fff0ff"))
