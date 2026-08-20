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
const PRIVACY_URL := "https://fufunafu.github.io/Orbit-Breaker/privacy.html"
const SUPPORT_URL := "https://fufunafu.github.io/Orbit-Breaker/support.html"

@export var tuning: GameTuning
@export var save_path: String = SaveStore.DEFAULT_PATH
@export var metrics_path: String = PlaytestMetrics.DEFAULT_PATH

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
@onready var game_center: OrbitGameCenter = $GameCenter

var state: GameState = GameState.READY
var current_planet: OrbitPlanet
var target_planet: OrbitPlanet
var score: int = 0
var combo: int = 1
var best_score: int = 0
var landings: int = 0
var perfect_landings: int = 0
var run_highest_combo: int = 1
var flight_time: float = 0.0
var launch_predicted_perfect: bool = false
var camera_target_y: float = 960.0
var shake_time: float = 0.0
var shake_strength: float = 0.0
var paused_by_os: bool = false
var manually_paused: bool = false
var input_locked_until_msec: int = 0
var profile: Dictionary
var is_daily_run: bool = false
var daily_date: String = ""
var zone_index: int = 0
var layout_rng := RandomNumberGenerator.new()
var feedback_rng := RandomNumberGenerator.new()
var run_started_msec: int = 0
var launch_count: int = 0
var first_launch_succeeded: bool = false
var marketing_demo: bool = false
var marketing_demo_elapsed: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	marketing_demo = OS.get_cmdline_user_args().has("--marketing-preview")
	if marketing_demo:
		save_path = "user://orbit_breaker_marketing_save.cfg"
		metrics_path = "user://orbit_breaker_marketing_metrics.json"
	if tuning == null:
		tuning = preload("res://resources/game_tuning.tres")
	layout_rng.randomize()
	feedback_rng.randomize()
	profile = SaveStore.load_profile(save_path)
	CosmeticCatalog.refresh_unlocks(profile)
	best_score = int(profile.best_score)
	daily_date = DailyChallenge.utc_date_key()
	ship.radius = tuning.ship_radius
	_connect_hud()
	_apply_profile()
	_reset_world(false)
	if marketing_demo:
		profile.guide_mode = 2
		call_deferred("start_run", false)


func _connect_hud() -> void:
	hud.classic_requested.connect(func() -> void: start_run(false))
	hud.daily_requested.connect(func() -> void: start_run(true))
	hud.replay_requested.connect(_replay_current_mode)
	hud.share_requested.connect(_on_share_requested)
	hud.pause_requested.connect(_pause_run)
	hud.resume_requested.connect(_resume_run)
	hud.restart_requested.connect(_restart_from_pause)
	hud.leaderboards_requested.connect(game_center.show_leaderboards)
	hud.setting_changed.connect(_on_setting_changed)
	hud.cosmetic_cycle_requested.connect(_on_cosmetic_cycle_requested)
	hud.export_metrics_requested.connect(_on_export_metrics_requested)
	hud.privacy_requested.connect(func() -> void: _open_external_url(PRIVACY_URL))
	hud.support_requested.connect(func() -> void: _open_external_url(SUPPORT_URL))


func _unhandled_input(event: InputEvent) -> void:
	if paused_by_os or manually_paused or hud.settings_panel.visible:
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
	if paused_by_os or manually_paused:
		return
	if marketing_demo:
		_update_marketing_demo(delta)
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
			if start_run(false):
				input_locked_until_msec = now_msec + 350
		GameState.ORBITING:
			_launch_ship()
		GameState.IN_FLIGHT:
			pass
		GameState.GAME_OVER:
			_replay_current_mode()
			input_locked_until_msec = now_msec + 350


