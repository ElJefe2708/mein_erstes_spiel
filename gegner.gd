extends CharacterBody2D
class_name Enemy

const GRAVITY := 1200.0
var start_x := 0.0
var direction := -1.0
var animation_time := 0.0
var visual_base_position := Vector2.ZERO

@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	start_x = global_position.x
	visual_base_position = visual.position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	velocity.x = direction * 70.0
	move_and_slide()
	animation_time += delta * 8.0
	visual.position = visual_base_position + Vector2(0, abs(sin(animation_time)) * 1.5)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		# Die Vorlage schaut nach rechts; nach links wird sie gespiegelt.
		visual.flip_h = player.global_position.x < global_position.x
	else:
		visual.flip_h = direction < 0.0
	if global_position.x < start_x - 130.0 or global_position.x > start_x + 130.0 or is_on_wall():
		direction *= -1.0
