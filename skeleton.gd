
extends CharacterBody2D

@export var speed: float = 75.0
@export var detection_range: float = 180.0
@export var attack_range: float = 38.0
@export var max_health: int = 3
@export var damage: int = 1
@export var attack_cooldown: float = 1.0

@export_group("Animation Names")
@export var idle_animation: String = "idle"
@export var run_animation: String = "run"
@export var attack_animation: String = "attack"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health: int
var target: Node2D = null
var has_detected_player: bool = false
var attack_timer: float = 0.0


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	play_animation([idle_animation, "Idle", "idle"])


func _physics_process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)

	if not has_detected_player:
		var players := get_tree().get_nodes_in_group("player")

		for candidate in players:
			if not candidate is Node2D:
				continue

			var distance_to_player: float = global_position.distance_to(
				candidate.global_position
			)

			if distance_to_player <= detection_range:
				target = candidate
				has_detected_player = true
				print("Skeleton detected the player!")
				break

	if not is_instance_valid(target):
		target = null
		velocity = Vector2.ZERO
		play_animation([idle_animation, "Idle", "idle"])
		move_and_slide()
		return

	var distance: float = global_position.distance_to(
		target.global_position
	)

	var horizontal_distance: float = (
		target.global_position.x - global_position.x
	)

	if horizontal_distance != 0.0:
		sprite.flip_h = horizontal_distance < 0.0

	if distance > attack_range:
		velocity = global_position.direction_to(
			target.global_position
		) * speed

		play_animation([run_animation, "Run", "run", "walk", "Walk"])

	else:
		velocity = Vector2.ZERO
		play_animation([
			attack_animation,
			"Attack",
			"attack",
            "Attack_1"
		])

		if attack_timer <= 0.0:
			if target.has_method("take_damage"):
				target.take_damage(damage)

			attack_timer = attack_cooldown

	move_and_slide()


func play_animation(names: Array) -> void:
	if sprite.sprite_frames == null:
		return

	for animation_name in names:
		if sprite.sprite_frames.has_animation(animation_name):
			if sprite.animation != animation_name:
				sprite.play(animation_name)
			return


func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	print("Skeleton HP: ", health, "/", max_health)

	if health <= 0:
		print("Skeleton defeated!")
		queue_free()
