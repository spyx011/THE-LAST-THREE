
extends Area2D

@export var gold_amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("Gold coin loaded: ", name)


func _on_body_entered(body: Node2D) -> void:
	print("Something touched the gold: ", body.name)

	if not body.is_in_group("player"):
		return

	if not body.has_method("add_gold"):
		push_warning("Player does not have add_gold()!")
		return

	body.add_gold(gold_amount)
	print("GOLD COLLECTED!")
	queue_free()
