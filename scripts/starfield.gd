class_name OrbitStarfield
extends Control

const STAR_COUNT := 150

var camera_y: float = 0.0
var stars: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = 90210
	for index in STAR_COUNT:
		stars.append({
			"x": local_rng.randf(),
			"y": local_rng.randf(),
			"size": local_rng.randf_range(1.2, 4.2),
			"speed": local_rng.randf_range(0.08, 0.28),
			"brightness": local_rng.randf_range(0.3, 0.9),
		})
	queue_redraw()


func set_camera_y(value: float) -> void:
	camera_y = value
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("030615"))
	for star in stars:
		var x := float(star.x) * size.x
		var scroll_range := size.y + 80.0
		var y := fposmod(float(star.y) * scroll_range - camera_y * float(star.speed), scroll_range) - 40.0
		var brightness := float(star.brightness)
		var star_color := Color(0.62, 0.87, 1.0, brightness)
		draw_circle(Vector2(x, y), float(star.size), star_color)

	var center := Vector2(size.x * 0.16, size.y * 0.25)
	var glow_color := Color("5a2bbd", 0.035)
	for ring in range(7, 0, -1):
		draw_circle(center, 65.0 * ring, Color(glow_color, glow_color.a * float(8 - ring)))


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

