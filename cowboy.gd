
extends CharacterBody2D

@export var move_speed: float = 35.0
@export var wander_radius: float = 100.0
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0

var player_in_range: Node2D = null
var duck_rescued: bool = false

var home_position: Vector2
var target_position: Vector2
var waiting: bool = false
var wait_timer: float = 0.0

var interact_prompt: Label

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_bubble = $DialogueBubble
@onready var dialogue_text: Label = $DialogueBubble/DialogueText


func _ready() -> void:
	home_position = global_position
	target_position = home_position

	dialogue_bubble.hide()
	create_interact_prompt()

	$TalkRange.body_entered.connect(_on_body_entered)
	$TalkRange.body_exited.connect(_on_body_exited)

	choose_new_target()


func create_interact_prompt() -> void:
	interact_prompt = Label.new()
	interact_prompt.name = "RuntimeInteractPrompt"
	interact_prompt.text = "Press E to talk"
	interact_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_prompt.add_theme_font_size_override("font_size", 16)
	interact_prompt.add_theme_color_override("font_color", Color.WHITE)
	interact_prompt.add_theme_color_override("font_shadow_color", Color.BLACK)
	interact_prompt.add_theme_constant_override("shadow_offset_x", 2)
	interact_prompt.add_theme_constant_override("shadow_offset_y", 2)

	# Keep the prompt attached to the moving Cowboy.
	add_child(interact_prompt)
	interact_prompt.position = Vector2(-65, -65)
	interact_prompt.size = Vector2(130, 28)
	interact_prompt.hide()


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
			talk_to_cowboy()


func choose_new_target() -> void:
	target_position = home_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		interact_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		interact_prompt.hide()
		dialogue_bubble.hide()


func talk_to_cowboy() -> void:
	if duck_rescued:
		show_message("Cowboy: The duck is safe! Thank you!")
		return

	if not is_instance_valid(player_in_range):
		return

	if not player_in_range.has_method("assemble_boat"):
		show_message("Cowboy: I need a boat and a seat!")
		return

	var boat_ready = player_in_range.assemble_boat()

	if boat_ready:
		if player_in_range.has_method("rescue_duck"):
			player_in_range.rescue_duck()
			duck_rescued = true
			show_message("Cowboy: Amazing! Let's rescue the duck!")
		else:
			show_message("Cowboy: The boat is ready!")
	else:
		show_message("Cowboy: We need both the boat and the seat!")


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