func start_run(daily: bool = false) -> bool:
	if state != GameState.READY:
		return false
	is_daily_run = daily
	_seed_layout_rng()
	if daily:
		_reset_world(true)
	else:
		run_started_msec = Time.get_ticks_msec()
		state = GameState.ORBITING
		hud.show_running(_tutorial_should_show(), false, daily_date)
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
	launch_count += 1
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
	var end_run_reason := "wrong_planet"

	for hazard_node in hazards.get_children():
		var hazard := hazard_node as OrbitHazard
		if hazard == null:
			continue
		var hit_fraction := OrbitMath.segment_circle_hit_fraction(
			previous_position,
			flight_end,
			hazard.global_position,
			hazard.collision_radius() + ship.radius
		)
		if hit_fraction >= 0.0 and (closest_hit_fraction < 0.0 or hit_fraction < closest_hit_fraction):
			closest_hit_fraction = hit_fraction
			hit_target = false
			end_run_reason = "wrong_planet"
			if hazard.kind == OrbitHazard.Kind.PULSE_MINE:
				end_run_reason = "pulse_mine"
			else:
				end_run_reason = "asteroid"

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
			end_run_reason = "wrong_planet"

	if closest_hit_fraction >= 0.0:
		ship.global_position = previous_position.lerp(flight_end, closest_hit_fraction)
		if hit_target:
			_complete_landing(launch_predicted_perfect)
		else:
			end_run(end_run_reason)
		return

	var camera_bottom := camera.global_position.y + 1100.0
	var camera_top := camera.global_position.y - 1120.0
	if flight_time >= tuning.flight_timeout:
		end_run("timeout")
		return
	if (
		ship.global_position.x < -180.0
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
	if launch_count == 1:
		first_launch_succeeded = true
	if perfect:
		perfect_landings += 1

	var result := GameRules.landing_result(combo, perfect)
	combo = int(result.combo)
	run_highest_combo = maxi(run_highest_combo, combo)
	score += int(result.points)
	best_score = maxi(best_score, score)

	ship.attach_to_planet(
		current_planet.global_position,
		current_planet.radius + tuning.orbit_clearance,
		contact_angle,
		next_direction
	)
	state = GameState.ORBITING
	_update_zone()
	target_planet = _spawn_target_from(current_planet)
	_spawn_hazard_for_segment(current_planet, target_planet)
	camera_target_y = current_planet.global_position.y - tuning.camera_vertical_lead
	if landings >= 3 and not bool(profile.tutorial_completed):
		profile.tutorial_completed = true
		SaveStore.save_profile(profile, save_path)
	hud.set_tutorial_visible(_tutorial_should_show())
	_update_aim_guide()
	audio_controller.set_intensity(combo, zone_index)
	if landings == tuning.hazards_begin_at_landing:
		hud.show_tip("ASTEROIDS BLOCK SOME WINDOWS. WAIT FOR A CLEAR LINE.")
	elif landings == tuning.pulse_hazards_begin_at_landing:
		hud.show_tip("PULSE MINES EXPAND AND CONTRACT. WATCH THEIR RHYTHM.")

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


func end_run(reason: String = "miss") -> bool:
	if state != GameState.ORBITING and state != GameState.IN_FLIGHT:
		return false
	state = GameState.GAME_OVER
	aim_guide.hide_guide()
	var run_result := SaveStore.record_run(profile, score, landings, perfect_landings, run_highest_combo, is_daily_run, daily_date)
	profile = run_result.profile
	var new_unlocks := CosmeticCatalog.refresh_unlocks(profile)
	best_score = int(profile.best_score)
	SaveStore.save_profile(profile, save_path)
	var run_seconds := float(Time.get_ticks_msec() - run_started_msec) / 1000.0 if run_started_msec > 0 else 0.0
	PlaytestMetrics.record_run(score, landings, run_seconds, reason, first_launch_succeeded, metrics_path)
	game_center.submit_run(score, is_daily_run)
	game_center.submit_achievement_progress(profile)
	effects.burst(ship.global_position, Color("ff315f"), 48, 430.0)
	audio_controller.play(OrbitAudioController.Sound.FAIL)
	hud.flash(Color("ff315f"), 0.38)
	hud.show_game_over({
		"score": score,
		"best_score": best_score,
		"landings": landings,
		"perfect_landings": perfect_landings,
		"highest_combo": run_highest_combo,
		"failure_reason": _failure_reason_text(reason),
		"new_best": bool(run_result.new_best),
		"new_unlocks": new_unlocks,
	})
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
	perfect_landings = 0
	run_highest_combo = 1
	launch_count = 0
	first_launch_succeeded = false
	run_started_msec = 0
	flight_time = 0.0
	launch_predicted_perfect = false
	manually_paused = false
	world.process_mode = Node.PROCESS_MODE_INHERIT
	audio_controller.set_music_paused(false)
	zone_index = _selected_theme_zone()
	_apply_zone()
	audio_controller.set_intensity(combo, zone_index)
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
		run_started_msec = Time.get_ticks_msec()
		state = GameState.ORBITING
		hud.show_running(_tutorial_should_show(), is_daily_run, daily_date)
		_update_aim_guide()
		run_started.emit()
	else:
		state = GameState.READY
		_refresh_ready_screen()
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
		_guide_should_show()
	)


