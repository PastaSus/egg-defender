---
project_name: 'egg-defender'
user_name: 'Administrator'
date: '2026-09-18'
sections_completed: ['technology_stack', 'critical_implementation_rules', 'code_patterns', 'architecture']
existing_patterns_found: 8
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing game code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

| Technology | Version | Notes |
|---|---|---|
| **Godot Engine** | 4.2+ | GL Compatibility renderer, 2D canvas mode |
| **GDScript** | 4.x | Typed variables, `@export`, `class_name` syntax |
| **Display** | 1280×720 | `canvas_items` stretch mode, `keep` aspect |
| **Texture Filtering** | Nearest (0) | Pixel-art friendly, no blurring |

---

## Critical Implementation Rules

### Architecture Rules (NON-NEGOTIABLE)

1. **SignalBus Only** — All feature-to-feature communication MUST go through `SignalBus` autoload. Never create direct node references between `features/` subdirectories.
2. **Core vs Features** — `core/` contains autoloads and data resources. `features/` contains gameplay logic. Never put gameplay logic in `core/`.
3. **Autoload Registration** — New autoloads must be registered in `project.godot` under `[autoload]` section.
4. **StatsResource Extension** — When creating new entity types (enemies, weapons), extend `StatsResource` with `class_name`. Never duplicate stat fields.

### GDScript 4.x Rules

5. **Typed Variables** — Always use typed variables: `var health: float = 100.0` not `var health = 100.0`
6. **Signal Connections** — Connect signals in `_ready()` using `SignalBus.signal_name.connect(_on_handler)`
7. **Export Syntax** — Use `@export var name: Type = default` for inspector-exposed properties
8. **Class Names** — Use `class_name ClassName` for reusable resource types

### Performance Rules

9. **Object Pooling** — Enemy bullets and effects must use object pooling, not `queue_free()`/`instantiate()` cycles
10. **Frame Budget** — Target 60fps (16.67ms per frame). Profile spawning systems under heavy load
11. **Signal Arguments** — Keep signal payloads minimal. Use `int` or `float`, not full objects

### Scene & Node Rules

12. **Scene Instancing** — Use `preload()` or `load()` for scene references, never hardcoded paths
13. **Node Ownership** — Scenes must have proper ownership for save/load compatibility
14. **Group System** — Use groups for enemy tracking (`add_to_group("enemies")`), not node references

---

## Code Patterns

### Folder Structure
```
core/
├── autoload/          # Global singletons (SignalBus, GameManager)
│   ├── signal_bus.gd
│   └── game_manager.gd
└── data/              # Resource definitions
    └── stats_resource.gd

features/
├── player_egg/        # Player egg cell logic
├── enemies/           # Enemy types and spawners
├── weapons/           # Weapon systems
└── ui/                # HUD, menus, overlays
```

### Signal Naming Convention
- Past tense for events: `enemy_died`, `wave_completed`
- Verb-noun pattern: `player_damaged`, `weapon_fired`
- Always in `signal_bus.gd`, never local signals for cross-feature use

### Resource Pattern
```gdscript
class_name EnemyStats
extends StatsResource

@export var xp_reward: int = 10
@export var spawn_weight: float = 1.0
```

### Autoload Access Pattern
```gdscript
# Correct - via autoload
SignalBus.enemy_died.emit(xp_amount)

# Wrong - direct reference
get_node("/root/SignalBus").enemy_died.emit(xp_amount)
```

---

## Architecture

### Communication Flow
```
Features → SignalBus → GameManager
    ↑              ↑
    │              └── Score tracking, wave state
    └── Enemy, weapon, player events
```

### State Management
- **GameManager** — Global state (wave number, score, game over flag)
- **Feature State** — Each feature manages its own local state
- **No Shared State** — Never store cross-feature state in SignalBus

### Input Handling
- Player input handled in `features/player_egg/`
- UI input handled in `features/ui/`
- Pause/game-over states managed by GameManager

---

## Summary

This is a **2D horde-survival arcade game** built in Godot 4 with GDScript. The egg cell (player) defends against swarms of sperm (enemies) using various weapons. Key mechanics include wave progression, XP/score tracking, and weapon upgrades. All modules communicate through a centralized SignalBus to maintain decoupling.
