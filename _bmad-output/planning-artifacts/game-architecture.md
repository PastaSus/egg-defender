# Egg Defender — Game Architecture

**Engine:** Godot 4.2+
**Language:** GDScript 4.x
**Renderer:** GL Compatibility
**Platform:** PC (primary), Mobile (secondary)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CORE (Autoloads)                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ SignalBus   │  │ GameManager │  │ AudioManager│        │
│  │ (Events)    │  │ (State)     │  │ (SFX/Music) │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    DATA (Resources)                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │WeaponStats  │  │ EnemyStats  │  │ WaveConfig  │        │
│  │PlayerStats  │  │ UpgradeData │  │ MetaProgress│        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    FEATURES (Scenes)                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ Player   │ │ Enemies  │ │ Weapons  │ │    UI    │      │
│  │  _egg/   │ │          │ │          │ │          │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Systems

### SignalBus (Event Bus)

**Location:** `core/autoload/signal_bus.gd`

**Purpose:** Decoupled communication between all features. No direct node references between features.

**Signals:**

```gdscript
# Player Events
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal player_died()
signal player_leveled_up(new_level: int)

# Enemy Events
signal enemy_spawned(enemy: Node2D)
signal enemy_died(xp_amount: int, position: Vector2)
signal enemy_reached_player(damage: int)

# Weapon Events
signal weapon_fired(weapon_name: String, position: Vector2)
signal weapon_hit(enemy: Node2D, damage: float)
signal weapon_evolved(weapon_name: String, new_level: int)

# Wave Events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal boss_spawned(boss_name: String)
signal boss_defeated(boss_name: String)

# UI Events
signal upgrade_selected(upgrade_data: UpgradeData)
signal game_paused()
signal game_resumed()
signal run_ended(stats: RunStats)

# Meta Events
signal coins_earned(amount: int)
signal item_purchased(item_id: String)
```

### GameManager (State Manager)

**Location:** `core/autoload/game_manager.gd`

**Purpose:** Global game state, run management, persistence.

**State:**

```gdscript
enum GameState {
    MAIN_MENU,
    STAGE_SELECT,
    PLAYING,
    PAUSED,
    LEVEL_UP,
    RUN_END,
    UNLOCK_SHOP
}

var current_state: GameState = GameState.MAIN_MENU
var current_wave: int = 0
var run_stats: RunStats = null
var meta_data: MetaData = null
```

**Responsibilities:**
- Track game state transitions
- Manage run statistics (kills, time, score)
- Handle meta-progression persistence (save/load)
- Coordinate pause/resume

### AudioManager (Future)

**Location:** `core/autoload/audio_manager.gd`

**Purpose:** Centralized sound and music management.

**Features:**
- Object pooling for SFX
- Music crossfading
- Volume controls per category (SFX, Music, UI)

---

## Data Resources

### StatsResource (Base)

**Location:** `core/data/stats_resource.gd`

```gdscript
class_name StatsResource
extends Resource

@export var health: float = 100.0
@export var speed: float = 200.0
@export var damage: float = 10.0
@export var cooldown: float = 1.0
```

### WeaponStats

**Location:** `core/data/weapon_stats.gd`

```gdscript
class_name WeaponStats
extends StatsResource

@export var weapon_name: String = ""
@export var weapon_type: String = "projectile"
@export var base_damage: float = 10.0
@export var fire_rate: float = 1.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var piercing: int = 0
@export var area_multiplier: float = 1.0
@export var knockback: float = 0.0
@export var projectile_scene: PackedScene
```

### EnemyStats

**Location:** `core/data/enemy_stats.gd`

```gdscript
class_name EnemyStats
extends StatsResource

@export var enemy_name: String = ""
@export var xp_reward: int = 10
@export var coin_reward: int = 0
@export var spawn_weight: float = 1.0
@export var is_elite: bool = false
@export var is_boss: bool = false
```

### WaveConfig

**Location:** `core/data/wave_config.gd`

