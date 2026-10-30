
extends CharacterBody2D

@export var speed: float = 130.0

var gold: int = 0
var has_seat: bool = false
var has_book: bool = false
var has_boat: bool = false
var boat_assembled: bool = false
var duck_rescued: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")

	play_animation("Idle_Down")


func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_animation()


func handle_movement() -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
        "move_down"
	)

	if input_direction != Vector2.ZERO:
		last_direction = input_direction.normalized()

	velocity = input_direction * speed
	move_and_slide()


func handle_animation() -> void:
	if velocity.length() < 1.0:
		play_animation(get_idle_animation())
		return

	if absf(velocity.x) > absf(velocity.y):
		if velocity.x < 0.0:
			play_animation("Run_left")
		else:
			play_animation("Run_right")
	elif velocity.y < 0.0:
		play_animation("Run_Up")
	else:
		play_animation("Run_Down")


func get_idle_animation() -> String:
	if last_direction.y < -0.5:
		return "Idle_Up"

	if last_direction.y > 0.5:
		return "Idle_Down"

	if last_direction.x < 0.0:
		return "Idle_left"

	return "Idle_right"


func play_animation(animation_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return

	if animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.play(animation_name)


func add_gold(amount: int) -> void:
	if amount <= 0:
		return

	gold += amount
	print("Gold collected! Total gold: ", gold)


func spend_gold(amount: int) -> bool:
	if amount <= 0 or gold < amount:
		return false

	gold -= amount
	print("Gold spent! Remaining gold: ", gold)
	return true


func receive_seat() -> void:
	has_seat = true
	print("Quest updated: You obtained the seat!")


func receive_boat() -> void:
	has_boat = true
	print("Quest updated: You obtained the boat!")


func assemble_boat() -> bool:
	if not has_boat or not has_seat:
		print("You need both the boat and the seat!")
		return false

	boat_assembled = true
	print("Boat assembled! You are ready to sail.")
	return true

func rescue_duck() -> void:
	if not boat_assembled:
		print("Assemble your boat first!")
		return

	duck_rescued = true
	print("Quest complete: You rescued the duck!")
