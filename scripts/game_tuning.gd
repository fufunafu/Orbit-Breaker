class_name GameTuning
extends Resource

@export_category("Ship")
@export var ship_radius: float = 18.0
@export var orbit_clearance: float = 30.0
@export var launch_speed: float = 960.0
@export var base_orbit_speed: float = 1.85
@export var orbit_speed_per_tier: float = 0.16
@export var maximum_orbit_speed: float = 3.15
@export var flight_timeout: float = 3.2

@export_category("Planet generation")
@export var base_min_planet_radius: float = 78.0
@export var base_max_planet_radius: float = 132.0
@export var minimum_planet_radius: float = 52.0
@export var radius_reduction_per_tier: float = 6.0
@export var minimum_vertical_gap: float = 360.0
@export var maximum_vertical_gap: float = 525.0
@export var placement_window_tightening_per_tier: float = 14.0
@export var minimum_placement_window_size: float = 45.0
@export var maximum_horizontal_shift: float = 390.0
@export var minimum_planet_separation: float = 72.0
@export var maximum_target_distance: float = 690.0
@export_range(0.1, 0.9, 0.05) var perfect_zone_ratio: float = 0.42

@export_category("Hazards")
@export var hazards_begin_at_landing: int = 10
@export var base_hazard_chance: float = 0.42
@export var hazard_chance_per_tier: float = 0.05
@export var maximum_hazard_chance: float = 0.72
@export var minimum_hazard_radius: float = 25.0
@export var maximum_hazard_radius: float = 42.0
@export var pulse_hazards_begin_at_landing: int = 20
@export var combined_hazards_begin_at_landing: int = 30
@export var minimum_safe_launch_samples: int = 5

@export_category("Progression")
@export var nebula_zone_score: int = 10
@export var sunforge_zone_score: int = 25

@export_category("Camera and feedback")
@export var camera_follow_speed: float = 5.5
@export var camera_vertical_lead: float = 205.0
@export var screen_shake_strength: float = 18.0
@export var particle_count_landing: int = 22
@export var particle_count_perfect: int = 42
