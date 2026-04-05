extends Node2D

const PLAYER_START: Vector2 = Vector2(1024, 1024)
const FOG_POE_WALK_THRESHOLD: float = 3.0
const FOG_POE_MIN_SPEED: float = 30.0
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var ground: Sprite2D = $Ground
@onready var fog_manager = $FogManager
@onready var poe_manager = $PoeManager
@onready var poe_party = $PoeParty
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var prompt_label: Label = $PromptLayer/PromptLabel

var _current_interactable: Node2D
var _fog_walk_accumulator: float = 0.0

func _ready() -> void:
	randomize()
	canvas_modulate.color = Color(0.16, 0.18, 0.24, 1.0)
	_setup_ground()
	player.global_position = PLAYER_START
	camera.global_position = PLAYER_START
	camera.enabled = true
	player.lantern_position_changed.connect(poe_manager._on_lantern_moved)
	player.player_position_changed.connect(poe_manager._on_player_moved)
	player.player_position_changed.connect(poe_party.set_player_position)
	poe_manager.set_poe_party(poe_party)
	var lantern_position: Vector2 = player.get_lantern_world_position()
	poe_manager._on_lantern_moved(lantern_position)
	poe_manager._on_player_moved(player.global_position)
	poe_party.set_player_position(player.global_position)
	_connect_interactables()
	prompt_label.visible = false

func _process(delta: float) -> void:
	camera.global_position = player.global_position
	fog_manager.set_focus_position(player.global_position + Vector2(0, -10))
	_update_interaction_target()
	_update_fog_walk_progress(delta)
	if Input.is_action_just_pressed("interact"):
		_try_activate_current_interactable()

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

func _update_interaction_target() -> void:
	var best: Node2D = null
	var best_distance: float = INF
	var best_preview: Node2D = null
	var best_preview_distance: float = INF
	var follower_count: int = poe_party.get_follower_count()
	for node in get_tree().get_nodes_in_group("poe_interactable"):
		var interactable: Node2D = node
		if interactable == null:
			continue
		var preview_in_range: bool = interactable.is_player_in_preview_range(player.global_position)
		if preview_in_range:
			var preview_distance: float = interactable.global_position.distance_to(player.global_position)
			if preview_distance < best_preview_distance:
				best_preview_distance = preview_distance
				best_preview = interactable
		var in_range: bool = interactable.is_player_in_range(player.global_position)
		if not in_range:
			continue
		var distance: float = interactable.global_position.distance_to(player.global_position)
		if distance < best_distance:
			best_distance = distance
			best = interactable
	_current_interactable = best
	if best_preview != null and follower_count > 0:
		var preview_focus_count: int = min(best_preview.poe_cost, follower_count)
		poe_party.set_interaction_focus(preview_focus_count > 0, best_preview.global_position, preview_focus_count)
	else:
		poe_party.set_interaction_focus(false)
	if _current_interactable == null:
		prompt_label.visible = false
		return
	var prompt: String = _current_interactable.get_prompt(player.global_position, follower_count)
	prompt_label.text = prompt
	prompt_label.visible = prompt != ""

func _try_activate_current_interactable() -> void:
	if _current_interactable == null:
		return
	var follower_count: int = poe_party.get_follower_count()
	if not _current_interactable.can_activate(player.global_position, follower_count):
		return
	var spent: Array = poe_party.spend_poe(_current_interactable.global_position, _current_interactable.poe_cost)
	if spent.is_empty():
		return
	for poe in spent:
		poe.spent_arrived.connect(_on_spent_poe_arrived.bind(_current_interactable), CONNECT_ONE_SHOT)

func _on_spent_poe_arrived(_poe: Area2D, interactable) -> void:
	if is_instance_valid(interactable):
		interactable.activate()

func _connect_interactables() -> void:
	for node in get_tree().get_nodes_in_group("poe_interactable"):
		if node != null and node.has_signal("activated"):
			var callback: Callable = Callable(self, "_on_interactable_activated")
			if not node.is_connected("activated", callback):
				node.connect("activated", callback)
			if node.has_method("should_clear_fog") and node.should_clear_fog():
				fog_manager.add_permanent_clear_zone(node.global_position, node.fog_clear_radius)

func _on_interactable_activated(interactable: Node2D) -> void:
	if interactable != null and interactable.has_method("should_clear_fog") and interactable.should_clear_fog():
		fog_manager.add_permanent_clear_zone(interactable.global_position, interactable.fog_clear_radius)

func _update_fog_walk_progress(delta: float) -> void:
	var moving_in_fog: bool = player.velocity.length() >= FOG_POE_MIN_SPEED and fog_manager.is_position_in_active_fog(player.global_position)
	if not moving_in_fog:
		_fog_walk_accumulator = 0.0
		return
	_fog_walk_accumulator += delta
	if _fog_walk_accumulator < FOG_POE_WALK_THRESHOLD:
		return
	_fog_walk_accumulator = 0.0
	poe_manager.spawn_poe_near_position(player.global_position)
