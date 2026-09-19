class_name WeaponStats
extends StatsResource

## WeaponStats - Stat sheet for weapons. Fields match game-architecture.md#WeaponStats exactly.
##
## Inherited StatsResource fields, as used by weapons:
##   speed    - the projectile's travel speed (px/s)
##   health, damage, cooldown - unused. fire_rate and base_damage below carry those ideas for
##   weapons, per the architecture; the overlap is logged in deferred-work.md.
##
## Story 1.6 reads only weapon_name, fire_rate, projectile_scene and the inherited speed.
## Every other field is inert until damage (S8) and weapon upgrades (Epic 4) exist.

@export var weapon_name: String = ""
@export var weapon_type: String = "projectile"
@export var base_damage: float = 10.0
## Attacks per second.
@export var fire_rate: float = 1.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var piercing: int = 0
@export var area_multiplier: float = 1.0
@export var knockback: float = 0.0
@export var projectile_scene: PackedScene
