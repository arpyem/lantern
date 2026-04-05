extends Node2D

@export var cluster_scene: PackedScene
@export var cluster_count: int = 420
@export var world_size: Vector2 = Vector2(2048.0, 2048.0)
@export var edge_overscan: float = 220.0

func _ready() -> void:
	_populate()

func set_focus_position(position: Vector2) -> void:
	for child in get_children():
		if child.has_method("set_focus_position"):
			child.set_focus_position(position)

func _populate() -> void:
	if cluster_scene == null:
		push_warning("FogManager requires a cluster_scene.")
		return
	for child in get_children():
		child.queue_free()
	for _index in range(cluster_count):
		var cluster := cluster_scene.instantiate() as Node2D
		cluster.position = Vector2(
			randf_range(-edge_overscan, world_size.x + edge_overscan),
			randf_range(-edge_overscan, world_size.y + edge_overscan)
		)
		cluster.set("drift_angle", randf() * TAU)
		cluster.set("phase_offset", randf_range(0.0, 3.0))
		cluster.set("drift_speed", randf_range(0.8, 2.4))
		cluster.set("opacity_scale", randf_range(0.95, 1.6))
		cluster.set("wrap_distance", randf_range(180.0, 320.0))
		cluster.scale = Vector2(randf_range(0.92, 1.22), randf_range(0.92, 1.14))
		if randf() < 0.28:
			cluster.set("opacity_scale", randf_range(1.45, 1.9))
			cluster.scale = Vector2(randf_range(1.12, 1.45), randf_range(1.0, 1.18))
		add_child(cluster)
