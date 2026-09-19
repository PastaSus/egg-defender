extends Node

## GameManager - Global game state controller.
## Manages waves, scoring, and high-level game flow.
## All game state changes should go through this singleton.

var current_wave: int = 0
var score: int = 0
var is_game_over: bool = false

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.wave_completed.connect(_on_wave_completed)
	SignalBus.player_died.connect(_on_player_died)

func start_game() -> void:
	current_wave = 1
	score = 0
	is_game_over = false

func _on_enemy_died(xp_amount: int) -> void:
	score += xp_amount

func _on_wave_completed() -> void:
	current_wave += 1

func _on_player_died() -> void:
	is_game_over = true
