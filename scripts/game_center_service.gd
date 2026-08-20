class_name OrbitGameCenter
extends Node

signal authentication_changed(authenticated: bool)

const ALL_TIME_LEADERBOARD := "com.antonio.orbitbreaker.highscore"
const WEEKLY_LEADERBOARD := "com.antonio.orbitbreaker.weekly"
const DAILY_LEADERBOARD := "com.antonio.orbitbreaker.daily"
const PERFECT_10_ACHIEVEMENT := "com.antonio.orbitbreaker.perfect10"
const COMBO_5_ACHIEVEMENT := "com.antonio.orbitbreaker.combo5"
const PLANETS_50_ACHIEVEMENT := "com.antonio.orbitbreaker.planets50"

@export var enabled: bool = true

var game_center: Object
var modern_manager: Object
var authenticated: bool = false


func _ready() -> void:
	if not enabled or OS.get_name() != "iOS":
		set_process(false)
		return
	if ClassDB.class_exists("GameCenterManager"):
		modern_manager = ClassDB.instantiate("GameCenterManager")
		modern_manager.connect("authentication_result", _on_modern_authentication)
		modern_manager.connect("authentication_error", _on_modern_authentication_error)
		modern_manager.call("authenticate")
		set_process(false)
	elif Engine.has_singleton("GameCenter"):
		game_center = Engine.get_singleton("GameCenter")
		game_center.call("authenticate")
		set_process(true)
	else:
		set_process(false)


func _process(_delta: float) -> void:
	if game_center == null:
		return
	if game_center.has_method("get_pending_event_count"):
		while int(game_center.call("get_pending_event_count")) > 0:
			var event: Variant = game_center.call("pop_pending_event")
			if event is Dictionary and String(event.get("type", "")) == "authentication":
				authenticated = String(event.get("result", "")) == "ok"
				authentication_changed.emit(authenticated)
	elif game_center.has_method("is_authenticated"):
		var current := bool(game_center.call("is_authenticated"))
		if current != authenticated:
			authenticated = current
			authentication_changed.emit(authenticated)


func submit_run(score: int, is_daily: bool) -> void:
	if not _is_ready():
		return
	_post_score(ALL_TIME_LEADERBOARD, score)
	_post_score(WEEKLY_LEADERBOARD, score)
	if is_daily:
		_post_score(DAILY_LEADERBOARD, score)


func submit_achievement_progress(profile: Dictionary) -> void:
	if not _is_ready():
		return
	_award(PERFECT_10_ACHIEVEMENT, minf(100.0, float(profile.total_perfect_landings) * 10.0))
	_award(COMBO_5_ACHIEVEMENT, 100.0 if int(profile.highest_combo) >= 5 else float(profile.highest_combo) * 20.0)
	_award(PLANETS_50_ACHIEVEMENT, minf(100.0, float(profile.total_landings) * 2.0))


func show_leaderboards() -> void:
	if not _is_ready():
		return
	if modern_manager != null and ClassDB.class_exists("GKGameCenterViewController"):
		ClassDB.class_call_static("GKGameCenterViewController", "show_type", 1)
	elif game_center != null and game_center.has_method("show_game_center"):
		game_center.call("show_game_center", {"view": "leaderboards"})


func _post_score(category: String, score: int) -> void:
	if modern_manager != null and ClassDB.class_exists("GKLeaderboard"):
		var local_player: Object = modern_manager.get("local_player")
		ClassDB.class_call_static("GKLeaderboard", "load_leaderboards", PackedStringArray([category]), func(leaderboards: Array, error: Variant) -> void:
			if error == null and not leaderboards.is_empty():
				leaderboards[0].call("submit_score", score, 0, local_player, func(_submit_error: Variant) -> void: pass)
		)
	elif game_center != null and game_center.has_method("post_score"):
		game_center.call("post_score", {"category": category, "score": score})


func _award(name: String, progress: float) -> void:
	if modern_manager != null and ClassDB.class_exists("GKAchievement"):
		var achievement: Object = ClassDB.class_call_static("GKAchievement", "make", name)
		if achievement != null:
			achievement.set("percent_complete", progress)
			achievement.set("shows_completion_banner", is_equal_approx(progress, 100.0))
			ClassDB.class_call_static("GKAchievement", "report_achievement", [achievement], func(_error: Variant) -> void: pass)
	elif game_center != null and game_center.has_method("award_achievement"):
		game_center.call("award_achievement", {"name": name, "progress": progress, "show_completion_banner": is_equal_approx(progress, 100.0)})


func _is_ready() -> bool:
	if modern_manager != null:
		var local_player: Object = modern_manager.get("local_player")
		authenticated = local_player != null and bool(local_player.get("is_authenticated"))
		return authenticated
	if game_center == null:
		return false
	if game_center.has_method("is_authenticated"):
		authenticated = bool(game_center.call("is_authenticated"))
	return authenticated


func _on_modern_authentication(status: bool) -> void:
	authenticated = status
	authentication_changed.emit(authenticated)


func _on_modern_authentication_error(_message: String) -> void:
	authenticated = false
	authentication_changed.emit(false)
