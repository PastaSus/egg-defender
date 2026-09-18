# Egg Defender - Game Design Document

**Author:** Administrator
**Game Type:** 2D Horde Survival / Bullet Heaven / Roguelite
**Target Platform(s):** PC (primary), Mobile (secondary)

---

## Executive Summary

### Core Concept

Egg Defender is a 2D horde-survival arcade game where players control an egg cell defending against endless waves of sperm enemies. Using auto-attacking biological weapons and strategic positioning, survive increasingly chaotic waves while upgrading your defenses between runs.

### Target Audience

**Primary:** Casual gamers (18-35) who enjoy Vampire Survivors-style games and appreciate humor/absurd themes. Players seeking quick 15-25 minute roguelite sessions.

**Secondary:** Roguelite enthusiasts looking for build variety and meta-progression in a lighthearted package.

### Unique Selling Points (USPs)

1. **Biological Humor Theme** — No other horde survivor uses cellular biology as the core aesthetic
2. **Absurd Weapon Concepts** — Acid sprays, mucus shields, nucleus beams, and more
3. **Quick Sessions** — 15-25 minute runs designed for pick-up-and-play
4. **Simplified Meta** — Faster unlocks than Vampire Survivors, less grind

---

## Goals and Context

### Project Goals

- Create a polished horde survival game with strong game feel
- Deliver satisfying auto-combat with meaningful upgrade choices
- Build replayable roguelite runs with distinct weapon builds
- Establish humorous, memorable brand identity

### Background and Rationale

The Vampire Survivors genre has proven mass appeal with simple controls and deep build variety. Egg Defender differentiates through absurd biological humor and a cellular warfare theme, targeting players who want the same addictive loop with a lighter, funnier tone.

---

## Core Gameplay

### Game Pillars

1. **Absurd Biological Humor** — Every weapon, enemy, and upgrade leans into the silly cellular warfare theme
2. **Satisfying Auto-Combat** — Weapons fire automatically; focus on positioning and dodging
3. **Build Variety** — Different weapon combinations create unique run experiences
4. **Quick Runs** — 15-25 minute sessions with meaningful meta-progression

### Core Gameplay Loop

```
┌─────────────────────────────────────────────────────────────┐
│  START RUN                                                  │
│  ↓                                                          │
│  WAVE BEGINS → Auto-attack enemies → Collect XP gems        │
│  ↓                                                          │
│  LEVEL UP → Choose 1 of 3 upgrades (weapon/new/upgrade)     │
│  ↓                                                          │
│  WAVE COMPLETE → Next wave starts (harder)                   │
│  ↓                                                          │
│  REPEAT until death or wave 50                               │
│  ↓                                                          │
│  RUN END → Collect coins → Meta-upgrade shop → Return to hub │
└─────────────────────────────────────────────────────────────┘
```

### Win/Loss Conditions

**Win:** Clear wave 50 (or survive 30 minutes) — unlocks new content
**Loss:** Health reaches 0 — keep earned coins for meta-progression
**Partial Victory:** High scores, fastest clear times, achievement unlocks

---

## Game Mechanics

### Primary Mechanics

#### Movement
- **WASD / Arrow Keys / Joystick** — 8-directional movement
- **Speed:** 200 base units/second, upgradeable
- **Collision:** Player hurtbox is small circle (egg yolk center)

#### Auto-Attack System
- Weapons fire automatically at nearest enemy or in set patterns
- Player focuses on positioning, not aiming
- Weapon slots: 1 starting + 4 unlockable = 5 max per run

#### XP & Leveling
- Enemies drop XP gems on death
- Collect gems to fill XP bar
- Each level-up: Choose 1 of 3 random upgrades
- Upgrades: New weapon, weapon evolution, stat boost, or passive

#### Health System
- Player starts with 100 HP (upgradeable via meta)
- Enemies deal damage on contact
- Healing: Rare health drops from elite enemies, or healing upgrades
- No regen by default (meta-progression can add slow regen)

### Controls and Input

| Platform | Movement | Special |
|---|---|---|
| PC | WASD / Arrows | Pause: ESC / P |
| Mobile | Virtual joystick | Pause: Tap button |
| Gamepad | Left stick | Start: Pause |

**Design Principle:** One thumb controls movement. That's it. Everything else is automatic.

---

## Weapons

### Weapon Categories

#### Tier 1 — Starting Weapons (Choose 1 to start)

| Weapon | Type | Description |
|---|---|---|
| **Yolk Spit** | Projectile | Fires small yolk globs at nearest enemy |
| **Shell Fragment** | AoE | Explodes shell pieces in a circle around player |
| **Mucus Trail** | DOT | Leaves damaging slime trail behind player |

#### Tier 2 — Unlockable Weapons

| Weapon | Type | Description |
|---|---|---|
| **Acid Spray** | Cone | Short-range cone of acid, high damage |
| **Nucleus Beam** | Piercing | Laser beam that pierces through enemies |
| **Flagellum Whip** | Melee | Circular whip attack around player |
| **Membrane Shield** | Defensive | Orbiting shield that blocks projectiles |

