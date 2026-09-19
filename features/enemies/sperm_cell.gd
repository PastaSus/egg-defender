class_name SpermCell
extends EnemyBase

## SpermCell - Basic enemy that charges in a straight line at the player.

func _get_move_direction() -> Vector2:
	return (_player.global_position - global_position).normalized()
