extends SceneTree

const SCREENSHOT_DIR := "res://marketing/screenshots"
const CAPTURE_SAVE := "res://.godot/orbit_breaker_marketing_capture.cfg"
const CAPTURE_METRICS := "res://.godot/orbit_breaker_marketing_capture.json"
const CAPTURE_SIZE := Vector2i(1320, 2868)

var capture_failures: int = 0


func _init() -> void:
	call_deferred("_capture_all")


func _capture_all() -> void:
	root.size = CAPTURE_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(CAPTURE_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(CAPTURE_METRICS))
	var capture_profile := SaveStore.default_profile()
	capture_profile.best_score = 40
	capture_profile.total_landings = 19
	capture_profile.highest_combo = 5
	SaveStore.save_profile(capture_profile, CAPTURE_SAVE)
	var packed := load("res://scenes/game.tscn") as PackedScene
	var game := packed.instantiate()
	game.save_path = CAPTURE_SAVE
	game.metrics_path = CAPTURE_METRICS
	(game.get_node("GameCenter") as OrbitGameCenter).enabled = false
	root.add_child(game)
	await process_frame
	game.layout_rng.seed = 20260820
	game.feedback_rng.seed = 20260820
	game._reset_world(false)
	game.set_physics_process(false)
	await process_frame
	game.audio_controller.apply_settings(false, false)
	await _capture("01-home.png")

	game.start_run(false)
	_align_ship_for_perfect_guide(game)
	await process_frame
	await _capture("02-perfect-launch.png")

	game.score = 16
	game.combo = 5
	game.landings = 16
	game.perfect_landings = 8
	game.run_highest_combo = 5
	game.hud.set_score(game.score, game.combo, game.best_score)
	game.hud.set_tutorial_visible(false)
	game._update_zone()
	var asteroid := game.HAZARD_SCENE.instantiate() as OrbitHazard
	game.hazards.add_child(asteroid)
	asteroid.global_position = game.current_planet.global_position + Vector2(250.0, -250.0)
	asteroid.configure(38.0, 88, OrbitHazard.Kind.ASTEROID)
	var mine := game.HAZARD_SCENE.instantiate() as OrbitHazard
	game.hazards.add_child(mine)
	mine.global_position = game.current_planet.global_position + Vector2(-260.0, -350.0)
	mine.configure(36.0, 99, OrbitHazard.Kind.PULSE_MINE)
	await process_frame
	await _capture("03-nova-hazards.png")

	game.score = 42
	game.landings = 31
	game.perfect_landings = 12
	game.run_highest_combo = 5
	game.best_score = maxi(game.best_score, game.score)
	game.hud.set_score(game.score, game.combo, game.best_score)
	game.end_run("pulse_mine")
	await process_frame
	await _capture("04-score-card.png")

	var icon_texture := load("res://icon.svg") as Texture2D
	if icon_texture:
		var icon_image := icon_texture.get_image()
		icon_image.resize(1024, 1024, Image.INTERPOLATE_LANCZOS)
		icon_image.convert(Image.FORMAT_RGB8)
		icon_image.save_png("res://marketing/app-icon-1024.png")

	game.queue_free()
	await process_frame
	await process_frame
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(CAPTURE_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(CAPTURE_METRICS))
	if capture_failures > 0:
		print("ORBIT_BREAKER_MARKETING_CAPTURE_FAILED: %d" % capture_failures)
		quit(1)
		return
	print("ORBIT_BREAKER_MARKETING_CAPTURE_OK")
	quit(0)


func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	var captured := Vector2i(image.get_width(), image.get_height())
	if captured != CAPTURE_SIZE:
		# The display clamped the window. Resizing a different aspect ratio would
		# produce a distorted, non-native screenshot, so refuse instead.
		push_error("Captured %s at %s, expected %s. Use a display that allows the full capture size." % [filename, captured, CAPTURE_SIZE])
		capture_failures += 1
		return
	image.convert(Image.FORMAT_RGB8)
	var result := image.save_png("%s/%s" % [SCREENSHOT_DIR, filename])
	if result != OK:
		push_error("Unable to save marketing screenshot %s" % filename)
		capture_failures += 1


func _align_ship_for_perfect_guide(game: OrbitGame) -> void:
	var best_angle := game.ship.orbit_angle
	var best_miss := INF
	for index in 1440:
		var angle := TAU * float(index) / 1440.0
		var origin := OrbitMath.orbit_position(game.ship.orbit_center, game.ship.orbit_radius, angle)
		var direction := OrbitMath.tangent_for_angle(angle, game.ship.orbit_direction)
		if not OrbitMath.target_is_in_front(origin, direction, game.target_planet.global_position):
			continue
		var miss := OrbitMath.ray_miss_distance(origin, direction, game.target_planet.global_position)
		if miss < best_miss:
			best_miss = miss
			best_angle = angle
	game.ship.orbit_angle = best_angle
	game.ship.update_orbit(0.0, 0.0)
	game._update_aim_guide()
