class_name GameRules
extends RefCounted


static func difficulty_tier(landings: int) -> int:
	return maxi(0, landings / 5)


static func orbit_speed(landings: int, tuning: GameTuning) -> float:
	return minf(
		tuning.maximum_orbit_speed,
		tuning.base_orbit_speed + difficulty_tier(landings) * tuning.orbit_speed_per_tier
	)


static func planet_radius_range(landings: int, tuning: GameTuning) -> Vector2:
	var reduction := difficulty_tier(landings) * tuning.radius_reduction_per_tier
	var minimum_radius := maxf(tuning.minimum_planet_radius, tuning.base_min_planet_radius - reduction)
	var maximum_radius := maxf(minimum_radius + 12.0, tuning.base_max_planet_radius - reduction)
	return Vector2(minimum_radius, maximum_radius)


static func vertical_gap_range(landings: int, tuning: GameTuning) -> Vector2:
	var maximum_minimum_gap := maxf(
		tuning.minimum_vertical_gap,
		tuning.maximum_vertical_gap - tuning.minimum_placement_window_size
	)
	var minimum_gap := minf(
		maximum_minimum_gap,
		tuning.minimum_vertical_gap
			+ difficulty_tier(landings) * tuning.placement_window_tightening_per_tier
	)
	return Vector2(minimum_gap, tuning.maximum_vertical_gap)


static func landing_result(current_combo: int, perfect: bool) -> Dictionary:
	var next_combo := mini(5, current_combo + 1) if perfect else 1
	return {
		"combo": next_combo,
		"points": next_combo,
	}


static func hazard_chance(landings: int, tuning: GameTuning) -> float:
	if landings < tuning.hazards_begin_at_landing:
		return 0.0
	var active_tier := difficulty_tier(landings) - difficulty_tier(tuning.hazards_begin_at_landing)
	return minf(
		tuning.maximum_hazard_chance,
		tuning.base_hazard_chance + active_tier * tuning.hazard_chance_per_tier
	)