```gdscript
class_name WaveConfig
extends Resource

@export var wave_number: int = 1
@export var enemy_types: Array[EnemySpawnEntry] = []
@export var spawn_rate: float = 1.0
@export var spawn_patterns: Array[String] = ["random"]
@export var boss_wave: bool = false
@export var boss_enemy: EnemyStats = null
```

### UpgradeData

**Location:** `core/data/upgrade_data.gd`

```gdscript
class_name UpgradeData
extends Resource

@export var upgrade_name: String = ""
@export var upgrade_type: String = "weapon"  # weapon, stat, passive
@export var icon: Texture2D
@export var description: String = ""
@export var level: int = 1
@export var max_level: int = 5
@export var stat_modifiers: Dictionary = {}
```

### RunStats

**Location:** `core/data/run_stats.gd`

```gdscript
class_name RunStats
extends Resource

@export var waves_cleared: int = 0
@export var enemies_killed: int = 0
@export var xp_collected: int = 0
@export var coins_earned: int = 0
@export var time_survived: float = 0.0
@export var score: int = 0
@export var highest_wave: int = 0
```

---

## Feature Modules

### Player (features/player_egg/)

**Scene:** `player_egg.tscn`

**Node Structure:**
```
Player (CharacterBody2D)
├── CollisionShape2D (CircleShape2D - yolk)
├── Sprite2D (Egg sprite)
├── HurtBox (Area2D - takes damage)
│   └── CollisionShape2D
├── HitBox (Area2D - deals contact damage)
│   └── CollisionShape2D
├── WeaponPivot (Node2D - weapons orbit here)
├── AnimationPlayer
└── Player.gd
```

**Player.gd Responsibilities:**
- Handle movement input
- Manage health (take damage, heal)
- Emit signals via SignalBus
- Collect XP gems (magnet range)

### Enemies (features/enemies/)

**Scene:** `enemy_base.tscn`

**Node Structure:**
```
Enemy (CharacterBody2D)
├── CollisionShape2D (varies by type)
├── Sprite2D (Enemy sprite)
├── HurtBox (Area2D - takes damage)
│   └── CollisionShape2D
├── HitBox (Area2D - deals damage on contact)
│   └── CollisionShape2D
├── HealthComponent (Node - manages HP)
├── NavigationAgent2D (pathfinding)
└── Enemy.gd
```

**Enemy.gd Responsibilities:**
- Move toward player (or patrol)
- Take damage and die
- Drop XP gems on death
- Emit enemy_died signal

**Enemy Types (Inheritance):**
```
EnemyBase (enemy_base.gd)
├── SpermCell (sperm_cell.gd) - Basic charge
├── SwarmSperm (swarm_sperm.gd) - Fast, weak
├── FatSperm (fat_sperm.gd) - Tanky, slow
├── FastSperm (fast_sperm.gd) - Zigzag movement
└── EliteEnemy (elite_enemy.gd) - Base for elites
```

### Weapons (features/weapons/)

**Scene:** `weapon_base.tscn`

**Node Structure:**
```
Weapon (Node2D)
├── Sprite2D (Weapon icon/visual)
├── Timer (Fire rate cooldown)
├── WeaponPivot (Node2D - rotation point)
└── Weapon.gd
```

**Weapon.gd Responsibilities:**
- Track fire rate cooldown
- Spawn projectiles on fire
- Apply upgrades and modifiers
- Handle weapon evolution

**Weapon Types (Inheritance):**
```
WeaponBase (weapon_base.gd)
├── ProjectileWeapon (projectile_weapon.gd) - Yolk Spit
├── AoEWeapon (aoe_weapon.gd) - Shell Fragment
├── DOTWeapon (dot_weapon.gd) - Mucus Trail
├── ConeWeapon (cone_weapon.gd) - Acid Spray
├── PiercingWeapon (piercing_weapon.gd) - Nucleus Beam
├── MeleeWeapon (melee_weapon.gd) - Flagellum Whip
└── DefensiveWeapon (defensive_weapon.gd) - Membrane Shield
```

