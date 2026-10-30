extends Control

@export_group("Game")
@export_file("*.tscn") var game_scene := "res://WORLD.tscn"

@export_group("Look")
@export var game_title := "THE LAST THREE"
@export var title_size := 88
@export var button_size := 26
@export var left_margin := 140
@export var background_color := Color(0.07, 0.065, 0.06)
@export var background_image: Texture2D          
@export var title_color := Color(0.89, 0.86, 0.78)
@export var button_idle := Color(0.50, 0.47, 0.42)
@export var button_hover := Color(0.95, 0.92, 0.84)
@export var title_font: Font                      

var play_button: Button
var quit_button: Button
var title_label: Label
var divider: ColorRect
var fade: ColorRect
var _tweens := {}
var _leaving := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_menu()

	fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fade)

	_intro()


func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = background_color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	if background_image:
		var pic := TextureRect.new()
		pic.texture = background_image
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pic.modulate = Color(0.55, 0.55, 0.55)
		pic.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(pic)

	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.85)])
	grad.offsets = PackedFloat32Array([0.35, 1.0])
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	var vig := TextureRect.new()
	vig.texture = gt
	vig.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vig.stretch_mode = TextureRect.STRETCH_SCALE
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vig)


func _spaced_font(spacing: int) -> Font:
	var fv := FontVariation.new()
	fv.base_font = title_font if title_font else ThemeDB.fallback_font
	fv.spacing_glyph = spacing
	return fv


func _build_menu() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", left_margin)
	margin.add_theme_constant_override("margin_right", 60)
	add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	title_label = Label.new()
	title_label.text = game_title
	title_label.add_theme_font_override("font", _spaced_font(12))
	title_label.add_theme_font_size_override("font_size", title_size)
	title_label.add_theme_color_override("font_color", title_color)
	box.add_child(title_label)

	divider = ColorRect.new()
	divider.color = Color(title_color, 0.35)
	divider.custom_minimum_size = Vector2(120, 2)
	divider.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(divider)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 40)
	box.add_child(gap)

	play_button = _make_button("PLAY")
	play_button.pressed.connect(_on_play)
	box.add_child(play_button)

	quit_button = _make_button("QUIT")
	quit_button.pressed.connect(_on_quit)
	box.add_child(quit_button)

	play_button.grab_focus()


func _make_button(label: String) -> Button:
	var b := Button.new()
	b.text = label
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_override("font", _spaced_font(6))
	b.add_theme_font_size_override("font_size", button_size)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color.WHITE)

	b.add_theme_stylebox_override("normal", _line(false))
	b.add_theme_stylebox_override("hover", _line(true))
	b.add_theme_stylebox_override("pressed", _line(true))
	b.add_theme_stylebox_override("focus", _line(true))

	b.modulate = button_idle
	b.mouse_entered.connect(b.grab_focus)
	b.focus_entered.connect(_hover.bind(b, true))
	b.focus_exited.connect(_hover.bind(b, false))
	return b


func _line(active: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_width_bottom = 2
	sb.border_color = title_color if active else Color(0, 0, 0, 0)
	sb.content_margin_left = 0
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


func _intro() -> void:
	title_label.modulate.a = 0.0
	divider.modulate.a = 0.0
	play_button.modulate = Color(button_idle, 0.0)
	quit_button.modulate = Color(button_idle, 0.0)

	var t := create_tween()
	t.tween_property(fade, "color:a", 0.0, 1.0).from(1.0)
	t.parallel().tween_property(title_label, "modulate:a", 1.0, 1.8).set_delay(0.4)
	t.parallel().tween_property(divider, "modulate:a", 1.0, 1.8).set_delay(0.9)
	t.parallel().tween_property(play_button, "modulate:a", 1.0, 1.0).set_delay(1.5)
	t.parallel().tween_property(quit_button, "modulate:a", 1.0, 1.0).set_delay(1.7)
	t.tween_callback(_sync_focus_color)


func _sync_focus_color() -> void:
	if play_button.has_focus():
		_hover(play_button, true)


func _hover(b: Button, on: bool) -> void:
	if _leaving:
		return
	if _tweens.has(b) and _tweens[b]:
		_tweens[b].kill()
	var target := button_hover if on else button_idle
	var t := create_tween()
	t.tween_property(b, "modulate", Color(target, b.modulate.a), 0.15)
	_tweens[b] = t


func _on_play() -> void:
	if _leaving:
		return
	if not ResourceLoader.exists(game_scene):
		push_error("start_screen: game scene not found: " + game_scene)
		return
	_leaving = true
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, 0.8)
	t.tween_callback(func(): get_tree().change_scene_to_file(game_scene))


func _on_quit() -> void:
	if _leaving:
		return
	_leaving = true
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, 0.5)
	t.tween_callback(func(): get_tree().quit());
