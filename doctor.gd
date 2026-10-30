
extends CharacterBody2D

@export var move_speed: float = 24.0
@export var patrol_radius: float = 120.0
@export var wait_min: float = 1.5
@export var wait_max: float = 3.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var talk_range: Area2D = $TalkRange
@onready var dialogue_bubble: CanvasLayer = $DialogueBubble
@onready var dialogue_text: Label = $DialogueBubble/DialogueText

var home_position: Vector2
var target_position: Vector2
var player_nearby: Node2D = null

var waiting: bool = false
var wait_timer: float = 0.0
var dialogue_index: int = 0
var dialogue_finished: bool = false

# The Doctor speaks only once, in this order.
var dialogue_lines: Array[String] = [
	"Hello! I'm the village doctor.",
	"I'm searching the village for patients.",
	"Have you seen anyone who needs medical help?",
    "I should check the houses and make sure everyone is okay."
]


func _ready() -> void:
	home_position = global_position
	target_position = home_position

	dialogue_bubble.hide()

	talk_range.body_entered.connect(_on_body_entered)
	talk_range.body_exited.connect(_on_body_exited)

	randomize()
	choose_target()
	play_idle()


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

	if direction.length() < 5.0:
		velocity = Vector2.ZERO
		move_and_slide()

		waiting = true
		wait_timer = randf_range(wait_min, wait_max)
		play_idle()
		print("Doctor: Searching for patients...")
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

		if not dialogue_finished:
			show_message("Press E to talk to the Doctor.")


func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null
		dialogue_bubble.hide()


func talk_to_player() -> void:
	# Never repeat dialogue after the final line.
	if dialogue_finished:
		return

	if dialogue_index < dialogue_lines.size():
		show_message(dialogue_lines[dialogue_index])
		dialogue_index += 1

		if dialogue_index >= dialogue_lines.size():
			dialogue_finished = true
			print("Doctor: Dialogue finished.")


func show_message(message: String) -> void:
	dialogue_text.text = message
	dialogue_bubble.show()


func play_walk(direction: Vector2) -> void:
	if sprite.sprite_frames == null:
		return

	var animation_name: String = "Run_Down"

	if absf(direction.x) > absf(direction.y):
		animation_name = "Run_right"
		sprite.flip_h = direction.x < 0.0
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

	var animation_name: String = "Idle_Down"

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)
