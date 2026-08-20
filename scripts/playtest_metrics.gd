class_name PlaytestMetrics
extends RefCounted

const DEFAULT_PATH := "user://playtest_metrics.json"


static func default_data() -> Dictionary:
	return {
		"schema_version": 2,
		"completed_runs": 0,
		"runs_with_a_landing": 0,
		"runs_with_first_launch_success": 0,
		"restarts": 0,
		"total_run_seconds": 0.0,
		"score_buckets": {"0": 0, "1-4": 0, "5-9": 0, "10-24": 0, "25+": 0},
		"failure_reasons": {},
	}


static func load_data(path: String = DEFAULT_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return default_data()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return default_data()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else default_data()


static func record_run(score: int, landings: int, duration_seconds: float, failure_reason: String, first_launch_succeeded: bool = false, path: String = DEFAULT_PATH) -> Error:
	var data := load_data(path)
	data.completed_runs = int(data.get("completed_runs", 0)) + 1
	if landings > 0:
		data.runs_with_a_landing = int(data.get("runs_with_a_landing", 0)) + 1
	if first_launch_succeeded:
		data.runs_with_first_launch_success = int(data.get("runs_with_first_launch_success", 0)) + 1
	data.total_run_seconds = float(data.get("total_run_seconds", 0.0)) + maxf(0.0, duration_seconds)
	var buckets: Dictionary = data.get("score_buckets", default_data().score_buckets)
	var bucket := _score_bucket(score)
	buckets[bucket] = int(buckets.get(bucket, 0)) + 1
	data.score_buckets = buckets
	var reasons: Dictionary = data.get("failure_reasons", {})
	reasons[failure_reason] = int(reasons.get(failure_reason, 0)) + 1
	data.failure_reasons = reasons
	return _save(data, path)


static func record_restart(path: String = DEFAULT_PATH) -> Error:
	var data := load_data(path)
	data.restarts = int(data.get("restarts", 0)) + 1
	return _save(data, path)


static func summary(path: String = DEFAULT_PATH) -> Dictionary:
	var data := load_data(path)
	var runs := int(data.get("completed_runs", 0))
	return {
		"completed_runs": runs,
		"first_landing_rate": float(data.get("runs_with_a_landing", 0)) / float(runs) if runs > 0 else 0.0,
		"first_launch_success_rate": float(data.get("runs_with_first_launch_success", 0)) / float(runs) if runs > 0 else 0.0,
		"restart_rate": float(data.get("restarts", 0)) / float(runs) if runs > 0 else 0.0,
		"average_run_seconds": float(data.get("total_run_seconds", 0.0)) / float(runs) if runs > 0 else 0.0,
		"score_buckets": data.get("score_buckets", {}),
		"failure_reasons": data.get("failure_reasons", {}),
	}


static func export_report(path: String = "user://orbit-breaker-playtest-report.json", source_path: String = DEFAULT_PATH) -> String:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(summary(source_path), "\t"))
	file.close()
	return ProjectSettings.globalize_path(path)


static func _save(data: Dictionary, path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.close()
	return OK


static func _score_bucket(score: int) -> String:
	if score <= 0:
		return "0"
	if score <= 4:
		return "1-4"
	if score <= 9:
		return "5-9"
	if score <= 24:
		return "10-24"
	return "25+"
