extends Node2D

signal cleared(spawn_data: Dictionary)

enum FogState { ACTIVE, FADING_OUT, RESPAWNING }

@export var drift_speed: float = 1.6
@export var drift_angle: float = 0.0
@export var phase_offset: float = 0.0
@export var opacity_scale: float = 1.0
@export var wrap_distance: float = 240.0
@export var proximity_radius: float = 124.0
@export var fade_out_duration: float = 1.6
@export var cleared_duration: float = 10.0
@export var fade_in_duration: float = 0.65
@export var max_push_distance: float = 116.0

var _spawn_origin: Vector2
var _focus_position: Vector2 = Vector2.INF
var _state: FogState = FogState.ACTIVE
var _transition_timer: float = 0.0
var _transition_progress: float = 0.0
var _transition_direction: Vector2 = Vector2.ZERO
var _pending_spawn_data: Dictionary = {}

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

	if not _pending_spawn_data.is_empty():
		_apply_spawn_data(_pending_spawn_data)
		_pending_spawn_data = {}

	_spawn_origin = position
	if layer_blanket.position == Vector2.ZERO:
		layer_blanket.position = Vector2(randf_range(-20.0, 20.0), randf_range(-10.0, 10.0))
	if layer_b.position == Vector2.ZERO:
		layer_b.position = Vector2(randf_range(-30.0, 30.0), randf_range(-14.0, 14.0))
	if layer_c.position == Vector2.ZERO:
		layer_c.position = Vector2(randf_range(-42.0, 42.0), randf_range(-20.0, 20.0))

	_base_blanket_position = layer_blanket.position
	_base_blanket_scale = layer_blanket.scale
	_base_layer_a_scale = layer_a.scale
	_base_layer_b_position = layer_b.position
	_base_layer_b_scale = layer_b.scale
	_base_layer_c_position = layer_c.position
	_base_layer_c_scale = layer_c.scale

	layer_blanket.modulate = Color(0.66, 0.74, 0.84, 0.28 * opacity_scale)
	layer_a.modulate = Color(0.69, 0.77, 0.88, 0.20 * opacity_scale)
	layer_b.modulate = Color(0.70, 0.79, 0.90, 0.13 * opacity_scale)
	layer_c.modulate = Color(0.72, 0.81, 0.92, 0.08 * opacity_scale)

	layer_blanket.frame = randi() % 4
	layer_a.frame = randi() % 4
	layer_b.frame = randi() % 4
	layer_c.frame = randi() % 4

	_build_animation()
	animation_player.play("breathe")
	animation_player.seek(fposmod(phase_offset, 3.0), true)
	_apply_visuals(1.0, Vector2.ZERO)

func _process(delta: float) -> void:
	if _state == FogState.ACTIVE or _state == FogState.RESPAWNING:
		position += Vector2.from_angle(drift_angle) * drift_speed * delta
		if position.distance_to(_spawn_origin) > wrap_distance:
			position = _spawn_origin

	match _state:
		FogState.ACTIVE:
			_update_active_state()
		FogState.FADING_OUT:
			_update_fade_out(delta)
		FogState.RESPAWNING:
			_update_respawn(delta)

func set_focus_position(position: Vector2) -> void:
	_focus_position = position

func configure_from_spawn_data(data: Dictionary) -> void:
	_pending_spawn_data = data.duplicate(true)
	if not is_node_ready():
		return
	_apply_spawn_data(_pending_spawn_data)
	_pending_spawn_data = {}

func begin_respawn() -> void:
	if not is_node_ready():
		call_deferred("begin_respawn")
		return
	_state = FogState.RESPAWNING
	_transition_timer = 0.0
	_transition_progress = 0.0
	_transition_direction = Vector2.ZERO
	_capture_bases()
	_refresh_layer_appearance()
	animation_player.play("breathe")
	animation_player.seek(fposmod(phase_offset, 3.0), true)
	_apply_visuals(0.0, Vector2.ZERO)

func _update_active_state() -> void:
	if _focus_position == Vector2.INF:
		return
	if _representative_position().distance_to(_focus_position) > proximity_radius:
		return
	_state = FogState.FADING_OUT
	_transition_timer = 0.0
	_transition_progress = 0.0
	_transition_direction = _push_direction()

func _update_fade_out(delta: float) -> void:
	_transition_timer += delta
	_transition_progress = clampf(_transition_timer / max(fade_out_duration, 0.001), 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - _transition_progress, 3.0)
	_apply_visuals(1.0 - eased, _transition_direction * eased)
	if _transition_progress >= 1.0:
		cleared.emit(_make_spawn_data())
		queue_free()