func _create_planet(position_value: Vector2, radius_value: float, target: bool, current: bool) -> OrbitPlanet:
	var planet := PLANET_SCENE.instantiate() as OrbitPlanet
	planets.add_child(planet)
	planet.global_position = position_value
	planet.configure(radius_value, target, current, tuning.perfect_zone_ratio)
	planet.set_zone(zone_index)
	return planet


func _spawn_target_from(source: OrbitPlanet) -> OrbitPlanet:
	var radius_range := GameRules.planet_radius_range(landings, tuning)
	var vertical_gap_range := GameRules.vertical_gap_range(landings, tuning)
	var source_orbit_radius := source.radius + tuning.orbit_clearance
	var selected_position := source.global_position + Vector2(0.0, -tuning.minimum_vertical_gap)
	var selected_radius := radius_range.x
	var found_layout := false

	for attempt in 48:
		selected_radius = layout_rng.randf_range(radius_range.x, radius_range.y)
		var vertical_gap := layout_rng.randf_range(vertical_gap_range.x, vertical_gap_range.y)
		var horizontal_shift := layout_rng.randf_range(-tuning.maximum_horizontal_shift, tuning.maximum_horizontal_shift)
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
	if chance <= 0.0 or layout_rng.randf() > chance:
		return
	var count := 2 if landings >= tuning.combined_hazards_begin_at_landing and layout_rng.randf() < 0.45 else 1
	var accepted: Array[Dictionary] = []
	for hazard_index in count:
		for attempt in 32:
			var segment := target.global_position - source.global_position
			var perpendicular := segment.normalized().orthogonal()
			var side := -1.0 if layout_rng.randf() < 0.5 else 1.0
			var position_on_segment := source.global_position.lerp(target.global_position, layout_rng.randf_range(0.38, 0.74))
			var hazard_position := position_on_segment + perpendicular * side * layout_rng.randf_range(105.0, 210.0)
			hazard_position.x = clampf(hazard_position.x, 95.0, 985.0)
			var radius := layout_rng.randf_range(tuning.minimum_hazard_radius, tuning.maximum_hazard_radius)
			var kind := OrbitHazard.Kind.ASTEROID
			if landings >= tuning.pulse_hazards_begin_at_landing and (hazard_index == 1 or layout_rng.randf() < 0.5):
				kind = OrbitHazard.Kind.PULSE_MINE
			var candidate := {"position": hazard_position, "radius": radius * 1.12, "kind": kind}
			var candidates := accepted.duplicate()
			candidates.append(candidate)
			if _hazards_preserve_launch_window(source, target, candidates):
				accepted.append(candidate)
				break
	for data in accepted:
		var hazard := HAZARD_SCENE.instantiate() as OrbitHazard
		hazards.add_child(hazard)
		hazard.global_position = data.position
		hazard.configure(float(data.radius) / 1.12, layout_rng.randi(), data.kind)


func _hazards_preserve_launch_window(source: OrbitPlanet, target: OrbitPlanet, candidates: Array[Dictionary]) -> bool:
	var blocking_hazards := candidates.duplicate()
	for hazard_node in hazards.get_children():
		var hazard := hazard_node as OrbitHazard
		if hazard:
			blocking_hazards.append({
				"position": hazard.global_position,
				"radius": hazard.radius * 1.12,
			})
	var safe_samples := OrbitMath.safe_launch_sample_count_for_hazards(
		source.global_position,
		source.radius + tuning.orbit_clearance,
		ship.orbit_direction,
		target.global_position,
		target.radius + ship.radius,
		blocking_hazards,
		180
	)
	return safe_samples >= tuning.minimum_safe_launch_samples


