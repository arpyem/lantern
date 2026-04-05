extends Area2D

signal recruited(poe)
signal spent_arrived(poe)

enum PoeState { WANDERING, ATTRACTED, FOLLOWING, SPENDING }

@export var poe_type := "common"
@export var attraction_radius := 180.0
@export var move_speed := 52.0
@export var wander_speed := 14.0
@export var recruit_radius := 18.0
@export var spend_arrive_radius := 10.0
@export var color := Color(0.7, 0.85, 1.0)
@export var follow_hover_x := 6.0
@export var follow_hover_y := 5.0
@export var follow_speed_near := 320.0
@export var follow_speed_far := 420.0
@export var follow_far_threshold := 64.0

var state := PoeState.WANDERING
var lantern_position := Vector2.ZERO
var player_position := Vector2.ZERO
var follow_target := Vector2.ZERO
var _wander_direction := Vector2.RIGHT
var _wander_timer := 0.0
var _float_time := 0.0
var _follow_slot_index := 0
var _spend_target := Vector2.ZERO

@onready var poe_sprite: Sprite2D = $PoeSprite
@onready var glow_light: PointLight2D = $GlowLight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_burst: GPUParticles2D = $StateBurst
@onready var travel_trail: GPUParticles2D = $TravelTrail

var _visual_tween: Tween

func _ready() -> void:
	_apply_type_visual()
	_setup_glow()
	_setup_particles()
	_pick_new_wander_direction()
	_setup_float_animation()

func _physics_process(delta: float) -> void:
	_float_time += delta
	match state:
		PoeState.WANDERING:
			_process_wander(delta)
		PoeState.ATTRACTED:
			_process_attracted(delta)
		PoeState.FOLLOWING:
			_process_following(delta)
		PoeState.SPENDING:
			_process_spending(delta)

func set_lantern_position(position: Vector2) -> void:
	lantern_position = position

func set_player_position(position: Vector2) -> void:
	player_position = position

func begin_following(slot_index: int) -> void:
	state = PoeState.FOLLOWING
	_follow_slot_index = slot_index
	modulate.a = 1.0
	_play_state_transition(Color(0.9, 1.0, 1.22, 1.0), 1.3, 0.82)
	state_burst.restart()
	state_burst.emitting = true
	travel_trail.emitting = false
	_spawn_world_burst(Color(0.86, 0.96, 1.0, 0.75), 8, 0.22)

func set_follow_target_position(position: Vector2, slot_index: int) -> void:
	follow_target = position
	_follow_slot_index = slot_index

func begin_spend(target_position: Vector2) -> void:
	state = PoeState.SPENDING
	_spend_target = target_position
	_play_state_transition(Color(1.2, 0.92, 0.56, 1.0), 1.45, 1.1)
	state_burst.restart()
	state_burst.emitting = true
	travel_trail.restart()
	travel_trail.emitting = true

func _process_wander(delta: float) -> void:
	var distance: float = global_position.distance_to(lantern_position)
	if distance <= attraction_radius:
		state = PoeState.ATTRACTED
		_play_state_transition(Color(0.82, 0.9, 1.08, 1.0), 1.08, 0.55)
		return
	_wander(delta)

func _process_attracted(delta: float) -> void:
	var distance: float = global_position.distance_to(lantern_position)
	if distance > attraction_radius * 1.5:
		state = PoeState.WANDERING
		return
	if global_position.distance_to(player_position) <= recruit_radius:
		recruited.emit(self)
		return
	var seek: Vector2 = global_position.direction_to(lantern_position)
	var sway: Vector2 = Vector2(sin(_float_time * 4.6 + _follow_slot_index), cos(_float_time * 3.8 + _follow_slot_index * 0.7)) * 12.0
	global_position += (seek * move_speed + sway) * delta

func _process_following(delta: float) -> void:
	var hover: Vector2 = Vector2(
		sin(_float_time * 2.6 + float(_follow_slot_index) * 1.7) * follow_hover_x,
		cos(_float_time * 3.4 + float(_follow_slot_index) * 1.2) * follow_hover_y
	)
	var raw_target: Vector2 = follow_target - global_position
	var hover_ratio: float = clampf(1.0 - raw_target.length() / 120.0, 0.18, 1.0)
	var desired: Vector2 = follow_target + hover * hover_ratio
	var to_target: Vector2 = desired - global_position
	var follow_speed: float = follow_speed_far if to_target.length() >= follow_far_threshold else follow_speed_near
	global_position += to_target.limit_length(follow_speed * delta)
	modulate.a = 1.0

func _process_spending(delta: float) -> void:
	var to_target: Vector2 = _spend_target - global_position
	if to_target.length() <= spend_arrive_radius:
		travel_trail.emitting = false
		_play_state_transition(Color(1.4, 0.92, 0.5, 1.0), 0.55, 1.15)
		_spawn_world_burst(Color(1.0, 0.84, 0.48, 0.8), 10, 0.26)
		spent_arrived.emit(self)
		queue_free()
		return
	var tangent: Vector2 = Vector2(-to_target.y, to_target.x).normalized() * sin(_float_time * 9.0) * 18.0
	global_position += (to_target.normalized() * 120.0 + tangent) * delta
	modulate.a = clampf(to_target.length() / 96.0, 0.25, 1.0)
	rotation = lerpf(rotation, to_target.angle() * 0.12, min(delta * 8.0, 1.0))

