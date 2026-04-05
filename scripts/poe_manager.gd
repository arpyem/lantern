extends Node2D

@export var max_poes: int = 12
@export var spawn_interval: float = 3.0
@export var spawn_radius_min: float = 120.0
@export var spawn_radius_max: float = 320.0
@export var spawn_attempts_per_tick: int = 8
@export var world_size: Vector2 = Vector2(2048, 2048)

var _lantern_position: Vector2 = Vector2(1024, 1024)
var _poe_scene: PackedScene = preload("res://scenes/poe.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_attempt)
	spawn_timer.start()

func _on_lantern_moved(position: Vector2) -> void:
	_lantern_position = position
	for child in get_children():
		if child.has_method("set_lantern_position"):
			child.set_lantern_position(position)

func _spawn_attempt() -> void:
	var active_poes: int = 0
	for child in get_children():
		if child is Area2D:
			active_poes += 1
	if active_poes >= max_poes:
		return
	var candidate := Vector2.ZERO
	var found_candidate := false
	for _attempt in range(max(spawn_attempts_per_tick, 1)):
		var angle: float = randf() * TAU
		var distance: float = randf_range(spawn_radius_min, spawn_radius_max)
		candidate = _lantern_position + Vector2.RIGHT.rotated(angle) * distance
		if _is_in_bounds(candidate) and not _is_too_close_to_existing(candidate):
			found_candidate = true
			break
	if not found_candidate:
		return
	var poe: Area2D = _poe_scene.instantiate() as Area2D
	poe.global_position = candidate
	poe.poe_type = _pick_type()
	poe.color = _type_color(poe.poe_type)
	poe.set_lantern_position(_lantern_position)
	poe.collected.connect(_on_poe_collected)
	add_child(poe)

func _pick_type() -> String:
	var roll: float = randf()
	if roll <= 0.7:
		return "common"
	if roll <= 0.9:
		return "ember"
	return "wisp"

func _type_color(type: String) -> Color:
	match type:
		"ember":
			return Color(1.0, 0.65, 0.2)
		"wisp":
			return Color(0.6, 1.0, 0.7)
		_:
			return Color(0.7, 0.85, 1.0)

func _on_poe_collected(_poe_type: String) -> void:
	pass

func _is_in_bounds(position: Vector2) -> bool:
	return position.x >= 0.0 and position.x <= world_size.x and position.y >= 0.0 and position.y <= world_size.y

func _is_too_close_to_existing(position: Vector2) -> bool:
	for child in get_children():
		if child is Area2D and child.global_position.distance_to(position) < 48.0:
			return true
	return false
