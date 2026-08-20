class_name OrbitHUD
extends Control

signal classic_requested
signal daily_requested
signal replay_requested
signal share_requested
signal pause_requested
signal resume_requested
signal restart_requested
signal leaderboards_requested
signal setting_changed(key: String, value: Variant)
signal cosmetic_cycle_requested(category: String)
signal export_metrics_requested
signal privacy_requested
signal support_requested

var score_label: Label
var best_label: Label
var combo_label: Label
var mode_label: Label
var title_label: Label
var prompt_label: Label
var tutorial_label: Label
var tip_label: Label
var ready_actions: VBoxContainer
var game_over_panel: PanelContainer
var new_best_label: Label
var failure_label: Label
var final_score_label: Label
var stats_label: Label
var unlock_label: Label
var share_status_label: Label
var pause_button: Button
var pause_panel: PanelContainer
var settings_panel: PanelContainer
var settings_controls: Dictionary = {}
var loadout_buttons: Dictionary = {}
var flash_rect: ColorRect
var flash_tween: Tween
var tip_tween: Tween
var settings_return_to_pause: bool = false
var safe_padding := Vector4(54.0, 72.0, 54.0, 54.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_interface()
	_apply_safe_area()


func _build_interface() -> void:
	_build_top_row()
	_build_ready_actions()
	_build_tutorial()
	_build_game_over()
	_build_pause()
	_build_settings()
	flash_rect = ColorRect.new()
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	add_child(flash_rect)


func _build_top_row() -> void:
	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_row.offset_left = safe_padding.x
	top_row.offset_top = safe_padding.y
	top_row.offset_right = -safe_padding.z
	top_row.offset_bottom = safe_padding.y + 110.0
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_row)
	score_label = _make_label("0", 58, Color("eaffff"), HORIZONTAL_ALIGNMENT_LEFT)
	score_label.custom_minimum_size = Vector2(210.0, 96.0)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(score_label)
	best_label = _make_label("BEST 0", 28, Color("75e8ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	best_label.custom_minimum_size = Vector2(330.0, 96.0)
	best_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(best_label)
	pause_button = _make_button("II", 32, Vector2(82.0, 76.0))
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	top_row.add_child(pause_button)
	combo_label = _make_label("", 34, Color("ff6bdd"), HORIZONTAL_ALIGNMENT_CENTER)
	combo_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	combo_label.position = Vector2(-170.0, safe_padding.y + 88.0)
	combo_label.size = Vector2(340.0, 58.0)
	add_child(combo_label)
	mode_label = _make_label("", 24, Color("ffd166"), HORIZONTAL_ALIGNMENT_CENTER)
	mode_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	mode_label.position = Vector2(-260.0, safe_padding.y + 145.0)
	mode_label.size = Vector2(520.0, 48.0)
	add_child(mode_label)


func _build_ready_actions() -> void:
	title_label = _make_label("ORBIT\nBREAKER", 92, Color("eaffff"), HORIZONTAL_ALIGNMENT_CENTER)
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.position = Vector2(-370.0, -760.0)
	title_label.size = Vector2(740.0, 240.0)
	title_label.add_theme_constant_override("line_spacing", -18)
	add_child(title_label)
	prompt_label = _make_label("ONE TAP. PERFECT TIMING.", 29, Color("79f9ff"), HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.set_anchors_preset(Control.PRESET_CENTER)
	prompt_label.position = Vector2(-390.0, -490.0)
	prompt_label.size = Vector2(780.0, 70.0)
	add_child(prompt_label)
	ready_actions = VBoxContainer.new()
	ready_actions.set_anchors_preset(Control.PRESET_CENTER)
	ready_actions.position = Vector2(-300.0, -320.0)
	ready_actions.size = Vector2(600.0, 450.0)
	ready_actions.add_theme_constant_override("separation", 22)
	add_child(ready_actions)
	var classic_button := _make_button("CLASSIC RUN", 34, Vector2(600.0, 88.0))
	classic_button.pressed.connect(func() -> void: classic_requested.emit())
	ready_actions.add_child(classic_button)
	var daily_button := _make_button("DAILY CHALLENGE", 34, Vector2(600.0, 88.0))
	daily_button.name = "DailyButton"
	daily_button.pressed.connect(func() -> void: daily_requested.emit())
	ready_actions.add_child(daily_button)
	var settings_button := _make_button("LOADOUT + SETTINGS", 28, Vector2(600.0, 78.0))
	settings_button.pressed.connect(show_settings)
	ready_actions.add_child(settings_button)
	var leaderboard_button := _make_button("LEADERBOARDS", 28, Vector2(600.0, 78.0))
	leaderboard_button.pressed.connect(func() -> void: leaderboards_requested.emit())
	ready_actions.add_child(leaderboard_button)


func _build_tutorial() -> void:
	tutorial_label = _make_label("WAIT FOR THE GUIDE TO TOUCH THE TARGET\nTHEN TAP TO LAUNCH", 29, Color("d6fdff"), HORIZONTAL_ALIGNMENT_CENTER)
	tutorial_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tutorial_label.position = Vector2(-450.0, -310.0)
	tutorial_label.size = Vector2(900.0, 150.0)
	tutorial_label.add_theme_constant_override("line_spacing", 8)
	tutorial_label.visible = false
	add_child(tutorial_label)
	tip_label = _make_label("", 28, Color("fff0b8"), HORIZONTAL_ALIGNMENT_CENTER)
	tip_label.set_anchors_preset(Control.PRESET_CENTER)
	tip_label.position = Vector2(-440.0, 520.0)
	tip_label.size = Vector2(880.0, 100.0)
	tip_label.visible = false
	add_child(tip_label)


func _build_game_over() -> void:
	game_over_panel = _make_panel(Vector2(780.0, 860.0), Vector2(-390.0, -430.0))
	add_child(game_over_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	game_over_panel.add_child(box)
	new_best_label = _make_label("NEW BEST", 34, Color("ffd166"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(new_best_label)
	var over_title := _make_label("SIGNAL LOST", 54, Color("ff7194"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(over_title)
	failure_label = _make_label("DRIFTED INTO SPACE", 25, Color("ffb0c1"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(failure_label)
	final_score_label = _make_label("SCORE 0", 45, Color("ecffff"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(final_score_label)
	stats_label = _make_label("", 26, Color("bdefff"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(stats_label)
	unlock_label = _make_label("", 24, Color("ffd166"), HORIZONTAL_ALIGNMENT_CENTER)
	unlock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(unlock_label)
	var replay_button := _make_button("REPLAY NOW", 32, Vector2(620.0, 76.0))
	replay_button.pressed.connect(func() -> void: replay_requested.emit())
	box.add_child(replay_button)
	var share_button := _make_button("SAVE SCORE CARD", 27, Vector2(620.0, 68.0))
	share_button.pressed.connect(func() -> void: share_requested.emit())
	box.add_child(share_button)
	var leaderboard_button := _make_button("LEADERBOARDS", 25, Vector2(620.0, 64.0))
	leaderboard_button.pressed.connect(func() -> void: leaderboards_requested.emit())
	box.add_child(leaderboard_button)
	share_status_label = _make_label("", 20, Color("8fffd4"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(share_status_label)
	game_over_panel.visible = false


func _build_pause() -> void:
	pause_panel = _make_panel(Vector2(650.0, 470.0), Vector2(-325.0, -235.0))
	add_child(pause_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	pause_panel.add_child(box)
	box.add_child(_make_label("RUN PAUSED", 48, Color("eaffff"), HORIZONTAL_ALIGNMENT_CENTER))
	var resume_button := _make_button("RESUME", 32, Vector2(520.0, 78.0))
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	box.add_child(resume_button)
	var restart_button := _make_button("RESTART", 30, Vector2(520.0, 74.0))
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	box.add_child(restart_button)
	var settings_button := _make_button("SETTINGS", 27, Vector2(520.0, 68.0))
	settings_button.pressed.connect(show_settings)
	box.add_child(settings_button)
	pause_panel.visible = false


func _build_settings() -> void:
	settings_panel = _make_panel(Vector2(820.0, 1260.0), Vector2(-410.0, -630.0))
	settings_panel.name = "SettingsPanel"
	add_child(settings_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	settings_panel.add_child(box)
	box.add_child(_make_label("LOADOUT + SETTINGS", 42, Color("eaffff"), HORIZONTAL_ALIGNMENT_CENTER))
	for setting in [
		["sound_enabled", "SOUND"],
		["music_enabled", "MUSIC"],
		["haptics_enabled", "HAPTICS"],
		["reduced_motion", "REDUCED MOTION"],
		["reduced_screen_shake", "REDUCED SCREEN SHAKE"],
		["high_contrast", "HIGH CONTRAST GUIDE"],
	]:
		var check := CheckButton.new()
		check.text = setting[1]
		check.custom_minimum_size = Vector2(650.0, 62.0)
		check.add_theme_font_size_override("font_size", 26)
		var key := String(setting[0])
		check.toggled.connect(func(value: bool) -> void: setting_changed.emit(key, value))
		settings_controls[key] = check
		box.add_child(check)
	var guide_button := _make_button("GUIDE: TUTORIAL", 25, Vector2(650.0, 64.0))
	guide_button.pressed.connect(func() -> void: setting_changed.emit("guide_cycle", true))
	settings_controls.guide_mode = guide_button
	box.add_child(guide_button)
	for cosmetic in [["ship", "SHIP"], ["trail", "TRAIL"], ["theme", "PLANETS"]]:
		var button := _make_button("%s: ION" % cosmetic[1], 25, Vector2(650.0, 64.0))
		var category := String(cosmetic[0])
		button.pressed.connect(func() -> void: cosmetic_cycle_requested.emit(category))
		loadout_buttons[category] = button
		box.add_child(button)
	var metrics_button := _make_button("EXPORT PLAYTEST REPORT", 23, Vector2(650.0, 62.0))
	metrics_button.pressed.connect(func() -> void: export_metrics_requested.emit())
	box.add_child(metrics_button)
	var legal_row := HBoxContainer.new()
	legal_row.add_theme_constant_override("separation", 14)
	box.add_child(legal_row)
	var privacy_button := _make_button("PRIVACY", 22, Vector2(318.0, 58.0))
	privacy_button.name = "PrivacyButton"
	privacy_button.pressed.connect(func() -> void: privacy_requested.emit())
	legal_row.add_child(privacy_button)
	var support_button := _make_button("SUPPORT", 22, Vector2(318.0, 58.0))
	support_button.name = "SupportButton"
	support_button.pressed.connect(func() -> void: support_requested.emit())
	legal_row.add_child(support_button)
	var close_button := _make_button("DONE", 30, Vector2(650.0, 76.0))
	close_button.pressed.connect(hide_settings)
	box.add_child(close_button)
	settings_panel.visible = false


func _make_panel(panel_size: Vector2, panel_position: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = panel_position
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("08122a", 0.97)
	style.border_color = Color("5cecff", 0.8)
	style.set_border_width_all(3)
	style.set_corner_radius_all(34)
	style.content_margin_left = 48.0
	style.content_margin_right = 48.0
	style.content_margin_top = 38.0
	style.content_margin_bottom = 38.0
	style.shadow_color = Color("4df3ff", 0.16)
	style.shadow_size = 22
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _make_label(text_value: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("071123", 0.9))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _make_button(text_value: String, font_size: int, minimum_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = minimum_size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("eaffff"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.focus_mode = Control.FOCUS_NONE
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("102344", 0.92)
	normal.border_color = Color("55dff2", 0.7)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(22)
	var hover := normal.duplicate()
	hover.bg_color = Color("1b3c63", 0.98)
	hover.border_color = Color("8ffaff")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	return button


func show_ready(best_score: int, daily_best: int = 0, date_key: String = "") -> void:
	set_score(0, 1, best_score)
	title_label.visible = true
	prompt_label.visible = true
	ready_actions.visible = true
	var daily_button := ready_actions.get_node("DailyButton") as Button
	daily_button.text = "DAILY CHALLENGE  •  BEST %d\n%s UTC" % [daily_best, date_key]
	tutorial_label.visible = false
	tip_label.visible = false
	game_over_panel.visible = false
	pause_panel.visible = false
	settings_panel.visible = false
	pause_button.visible = false
	mode_label.text = ""


func show_running(show_tutorial: bool = false, is_daily: bool = false, date_key: String = "") -> void:
	title_label.visible = false
	prompt_label.visible = false
	ready_actions.visible = false
	tutorial_label.visible = show_tutorial
	game_over_panel.visible = false
	pause_panel.visible = false
	settings_panel.visible = false
	pause_button.visible = true
	mode_label.text = "DAILY  •  %s UTC" % date_key if is_daily else "CLASSIC"


func show_game_over(summary: Dictionary) -> void:
	title_label.visible = false
	prompt_label.visible = false
	ready_actions.visible = false
	tutorial_label.visible = false
	tip_label.visible = false
	new_best_label.visible = bool(summary.get("new_best", false))
	failure_label.text = String(summary.get("failure_reason", "SIGNAL LOST"))
	final_score_label.text = "SCORE %d   •   BEST %d" % [int(summary.get("score", 0)), int(summary.get("best_score", 0))]
	stats_label.text = "LANDINGS %d   •   PERFECT %d\nMAX COMBO %dx" % [int(summary.get("landings", 0)), int(summary.get("perfect_landings", 0)), int(summary.get("highest_combo", 1))]
	var unlocks: PackedStringArray = summary.get("new_unlocks", PackedStringArray())
	unlock_label.text = "UNLOCKED: %s" % ", ".join(unlocks).to_upper() if not unlocks.is_empty() else ""
	share_status_label.text = ""
	game_over_panel.visible = true
	pause_panel.visible = false
	settings_panel.visible = false
	pause_button.visible = false


func show_pause() -> void:
	pause_panel.visible = true
	pause_button.visible = false


func hide_pause() -> void:
	pause_panel.visible = false
	pause_button.visible = true


func show_settings() -> void:
	settings_return_to_pause = pause_panel.visible
	settings_panel.visible = true
	pause_panel.visible = false


func hide_settings() -> void:
	settings_panel.visible = false
	if settings_return_to_pause:
		pause_panel.visible = true
	settings_return_to_pause = false


func update_settings(profile: Dictionary) -> void:
	for key in ["sound_enabled", "music_enabled", "haptics_enabled", "reduced_motion", "reduced_screen_shake", "high_contrast"]:
		(settings_controls[key] as CheckButton).button_pressed = bool(profile[key])
	var guide_names := ["OFF", "TUTORIAL", "ALWAYS"]
	(settings_controls.guide_mode as Button).text = "GUIDE: %s" % guide_names[clampi(int(profile.guide_mode), 0, 2)]
	loadout_buttons.ship.text = "SHIP: %s" % CosmeticCatalog.find_item(CosmeticCatalog.SHIP_COLORS, String(profile.selected_ship_color)).name
	loadout_buttons.trail.text = "TRAIL: %s" % CosmeticCatalog.find_item(CosmeticCatalog.TRAILS, String(profile.selected_trail)).name
	loadout_buttons.theme.text = "PLANETS: %s" % CosmeticCatalog.find_item(CosmeticCatalog.PLANET_THEMES, String(profile.selected_planet_theme)).name


func set_tutorial_visible(value: bool) -> void:
	tutorial_label.visible = value


func set_score(score: int, combo: int, best_score: int) -> void:
	score_label.text = str(score)
	best_label.text = "BEST %d" % best_score
	combo_label.text = "%dx COMBO" % combo if combo > 1 else ""


func show_tip(text_value: String, duration: float = 2.4) -> void:
	if tip_tween and tip_tween.is_valid():
		tip_tween.kill()
	tip_label.text = text_value
	tip_label.modulate.a = 1.0
	tip_label.visible = true
	tip_tween = create_tween()
	tip_tween.tween_interval(duration)
	tip_tween.tween_property(tip_label, "modulate:a", 0.0, 0.35)
	tip_tween.tween_callback(func() -> void: tip_label.visible = false)


func show_share_status(path: String) -> void:
	share_status_label.text = "SCORE CARD SAVED\n%s" % path


func flash(color: Color, strength: float = 0.35) -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	flash_rect.color = Color(color, strength)
	flash_tween = create_tween()
	flash_tween.tween_property(flash_rect, "color:a", 0.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _apply_safe_area() -> void:
	var viewport_size := get_viewport_rect().size
	var safe_rect := DisplayServer.get_display_safe_area()
	var screen_size := DisplayServer.screen_get_size()
	if (OS.get_name() == "iOS" or OS.get_name() == "Android") and safe_rect.size.x > 0 and safe_rect.size.y > 0 and screen_size.x > 0 and screen_size.y > 0:
		var scale_x := viewport_size.x / float(screen_size.x)
		var scale_y := viewport_size.y / float(screen_size.y)
		safe_padding.x = maxf(54.0, float(safe_rect.position.x) * scale_x + 28.0)
		safe_padding.y = maxf(72.0, float(safe_rect.position.y) * scale_y + 28.0)
		safe_padding.z = maxf(54.0, float(screen_size.x - safe_rect.end.x) * scale_x + 28.0)
		safe_padding.w = maxf(54.0, float(screen_size.y - safe_rect.end.y) * scale_y + 28.0)
	var top_row := get_node_or_null("TopRow") as HBoxContainer
	if top_row:
		top_row.offset_left = safe_padding.x
		top_row.offset_top = safe_padding.y
		top_row.offset_right = -safe_padding.z
		top_row.offset_bottom = safe_padding.y + 110.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_apply_safe_area()
