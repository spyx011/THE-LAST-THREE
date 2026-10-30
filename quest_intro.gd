
extends CanvasLayer

@onready var paper_ui: Control = $PaperUI
@onready var paper_sprite: TextureRect = $PaperUI/PaperSprite

var is_open: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	paper_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper_ui.visible = true

	paper_sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	paper_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	paper_sprite.z_index = 0

	get_tree().paused = true
	is_open = true

	create_quest_text()


func create_quest_text() -> void:

	var dim := ColorRect.new()
	dim.name = "DarkOverlay"
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.z_index = -1
	paper_ui.add_child(dim)

	var content := VBoxContainer.new()
	content.name = "QuestText"

	content.anchor_left = 0.15
	content.anchor_top = 0.08
	content.anchor_right = 0.85
	content.anchor_bottom = 0.92

	content.offset_left = 0
	content.offset_top = 0
	content.offset_right = 0
	content.offset_bottom = 0

	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	content.z_index = 2
	paper_ui.add_child(content)

	add_text(content, "YOUR QUEST BEGINS!", 27, true)
	add_text(content, "Your adventure starts now.", 16)

	add_text(content, "1. FIND GOLD", 19, true)
	add_text(content, "Explore the world and collect gold coins.")

	add_text(content, "2. GET THE BOAT", 19, true)
	add_text(content, "Exchange your gold with the boat trader.")

	add_text(content, "3. FIND THE BOOK", 19, true)
	add_text(content, "Find the book to help you obtain a seat.")

	add_text(content, "4. PREPARE YOUR BOAT", 19, true)
	add_text(content, "Combine the boat and seat at the shore.")

	add_text(content, "5. RESCUE THE DUCK", 19, true)
	add_text(content, "Sail into the sea and find the duck.")

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var start_button := Button.new()
	start_button.name = "StartAdventureButton"
	start_button.text = "START ADVENTURE"
	start_button.custom_minimum_size = Vector2(0, 44)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.add_theme_font_size_override("font_size", 18)
	start_button.pressed.connect(close_paper)
	content.add_child(start_button)

	var hint := Label.new()
	hint.text = "Press E to begin"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("#382719"))
	content.add_child(hint)


func add_text(
	parent: VBoxContainer,
	message: String,
	font_size: int = 15,
	bold: bool = false
) -> void:
	var label := Label.new()
	label.text = message
	label.custom_minimum_size = Vector2(0, 24)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)

	var text_color := Color("#20160e") if bold else Color("#382719")
	label.add_theme_color_override("font_color", text_color)

	parent.add_child(label)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_E:
			close_paper()
			get_viewport().set_input_as_handled()


func close_paper() -> void:
	if not is_open:
		return

	is_open = false
	paper_ui.hide()
	get_tree().paused = false
