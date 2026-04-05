extends Node2D

signal fog_walk_progressed(position: Vector2)

@export var cluster_scene: PackedScene
@export var cluster_count: int = 1680
@export var world_size: Vector2 = Vector2(2048.0, 2048.0)
@export var edge_overscan: float = 260.0

var _pending_respawns: Array[Dictionary] = []
var _permanent_clear_zones: Array[Dictionary] = []

func _ready() -> void:
	_populate()

func _process(_delta: float) -> void:
	_process_respawns()

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
		var spawn_data: Dictionary = _make_spawn_data()
		if _is_inside_clear_zone(spawn_data.get("position", Vector2.ZERO)):
			continue
		_spawn_cluster(spawn_data)

func _process_respawns() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	var remaining: Array[Dictionary] = []
	for pending in _pending_respawns:
		var spawn_position: Vector2 = pending.get("position", Vector2.ZERO)
		if _is_inside_clear_zone(spawn_position):
			continue
		if float(pending.get("spawn_at", now + 1.0)) <= now:
			_spawn_cluster(pending)
		else:
			remaining.append(pending)
	_pending_respawns = remaining

func _spawn_cluster(data: Dictionary) -> void:
	if cluster_scene == null:
		return
	var cluster: Node2D = cluster_scene.instantiate() as Node2D
	cluster.cleared.connect(_on_cluster_cleared)
	add_child(cluster)
	cluster.configure_from_spawn_data(data)
	cluster.begin_respawn()

func _on_cluster_cleared(spawn_data: Dictionary) -> void:
	var spawn_position: Vector2 = spawn_data.get("position", Vector2.ZERO)
	if not _is_inside_clear_zone(spawn_position):
		_pending_respawns.append(spawn_data)

func add_permanent_clear_zone(position: Vector2, radius: float) -> void:
	_permanent_clear_zones.append({
		"position": position,
		"radius": radius,
	})
	for child in get_children():
		if child.has_method("get_representative_position") and child.has_method("begin_permanent_clear"):
			var child_position: Vector2 = child.get_representative_position()
			if child_position.distance_to(position) <= radius:
				child.begin_permanent_clear(position)

func is_position_in_active_fog(position: Vector2) -> bool:
	if _is_inside_clear_zone(position):
		return false
	for child in get_children():
		if child.has_method("is_active_fog") and child.has_method("get_representative_position") and child.is_active_fog():
			var child_position: Vector2 = child.get_representative_position()
			if child_position.distance_to(position) <= 132.0:
				return true
	return false

func _make_spawn_data() -> Dictionary:
	var opacity_scale: float = randf_range(1.0, 1.55)
	var scale: Vector2 = Vector2(randf_range(1.0, 1.3), randf_range(0.96, 1.18))
	if randf() < 0.28:
		opacity_scale = randf_range(1.45, 1.9)
		scale = Vector2(randf_range(1.2, 1.55), randf_range(1.02, 1.22))
	return {
		"position": Vector2(
			randf_range(-edge_overscan, world_size.x + edge_overscan),
			randf_range(-edge_overscan, world_size.y + edge_overscan)
		),
		"drift_angle": randf() * TAU,
		"phase_offset": randf_range(0.0, 3.0),
		"drift_speed": randf_range(0.8, 2.4),
		"opacity_scale": opacity_scale,
		"wrap_distance": randf_range(180.0, 320.0),
		"scale": scale,
		"blanket_position": Vector2(randf_range(-20.0, 20.0), randf_range(-10.0, 10.0)),
		"layer_b_position": Vector2(randf_range(-30.0, 30.0), randf_range(-14.0, 14.0)),
		"layer_c_position": Vector2(randf_range(-42.0, 42.0), randf_range(-20.0, 20.0)),
	}

func _is_inside_clear_zone(position: Vector2) -> bool:
	for zone in _permanent_clear_zones:
		var zone_position: Vector2 = zone.get("position", Vector2.ZERO)
		var zone_radius: float = float(zone.get("radius", 0.0))
		if zone_radius > 0.0 and zone_position.distance_to(position) <= zone_radius:
			return true
	return false