### Projectiles (features/weapons/)

**Scene:** `projectile_base.tscn`

**Node Structure:**
```
Projectile (Area2D)
├── CollisionShape2D (varies)
├── Sprite2D
├── LifetimeTimer (auto-destroy)
└── Projectile.gd
```

**Object Pooling:** All projectiles use pooling, not instantiate/free.

### UI (features/ui/)

**Scenes:**
```
ui/
├── hud.tscn           (in-game overlay)
├── main_menu.tscn     (title screen)
├── pause_menu.tscn    (pause overlay)
├── level_up.tscn      (upgrade selection)
├── game_over.tscn     (run summary)
├── unlock_shop.tscn   (meta-progression)
└── stage_select.tscn  (level selection)
```

**UI communicates via SignalBus only.** No direct references to Player or Enemy nodes.

---

## Object Pooling System

**Location:** `core/autoload/pool_manager.gd` (Future)

**Pattern:**
```gdscript
# Pre-instantiate pool of objects
var projectile_pool: Array[Node2D] = []
const POOL_SIZE: int = 100

func _ready() -> void:
    for i in POOL_SIZE:
        var proj = projectile_scene.instantiate()
        proj.visible = false
        proj.set_process(false)
        add_child(proj)
        projectile_pool.append(proj)

func get_projectile() -> Node2D:
    for proj in projectile_pool:
        if not proj.visible:
            proj.visible = true
            proj.set_process(true)
            return proj
    # Pool exhausted - expand or recycle oldest
    return null

func return_projectile(proj: Node2D) -> void:
    proj.visible = false
    proj.set_process(false)
    proj.global_position = Vector2.ZERO
```

**Pooled Objects:**
- Enemy bullets (if any)
- Player projectiles
- XP gems
- Damage numbers
- Particle effects

---

## Scene Management

**Main Scene:** `core/autoload/game_manager.gd` (entry point)

**Scene Transitions:**
```
Main Menu → Stage Select → Gameplay (instanced)
                            ↕
                          Pause Menu (overlay)
                            ↕
                          Level Up (overlay)
                            ↕
                          Game Over → Unlock Shop → Main Menu
```

**Scene Instancing Pattern:**
```gdscript
# In GameManager
var current_run_scene: Node2D = null

func start_run(stage: String) -> void:
    var scene_path = "res://features/gameplay/%s.tscn" % stage
    current_run_scene = load(scene_path).instantiate()
    add_child(current_run_scene)
    current_state = GameState.PLAYING

func end_run() -> void:
    current_run_scene.queue_free()
    current_run_scene = null
    current_state = GameState.RUN_END
```

---

## Input Handling

**Input Map (project.godot):**

| Action | PC Keys | Gamepad | Mobile |
|---|---|---|---|
| `move_up` | W, Up | Left Stick Up | Virtual Joystick Y- |
| `move_down` | S, Down | Left Stick Down | Virtual Joystick Y+ |
| `move_left` | A, Left | Left Stick Left | Virtual Joystick X- |
| `move_right` | D, Right | Left Stick Right | Virtual Joystick X+ |
| `pause` | Escape, P | Start | Pause Button |
| `upgrade_1` | 1 | — | Tap Card 1 |
| `upgrade_2` | 2 | — | Tap Card 2 |
| `upgrade_3` | 3 | — | Tap Card 3 |

**Input Processing:**
- Player reads input in `_physics_process()`
- UI reads input in `_input()` or `_unhandled_input()`
- No direct input handling in autoloads

---

## Performance Budget

**Target:** 60fps on mid-range PC

