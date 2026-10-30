
extends CharacterBody2D

@export var guard_name: String = "Royal Guard"
@export var move_speed: float = 25.0
@export var patrol_radius: float = 55.0
@export var wait_min: float = 1.0
@export var wait_max: float = 2.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var talk_range: Area2D = $TalkRange
@onready var dialogue_bubble: CanvasLayer = $DialogueBubble
@onready var dialogue_text: Label = $DialogueBubble/DialogueText

var home_position: Vector2
var target_position: Vector2
var player_nearby: Node2D = null
var waiting: bool = false
var wait_timer: float = 0.0


func _ready() -> void:
	home_position = global_position
	target_position = home_position

	dialogue_bubble.hide()

	talk_range.body_entered.connect(_on_body_entered)
	talk_range.body_exited.connect(_on_body_exited)

	# Make the guard face LEFT when standing still.
	sprite.flip_h = true

	choose_target()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player_nearby):
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
			choose_target()

		return

	var direction: Vector2 = target_position - global_position

	if direction.length() < 4.0:
		waiting = true
		wait_timer = randf_range(wait_min, wait_max)
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()
		return

	velocity = direction.normalized() * move_speed
	move_and_slide()
	play_walk(direction)


func _process(_delta: float) -> void:
	if is_instance_valid(player_nearby):
		if Input.is_action_just_pressed("interact"):
			talk_to_player()


func choose_target() -> void:
	target_position = home_position + Vector2(
		randf_range(-patrol_radius, patrol_radius),
		randf_range(-patrol_radius, patrol_radius)
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body
		velocity = Vector2.ZERO
		show_message("Press E to speak to the " + guard_name + ".")


func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null
		dialogue_bubble.hide()


func talk_to_player() -> void:
	if GameState.queen_quest_completed:
		show_message(
			guard_name + ": Welcome! You may enter the Queen's area."
		)
		return

	if GameState.has_royal_letter:
		show_message(
			guard_name + ": The missing royal letter! "
			+ "You have done well. The Queen's gates are open."
		)
		GameState.complete_queen_quest()
	else:
		show_message(
			guard_name + ": The Queen's area is restricted. "
			+ "Find the lost royal letter somewhere in the world "
			+ "and bring it to us."
		)


func show_message(message: String) -> void:
	dialogue_text.text = message
	dialogue_bubble.show()


func play_walk(direction: Vector2) -> void:
	if sprite.sprite_frames == null:
		return

	var animation_name: String = "Run_Down"

	if absf(direction.x) > absf(direction.y):
		if direction.x < 0.0:
			# Moving left: face LEFT.
			sprite.flip_h = true
			animation_name = "Run_right"
		else:
			# Moving right: face RIGHT.
			sprite.flip_h = false
			animation_name = "Run_right"
	elif direction.y < 0.0:
		animation_name = "Run_Up"
	else:
		animation_name = "Run_Down"

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)


func play_idle() -> void:
	if sprite.sprite_frames == null:
		return

	# Keep the guard facing LEFT while idle.
	sprite.flip_h = true

	if sprite.sprite_frames.has_animation("Idle_Down"):
		if sprite.animation != "Idle_Down":
			sprite.play("Idle_Down")
