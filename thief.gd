
extends CharacterBody2D

@export var move_speed: float = 30.0
@export var wander_radius: float = 80.0
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0
@export var gold_price: int = 10

var player_in_range: Node2D = null
var trade_completed: bool = false

var home_position: Vector2
var target_position: Vector2
var waiting: bool = false
var wait_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_bubble = $DialogueBubble
@onready var dialogue_text: Label = $DialogueBubble/DialogueText


func _ready() -> void:
	home_position = global_position
	target_position = home_position

	dialogue_bubble.hide()

	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

	choose_new_target()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player_in_range):
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()
		return

	if waiting:
		wait_timer -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()

		if wait_timer <= 0.0:
			waiting = false
			choose_new_target()
		return

	var direction: Vector2 = target_position - global_position

	if direction.length() < 5.0:
		velocity = Vector2.ZERO
		move_and_slide()
		waiting = true
		wait_timer = randf_range(min_wait_time, max_wait_time)
		play_idle()
		return

	velocity = direction.normalized() * move_speed
	move_and_slide()
	play_walk(direction)


func _process(_delta: float) -> void:
	if is_instance_valid(player_in_range):
		if Input.is_action_just_pressed("interact"):
			trade_seat()


func choose_new_target() -> void:
	target_position = home_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		velocity = Vector2.ZERO
		show_message("THIEF\nPress E to trade 10 gold for a seat.")


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		dialogue_bubble.hide()


func trade_seat() -> void:
	if not is_instance_valid(player_in_range):
		return

	if trade_completed:
		show_message("Thief: I've already traded with you!")
		return

	if not player_in_range.has_method("spend_gold"):
		show_message("Thief: Your gold inventory isn't ready.")
		return

	if not player_in_range.has_method("receive_seat"):
		show_message("Thief: Your inventory can't carry the seat yet.")
		return

	if player_in_range.spend_gold(gold_price):
		player_in_range.receive_seat()
		trade_completed = true
		show_message("Thief: Deal! Here's your seat.")
	else:
		show_message("Thief: Bring me 10 gold first!")


func show_message(message: String) -> void:
	dialogue_text.text = message
	dialogue_bubble.show()


func play_walk(direction: Vector2) -> void:
	if sprite.sprite_frames == null:
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
	if sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation("Idle_Down"):
		if sprite.animation != "Idle_Down":
			sprite.play("Idle_Down")
	elif sprite.sprite_frames.has_animation("Run_Down"):
		sprite.stop()