#### Tier 3 — Evolution Weapons (Combine Tier 1+2)

| Evolution | Components | Description |
|---|---|---|
| **Tsunami** | Mucus Trail + Acid Spray | Massive damaging wave forward |
| **Supernova** | Shell Fragment + Nucleus Beam | screen-clearing explosion |
| **Vortex** | Yolk Spit + Flagellum | Spiraling projectile storm |

### Weapon Stats

```gdscript
class_name WeaponStats
extends StatsResource

@export var weapon_name: String = ""
@export var weapon_type: String = "projectile"  # projectile, aoe, dot, cone, piercing, melee, defensive
@export var base_damage: float = 10.0
@export var fire_rate: float = 1.0  # attacks per second
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var piercing: int = 0
@export var area_multiplier: float = 1.0
@export var knockback: float = 0.0
```

---

## Enemies

### Enemy Types

#### Basic Enemies

| Enemy | HP | Speed | Damage | Behavior |
|---|---|---|---|---|
| **Sperm Cell** | 10 | 150 | 10 | Straight-line charge at player |
| **Swarm Sperm** | 5 | 200 | 5 | Fast, weak, spawns in groups of 5-10 |
| **Fat Sperm** | 50 | 80 | 20 | Slow, tanky, blocks other enemies |
| **Fast Sperm** | 8 | 300 | 8 | Zig-zag movement, hard to hit |

#### Elite Enemies (Rare, tougher variants)

| Enemy | HP | Speed | Damage | Special |
|---|---|---|---|---|
| **Mega Sperm** | 200 | 120 | 30 | Spawns minions on death |
| **Shield Sperm** | 100 | 100 | 15 | Frontal shield, must hit from behind |
| **Splitter** | 80 | 150 | 12 | Splits into 2 when killed |

#### Boss Enemies (Wave 5, 10, 15, etc.)

| Boss | HP | Mechanics |
|---|---|---|
| **The Patriarch** | 1000 | Spawns minions, charge attack, shield phase |
| **The Swarm King** | 800 | Constant minion summoning, area denial |
| **The Mutant** | 1500 | Changes resistances, projectile reflection |

### Enemy Spawning

```gdscript
class_name SpawnWave
extends Resource

@export var wave_number: int = 1
@export var enemy_types: Array[String] = ["sperm"]
@export var spawn_count: int = 10
@export var spawn_rate: float = 1.0  # enemies per second
@export var spawn_patterns: Array[String] = ["random"]  # random, circle, line, rush
@export var boss_wave: bool = false
```

### Wave Progression

| Wave | Enemy Count | Types | Difficulty |
|---|---|---|---|
| 1-5 | 10-30 | Sperm only | Tutorial pace |
| 6-10 | 30-60 | + Swarm, Fat | Building intensity |
| 11-15 | 60-100 | + Fast, Elite | Peak action |
| 16-20 | 100-150 | All types | Chaos |
| 21+ | 150+ | Dense hordes | Endgame |

---

## Progression and Balance

### Player Progression

#### In-Run Progression
- **XP Bar:** Collect gems → Level up → Choose upgrade
- **Upgrade Choices:** 3 random options from pool
  - New weapon (if slot available)
  - Weapon upgrade (damage, fire rate, count)
  - Stat boost (health, speed, armor, magnet range)
  - Passive ability (XP gain, health regen, etc.)

#### Meta-Progression (Between Runs)

**Currency:** Coins earned during runs (based on enemies killed, waves cleared)

**Permanent Upgrades (Unlock Shop):**

| Upgrade | Cost | Effect |
|---|---|---|
| Extra HP | 100 | +10 max HP |
| Move Speed | 75 | +5% move speed |
| XP Boost | 100 | +10% XP gain |
| Starting Weapon | 200 | Unlock new starting weapon |
| Weapon Slot | 300 | +1 max weapon slot |
| Armor | 150 | -10% damage taken |
| Magnet Range | 50 | +20% XP pickup range |
| Health Regen | 200 | +1 HP per 10 seconds |

### Difficulty Curve

**Wave Scaling Formula:**
```
enemy_hp = base_hp * (1 + wave * 0.15)
enemy_count = base_count * (1 + wave * 0.1)
spawn_rate = base_rate * (1 + wave * 0.05)
```

**Player Power Curve:**
- Waves 1-5: Player at 100% relative power (learning phase)
- Waves 6-15: Player builds to 150-200% power (power fantasy)
- Waves 16-25: Enemies catch up, player at 120-150% (challenge)
- Waves 25+: Enemies outscale, test of skill and build optimization

### Economy and Resources

**Run Economy:**
- XP gems: Blue (common, 1pt), Green (uncommon, 5pt), Red (rare, 25pt)
- Coins: Dropped by elites and bosses, scales with wave
- Health orbs: Rare drop from elites, restores 20 HP

