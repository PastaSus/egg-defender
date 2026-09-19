extends Node

## SignalBus - Global event bus for decoupled communication.
## All core systems and feature scripts communicate through this singleton.
## Never create direct references between feature scripts.

signal enemy_died(xp_amount: int)
## Request: "apply this much damage to the player", already rate-limited by PlayerHurtBox.
## Listeners apply it; they must NOT re-emit it. Story 1.5's health system emits
## player_health_changed for HUD/feedback instead, so the two directions stay separate.
signal player_damaged(amount: int)
## Notification for HUD and feedback: emitted by the player after every accepted health change.
signal player_health_changed(current: float, maximum: float)
## Emitted exactly once when the player's health reaches 0. GameManager decides what it means.
signal player_died()
signal wave_completed()
## A weapon just fired. Nothing listens yet.
signal weapon_fired(weapon_name: String, position: Vector2)
## Raw contact report from an enemy hitbox, emitted every physics frame while overlapping.
## Only PlayerHurtBox should listen; it collapses these into player_damaged.
signal enemy_reached_player(damage: int)
