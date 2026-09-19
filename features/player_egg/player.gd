class_name Player
extends CharacterBody2D

## Player - Handles movement input and health for the egg character.
## Health is applied from SignalBus.player_damaged (already rate-limited by PlayerHurtBox).
## What death means for the run is GameManager's decision, not this script's.

const FALLBACK_MAX_HEALTH: float = 100.0

@export_range(0.0, 1000.0) var speed: float = 200.0
## Shared with the HurtBox in player_egg.tscn. stats.health is the maximum, never run state.
@export var stats: StatsResource

var current_health: float = 0.0
var _max_health: float = FALLBACK_MAX_HEALTH
var _is_dead: bool = false

func _ready() -> void:
	add_to_group("player")
	# A resource with health <= 0 would leave the player alive at 0 HP: never able to die, and
	# handing listeners a 0/0 ratio. Treat it like a missing resource.
	if stats == null or stats.health <= 0.0:
		push_error("Player stats missing or health <= 0; using %.0f max health." % FALLBACK_MAX_HEALTH)
	else:
		_max_health = stats.health
	current_health = _max_health
	SignalBus.player_damaged.connect(take_damage)
	# Deferred so listeners elsewhere in the tree have finished connecting: children are readied
	# before parents, so an immediate emit would miss anything readied after this node.
	_broadcast_health.call_deferred()

func _broadcast_health() -> void:
	SignalBus.player_health_changed.emit(current_health, _max_health)

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector.normalized() * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if _is_dead or amount <= 0:
		return
	current_health = maxf(current_health - amount, 0.0)
	SignalBus.player_health_changed.emit(current_health, _max_health)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	# Set before emitting so a re-entrant take_damage() can never fire player_died twice.
	_is_dead = true
	velocity = Vector2.ZERO
	SignalBus.player_died.emit()