**Meta Economy:**
- Coins persist between runs
- No pay-to-win, no microtransactions (premium game)
- Unlock pacing: ~3-5 runs to unlock first new weapon, ~10 runs for full roster

---

## Level Design Framework

### Arena Structure

**Single Arena:** 2000x2000 pixel play area with soft boundaries
- Camera follows player
- Enemies spawn from edges
- No walls or obstacles in MVP (flat arena)

**Visual Themes (Cosmetic, unlockable):**
1. **Petri Dish** — Default, clean laboratory aesthetic
2. **Human Body** — Inside bloodstream, organic backgrounds
3. **Microscope View** — Scientific, grid overlay

### Level Progression

**No traditional levels** — Wave-based progression within single arena
- Visual changes at wave milestones (5, 10, 15, 20)
- Lighting shifts (brighter → darker → dramatic)
- Background elements animate faster at higher waves

---

## Art and Audio Direction

### Art Style

**Aesthetic:** Cartoon cellular biology — "Osmosis Jones meets Vampire Survivors"

**Color Palette:**
- Player (Egg): White shell, yellow yolk, warm glow
- Enemies (Sperm): Blue/white tails, varying sizes
- XP Gems: Bright blue, green, red
- UI: Clean, minimal, biological textures

**Animation Style:**
- Exaggerated squash/stretch on attacks
- Juice screenshake on big hits
- Particle effects for impacts, deaths, upgrades
- Enemy death: Satisfying pop/splat effects

### Audio and Music

**Soundtrack:** Upbeat electronic/synth with biological undertones
- Wave 1-5: Calm, building energy
- Wave 6-15: Intense, driving beat
- Wave 16+: Chaotic, layered

**SFX:**
- Attacks: Squish, splat, pop sounds
- XP collection: Satisfying chime
- Level up: Ascending tone
- Death: Dramatic but humorous
- UI: Clean clicks, biological bubbles

---

## Technical Specifications

### Performance Requirements

- **Target FPS:** 60fps on mid-range PC, 30fps minimum on low-end
- **Max Enemies on Screen:** 200+ simultaneously
- **Object Pooling:** Required for enemies, projectiles, XP gems
- **Draw Calls:** Minimize via batching, use CanvasItem nodes efficiently

### Platform-Specific Details

**PC:**
- Resolution: 1280x720 native, scaling to 1920x1080
- Input: Keyboard/Mouse, Gamepad
- Renderer: GL Compatibility

**Mobile (Post-MVP):**
- Resolution: Adapt to device
- Input: Virtual joystick
- Touch targets: Minimum 44x44px

### Asset Requirements

**Characters:**
- Player: 1 animated sprite sheet (idle, move, attack, hurt, death)
- Enemies: 5 base + 3 elite + 3 boss sprite sheets

**Weapons:**
- 7 weapon visual effects (projectile or area)
- 3 evolution effects (screen-wide)

**UI:**
- HUD: Health bar, XP bar, wave counter, score, timer
- Menus: Main menu, pause, upgrade selection, meta shop
- Fonts: Clear, readable at small sizes

---

## Development Epics

### Epic Structure

| Epic | Description | Priority |
|---|---|---|
| **E1: Core Foundation** | Player movement, basic enemy, auto-attack | P0 — Must Have |
| **E2: Wave System** | Enemy spawning, wave progression, difficulty scaling | P0 — Must Have |
| **E3: Weapon System** | Weapon slots, upgrades, evolutions | P0 — Must Have |
| **E4: Progression** | XP system, level-up UI, upgrade choices | P0 — Must Have |
| **E5: Meta-Progression** | Coins, unlock shop, permanent upgrades | P1 — Should Have |
| **E6: Content** | Enemy variety, boss fights, arena themes | P1 — Should Have |
| **E7: Juice & Polish** | Particles, screenshake, SFX, animations | P1 — Should Have |
| **E8: UI & Menus** | Main menu, pause, HUD, game over | P1 — Should Have |
| **E9: Mobile Port** | Touch controls, UI scaling, optimization | P2 — Nice to Have |
| **E10: Audio** | Music, SFX implementation | P2 — Nice to Have |

---

## Success Metrics

### Technical Metrics

- 60fps with 200+ enemies on screen
- Load time < 3 seconds
- No memory leaks during 30+ minute runs
- Build size < 100MB

### Gameplay Metrics

- First run completion rate > 50%
- Average session length: 15-25 minutes
- Replay rate: 3+ runs per session
- Time to "fun": < 30 seconds from start

---

## Out of Scope

- Multiplayer (co-op or competitive)
- Narrative campaign
- Procedurally generated arenas
- Complex crafting systems
- Voice acting
- Console ports (initially)

---

## Assumptions and Dependencies

### Assumptions

- Solo developer with GDScript/Godot experience
- No external art assets required (programmer art or simple sprites initially)
- Godot 4.2+ with GL Compatibility renderer sufficient
- 3-6 month development timeline for MVP

### Dependencies

- Godot Engine 4.2+
- No external plugins required
- SignalBus architecture pattern must be maintained
