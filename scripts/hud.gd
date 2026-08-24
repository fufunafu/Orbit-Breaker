class_name OrbitHUD
extends Control

signal classic_requested
signal daily_requested
signal replay_requested
signal share_requested
signal pause_requested
signal resume_requested
signal restart_requested
signal menu_requested
signal leaderboards_requested
signal setting_changed(key: String, value: Variant)
signal cosmetic_cycle_requested(category: String)
signal cosmetic_selected_requested(category: String, item_id: String)
signal export_metrics_requested
signal privacy_requested
signal support_requested
signal ui_sound_requested

const GUIDE_MODE_NAMES := ["OFF", "TUTORIAL", "ALWAYS"]

var score_label: Label
var best_label: Label
var combo_label: Label
var mode_label: Label
var menu_scrim: TextureRect
var title_label: Label
var prompt_label: Label
var classic_menu_button: Button
var daily_menu_button: Button
var loadout_menu_button: Button
var tutorial_label: Label
var tip_label: Label
var zone_banner: Control
var zone_banner_label: Label
var zone_banner_bar: ColorRect
var ready_actions: Control
var game_over_panel: PanelContainer
var game_over_title: Label
var new_best_label: Label
var failure_label: Label
var final_score_label: Label
var stats_label: Label
var unlock_label: Label
var share_status_label: Label
var pause_button: Button
var pause_panel: PanelContainer
var pause_card: PanelContainer
var settings_panel: PanelContainer
var settings_card: PanelContainer
var settings_done_button: Button
var loadout_panel: PanelContainer
var loadout_card: PanelContainer
var loadout_done_button: Button
var settings_controls: Dictionary = {}
var loadout_buttons: Dictionary = {}
var flash_rect: ColorRect
var flash_tween: Tween
var tip_tween: Tween
var combo_tween: Tween
var banner_tween: Tween
var top_row: Control
var reduced_motion: bool = false
var settings_return_to_pause: bool = false
var settings_return_to_ready: bool = false
var safe_padding := Vector4(54.0, 72.0, 54.0, 54.0)
var _last_combo: int = 1
var _running: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_interface()
	_apply_safe_area()


func _build_interface() -> void:
	# The flash sits beneath every panel so a failure flash tints the world,
	# never the run summary.
	flash_rect = ColorRect.new()
	flash_rect.name = "Flash"
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	add_child(flash_rect)
	_build_menu_backdrop()
	_build_top_row()
	_build_ready_actions()
	_build_tutorial()
	_build_zone_banner()
	_build_game_over()
	_build_pause()
	_build_settings()
	_build_loadout()


func _build_menu_backdrop() -> void:
	menu_scrim = TextureRect.new()
	menu_scrim.name = "MenuScrim"
	menu_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_scrim.stretch_mode = TextureRect.STRETCH_SCALE
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("1a1038", 0.62), Color("070812", 0.30)])
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	menu_scrim.texture = gradient_texture
	add_child(menu_scrim)


