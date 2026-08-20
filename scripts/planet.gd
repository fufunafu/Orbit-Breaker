class_name OrbitPlanet
extends Node2D

@export var radius: float = 100.0:
	set(value):
		radius = value
		queue_redraw()

var is_current: bool = false
var is_target: bool = false
var perfect_zone_ratio: float = 0.42
var pulse_time: float = 0.0
var hue_seed: float = 0.0
var zone_index: int = 0


func configure(new_radius: float, target: bool, current: bool, perfect_ratio: float) -> void:
	radius = new_radius
	is_target = target
	is_current = current
	perfect_zone_ratio = perfect_ratio
	hue_seed = fposmod(global_position.x * 0.0007 + global_position.y * 0.0003, 1.0)
	queue_redraw()


func set_role(target: bool, current: bool) -> void:
	is_target = target
	is_current = current
	queue_redraw()


func set_zone(value: int) -> void:
	zone_index = clampi(value, 0, 2)
	queue_redraw()


func _process(delta: float) -> void:
	pulse_time += delta
	if is_target or is_current:
		queue_redraw()


func _draw() -> void:
	var zone_hues := [0.52, 0.83, 0.10]
	var base_color := Color.from_hsv(fposmod(float(zone_hues[zone_index]) + hue_seed * 0.10, 1.0), 0.72, 0.88)
	if is_target:
		base_color = [Color("7cf8ff"), Color("ff78e8"), Color("ffd166")][zone_index]
	elif is_current:
		base_color = [Color("735cff"), Color("9a4dff"), Color("ff7b32")][zone_index]

	for ring_index in range(5, 0, -1):
		var ring_radius := radius + float(ring_index) * 12.0
		var ring_alpha := 0.018 + float(6 - ring_index) * 0.008
		draw_circle(Vector2.ZERO, ring_radius, Color(base_color, ring_alpha))

	draw_circle(Vector2.ZERO, radius, Color("08152f"))
	draw_circle(Vector2.ZERO, radius * 0.92, Color(base_color, 0.18))
	draw_circle(Vector2(-radius * 0.2, -radius * 0.24), radius * 0.64, Color(base_color.lightened(0.15), 0.18))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(base_color, 0.95), 4.0, true)
	draw_arc(Vector2.ZERO, radius * 0.76, -2.35, 0.35, 48, Color(base_color.lightened(0.35), 0.55), 3.0, true)

	if is_target:
		var pulse := 1.0 + sin(pulse_time * 4.5) * 0.045
		var perfect_radius := radius * perfect_zone_ratio
		draw_circle(Vector2.ZERO, perfect_radius * pulse, Color("ff4fd8", 0.13))
		draw_arc(Vector2.ZERO, perfect_radius * pulse, 0.0, TAU, 64, Color("ff74df", 0.9), 3.0, true)
		draw_arc(Vector2.ZERO, radius + 20.0 + sin(pulse_time * 4.0) * 7.0, 0.0, TAU, 80, Color("8efbff", 0.42), 3.0, true)
