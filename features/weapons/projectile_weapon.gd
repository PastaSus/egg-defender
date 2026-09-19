class_name ProjectileWeapon
extends WeaponBase

## ProjectileWeapon - Fires pooled projectiles. Yolk Spit is this class configured with a WeaponStats
## resource, not a subclass of it.
##
## The pool is deliberately scoped to this one projectile type: no autoload, no generic framework.

## Story 1.7 replaces this with real targeting. Until then the weapon fires blindly to the right.
const PLACEHOLDER_DIRECTION: Vector2 = Vector2.RIGHT

@export var pool_size: int = 16
## Distance from the weapon to the muzzle. Without it a projectile spawns inside the hurtbox of any
## enemy parked on the player (they stop ~10px away, and hurtbox 12 + projectile 5 = 17px of overlap),
## so every shot would expire on its first monitoring frame.
@export var muzzle_offset: float = 20.0

var _pool: Array[ProjectileBase] = []
var _warned_pool_exhausted: bool = false

func _ready() -> void:
	# GDScript does not chain _ready(): without this the fire timer and stats validation never run.
	super()
	if not _is_configured:
		return
	if pool_size <= 0:
		push_error("%s has pool_size <= 0; weapon disabled." % name)
		_disable()
		return
	for _i in pool_size:
		var instance: Node = stats.projectile_scene.instantiate()
		var projectile: ProjectileBase = instance as ProjectileBase
		if projectile == null:
			push_error("%s projectile_scene is not a ProjectileBase; weapon disabled." % name)
			instance.free()
			_clear_pool()
			_disable()
			return
		# Children of the weapon so they are freed with it; ProjectileBase is top_level so they
		# ignore the weapon's (and Player's) movement.
		add_child(projectile)
		_pool.append(projectile)
	_warn_if_pool_undersized()

func _fire() -> void:
	var projectile: ProjectileBase = _acquire()
	if projectile == null:
		if not _warned_pool_exhausted:
			_warned_pool_exhausted = true
			push_warning("%s projectile pool exhausted; skipping shots." % name)
		return
	var direction: Vector2 = PLACEHOLDER_DIRECTION
	projectile.launch(global_position + direction * muzzle_offset, direction, stats.speed)
	SignalBus.weapon_fired.emit(stats.weapon_name, global_position)

func _acquire() -> ProjectileBase:
	for projectile in _pool:
		if not projectile.is_active:
			return projectile
	return null

## The pool must cover fire_rate * lifetime concurrent projectiles. Those three numbers live in three
## different files, so warn at startup rather than letting shots vanish silently once a fire-rate
## upgrade outpaces the pool.
func _warn_if_pool_undersized() -> void:
	var lifetime: float = _pool[0].get_lifetime()
	if lifetime <= 0.0:
		return
	var needed: int = ceili(stats.fire_rate * lifetime)
	if pool_size < needed:
		push_warning("%s pool_size %d cannot sustain fire_rate %.2f over a %.2fs lifetime (needs %d); shots will be dropped." % [name, pool_size, stats.fire_rate, lifetime, needed])

func _clear_pool() -> void:
	for projectile in _pool:
		projectile.queue_free()
	_pool.clear()
