extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_all")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _close_enough(actual: Vector2, expected: Vector2, tolerance: float = 0.001) -> bool:
	return actual.distance_to(expected) <= tolerance


func _run_all() -> void:
	_test_orbit_math()
	_test_rules()
	_test_save_store()
	_test_daily_challenge()
	_test_progression()
	_test_playtest_metrics()
	await _test_gameplay_integration()

	if failures.is_empty():
		print("ORBIT_BREAKER_TESTS_OK")
		quit(0)
		return
	for failure in failures:
		push_error("TEST FAILURE: %s" % failure)
	print("ORBIT_BREAKER_TESTS_FAILED: %d" % failures.size())
	quit(1)


func _test_orbit_math() -> void:
	_check(
		_close_enough(OrbitMath.tangent_for_angle(0.0, 1), Vector2(0.0, 1.0)),
		"Clockwise tangent at angle zero must point down."
	)
	_check(
		_close_enough(OrbitMath.tangent_for_angle(0.0, -1), Vector2(0.0, -1.0)),
		"Counterclockwise tangent at angle zero must point up."
	)
	_check(
		OrbitMath.direction_from_velocity(Vector2.RIGHT, Vector2.DOWN) == 1,
		"Incoming clockwise velocity must preserve clockwise orbit."
	)
	_check(
		OrbitMath.direction_from_velocity(Vector2.RIGHT, Vector2.UP) == -1,
		"Incoming counterclockwise velocity must preserve counterclockwise orbit."
	)
	_check(
		is_equal_approx(OrbitMath.ray_miss_distance(Vector2.ZERO, Vector2.RIGHT, Vector2(10.0, 4.0)), 4.0),
		"Ray miss distance must be perpendicular distance."
	)
	_check(
		OrbitMath.layout_is_reachable(Vector2.ZERO, 100.0, Vector2(0.0, -400.0), 80.0, 70.0, 690.0),
		"Valid target layout must be accepted."
	)
	_check(
		not OrbitMath.layout_is_reachable(Vector2.ZERO, 100.0, Vector2(0.0, -180.0), 80.0, 70.0, 690.0),
		"Overlapping target layout must be rejected."
	)
	_check(
		not OrbitMath.layout_is_reachable(Vector2.ZERO, 100.0, Vector2(0.0, -800.0), 80.0, 70.0, 690.0),
		"Unreachable distant target layout must be rejected."
	)
	_check(
		OrbitMath.tangent_launch_window(Vector2.ZERO, 100.0, Vector2(0.0, -400.0), 80.0) > 0.0,
		"A reachable target must expose a nonzero tangent launch window."
	)
	_check(
		is_equal_approx(
			OrbitMath.segment_circle_hit_fraction(Vector2.ZERO, Vector2(100.0, 0.0), Vector2(50.0, 0.0), 10.0),
			0.4
		),
		"Swept collision must return the first circle contact."
	)
	_check(
		OrbitMath.segment_circle_hit_fraction(Vector2.ZERO, Vector2(100.0, 0.0), Vector2(50.0, 20.0), 10.0) < 0.0,
		"Swept collision must reject a missed circle."
	)
	var open_window_count := OrbitMath.safe_launch_sample_count_for_hazards(
		Vector2.ZERO,
		100.0,
		1,
		Vector2(0.0, -400.0),
		95.0,
		[],
		180
	)
	var blocked_window_count := OrbitMath.safe_launch_sample_count_for_hazards(
		Vector2.ZERO,
		100.0,
		1,
		Vector2(0.0, -400.0),
		95.0,
		[{"position": Vector2(0.0, -260.0), "radius": 420.0}],
		180
	)
	_check(open_window_count > 0, "An unobstructed target must expose sampled launch windows.")
	_check(blocked_window_count == 0, "A fully blocked route must expose no safe launch windows.")


