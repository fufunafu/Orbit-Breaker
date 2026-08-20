class_name OrbitHUD
extends Control

signal primary_action_requested

var score_label: Label
var best_label: Label
var combo_label: Label
var title_label: Label
var prompt_label: Label
var tutorial_label: Label
var game_over_panel: PanelContainer
var final_score_label: Label
var restart_label: Label
var flash_rect: ColorRect
var flash_tween: Tween
var safe_padding := Vector4(54.0, 72.0, 54.0, 54.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_interface()
	_apply_safe_area()


func _build_interface() -> void:
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
	score_label.custom_minimum_size = Vector2(260.0, 96.0)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(score_label)
	best_label = _make_label("BEST 0", 30, Color("75e8ff"), HORIZONTAL_ALIGNMENT_RIGHT)
	best_label.custom_minimum_size = Vector2(360.0, 96.0)
	best_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(best_label)

	combo_label = _make_label("", 34, Color("ff6bdd"), HORIZONTAL_ALIGNMENT_CENTER)
	combo_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	combo_label.position = Vector2(-170.0, safe_padding.y + 88.0)
	combo_label.size = Vector2(340.0, 58.0)
	add_child(combo_label)

	title_label = _make_label("ORBIT\nBREAKER", 92, Color("eaffff"), HORIZONTAL_ALIGNMENT_CENTER)
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.position = Vector2(-370.0, -760.0)
	title_label.size = Vector2(740.0, 240.0)
	title_label.add_theme_constant_override("line_spacing", -18)
	add_child(title_label)

	prompt_label = _make_label("TAP TO START", 38, Color("79f9ff"), HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.set_anchors_preset(Control.PRESET_CENTER)
	prompt_label.position = Vector2(-320.0, -500.0)
	prompt_label.size = Vector2(640.0, 80.0)
	add_child(prompt_label)

	tutorial_label = _make_label(
		"WAIT FOR THE LINE TO REACH THE GLOWING PLANET\nTHEN TAP TO LAUNCH",
		29,
		Color("d6fdff"),
		HORIZONTAL_ALIGNMENT_CENTER
	)
	tutorial_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tutorial_label.position = Vector2(-450.0, -310.0)
	tutorial_label.size = Vector2(900.0, 150.0)
	tutorial_label.add_theme_constant_override("line_spacing", 8)
	tutorial_label.visible = false
	add_child(tutorial_label)

	game_over_panel = PanelContainer.new()
	game_over_panel.name = "GameOverPanel"
	game_over_panel.set_anchors_preset(Control.PRESET_CENTER)
	game_over_panel.position = Vector2(-360.0, -260.0)
	game_over_panel.size = Vector2(720.0, 520.0)
	game_over_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("08122a", 0.94)
	panel_style.border_color = Color("5cecff", 0.8)
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(34)
	panel_style.shadow_color = Color("4df3ff", 0.16)
	panel_style.shadow_size = 22
	game_over_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(game_over_panel)

	var over_box := VBoxContainer.new()
	over_box.alignment = BoxContainer.ALIGNMENT_CENTER
	over_box.add_theme_constant_override("separation", 28)
	game_over_panel.add_child(over_box)
	var over_title := _make_label("SIGNAL LOST", 58, Color("ff7194"), HORIZONTAL_ALIGNMENT_CENTER)
	over_box.add_child(over_title)
	final_score_label = _make_label("SCORE 0", 48, Color("ecffff"), HORIZONTAL_ALIGNMENT_CENTER)
	over_box.add_child(final_score_label)
	restart_label = _make_label("TAP TO RESTART", 34, Color("75f8ff"), HORIZONTAL_ALIGNMENT_CENTER)
	over_box.add_child(restart_label)

	flash_rect = ColorRect.new()
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	add_child(flash_rect)


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


func show_ready(best_score: int) -> void:
	set_score(0, 1, best_score)
	title_label.visible = true
	prompt_label.visible = true
	tutorial_label.visible = false
	game_over_panel.visible = false


func show_running(show_tutorial: bool = false) -> void:
	title_label.visible = false
	prompt_label.visible = false
	tutorial_label.visible = show_tutorial
	game_over_panel.visible = false


func show_game_over(score: int, best_score: int) -> void:
	title_label.visible = false
	prompt_label.visible = false
	tutorial_label.visible = false
	final_score_label.text = "SCORE %d\nBEST %d" % [score, best_score]
	game_over_panel.visible = true


func set_tutorial_visible(value: bool) -> void:
	tutorial_label.visible = value


func set_score(score: int, combo: int, best_score: int) -> void:
	score_label.text = str(score)
	best_label.text = "BEST %d" % best_score
	combo_label.text = "%dx COMBO" % combo if combo > 1 else ""


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
	if safe_rect.size.x > 0 and safe_rect.size.y > 0 and screen_size.x > 0 and screen_size.y > 0:
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