func _update_camera(delta: float) -> void:
	var desired_position := Vector2(540.0, camera_target_y)
	var smoothing := 1.0 - exp(-tuning.camera_follow_speed * delta)
	camera.global_position = camera.global_position.lerp(desired_position, smoothing)
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
		var ratio := shake_time / 0.28
		camera.offset = Vector2(
			feedback_rng.randf_range(-1.0, 1.0),
			feedback_rng.randf_range(-1.0, 1.0)
		) * shake_strength * ratio
	else:
		camera.offset = camera.offset.lerp(Vector2.ZERO, 1.0 - exp(-18.0 * delta))
	starfield.set_camera_y(camera.global_position.y)


func _start_shake(strength: float) -> void:
	if bool(profile.reduced_motion) or bool(profile.reduced_screen_shake):
		return
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
	if bool(profile.haptics_enabled) and (OS.get_name() == "iOS" or OS.get_name() == "Android"):
		Input.vibrate_handheld(duration_ms, amplitude)


func _seed_layout_rng() -> void:
	if is_daily_run:
		daily_date = DailyChallenge.utc_date_key()
		layout_rng.seed = DailyChallenge.seed_for_date(daily_date)
	else:
		layout_rng.randomize()


func _tutorial_should_show() -> bool:
	return int(profile.guide_mode) != 0 and not bool(profile.tutorial_completed) and landings < 3


func _guide_should_show() -> bool:
	return int(profile.guide_mode) == 2 or _tutorial_should_show()


func _selected_theme_zone() -> int:
	return int(CosmeticCatalog.find_item(CosmeticCatalog.PLANET_THEMES, String(profile.selected_planet_theme)).zone)


func _update_zone() -> void:
	var stage := 0
	if score >= tuning.sunforge_zone_score:
		stage = 2
	elif score >= tuning.nebula_zone_score:
		stage = 1
	var next_zone := (_selected_theme_zone() + stage) % 3
	if next_zone == zone_index:
		return
	zone_index = next_zone
	_apply_zone()
	var zone_names := ["ION VEIL", "NOVA DRIFT", "SUNFORGE"]
	hud.show_tip("ENTERING %s" % zone_names[zone_index], 1.8)


func _apply_zone() -> void:
	starfield.set_zone(zone_index, bool(profile.reduced_motion))
	for planet_node in planets.get_children():
		var planet := planet_node as OrbitPlanet
		if planet:
			planet.set_zone(zone_index)


func _apply_profile() -> void:
	ship.set_appearance(String(profile.selected_ship_color), String(profile.selected_trail))
	aim_guide.set_high_contrast(bool(profile.high_contrast))
	effects.reduced_motion = bool(profile.reduced_motion)
	audio_controller.apply_settings(bool(profile.sound_enabled), bool(profile.music_enabled))
	audio_controller.set_intensity(combo, zone_index)
	hud.update_settings(profile)
	_apply_zone()


func _refresh_ready_screen() -> void:
	daily_date = DailyChallenge.utc_date_key()
	var daily_best := int(profile.daily_best_score) if String(profile.daily_date) == daily_date else 0
	hud.show_ready(best_score, daily_best, daily_date)


func _replay_current_mode() -> void:
	if state != GameState.GAME_OVER:
		return
	profile.restarts = int(profile.restarts) + 1
	PlaytestMetrics.record_restart(metrics_path)
	SaveStore.save_profile(profile, save_path)
	_seed_layout_rng()
	_reset_world(true)


func _pause_run() -> void:
	if state != GameState.ORBITING and state != GameState.IN_FLIGHT:
		return
	manually_paused = true
	world.process_mode = Node.PROCESS_MODE_DISABLED
	audio_controller.set_music_paused(true)
	hud.show_pause()


func _resume_run() -> void:
	if not manually_paused:
		return
	manually_paused = false
	world.process_mode = Node.PROCESS_MODE_INHERIT
	audio_controller.set_music_paused(false)
	hud.hide_pause()


