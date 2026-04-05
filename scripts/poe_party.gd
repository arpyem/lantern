extends Node2D

signal party_changed(count: int)

@export var max_followers: int = 3
@export var orbit_radius_x: float = 30.0
@export var orbit_radius_y: float = 16.0
@export var center_offset: Vector2 = Vector2(0, -18)
@export var orbit_speed: float = 1.5
@export var interactable_pull_strength: float = 0.6
@export var interactable_pull_spacing: float = 22.0
@export var interactable_hover_height: float = 18.0

var _followers: Array = []
var _player_position: Vector2 = Vector2.ZERO
var _time: float = 0.0
var _interaction_focus_position: Vector2 = Vector2.ZERO
var _interaction_focus_enabled: bool = false
var _interaction_focus_count: int = 0

func _process(delta: float) -> void:
	_time += delta
	_prune_invalid_followers()
	for index in range(_followers.size()):
		var follower = _followers[index]
		if not is_instance_valid(follower):
			continue
		var slot_angle: float = _time * orbit_speed + float(index) * (TAU / float(max(max_followers, 1)))
		var offset: Vector2 = Vector2(cos(slot_angle) * orbit_radius_x, sin(slot_angle) * orbit_radius_y) + center_offset
		if _interaction_focus_enabled and index < _interaction_focus_count:
			var preview_offset: Vector2 = Vector2((float(index) - float(max(_interaction_focus_count - 1, 0)) * 0.5) * interactable_pull_spacing, -interactable_hover_height + sin(_time * 3.2 + float(index)) * 5.0)
			var preview_target: Vector2 = _interaction_focus_position + preview_offset
			offset = (_player_position + offset).lerp(preview_target, interactable_pull_strength) - _player_position
		if follower.has_method("set_follow_target_position"):
			follower.set_follow_target_position(_player_position + offset, index)

func set_player_position(position: Vector2) -> void:
	_player_position = position

func set_interaction_focus(enabled: bool, position: Vector2 = Vector2.ZERO, follower_count: int = 0) -> void:
	_interaction_focus_enabled = enabled
	_interaction_focus_position = position
	_interaction_focus_count = max(follower_count, 0)

func can_recruit() -> bool:
	_prune_invalid_followers()
	return _followers.size() < max_followers

func recruit_poe(poe) -> bool:
	_prune_invalid_followers()
	if _followers.size() >= max_followers:
		return false
	if _followers.has(poe):
		return true
	_followers.append(poe)
	if poe.has_method("begin_following"):
		poe.begin_following(_followers.size() - 1)
	party_changed.emit(_followers.size())
	return true

func has_available_poe(count: int = 1) -> bool:
	_prune_invalid_followers()
	return _followers.size() >= count

func get_follower_count() -> int:
	_prune_invalid_followers()
	return _followers.size()

func spend_poe(target_position: Vector2, count: int = 1) -> Array:
	_prune_invalid_followers()
	if _followers.size() < count:
		return []
	var spent: Array = []
	for _index in range(count):
		var follower = _followers.pop_front()
		if is_instance_valid(follower):
			if follower.has_method("begin_spend"):
				follower.begin_spend(target_position)
			spent.append(follower)
	party_changed.emit(_followers.size())
	return spent

func _prune_invalid_followers() -> void:
	var removed: bool = false
	for index in range(_followers.size() - 1, -1, -1):
		if not is_instance_valid(_followers[index]):
			_followers.remove_at(index)
			removed = true
	if removed:
		party_changed.emit(_followers.size())
