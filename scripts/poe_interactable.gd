extends Node2D

signal activated(interactable: Node2D)

@export var interaction_radius: float = 80.0
@export var follower_preview_radius: float = 240.0
@export var poe_cost: int = 1
@export var one_shot: bool = true
@export var active: bool = false
@export var inactive_asset_path: String = ""
@export var active_asset_path: String = ""
@export var sprite_offset: Vector2 = Vector2(0, -16)
@export var sprite_scale: float = 1.0
@export var light_offset: Vector2 = Vector2(0, -18)
@export var light_scale: float = 0.85
@export var light_color: Color = Color(1.0, 0.72, 0.34, 1.0)
@export var inactive_light_energy: float = 0.0
@export var active_light_energy: float = 0.7
@export var prompt_action: String = "Press F"
@export var interaction_label: String = "activate"
@export var activation_pop_scale: float = 1.12
@export var activation_duration: float = 0.14
@export var clears_fog: bool = false
@export var fog_clear_radius: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	add_to_group("poe_interactable")
	_apply_visual_layout()
	_refresh_visuals()

func is_player_in_range(player_position: Vector2) -> bool:
	return global_position.distance_to(player_position) <= interaction_radius

func is_player_in_preview_range(player_position: Vector2) -> bool:
	if one_shot and active:
		return false
	return global_position.distance_to(player_position) <= follower_preview_radius

func can_activate(player_position: Vector2, follower_count: int) -> bool:
	if one_shot and active:
		return false
	return is_player_in_range(player_position) and follower_count >= poe_cost

func get_prompt(player_position: Vector2, follower_count: int) -> String:
	if one_shot and active:
		return ""
	if not is_player_in_range(player_position):
		return ""
	if follower_count >= poe_cost:
		return "%s to spend %d Poe%s and %s" % [prompt_action, poe_cost, "" if poe_cost == 1 else "s", interaction_label]
	return "Need %d Poe%s to %s" % [poe_cost, "" if poe_cost == 1 else "s", interaction_label]

func activate() -> void:
	if one_shot and active:
		return
	if one_shot:
		active = true
	var previous_energy: float = light.energy
	_refresh_visuals()
	light.energy = previous_energy
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ONE * sprite_scale * activation_pop_scale, activation_duration)
	tween.tween_property(light, "energy", active_light_energy, activation_duration * 1.35)
	tween.tween_property(sprite, "self_modulate", Color(1.18, 1.08, 0.94, 1.0), activation_duration * 0.8)
	tween.chain().tween_property(sprite, "scale", Vector2.ONE * sprite_scale, activation_duration)
	tween.parallel().tween_property(sprite, "self_modulate", Color.WHITE, activation_duration)
	activated.emit(self)

func should_clear_fog() -> bool:
	return active and clears_fog and fog_clear_radius > 0.0

func _refresh_visuals() -> void:
	var relative_path: String = inactive_asset_path
	if active and active_asset_path != "":
		relative_path = active_asset_path
	if relative_path != "":
		sprite.texture = load(AssetConfig.path(relative_path))
	sprite.self_modulate = Color.WHITE
	light.energy = active_light_energy if active else inactive_light_energy
	light.color = light_color

func _apply_visual_layout() -> void:
	sprite.position = sprite_offset
	sprite.scale = Vector2.ONE * sprite_scale
	light.position = light_offset
	light.color = light_color
	light.texture_scale = light_scale
	if light.texture == null:
		light.texture = _make_light_texture(light_color)

func _make_light_texture(base_color: Color) -> Texture2D:
	var image: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(64, 64)
	for x in range(128):
		for y in range(128):
			var distance: float = Vector2(x, y).distance_to(center)
			var falloff: float = clampf(1.0 - distance / 64.0, 0.0, 1.0)
			var alpha: float = falloff * falloff * 0.62
			image.set_pixel(x, y, Color(base_color.r, base_color.g, base_color.b, alpha))
	return ImageTexture.create_from_image(image)
