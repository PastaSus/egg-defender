extends Node

## SignalBus - Global event bus for decoupled communication.
## All core systems and feature scripts communicate through this singleton.
## Never create direct references between feature scripts.

signal enemy_died(xp_amount: int)
## Request: "apply this much damage to the player", already rate-limited by PlayerHurtBox.
## Listeners apply it; they must NOT re-emit it. Story 1.5's health system emits
## player_health_changed for HUD/feedback instead, so the two directions stay separate.
signal player_damaged(amount: int)
signal wave_completed()
## Raw contact report from an enemy hitbox, emitted every physics frame while overlapping.
## Only PlayerHurtBox should listen; it collapses these into player_damaged.
signal enemy_reached_player(damage: int)
