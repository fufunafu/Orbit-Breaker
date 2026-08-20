class_name OrbitGame
extends Node

signal run_started
signal landed
signal perfect_landed
signal score_changed(score: int, combo: int)
signal run_ended(final_score: int)

enum GameState {
	READY,
	ORBITING,
	IN_FLIGHT,
	GAME_OVER,
}

const PLANET_SCENE := preload("res://scenes/planet.tscn")
const HAZARD_SCENE := preload("res://scenes/hazard.tscn")

@export var tuning: GameTuning

@onready var world: Node2D = $World
@onready var planets: Node2D = $World/Planets
@onready var hazards: Node2D = $World/Hazards
@onready var ship: OrbitShip = $World/Ship
@onready var effects: OrbitEffects = $World/Effects
@onready var aim_guide: Node2D = $World/AimGuide
@onready var camera: Camera2D = $World/Camera2D
@onready var starfield: OrbitStarfield = $Background/Starfield
@onready var hud: OrbitHUD = $Interface/HUD
@onready var audio_controller: OrbitAudioController = $AudioController

var state: GameState = GameState.READY
var current_planet: OrbitPlanet
var target_planet: OrbitPlanet
var score: int = 0
var combo: int = 1
var best_score: int = 0
var landings: int = 0
var flight_time: float = 0.0
var launch_predicted_perfect: bool = false
var camera_target_y: float = 960.0
var shake_time: float = 0.0
var shake_strength: float = 0.0
var paused_by_os: bool = false
var input_locked_until_msec: int = 0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if tuning == null:
		tuning = preload("res://resources/game_tuning.tres")
	rng.randomize()
	best_score = SaveStore.load_best_score()
	ship.radius = tuning.ship_radius
	_reset_world(false)


func _unhandled_input(event: InputEvent) -> void:
	if paused_by_os:
		return
	if event.is_action_pressed("launch"):
		_handle_primary_action()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch and event.pressed:
		_handle_primary_action()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_primary_action()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if paused_by_os:
		return
	match state:
		GameState.READY:
			ship.update_orbit(delta, tuning.base_orbit_speed * 0.72)
		GameState.ORBITING:
			ship.update_orbit(delta, GameRules.orbit_speed(landings, tuning))
			_update_aim_guide()
		GameState.IN_FLIGHT:
			_update_flight(delta)
	_update_camera(delta)


func _handle_primary_action() -> void:
	var now_msec := Time.get_ticks_msec()
	if now_msec < input_locked_until_msec:
		return
	match state:
		GameState.READY:
			if start_run():
				input_locked_until_msec = now_msec + 350
		GameState.ORBITING:
			_launch_ship()
		GameState.IN_FLIGHT:
			pass
		GameState.GAME_OVER:
			_reset_world(true)
			input_locked_until_msec = now_msec + 350


func start_run() -> bool:
	if state != GameState.READY:
		return false
	state = GameState.ORBITING
	hud.show_running(true)
	_update_aim_guide()
	run_started.emit()
	return true


func _launch_ship() -> void:
	if state != GameState.ORBITING or target_planet == null:
		return
	var launch_origin := ship.global_position
	var launch_direction := ship.launch(tuning.launch_speed)
	var miss_distance := OrbitMath.ray_miss_distance(
		launch_origin,
		launch_direction,
		target_planet.global_position
	)
	launch_predicted_perfect = (
		OrbitMath.target_is_in_front(launch_origin, launch_direction, target_planet.global_position)
		and miss_distance <= target_planet.radius * tuning.perfect_zone_ratio
	)
	flight_time = 0.0
	state = GameState.IN_FLIGHT
	aim_guide.hide_guide()
	hud.set_tutorial_visible(false)
	audio_controller.play(OrbitAudioController.Sound.LAUNCH)
	_vibrate(24, 0.25)


