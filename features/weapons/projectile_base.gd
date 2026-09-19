class_name ProjectileBase
extends Area2D

## ProjectileBase - A pooled projectile. Flies in a straight line until its lifetime runs out or it
## touches an enemy hurtbox (layer 5), then goes inert so the pool can reuse it. Applies no damage:
## damage on hit is Story 1.8's job.

## Pool availability flag. An explicit flag, not `visible`, so a hidden-but-live node can't be mistaken for a free one.
var is_active: bool = false

var _direction: Vector2 = Vector2.ZERO
var _speed: float = 0.0

@onready var _lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	_lifetime_timer.timeout.connect(_expire)
	area_entered.connect(_on_area_entered)
	# Start inert: a pooled projectile must cost nothing until it is launched.
	deactivate()

func launch(from: Vector2, direction: Vector2, speed: float) -> void:
	# Position first, so a recycled projectile never reports an overlap from its stale position.
	global_position = from
	_direction = direction
	_speed = speed
	is_active = true
	visible = true
	set_physics_process(true)
	# Deferred on both edges so the on/off order always matches call order, even within one frame.
	set_deferred("monitoring", true)
	_lifetime_timer.start()

func deactivate() -> void:
	is_active = false
	visible = false
	set_physics_process(false)
	_lifetime_timer.stop()
	# Deferred: this can run inside an area_entered callback, where changing monitoring directly errors.
	set_deferred("monitoring", false)

## How long a launched projectile stays alive. Read by the weapon to size its pool.
func get_lifetime() -> float:
	return _lifetime_timer.wait_time

func _physics_process(delta: float) -> void:
	global_position += _direction * _speed * delta

func _on_area_entered(_area: Area2D) -> void:
	_expire()

func _expire() -> void:
	# Timer and overlap can land in the same frame; only the first one counts.
	if not is_active:
		return
	deactivate()
