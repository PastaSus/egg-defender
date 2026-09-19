class_name WeaponBase
extends Node2D

## WeaponBase - Shared fire-rate plumbing for weapons. Subclasses override _fire().
## Reads no player state: what a weapon shoots at is decided by its subclass, not by the node it hangs from.

@export var stats: WeaponStats

## True only when stats validated and the fire timer is running. Subclasses check it before building anything.
var _is_configured: bool = false
var _is_dead: bool = false

@onready var _fire_timer: Timer = $FireTimer

func _ready() -> void:
	if stats == null:
		push_error("%s has no stats assigned; weapon disabled." % name)
		return
	if stats.fire_rate <= 0.0:
		push_error("%s has fire_rate <= 0; weapon disabled." % name)
		return
	if stats.projectile_scene == null:
		push_error("%s has no projectile_scene; weapon disabled." % name)
		return
	_fire_timer.wait_time = 1.0 / stats.fire_rate
	_fire_timer.timeout.connect(_on_fire_timer_timeout)
	SignalBus.player_died.connect(_on_player_died)
	_is_configured = true
	_fire_timer.start()
	# Fire once straight away so the weapon doesn't sit silent for a full interval; the timer then
	# carries the normal 1/fire_rate cadence. Deferred so a subclass has finished its own _ready()
	# (ProjectileWeapon builds its pool there) before the first shot.
	_fire_first_shot.call_deferred()

## Overridden by weapon types. Does nothing in the base.
func _fire() -> void:
	pass

## Every path to _fire() goes through here, so a disabled or dead weapon cannot shoot even if
## something else restarts the timer (Story 1.7 will start and stop it as targets come and go).
func _can_fire() -> bool:
	return _is_configured and not _is_dead

func _on_fire_timer_timeout() -> void:
	if _can_fire():
		_fire()

func _fire_first_shot() -> void:
	if _can_fire():
		_fire()

func _on_player_died() -> void:
	# A dead player must not keep attacking. Projectiles already in flight finish their own lifetime.
	_is_dead = true
	_fire_timer.stop()

## Shuts the weapon down permanently after a misconfiguration a subclass detected.
func _disable() -> void:
	_is_configured = false
	_fire_timer.stop()
