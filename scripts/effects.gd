class_name OrbitEffects
extends Node2D

var particles: Array[Dictionary] = []
var reduced_motion: bool = false


func burst(world_position: Vector2, color: Color, count: int, power: float = 260.0) -> void:
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = Time.get_ticks_usec()
	var effective_count := mini(count, 8) if reduced_motion else count
	for index in effective_count:
		var direction := Vector2.from_angle(local_rng.randf_range(0.0, TAU))
		var lifetime := local_rng.randf_range(0.34, 0.72)
		particles.append({
			"position": world_position,
			"velocity": direction * local_rng.randf_range(power * 0.35, power),
			"life": lifetime,
			"max_life": lifetime,
			"size": local_rng.randf_range(3.0, 9.0),
			"color": color,
		})
	queue_redraw()


func _process(delta: float) -> void:
	if particles.is_empty():
		return
	for index in range(particles.size() - 1, -1, -1):
		var particle := particles[index]
		particle.life = float(particle.life) - delta
		if float(particle.life) <= 0.0:
			particles.remove_at(index)
			continue
		particle.position = Vector2(particle.position) + Vector2(particle.velocity) * delta
		particle.velocity = Vector2(particle.velocity) * pow(0.04, delta)
		particles[index] = particle
	queue_redraw()


func _draw() -> void:
	for particle in particles:
		var life_ratio := float(particle.life) / float(particle.max_life)
		var particle_color: Color = particle.color
		particle_color.a = life_ratio
		var draw_position := to_local(Vector2(particle.position))
		draw_circle(draw_position, float(particle.size) * life_ratio, particle_color)
