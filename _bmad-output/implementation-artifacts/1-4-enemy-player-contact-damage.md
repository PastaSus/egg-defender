---
baseline_commit: b19ac421e059f614a80c6016671abe90e453673f
---

# Story 1.4: Enemy-player collision (damage on contact)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a player,
I want enemies that touch me to hurt me, but not more than once in quick succession,
so that dodging matters and a crowd of enemies is dangerous without being an instant kill.

## Acceptance Criteria

1. **Layer convention extended.** `project.godot` `[layer_names]` gains `2d_physics/layer_4="player_hurtbox"` and `2d_physics/layer_5="enemy_hurtbox"`. Layers 1 (`world`), 2 (`player`), 3 (`enemy`) are untouched. Layer 5 is reserved: no node uses it in this story (needed once player weapons hit enemies, a later epic). [Source: user decision; Story 1.3 Dev Notes]
2. **Player HurtBox.** `features/player_egg/player_egg.tscn` gains a child `Area2D` named `HurtBox` with a `CircleShape2D` (radius 8, the "small circle, egg yolk center" from gdd.md#Movement): `collision_layer = 8` (layer 4), `collision_mask = 0`, `monitoring = false`, `monitorable = true`. [Source: gdd.md#Movement; game-architecture.md#Player node structure]
3. **Enemy HitBox.** Both `features/enemies/sperm_cell.tscn` and `features/enemies/enemy_base.tscn` gain a child `Area2D` named `HitBox` with a `CircleShape2D` (radius 14): `collision_layer = 0`, `collision_mask = 8` (layer 4), `monitoring = true`, `monitorable = false`. [Source: game-architecture.md#Enemies node structure]
4. **Contact reports damage, including sustained contact.** While an enemy's HitBox overlaps a player HurtBox, the enemy emits `SignalBus.enemy_reached_player(damage: int)` **every physics frame** with `roundi(stats.damage)` (10 for SpermCell). It must not rely only on `area_entered`: an enemy that stays on top of the player must keep hurting them (see Dev Notes, "area_entered fires once").
5. **Player-side invulnerability gate.** A script on the Player's `HurtBox` listens to `SignalBus.enemy_reached_player`. When not invulnerable it emits `SignalBus.player_damaged(amount)` with the same amount and starts an invulnerability window of `stats.cooldown` seconds (the existing `StatsResource.cooldown` field, default `1.0`, not a new field). Signals received during the window are ignored. [Source: user decision]
6. **Simultaneous enemies are safe.** With two or more SpermCells touching the player in the same window, exactly one `player_damaged` is emitted per window, not one per enemy. [Source: user decision; resolves the damage side of the enemy-stacking concern]
7. **Sustained contact repeats.** A player standing still under a SpermCell takes one hit at first contact and then one hit every `cooldown` seconds (about 1 s) for as long as the overlap lasts.
8. **Overlap jitter fixed (folded in from the 1.3 deferred ledger).** `SpermCell` stops moving once its distance to the player is within `arrival_distance` (`@export var arrival_distance: float = 10.0`), returning `Vector2.ZERO` from `_get_move_direction()`. It resumes charging when the player moves out of that distance. No visible vibrating at contact, no NaN or zero-vector edge cases at exact overlap. `arrival_distance` must stay smaller than the HitBox+HurtBox contact range (14 + 8 = 22) so a stopped enemy keeps damaging the player. [Source: deferred-work.md "No arrival/stop distance"; user decision]
9. **Scope boundaries held.** No `HealthComponent`, no HP variable, no death or game-over, no HUD or screen-flash feedback. The enemy still neither blocks nor pushes the player (no physics-layer overlap between `enemy` and `player` bodies is introduced). [Source: user decision; epics-and-stories.md E1-S5]
10. `arena.tscn` contains two `SpermCell` instances at opposite sides of the player, and the scene runs without errors or missing-reference warnings.

## Tasks / Subtasks

- [x] Task 0: Extend collision layer names (AC: #1)
  - [x] Append `2d_physics/layer_4="player_hurtbox"` and `2d_physics/layer_5="enemy_hurtbox"` to the existing `[layer_names]` section of `project.godot`. Do not touch layers 1–3 or any other section.
- [x] Task 1: Add `enemy_reached_player` to SignalBus (AC: #4, #5)
  - [x] In `core/autoload/signal_bus.gd` add `signal enemy_reached_player(damage: int)` (the exact signature already specified in game-architecture.md#SignalBus). Leave the existing three signals as they are.
- [x] Task 2: Player HurtBox with invulnerability gate (AC: #2, #5, #6, #7)
  - [x] Create `features/player_egg/player_hurt_box.gd` (`class_name PlayerHurtBox`, `extends Area2D`). Do not name it `HurtBox`: Epic 2 will need an enemy-side hurtbox class.
  - [x] `@export var stats: StatsResource`. Only `stats.cooldown` is read in this story.
  - [x] `_ready()`: `SignalBus.enemy_reached_player.connect(_on_enemy_reached_player)`.
  - [x] Track remaining invulnerability time in a float; decrement it in `_physics_process(delta)` (clamped at 0). Because it uses delta, it pauses correctly with the tree.
  - [x] `_on_enemy_reached_player(damage: int)`: if invulnerable, `return`. Otherwise set the remaining time to `stats.cooldown`, then `SignalBus.player_damaged.emit(damage)`. Guard `stats == null` (skip gating, still emit, and `push_warning`) so a misconfigured scene degrades loudly rather than crashing.
  - [x] In `player_egg.tscn` add `HurtBox` (`Area2D`, script attached) with `collision_layer = 8`, `collision_mask = 0`, `monitoring = false`, plus a `CollisionShape2D` child using a `CircleShape2D` radius 8. Assign `stats` to an embedded resource: `[sub_resource type="Resource" ...]` with `script = ExtResource(<stats_resource.gd>)`, `cooldown = 1.0`, and **`resource_local_to_scene = true`**. Update `load_steps` in the scene header.
  - [x] Do **not** edit `player.gd`.
- [x] Task 3: Enemy HitBox that reports sustained contact (AC: #3, #4)
  - [x] Create `features/enemies/enemy_hit_box.gd` (`class_name EnemyHitBox`, `extends Area2D`). Cache the parent as `EnemyBase` (`@onready var _enemy: EnemyBase = get_parent()`).
  - [x] `_physics_process`: if `_enemy.stats == null` return; if `get_overlapping_areas()` is non-empty, `SignalBus.enemy_reached_player.emit(roundi(_enemy.stats.damage))` once per frame (not once per overlapping area).
  - [x] Add a `HitBox` node (script attached, `collision_layer = 0`, `collision_mask = 8`, `monitorable = false`, `CircleShape2D` radius 14) to **both** `sperm_cell.tscn` and `enemy_base.tscn`, and update `load_steps` in each.
- [x] Task 4: Arrival distance (AC: #8)
  - [x] In `features/enemies/sperm_cell.gd` add `@export var arrival_distance: float = 10.0`. In `_get_move_direction()`, compute `var to_player: Vector2 = _player.global_position - global_position`. If `to_player.length() <= arrival_distance`, return `Vector2.ZERO`. Otherwise return `to_player.normalized()`.
  - [x] Why 10 and why no overshoot: at 150 px/s and 60 physics ticks a SpermCell moves 2.5 px per frame, so it stops within one step of the threshold and cannot cross the player's center and flip direction. Keep `arrival_distance` greater than that step and below 22.
  - [x] Do not change `enemy_base.gd`.
- [x] Task 5: Second test enemy in the arena (AC: #10)
  - [x] In `features/gameplay/arena.tscn` add a second `SpermCell` instance (same `ext_resource` `2_spermcell`, node name `SpermCell2`) at `position = Vector2(1180, 360)`. The player starts at (640, 360) and the first SpermCell is at (100, 360). This is a temporary test fixture like the first one; Story 2.1's wave spawner replaces both. Hand-added nodes may omit `unique_id`; Godot assigns them on the next editor save.
- [x] Task 6: Manual verification (AC: #2–#10)
  - [x] **Temporary** debug line, removed before finishing: in `PlayerHurtBox._ready()` add `SignalBus.player_damaged.connect(func(a: int) -> void: print("player_damaged ", a, " @ ", Time.get_ticks_msec()))`. There is no listener until Story 1.5, so this is the only way to see events.
  - [x] Run `arena.tscn` (F5 or F6). Stand still: both SpermCells arrive, and the console shows exactly one `player_damaged 10` at contact, then one about every 1000 ms (timestamps), never two within the same window even though two enemies overlap.
  - [x] Move away and back: the enemies resume charging, and contact damage resumes. Confirm the enemies do not vibrate or jitter while sitting on the player (AC #8), and that the player is not pushed or blocked by them.
  - [x] Confirm no console errors or warnings on load or during play.
  - [x] Remove the temporary print. Confirm with `git diff` that it is gone.
- [x] Task 7: Close the deferred item (AC: #8)
  - [x] In `_bmad-output/implementation-artifacts/deferred-work.md`, mark the "No arrival/stop distance" entry resolved by Story 1.4 (do not delete the ledger history). The "enemies stack into one blob" and "inherited scene" entries stay deferred (Story 2.1 and an editor task).

### Review Findings

- [x] [Review][Decision] **Resolved 2026-09-19: keep `player_damaged` as the request, rename the outgoing notification.** Story 1.5's health system listens to `player_damaged`, applies the damage, and emits a new `player_health_changed` for HUD and feedback; it must not re-emit `player_damaged`. No code change was needed in this story: the semantics are now documented on both signals in `core/autoload/signal_bus.gd`, and E1-S5's task list in `sprint-status.yaml` was corrected so 1.5 cannot be built into the recursion. Original finding: `player_damaged` now means two opposite things, and Story 1.5 as specified collides with it head-on. This story made `player_damaged` an *input* ("apply this damage"). But E1-S5's recorded task list in `sprint-status.yaml` says "Emit `player_damaged` signal" from `take_damage()`, and `game-architecture.md`'s canonical listener pattern treats it as an *output* notification (HUD, flash, HP bar). If 1.5 is built as written — a health component that connects to `player_damaged` to apply damage and also emits it from `take_damage()` — the first contact recurses until the stack overflows, or at best double-applies. Options: (a) rename the outgoing notification to `player_health_changed` and keep `player_damaged` as the request; (b) keep `player_damaged` as the notification and rename this story's emission to `player_damage_requested`; (c) strike the emit from E1-S5's task list so 1.5 only listens. Must be settled before 1.5 starts. [core/autoload/signal_bus.gd:8, features/player_egg/player_hurt_box.gd:24, sprint-status.yaml E1-S5]
- [x] [Review][Decision] **Resolved 2026-09-19: fixed now, max damage per window.** `PlayerHurtBox` accumulates every report with `maxi()` and resolves the hardest hit once on the next physics frame, so the outcome no longer depends on scene-tree order. Costs up to one frame (~16ms) of latency against a one-second window. Original finding: Damage amount is decided by scene-tree order, so the weakest enemy in a pile wins the invulnerability window. `enemy_reached_player(damage)` carries no sender, and the gate accepts the first emission of the window then discards the rest for a full second. Invisible today — both arena enemies are SpermCells at damage 10. It becomes live at the next enemy type: the GDD specifies Swarm Sperm 5, Fat Sperm 20, Fast Sperm 8, plus elites. A Swarm Sperm earlier in the tree than a Fat Sperm means the player takes 5, not 20 — so adding weak enemies to a crowd *reduces* incoming damage, inverting the GDD's "crowd is dangerous" intent. `arrival_distance` makes overlap the steady state rather than a transient, so the race runs every window. Options: (a) accumulate reports during the frame and resolve max damage once at frame end; (b) add the sender to the signal so the gate can choose; (c) accept first-wins as a balance choice and revisit in Epic 2. Flagged independently by two layers. [features/enemies/enemy_hit_box.gd:14, features/player_egg/player_hurt_box.gd:17-24]
- [x] [Review][Patch] `player_egg.tscn` declares `load_steps=6` but now holds 6 resources, so it must be 7 (Godot's convention is resources + 1; the other two scenes in this change count correctly). Benign at runtime — Godot uses it only for load-progress reporting — but it is exactly the hand-authored `.tscn` slip the Dev Notes warned about. Flagged by two layers. [features/player_egg/player_egg.tscn:1]
- [x] [Review][Patch] `get_overlapping_areas()` allocates a fresh `Array[Area2D]` every physics frame for every enemy, and only `.is_empty()` is read from it. `has_overlapping_areas()` answers the same question without allocating. At Epic 1's own bar of 50+ enemies that is roughly 3,000 wasted allocations per second even when nothing touches the player — so the story's "cheap when nothing overlaps" note is wrong about precisely the no-overlap case. Flagged by two layers. [features/enemies/enemy_hit_box.gd:13]
- [x] [Review][Patch] The `stats == null` branch does not degrade loudly, it degrades catastrophically: it warns but never sets the invulnerability window, so every report passes through. One overlapping enemy yields 60 `player_damaged(10)` per second — 600 damage/s against 100 HP, death in about 0.17s — plus 60 `push_warning` calls per second flooding the output pane. This is what Task 2 literally specified, so the fix is a deliberate deviation from the task text in service of its stated intent: fall back to a sane default cooldown and warn once. Flagged by all three layers. [features/player_egg/player_hurt_box.gd:19-24]
- [x] [Review][Patch] `@onready var _enemy: EnemyBase = get_parent()` is a typed assignment with no guard. If the HitBox ever sits under anything that is not an `EnemyBase` — a spawner wrapper node in Story 2.1, a boss on a different base, or a reparent in the editor — the assignment fails, `_enemy` stays null, and `_physics_process` dereferences `_enemy.stats` 60 times a second forever. `enemy_base.gd` already carries the defensive pattern from Story 1.3's review; this is the one new script that skips it. [features/enemies/enemy_hit_box.gd:8,11]
- [x] [Review][Patch] The story's File List omits `_bmad-output/implementation-artifacts/sprint-status.yaml` and the two generated `.gd.uid` files, so committing only the listed paths would drop them — and Project Structure Notes says to commit `.uid` files as Story 1.3 did. The comment added to `sprint-status.yaml` also reads "story file created (ready-for-dev)" above a block whose status is now `review`. [1-4-enemy-player-contact-damage.md File List, sprint-status.yaml]
- [x] [Review][Defer] Nothing gates contact damage on game-over state. `GameManager.is_game_over` exists and is written in `start_game()` but is read by nothing in the project. Once Story 1.5 lands death, enemies stay parked on the player (that is what `arrival_distance` does) and `player_damaged` keeps firing once a second forever, driving HP negative and potentially re-triggering death handling. [features/enemies/enemy_hit_box.gd, features/player_egg/player_hurt_box.gd, core/autoload/game_manager.gd:9] — deferred: `is_game_over` is never set true by anything yet, so a check added now would be speculative. Story 1.5 owns death and is the right place to wire it.
- [x] [Review][Defer] The arrival-distance stop lives on `SpermCell`, not `EnemyBase`, so every future enemy type that overrides `_get_move_direction()` re-inherits the jitter this story just fixed — and jitter now moves an enemy in and out of the 22px contact band, making it a gameplay bug rather than a cosmetic one. Separately, the "keep `arrival_distance` below 14 + 8" rule exists only as a doc comment on an `@export`, so any value at or above 22 produces an enemy that charges, parks just outside contact range, and deals zero damage silently. [features/enemies/sperm_cell.gd:6-8, features/enemies/enemy_base.gd:20-21] — deferred: Task 4 explicitly said not to change `enemy_base.gd`, and no enemy sets a value near 22 today. Hoist the stop behaviour (and clamp or derive the value from the hitbox radius) when Epic 2 adds the second enemy type.
- [x] [Review][Defer] Every overlapping enemy emits `enemy_reached_player` every physics frame, and all but the first are discarded by the gate — with a large pile-up that is roughly 50 dispatches per frame of which 49 hit the early return. [features/enemies/enemy_hit_box.gd:14] — deferred: the story's Testing Requirements already nominate Story 2.1 (wave spawner) as the place to switch to `area_entered`/`area_exited` tracking if the profiler shows real cost.
- [x] [Review][Defer] `roundi(stats.damage)` floors any damage below 0.5 to 0, and the gate consumes the full invulnerability window before looking at the value — so a 0-damage enemy would act as a shield, absorbing each window and blocking real hits. [features/enemies/enemy_hit_box.gd:14] — deferred: no enemy has damage below 0.5, and this becomes reachable only if difficulty scaling ever multiplies damage downward.

## Dev Notes

### Design decisions (settled by the user before story creation, do not re-litigate)

- Layer 4 = `player_hurtbox` (Player's HurtBox, `monitoring = false`); layer 5 = `enemy_hurtbox`, reserved and unused. The Enemy HitBox has `monitoring = true` and masks layer 4.
- Invulnerability is **player-side**, using `StatsResource.cooldown`. No per-hitbox timers.
- No `HealthComponent` (Story 1.5). The only output is a SignalBus emission.
- The arrival-distance jitter fix is in scope now.

### Design choices made by story creation (flagged for user review)

1. **Two-hop signal path instead of a direct emit from the enemy.** The enemy emits `enemy_reached_player(damage)`; the player-side `PlayerHurtBox` gates it and emits `player_damaged(amount)`. Reason: the gate must live on the player side (decision 2), so the enemy cannot emit `player_damaged` directly without bypassing it, and calling a method on the player's HurtBox from enemy code would be a direct cross-feature reference (AGENTS.md Communication Rule). `enemy_reached_player(damage: int)` is already specified in game-architecture.md#SignalBus, so this uses the documented design, not a new signal. The Story 1.5 listener still subscribes to `player_damaged`, exactly as decision 3 intends.
2. **Player stats live on the HurtBox node.** `player.gd` has no `StatsResource` (an existing, deferred deviation) and this story does not touch it. The Player gets no new stats export here. The embedded resource keeps the default `health = 100.0` (matches gdd.md#Health System) and `speed = 200.0`; **both are inert and duplicated-in-spirit** with `player.gd`'s `speed` until Story 1.5 or a cleanup story hoists player stats onto `Player`. Do not read `health` or `speed` from it.
3. **`cooldown = 1.0`** (the `StatsResource` default) is the starting invulnerability window. At 10 damage against 100 HP that is 10 s of unbroken contact to die. It is a placeholder tuned by feel, not a GDD value. Change it in the `.tscn` resource only, not in code.

### Critical technical gotchas

- **`area_entered` fires once.** If the HitBox only reacted to `area_entered`, an enemy that keeps overlapping the player after the invulnerability window ends would never deal damage again. That is why AC #4 requires polling `get_overlapping_areas()` each physics frame in the HitBox, and why the player-side gate (not the enemy) enforces spacing. The player HurtBox has `monitoring = false` by design, so it cannot query overlaps itself.
- **Area2D defaults are wrong for both new nodes.** A fresh `Area2D` has `collision_layer = 1`, `collision_mask = 1`, `monitoring = true`, `monitorable = true`. You must set layer/mask/monitoring/monitorable explicitly as listed, or the areas will detect the arena walls or each other.
- **Bitmask values.** Layer N is bit value `2^(N-1)`: layer 4 → `8`, layer 5 → `16`. (1.3 made the same point: layer 3 is `4`.)
- **Area detection rule.** An area detects another when its `collision_mask` includes the other's `collision_layer` **and** the other has `monitorable = true`. Here: HitBox mask 8 vs HurtBox layer 8, HurtBox `monitorable = true`.
- **Type mismatch.** `SignalBus.player_damaged(amount: int)` and `enemy_reached_player(damage: int)` take `int`, but `StatsResource.damage` is `float`. Use `roundi(...)`; do not pass the float.
- **Scripted sub-resource syntax in `.tscn`.** (This was Story 1.3's real defect.) Use `[sub_resource type="Resource" id="..."]` plus `script = ExtResource("<id>")` pointing at `res://core/data/stats_resource.gd`. Never `type="StatsResource"`. Also add `resource_local_to_scene = true` (a Story 1.3 review finding: otherwise every scene instance shares one resource).
- **Scene `load_steps` count.** Each added `ext_resource`/`sub_resource` raises `load_steps`. A wrong value only warns, but keep it right.
- **`arena.tscn` was re-saved by the Godot editor** and now has `uid="uid://ocb2cl8rtt1l"` and per-node `unique_id=` attributes. Keep those intact when adding `SpermCell2`; do not rewrite the file wholesale.

### Existing code this story touches (read in full)

| File | State today | This story changes | Must preserve |
|---|---|---|---|
| `project.godot` | `[layer_names]` has layers 1–3; `run/main_scene` is `uid://ocb2cl8rtt1l` (arena) | append layers 4–5 | input map, main scene, autoloads |
| `core/autoload/signal_bus.gd` | 3 signals: `enemy_died(xp_amount: int)`, `player_damaged(amount: int)`, `wave_completed()` | add `enemy_reached_player(damage: int)` | existing signatures (`GameManager` connects to two of them) |
| `features/player_egg/player_egg.tscn` | `Player` CharacterBody2D (`motion_mode=1`, layer 2, mask 1), Sprite2D, CollisionShape2D circle r16 | add `HurtBox` subtree | body layer/mask, script, existing shape |
| `features/player_egg/player.gd` | `speed` export, `_ready()` adds `"player"` group, `_physics_process` moves | **nothing** | everything |
| `features/enemies/enemy_base.gd` | exports `stats: EnemyStats`; `_physics_process` guards null `stats`, lazily re-acquires `_player` via `is_instance_valid()` | **nothing** | the null and validity guards (Story 1.3 review patches) |
| `features/enemies/enemy_base.tscn` / `sperm_cell.tscn` | body layer 4 (`enemy`), mask 1, circle r12; SpermCell has a `resource_local_to_scene` `EnemyStats` (health 10, speed 150, damage 10) | add `HitBox` subtree to each | layer/mask, stats values |
| `features/enemies/sperm_cell.gd` | `_get_move_direction()` returns normalized vector to `_player` | arrival distance | override signature, `_player` use |
| `features/gameplay/arena.tscn` | Player (640,360), SpermCell (100,360), walled `ArenaBoundary` | add `SpermCell2` | walls, main-scene uid |

### Architecture compliance

- `features/*` scripts communicate through `SignalBus` only. `enemy_hit_box.gd` (enemies) and `player_hurt_box.gd` (player_egg) reference each other **only** through the bus and the physics layers, never by node path or class. `EnemyHitBox` reads its own parent (`EnemyBase`), which is within the same feature.
- Node structure follows game-architecture.md: `Player` gets `HurtBox` (Area2D); `Enemy` gets `HitBox` (Area2D). The architecture's Player `HitBox`, Enemy `HurtBox`, `HealthComponent`, and `NavigationAgent2D` are **not** built here.
- Typed GDScript throughout, with a `class_name` for each new script (Definition of Done, epics-and-stories.md).

### Testing requirements

- No automated test framework exists yet; verification is manual (Task 6), as in Stories 1.1–1.3. Per-frame checks are not automatable without GUT. Do not claim verification happened without a human-reported result if no Godot editor is available in your environment (same constraint as 1.1–1.3).
- Performance (Epic 1 AC "60fps with 50+ enemies"): per-frame `get_overlapping_areas()` on each enemy is cheap when nothing overlaps. If the profiler later shows cost with many simultaneous overlaps, switch to `area_entered`/`area_exited` tracking; that is an optimization for Story 2.1, not now.

### Previous story intelligence (1.3)

- Establishes: `EnemyBase`/`SpermCell`, the `"player"` group lookup, `EnemyStats`, collision layers 1–3, the `resource_local_to_scene` requirement, and the scripted-sub-resource `.tscn` syntax. All are reused as-is.
- Review outcomes to honor: accepted that SpermCell (150) is slower than Player (200); contact therefore happens when the player stops, is cornered, or is intercepted by a second enemy. Test by standing still.
- **Same drift risk still open:** `sperm_cell.tscn` duplicates `enemy_base.tscn`'s node structure instead of inheriting, so HitBox must be added to **both** by hand (Task 3). Don't "fix" this here; it stays in the deferred ledger.
- Environment constraint from 1.1–1.3: no Godot CLI in the agent environment, so scene-file syntax is verified by static review plus a human run. The hand-authored `.tscn` bug in 1.3 was only found that way.

### Git intelligence

- Recent history: `b19ac42` (Story 1.3: enemies, `EnemyStats`, review patches) and `5da84da` (player movement and arena). Conventional-commit style with scope, e.g. `feat(enemies): ...`. This story's commit should be `feat(combat): add enemy contact damage with player invulnerability window` or similar (use `feat(gameplay)`/`feat(player)` if preferred), one atomic commit.
- Godot version in `project.godot` features is `4.7` (AGENTS.md says 4.2+); no new-API concerns for `Area2D`, `roundi`, or `get_overlapping_areas()`.

### Project Structure Notes

- New files: `features/player_egg/player_hurt_box.gd`, `features/enemies/enemy_hit_box.gd` (Godot will also generate `.gd.uid` files; commit them, as done in 1.3).
- Modified: `project.godot`, `core/autoload/signal_bus.gd`, `player_egg.tscn`, `enemy_base.tscn`, `sperm_cell.tscn`, `sperm_cell.gd`, `arena.tscn`, `deferred-work.md`.
- No conflict with the architecture's file layout. `HurtBox`/`HitBox` are scene node names; the scripts use prefixed class names to avoid a future global `class_name` clash.

### Project Context Rules

- No `project-context.md` exists (removed in commit 6167ffa); the equivalent rules come from `AGENTS.md`: SignalBus-only cross-feature communication, GDScript 4.x typed code with `class_name`, extend `StatsResource` rather than duplicating stat fields, Conventional Commits, feature branches.

### Latest tech information

- No external research needed: only core Godot 4 `Area2D`, collision layers/masks, and signals are used, all stable across the 4.x line.

### Out of scope (do not build)

HP tracking or `HealthComponent` and `die()` (1.5); screen-flash/HP-bar shake and damage sounds (UX feedback table in EXPERIENCE.md, Epic 5); player-hit visual flicker during invulnerability; enemy-vs-enemy separation (2.1); knockback; enemy `HurtBox` (layer 5 is only named).

### References

- [Source: _bmad-output/planning-artifacts/epics/epics-and-stories.md#Epic 1 — E1-S4, E1-S5]
- [Source: _bmad-output/implementation-artifacts/sprint-status.yaml — E1-S4 tasks]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#SignalBus, #Player, #Enemies node structures, #StatsResource]
- [Source: _bmad-output/planning-artifacts/gdd.md#Movement (hurtbox is a small circle), #Health System, #Enemy Types (Sperm Cell damage 10)]
- [Source: _bmad-output/planning-artifacts/ux-design/EXPERIENCE.md#Feedback — "Take damage: screen flash red, HP bar shake" (deferred to Epic 5)]
- [Source: _bmad-output/implementation-artifacts/1-3-spermcell-charge-enemy.md — review findings, conventions]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md — "No arrival/stop distance" (this story), enemy stacking (2.1), inherited scene (editor)]
- [Source: AGENTS.md#Communication Rule, #Code Conventions]

## Change Log

- 2026-09-19: Story created (ready-for-dev) from user-settled design decisions for layers, player-side invulnerability, SignalBus-only output, and folding in the arrival-distance jitter fix.
- 2026-09-19: Code review (3 parallel layers). 2 decisions resolved, 5 patches applied, 4 items deferred, 5 dismissed. Patches: `load_steps` 6 to 7 in `player_egg.tscn`; `has_overlapping_areas()` replaces a per-frame array allocation; the null-`stats` branch now falls back to a 1.0s window and warns once instead of emitting unthrottled; `EnemyHitBox` guards a non-`EnemyBase` parent; File List and `sprint-status.yaml` corrected. Decisions: `player_damaged` keeps request semantics (1.5 emits `player_health_changed` instead, and E1-S5's task list was corrected), and the gate now takes max damage per window rather than first-reporter-wins.
- **Re-verification advised:** the patches changed the damage path after Administrator's manual run, so the contact-damage cadence has not been re-tested in the editor.
- 2026-09-19: Implemented Tasks 0-5 and 7. Administrator ran `arena.tscn` and confirmed: one `player_damaged` per ~1 s window even with both enemies touching, damage resumes after moving away and back, no vibration or pushing, no console errors. Temporary debug print removed. Task 6 done; moved to review.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5 (claude-sonnet-5)

### Debug Log References

### Completion Notes List

- Tasks 0-5 and 7 implemented and statically reviewed (`.tscn` syntax follows the scripted-resource pattern from Story 1.3; `load_steps` recounted; layer/mask bitmasks 8 and 0/8 as specified).
- Task 6 verified by Administrator in the Godot editor (see Change Log); the temporary `print` in `player_hurt_box.gd` was removed afterwards. All 10 ACs satisfied.

### File List

- `project.godot` (modified: layers 4-5)
- `core/autoload/signal_bus.gd` (modified: `enemy_reached_player`)
- `features/player_egg/player_hurt_box.gd` (new)
- `features/player_egg/player_egg.tscn` (modified: HurtBox subtree, local-to-scene stats resource)
- `features/enemies/enemy_hit_box.gd` (new)
- `features/enemies/enemy_base.tscn` (modified: HitBox subtree)
- `features/enemies/sperm_cell.tscn` (modified: HitBox subtree)
- `features/enemies/sperm_cell.gd` (modified: `arrival_distance`)
- `features/gameplay/arena.tscn` (modified: `SpermCell2`)
- `_bmad-output/implementation-artifacts/deferred-work.md` (modified: arrival-distance item resolved; code-review deferrals appended)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified: E1-S4 status; E1-S5 task list corrected per the signal-semantics decision)
- `features/enemies/enemy_hit_box.gd.uid` (new, editor-generated - commit it)
- `features/player_egg/player_hurt_box.gd.uid` (new, editor-generated - commit it)
