class_name EnemyBase
extends CharacterBody2D

## EnemyBase - Shared movement plumbing for enemy types. Subclasses override _get_move_direction().

@export var stats: EnemyStats

var _player: Node2D

func _physics_process(_delta: float) -> void:
	if stats == null:
		return
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if _player == null:
			return
	velocity = _get_move_direction() * stats.speed
	move_and_slide()

func _get_move_direction() -> Vector2:
	return Vector2.ZERO
