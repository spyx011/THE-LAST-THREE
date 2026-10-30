
extends CharacterBody2D

const GOLD_PRICE: int = 5
const MEAT_REWARD: int = 3

@export var move_speed: float = 30.0
@export var wander_radius: float = 80.0
@export var wait_time: float = 2.0

var player_in_range: Node2D = null
var sold_meat: bool = false
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
		push_error("Meat Merchant needs an InteractionArea node.")

	if dialogue_bubble != null:
		dialogue_bubble.hide()
	else:
		push_error("Add a DialogueBubble CanvasLayer to Meat Merchant.")

	if dialogue_label == null:
		push_error("Add DialogueText (Label) under DialogueBubble.")

	choose_target()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player_in_range):
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
		wait_left = wait_time
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
		velocity = Vector2.ZERO
		show_message("MEAT MERCHANT\nPress E: 5 gold for 3 meat")


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		if dialogue_bubble != null:
			dialogue_bubble.hide()


func trade() -> void:
	if not is_instance_valid(player_in_range):
		return

	if sold_meat:
		show_message("I've sold all my meat today!")
		return

	if not player_in_range.has_method("spend_gold"):
		show_message("Bring me 5 gold, traveler.")
		return

	if not player_in_range.has_method("add_meat"):
		show_message("Your meat inventory isn't ready.")
		return

	if not player_in_range.spend_gold(GOLD_PRICE):
		show_message("You need 5 gold first!")
		return

	player_in_range.add_meat(MEAT_REWARD)
	sold_meat = true
	show_message("Trade complete!\nYou received 3 meat!")


func show_message(message: String) -> void:
	if dialogue_label == null or dialogue_bubble == null:
		return

	dialogue_label.text = message
	dialogue_bubble.show()


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
