extends CharacterBody2D

signal lantern_position_changed(position: Vector2)

@export var speed := 120.0
@export var acceleration := 800.0
@export var friction := 600.0
@export var lantern_radius := 160.0
@export var lantern_energy := 1.2
@export var lantern_color := Color(1.0, 0.72, 0.25)
@export var lantern_flicker_speed := 7.5
@export var lantern_flicker_amplitude := 0.09
@export var lantern_breath_speed := 1.6
@export var lantern_breath_amplitude := 0.12
@export var lantern_idle_sway_distance := 1.8
@export var lantern_move_sway_distance := 3.2

var facing := Vector2.DOWN
var _body_textures: Dictionary = {}
var _light_time := 0.0
var _base_lantern_light_scale := 1.0
var _base_lantern_light_position := Vector2.ZERO
var _base_lantern_sprite_position := Vector2.ZERO

@onready var body_sprite: Sprite2D = $BodySprite
@onready var lantern_sprite: Sprite2D = $LanternSprite
@onready var lantern_light: PointLight2D = $LanternLight

func _ready() -> void:
	_load_textures()
	_apply_facing_visuals()
	_setup_lantern_light()
	lantern_position_changed.emit(get_lantern_world_position())

func _physics_process(delta: float) -> void:
	_light_time += delta
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		facing = input_vector.normalized()
	velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	_apply_facing_visuals()
	_update_lantern_presentation(delta)
	lantern_position_changed.emit(get_lantern_world_position())

func upgrade_lantern(radius: float, energy: float) -> void:
	lantern_radius = radius
	lantern_energy = energy
	_setup_lantern_light()

func get_lantern_world_position() -> Vector2:
	return global_position + _facing_basis() * 18.0

func _load_textures() -> void:
	# PROTOTYPE: res://assets/placeholder/player/idle_down.png
	# FINAL: res://assets/final/player/idle_down.png
	_body_textures["down"] = load(AssetConfig.path("player/idle_down.png"))
	# PROTOTYPE: res://assets/placeholder/player/idle_up.png
	# FINAL: res://assets/final/player/idle_up.png
	_body_textures["up"] = load(AssetConfig.path("player/idle_up.png"))
	# PROTOTYPE: res://assets/placeholder/player/idle_left.png
	# FINAL: res://assets/final/player/idle_left.png
	_body_textures["left"] = load(AssetConfig.path("player/idle_left.png"))
	# PROTOTYPE: res://assets/placeholder/player/idle_right.png
	# FINAL: res://assets/final/player/idle_right.png
	_body_textures["right"] = load(AssetConfig.path("player/idle_right.png"))
	# PROTOTYPE: res://assets/placeholder/player/lantern.png
	# FINAL: res://assets/final/player/lantern.png
	lantern_sprite.texture = load(AssetConfig.path("player/lantern.png"))

func _apply_facing_visuals() -> void:
	var key := "down"
	if absf(facing.x) > absf(facing.y):
		key = "right" if facing.x >= 0.0 else "left"
	else:
		key = "down" if facing.y >= 0.0 else "up"
	body_sprite.texture = _body_textures[key]
	_base_lantern_sprite_position = _facing_basis() * 12.0 + Vector2(0, -8)
	lantern_sprite.position = _base_lantern_sprite_position
	lantern_sprite.rotation = _facing_basis().angle() + PI * 0.5
	_base_lantern_light_position = _facing_basis() * 10.0
	lantern_light.position = _base_lantern_light_position

func _setup_lantern_light() -> void:
	lantern_light.texture = _make_light_texture(lantern_color)
	_base_lantern_light_scale = lantern_radius / 64.0
	lantern_light.texture_scale = _base_lantern_light_scale
	lantern_light.energy = lantern_energy
	lantern_light.color = lantern_color

func _update_lantern_presentation(_delta: float) -> void:
	var move_ratio := clampf(velocity.length() / max(speed, 0.001), 0.0, 1.0)
	var sway_strength := lerpf(lantern_idle_sway_distance, lantern_move_sway_distance, move_ratio)
	var sway_axis := Vector2(-_facing_basis().y, _facing_basis().x)
	var sway := sway_axis * sin(_light_time * (2.4 + move_ratio * 3.2)) * sway_strength
	var bob := Vector2(0.0, cos(_light_time * (1.8 + move_ratio * 4.0)) * (0.8 + move_ratio * 1.2))
	var breath := 1.0 + sin(_light_time * lantern_breath_speed) * lantern_breath_amplitude
	var flicker := 1.0 + sin(_light_time * lantern_flicker_speed + move_ratio * 0.9) * lantern_flicker_amplitude

	lantern_sprite.position = _base_lantern_sprite_position + sway * 0.45 + bob * 0.4
	lantern_light.position = _base_lantern_light_position + sway + bob
	lantern_light.texture_scale = _base_lantern_light_scale * breath
	lantern_light.energy = lantern_energy * flicker

func _make_light_texture(color: Color) -> Texture2D:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var center := Vector2(64, 64)
	for x in range(128):
		for y in range(128):
			var dist := Vector2(x, y).distance_to(center)
			var alpha := clampf(pow(max(0.0, 1.0 - dist / 64.0), 2.0), 0.0, 1.0)
			image.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
	return ImageTexture.create_from_image(image)

func _facing_basis() -> Vector2:
	if facing == Vector2.ZERO:
		return Vector2.DOWN
	return facing.normalized()
