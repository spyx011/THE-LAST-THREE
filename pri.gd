
extends CharacterBody2D

enum NPCType {
	VILLAGER,
	MEAT_MERCHANT,
	WOOD_TRADER,
	THIEF
}

@export_group("NPC Settings")
@export var npc_type: NPCType = NPCType.VILLAGER
@export var npc_name: String = "Villager"
@export var can_wander: bool = true
@export var move_speed: float = 30.0
@export var wander_radius: float = 80.0
@export var pause_min: float = 1.0
@export var pause_max: float = 3.0

@export_group("Trading")
@export var gold_price: int = 5
@export var meat_price: int = 3
@export var meat_reward: int = 3
@export var wood_reward: int = 5

@export_group("Villager Dialogue")
@export_multiline var dialogue_lines: PackedStringArray = [
	"yoo dude did you say me dog!!",
	"like its as cut as like you",
    "plzz dude if you find it just kill it!!"
]

var player_in_range: Node2D = null
var home_position: Vector2
var target_position: Vector2
var waiting: bool = false
var wait_left: float = 0.0
var dialogue_index: int = 0
var conversation_finished: bool = false
var trade_completed: bool = false

var sprite: AnimatedSprite2D
var interaction_area: Area2D
var dialogue_bubble: CanvasLayer
var dialogue_label: Label


func _ready() -> void:
	randomize()

	home_position = global_position
	target_position = home_position

	sprite = get_node_or_null("AnimatedSprite2D")
	interaction_area = get_node_or_null("InteractionArea")
	dialogue_bubble = get_node_or_null("DialogueBubble")

	if dialogue_bubble != null:
		dialogue_label = dialogue_bubble.get_node_or_null("DialogueText")
		dialogue_bubble.hide()

	if interaction_area != null:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	else:
		push_error(npc_name + ": Missing InteractionArea!")

	if dialogue_label == null:
		push_warning(npc_name + ": Missing DialogueText under DialogueBubble.")

	choose_target()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player_in_range):
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()
		return

	if not can_wander:
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

	var direction: Vector2 = target_position - global_position

	if direction.length() < 5.0:
		velocity = Vector2.ZERO
		waiting = true
		wait_left = randf_range(pause_min, pause_max)
		move_and_slide()
		play_idle()
		return

	velocity = direction.normalized() * move_speed
	move_and_slide()
	play_walk(direction)


func _process(_delta: float) -> void:
	if is_instance_valid(player_in_range):
		if Input.is_action_just_pressed("interact"):
			interact_with_player()


func choose_target() -> void:
	target_position = home_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		velocity = Vector2.ZERO

		if npc_type == NPCType.VILLAGER and conversation_finished:
			show_message(npc_name + ": I've told you everything!")
		else:
			show_message("Press E to talk to " + npc_name + ".")


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

		if dialogue_bubble != null:
			dialogue_bubble.hide()


func interact_with_player() -> void:
	if not is_instance_valid(player_in_range):
		return

	match npc_type:
		NPCType.VILLAGER:
			talk_to_villager()
		NPCType.MEAT_MERCHANT:
			trade_meat()
		NPCType.WOOD_TRADER:
			trade_wood()
		NPCType.THIEF:
			trade_seat()


func talk_to_villager() -> void:
	if conversation_finished:
		show_message(npc_name + ": I've told you everything!")
		return

	if dialogue_lines.is_empty():
		conversation_finished = true
		show_message(npc_name + ": Hello!")
		return

	show_message(npc_name + ": " + dialogue_lines[dialogue_index])

	dialogue_index += 1

	if dialogue_index >= dialogue_lines.size():
		conversation_finished = true


func trade_meat() -> void:
	if trade_completed:
		show_message("Merchant: I've sold my meat for today!")
		return

	if not player_in_range.has_method("spend_gold"):
		show_message("Merchant: Bring me some gold.")
		return

	if not player_in_range.has_method("add_meat"):
		show_message("Merchant: Your inventory isn't ready.")
		return

	if not player_in_range.spend_gold(gold_price):
		show_message("Merchant: I need " + str(gold_price) + " gold!")
		return

	player_in_range.add_meat(meat_reward)
	trade_completed = true
	show_message("Merchant: Deal! You received " + str(meat_reward) + " meat.")


func trade_wood() -> void:
	if trade_completed:
		show_message("Trader: Thanks for the trade!")
		return

	if not player_in_range.has_method("spend_meat"):
		show_message("Trader: Bring me some meat.")
		return

	if not player_in_range.has_method("add_wood"):
		show_message("Trader: Your wood inventory isn't ready.")
		return

	if not player_in_range.spend_meat(meat_price):
		show_message("Trader: I need " + str(meat_price) + " meat!")
		return

	player_in_range.add_wood(wood_reward)
	trade_completed = true
	show_message("Trader: Deal! You received " + str(wood_reward) + " wood.")


func trade_seat() -> void:
	if trade_completed:
		show_message("Thief: The seat is yours!")
		return

	if not player_in_range.has_method("spend_gold"):
		show_message("Thief: I only accept gold.")
		return

	if not player_in_range.has_method("receive_seat"):
		show_message("Thief: Your quest inventory isn't ready.")
		return

	if not player_in_range.spend_gold(gold_price):
		show_message("Thief: Bring me " + str(gold_price) + " gold!")
		return

	player_in_range.receive_seat()
	trade_completed = true
	show_message("Thief: Deal! The seat is yours.")


func show_message(message: String) -> void:
	if dialogue_label != null and dialogue_bubble != null:
		dialogue_label.text = message
		dialogue_bubble.show()
	else:
		print(npc_name, ": ", message)


func play_walk(direction: Vector2) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	var animation_name: String = "Run_Down"

	if absf(direction.x) > absf(direction.y):
		if direction.x > 0.0:
			animation_name = "Run_right"
		else:
			animation_name = "Run_left"
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
