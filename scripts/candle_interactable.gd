extends "res://scripts/poe_interactable.gd"

@export var wick_offset: Vector2 = Vector2(1, -40)
@export var flame_scale: float = 0.42
@export var inactive_body_modulate: Color = Color(0.62, 0.64, 0.72, 1.0)
@export var active_body_modulate: Color = Color(1.0, 0.96, 0.92, 1.0)
@export var idle_flicker_amount: float = 0.12
@export var idle_flicker_speed: float = 5.0

@onready var flame_sprite: Sprite2D = $FlameSprite
@onready var flame_particles: GPUParticles2D = $FlameParticles
@onready var activation_burst: GPUParticles2D = $ActivationBurst

var _flicker_time: float = 0.0
var _target_light_energy: float = 0.0

func _ready() -> void:
	super._ready()
	_setup_flame_visuals()
	_setup_particles()
	_refresh_candle_state()

func _process(delta: float) -> void:
	if not active:
		return
	_flicker_time += delta * idle_flicker_speed
	var flicker: float = 1.0 + sin(_flicker_time) * idle_flicker_amount + cos(_flicker_time * 1.9) * (idle_flicker_amount * 0.45)
	light.energy = _target_light_energy * flicker
	flame_sprite.scale = Vector2.ONE * flame_scale * (1.0 + sin(_flicker_time * 1.4) * 0.08)
	flame_sprite.position = wick_offset + Vector2(0, sin(_flicker_time * 1.7) * -0.8)
	light.position = wick_offset + Vector2(0, 6)

func activate() -> void:
	var was_active: bool = active
	super.activate()
	if was_active and one_shot:
		return
	_target_light_energy = active_light_energy
	activation_burst.restart()
	activation_burst.emitting = true
	flame_particles.restart()
	flame_particles.emitting = true
	flame_sprite.visible = true
	flame_sprite.modulate = Color(1.4, 1.1, 0.72, 0.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flame_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)
	tween.tween_property(flame_sprite, "scale", Vector2.ONE * flame_scale * 1.24, 0.12)
	tween.chain().tween_property(flame_sprite, "scale", Vector2.ONE * flame_scale, 0.16)

func _refresh_visuals() -> void:
	super._refresh_visuals()
	_refresh_candle_state()

func _refresh_candle_state() -> void:
	sprite.self_modulate = active_body_modulate if active else inactive_body_modulate
	_target_light_energy = active_light_energy if active else inactive_light_energy
	flame_sprite.visible = active
	flame_particles.emitting = active
	if not active:
		light.energy = inactive_light_energy
		flame_sprite.scale = Vector2.ONE * flame_scale
		flame_sprite.position = wick_offset
		light.position = wick_offset + Vector2(0, 6)

func _setup_flame_visuals() -> void:
	flame_sprite.texture = _make_flame_texture()
	flame_sprite.position = wick_offset
	flame_sprite.scale = Vector2.ONE * flame_scale
	flame_sprite.visible = active
	flame_sprite.z_index = sprite.z_index + 1
	light.position = wick_offset + Vector2(0, 6)

func _setup_particles() -> void:
	var flame_texture: Texture2D = flame_sprite.texture
	flame_particles.texture = flame_texture
	flame_particles.one_shot = false
	flame_particles.amount = 6
	flame_particles.lifetime = 0.65
	flame_particles.preprocess = 0.65
	flame_particles.position = wick_offset
	flame_particles.emitting = active
	var flame_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	flame_material.direction = Vector3(0.0, -1.0, 0.0)
	flame_material.spread = 22.0
	flame_material.gravity = Vector3(0.0, -6.0, 0.0)
	flame_material.initial_velocity_min = 5.0
	flame_material.initial_velocity_max = 13.0
	flame_material.scale_min = 0.35
	flame_material.scale_max = 0.7
	flame_material.color = Color(1.0, 0.78, 0.34, 0.55)
	flame_particles.process_material = flame_material

	activation_burst.texture = flame_texture
	activation_burst.one_shot = true
	activation_burst.amount = 18
	activation_burst.lifetime = 0.55
	activation_burst.explosiveness = 1.0
	activation_burst.position = wick_offset
	activation_burst.emitting = false
	var burst_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	burst_material.direction = Vector3(0.0, -1.0, 0.0)
	burst_material.spread = 55.0
	burst_material.gravity = Vector3(0.0, -8.0, 0.0)
	burst_material.initial_velocity_min = 14.0
	burst_material.initial_velocity_max = 24.0
	burst_material.scale_min = 0.5
	burst_material.scale_max = 1.0
	burst_material.color = Color(1.0, 0.8, 0.42, 0.8)
	activation_burst.process_material = burst_material

func _make_flame_texture() -> Texture2D:
	var image: Image = Image.create(32, 48, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(16, 24)
	for x in range(32):
		for y in range(48):
			var normalized_x: float = (float(x) - center.x) / 10.0
			var normalized_y: float = (float(y) - center.y) / 18.0
			var body: float = clampf(1.0 - (normalized_x * normalized_x + normalized_y * normalized_y), 0.0, 1.0)
			var inner: float = clampf(1.0 - (normalized_x * normalized_x * 1.8 + normalized_y * normalized_y * 2.4), 0.0, 1.0)
			var alpha: float = max(body * 0.8, inner * 0.95)
			var flame_color: Color = Color(1.0, 0.72, 0.18, alpha)
			if inner > 0.35:
				flame_color = Color(1.0, 0.94, 0.62, alpha)
			image.set_pixel(x, y, flame_color)
	return ImageTexture.create_from_image(image)
