class_name EnemyHitBox
extends Area2D

## EnemyHitBox - Reports contact with the player's hurtbox every physics frame while overlapping.
## Polls instead of using area_entered, which fires only once and would stop hurting a player
## the enemy is still sitting on. The player side decides how often a report becomes damage.

@onready var _enemy: EnemyBase = get_parent()

func _ready() -> void:
	if _enemy == null:
		push_error("EnemyHitBox expects an EnemyBase parent; contact damage disabled for %s." % get_path())
		set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if _enemy.stats == null:
		return
	if has_overlapping_areas():
		SignalBus.enemy_reached_player.emit(roundi(_enemy.stats.damage))
