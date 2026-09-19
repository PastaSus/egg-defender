class_name SpermCell
extends EnemyBase

## SpermCell - Basic enemy that charges in a straight line at the player.

## Stops charging inside this distance so it doesn't jitter on top of the player.
## Keep below the HitBox + HurtBox contact range (14 + 8) so a stopped enemy still deals damage.
@export var arrival_distance: float = 10.0

func _get_move_direction() -> Vector2:
	var to_player: Vector2 = _player.global_position - global_position
	if to_player.length() <= arrival_distance:
		return Vector2.ZERO
	return to_player.normalized()
