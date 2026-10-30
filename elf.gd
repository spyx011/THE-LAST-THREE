
extends CharacterBody2D

@export var speed: float = 55.0
@export var detection_range: float = 250.0
@export var attack_range: float = 180.0
@export var max_health: int = 5
@export var spell_damage: int = 1
@export var spell_cooldown: float = 1.5
@export var projectile_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health: int
var target: Node2D = null
var attack_timer: float = 0.0


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	print("Elf ready. Projectile assigned: ", projectile_scene != null)


func _physics_process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)

	if not is_instance_valid(target):
		target = null

		for candidate in get_tree().get_nodes_in_group("player"):
			if candidate is Node2D:
				if global_position.distance_to(candidate.global_position) <= detection_range:
					target = candidate
					print("Elf detected player!")
					break

	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		play_if_available("idle")
		move_and_slide()
		return

	var offset: Vector2 = target.global_position - global_position
	var distance: float = offset.length()

	if offset.x != 0.0:
		sprite.flip_h = offset.x < 0.0

	if distance > attack_range:
		velocity = offset.normalized() * speed
		play_if_available("run")
		move_and_slide()
		return

	velocity = Vector2.ZERO
	move_and_slide()

	if attack_timer <= 0.0:
		cast_spell()
		attack_timer = spell_cooldown
	else:
		play_if_available("idle")


func cast_spell() -> void:
	if projectile_scene == null:
		push_error("Elf has no Projectile Scene assigned!")
		return

	if not is_instance_valid(target):
		return

	print("Elf casts magic!")

	play_if_available("attack")

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position

	if "direction" in projectile:
		projectile.direction = (
			target.global_position - global_position
		).normalized()

	if "damage" in projectile:
		projectile.damage = spell_damage


func play_if_available(animation_name: String) -> void:
	if sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)


func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	print("Elf HP: ", health, "/", max_health)

	if health <= 0:
		queue_free()
