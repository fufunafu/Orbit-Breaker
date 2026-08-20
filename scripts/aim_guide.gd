class_name OrbitAimGuide
extends Node2D

var active: bool = false
var origin: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var target: Vector2 = Vector2.ZERO
var target_radius: float = 80.0
var ship_radius: float = 18.0
var perfect_ratio: float = 0.42
var pulse_time: float = 0.0


func configure(
	new_origin: Vector2,
	new_direction: Vector2,
	new_target: Vector2,
	new_target_radius: float,
	new_ship_radius: float,
	new_perfect_ratio: float,
	new_active: bool
) -> void:
	origin = new_origin
	direction = new_direction.normalized()
	target = new_target
	target_radius = new_target_radius
	ship_radius = new_ship_radius
	perfect_ratio = new_perfect_ratio
	active = new_active
	queue_redraw()


func hide_guide() -> void:
	active = false
	queue_redraw()


func _process(delta: float) -> void:
	pulse_time += delta
	if active:
		queue_redraw()


func _draw() -> void:
	if not active:
		return
	var target_ahead := OrbitMath.target_is_in_front(origin, direction, target)
	var miss_distance := OrbitMath.ray_miss_distance(origin, direction, target)
	var will_land := target_ahead and miss_distance <= target_radius + ship_radius
	var will_be_perfect := target_ahead and miss_distance <= target_radius * perfect_ratio
	var guide_color := Color("63738e", 0.28)
	if will_be_perfect:
		guide_color = Color("ff67dc", 0.9)
	elif will_land:
		guide_color = Color("72faff", 0.85)

	var distance_to_target := origin.distance_to(target)
	var line_length := clampf(distance_to_target + target_radius, 420.0, 820.0)
	var dash_length := 25.0
	var gap_length := 17.0
	var cursor := 34.0
	while cursor < line_length:
		var segment_end := minf(line_length, cursor + dash_length)
		draw_line(
			origin + direction * cursor,
			origin + direction * segment_end,
			guide_color,
			5.0,
			true
		)
		cursor += dash_length + gap_length

	if will_land:
		var ring_radius := target_radius + 25.0 + sin(pulse_time * 5.0) * 7.0
		draw_arc(target, ring_radius, 0.0, TAU, 72, guide_color, 5.0, true)
