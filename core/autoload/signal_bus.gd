extends Node

## SignalBus - Global event bus for decoupled communication.
## All core systems and feature scripts communicate through this singleton.
## Never create direct references between feature scripts.

signal enemy_died(xp_amount: int)
signal player_damaged(amount: int)
signal wave_completed()
