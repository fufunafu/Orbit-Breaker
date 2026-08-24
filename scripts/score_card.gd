class_name OrbitScoreCard
extends Control

## A self-contained share card drawn from a run summary. It is rendered in an
## off-screen SubViewport by OrbitGame.render_score_card_image so the saved
## image never includes the interface or the HUD.

var summary: Dictionary = {}


func _ready() -> void:
	_build()


func _build() -> void:
	var zone_color: Color = summary.get("zone_color", Color("7cf8ff"))
	var background := ColorRect.new()
	background.color = Color("050b1c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var stars := OrbitStarfield.new()
	stars.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(stars)
	var frame := PanelContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 60.0
	frame.offset_top = 60.0
	frame.offset_right = -60.0
	frame.offset_bottom = -60.0
	var style := OrbitUIKit.card_style(0.94)
	style.border_color = zone_color
	style.content_margin_left = 64.0
	style.content_margin_right = 64.0
	style.content_margin_top = 56.0
	style.content_margin_bottom = 56.0
	frame.add_theme_stylebox_override("panel", style)
	add_child(frame)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	frame.add_child(box)

	var mode_text := "CLASSIC RUN"
	if bool(summary.get("is_daily", false)):
		mode_text = "DAILY CHALLENGE  ·  %s UTC" % String(summary.get("daily_date", ""))
	box.add_child(OrbitUIKit.label(mode_text, OrbitUIKit.CAPTION, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_CENTER, true))
	box.add_child(OrbitUIKit.label("ORBIT BREAKER", 64, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true))
	box.add_child(_spacer(28.0))
	if bool(summary.get("new_best", false)):
		box.add_child(OrbitUIKit.label("NEW BEST", OrbitUIKit.LABEL, OrbitUIKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER, true))
	var score_label := OrbitUIKit.label(str(int(summary.get("score", 0))), 260, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true)
	score_label.custom_minimum_size = Vector2(0.0, 280.0)
	box.add_child(score_label)
	box.add_child(OrbitUIKit.label("SCORE", OrbitUIKit.CAPTION, zone_color, HORIZONTAL_ALIGNMENT_CENTER, true))
	box.add_child(_spacer(36.0))
	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 24)
	box.add_child(stats)
	for stat in [
		["LANDINGS", str(int(summary.get("landings", 0)))],
		["PERFECT", str(int(summary.get("perfect_landings", 0)))],
		["COMBO", "%dx" % int(summary.get("highest_combo", 1))],
		["BEST", str(int(summary.get("best_score", 0)))],
	]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 4)
		column.add_child(OrbitUIKit.label(String(stat[1]), OrbitUIKit.HEADING, OrbitUIKit.INK, HORIZONTAL_ALIGNMENT_CENTER, true))
		column.add_child(OrbitUIKit.label(String(stat[0]), 34, OrbitUIKit.INK_MUTED, HORIZONTAL_ALIGNMENT_CENTER, true))
		stats.add_child(column)
	box.add_child(_spacer(36.0))
	var zone_line := OrbitUIKit.label("REACHED %s" % String(summary.get("zone_name", "ION VEIL")), OrbitUIKit.BODY, zone_color, HORIZONTAL_ALIGNMENT_CENTER)
	zone_line.add_theme_font_override("font", OrbitUIKit.body_bold_font())
	box.add_child(zone_line)
	box.add_child(OrbitUIKit.label(String(summary.get("failure_reason", "")), OrbitUIKit.CAPTION, Color("ffb0c1"), HORIZONTAL_ALIGNMENT_CENTER))


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	return spacer