| System | Budget | Notes |
|---|---|---|
| Player update | 0.1ms | Movement, collision |
| Enemy updates | 2.0ms | 200+ enemies |
| Weapon updates | 1.0ms | 5 weapons × fire rate |
| Projectile updates | 1.0ms | 50+ projectiles |
| XP gem updates | 0.5ms | 100+ gems |
| UI updates | 0.5ms | HUD, effects |
| Rendering | 4.0ms | Canvas items, particles |
| Physics | 1.0ms | Collision detection |
| **Total** | **~10ms** | **Leaves 6.67ms headroom** |

**Optimization Strategies:**
- Object pooling for all frequently spawned objects
- Distance-based enemy AI (simplify far enemies)
- Batch rendering for similar sprites
- Profile with Godot's built-in profiler

---

## File Structure

```
egg-defender/
├── project.godot
├── core/
│   ├── autoload/
│   │   ├── signal_bus.gd
│   │   ├── game_manager.gd
│   │   └── pool_manager.gd (future)
│   └── data/
│       ├── stats_resource.gd
│       ├── weapon_stats.gd
│       ├── enemy_stats.gd
│       ├── wave_config.gd
│       ├── upgrade_data.gd
│       └── run_stats.gd
├── features/
│   ├── player_egg/
│   │   ├── player_egg.tscn
│   │   └── player.gd
│   ├── enemies/
│   │   ├── enemy_base.tscn
│   │   ├── enemy_base.gd
│   │   ├── sperm_cell.gd
│   │   ├── swarm_sperm.gd
│   │   ├── fat_sperm.gd
│   │   └── fast_sperm.gd
│   ├── weapons/
│   │   ├── weapon_base.tscn
│   │   ├── weapon_base.gd
│   │   ├── projectile_base.tscn
│   │   ├── projectile_base.gd
│   │   ├── yolk_spit.gd
│   │   ├── acid_spray.gd
│   │   └── ...
│   └── ui/
│       ├── hud.tscn
│       ├── hud.gd
│       ├── main_menu.tscn
│       ├── main_menu.gd
│       └── ...
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── weapons/
│   │   └── ui/
│   ├── audio/
│   │   ├── sfx/
│   │   └── music/
│   └── fonts/
└── docs/
    ├── AGENTS.md
    └── project-context.md
```

---

## Key Patterns

### Signal Connection Pattern

```gdscript
# In any feature script
func _ready() -> void:
    SignalBus.enemy_died.connect(_on_enemy_died)
    SignalBus.player_damaged.connect(_on_player_damaged)

func _on_enemy_died(xp_amount: int) -> void:
    # React to enemy death
    pass
```

### Resource Inheritance Pattern

```gdscript
# Create new entity types by extending StatsResource
class_name SpermCellStats
extends EnemyStats

@export var charge_speed: float = 300.0
@export var can_split: bool = false
```

### Scene Instancing Pattern

```gdscript
# Preload scenes at class level
const ENEMY_SCENE = preload("res://features/enemies/enemy_base.tscn")

func spawn_enemy(stats: EnemyStats) -> void:
    var enemy = ENEMY_SCENE.instantiate()
    enemy.stats = stats
    enemy.global_position = get_spawn_position()
    add_child(enemy)
```

### Save/Load Pattern (Meta-Progression)

```gdscript
# In GameManager
const SAVE_PATH = "user://save_game.dat"

func save_meta() -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_var(meta_data)
    file.close()

func load_meta() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
        meta_data = file.get_var()
        file.close()
    else:
        meta_data = MetaData.new()
```

---

## Testing Strategy

**Unit Tests:**
- StatsResource calculations
- Wave progression formulas
- Save/load functionality

**Integration Tests:**
- Weapon damage application
- Enemy spawning and death
- XP collection and leveling

**Manual Testing:**
- Game feel and juice
- Performance under load
- Platform-specific input

---

## Future Considerations

**Not in MVP:**
- Multiplayer (co-op)
- Procedural arenas
- Complex crafting
- Console ports

**Scalability:**
- Modular weapon system allows easy addition
- Enemy types inherit from base
- Wave configs are data-driven (Resource files)
- UI is scene-based, easily rearranged