func is_ambient() -> bool:
	return state == PoeState.WANDERING or state == PoeState.ATTRACTED

func _wander(delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_pick_new_wander_direction()
	global_position += _wander_direction * wander_speed * delta

func _pick_new_wander_direction() -> void:
	_wander_timer = randf_range(0.8, 1.6)
	_wander_direction = Vector2.RIGHT.rotated(randf() * TAU)

func _apply_type_visual() -> void:
	var path: String = "poes/common.png"
	if poe_type == "ember":
		path = "poes/ember.png"
	elif poe_type == "wisp":
		path = "poes/wisp.png"
	poe_sprite.texture = load(AssetConfig.path(path))
	poe_sprite.hframes = 3
	poe_sprite.frame = randi() % 3

func _setup_glow() -> void:
	glow_light.texture = _make_light_texture(color)
	glow_light.texture_scale = 40.0 / 64.0
	glow_light.energy = 0.4
	glow_light.color = color

func _setup_particles() -> void:
	state_burst.texture = _make_light_texture(color)
	state_burst.one_shot = true
	state_burst.amount = 16
	state_burst.lifetime = 0.22
	state_burst.explosiveness = 1.0
	var burst_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	burst_material.direction = Vector3(0.0, -1.0, 0.0)
	burst_material.spread = 42.0
	burst_material.gravity = Vector3(0.0, 32.0, 0.0)
	burst_material.initial_velocity_min = 24.0
	burst_material.initial_velocity_max = 42.0
	burst_material.scale_min = 0.06
	burst_material.scale_max = 0.16
	burst_material.color = Color(color.r, color.g, color.b, 0.82)
	state_burst.process_material = burst_material

	travel_trail.texture = _make_light_texture(Color(1.0, 0.82, 0.46, 1.0))
	travel_trail.one_shot = false
	travel_trail.amount = 14
	travel_trail.lifetime = 0.14
	travel_trail.preprocess = 0.14
	travel_trail.emitting = false
	var trail_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	trail_material.direction = Vector3(0.0, -1.0, 0.0)
	trail_material.spread = 24.0
	trail_material.gravity = Vector3(0.0, 18.0, 0.0)
	trail_material.initial_velocity_min = 10.0
	trail_material.initial_velocity_max = 18.0
	trail_material.scale_min = 0.04
	trail_material.scale_max = 0.12
	trail_material.color = Color(1.0, 0.82, 0.46, 0.7)
	travel_trail.process_material = trail_material

func _setup_float_animation() -> void:
	var animation: Animation = Animation.new()
	animation.length = 0.9
	animation.loop_mode = Animation.LOOP_LINEAR
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath("PoeSprite:frame"))
	animation.track_insert_key(track, 0.0, 0)
	animation.track_insert_key(track, 0.3, 1)
	animation.track_insert_key(track, 0.6, 2)
	animation.track_insert_key(track, 0.9, 0)
	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation("float", animation)
	animation_player.add_animation_library("", library)
	animation_player.play("float")

func _play_state_transition(flash_color: Color, scale_multiplier: float, light_multiplier: float) -> void:
	if _visual_tween != null:
		_visual_tween.kill()
	_visual_tween = create_tween()
	_visual_tween.set_parallel(true)
	_visual_tween.tween_property(poe_sprite, "scale", Vector2.ONE * 3.0 * scale_multiplier, 0.12)
	_visual_tween.tween_property(poe_sprite, "modulate", flash_color, 0.1)
	_visual_tween.tween_property(glow_light, "energy", 0.4 * light_multiplier, 0.12)
	_visual_tween.chain().tween_property(poe_sprite, "scale", Vector2.ONE * 3.0, 0.18)
	_visual_tween.parallel().tween_property(poe_sprite, "modulate", Color.WHITE, 0.18)
	_visual_tween.parallel().tween_property(glow_light, "energy", 0.4, 0.2)

func _make_light_texture(light_color: Color) -> Texture2D:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(32, 32)
	for x in range(64):
		for y in range(64):
			var dist: float = Vector2(x, y).distance_to(center)
			var alpha: float = clampf(1.0 - dist / 32.0, 0.0, 1.0) * 0.5
			image.set_pixel(x, y, Color(light_color.r, light_color.g, light_color.b, alpha))
	return ImageTexture.create_from_image(image)

func _spawn_world_burst(burst_color: Color, amount: int, particle_scale: float) -> void:
	var parent_node: Node = get_parent()
	if get_tree().current_scene != null:
		parent_node = get_tree().current_scene
	if parent_node == null:
		return
	var burst: GPUParticles2D = GPUParticles2D.new()
	burst.position = global_position
	burst.one_shot = true
	burst.emitting = false
	burst.amount = amount
	burst.lifetime = 0.18
	burst.explosiveness = 1.0
	burst.texture = _make_light_texture(Color(burst_color.r, burst_color.g, burst_color.b, 1.0))
	var material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	material.direction = Vector3(0.0, -1.0, 0.0)
	material.spread = 36.0
	material.gravity = Vector3(0.0, 28.0, 0.0)
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 34.0
	material.scale_min = particle_scale * 0.22
	material.scale_max = particle_scale * 0.55
	material.color = burst_color
	burst.process_material = material
	parent_node.add_child(burst)
	burst.restart()
	burst.emitting = true
	var cleanup_timer: SceneTreeTimer = get_tree().create_timer(0.7)
	cleanup_timer.timeout.connect(Callable(burst, "queue_free"))
