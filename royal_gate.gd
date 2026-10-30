
extends StaticBody2D

@onready var gate_collision: CollisionShape2D = $CollisionShape2D

var gate_open: bool = false


func _ready() -> void:
	update_gate()


func _process(_delta: float) -> void:
	# Check whether the royal quest has been completed.
	if GameState.queen_quest_completed and not gate_open:
		open_gate()


func open_gate() -> void:
	gate_open = true

	# Remove the collision so the player can pass through.
	gate_collision.set_deferred("disabled", true)

	# Hide the gate and its child visuals.
	hide()

	print("Royal Gate: OPEN!")


func update_gate() -> void:
	gate_open = GameState.queen_quest_completed
	gate_collision.set_deferred("disabled", gate_open)
	visible = not gate_open