func _test_rules() -> void:
	var tuning := GameTuning.new()
	_check(GameRules.difficulty_tier(0) == 0, "Difficulty must begin at tier zero.")
	_check(GameRules.difficulty_tier(4) == 0, "Difficulty must not rise before five landings.")
	_check(GameRules.difficulty_tier(5) == 1, "Difficulty must rise every five landings.")
	_check(GameRules.orbit_speed(5, tuning) > GameRules.orbit_speed(4, tuning), "Orbit speed must rise at tier boundaries.")
	_check(
		GameRules.planet_radius_range(5, tuning).y < GameRules.planet_radius_range(4, tuning).y,
		"Average target size must shrink at tier boundaries."
	)
	_check(
		GameRules.vertical_gap_range(5, tuning).x > GameRules.vertical_gap_range(4, tuning).x,
		"The target placement window must tighten at tier boundaries."
	)
	_check(
		GameRules.vertical_gap_range(80, tuning).y - GameRules.vertical_gap_range(80, tuning).x
			>= tuning.minimum_placement_window_size - 0.001,
		"The placement window must retain a tunable minimum size."
	)
	var perfect_result := GameRules.landing_result(1, true)
	_check(int(perfect_result.combo) == 2 and int(perfect_result.points) == 2, "Perfect landing must raise and award the combo.")
	var capped_result := GameRules.landing_result(5, true)
	_check(int(capped_result.combo) == 5 and int(capped_result.points) == 5, "Combo must cap at five.")
	var normal_result := GameRules.landing_result(4, false)
	_check(int(normal_result.combo) == 1 and int(normal_result.points) == 1, "Normal landing must reset the combo.")
	_check(GameRules.hazard_chance(9, tuning) == 0.0, "Hazards must not spawn before ten landings.")
	_check(GameRules.hazard_chance(10, tuning) > 0.0, "Hazards must begin at ten landings.")


func _test_save_store() -> void:
	_check(SaveStore.load_best_score("res://tests/fixtures/corrupt_save.cfg") == 0, "Corrupt save data must fall back to zero.")
	var test_path := "res://.godot/orbit_breaker_test_save.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	_check(SaveStore.save_best_score(37, test_path) == OK, "Best score must save successfully.")
	_check(SaveStore.load_best_score(test_path) == 37, "Best score must load after saving.")
	var profile := SaveStore.load_profile(test_path)
	profile.reduced_screen_shake = true
	profile.guide_mode = 2
	profile.selected_ship_color = "nova"
	profile.unlocked_ship_colors = PackedStringArray(["ion", "nova"])
	_check(SaveStore.save_profile(profile, test_path) == OK, "Complete profile must save successfully.")
	var restored := SaveStore.load_profile(test_path)
	_check(bool(restored.reduced_screen_shake), "Reduced screen shake must persist.")
	_check(int(restored.guide_mode) == 2, "Guide visibility must persist.")
	_check(String(restored.selected_ship_color) == "nova", "Selected cosmetics must persist.")
	_check((restored.unlocked_ship_colors as PackedStringArray).has("nova"), "Unlocked cosmetics must persist.")
	var tied_run := SaveStore.record_run(restored, 37, 0, 0, 1, false, "")
	_check(not bool(tied_run.new_best), "An equal score must not be marked as a new best.")
	var higher_run := SaveStore.record_run(tied_run.profile, 38, 0, 0, 1, false, "")
	_check(bool(higher_run.new_best), "A strictly higher score must be marked as a new best.")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))


func _test_daily_challenge() -> void:
	_check(DailyChallenge.utc_date_key(0) == "1970-01-01", "Daily date keys must use UTC calendar dates.")
	var first_seed := DailyChallenge.seed_for_date("2026-08-20")
	_check(first_seed == DailyChallenge.seed_for_date("2026-08-20"), "The same UTC date must always produce the same seed.")
	_check(first_seed != DailyChallenge.seed_for_date("2026-08-21"), "Different UTC dates must produce different seeds.")
	var first_rng := RandomNumberGenerator.new()
	var second_rng := RandomNumberGenerator.new()
	first_rng.seed = first_seed
	second_rng.seed = first_seed
	for index in 32:
		_check(first_rng.randi() == second_rng.randi(), "Daily random sequence item %d must be deterministic." % index)


func _test_progression() -> void:
	var profile := SaveStore.default_profile()
	profile.total_perfect_landings = 10
	profile.highest_combo = 5
	profile.best_score = 25
	profile.total_landings = 50
	var unlocked := CosmeticCatalog.refresh_unlocks(profile)
	_check(unlocked.size() == 6, "All six skill rewards must unlock at their milestones.")
	_check((profile.unlocked_ship_colors as PackedStringArray).has("nova"), "Ten perfect landings must unlock the Nova ship.")
	_check((profile.unlocked_ship_colors as PackedStringArray).has("solar"), "A 5x combo must unlock the Solar ship.")
	_check((profile.unlocked_trails as PackedStringArray).has("plasma"), "Ten perfect landings must unlock the Plasma trail.")
	_check((profile.unlocked_trails as PackedStringArray).has("comet"), "A score of 25 must unlock the Comet trail.")
	_check((profile.unlocked_planet_themes as PackedStringArray).has("nebula"), "Twenty-five landings must unlock Nebula.")
	_check((profile.unlocked_planet_themes as PackedStringArray).has("sunforge"), "Fifty landings must unlock Sunforge.")
	_check(CosmeticCatalog.refresh_unlocks(profile).is_empty(), "Unlocked rewards must not be granted twice.")