func _update_flight(delta: float) -> void:
	flight_time += delta
	var previous_position := ship.global_position
	ship.update_flight(delta)
	var flight_end := ship.global_position
	var closest_hit_fraction := OrbitMath.segment_circle_hit_fraction(
		previous_position,
		flight_end,
		target_planet.global_position,
		target_planet.radius + ship.radius
	)
	var hit_target := closest_hit_fraction >= 0.0

	for hazard_node in hazards.get_children():
		var hazard := hazard_node as OrbitHazard
		if hazard == null:
			continue
		var hit_fraction := OrbitMath.segment_circle_hit_fraction(
			previous_position,
			flight_end,
			hazard.global_position,
			hazard.radius + ship.radius
		)
		if hit_fraction >= 0.0 and (closest_hit_fraction < 0.0 or hit_fraction < closest_hit_fraction):
			closest_hit_fraction = hit_fraction
			hit_target = false

	for planet_node in planets.get_children():
		var planet := planet_node as OrbitPlanet
		if planet == null or planet == target_planet or planet == current_planet:
			continue
		var hit_fraction := OrbitMath.segment_circle_hit_fraction(
			previous_position,
			flight_end,
			planet.global_position,
			planet.radius + ship.radius
		)
		if hit_fraction >= 0.0 and (closest_hit_fraction < 0.0 or hit_fraction < closest_hit_fraction):
			closest_hit_fraction = hit_fraction
			hit_target = false

	if closest_hit_fraction >= 0.0:
		ship.global_position = previous_position.lerp(flight_end, closest_hit_fraction)
		if hit_target:
			_complete_landing(launch_predicted_perfect)
		else:
			end_run("collision")
		return

	var camera_bottom := camera.global_position.y + 1100.0
	var camera_top := camera.global_position.y - 1120.0
	if (
		flight_time >= tuning.flight_timeout
		or ship.global_position.x < -180.0
		or ship.global_position.x > 1260.0
		or ship.global_position.y < camera_top
		or ship.global_position.y > camera_bottom
	):
		end_run("miss")


func _complete_landing(perfect: bool) -> void:
	if state != GameState.IN_FLIGHT:
		return
	var incoming_velocity := ship.velocity
	var contact_radial := ship.global_position - target_planet.global_position
	var next_direction := OrbitMath.direction_from_velocity(contact_radial, incoming_velocity)
	var contact_angle := contact_radial.angle()

	current_planet.set_role(false, false)
	current_planet = target_planet
	current_planet.set_role(false, true)
	landings += 1

	var result := GameRules.landing_result(combo, perfect)
	combo = int(result.combo)
	score += int(result.points)
	if score > best_score:
		best_score = score
		SaveStore.save_best_score(best_score)

	ship.attach_to_planet(
		current_planet.global_position,
		current_planet.radius + tuning.orbit_clearance,
		contact_angle,
		next_direction
	)
	state = GameState.ORBITING
	target_planet = _spawn_target_from(current_planet)
	_spawn_hazard_for_segment(current_planet, target_planet)
	camera_target_y = current_planet.global_position.y - tuning.camera_vertical_lead
	hud.set_tutorial_visible(landings < 3)
	_update_aim_guide()

	if perfect:
		perfect_landed.emit()
		effects.burst(current_planet.global_position, Color("ff64dc"), tuning.particle_count_perfect, 390.0)
		audio_controller.play(OrbitAudioController.Sound.PERFECT)
		hud.flash(Color("ff62dc"), 0.34)
		_vibrate(68, 0.78)
		_start_shake(tuning.screen_shake_strength)
	else:
		landed.emit()
		effects.burst(current_planet.global_position, Color("71faff"), tuning.particle_count_landing, 285.0)
		audio_controller.play(OrbitAudioController.Sound.LAND)
		hud.flash(Color("6df8ff"), 0.18)
		_vibrate(38, 0.42)
		_start_shake(tuning.screen_shake_strength * 0.5)

	score_changed.emit(score, combo)
	hud.set_score(score, combo, best_score)
	_cleanup_world()


func end_run(_reason: String = "miss") -> bool:
	if state != GameState.ORBITING and state != GameState.IN_FLIGHT:
		return false
	state = GameState.GAME_OVER
	aim_guide.hide_guide()
	if score > best_score:
		best_score = score
		SaveStore.save_best_score(best_score)
	effects.burst(ship.global_position, Color("ff315f"), 48, 430.0)
	audio_controller.play(OrbitAudioController.Sound.FAIL)
	hud.flash(Color("ff315f"), 0.38)
	hud.show_game_over(score, best_score)
	_vibrate(160, 1.0)
	_start_shake(tuning.screen_shake_strength * 1.35)
	run_ended.emit(score)
	return true


func _reset_world(begin_running: bool) -> void:
	for child in planets.get_children():
		child.queue_free()
	for child in hazards.get_children():
		child.queue_free()

	score = 0
	combo = 1
	landings = 0
	flight_time = 0.0
	launch_predicted_perfect = false
	var start_position := Vector2(540.0, 1370.0)
	current_planet = _create_planet(start_position, 118.0, false, true)
	target_planet = _spawn_target_from(current_planet)
	ship.attach_to_planet(
		current_planet.global_position,
		current_planet.radius + tuning.orbit_clearance,
		-0.35,
		1
	)
	camera_target_y = current_planet.global_position.y - tuning.camera_vertical_lead
	camera.global_position = Vector2(540.0, camera_target_y)
	camera.offset = Vector2.ZERO
	starfield.set_camera_y(camera.global_position.y)
	hud.set_score(score, combo, best_score)
	if begin_running:
		state = GameState.ORBITING
		hud.show_running(true)
		_update_aim_guide()
		run_started.emit()
	else:
		state = GameState.READY
		hud.show_ready(best_score)
		aim_guide.hide_guide()