func _update_respawn(delta: float) -> void:
	_transition_timer += delta
	_transition_progress = clampf(_transition_timer / max(fade_in_duration, 0.001), 0.0, 1.0)
	var eased := _transition_progress * _transition_progress * (3.0 - 2.0 * _transition_progress)
	_apply_visuals(eased, _transition_direction * (1.0 - eased))
	if _transition_progress >= 1.0:
		_state = FogState.ACTIVE
		_transition_timer = 0.0
		_transition_progress = 1.0
		_apply_visuals(1.0, Vector2.ZERO)

func _representative_position() -> Vector2:
	return layer_blanket.global_position

func _push_direction() -> Vector2:
	if _focus_position == Vector2.INF:
		return Vector2.ZERO
	var direction := _representative_position() - _focus_position
	if direction.length_squared() <= 0.001:
		return Vector2.RIGHT if randf() >= 0.5 else Vector2.LEFT
	var horizontal_sign := signf(direction.x)
	if is_zero_approx(horizontal_sign):
		horizontal_sign = 1.0 if randf() >= 0.5 else -1.0
	return Vector2(horizontal_sign, 0.0)

func _apply_visuals(visibility_ratio: float, push_ratio: Vector2) -> void:
	var blanket_push := push_ratio * max_push_distance
	var layer_a_push := push_ratio * max_push_distance * 0.78
	var layer_b_push := push_ratio * max_push_distance * 0.9
	var layer_c_push := push_ratio * max_push_distance

	layer_blanket.position = _base_blanket_position + blanket_push
	layer_a.position = layer_a_push
	layer_b.position = _base_layer_b_position + layer_b_push
	layer_c.position = _base_layer_c_position + layer_c_push

	layer_blanket.modulate.a = 0.28 * opacity_scale * visibility_ratio
	layer_a.modulate.a = 0.20 * opacity_scale * visibility_ratio
	layer_b.modulate.a = 0.13 * opacity_scale * visibility_ratio
	layer_c.modulate.a = 0.08 * opacity_scale * visibility_ratio

	layer_blanket.scale = _base_blanket_scale * lerpf(1.12, 1.0, visibility_ratio)
	layer_a.scale = _base_layer_a_scale * lerpf(1.10, 1.0, visibility_ratio)
	layer_b.scale = _base_layer_b_scale * lerpf(1.08, 1.0, visibility_ratio)
	layer_c.scale = _base_layer_c_scale * lerpf(1.06, 1.0, visibility_ratio)

func _capture_bases() -> void:
	_base_blanket_position = layer_blanket.position
	_base_blanket_scale = layer_blanket.scale
	_base_layer_a_scale = layer_a.scale
	_base_layer_b_position = layer_b.position
	_base_layer_b_scale = layer_b.scale
	_base_layer_c_position = layer_c.position
	_base_layer_c_scale = layer_c.scale

func _refresh_layer_appearance() -> void:
	layer_blanket.modulate = Color(0.66, 0.74, 0.84, 0.28 * opacity_scale)
	layer_a.modulate = Color(0.69, 0.77, 0.88, 0.20 * opacity_scale)
	layer_b.modulate = Color(0.70, 0.79, 0.90, 0.13 * opacity_scale)
	layer_c.modulate = Color(0.72, 0.81, 0.92, 0.08 * opacity_scale)

func _make_spawn_data() -> Dictionary:
	return {
		"spawn_at": Time.get_ticks_msec() / 1000.0 + cleared_duration,
		"position": _spawn_origin + Vector2(randf_range(-32.0, 32.0), randf_range(-18.0, 18.0)),
		"drift_angle": randf() * TAU,
		"drift_speed": randf_range(0.8, 2.4),
		"phase_offset": randf_range(0.0, 3.0),
		"opacity_scale": randf_range(0.8, 1.25),
		"wrap_distance": randf_range(180.0, 320.0),
		"scale": Vector2(randf_range(0.92, 1.22), randf_range(0.92, 1.14)),
		"blanket_position": Vector2(randf_range(-20.0, 20.0), randf_range(-10.0, 10.0)),
		"layer_b_position": Vector2(randf_range(-30.0, 30.0), randf_range(-14.0, 14.0)),
		"layer_c_position": Vector2(randf_range(-42.0, 42.0), randf_range(-20.0, 20.0)),
	}

func _apply_spawn_data(data: Dictionary) -> void:
	position = data.get("position", position)
	_spawn_origin = position
	drift_angle = float(data.get("drift_angle", drift_angle))
	drift_speed = float(data.get("drift_speed", drift_speed))
	phase_offset = float(data.get("phase_offset", phase_offset))
	opacity_scale = float(data.get("opacity_scale", opacity_scale))
	wrap_distance = float(data.get("wrap_distance", wrap_distance))
	scale = data.get("scale", scale)
	layer_blanket.position = data.get("blanket_position", layer_blanket.position)
	layer_b.position = data.get("layer_b_position", layer_b.position)
	layer_c.position = data.get("layer_c_position", layer_c.position)

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
