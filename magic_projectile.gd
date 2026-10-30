
extends Area2D

@export var speed: float = 220.0
@export var damage: int = 1
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.LEFT
var has_hit: bool = false
var travelled_time: float = 0.0


func _ready() -> void:
	# Draw a visible magic bolt if no animated frames exist.
	var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

	if sprite != null and sprite.sprite_frames != null:
		if sprite.sprite_frames.has_animation("fly"):
			sprite.play("fly")
		else:
			create_magic_visual()
	else:
		create_magic_visual()

	body_entered.connect(_on_body_entered)

	# Ensure the projectile is visible above the ground.
	z_index = 10

	get_tree().create_timer(lifetime).timeout.connect(
		_on_lifetime_timeout
	)


func create_magic_visual() -> void:
	if has_node("MagicVisual"):
		return

	var orb := Polygon2D.new()
	orb.name = "MagicVisual"
	orb.color = Color(0.75, 0.2, 1.0, 1.0)

	# A bright diamond-shaped magic projectile.
	orb.polygon = PackedVector2Array([
		Vector2(12, 0),
		Vector2(5, 5),
		Vector2(0, 12),
		Vector2(-5, 5),
		Vector2(-12, 0),
		Vector2(-5, -5),
		Vector2(0, -12),
		Vector2(5, -5)
	])

	add_child(orb)


func _physics_process(delta: float) -> void:
	if has_hit:
		return

	if direction.length_squared() > 0.0:
		global_position += direction.normalized() * speed * delta

	travelled_time += delta
	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if has_hit or not body.is_in_group("player"):
		return

	has_hit = true
	set_deferred("monitoring", false)

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()


func _on_lifetime_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
