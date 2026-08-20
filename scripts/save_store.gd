class_name SaveStore
extends RefCounted

const SAVE_VERSION := 1
const DEFAULT_PATH := "user://save.cfg"


static func load_best_score(path: String = DEFAULT_PATH) -> int:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return 0
	var version_value: Variant = config.get_value("save", "version", 0)
	var score_value: Variant = config.get_value("save", "best_score", 0)
	if typeof(version_value) != TYPE_INT or int(version_value) != SAVE_VERSION:
		return 0
	if typeof(score_value) != TYPE_INT:
		return 0
	return maxi(0, int(score_value))


static func save_best_score(score: int, path: String = DEFAULT_PATH) -> Error:
	var config := ConfigFile.new()
	config.set_value("save", "version", SAVE_VERSION)
	config.set_value("save", "best_score", maxi(0, score))
	return config.save(path)

