extends Node2D

@export var drift_speed: float = 4.0
@export var drift_angle: float = 0.0
@export var phase_offset: float = 0.0
@export var opacity_scale: float = 1.0
@export var wrap_distance: float = 240.0
@export var full_clear_radius: float = 84.0
@export var feather_radius: float = 76.0
@export var clear_fade_duration: float = 0.12
@export var cleared_hold_duration: float = 10.0
@export var return_duration: float = 1.2

var _spawn_origin: Vector2
var _focus_position: Vector2 = Vector2.INF
var _blanket_hold_timer: float = 0.0
var _a_hold_timer: float = 0.0
var _b_hold_timer: float = 0.0
var _c_hold_timer: float = 0.0
var _clear_strength_blanket: float = 0.0
var _clear_strength_a: float = 0.0
var _clear_strength_b: float = 0.0
var _clear_strength_c: float = 0.0
var _base_blanket_position: Vector2
var _base_blanket_scale: Vector2
var _base_layer_a_scale: Vector2
var _base_layer_b_position: Vector2
var _base_layer_b_scale: Vector2
var _base_layer_c_position: Vector2
var _base_layer_c_scale: Vector2

@onready var layer_blanket: Sprite2D = $LayerBlanket
@onready var layer_a: Sprite2D = $LayerA
@onready var layer_b: Sprite2D = $LayerB
@onready var layer_c: Sprite2D = $LayerC
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_spawn_origin = position
	layer_blanket.texture = _load_texture("fog/fog_blanket.png", "res://assets/placeholder/fog/fog_blanket.png")
	layer_a.texture = _load_texture("fog/fog_large.png", "res://assets/placeholder/fog/fog_large.png")
	layer_b.texture = _load_texture("fog/fog_medium.png", "res://assets/placeholder/fog/fog_medium.png")
	layer_c.texture = _load_texture("fog/fog_small.png", "res://assets/placeholder/fog/fog_small.png")
	layer_blanket.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	layer_a.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	layer_b.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	layer_c.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	layer_blanket.scale = Vector2(1.9, 1.5)
	layer_a.scale = Vector2(1.8, 1.45)
	layer_b.scale = Vector2(1.65, 1.35)
	layer_c.scale = Vector2(1.45, 1.25)

	layer_blanket.position = Vector2(randf_range(-20.0, 20.0), randf_range(-10.0, 10.0))
	layer_b.position = Vector2(randf_range(-30.0, 30.0), randf_range(-14.0, 14.0))
	layer_c.position = Vector2(randf_range(-42.0, 42.0), randf_range(-20.0, 20.0))
	_base_blanket_position = layer_blanket.position
	_base_blanket_scale = layer_blanket.scale
	_base_layer_a_scale = layer_a.scale
	_base_layer_b_position = layer_b.position
	_base_layer_b_scale = layer_b.scale
	_base_layer_c_position = layer_c.position
	_base_layer_c_scale = layer_c.scale

	layer_blanket.modulate = Color(0.66, 0.74, 0.84, 0.34 * opacity_scale)
	layer_a.modulate = Color(0.69, 0.77, 0.88, 0.26 * opacity_scale)
	layer_b.modulate = Color(0.70, 0.79, 0.90, 0.18 * opacity_scale)
	layer_c.modulate = Color(0.72, 0.81, 0.92, 0.11 * opacity_scale)

	layer_blanket.frame = randi() % 4
	layer_a.frame = randi() % 4
	layer_b.frame = randi() % 4
	layer_c.frame = randi() % 4

	_build_animation()
	animation_player.play("breathe")
	animation_player.seek(fposmod(phase_offset, 3.0), true)

func _process(delta: float) -> void:
	position += Vector2.from_angle(drift_angle) * drift_speed * delta
	if position.distance_to(_spawn_origin) > wrap_distance:
		position = _spawn_origin
	_update_disturbance(delta)

func set_focus_position(position: Vector2) -> void:
	_focus_position = position

func _asset_path(relative_path: String, fallback_path: String) -> String:
	if get_node_or_null("/root/AssetConfig") != null:
		return AssetConfig.path(relative_path)
	return fallback_path

func _load_texture(relative_path: String, fallback_path: String) -> Texture2D:
	return load(_asset_path(relative_path, fallback_path)) as Texture2D

