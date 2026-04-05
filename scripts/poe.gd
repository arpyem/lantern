extends Area2D

signal collected(poe_type: String)

enum PoeState { WANDERING, ATTRACTED, COLLECTED }

@export var poe_type := "common"
@export var attraction_radius := 180.0
@export var move_speed := 40.0
@export var wander_speed := 12.0
@export var collect_radius := 16.0
@export var color := Color(0.7, 0.85, 1.0)

var state := PoeState.WANDERING
var lantern_position := Vector2.ZERO
var _wander_direction := Vector2.RIGHT
var _wander_timer := 0.0

@onready var poe_sprite: Sprite2D = $PoeSprite
@onready var glow_light: PointLight2D = $GlowLight
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_apply_type_visual()
	_setup_glow()
	_pick_new_wander_direction()
	_setup_float_animation()

func _physics_process(delta: float) -> void:
	if state == PoeState.COLLECTED:
		return
	var distance := global_position.distance_to(lantern_position)
	match state:
		PoeState.WANDERING:
			if distance <= attraction_radius:
				state = PoeState.ATTRACTED
			else:
				_wander(delta)
		PoeState.ATTRACTED:
			if distance > attraction_radius * 1.5:
				state = PoeState.WANDERING
			elif distance <= collect_radius:
				collect()
			else:
				global_position += global_position.direction_to(lantern_position) * move_speed * delta

func set_lantern_position(position: Vector2) -> void:
	lantern_position = position

func collect() -> void:
	if state == PoeState.COLLECTED:
		return
	state = PoeState.COLLECTED
	collected.emit(poe_type)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(Callable(self, "queue_free"))

func _wander(delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_pick_new_wander_direction()
	global_position += _wander_direction * wander_speed * delta

func _pick_new_wander_direction() -> void:
	_wander_timer = randf_range(0.8, 1.6)
	_wander_direction = Vector2.RIGHT.rotated(randf() * TAU)

func _apply_type_visual() -> void:
	var path := "poes/common.png"
	if poe_type == "ember":
		path = "poes/ember.png"
	elif poe_type == "wisp":
		path = "poes/wisp.png"
	# PROTOTYPE: res://assets/placeholder/poes/common.png
	# FINAL: res://assets/final/poes/common.png
	poe_sprite.texture = load(AssetConfig.path(path))
	poe_sprite.hframes = 3
	poe_sprite.frame = randi() % 3

func _setup_glow() -> void:
	glow_light.texture = _make_light_texture(color)
	glow_light.texture_scale = 40.0 / 64.0
	glow_light.energy = 0.4
	glow_light.color = color

func _setup_float_animation() -> void:
	var animation := Animation.new()
	animation.length = 0.9
	animation.loop_mode = Animation.LOOP_LINEAR
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath("PoeSprite:frame"))
	animation.track_insert_key(track, 0.0, 0)
	animation.track_insert_key(track, 0.3, 1)
	animation.track_insert_key(track, 0.6, 2)
	animation.track_insert_key(track, 0.9, 0)
	var library := AnimationLibrary.new()
	library.add_animation("float", animation)
	animation_player.add_animation_library("", library)
	animation_player.play("float")

func _make_light_texture(light_color: Color) -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var center := Vector2(32, 32)
	for x in range(64):
		for y in range(64):
			var dist := Vector2(x, y).distance_to(center)
			var alpha := clampf(1.0 - dist / 32.0, 0.0, 1.0) * 0.5
			image.set_pixel(x, y, Color(light_color.r, light_color.g, light_color.b, alpha))
	return ImageTexture.create_from_image(image)
