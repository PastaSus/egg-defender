class_name PlayerHurtBox
extends Area2D

## PlayerHurtBox - Player-side damage gate. Collects every enemy contact report, then lets the
## single hardest hit through per invulnerability window (stats.cooldown), so a pile of enemies
## touching at once costs one hit rather than one hit each.
##
## Reports are accumulated rather than resolved on arrival: an enemy emits during its own
## _physics_process, so resolving the first arrival would hand the window to whichever enemy sits
## earliest in the scene tree, not the most dangerous one. Accumulating and resolving on the next
## physics frame makes the outcome independent of tree order, at the cost of up to one frame (~16ms)
## of latency, which is invisible against a one-second window.

## Used when `stats` is unassigned, so a misconfigured scene degrades to a sane rate instead of
## taking damage every physics frame.
const FALLBACK_COOLDOWN: float = 1.0

@export var stats: StatsResource

var _invulnerable_time_left: float = 0.0
var _pending_damage: int = 0
var _warned_missing_stats: bool = false
var _player_dead: bool = false

func _ready() -> void:
	SignalBus.enemy_reached_player.connect(_on_enemy_reached_player)
	SignalBus.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	_invulnerable_time_left = maxf(_invulnerable_time_left - delta, 0.0)
	_resolve_pending_damage()

func _on_enemy_reached_player(damage: int) -> void:
	# Enemies park on the corpse and keep reporting forever, so drop reports here rather than at
	# resolve time: otherwise _pending_damage latches and would land on the first frame of a revive.
	if _player_dead:
		return
	_pending_damage = maxi(_pending_damage, damage)

func _on_player_died() -> void:
	_player_dead = true
	_pending_damage = 0

func _resolve_pending_damage() -> void:
	if _player_dead or _pending_damage <= 0:
		return
	var damage: int = _pending_damage
	_pending_damage = 0
	if _invulnerable_time_left > 0.0:
		return
	_invulnerable_time_left = _invulnerability_duration()
	SignalBus.player_damaged.emit(damage)

func _invulnerability_duration() -> float:
	if stats != null:
		return stats.cooldown
	if not _warned_missing_stats:
		_warned_missing_stats = true
		push_warning("PlayerHurtBox has no stats assigned; using %.1fs invulnerability." % FALLBACK_COOLDOWN)
	return FALLBACK_COOLDOWN
