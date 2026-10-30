
extends CanvasLayer

@export_group("Paper")
@export var paper_texture: Texture2D

@onready var paper_ui: Control = $PaperUI
@onready var paper_sprite: TextureRect = $PaperUI/PaperSprite

var journal_open := false

var has_gold := false
var has_boat := false
var has_book := false
var has_seat := false
var duck_rescued := false

var task_labels: Array[Label] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	paper_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper_ui.visible = false

	if paper_texture != null:
		paper_sprite.texture = paper_texture

	paper_sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	paper_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE

	build_journal()


func build_journal() -> void:
	var content := VBoxContainer.new()
	content.name = "JournalContent"

	content.anchor_left = 0.20
	content.anchor_top = 0.12
	content.anchor_right = 0.80
	content.anchor_bottom = 0.88

	content.add_theme_constant_override("separation", 12)
	paper_ui.add_child(content)

	var heading := Label.new()
	heading.text = "YOUR ADVENTURE"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 28)
	heading.add_theme_color_override("font_color", Color("#382719"))
	content.add_child(heading)

	add_task(content, "Collect gold")
	add_task(content, "Exchange gold for a boat")
	add_task(content, "Find the book")
	add_task(content, "Obtain a seat")
	add_task(content, "Combine boat and seat")
	add_task(content, "Rescue the duck")

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var close_button := Button.new()
	close_button.text = "CLOSE JOURNAL"
	close_button.pressed.connect(close_journal)
	content.add_child(close_button)

	var hint := Label.new()
	hint.text = "Press G to close"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(hint)

	update_tasks()


func add_task(parent: VBoxContainer, task: String) -> void:
	var label := Label.new()
	label.text = "[ ] " + task
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("#382719"))
	parent.add_child(label)
	task_labels.append(label)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quest_journal") and not event.is_echo():
		toggle_journal()
		get_viewport().set_input_as_handled()


func toggle_journal() -> void:
	journal_open = not journal_open
	paper_ui.visible = journal_open


func close_journal() -> void:
	journal_open = false
	paper_ui.hide()


func update_tasks() -> void:
	var completed: Array[bool] = [
		has_gold,
		has_boat,
		has_book,
		has_seat,
		has_boat and has_seat,
		duck_rescued
	]

	for i in range(task_labels.size()):
		var task_text: String = task_labels[i].text
		var task_name: String = task_text.substr(4)

		if completed[i]:
			task_labels[i].text = "[X] " + task_name
			task_labels[i].add_theme_color_override(
				"font_color", Color("#77705f")
			)
		else:
			task_labels[i].text = "[ ] " + task_name
			task_labels[i].add_theme_color_override(
				"font_color", Color("#382719")
			)


func complete_gold() -> void:
	has_gold = true
	update_tasks()


func complete_boat() -> void:
	has_boat = true
	update_tasks()


func complete_book() -> void:
	has_book = true
	update_tasks()


func complete_seat() -> void:
	has_seat = true
	update_tasks()


func complete_duck_rescue() -> void:
	duck_rescued = true
	update_tasks()
