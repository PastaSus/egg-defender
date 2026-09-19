class_name EnemyStats
extends StatsResource

## EnemyStats - Stat sheet for enemy entities. Extend or configure per enemy type.

@export var enemy_name: String = ""
@export var xp_reward: int = 10
@export var coin_reward: int = 0
@export var spawn_weight: float = 1.0
@export var is_elite: bool = false
@export var is_boss: bool = false
