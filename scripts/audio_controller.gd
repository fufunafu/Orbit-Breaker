class_name OrbitAudioController
extends Node

enum Sound {
	LAUNCH,
	LAND,
	PERFECT,
	FAIL,
}

const SAMPLE_RATE := 44100
var streams: Dictionary = {}
var playback_enabled: bool = true


func _ready() -> void:
	streams[Sound.LAUNCH] = _make_tone(360.0, 760.0, 0.12, 0.34, 0.0)
	streams[Sound.LAND] = _make_tone(210.0, 420.0, 0.15, 0.34, 0.18)
	streams[Sound.PERFECT] = _make_tone(520.0, 1180.0, 0.27, 0.32, 0.32)
	streams[Sound.FAIL] = _make_tone(180.0, 52.0, 0.42, 0.42, 0.08)


func play(sound: Sound) -> void:
	if not playback_enabled or not streams.has(sound):
		return
	var player := AudioStreamPlayer.new()
	player.stream = streams[sound]
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func _exit_tree() -> void:
	for child in get_children():
		var player := child as AudioStreamPlayer
		if player:
			player.stop()
	streams.clear()


func _make_tone(
	start_frequency: float,
	end_frequency: float,
	duration: float,
	volume: float,
	harmonic_mix: float
) -> AudioStreamWAV:
	var frame_count := maxi(1, int(duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(frame_count * 2)
	var phase := 0.0
	for frame in frame_count:
		var progress := float(frame) / float(frame_count)
		var frequency := lerpf(start_frequency, end_frequency, progress)
		phase += TAU * frequency / float(SAMPLE_RATE)
		var envelope := pow(1.0 - progress, 2.2) * minf(1.0, progress * 28.0)
		var sample := sin(phase) + sin(phase * 2.0) * harmonic_mix
		var pcm := clampi(int(sample * envelope * volume * 32767.0), -32768, 32767)
		data.encode_s16(frame * 2, pcm)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream
