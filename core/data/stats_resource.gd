class_name StatsResource
extends Resource

## StatsResource - Base resource for all entity stats (player, enemies, weapons).
## Extend this class to create specific stat sheets.

@export var health: float = 100.0
@export var speed: float = 200.0
@export var damage: float = 10.0
@export var cooldown: float = 1.0
