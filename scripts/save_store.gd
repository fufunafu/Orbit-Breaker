class_name SaveStore
extends RefCounted

const SAVE_VERSION := 2
const DEFAULT_PATH := "user://save.cfg"


static func default_profile() -> Dictionary:
	return {
		"best_score": 0,
		"total_landings": 0,
		"total_perfect_landings": 0,
		"highest_combo": 1,
		"completed_runs": 0,
		"restarts": 0,
		"tutorial_completed": false,
		"selected_ship_color": "ion",
		"selected_trail": "ion",
		"selected_planet_theme": "cosmic",
		"unlocked_ship_colors": PackedStringArray(["ion"]),
		"unlocked_trails": PackedStringArray(["ion"]),
		"unlocked_planet_themes": PackedStringArray(["cosmic"]),
		"sound_enabled": true,
		"music_enabled": true,
		"haptics_enabled": true,
		"reduced_motion": false,
		"reduced_screen_shake": false,
		"high_contrast": false,
		"guide_mode": 1,
		"daily_date": "",
		"daily_best_score": 0,
	}


static func load_profile(path: String = DEFAULT_PATH) -> Dictionary:
	var profile := default_profile()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return profile
	var version_value: Variant = config.get_value("save", "version", 0)
	if typeof(version_value) != TYPE_INT or int(version_value) < 1 or int(version_value) > SAVE_VERSION:
		return profile

	for key in ["best_score", "total_landings", "total_perfect_landings", "highest_combo", "completed_runs", "restarts"]:
		var value: Variant = config.get_value("progress", key, config.get_value("save", key, profile[key]))
		if typeof(value) == TYPE_INT:
			profile[key] = maxi(0, int(value))
	var tutorial_value: Variant = config.get_value("progress", "tutorial_completed", profile.tutorial_completed)
	if typeof(tutorial_value) == TYPE_BOOL:
		profile.tutorial_completed = tutorial_value
	for key in ["selected_ship_color", "selected_trail", "selected_planet_theme"]:
		var value: Variant = config.get_value("progress", key, profile[key])
		if typeof(value) == TYPE_STRING and not String(value).is_empty():
			profile[key] = value
	for key in ["unlocked_ship_colors", "unlocked_trails", "unlocked_planet_themes"]:
		var value: Variant = config.get_value("unlocks", key, profile[key])
		if value is PackedStringArray and not value.is_empty():
			profile[key] = value
	for key in ["sound_enabled", "music_enabled", "haptics_enabled", "reduced_motion", "reduced_screen_shake", "high_contrast"]:
		var value: Variant = config.get_value("settings", key, profile[key])
		if typeof(value) == TYPE_BOOL:
			profile[key] = value
	var guide_value: Variant = config.get_value("settings", "guide_mode", profile.guide_mode)
	if typeof(guide_value) == TYPE_INT:
		profile.guide_mode = clampi(int(guide_value), 0, 2)
	var daily_date: Variant = config.get_value("daily", "date", "")
	var daily_best: Variant = config.get_value("daily", "best_score", 0)
	if typeof(daily_date) == TYPE_STRING:
		profile.daily_date = daily_date
	if typeof(daily_best) == TYPE_INT:
		profile.daily_best_score = maxi(0, int(daily_best))
	return profile


static func save_profile(profile: Dictionary, path: String = DEFAULT_PATH) -> Error:
	var defaults := default_profile()
	var config := ConfigFile.new()
	config.set_value("save", "version", SAVE_VERSION)
	for key in ["best_score", "total_landings", "total_perfect_landings", "highest_combo", "completed_runs", "restarts", "tutorial_completed", "selected_ship_color", "selected_trail", "selected_planet_theme"]:
		config.set_value("progress", key, profile.get(key, defaults[key]))
	for key in ["unlocked_ship_colors", "unlocked_trails", "unlocked_planet_themes"]:
		config.set_value("unlocks", key, profile.get(key, defaults[key]))
	for key in ["sound_enabled", "music_enabled", "haptics_enabled", "reduced_motion", "reduced_screen_shake", "high_contrast", "guide_mode"]:
		config.set_value("settings", key, profile.get(key, defaults[key]))
	config.set_value("daily", "date", profile.get("daily_date", ""))
	config.set_value("daily", "best_score", maxi(0, int(profile.get("daily_best_score", 0))))
	return config.save(path)


static func load_best_score(path: String = DEFAULT_PATH) -> int:
	return int(load_profile(path).best_score)


static func save_best_score(score: int, path: String = DEFAULT_PATH) -> Error:
	var profile := load_profile(path)
	profile.best_score = maxi(int(profile.best_score), score)
	return save_profile(profile, path)


static func record_run(profile: Dictionary, score: int, landings: int, perfect_landings: int, maximum_combo: int, is_daily: bool, daily_date: String) -> Dictionary:
	var previous_best := int(profile.best_score)
	profile.best_score = maxi(previous_best, score)
	profile.total_landings = int(profile.total_landings) + maxi(0, landings)
	profile.total_perfect_landings = int(profile.total_perfect_landings) + maxi(0, perfect_landings)
	profile.highest_combo = maxi(int(profile.highest_combo), maximum_combo)
	profile.completed_runs = int(profile.completed_runs) + 1
	if is_daily:
		if String(profile.daily_date) != daily_date:
			profile.daily_date = daily_date
			profile.daily_best_score = 0
		profile.daily_best_score = maxi(int(profile.daily_best_score), score)
	return {"new_best": score > previous_best, "profile": profile}
