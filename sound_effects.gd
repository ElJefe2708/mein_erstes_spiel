extends Node

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var frequency := 0.0
var duration := 0.0
var elapsed := 0.0
var phase := 0.0
var volume := 0.0
var music_player: AudioStreamPlayer
var music_playback: AudioStreamGeneratorPlayback
var music_phase := 0.0
var music_frame := 0
var music_active := false
var melody := [261.63, 329.63, 392.0, 329.63, 293.66, 349.23, 440.0, 349.23]

func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.2
	player = AudioStreamPlayer.new()
	player.stream = generator
	player.volume_db = -10.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback()
	var music_generator := AudioStreamGenerator.new()
	music_generator.mix_rate = 22050.0
	music_generator.buffer_length = 0.2
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_generator
	music_player.volume_db = -14.0
	add_child(music_player)
	music_player.play()
	music_playback = music_player.get_stream_playback()

func _process(_delta: float) -> void:
	if playback == null:
		playback = player.get_stream_playback()
		return
	for frame in playback.get_frames_available():
		var sample := 0.0
		if elapsed < duration:
			var progress := elapsed / duration
			sample = sin(phase) * volume * (1.0 - progress)
			phase += TAU * frequency / 22050.0
			elapsed += 1.0 / 22050.0
		playback.push_frame(Vector2(sample, sample))
	if music_playback == null:
		music_playback = music_player.get_stream_playback()
		return
	for frame in music_playback.get_frames_available():
		var music_sample := 0.0
		if music_active:
			var note_index := int(float(music_frame) / 8500.0) % melody.size()
			var note: float = melody[note_index]
			music_sample = (sin(music_phase) + sin(music_phase * 2.0) * 0.2) * 0.28
			music_phase += TAU * note / 22050.0
			music_frame += 1
		music_playback.push_frame(Vector2(music_sample, music_sample))

func jump() -> void:
	_play_tone(680.0, 0.11, 0.35)

func defeat_enemy() -> void:
	_play_tone(760.0, 0.18, 0.55)

func lose_life() -> void:
	_play_tone(360.0, 0.42, 0.6)

func gate_open() -> void:
	_play_tone(520.0, 0.6, 0.35)

func start_game() -> void:
	music_active = true
	_play_tone(440.0, 0.2, 0.3)

func _play_tone(new_frequency: float, new_duration: float, new_volume: float) -> void:
	frequency = new_frequency
	duration = new_duration
	volume = new_volume
	elapsed = 0.0
	phase = 0.0
