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
	var test_path := "user://orbit_breaker_test_save.cfg"
	_check(SaveStore.save_best_score(37, test_path) == OK, "Best score must save successfully.")
	_check(SaveStore.load_best_score(test_path) == 37, "Best score must load after saving.")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))


func _test_gameplay_integration() -> void:
	var game_scene := load("res://scenes/game.tscn") as PackedScene
	_check(game_scene != null, "Main game scene must load.")
	if game_scene == null:
		return
	var game := game_scene.instantiate() as OrbitGame
	_check(game != null, "Main game scene must instantiate.")
	if game == null:
		return
	root.add_child(game)
	await process_frame
	await process_frame
	game.audio_controller.playback_enabled = false

	_check(game.state == OrbitGame.GameState.READY, "Game must begin in READY state.")
	game._handle_primary_action()
	_check(game.state == OrbitGame.GameState.ORBITING, "First tap must start in orbit without launching.")
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

	game._reset_world(true)
	var state_before_pause := game.state
	game._notification(NOTIFICATION_APPLICATION_PAUSED)
	_check(game.paused_by_os and game.state == state_before_pause, "Background pause must preserve the run state.")
	game._notification(NOTIFICATION_APPLICATION_RESUMED)
	_check(not game.paused_by_os and game.state == state_before_pause, "Resume must restore the same run state.")

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

	game.queue_free()
	await process_frame
	await process_frame
	await process_frame
