extends Node2D

const MAX_LIVES := GameState.MAX_LIVES
var lives := MAX_LIVES
var intro_active := true
var intro_time := 0.0
var intro_index := 0
var intro_lines := [
	"Ein eisiger Zauber hat die Tore der Winterstadt verschlossen.",
	"Nur ein mutiger Winterheld kann das magische Eistor erreichen.",
	"Besiege die Schneekobolde und bringe das Licht zurück in die Stadt!"
]

@onready var player: MainCharacter = $Player
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var lives_label: Label = $CanvasLayer/LivesLabel
@onready var final_city: Sprite2D = $FinalCity
@onready var city_transition: Sprite2D = $CityTransition
@onready var intro_layer: CanvasLayer = $IntroLayer
@onready var intro_story: Label = $IntroLayer/Story

func _ready() -> void:
	lives = GameState.lives
	player.died.connect(_on_player_died)
	final_city.modulate.a = 0.0
	city_transition.modulate.a = 0.0
	_update_lives_label()
	player.set_physics_process(false)
	status_label.hide()
	lives_label.hide()

func _process(delta: float) -> void:
	if intro_active:
		intro_time += delta
		if intro_time >= 3.0:
			intro_time = 0.0
			intro_index = (intro_index + 1) % intro_lines.size()
			intro_story.text = intro_lines[intro_index]
		return
	# Erst erscheinen Dorf und Stadtmauer, dann die große Stadt beim Eistor.
	var transition_fade: float = clamp((player.global_position.x - 1200.0) / 700.0, 0.0, 1.0)
	var city_fade: float = clamp((player.global_position.x - 2450.0) / 400.0, 0.0, 1.0)
	city_transition.modulate.a = transition_fade
	final_city.modulate.a = city_fade

func _unhandled_input(event: InputEvent) -> void:
	if intro_active and event.is_action_pressed("springen"):
		intro_active = false
		intro_layer.hide()
		player.set_physics_process(true)
		status_label.show()
		lives_label.show()
		$SoundEffects.start_game()

func _on_player_died() -> void:
	lives -= 1
	GameState.lives = lives
	if lives > 0:
		status_label.text = "Autsch! Der Level startet neu."
		_update_lives_label()
		await get_tree().create_timer(0.9).timeout
		get_tree().reload_current_scene()
	else:
		status_label.text = "Keine Leben mehr – neuer Versuch!"
		lives = MAX_LIVES
		GameState.lives = MAX_LIVES
		_update_lives_label()
		await get_tree().create_timer(1.2).timeout
		get_tree().reload_current_scene()

func _update_lives_label() -> void:
	lives_label.text = "♥ × " + str(lives)

func _on_goal_body_entered(body: Node2D) -> void:
	if body is MainCharacter:
		body.z_index = 100
		body.velocity = Vector2.ZERO
		body.set_physics_process(false)
		status_label.text = "Das Eistor öffnet sich!"
		$SoundEffects.gate_open()
		$Goal/CollisionShape2D.set_deferred("disabled", true)
		$Goal/IceGateClosed.visible = false
		$Goal/IceGateOpen.visible = true
		var gate_tween := create_tween()
		gate_tween.set_trans(Tween.TRANS_SINE)
		gate_tween.set_ease(Tween.EASE_OUT)
		$Goal/IceGateOpen.scale = Vector2(1.15, 1.15)
		gate_tween.tween_property($Goal/IceGateOpen, "scale", Vector2(1.35, 1.35), 0.45)
		await gate_tween.finished
		status_label.text = "Level geschafft!"

func _on_quit_button_pressed() -> void:
	get_tree().quit()
