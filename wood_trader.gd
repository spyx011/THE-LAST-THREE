
extends CharacterBody2D

const MEAT_PRICE: int = 3
const WOOD_REWARD: int = 5

@export var can_wander: bool = false
@export var move_speed: float = 30.0
@export var wander_radius: float = 80.0

var player_in_range: Node2D = null
var trade_completed: bool = false
var home_position: Vector2
var target_position: Vector2
var waiting: bool = false
var wait_left: float = 0.0

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var interaction_area: Area2D = get_node_or_null("InteractionArea")
@onready var dialogue_bubble: CanvasLayer = get_node_or_null("DialogueBubble")
@onready var dialogue_label: Label = get_node_or_null(
    "DialogueBubble/DialogueText"
)


func _ready() -> void:
	home_position = global_position
	target_position = home_position

	if interaction_area != null:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	else:
		push_error("WoodTrader needs an InteractionArea node.")

	if dialogue_bubble != null:
		dialogue_bubble.hide()

	choose_target()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player_in_range) or not can_wander:
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()
		return

	if waiting:
		wait_left -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()

		if wait_left <= 0.0:
			waiting = false
			choose_target()
		return

	var direction := target_position - global_position

	if direction.length() < 5.0:
		velocity = Vector2.ZERO
		waiting = true
		wait_left = randf_range(1.0, 3.0)
		move_and_slide()
		play_idle()
		return

	velocity = direction.normalized() * move_speed
	move_and_slide()
	play_walk(direction)


func _process(_delta: float) -> void:
	if is_instance_valid(player_in_range):
		if Input.is_action_just_pressed("interact"):
			trade()


func choose_target() -> void:
	target_position = home_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		show_message("WOOD TRADER\nPress E: Trade 3 meat for 5 wood.")


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		if dialogue_bubble != null:
			dialogue_bubble.hide()


func trade() -> void:
	if not is_instance_valid(player_in_range):
		return

	if trade_completed:
		show_message("Trader: Thanks for the trade!")
		return

	if not player_in_range.has_method("spend_meat"):
		show_message("Trader: Your meat inventory isn't ready.")
		return

	if not player_in_range.has_method("add_wood"):
		show_message("Trader: Your wood inventory isn't ready.")
		return

	if not player_in_range.spend_meat(MEAT_PRICE):
		show_message("Trader: Bring me 3 meat first!")
		return

	player_in_range.add_wood(WOOD_REWARD)
	trade_completed = true
	show_message("Trader: Deal! You received 5 wood.")


func show_message(message: String) -> void:
	if dialogue_label != null and dialogue_bubble != null:
		dialogue_label.text = message
		dialogue_bubble.show()
	else:
		print("Wood Trader: ", message)


func play_walk(direction: Vector2) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	var animation_name := "Run_Down"

	if absf(direction.x) > absf(direction.y):
		animation_name = "Run_right" if direction.x > 0.0 else "Run_left"
	elif direction.y < 0.0:
		animation_name = "Run_Up"

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)


func play_idle() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation("Idle_Down"):
		if sprite.animation != "Idle_Down":
			sprite.play("Idle_Down")
