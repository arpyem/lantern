extends Node2D

const PLAYER_START: Vector2 = Vector2(1024, 1024)
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var ground: Sprite2D = $Ground
@onready var fog_manager: Node2D = $FogManager
@onready var poe_manager: Node2D = $PoeManager
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	randomize()
	canvas_modulate.color = Color(0.16, 0.18, 0.24, 1.0)
	_setup_ground()
	player.global_position = PLAYER_START
	camera.global_position = PLAYER_START
	camera.enabled = true
	player.lantern_position_changed.connect(poe_manager._on_lantern_moved)
	var lantern_position: Vector2 = player.get_lantern_world_position()
	poe_manager._on_lantern_moved(lantern_position)

func _process(_delta: float) -> void:
	camera.global_position = player.global_position
	fog_manager.set_focus_position(player.global_position + Vector2(0, -10))

func _setup_ground() -> void:
	# PROTOTYPE: res://assets/placeholder/terrain/ground_tile.png
	# FINAL: res://assets/final/terrain/ground_tile.png
	ground.texture = load(AssetConfig.path("terrain/ground_tile.png"))
	ground.centered = false
	ground.position = Vector2.ZERO
	ground.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	ground.region_enabled = true
	ground.region_rect = Rect2(Vector2.ZERO, Vector2(2048, 2048))
	ground.scale = Vector2.ONE
