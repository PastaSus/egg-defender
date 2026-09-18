# Egg Defender - AI Agent Guidelines

## Project Structure

- `core/` — Core systems (autoloads, data resources). **All game-wide logic lives here.**
- `features/` — Gameplay features (player, enemies, weapons, UI). **No direct cross-feature references.**
- `assets/` — Art, audio, and other assets.

## Communication Rule

All feature scripts in `features/` **must** communicate through `SignalBus` (core/autoload/signal_bus.gd). Never create direct node references between features. This keeps modules decoupled and independently testable.

**Examples:**
- Enemy dies → emit `SignalBus.enemy_damaged(amount)` or `SignalBus.enemy_died(xp_amount)`
- Wave ends → emit `SignalBus.wave_completed()`
- Player takes damage → emit `SignalBus.player_damaged(amount)`

## Core System Responsibilities

| Autoload | Role |
|---|---|
| `SignalBus` | Global event bus. All inter-feature signals defined here. |
| `GameManager` | Game state (wave, score, game-over). Entry point for starting/restarting. |

## Code Conventions

- Use GDScript 4.x syntax (`@export`, typed variables, `class_name`).
- Keep feature scripts self-contained within their `features/` subdirectory.
- Extend `StatsResource` for new entity types; do not duplicate stat fields.