func _test_playtest_metrics() -> void:
	var path := "res://.godot/orbit_breaker_test_metrics.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_check(PlaytestMetrics.record_run(0, 0, 10.0, "miss", false, path) == OK, "A failed first launch must be recorded.")
	_check(PlaytestMetrics.record_run(7, 3, 20.0, "asteroid", true, path) == OK, "A successful first launch must be recorded.")
	_check(PlaytestMetrics.record_restart(path) == OK, "Restarts must be recorded.")
	var report := PlaytestMetrics.summary(path)
	_check(int(report.completed_runs) == 2, "Playtest report must count completed runs.")
	_check(is_equal_approx(float(report.average_run_seconds), 15.0), "Playtest report must calculate average run length.")
	_check(is_equal_approx(float(report.restart_rate), 0.5), "Playtest report must calculate restart rate.")
	_check(is_equal_approx(float(report.first_launch_success_rate), 0.5), "Playtest report must measure first-launch success directly.")
	_check(int(report.score_buckets["0"]) == 1 and int(report.score_buckets["5-9"]) == 1, "Playtest report must retain score distribution.")
	_check(int(report.failure_reasons.get("miss", 0)) == 1 and int(report.failure_reasons.get("asteroid", 0)) == 1, "Playtest report must retain common failure reasons.")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_gameplay_integration() -> void:
	var game_scene := load("res://scenes/game.tscn") as PackedScene
	_check(game_scene != null, "Main game scene must load.")
	if game_scene == null:
		return
	var game := game_scene.instantiate() as OrbitGame
	_check(game != null, "Main game scene must instantiate.")
	if game == null:
		return
	var integration_save_path := "res://.godot/orbit_breaker_integration_test_save.cfg"
	var integration_metrics_path := "res://.godot/orbit_breaker_integration_test_metrics.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(integration_save_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(integration_metrics_path))
	game.save_path = integration_save_path
	game.metrics_path = integration_metrics_path
	root.add_child(game)
	await process_frame
	await process_frame
	game.audio_controller.playback_enabled = false
	_check(not game.game_center.authenticated, "Game Center must degrade safely outside iOS.")
	_check(not game.hud.settings_panel.visible, "Settings must begin closed.")
	_check(game.hud.settings_panel.find_child("PrivacyButton", true, false) != null, "Settings must expose the privacy policy.")
	_check(game.hud.settings_panel.find_child("SupportButton", true, false) != null, "Settings must expose support.")
	_check(OrbitGame.PRIVACY_URL.begins_with("https://"), "The in-app privacy action must use HTTPS.")
	_check(OrbitGame.SUPPORT_URL.begins_with("https://"), "The in-app support action must use HTTPS.")

	_check(game.state == OrbitGame.GameState.READY, "Game must begin in READY state.")
	game._handle_primary_action()
	_check(game.state == OrbitGame.GameState.ORBITING, "First tap must start in orbit without launching.")
	_check(game.run_started_msec > 0, "The initial Classic run must start the run-length timer.")
	_check(game.aim_guide.active, "First run must show the trajectory guide.")
	_check(game.hud.tutorial_label.visible, "First run must keep the launch tutorial visible.")
	game._handle_primary_action()
	_check(game.state == OrbitGame.GameState.ORBITING, "Duplicate iOS tap event must not launch the ship.")
	_check(not game.start_run(), "An active run must not start twice.")
	game.input_locked_until_msec = 0
	game._handle_primary_action()
	_check(game.state == OrbitGame.GameState.IN_FLIGHT, "Launch must enter IN_FLIGHT state.")
	_check(not game.aim_guide.active, "Trajectory guide must hide during flight.")
	var launch_velocity := game.ship.velocity
	game._launch_ship()
	_check(game.ship.velocity == launch_velocity, "Rapid second launch must be ignored.")

	game.launch_predicted_perfect = true
	game.ship.velocity = Vector2.UP * game.tuning.launch_speed
	game.ship.global_position = game.target_planet.global_position + Vector2(game.target_planet.radius + game.ship.radius - 1.0, 0.0)
	game._update_flight(0.0)
	_check(game.state == OrbitGame.GameState.ORBITING, "Target contact must return to ORBITING state.")
	_check(game.score == 2 and game.combo == 2, "Perfect landing must update score and combo.")
	_check(game.first_launch_succeeded, "Landing the first launch must be captured for playtest analysis.")

	game._launch_ship()
	game.launch_predicted_perfect = false
	game.ship.velocity = Vector2.UP * game.tuning.launch_speed
	game.ship.global_position = game.target_planet.global_position + Vector2(game.target_planet.radius + game.ship.radius - 1.0, 0.0)
	game._update_flight(0.0)
	_check(game.score == 3 and game.combo == 1, "Normal landing must add one and reset combo.")

	game._launch_ship()
	var hazard := game.HAZARD_SCENE.instantiate() as OrbitHazard
	game.hazards.add_child(hazard)
	hazard.global_position = game.ship.global_position + game.ship.velocity.normalized() * 120.0
	hazard.configure(30.0, 7)
	game._update_flight(0.25)
	_check(game.state == OrbitGame.GameState.GAME_OVER, "Crossing a hazard between frames must end the run.")

	game._reset_world(true)
	game._launch_ship()
	game.ship.global_position = Vector2(-220.0, game.camera.global_position.y)
	game._update_flight(0.0)
	_check(game.state == OrbitGame.GameState.GAME_OVER, "Leaving the play area must end the run as a miss.")

	game._reset_world(true)
	game._launch_ship()
	game.flight_time = game.tuning.flight_timeout
	game._update_flight(0.001)
	_check(game.state == OrbitGame.GameState.GAME_OVER, "Flight timeout must end the run.")
	_check(game.hud.failure_label.text == "SIGNAL TIMED OUT", "A flight timeout must display its specific failure reason.")

	game._reset_world(true)
	var state_before_pause := game.state
	game._notification(NOTIFICATION_APPLICATION_PAUSED)
	_check(game.paused_by_os and game.state == state_before_pause, "Background pause must preserve the run state.")
	game._notification(NOTIFICATION_APPLICATION_RESUMED)
	_check(not game.paused_by_os and game.state == state_before_pause, "Resume must restore the same run state.")
	game._pause_run()
	_check(game.manually_paused and game.audio_controller.music_paused, "Manual pause must pause music playback.")
	_check(game.world.process_mode == Node.PROCESS_MODE_DISABLED, "Manual pause must freeze the gameplay world.")
	if game.audio_controller.base_player.stream != null:
		_check(game.audio_controller.base_player.stream_paused, "Manual pause must pause the active base music player.")
	game._restart_from_pause()
	_check(not game.manually_paused and not game.audio_controller.music_paused, "Restarting from pause must resume music playback.")
	_check(game.world.process_mode == Node.PROCESS_MODE_INHERIT, "Restarting from pause must resume the gameplay world.")
	if game.audio_controller.base_player.stream != null:
		_check(not game.audio_controller.base_player.stream_paused, "Restarting from pause must resume the active base music player.")
	game.audio_controller.apply_settings(false, false)
	game.audio_controller.set_intensity(5, 2)
	_check(
		is_equal_approx(game.audio_controller.drive_player.volume_db, -80.0),
		"Changing intensity must not unmute disabled music."
	)
	game.audio_controller.apply_settings(false, true)
	game.audio_controller.set_intensity(1, 0)

	_check(game.end_run("test"), "Active run must enter GAME_OVER state.")
	_check(game.state == OrbitGame.GameState.GAME_OVER, "Failure must show GAME_OVER state.")
	_check(not game.end_run("duplicate"), "Duplicate failure must be ignored.")

	for cycle in 10:
		game._reset_world(true)
		_check(game.state == OrbitGame.GameState.ORBITING, "Restart cycle %d must begin immediately." % cycle)
		game._launch_ship()
		_check(game.state == OrbitGame.GameState.IN_FLIGHT, "Restart cycle %d must launch." % cycle)
		game.flight_time = game.tuning.flight_timeout
		game._update_flight(0.001)
		_check(game.state == OrbitGame.GameState.GAME_OVER, "Restart cycle %d must end on timeout." % cycle)

	for generation in 100:
		game._reset_world(false)
		var distance := game.current_planet.global_position.distance_to(game.target_planet.global_position)
		_check(
			OrbitMath.layout_is_reachable(
				game.current_planet.global_position,
				game.current_planet.radius + game.tuning.orbit_clearance,
				game.target_planet.global_position,
				game.target_planet.radius,
				game.tuning.minimum_planet_separation,
				game.tuning.maximum_target_distance
			),
			"Generated layout %d must be reachable, distance %.2f." % [generation, distance]
		)
		_check(
			OrbitMath.tangent_launch_window(
				game.current_planet.global_position,
				game.current_planet.radius + game.tuning.orbit_clearance,
				game.target_planet.global_position,
				game.target_planet.radius + game.ship.radius
			) > 0.0,
			"Generated layout %d must provide a real tangent launch window." % generation
		)

	await process_frame
	var original_base_hazard_chance := game.tuning.base_hazard_chance
	var original_hazard_chance_per_tier := game.tuning.hazard_chance_per_tier
	var original_maximum_hazard_chance := game.tuning.maximum_hazard_chance
	game.tuning.base_hazard_chance = 1.0
	game.tuning.hazard_chance_per_tier = 0.0
	game.tuning.maximum_hazard_chance = 1.0
	for landing_stage in [9, 10, 20, 30, 60]:
		for hazard_generation in 60:
			for child in game.hazards.get_children():
				child.free()
			game.landings = landing_stage
			game.layout_rng.seed = landing_stage * 1000 + hazard_generation
			game._spawn_hazard_for_segment(game.current_planet, game.target_planet)
			var hazard_data: Array[Dictionary] = []
			for hazard_node in game.hazards.get_children():
				var generated_hazard := hazard_node as OrbitHazard
				if generated_hazard == null:
					continue
				hazard_data.append({
					"position": generated_hazard.global_position,
					"radius": generated_hazard.radius * 1.12,
				})
				if landing_stage < game.tuning.pulse_hazards_begin_at_landing:
					_check(generated_hazard.kind == OrbitHazard.Kind.ASTEROID, "Pulse mines must not appear before their introduction.")
			if landing_stage < game.tuning.hazards_begin_at_landing:
				_check(hazard_data.is_empty(), "Hazards must not appear before their introduction.")
			if landing_stage < game.tuning.combined_hazards_begin_at_landing:
				_check(hazard_data.size() <= 1, "Combined hazards must not appear before both kinds are introduced.")
			var safe_samples := OrbitMath.safe_launch_sample_count_for_hazards(
				game.current_planet.global_position,
				game.current_planet.radius + game.tuning.orbit_clearance,
				game.ship.orbit_direction,
				game.target_planet.global_position,
				game.target_planet.radius + game.ship.radius,
				hazard_data,
				180
			)
			_check(
				safe_samples >= game.tuning.minimum_safe_launch_samples,
				"Hazard layout at landing %d, seed %d must preserve a valid launch window." % [landing_stage, hazard_generation]
			)
	game.tuning.base_hazard_chance = original_base_hazard_chance
	game.tuning.hazard_chance_per_tier = original_hazard_chance_per_tier
	game.tuning.maximum_hazard_chance = original_maximum_hazard_chance
	for child in game.hazards.get_children():
		child.free()

	game.audio_controller.set_intensity(5, 2)
	game._reset_world(true)
	_check(is_equal_approx(game.audio_controller.drive_player.volume_db, -34.0), "A replay must reset adaptive music intensity.")
	game.end_run("miss")
	game._reset_world(false)

	_check(game.start_run(true), "Daily Challenge must start from the ready screen.")
	var first_daily_target := game.target_planet.global_position
	var first_daily_radius := game.target_planet.radius
	_check(game.end_run("miss"), "A Daily Challenge run must be able to end.")
	game._replay_current_mode()
	_check(game.is_daily_run, "Immediate replay must preserve Daily Challenge mode.")
	_check(_close_enough(game.target_planet.global_position, first_daily_target), "Daily replay must reproduce the first target position.")
	_check(is_equal_approx(game.target_planet.radius, first_daily_radius), "Daily replay must reproduce the first target size.")
	game.end_run("miss")
	var score_card_image := Image.create(320, 320, false, Image.FORMAT_RGB8)
	score_card_image.fill(Color("08152f"))
	var score_card_path := game.save_score_image(score_card_image, "res://.godot/orbit_breaker_test_score_card.png")
	_check(not score_card_path.is_empty() and FileAccess.file_exists(score_card_path), "A shareable score-card PNG must be generated.")
	if not score_card_path.is_empty():
		DirAccess.remove_absolute(score_card_path)

	game.queue_free()
	await process_frame
	await process_frame
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(integration_save_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(integration_metrics_path))
