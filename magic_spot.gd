
extends Area2D

@export var required_standing_time: float = 1.0
@export var completed_animation: String = "Idle_Down"

@onready var spot_animation: AnimatedSprite2D = $SpotAnimation
@onready var prompt_animation: AnimatedSprite2D = $PromptAnimation
@onready var prompt_label: Label = $PromptLabel

var player: CharacterBody2D = null
var standing_timer: float = 0.0
var activated: bool = false


func _ready() -> void:
	prompt_animation.hide()
	prompt_label.hide()

	spot_animation.play()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if activated or not is_instance_valid(player):
		return

	standing_timer += delta

	prompt_animation.show()
	prompt_label.show()
	prompt_label.text = "Come and stand here!"

	if standing_timer >= required_standing_time:
		activate_spot()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		standing_timer = 0.0


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		standing_timer = 0.0

		if not activated:
			prompt_animation.hide()
			prompt_label.hide()


func activate_spot() -> void:
	if activated or not is_instance_valid(player):
		return

	activated = true
	prompt_label.text = "Activated!"

	player.velocity = Vector2.ZERO

	var player_sprite: AnimatedSprite2D = \
		player.get_node_or_null("AnimatedSprite2D")

	if player_sprite and player_sprite.sprite_frames:
		if player_sprite.sprite_frames.has_animation(
			completed_animation
		):
			player_sprite.play(completed_animation)

	print("Magic spot activated!")