func _restart_from_pause() -> void:
	if not manually_paused:
		return
	manually_paused = false
	profile.restarts = int(profile.restarts) + 1
	PlaytestMetrics.record_restart(metrics_path)
	SaveStore.save_profile(profile, save_path)
	_seed_layout_rng()
	_reset_world(true)


func _on_setting_changed(key: String, value: Variant) -> void:
	if key == "guide_cycle":
		profile.guide_mode = (int(profile.guide_mode) + 1) % 3
	elif profile.has(key):
		profile[key] = value
	SaveStore.save_profile(profile, save_path)
	_apply_profile()
	_update_aim_guide()


func _on_cosmetic_cycle_requested(category: String) -> void:
	match category:
		"ship":
			var item := CosmeticCatalog.next_unlocked(CosmeticCatalog.SHIP_COLORS, profile.unlocked_ship_colors, String(profile.selected_ship_color))
			profile.selected_ship_color = item.id
		"trail":
			var item := CosmeticCatalog.next_unlocked(CosmeticCatalog.TRAILS, profile.unlocked_trails, String(profile.selected_trail))
			profile.selected_trail = item.id
		"theme":
			var item := CosmeticCatalog.next_unlocked(CosmeticCatalog.PLANET_THEMES, profile.unlocked_planet_themes, String(profile.selected_planet_theme))
			profile.selected_planet_theme = item.id
	SaveStore.save_profile(profile, save_path)
	zone_index = _selected_theme_zone()
	_apply_profile()


func _failure_reason_text(reason: String) -> String:
	match reason:
		"asteroid":
			return "STRUCK AN ASTEROID"
		"pulse_mine":
			return "CAUGHT IN A PULSE MINE"
		"wrong_planet":
			return "COLLIDED WITH A DEAD ORBIT"
		"timeout":
			return "SIGNAL TIMED OUT"
		_:
			return "DRIFTED INTO DEEP SPACE"


func _on_share_requested() -> void:
	var path := generate_score_image()
	hud.show_share_status(path if not path.is_empty() else "UNABLE TO SAVE")


func generate_score_image() -> String:
	if DisplayServer.get_name() == "headless":
		return ""
	var image := get_viewport().get_texture().get_image()
	return save_score_image(image)


func save_score_image(image: Image, path_override: String = "") -> String:
	if image == null or image.is_empty():
		return ""
	image.convert(Image.FORMAT_RGB8)
	var path := path_override
	if path.is_empty():
		var timestamp := Time.get_datetime_string_from_system(false, true).replace(":", "-")
		path = "user://orbit-breaker-score-%s.png" % timestamp
	if image.save_png(path) != OK:
		return ""
	return ProjectSettings.globalize_path(path)


func _on_export_metrics_requested() -> void:
	var path := PlaytestMetrics.export_report("user://orbit-breaker-playtest-report.json", metrics_path)
	if path.is_empty():
		hud.show_tip("UNABLE TO SAVE PLAYTEST REPORT", 4.0)
	elif OS.get_name() == "iOS":
		hud.show_tip("PLAYTEST REPORT SAVED\nFILES > ON MY IPHONE > ORBIT BREAKER", 4.0)
	else:
		hud.show_tip("PLAYTEST REPORT SAVED\n%s" % path, 4.0)


func _open_external_url(url: String) -> void:
	var error := OS.shell_open(url)
	if error != OK:
		hud.show_tip("UNABLE TO OPEN LINK", 2.4)


func _update_marketing_demo(delta: float) -> void:
	marketing_demo_elapsed += delta
	if marketing_demo_elapsed >= 24.0 and state != GameState.GAME_OVER:
		end_run("miss")
		return
	if state != GameState.ORBITING or target_planet == null:
		return
	var direction := OrbitMath.tangent_for_angle(ship.orbit_angle, ship.orbit_direction)
	var miss_distance := OrbitMath.ray_miss_distance(ship.global_position, direction, target_planet.global_position)
	if OrbitMath.target_is_in_front(ship.global_position, direction, target_planet.global_position) and miss_distance <= target_planet.radius * tuning.perfect_zone_ratio * 0.82:
		_launch_ship()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		paused_by_os = true
		get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		get_tree().paused = false
		paused_by_os = false