func _build_top_row() -> void:
	var row := HBoxContainer.new()
	row.name = "TopRow"
	row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	top_row = row
	var score_block := VBoxContainer.new()
	score_block.add_theme_constant_override("separation", 0)
	score_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_block.custom_minimum_size = Vector2(300.0, 0.0)
	row.add_child(score_block)
	score_label = OrbitUIKit.label("0", OrbitUIKit.SCORE, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_LEFT, true)
	score_label.custom_minimum_size = Vector2(0.0, 112.0)
	score_block.add_child(score_label)
	best_label = OrbitUIKit.label("BEST 0", OrbitUIKit.CAPTION, OrbitUIKit.ACCENT_SOFT, HORIZONTAL_ALIGNMENT_LEFT)
	best_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	score_block.add_child(best_label)
	mode_label = OrbitUIKit.label("", OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	score_block.add_child(mode_label)
	combo_label = OrbitUIKit.label("", 68, OrbitUIKit.PERFECT, HORIZONTAL_ALIGNMENT_CENTER, true)
	combo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	combo_label.custom_minimum_size = Vector2(0.0, OrbitUIKit.PAUSE_BUTTON_SIZE)
	row.add_child(combo_label)
	pause_button = _make_pause_button()
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	row.add_child(pause_button)


func _make_pause_button() -> Button:
	var button := Button.new()
	button.name = "PauseButton"
	button.text = ""
	button.tooltip_text = "Pause"
	button.custom_minimum_size = Vector2(OrbitUIKit.PAUSE_BUTTON_SIZE, OrbitUIKit.PAUSE_BUTTON_SIZE)
	button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	button.focus_mode = Control.FOCUS_ALL
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(OrbitUIKit.FIELD, 0.88)
	normal.border_color = Color(OrbitUIKit.ACCENT, 0.7)
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(int(OrbitUIKit.PAUSE_BUTTON_SIZE * 0.5))
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("1b3c63", 0.98)
	hover.border_color = Color("8ffaff")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = OrbitUIKit.INK
	bar_style.set_corner_radius_all(4)
	for bar_index in 2:
		var bar := Panel.new()
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.set_anchors_preset(Control.PRESET_CENTER)
		bar.size = Vector2(14.0, 44.0)
		bar.position = Vector2(-20.0 + float(bar_index) * 26.0, -22.0)
		bar.add_theme_stylebox_override("panel", bar_style)
		button.add_child(bar)
	button.pressed.connect(func() -> void: ui_sound_requested.emit())
	return button


func _build_ready_actions() -> void:
	ready_actions = PanelContainer.new()
	ready_actions.name = "ReadyActions"
	ready_actions.set_anchors_preset(Control.PRESET_TOP_WIDE)
	ready_actions.offset_left = 90.0
	ready_actions.offset_right = -90.0
	ready_actions.offset_top = 300.0
	ready_actions.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := OrbitUIKit.card_style(0.96)
	panel_style.content_margin_left = 48.0
	panel_style.content_margin_right = 48.0
	panel_style.content_margin_top = 44.0
	panel_style.content_margin_bottom = 28.0
	ready_actions.add_theme_stylebox_override("panel", panel_style)
	add_child(ready_actions)
	var menu_content := VBoxContainer.new()
	menu_content.add_theme_constant_override("separation", 18)
	ready_actions.add_child(menu_content)
	title_label = OrbitUIKit.label("ORBIT BREAKER", 80, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true)
	title_label.custom_minimum_size = Vector2(0.0, 120.0)
	menu_content.add_child(title_label)
	prompt_label = OrbitUIKit.label("ONE TAP. PERFECT TIMING.", OrbitUIKit.CAPTION, OrbitUIKit.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	prompt_label.custom_minimum_size = Vector2(0.0, 60.0)
	menu_content.add_child(prompt_label)
	classic_menu_button = _make_panel_menu_button("CLASSIC RUN", "TAP TO START", "", "primary")
	classic_menu_button.name = "ClassicButton"
	classic_menu_button.custom_minimum_size = Vector2(0.0, 236.0)
	classic_menu_button.pressed.connect(func() -> void: classic_requested.emit())
	menu_content.add_child(classic_menu_button)
	daily_menu_button = _make_panel_menu_button("DAILY CHALLENGE", "", "BEST 0", "daily")
	daily_menu_button.name = "DailyButton"
	daily_menu_button.custom_minimum_size = Vector2(0.0, 196.0)
	daily_menu_button.pressed.connect(func() -> void: daily_requested.emit())
	menu_content.add_child(daily_menu_button)
	var utility_stack := VBoxContainer.new()
	utility_stack.add_theme_constant_override("separation", 0)
	menu_content.add_child(utility_stack)
	loadout_menu_button = _make_panel_menu_button("LOADOUT", "", "", "row")
	loadout_menu_button.name = "LoadoutButton"
	loadout_menu_button.custom_minimum_size = Vector2(0.0, 132.0)
	loadout_menu_button.pressed.connect(show_loadout)
	utility_stack.add_child(loadout_menu_button)
	var leaderboard_button := _make_panel_menu_button("LEADERBOARD", "", "GAME CENTER", "row")
	leaderboard_button.name = "LeaderboardButton"
	leaderboard_button.custom_minimum_size = Vector2(0.0, 132.0)
	leaderboard_button.pressed.connect(func() -> void: leaderboards_requested.emit())
	utility_stack.add_child(leaderboard_button)
	var settings_button := _make_panel_menu_button("SETTINGS", "", "›", "row")
	settings_button.name = "SettingsButton"
	settings_button.custom_minimum_size = Vector2(0.0, 132.0)
	settings_button.pressed.connect(show_settings)
	utility_stack.add_child(settings_button)


func _build_tutorial() -> void:
	tutorial_label = OrbitUIKit.label("WAIT FOR THE GUIDE TO TOUCH THE TARGET\nDOUBLE RING = PERFECT\nTHEN TAP TO LAUNCH", OrbitUIKit.BODY, Color("d6fdff"), HORIZONTAL_ALIGNMENT_CENTER)
	tutorial_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	tutorial_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tutorial_label.position = Vector2(-520.0, -360.0)
	tutorial_label.size = Vector2(1040.0, 220.0)
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.add_theme_constant_override("line_spacing", 10)
	tutorial_label.add_theme_color_override("font_shadow_color", Color("071123", 0.9))
	tutorial_label.add_theme_constant_override("shadow_offset_x", 3)
	tutorial_label.add_theme_constant_override("shadow_offset_y", 3)
	tutorial_label.visible = false
	add_child(tutorial_label)
	tip_label = OrbitUIKit.label("", OrbitUIKit.LABEL, Color("fff0b8"), HORIZONTAL_ALIGNMENT_CENTER)
	tip_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	tip_label.set_anchors_preset(Control.PRESET_CENTER)
	tip_label.position = Vector2(-480.0, 420.0)
	tip_label.size = Vector2(960.0, 160.0)
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_label.add_theme_color_override("font_shadow_color", Color("071123", 0.9))
	tip_label.add_theme_constant_override("shadow_offset_x", 3)
	tip_label.add_theme_constant_override("shadow_offset_y", 3)
	tip_label.visible = false
	add_child(tip_label)


func _build_zone_banner() -> void:
	zone_banner = Control.new()
	zone_banner.name = "ZoneBanner"
	zone_banner.set_anchors_preset(Control.PRESET_CENTER)
	zone_banner.position = Vector2(-500.0, -560.0)
	zone_banner.size = Vector2(1000.0, 260.0)
	zone_banner.pivot_offset = zone_banner.size * 0.5
	zone_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_banner.visible = false
	add_child(zone_banner)
	var eyebrow := OrbitUIKit.label("ENTERING", OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_CENTER, true)
	eyebrow.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	eyebrow.offset_bottom = 56.0
	eyebrow.add_theme_color_override("font_shadow_color", Color("071123", 0.9))
	eyebrow.add_theme_constant_override("shadow_offset_x", 3)
	eyebrow.add_theme_constant_override("shadow_offset_y", 3)
	zone_banner.add_child(eyebrow)
	zone_banner_label = OrbitUIKit.label("", OrbitUIKit.TITLE, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true)
	zone_banner_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	zone_banner_label.offset_top = 56.0
	zone_banner_label.offset_bottom = -48.0
	zone_banner_label.add_theme_color_override("font_shadow_color", Color("071123", 0.9))
	zone_banner_label.add_theme_constant_override("shadow_offset_x", 4)
	zone_banner_label.add_theme_constant_override("shadow_offset_y", 4)
	zone_banner.add_child(zone_banner_label)
	zone_banner_bar = ColorRect.new()
	zone_banner_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_banner_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	zone_banner_bar.size = Vector2(640.0, 8.0)
	zone_banner_bar.position = Vector2(-320.0, -32.0)
	zone_banner_bar.pivot_offset = Vector2(320.0, 4.0)
	zone_banner.add_child(zone_banner_bar)


func _build_game_over() -> void:
	game_over_panel = _make_centered_card(900.0)
	game_over_panel.name = "GameOverPanel"
	add_child(game_over_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	game_over_panel.add_child(box)
	new_best_label = OrbitUIKit.label("NEW BEST", OrbitUIKit.HEADING, OrbitUIKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER, true)
	new_best_label.custom_minimum_size = Vector2(0.0, 96.0)
	box.add_child(new_best_label)
	game_over_title = OrbitUIKit.label("SIGNAL LOST", OrbitUIKit.HEADING, Color("ff7194"), HORIZONTAL_ALIGNMENT_CENTER, true)
	game_over_title.custom_minimum_size = Vector2(0.0, 96.0)
	box.add_child(game_over_title)
	failure_label = OrbitUIKit.label("DRIFTED INTO SPACE", OrbitUIKit.CAPTION, Color("ffb0c1"), HORIZONTAL_ALIGNMENT_CENTER)
	failure_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	box.add_child(failure_label)
	box.add_child(_make_section_spacer(8.0))
	final_score_label = OrbitUIKit.label("SCORE 0", 64, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true)
	box.add_child(final_score_label)
	stats_label = OrbitUIKit.label("", OrbitUIKit.BODY, Color("bdefff"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(stats_label)
	unlock_label = OrbitUIKit.label("", OrbitUIKit.CAPTION, OrbitUIKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	unlock_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	unlock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(unlock_label)
	box.add_child(_make_section_spacer(8.0))
	var replay_button := OrbitUIKit.primary_button("REPLAY NOW")
	replay_button.name = "ReplayButton"
	replay_button.pressed.connect(func() -> void: replay_requested.emit())
	box.add_child(replay_button)
	var share_button := OrbitUIKit.secondary_button("SAVE SCORE CARD")
	share_button.name = "ShareButton"
	share_button.pressed.connect(func() -> void: share_requested.emit())
	box.add_child(share_button)
	var leaderboard_button := OrbitUIKit.secondary_button("LEADERBOARDS")
	leaderboard_button.pressed.connect(func() -> void: leaderboards_requested.emit())
	box.add_child(leaderboard_button)
	var menu_button := OrbitUIKit.secondary_button("MAIN MENU")
	menu_button.name = "MenuButton"
	menu_button.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(menu_button)
	share_status_label = OrbitUIKit.label("", OrbitUIKit.CAPTION, Color("8fffd4"), HORIZONTAL_ALIGNMENT_CENTER)
	share_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(share_status_label)
	for button in [replay_button, share_button, leaderboard_button, menu_button]:
		button.pressed.connect(func() -> void: ui_sound_requested.emit())
	game_over_panel.visible = false


func _build_pause() -> void:
	pause_panel = PanelContainer.new()
	pause_panel.name = "PausePanel"
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_panel.add_theme_stylebox_override("panel", OrbitUIKit.overlay_style())
	add_child(pause_panel)
	var stage := Control.new()
	pause_panel.add_child(stage)
	pause_card = _make_centered_card(800.0)
	stage.add_child(pause_card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	pause_card.add_child(box)
	var heading := OrbitUIKit.label("RUN PAUSED", OrbitUIKit.HEADING, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true)
	heading.custom_minimum_size = Vector2(0.0, 110.0)
	box.add_child(heading)
	var resume_button := OrbitUIKit.primary_button("RESUME")
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	box.add_child(resume_button)
	var restart_button := OrbitUIKit.secondary_button("RESTART")
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	box.add_child(restart_button)
	var settings_button := OrbitUIKit.secondary_button("SETTINGS")
	settings_button.pressed.connect(show_settings)
	box.add_child(settings_button)
	var menu_button := OrbitUIKit.secondary_button("MAIN MENU")
	menu_button.name = "MenuButton"
	menu_button.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(menu_button)
	for button in [resume_button, restart_button, settings_button, menu_button]:
		button.pressed.connect(func() -> void: ui_sound_requested.emit())
	pause_panel.visible = false


func _build_settings() -> void:
	var built := _build_overlay_sheet("SettingsPanel", "SETTINGS", "SettingsDoneButton", hide_settings)
	settings_panel = built.panel
	settings_card = built.card
	settings_done_button = built.done
	var body: VBoxContainer = built.body
	body.add_child(_make_section_label("AUDIO & FEEL"))
	for setting in [
		["sound_enabled", "Sound"],
		["music_enabled", "Music"],
		["haptics_enabled", "Haptics"],
	]:
		var check := _make_setting_toggle(String(setting[1]))
		var key := String(setting[0])
		check.toggled.connect(func(value: bool) -> void: setting_changed.emit(key, value))
		settings_controls[key] = check
		body.add_child(check)
	body.add_child(_make_section_spacer())
	body.add_child(_make_section_label("ACCESSIBILITY"))
	for setting in [
		["reduced_motion", "Reduced motion"],
		["reduced_screen_shake", "Reduced screen shake"],
		["high_contrast", "High contrast guide"],
	]:
		var check := _make_setting_toggle(String(setting[1]))
		var key := String(setting[0])
		check.toggled.connect(func(value: bool) -> void: setting_changed.emit(key, value))
		settings_controls[key] = check
		body.add_child(check)
	body.add_child(_make_section_spacer())
	body.add_child(_make_section_label("TRAJECTORY GUIDE"))
	var guide_row := HBoxContainer.new()
	guide_row.name = "GuideModeControl"
	guide_row.add_theme_constant_override("separation", 12)
	var guide_group := ButtonGroup.new()
	var guide_buttons: Array[Button] = []
	for mode_index in GUIDE_MODE_NAMES.size():
		var option := _make_segment_button(String(GUIDE_MODE_NAMES[mode_index]))
		option.name = "GuideMode%s" % String(GUIDE_MODE_NAMES[mode_index]).capitalize()
		option.button_group = guide_group
		option.pressed.connect(func() -> void: setting_changed.emit("guide_mode", mode_index))
		guide_buttons.append(option)
		guide_row.add_child(option)
	settings_controls.guide_mode = guide_row
	settings_controls.guide_buttons = guide_buttons
	body.add_child(guide_row)
	var guide_help := OrbitUIKit.label("Tutorial shows the guide for your first three landings. Always keeps it on.", OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	guide_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(guide_help)
	body.add_child(_make_section_spacer())
	body.add_child(_make_section_label("MORE"))
	var metrics_button := _make_link_button("EXPORT GAMEPLAY STATS")
	metrics_button.name = "StatsButton"
	metrics_button.pressed.connect(func() -> void: export_metrics_requested.emit())
	body.add_child(metrics_button)
	var privacy_button := _make_link_button("PRIVACY POLICY")
	privacy_button.name = "PrivacyButton"
	privacy_button.pressed.connect(func() -> void: privacy_requested.emit())
	body.add_child(privacy_button)
	var support_button := _make_link_button("SUPPORT")
	support_button.name = "SupportButton"
	support_button.pressed.connect(func() -> void: support_requested.emit())
	body.add_child(support_button)
	settings_panel.visible = false


func _build_loadout() -> void:
	var built := _build_overlay_sheet("LoadoutPanel", "LOADOUT", "LoadoutDoneButton", hide_loadout)
	loadout_panel = built.panel
	loadout_card = built.card
	loadout_done_button = built.done
	var body: VBoxContainer = built.body
	_add_loadout_group(body, "ship", "SHIP", CosmeticCatalog.SHIP_COLORS)
	body.add_child(_make_section_spacer())
	_add_loadout_group(body, "trail", "TRAIL", CosmeticCatalog.TRAILS)
	body.add_child(_make_section_spacer())
	_add_loadout_group(body, "theme", "PLANETS", CosmeticCatalog.PLANET_THEMES)
	loadout_panel.visible = false


## Builds a full-screen overlay with a titled card and a prominent Done pill
## beneath it. Returns {panel, card, body, done}.
func _build_overlay_sheet(panel_name: String, title_text: String, done_name: String, on_done: Callable) -> Dictionary:
	var panel := PanelContainer.new()
	panel.name = panel_name
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", OrbitUIKit.overlay_style())
	add_child(panel)
	var stage := Control.new()
	panel.add_child(stage)
	var card := PanelContainer.new()
	card.name = "%sCard" % panel_name.trim_suffix("Panel")
	card.add_theme_stylebox_override("panel", OrbitUIKit.card_style(0.985))
	stage.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	card.add_child(box)
	var header_margin := MarginContainer.new()
	header_margin.custom_minimum_size = Vector2(0.0, 132.0)
	header_margin.add_theme_constant_override("margin_left", 56)
	header_margin.add_theme_constant_override("margin_right", 56)
	box.add_child(header_margin)
	var title := OrbitUIKit.label(title_text, OrbitUIKit.HEADING, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_LEFT, true)
	header_margin.add_child(title)
	box.add_child(_make_separator(OrbitUIKit.CARD_LINE, 2.0))
	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(scroll)
	var body_margin := MarginContainer.new()
	body_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_margin.add_theme_constant_override("margin_left", 56)
	body_margin.add_theme_constant_override("margin_right", 56)
	body_margin.add_theme_constant_override("margin_top", 36)
	body_margin.add_theme_constant_override("margin_bottom", 36)
	scroll.add_child(body_margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body_margin.add_child(body)
	var done := OrbitUIKit.primary_button("DONE")
	done.name = done_name
	done.pressed.connect(on_done)
	done.pressed.connect(func() -> void: ui_sound_requested.emit())
	stage.add_child(done)
	return {"panel": panel, "card": card, "body": body, "done": done}


func _add_loadout_group(parent: VBoxContainer, category: String, label_text: String, items: Array) -> void:
	parent.add_child(_make_section_label(label_text))
	var category_buttons: Dictionary = {}
	for item in items:
		var item_id := String(item.id)
		var button := _make_loadout_option_button(String(item.name), String(item.hint))
		button.name = "%sOption%s" % [category.capitalize(), item_id.capitalize()]
		button.pressed.connect(func() -> void: cosmetic_selected_requested.emit(category, item_id))
		category_buttons[item_id] = button
		parent.add_child(button)
	loadout_buttons[category] = category_buttons


func _make_centered_card(width: float) -> PanelContainer:
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	card.grow_vertical = Control.GROW_DIRECTION_BOTH
	card.custom_minimum_size = Vector2(width, 0.0)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := OrbitUIKit.card_style()
	style.content_margin_left = 44.0
	style.content_margin_right = 44.0
	style.content_margin_top = 40.0
	style.content_margin_bottom = 40.0
	card.add_theme_stylebox_override("panel", style)
	return card


func _make_section_label(text_value: String) -> Label:
	var result := OrbitUIKit.label(text_value, OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_LEFT, true)
	result.custom_minimum_size = Vector2(0.0, 56.0)
	return result


func _make_section_spacer(height: float = 20.0) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _make_separator(color: Color, height: float) -> ColorRect:
	var separator := ColorRect.new()
	separator.color = color
	separator.custom_minimum_size = Vector2(0.0, height)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return separator


func _make_setting_toggle(text_value: String) -> CheckButton:
	var check := CheckButton.new()
	check.text = text_value
	check.custom_minimum_size = Vector2(0.0, OrbitUIKit.CONTROL_HEIGHT)
	check.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	check.add_theme_font_size_override("font_size", OrbitUIKit.BODY)
	check.add_theme_color_override("font_color", Color("dbe5fa"))
	check.add_theme_color_override("font_hover_color", Color("ffffff"))
	check.add_theme_color_override("font_pressed_color", Color("ffffff"))
	check.add_theme_color_override("font_hover_pressed_color", Color("ffffff"))
	check.add_theme_color_override("font_focus_color", Color("ffffff"))
	check.focus_mode = Control.FOCUS_ALL
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color.TRANSPARENT
	normal.border_color = Color("173951")
	normal.border_width_bottom = 2
	normal.content_margin_left = 0.0
	normal.content_margin_right = 140.0
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("102641", 0.64)
	check.add_theme_stylebox_override("normal", normal)
	check.add_theme_stylebox_override("hover", hover)
	check.add_theme_stylebox_override("pressed", normal)
	check.add_theme_stylebox_override("hover_pressed", hover)
	check.add_theme_stylebox_override("focus", hover)
	var blank_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	blank_image.fill(Color.TRANSPARENT)
	var blank_texture := ImageTexture.create_from_image(blank_image)
	for icon_name in ["checked", "checked_disabled", "checked_mirrored", "unchecked", "unchecked_disabled", "unchecked_mirrored"]:
		check.add_theme_icon_override(icon_name, blank_texture)
	var track := Panel.new()
	track.name = "ToggleTrack"
	track.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	track.position = Vector2(-118.0, -33.0)
	track.size = Vector2(112.0, 66.0)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	check.add_child(track)
	var knob := Panel.new()
	knob.name = "Knob"
	knob.position = Vector2(8.0, 8.0)
	knob.size = Vector2(50.0, 50.0)
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(knob)
	check.toggled.connect(func(value: bool) -> void: _sync_toggle_visual(check, value))
	check.pressed.connect(func() -> void: ui_sound_requested.emit())
	_sync_toggle_visual(check, false)
	return check


func _sync_toggle_visual(check: CheckButton, value: bool) -> void:
	var track := check.get_node("ToggleTrack") as Panel
	var knob := track.get_node("Knob") as Panel
	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color("3ed6ed") if value else Color("243753")
	track_style.border_color = Color("6af0ff") if value else Color("455b78")
	track_style.set_border_width_all(2)
	track_style.set_corner_radius_all(33)
	track.add_theme_stylebox_override("panel", track_style)
	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color = Color("082036") if value else Color("8295b3")
	knob_style.set_corner_radius_all(25)
	knob.add_theme_stylebox_override("panel", knob_style)
	knob.position.x = 54.0 if value else 8.0


func _make_segment_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0.0, OrbitUIKit.CONTROL_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_override("font", OrbitUIKit.display_font())
	button.add_theme_font_size_override("font_size", OrbitUIKit.CAPTION)
	button.add_theme_color_override("font_color", OrbitUIKit.INK_MUTED)
	button.add_theme_color_override("font_hover_color", OrbitUIKit.INK)
	button.add_theme_color_override("font_pressed_color", OrbitUIKit.ACCENT_INK)
	button.add_theme_color_override("font_hover_pressed_color", OrbitUIKit.ACCENT_INK)
	button.add_theme_color_override("font_focus_color", OrbitUIKit.INK)
	button.focus_mode = Control.FOCUS_ALL
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("09162b", 0.58)
	normal.border_color = OrbitUIKit.FIELD_LINE
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(OrbitUIKit.RADIUS)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("112d48", 0.9)
	var selected := StyleBoxFlat.new()
	selected.bg_color = OrbitUIKit.ACCENT
	selected.set_corner_radius_all(OrbitUIKit.RADIUS)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", selected)
	button.add_theme_stylebox_override("hover_pressed", selected)
	button.pressed.connect(func() -> void: ui_sound_requested.emit())
	return button


func _make_link_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0.0, OrbitUIKit.CONTROL_HEIGHT)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	button.add_theme_font_size_override("font_size", OrbitUIKit.BODY)
	button.add_theme_color_override("font_color", OrbitUIKit.ACCENT_SOFT)
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("ffffff"))
	button.add_theme_color_override("font_focus_color", Color("ffffff"))
	button.focus_mode = Control.FOCUS_ALL
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color.TRANSPARENT
	normal.border_color = Color("173951")
	normal.border_width_bottom = 2
	normal.content_margin_left = 0.0
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("102641", 0.64)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	var chevron := OrbitUIKit.label("›", OrbitUIKit.LABEL, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_RIGHT, true)
	chevron.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chevron.offset_right = -8.0
	button.add_child(chevron)
	button.pressed.connect(func() -> void: ui_sound_requested.emit())
	return button


func _make_loadout_option_button(text_value: String, hint_text: String) -> Button:
	var button := Button.new()
	button.text = ""
	button.toggle_mode = true
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.custom_minimum_size = Vector2(0.0, 156.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.clip_contents = true
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("0d1d36", 0.9)
	normal.border_color = OrbitUIKit.FIELD_LINE
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(OrbitUIKit.RADIUS)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("112d48", 0.95)
	hover.border_color = Color("4ccce1")
	var selected := normal.duplicate() as StyleBoxFlat
	selected.bg_color = Color("17415a", 0.98)
	selected.border_color = Color("4ce7fb")
	selected.set_border_width_all(3)
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color("050b18", 0.75)
	disabled.border_color = Color("1a2638")
	disabled.set_border_width_all(2)
	disabled.set_corner_radius_all(OrbitUIKit.RADIUS)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", selected)
	button.add_theme_stylebox_override("hover_pressed", selected)
	button.add_theme_stylebox_override("disabled", disabled)
	var name_label := OrbitUIKit.label(text_value, OrbitUIKit.LABEL, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_LEFT, true)
	name_label.name = "Name"
	name_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	name_label.offset_left = 32.0
	name_label.offset_top = 18.0
	name_label.offset_right = -32.0
	name_label.offset_bottom = -66.0
	button.add_child(name_label)
	var status_label := OrbitUIKit.label("", OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	status_label.name = "Status"
	status_label.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	status_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_label.offset_left = 32.0
	status_label.offset_top = 78.0
	status_label.offset_right = -32.0
	status_label.offset_bottom = -14.0
	button.add_child(status_label)
	button.set_meta("hint", hint_text)
	button.pressed.connect(func() -> void: ui_sound_requested.emit())
	_sync_loadout_option_visual(button, false, true)
	return button


func _sync_loadout_option_visual(button: Button, selected: bool, unlocked: bool) -> void:
	var name_label := button.get_node("Name") as Label
	var status_label := button.get_node("Status") as Label
	var hint := String(button.get_meta("hint", ""))
	if not unlocked:
		name_label.add_theme_color_override("font_color", OrbitUIKit.INK_FAINT)
		status_label.add_theme_color_override("font_color", OrbitUIKit.INK_FAINT)
		status_label.text = "LOCKED · %s" % hint if not hint.is_empty() else "LOCKED"
	elif selected:
		name_label.add_theme_color_override("font_color", Color("a8f6ff"))
		status_label.add_theme_color_override("font_color", OrbitUIKit.ACCENT)
		status_label.text = "EQUIPPED"
	else:
		name_label.add_theme_color_override("font_color", OrbitUIKit.INK)
		status_label.add_theme_color_override("font_color", OrbitUIKit.INK_MUTED)
		status_label.text = "TAP TO EQUIP"


func _layout_overlays() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	if ready_actions:
		ready_actions.offset_top = maxf(safe_padding.y + 150.0, viewport_size.y * 0.10)
	for sheet in [[settings_card, settings_done_button], [loadout_card, loadout_done_button]]:
		var card := sheet[0] as PanelContainer
		var done := sheet[1] as Button
		if card == null or done == null:
			continue
		var width := minf(900.0, viewport_size.x - safe_padding.x - safe_padding.z)
		var done_height := OrbitUIKit.CONTROL_HEIGHT
		var done_y := viewport_size.y - safe_padding.w - done_height
		var card_y := maxf(safe_padding.y + 24.0, viewport_size.y * 0.06)
		var card_height := done_y - 36.0 - card_y
		card.size = Vector2(width, card_height)
		card.position = Vector2((viewport_size.x - width) * 0.5, card_y)
		done.size = Vector2(width, done_height)
		done.position = Vector2((viewport_size.x - width) * 0.5, done_y)


func _make_panel_menu_button(title_text: String, eyebrow_text: String, meta_text: String, variant: String) -> Button:
	var button := Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_ALL
	button.clip_contents = true
	var normal := StyleBoxFlat.new()
	match variant:
		"primary":
			normal.bg_color = OrbitUIKit.ACCENT
			normal.set_corner_radius_all(OrbitUIKit.RADIUS)
			normal.shadow_color = Color("42dbf2", 0.3)
			normal.shadow_size = 22
		"daily":
			normal.bg_color = Color("0d1930", 0.98)
			normal.border_color = OrbitUIKit.DAILY
			normal.set_border_width_all(3)
			normal.set_corner_radius_all(OrbitUIKit.RADIUS)
		_:
			normal.bg_color = Color("0a1930", 0.02)
			normal.border_color = Color("24506a")
			normal.border_width_top = 2
	var hover := normal.duplicate() as StyleBoxFlat
	var pressed := normal.duplicate() as StyleBoxFlat
	match variant:
		"primary":
			hover.bg_color = Color("5cdef4")
			pressed.bg_color = Color("2bb3d0")
		"daily":
			hover.bg_color = Color("142442", 0.99)
			pressed.bg_color = Color("091326", 0.99)
		_:
			hover.bg_color = Color("11223d", 0.92)
			pressed.bg_color = Color("071225", 0.98)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	if variant == "primary":
		var eyebrow := OrbitUIKit.label(eyebrow_text, OrbitUIKit.CAPTION, Color("0e4d63"), HORIZONTAL_ALIGNMENT_LEFT)
		eyebrow.name = "Eyebrow"
		eyebrow.add_theme_font_override("font", OrbitUIKit.body_bold_font())
		eyebrow.set_anchors_preset(Control.PRESET_TOP_WIDE)
		eyebrow.offset_left = 44.0
		eyebrow.offset_top = 30.0
		eyebrow.offset_right = -130.0
		eyebrow.offset_bottom = 84.0
		button.add_child(eyebrow)
		var title := OrbitUIKit.label(title_text, 64, OrbitUIKit.ACCENT_INK, HORIZONTAL_ALIGNMENT_LEFT, true)
		title.set_anchors_preset(Control.PRESET_FULL_RECT)
		title.offset_left = 44.0
		title.offset_top = 72.0
		title.offset_right = -150.0
		title.offset_bottom = -24.0
		button.add_child(title)
		var arrow := OrbitUIKit.label("→", 64, OrbitUIKit.ACCENT_INK, HORIZONTAL_ALIGNMENT_CENTER, true)
		arrow.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		arrow.position = Vector2(-130.0, -52.0)
		arrow.size = Vector2(100.0, 104.0)
		button.add_child(arrow)
	elif variant == "daily":
		var title := OrbitUIKit.label(title_text, OrbitUIKit.LABEL, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_LEFT, true)
		title.set_anchors_preset(Control.PRESET_FULL_RECT)
		title.offset_left = 44.0
		title.offset_top = 16.0
		title.offset_right = -44.0
		title.offset_bottom = -70.0
		button.add_child(title)
		var sub := OrbitUIKit.label(eyebrow_text, OrbitUIKit.CAPTION, Color("b58bd4"), HORIZONTAL_ALIGNMENT_LEFT)
		sub.name = "Sub"
		sub.add_theme_font_override("font", OrbitUIKit.body_bold_font())
		sub.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		sub.offset_left = 44.0
		sub.offset_top = -82.0
		sub.offset_right = -300.0
		sub.offset_bottom = -22.0
		button.add_child(sub)
		var meta := OrbitUIKit.label(meta_text, OrbitUIKit.CAPTION, OrbitUIKit.DAILY, HORIZONTAL_ALIGNMENT_RIGHT, true)
		meta.name = "Meta"
		meta.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		meta.offset_left = -300.0
		meta.offset_top = -82.0
		meta.offset_right = -44.0
		meta.offset_bottom = -22.0
		button.add_child(meta)
	else:
		var title := OrbitUIKit.label(title_text, OrbitUIKit.LABEL, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_LEFT, true)
		title.set_anchors_preset(Control.PRESET_FULL_RECT)
		title.offset_left = 12.0
		title.offset_top = 0.0
		title.offset_right = -330.0
		title.offset_bottom = 0.0
		button.add_child(title)
		var meta := OrbitUIKit.label(meta_text, OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
		meta.name = "Meta"
		meta.add_theme_font_override("font", OrbitUIKit.body_bold_font())
		meta.set_anchors_preset(Control.PRESET_FULL_RECT)
		meta.offset_left = 330.0
		meta.offset_top = 0.0
		meta.offset_right = -12.0
		meta.offset_bottom = 0.0
		button.add_child(meta)
	button.pressed.connect(func() -> void: ui_sound_requested.emit())
	return button


func show_ready(best_score: int, daily_best: int = 0, date_key: String = "") -> void:
	_running = false
	set_score(0, 1, best_score)
	menu_scrim.visible = true
	ready_actions.visible = true
	(classic_menu_button.get_node("Eyebrow") as Label).text = "BEST %d  ·  TAP TO START" % best_score if best_score > 0 else "TAP TO START"
	(daily_menu_button.get_node("Sub") as Label).text = "TODAY  ·  %s UTC" % _format_daily_date(date_key)
	(daily_menu_button.get_node("Meta") as Label).text = "BEST %d" % daily_best
	tutorial_label.visible = false
	tip_label.visible = false
	zone_banner.visible = false
	game_over_panel.visible = false
	pause_panel.visible = false
	settings_panel.visible = false
	loadout_panel.visible = false
	pause_button.visible = false
	top_row.visible = false
	mode_label.text = ""


func show_running(show_tutorial: bool = false, is_daily: bool = false, date_key: String = "") -> void:
	_running = true
	menu_scrim.visible = false
	ready_actions.visible = false
	tutorial_label.visible = show_tutorial
	game_over_panel.visible = false
	pause_panel.visible = false
	settings_panel.visible = false
	loadout_panel.visible = false
	pause_button.visible = true
	top_row.visible = true
	mode_label.text = "DAILY  ·  %s UTC" % _format_daily_date(date_key) if is_daily else "CLASSIC"


func show_game_over(summary: Dictionary) -> void:
	_running = false
	menu_scrim.visible = false
	ready_actions.visible = false
	tutorial_label.visible = false
	tip_label.visible = false
	zone_banner.visible = false
	var new_best := bool(summary.get("new_best", false))
	# A new personal best owns the headline; the cause of the failure drops
	# to the subtitle. Otherwise the failure is the headline.
	new_best_label.visible = new_best
	game_over_title.visible = not new_best
	failure_label.text = String(summary.get("failure_reason", "SIGNAL LOST"))
	final_score_label.text = "SCORE %d   •   BEST %d" % [int(summary.get("score", 0)), int(summary.get("best_score", 0))]
	stats_label.text = "LANDINGS %d   •   PERFECT %d\nMAX COMBO %dx" % [int(summary.get("landings", 0)), int(summary.get("perfect_landings", 0)), int(summary.get("highest_combo", 1))]
	var unlocks: PackedStringArray = summary.get("new_unlocks", PackedStringArray())
	unlock_label.text = _describe_unlocks(unlocks)
	unlock_label.visible = not unlock_label.text.is_empty()
	share_status_label.text = ""
	game_over_panel.visible = true
	pause_panel.visible = false
	settings_panel.visible = false
	loadout_panel.visible = false
	pause_button.visible = false
	top_row.visible = false


func _describe_unlocks(unlocks: PackedStringArray) -> String:
	if unlocks.is_empty():
		return ""
	var grouped := CosmeticCatalog.describe_unlocks(unlocks)
	var lines := PackedStringArray()
	for category in ["ship", "trail", "theme"]:
		if grouped.has(category):
			var names: PackedStringArray = grouped[category]
			lines.append("NEW %s  ·  %s" % [String(CosmeticCatalog.CATEGORY_TITLES[category]), "  /  ".join(names)])
	return "\n".join(lines)


func _format_daily_date(date_key: String) -> String:
	var parts := date_key.split("-")
	if parts.size() != 3:
		return date_key
	var months := ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
	var month_index := clampi(int(parts[1]) - 1, 0, months.size() - 1)
	return "%s %d" % [months[month_index], int(parts[2])]


func show_pause() -> void:
	pause_panel.visible = true
	pause_button.visible = false
	top_row.visible = false


func hide_pause() -> void:
	pause_panel.visible = false
	pause_button.visible = true
	top_row.visible = _running


func overlay_open() -> bool:
	return settings_panel.visible or loadout_panel.visible


func show_settings() -> void:
	_open_sheet(settings_panel)


func hide_settings() -> void:
	_close_sheet(settings_panel)


func show_loadout() -> void:
	_open_sheet(loadout_panel)


func hide_loadout() -> void:
	_close_sheet(loadout_panel)


func _open_sheet(sheet: PanelContainer) -> void:
	if not overlay_open():
		settings_return_to_pause = pause_panel.visible
		settings_return_to_ready = ready_actions.visible
	ready_actions.visible = false
	pause_panel.visible = false
	settings_panel.visible = sheet == settings_panel
	loadout_panel.visible = sheet == loadout_panel
	top_row.visible = false
	(sheet.find_child("Scroll", true, false) as ScrollContainer).scroll_vertical = 0


func _close_sheet(sheet: PanelContainer) -> void:
	sheet.visible = false
	if overlay_open():
		return
	if settings_return_to_pause:
		pause_panel.visible = true
	elif settings_return_to_ready:
		ready_actions.visible = true
	else:
		top_row.visible = _running
	settings_return_to_pause = false
	settings_return_to_ready = false


func update_settings(profile: Dictionary) -> void:
	for key in ["sound_enabled", "music_enabled", "haptics_enabled", "reduced_motion", "reduced_screen_shake", "high_contrast"]:
		# set_pressed_no_signal: a plain assignment emits toggled, which would
		# re-enter the game's setting handler and rewrite the save file.
		var check := settings_controls[key] as CheckButton
		check.set_pressed_no_signal(bool(profile[key]))
		_sync_toggle_visual(check, bool(profile[key]))
	reduced_motion = bool(profile.reduced_motion)
	var guide_state := clampi(int(profile.guide_mode), 0, 2)
	var guide_buttons: Array[Button] = settings_controls.guide_buttons
	for mode_index in guide_buttons.size():
		guide_buttons[mode_index].set_pressed_no_signal(mode_index == guide_state)
	(settings_controls.guide_mode as Control).tooltip_text = "Trajectory guide: %s" % String(GUIDE_MODE_NAMES[guide_state])
	_update_loadout_group("ship", String(profile.selected_ship_color), profile.unlocked_ship_colors)
	_update_loadout_group("trail", String(profile.selected_trail), profile.unlocked_trails)
	_update_loadout_group("theme", String(profile.selected_planet_theme), profile.unlocked_planet_themes)
	var ship_name := String(CosmeticCatalog.find_item(CosmeticCatalog.SHIP_COLORS, String(profile.selected_ship_color)).name)
	var trail_name := String(CosmeticCatalog.find_item(CosmeticCatalog.TRAILS, String(profile.selected_trail)).name)
	var theme_name := String(CosmeticCatalog.find_item(CosmeticCatalog.PLANET_THEMES, String(profile.selected_planet_theme)).name)
	var locked := 0
	for pair in [[CosmeticCatalog.SHIP_COLORS, profile.unlocked_ship_colors], [CosmeticCatalog.TRAILS, profile.unlocked_trails], [CosmeticCatalog.PLANET_THEMES, profile.unlocked_planet_themes]]:
		for item in pair[0]:
			if not (pair[1] as PackedStringArray).has(String(item.id)):
				locked += 1
	var loadout_meta := "%s · %s · %s" % [ship_name, trail_name, theme_name]
	if locked > 0:
		loadout_meta = "%d TO UNLOCK" % locked
	(loadout_menu_button.get_node("Meta") as Label).text = loadout_meta


func _update_loadout_group(category: String, selected_id: String, unlocked: PackedStringArray) -> void:
	var category_buttons: Dictionary = loadout_buttons[category]
	for item_id in category_buttons:
		var button := category_buttons[item_id] as Button
		var is_unlocked := unlocked.has(String(item_id))
		var is_selected := String(item_id) == selected_id
		button.set_pressed_no_signal(is_selected)
		button.disabled = not is_unlocked
		_sync_loadout_option_visual(button, is_selected, is_unlocked)


func set_tutorial_visible(value: bool) -> void:
	tutorial_label.visible = value


func set_score(score: int, combo: int, best_score: int) -> void:
	score_label.text = str(score)
	best_label.text = "BEST %d" % best_score
	combo_label.text = "%dx COMBO" % combo if combo > 1 else ""
	if combo > _last_combo and combo > 1 and not reduced_motion:
		_pulse_combo()
	_last_combo = combo


func _pulse_combo() -> void:
	if combo_tween and combo_tween.is_valid():
		combo_tween.kill()
	combo_label.pivot_offset = combo_label.size * 0.5
	combo_label.scale = Vector2(1.28, 1.28)
	combo_tween = create_tween()
	combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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


## Announces a zone change with a large banner and a sweep of the zone colour.
func show_zone_banner(zone_name: String, zone_color: Color, duration: float = 1.4) -> void:
	if banner_tween and banner_tween.is_valid():
		banner_tween.kill()
	zone_banner_label.text = zone_name
	zone_banner_label.add_theme_color_override("font_color", zone_color.lightened(0.35))
	zone_banner_bar.color = zone_color
	zone_banner.visible = true
	zone_banner.modulate.a = 1.0
	zone_banner.scale = Vector2.ONE
	zone_banner_bar.scale = Vector2.ONE
	banner_tween = create_tween()
	if reduced_motion:
		banner_tween.tween_interval(duration)
		banner_tween.tween_callback(func() -> void: zone_banner.visible = false)
		return
	zone_banner.modulate.a = 0.0
	zone_banner.scale = Vector2(0.92, 0.92)
	zone_banner_bar.scale = Vector2(0.0, 1.0)
	banner_tween.set_parallel(true)
	banner_tween.tween_property(zone_banner, "modulate:a", 1.0, 0.22)
	banner_tween.tween_property(zone_banner, "scale", Vector2.ONE, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	banner_tween.tween_property(zone_banner_bar, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	banner_tween.set_parallel(false)
	banner_tween.tween_interval(duration - 0.22)
	banner_tween.tween_property(zone_banner, "modulate:a", 0.0, 0.3)
	banner_tween.tween_callback(func() -> void: zone_banner.visible = false)


func show_share_status(path: String, success: bool = true) -> void:
	if not success:
		share_status_label.text = "UNABLE TO SAVE SCORE CARD"
	elif OS.get_name() == "iOS":
		share_status_label.text = "SCORE CARD SAVED TO FILES\nON MY IPHONE > ORBIT BREAKER"
	else:
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
	if top_row:
		top_row.offset_left = safe_padding.x
		top_row.offset_top = safe_padding.y
		top_row.offset_right = -safe_padding.z
		top_row.offset_bottom = safe_padding.y + 220.0
	_layout_overlays()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_apply_safe_area()
