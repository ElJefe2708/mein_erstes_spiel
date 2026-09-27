extends CharacterBody2D
class_name MainCharacter

signal died

@export var speed := 260.0
@export var jump_force := -460.0
const GRAVITY := 1200.0
var spawn_position := Vector2.ZERO
var is_dead := false
var animation_time := 0.0
var visual_base_position := Vector2.ZERO
var visual_base_scale := Vector2.ONE

@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	spawn_position = global_position
	visual_base_position = visual.position
	visual_base_scale = visual.scale
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	var direction := Input.get_axis("nach_links_bewegen", "nach_rechts_bewegen")
	velocity.x = move_toward(velocity.x, direction * speed, speed * 10.0 * delta)
	if Input.is_action_just_pressed("springen") and is_on_floor():
		velocity.y = jump_force
		_play_sound("jump")
	move_and_slide()
	_animate(delta, direction)
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var enemy := collision.get_collider()
		if enemy is Enemy:
			# Eine nach oben gerichtete Kollisionsnormale bedeutet: Der Spieler kam von oben.
			if collision.get_normal().y < -0.65:
				enemy.queue_free()
				velocity.y = -300.0
				_play_sound("defeat_enemy")
			else:
				die()
	if global_position.y > 760.0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	_play_sound("lose_life")
	died.emit()

func reset_to_spawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false

func _animate(delta: float, direction: float) -> void:
	var is_running: bool = false
	if abs(velocity.x) > 15.0:
		is_running = is_on_floor()
	var animation_speed: float = 3.0
	if is_running:
		animation_speed = 12.0
	animation_time += delta * animation_speed
	if direction != 0.0:
		visual.flip_h = direction < 0.0
	var bounce_amount: float = 0.7
	if is_running:
		bounce_amount = 2.5
	var bounce: float = abs(sin(animation_time)) * bounce_amount
	var squash_amount: float = 0.015
	if is_running:
		squash_amount = 0.06
	var squash: float = sin(animation_time) * squash_amount
	visual.position = visual_base_position + Vector2(0, bounce)
	visual.scale = visual_base_scale * Vector2(1.0 + squash, 1.0 - squash)

func _play_sound(effect_name: String) -> void:
	var sounds := get_tree().current_scene.get_node_or_null("SoundEffects")
	if sounds != null and sounds.has_method(effect_name):
		sounds.call(effect_name)
