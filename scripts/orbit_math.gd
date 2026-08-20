class_name OrbitMath
extends RefCounted


static func orbit_position(center: Vector2, radius: float, angle: float) -> Vector2:
	return center + Vector2.from_angle(angle) * radius


static func tangent_for_angle(angle: float, direction: int) -> Vector2:
	var tangent := Vector2(-sin(angle), cos(angle))
	return tangent * signi(direction)


static func direction_from_velocity(radial: Vector2, velocity: Vector2) -> int:
	if radial.cross(velocity) < 0.0:
		return -1
	return 1


static func ray_miss_distance(origin: Vector2, direction: Vector2, target: Vector2) -> float:
	var normalized_direction := direction.normalized()
	return absf((target - origin).cross(normalized_direction))


static func target_is_in_front(origin: Vector2, direction: Vector2, target: Vector2) -> bool:
	return (target - origin).dot(direction.normalized()) > 0.0


static func tangent_launch_window(
	orbit_center: Vector2,
	orbit_radius: float,
	target: Vector2,
	capture_radius: float
) -> float:
	var distance := orbit_center.distance_to(target)
	if distance <= 0.0 or orbit_radius <= 0.0 or capture_radius <= 0.0:
		return 0.0
	var near_ratio := clampf((orbit_radius - capture_radius) / distance, -1.0, 1.0)
	var far_ratio := clampf((orbit_radius + capture_radius) / distance, -1.0, 1.0)
	return maxf(0.0, acos(near_ratio) - acos(far_ratio))


static func segment_circle_hit_fraction(
	start: Vector2,
	finish: Vector2,
	center: Vector2,
	radius: float
) -> float:
	if start.distance_squared_to(center) <= radius * radius:
		return 0.0
	var segment := finish - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.000001:
		return -1.0
	var offset := start - center
	var half_b := offset.dot(segment)
	var discriminant := half_b * half_b - length_squared * (offset.length_squared() - radius * radius)
	if discriminant < 0.0:
		return -1.0
	var hit_fraction := (-half_b - sqrt(discriminant)) / length_squared
	if hit_fraction < 0.0 or hit_fraction > 1.0:
		return -1.0
	return hit_fraction


static func layout_is_reachable(
	origin: Vector2,
	orbit_radius: float,
	target: Vector2,
	target_radius: float,
	minimum_separation: float,
	maximum_distance: float
) -> bool:
	var distance := origin.distance_to(target)
	var minimum_distance := orbit_radius + target_radius + minimum_separation
	return (
		distance >= minimum_distance
		and distance <= maximum_distance
		and tangent_launch_window(origin, orbit_radius, target, target_radius) > 0.0
	)


static func ray_circle_hit_distance(origin: Vector2, direction: Vector2, center: Vector2, radius: float) -> float:
	var normalized_direction := direction.normalized()
	var offset := origin - center
	if offset.length_squared() <= radius * radius:
		return 0.0
	var half_b := offset.dot(normalized_direction)
	var discriminant := half_b * half_b - (offset.length_squared() - radius * radius)
	if discriminant < 0.0:
		return -1.0
	var distance := -half_b - sqrt(discriminant)
	return distance if distance >= 0.0 else -1.0


static func safe_launch_sample_count(
	orbit_center: Vector2,
	orbit_radius: float,
	orbit_direction: int,
	target: Vector2,
	capture_radius: float,
	hazard: Vector2,
	hazard_radius: float,
	sample_count: int = 180
) -> int:
	return safe_launch_sample_count_for_hazards(
		orbit_center,
		orbit_radius,
		orbit_direction,
		target,
		capture_radius,
		[{"position": hazard, "radius": hazard_radius}],
		sample_count
	)


static func safe_launch_sample_count_for_hazards(
	orbit_center: Vector2,
	orbit_radius: float,
	orbit_direction: int,
	target: Vector2,
	capture_radius: float,
	hazards: Array,
	sample_count: int = 180
) -> int:
	var safe_samples := 0
	for index in sample_count:
		var angle := TAU * float(index) / float(sample_count)
		var origin := orbit_position(orbit_center, orbit_radius, angle)
		var direction := tangent_for_angle(angle, orbit_direction)
		var target_distance := ray_circle_hit_distance(origin, direction, target, capture_radius)
		if target_distance < 0.0:
			continue
		var blocked := false
		for hazard_data in hazards:
			if not hazard_data is Dictionary:
				continue
			var hazard_distance := ray_circle_hit_distance(
				origin,
				direction,
				Vector2(hazard_data.get("position", Vector2.ZERO)),
				float(hazard_data.get("radius", 0.0))
			)
			if hazard_distance >= 0.0 and hazard_distance < target_distance:
				blocked = true
				break
		if not blocked:
			safe_samples += 1
	return safe_samples