func _build_animation() -> void:
	var animation := Animation.new()
	animation.length = 3.0
	animation.loop_mode = Animation.LOOP_LINEAR
	_add_frame_track(animation, "LayerBlanket:frame", [2, 3, 0, 1], 0.15)
	_add_frame_track(animation, "LayerA:frame", [3, 0, 1, 2], 0.0)
	_add_frame_track(animation, "LayerB:frame", [3, 0, 1, 2], 0.4)
	_add_frame_track(animation, "LayerC:frame", [3, 0, 1, 2], 0.8)
	var library := AnimationLibrary.new()
	library.add_animation("breathe", animation)
	animation_player.add_animation_library("", library)

func _add_frame_track(animation: Animation, property_path: String, frames: Array[int], offset: float) -> void:
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(property_path))
	for index in range(frames.size()):
		var time := fposmod(float(index) + offset, animation.length)
		animation.track_insert_key(track, time, frames[index])

func _update_disturbance(delta: float) -> void:
	if _focus_position == Vector2.INF:
		return
	_clear_strength_blanket = _update_layer_clear_strength(
		layer_blanket.global_position,
		_clear_strength_blanket,
		_blanket_hold_timer,
		delta,
		1.0
	)
	_blanket_hold_timer = _update_hold_timer(layer_blanket.global_position, _blanket_hold_timer, delta)
	_clear_strength_a = _update_layer_clear_strength(
		layer_a.global_position,
		_clear_strength_a,
		_a_hold_timer,
		delta,
		1.0
	)
	_a_hold_timer = _update_hold_timer(layer_a.global_position, _a_hold_timer, delta)
	_clear_strength_b = _update_layer_clear_strength(
		layer_b.global_position,
		_clear_strength_b,
		_b_hold_timer,
		delta,
		0.96
	)
	_b_hold_timer = _update_hold_timer(layer_b.global_position, _b_hold_timer, delta)
	_clear_strength_c = _update_layer_clear_strength(
		layer_c.global_position,
		_clear_strength_c,
		_c_hold_timer,
		delta,
		0.9
	)
	_c_hold_timer = _update_hold_timer(layer_c.global_position, _c_hold_timer, delta)

	_apply_layer_disturbance(layer_blanket, _base_blanket_position, _base_blanket_scale, 0.34 * opacity_scale, _clear_strength_blanket, 42.0, 1.08)
	_apply_layer_disturbance(layer_a, Vector2.ZERO, _base_layer_a_scale, 0.26 * opacity_scale, _clear_strength_a, 56.0, 1.06)
	_apply_layer_disturbance(layer_b, _base_layer_b_position, _base_layer_b_scale, 0.18 * opacity_scale, _clear_strength_b, 70.0, 1.04)
	_apply_layer_disturbance(layer_c, _base_layer_c_position, _base_layer_c_scale, 0.11 * opacity_scale, _clear_strength_c, 84.0, 1.02)

func _update_layer_clear_strength(layer_world_position: Vector2, current_strength: float, hold_timer: float, delta: float, max_strength: float) -> float:
	var target_strength := _target_clear_strength(layer_world_position) * max_strength
	if target_strength > 0.0:
		return move_toward(current_strength, target_strength, delta / max(clear_fade_duration, 0.001))
	if hold_timer > 0.0:
		return current_strength
	return move_toward(current_strength, 0.0, delta / max(return_duration, 0.001))

func _update_hold_timer(layer_world_position: Vector2, current_timer: float, delta: float) -> float:
	if _target_clear_strength(layer_world_position) > 0.0:
		return cleared_hold_duration
	return max(current_timer - delta, 0.0)

func _target_clear_strength(layer_world_position: Vector2) -> float:
	var distance := layer_world_position.distance_to(_focus_position)
	if distance <= full_clear_radius:
		return 1.0
	var outer_radius := full_clear_radius + feather_radius
	if distance >= outer_radius:
		return 0.0
	var t: float = 1.0 - (distance - full_clear_radius) / max(feather_radius, 0.001)
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _apply_layer_disturbance(layer: Sprite2D, base_position: Vector2, base_scale: Vector2, base_alpha: float, clear_strength: float, displacement_amount: float, scale_boost: float) -> void:
	var direction := Vector2.ZERO
	var local_focus := _focus_position - global_position
	if base_position.distance_to(local_focus) > 0.001:
		direction = base_position.direction_to(local_focus) * -1.0
	layer.position = base_position + direction * displacement_amount * clear_strength
	layer.modulate.a = base_alpha * (1.0 - clear_strength)
	layer.scale = base_scale * lerpf(1.0, scale_boost, clear_strength)
