class_name OrbitUIKit
extends RefCounted

## Shared interface tokens. Every size is in design units: the 1080-wide
## viewport stretches to the screen width, so one unit is about 0.36pt on a
## 393pt iPhone. 44pt, Apple's minimum tap target, is 121 units; 15–17pt body
## copy is 41–47 units. Nothing tappable may be shorter than CONTROL_HEIGHT and
## no copy may use a size below CAPTION.

const CAPTION := 40
const BODY := 46
const LABEL := 52
const BUTTON := 56
const HEADING := 72
const TITLE := 88
const SCORE := 104

const CONTROL_HEIGHT := 124.0
const PAUSE_BUTTON_SIZE := 136.0
const RADIUS := 32

const INK := Color("f3f5ff")
const INK_MUTED := Color("8ea1c3")
const INK_FAINT := Color("5b6b8c")
const ACCENT := Color("43d4ed")
const ACCENT_SOFT := Color("8fdfeb")
const ACCENT_INK := Color("06182b")
const PERFECT := Color("ff5fd6")
const DAILY := Color("ff2777")
const GOLD := Color("ffd166")
const DANGER := Color("ff315f")
const CARD := Color("08182f")
const CARD_LINE := Color("1d4962")
const FIELD := Color("102344")
const FIELD_LINE := Color("2f5574")

static var _display_font: FontFile
static var _body_font: FontVariation
static var _body_bold_font: FontVariation


static func display_font() -> Font:
	if _display_font == null:
		_display_font = load("res://assets/fonts/ArchivoBlack-Regular.ttf") as FontFile
	return _display_font


static func body_font() -> Font:
	if _body_font == null:
		_body_font = _variation(600)
	return _body_font


static func body_bold_font() -> Font:
	if _body_bold_font == null:
		_body_bold_font = _variation(700)
	return _body_bold_font


static func _variation(weight: int) -> FontVariation:
	var variation := FontVariation.new()
	variation.base_font = load("res://assets/fonts/Archivo-Variable.ttf") as FontFile
	variation.variation_opentype = {"wght": weight, "wdth": 100}
	return variation


static func label(text_value: String, font_size: int, color: Color, alignment: HorizontalAlignment, display: bool = false) -> Label:
	var result := Label.new()
	result.text = text_value
	result.horizontal_alignment = alignment
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.add_theme_font_override("font", display_font() if display else body_font())
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


static func primary_button(text_value: String, minimum_width: float = 0.0) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(minimum_width, CONTROL_HEIGHT)
	button.add_theme_font_override("font", display_font())
	button.add_theme_font_size_override("font_size", BUTTON)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, ACCENT_INK)
	button.focus_mode = Control.FOCUS_ALL
	var normal := StyleBoxFlat.new()
	normal.bg_color = ACCENT
	normal.set_corner_radius_all(RADIUS)
	normal.shadow_color = Color(ACCENT, 0.28)
	normal.shadow_size = 22
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("62e5f8")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("2ab8d2")
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color.WHITE
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(RADIUS)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	return button


static func secondary_button(text_value: String, minimum_width: float = 0.0) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(minimum_width, CONTROL_HEIGHT)
	button.add_theme_font_override("font", body_bold_font())
	button.add_theme_font_size_override("font_size", LABEL)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", INK)
	button.focus_mode = Control.FOCUS_ALL
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(FIELD, 0.92)
	normal.border_color = Color(ACCENT, 0.55)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(RADIUS)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("1b3c63", 0.98)
	hover.border_color = Color("8ffaff")
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color.WHITE
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(RADIUS)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("hover_pressed", hover)
	button.add_theme_stylebox_override("focus", focus)
	return button


static func card_style(opacity: float = 0.97) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(CARD, opacity)
	style.border_color = Color("4ce7fb")
	style.set_border_width_all(3)
	style.set_corner_radius_all(44)
	style.shadow_color = Color("35dff7", 0.16)
	style.shadow_size = 28
	return style


static func overlay_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("080312", 0.74)
	return style