func _update_aim_guide() -> void:
	if state != GameState.ORBITING or target_planet == null:
		aim_guide.hide_guide()
		return
	aim_guide.configure(
		ship.global_position,
		OrbitMath.tangent_for_angle(ship.orbit_angle, ship.orbit_direction),
		target_planet.global_position,
		target_planet.radius,
		ship.radius,
		tuning.perfect_zone_ratio,
		landings < 3
	)


func _create_planet(position_value: Vector2, radius_value: float, target: bool, current: bool) -> OrbitPlanet:
	var planet := PLANET_SCENE.instantiate() as OrbitPlanet
	planets.add_child(planet)
	planet.global_position = position_value
	planet.configure(radius_value, target, current, tuning.perfect_zone_ratio)
	return planet


func _spawn_target_from(source: OrbitPlanet) -> OrbitPlanet:
	var radius_range := GameRules.planet_radius_range(landings, tuning)
	var vertical_gap_range := GameRules.vertical_gap_range(landings, tuning)
	var source_orbit_radius := source.radius + tuning.orbit_clearance
	var selected_position := source.global_position + Vector2(0.0, -tuning.minimum_vertical_gap)
	var selected_radius := radius_range.x
	var found_layout := false

	for attempt in 48:
		selected_radius = rng.randf_range(radius_range.x, radius_range.y)
		var vertical_gap := rng.randf_range(vertical_gap_range.x, vertical_gap_range.y)
		var horizontal_shift := rng.randf_range(-tuning.maximum_horizontal_shift, tuning.maximum_horizontal_shift)
		var minimum_x := 118.0 + selected_radius
		var maximum_x := 962.0 - selected_radius
		selected_position = Vector2(
			clampf(source.global_position.x + horizontal_shift, minimum_x, maximum_x),
			source.global_position.y - vertical_gap
		)
		if OrbitMath.layout_is_reachable(
			source.global_position,
			source_orbit_radius,
			selected_position,
			selected_radius,
			tuning.minimum_planet_separation,
			tuning.maximum_target_distance
		):
			found_layout = true
			break

	if not found_layout:
		selected_radius = radius_range.x
		selected_position = source.global_position + Vector2(0.0, -vertical_gap_range.x)
	return _create_planet(selected_position, selected_radius, true, false)


func _spawn_hazard_for_segment(source: OrbitPlanet, target: OrbitPlanet) -> void:
	var chance := GameRules.hazard_chance(landings, tuning)
	if chance <= 0.0 or rng.randf() > chance:
		return
	var segment := target.global_position - source.global_position
	var perpendicular := segment.normalized().orthogonal()
	var side := -1.0 if rng.randf() < 0.5 else 1.0
	var position_on_segment := source.global_position.lerp(target.global_position, rng.randf_range(0.42, 0.7))
	var hazard_position := position_on_segment + perpendicular * side * rng.randf_range(105.0, 185.0)
	hazard_position.x = clampf(hazard_position.x, 95.0, 985.0)
	var hazard := HAZARD_SCENE.instantiate() as OrbitHazard
	hazards.add_child(hazard)
	hazard.global_position = hazard_position
	hazard.configure(
		rng.randf_range(tuning.minimum_hazard_radius, tuning.maximum_hazard_radius),
		rng.randi()
	)


func _update_camera(delta: float) -> void:
	var desired_position := Vector2(540.0, camera_target_y)
	var smoothing := 1.0 - exp(-tuning.camera_follow_speed * delta)
	camera.global_position = camera.global_position.lerp(desired_position, smoothing)
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
		var ratio := shake_time / 0.28
		camera.offset = Vector2(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0)
		) * shake_strength * ratio
	else:
		camera.offset = camera.offset.lerp(Vector2.ZERO, 1.0 - exp(-18.0 * delta))
	starfield.set_camera_y(camera.global_position.y)


func _start_shake(strength: float) -> void:
	shake_time = 0.28
	shake_strength = strength


func _cleanup_world() -> void:
	var cutoff_y := camera.global_position.y + 1250.0
	for planet_node in planets.get_children():
		if planet_node == current_planet or planet_node == target_planet:
			continue
		if planet_node.global_position.y > cutoff_y:
			planet_node.queue_free()
	for hazard_node in hazards.get_children():
		if hazard_node.global_position.y > cutoff_y:
			hazard_node.queue_free()


func _vibrate(duration_ms: int, amplitude: float) -> void:
	if OS.get_name() == "iOS" or OS.get_name() == "Android":
		Input.vibrate_handheld(duration_ms, amplitude)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		paused_by_os = true
		get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		get_tree().paused = false
		paused_by_os = false
