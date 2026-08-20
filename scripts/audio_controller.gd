class_name OrbitAudioController
extends Node

enum Sound { LAUNCH, LAND, PERFECT, FAIL, UI }

const SOUND_STREAMS := {
	Sound.LAUNCH: preload("res://assets/audio/launch.wav"),
	Sound.LAND: preload("res://assets/audio/land.wav"),
	Sound.PERFECT: preload("res://assets/audio/perfect.wav"),
	Sound.FAIL: preload("res://assets/audio/fail.wav"),
	Sound.UI: preload("res://assets/audio/ui.wav"),
}
const MUSIC_BASE := preload("res://assets/audio/music_base.wav")
const MUSIC_DRIVE := preload("res://assets/audio/music_drive.wav")

var playback_enabled: bool = true
var music_enabled: bool = true
var music_paused: bool = false
var base_player: AudioStreamPlayer
var drive_player: AudioStreamPlayer


func _ready() -> void:
	var audio_output_available := DisplayServer.get_name() != "headless"
	base_player = _make_music_player(MUSIC_BASE if audio_output_available else null, -18.0)
	drive_player = _make_music_player(MUSIC_DRIVE if audio_output_available else null, -36.0)
	if audio_output_available:
		base_player.play()
		drive_player.play()


func _make_music_player(stream: AudioStreamWAV, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	if stream:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
		player.stream = stream
	player.volume_db = volume
	add_child(player)
	return player


func play(sound: Sound) -> void:
	if not playback_enabled or not SOUND_STREAMS.has(sound):
		return
	var player := AudioStreamPlayer.new()
	player.stream = SOUND_STREAMS[sound]
	player.volume_db = -5.0 if sound != Sound.PERFECT else -2.0
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func apply_settings(sound_on: bool, music_on: bool) -> void:
	playback_enabled = sound_on
	music_enabled = music_on
	if base_player:
		base_player.volume_db = -18.0 if music_enabled else -80.0
	if drive_player:
		drive_player.volume_db = -36.0 if music_enabled else -80.0


func set_intensity(combo: int, zone: int) -> void:
	if not base_player or not drive_player:
		return
	var intensity := clampf(float(combo - 1) / 4.0, 0.0, 1.0)
	base_player.pitch_scale = 1.0 + float(zone) * 0.035
	drive_player.pitch_scale = base_player.pitch_scale
	if music_enabled:
		drive_player.volume_db = lerpf(-34.0, -8.0, intensity)


func set_music_paused(value: bool) -> void:
	music_paused = value
	if base_player:
		base_player.stream_paused = value
	if drive_player:
		drive_player.stream_paused = value


func _exit_tree() -> void:
	for child in get_children():
		var player := child as AudioStreamPlayer
		if player:
			player.stop()
			player.stream = null
	base_player = null
	drive_player = null
