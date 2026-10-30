
extends Area2D

var collected: bool = false
var player_nearby: Node2D = null

@onready var hint_label: Label = get_node_or_null("HintLabel")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if hint_label:
		hint_label.text = "Press E to collect the letter"
		hint_label.hide()


func _process(_delta: float) -> void:
	if collected:
		return

	if is_instance_valid(player_nearby):
		if Input.is_action_just_pressed("interact"):
			collect_letter()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body

		if hint_label:
			hint_label.show()


func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null

		if hint_label:
			hint_label.hide()


func collect_letter() -> void:
	if collected:
		return

	collected = true
	GameState.collect_royal_letter()

	print("You found the lost royal letter!")

	queue_free()
