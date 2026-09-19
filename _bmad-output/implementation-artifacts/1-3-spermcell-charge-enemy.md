---
baseline_commit: 5da84da7f789e108abc87ec9c6c7b146c0a0bf4e
---

# Story 1.3: Basic enemy (SpermCell) that charges at player

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a player,
I want a basic enemy that charges straight at me,
so that there is something to dodge and eventually fight.

## Acceptance Criteria

1. A `SpermCell` enemy exists with stats HP: 10, Speed: 150 (damage: 10, unused until Story 1.4). [Source: gdd.md#Enemies — "Sperm Cell | 10 | 150 | 10 | Straight-line charge at player"]
2. The enemy is a `CharacterBody2D` that moves in a straight line toward the player's current position every physics frame — no pathfinding, no steering curves. [Source: gdd.md#Enemies — "Straight-line charge at player"; game-architecture.md — Enemy is CharacterBody2D like Player]
3. The enemy finds the player without a direct cross-feature node reference — via a Godot group lookup, not a hardcoded node path, and not by (ab)using `SignalBus` for continuous per-frame position polling (`SignalBus` is for events, not state queries). [Source: AGENTS.md#Communication Rule — "Never create direct node references between features"]
4. The enemy respects the arena boundary (collides with the `world` collision layer established in Story 1.2) but does NOT yet physically block or damage the player — enemy-player contact/damage is Story 1.4's job, not this one. Visually overlapping the player harmlessly is expected, not a bug. [Source: epics-and-stories.md#Epic 1 — E1-S4 "Enemy-player collision (damage on contact)" is a separate, later story]
5. A `SpermCell` instance is placed in `features/gameplay/arena.tscn` far enough from the player's start position that a tester can watch it visibly charge across the arena and reach the player. [Source: sprint-status.yaml task "Test enemy reaches player"]
6. The enemy scene/script instantiates and runs without crashing (no missing-reference errors) inside `arena.tscn`.

## Tasks / Subtasks

- [x] Task 0: Extend the collision layer convention with an `enemy` layer (AC: #4) — **this is the future story Story 1.2's Dev Notes explicitly reserved layers 3+ for**
  - [x] In `project.godot`'s existing `[layer_names]` section, add `2d_physics/layer_3="enemy"`
  - [x] Do not rename or renumber layers 1 (`world`) or 2 (`player`) — only append layer 3
- [x] Task 1: Register the Player in a lookup group so enemies can find it without a direct reference (AC: #3)
  - [x] In `features/player_egg/player.gd`'s `_ready()`, call `add_to_group("player")` — this is a small, additive change to an existing file; nothing else in `player.gd` changes
  - [x] `player.gd` currently has no `_ready()` function — add one containing only this line
- [x] Task 2: Create the `EnemyStats` resource (AC: #1) — **the architecture doc names this exact file/class but it doesn't exist yet**
  - [x] Create `core/data/enemy_stats.gd`: `class_name EnemyStats extends StatsResource` with `@export var enemy_name: String = ""`, `@export var xp_reward: int = 10`, `@export var coin_reward: int = 0`, `@export var spawn_weight: float = 1.0`, `@export var is_elite: bool = false`, `@export var is_boss: bool = false` — matches game-architecture.md#EnemyStats exactly
  - [x] `xp_reward`/`coin_reward`/`spawn_weight` are inert for this story (no XP/coin/wave-spawner systems exist yet — those are Epic 3/6/2) — set them but don't wire them to anything; do not build XP or spawning logic now
  - [x] Do NOT create a `SpermCellStats` subclass — SpermCell needs no fields beyond what `StatsResource` (health, speed, damage, cooldown) and `EnemyStats` already provide. A configured `EnemyStats` resource instance is sufficient; adding an empty subclass would be premature abstraction
- [x] Task 3: Create the Enemy base scene and script (AC: #2, #6)
  - [x] Create `features/enemies/enemy_base.gd`: `class_name EnemyBase extends CharacterBody2D`
  - [x] `@export var stats: EnemyStats`
  - [x] Cache the player reference once in `_ready()`: `var _player: Node2D = get_tree().get_first_node_in_group("player")`
  - [x] In `_physics_process(_delta)`: if `_player` is null, `return` (defensive guard — nothing to charge at); otherwise call an overridable `_get_move_direction() -> Vector2` method, set `velocity = _get_move_direction() * stats.speed`, call `move_and_slide()`
  - [x] `_get_move_direction()` returns `Vector2.ZERO` in the base class (no movement) — subclasses override it with their specific behavior
  - [x] Create `features/enemies/enemy_base.tscn`: `CharacterBody2D` (named `EnemyBase`) root with `motion_mode = 1` (Floating — same top-down rationale as Player, see Story 1.1's code review), `collision_layer = 4` (`enemy`), `collision_mask = 1` (`world` — respects arena walls), a `CollisionShape2D` (`CircleShape2D`, radius 12), a `Sprite2D` placeholder (no texture — same "no art pipeline yet" situation as Player), and the `enemy_base.gd` script attached
  - [x] Do NOT add `HurtBox`/`HitBox`/`HealthComponent`/`NavigationAgent2D` yet — HurtBox/HitBox belong to Story 1.4, HealthComponent's take-damage/die logic belongs to Story 1.9, and `NavigationAgent2D` (pathfinding) is unnecessary for a straight-line charger with no obstacles in the flat MVP arena
- [x] Task 4: Implement SpermCell (AC: #1, #2)
  - [x] Create `features/enemies/sperm_cell.gd`: `class_name SpermCell extends EnemyBase`, override `_get_move_direction() -> Vector2` to return `(_player.global_position - global_position).normalized()`
  - [x] Create `features/enemies/sperm_cell.tscn` — a standalone scene duplicating `enemy_base.tscn`'s node structure (root `CharacterBody2D` named `SpermCell`, `motion_mode = 1`, `collision_layer = 4`, `collision_mask = 1`, `CollisionShape2D`, `Sprite2D`), but with `sperm_cell.gd` attached instead of `enemy_base.gd`, and an `EnemyStats` sub-resource configured with `health = 10.0`, `speed = 150.0`, `damage = 10.0`, `enemy_name = "Sperm Cell"` — **note:** this duplicates node structure rather than using Godot's "Inherited Scene" feature, a deliberate simplification because inherited-scene `.tscn` files are harder to hand-author correctly outside the editor; a human can later convert this to a true inherited scene via the editor's "New Inherited Scene" if desired — flag this to the user, don't silently treat it as the final architecture
- [x] Task 5: Place a SpermCell instance in the arena for testing (AC: #5, #6)
  - [x] In `features/gameplay/arena.tscn`, instance `features/enemies/sperm_cell.tscn` as a child of `Arena`, positioned far from the player's `(640, 360)` start (`position = Vector2(100, 360)` — near the interior edge, giving it a long straight run across the arena to reach the player)
- [x] Task 6: Manual verification (AC: #1–#6)
  - [x] Open `features/gameplay/arena.tscn` in the Godot editor and use "Run Current Scene" (F6) — confirmed by Administrator: loads clean, no errors
  - [x] Confirm the SpermCell moves in a straight line toward wherever the player currently is (move the player with WASD/arrows and confirm the enemy's direction updates to track it) — confirmed: re-aims toward current player position as they move
  - [x] Confirm the enemy is blocked by the arena boundary walls (it should not leave the arena) but passes through/overlaps the player harmlessly (no damage, no push-back — expected, per AC #4) — confirmed: blocked by walls, passes through player harmlessly
  - [x] Confirm no console errors on scene load or during movement — confirmed: no console errors

### Review Findings

- [x] [Review][Decision] **Resolved 2026-09-19: accept as-is.** SpermCell is a deliberately weak baseline; pressure comes from swarm density, faster variants (FastSperm), and multi-directional spawning later, not from any single enemy outrunning the player. SpermCell's `speed = 150.0` is slower than the Player's `speed = 200.0`, so a pure straight-line chaser can never make contact against a player who simply holds one direction. Both values come from the GDD (Enemies table: Sperm Cell speed 150; Movement: player 200 base), so this is a design/balance question rather than a code defect — but it means Epic 1's combat loop (Stories 1.4/1.5 contact damage) may be untestable and trivially unloseable as specified. Options: accept as-is (other enemy types and swarm density provide the pressure), raise SpermCell's speed above the player's, or give it a wind-up/burst charge so the slower base speed is intentional. [gdd.md#Enemies, features/enemies/sperm_cell.tscn]
- [x] [Review][Patch] `enemy_base.tscn` ships with no `stats` assigned, but `enemy_base.gd:_physics_process` dereferences `stats.speed` after guarding only `_player` — instancing the base scene directly throws "Invalid access to property 'speed' on a base object of type 'Nil'" every physics frame. Flagged independently by all three review layers; the Acceptance Auditor ties it to a violation of AC #6 ("instantiates and runs without crashing"). Not observable today because only `sperm_cell.tscn` is instanced, but `enemy_base.tscn` is a shipped Task 3 deliverable. [features/enemies/enemy_base.gd:13, features/enemies/enemy_base.tscn]
- [x] [Review][Patch] The `EnemyStats` sub-resource embedded in `sperm_cell.tscn` lacks `resource_local_to_scene = true`, so every SpermCell instance shares one resource object. Latent today (nothing mutates stats), but Story 1.8 (projectile damage) and Story 1.9 (enemy death at HP 0) will mutate `health` — at which point damaging one SpermCell drains every SpermCell's health and they all die together. Flagged independently by two layers. Cheap to fix now, very hard to diagnose later. [features/enemies/sperm_cell.tscn]
- [x] [Review][Patch] `_player` is cached once in `_ready()` and guarded with `== null`, which does not detect a freed node, and is never re-acquired. Three related gaps collapse into one fix: (a) Story 1.5 adds player death — a freed `_player` would crash on `.global_position` rather than hitting the guard; (b) an enemy whose `_ready()` runs before the Player joins the group stays permanently inert (verified not broken today only because `Player` precedes `SpermCell` in `arena.tscn` tree order — an unguarded ordering dependency); (c) a subclass overriding `_ready()` without `super._ready()` would leave `_player` null forever. A lazy re-acquire using `is_instance_valid()` closes all three. [features/enemies/enemy_base.gd:8-13]
- [x] [Review][Defer] `sperm_cell.tscn` duplicates `enemy_base.tscn`'s node structure (root type, `motion_mode`, collision layer/mask, shape radius, child nodes) instead of being a Godot Inherited Scene, leaving `enemy_base.tscn` as an unused template that will silently drift as shared changes (hurtbox, layers, shape) are added per-enemy in Epic 2. [features/enemies/sperm_cell.tscn, features/enemies/enemy_base.tscn] — deferred, deliberate: hand-authoring inherited-scene `.tscn` format outside the editor is error-prone, and this story had no editor access. **Task 4 required this tradeoff be flagged to the user rather than treated as final architecture; that flag was missed at hand-off and is recorded here and in `deferred-work.md` to correct it.** A human can convert it via the editor's "New Inherited Scene", or the base scene can be dropped in favour of base-script-only inheritance.
- [x] [Review][Defer] Enemies neither collide with nor separate from each other (`collision_mask = 1` covers `world` only), so multiple spawns will stack into one overlapping blob. [features/enemies/enemy_base.tscn, features/enemies/sperm_cell.tscn] — deferred, not observable with a single hand-placed enemy; becomes real in Story 2.1 (wave spawner), which is the right place to decide between mask-based separation and a steering/separation behaviour.
- [x] [Review][Defer] No arrival/stop distance: `(_player.global_position - global_position).normalized()` returns `Vector2.ZERO` at exact overlap and can oscillate direction under float noise near zero, so an enemy that reaches the player jitters on top of them. [features/enemies/sperm_cell.gd:5] — deferred, cosmetic today (enemies pass through the player harmlessly by design per AC #4); tune once Story 1.4 adds contact damage and there is real behaviour to tune against.

## Dev Notes

### Critical Gaps Not Covered by Sprint Task List (read before starting)

- **This story resolves the collision-layer reservation Story 1.2 explicitly left open.** Story 1.2's Dev Notes said: "Leave layers 3+ unnamed/reserved for future stories (enemies, projectiles) — do not invent names for systems that don't exist yet." This is that future story — Task 0 adds layer 3 = `enemy`. Don't touch layers 1/2.
- **No mechanism exists yet for an enemy to find the player.** Nothing in the codebase currently looks up the Player node from another feature. `AGENTS.md`'s Communication Rule bans direct cross-feature node references, and `SignalBus` (a pure event bus with 3 signals: `enemy_died`, `player_damaged`, `wave_completed`) is the wrong tool for continuously reading the player's position every physics frame. Task 1 + Task 3 establish the pattern: Player self-registers into a `"player"` Godot group; enemies do a one-time `get_tree().get_first_node_in_group("player")` lookup and cache it. This is the first enemy story, so this pattern doesn't exist yet — you're establishing it, and every future enemy type (Story 2.6's SwarmSperm/FatSperm, etc.) will reuse it via `EnemyBase`.
- **`core/data/enemy_stats.gd` doesn't exist yet**, even though game-architecture.md's Data Resources section names it explicitly with an exact field list. This story creates it because it's the first story that needs enemy stats. Follow the documented fields exactly — don't invent extra ones.
- **`AGENTS.md` says "Extend `StatsResource` for new entity types; do not duplicate stat fields."** Story 1.1's `player.gd` did NOT follow this (it used a bare `@export var speed` directly on the node instead of a `StatsResource`-derived resource) — that's an existing deviation already merged, not a pattern to copy. This story follows the documented convention correctly via `EnemyStats extends StatsResource`. Do not "fix" Player's approach as part of this story — that's out of scope; just don't repeat the shortcut here.
- **CharacterBody2D `collision_layer`/`collision_mask` (physics blocking) is a completely separate system from the future `Area2D`-based `HitBox`/`HurtBox` (contact damage) that Story 1.4 will add.** This story only touches the former. Do not add `Area2D` nodes or damage logic — that's Story 1.4's scope, and doing it now would mean redoing it once Story 1.4's actual signal-based damage design is written.
- **No wave spawner exists yet** (that's Story 2.1, a different epic). Task 5's single hand-placed `SpermCell` in `arena.tscn` is a temporary manual test fixture, not the real spawning system — don't build spawning logic now.

### Relevant Architecture Patterns and Constraints

- Enemy Types (Inheritance), from game-architecture.md#Enemies: `EnemyBase (enemy_base.gd)` → `SpermCell (sperm_cell.gd)` - Basic charge, `SwarmSperm`, `FatSperm`, `FastSperm`, `EliteEnemy` (the latter four are NOT part of this story — only `EnemyBase` and `SpermCell`). [Source: game-architecture.md#Enemy Types (Inheritance)]
- `EnemyStats` field list (exact, from game-architecture.md#EnemyStats): `enemy_name: String`, `xp_reward: int = 10`, `coin_reward: int = 0`, `spawn_weight: float = 1.0`, `is_elite: bool = false`, `is_boss: bool = false`, extending `StatsResource` (`health: float = 100.0`, `speed: float = 200.0`, `damage: float = 10.0`, `cooldown: float = 1.0` — override `health`/`speed`/`damage` per SpermCell's GDD stats, `cooldown` is unused for a simple charger and can stay at its default).
- File structure target (from game-architecture.md#File Structure): `features/enemies/enemy_base.tscn`, `enemy_base.gd`, `sperm_cell.gd` — matches this story's Task 3/4 paths exactly.
- Communication rule: feature scripts go through `SignalBus`, no direct cross-feature node references — addressed via the group-lookup pattern (Dev Notes above), which is a Godot-native decoupling mechanism, not a direct reference. [Source: AGENTS.md#Communication Rule]
- Established convention from Stories 1.1/1.2: `CharacterBody2D` + `motion_mode = 1` (Floating) + `move_and_slide()` for all moving bodies in this top-down game — applied to the enemy for the same reasons as Player (avoid floor/ceiling/slide semantics meant for platformers).

### Project Structure Notes

- New files: `core/data/enemy_stats.gd`, `features/enemies/enemy_base.gd`, `features/enemies/enemy_base.tscn`, `features/enemies/sperm_cell.gd`, `features/enemies/sperm_cell.tscn`.
- Modified files (UPDATE, both read in full during story creation): `project.godot` (append `layer_3="enemy"` to the existing `[layer_names]` section — do not touch `[input]` or the layer_1/layer_2 lines from prior stories), `features/player_egg/player.gd` (add a `_ready()` with `add_to_group("player")` — the file currently has no `_ready()` at all, just `_physics_process`), `features/gameplay/arena.tscn` (add one child node instancing `sperm_cell.tscn`).
- `features/enemies/.gitkeep` currently occupies this directory — it can remain.

### Testing Requirements

- No automated test framework is set up yet (same as Stories 1.1/1.2). Verification is manual, per Task 6.
- Per epics-and-stories.md#Definition of Done: code must compile and run without errors, no performance regression, follow project conventions (typed variables, class names).

### Previous Story Intelligence (from 1-2-arena-boundary-collision.md)

- **Environment constraint carries over:** no Godot editor/CLI available in this execution environment. Static code/scene-file review can verify syntax, but running the scene (Task 6) requires a human at the Godot editor, same as Stories 1.1 and 1.2. Do not claim manual verification happened without an actual human-reported result.
- **Collision layer convention established:** `world = 1`, `player = 2` (this story adds `enemy = 4` — note layer 3's bitmask VALUE is 4, not 3; Godot's `collision_layer`/`collision_mask` are bitmasks where layer N corresponds to bit value `2^(N-1)`, matching how `player = layer 2 → collision_layer = 2` and `world = layer 1 → collision_layer = 1` were already set in Stories 1.1/1.2).
- **`arena.tscn` is the shared test harness** for Sprint 1 stories (Player instance at `(640,360)`, `ArenaBoundary` StaticBody2D with 4 walls framing a 1280×720-ish interior). This story adds to it rather than creating a competing scene.
- **`motion_mode = 1` (Floating) is the established convention** for every `CharacterBody2D` in this project so far (applied to Player in Story 1.1's code review) — apply it directly to the enemy from the start instead of waiting for a review to catch it.

### References

- [Source: _bmad-output/planning-artifacts/gdd.md#Enemies]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Enemies (features/enemies/)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Enemy Types (Inheritance)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#EnemyStats]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#File Structure]
- [Source: _bmad-output/planning-artifacts/epics/epics-and-stories.md#Epic 1: Core Foundation]
- [Source: _bmad-output/implementation-artifacts/1-1-player-movement.md, 1-2-arena-boundary-collision.md — Dev Agent Record, established conventions]
- [Source: AGENTS.md#Communication Rule, #Code Conventions]
- [Source: project.godot, features/player_egg/player.gd, features/player_egg/player_egg.tscn, features/gameplay/arena.tscn, core/data/stats_resource.gd]

## Change Log

- 2026-09-18: Implemented enemy collision layer, player group registration, EnemyStats resource, EnemyBase/SpermCell scripts and scenes, and placed a SpermCell in arena.tscn (Tasks 0–5). Task 6 (manual verification) left open — no Godot editor/CLI available in this environment.
- 2026-09-18: Fixed a real defect in `sperm_cell.tscn` reported by Administrator during manual testing (`Cannot get class 'EnemyStats'`, sub-resource creation failure, cascading `arena.tscn` resource error). Root cause: `[sub_resource type="EnemyStats" ...]` is invalid `.tscn` syntax for a custom scripted Resource — corrected to `type="Resource"` + `script = ExtResource(...)`.
- 2026-09-18: Administrator retested and confirmed the fix in the Godot editor: loads clean, SpermCell re-aims toward the player's current position as they move, blocked by walls, passes through the player harmlessly, no console errors. Task 6 marked complete; story moved to review.

- 2026-09-19: Code review follow-up. Speed decision resolved (accept SpermCell 150 < Player 200 as-is). Applied 3 patches: `enemy_base.gd` now guards `stats == null` and lazily re-acquires `_player` via `is_instance_valid()` (the `_ready()` cache was removed); `sperm_cell.tscn`'s `EnemyStats` sub-resource is now `resource_local_to_scene = true`.
- 2026-09-19: Administrator re-ran `arena.tscn` after the patches and confirmed: still re-aims toward the player, blocked by walls, passes through the player, no console errors. Story marked done.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5 (claude-sonnet-5)

### Debug Log References

None — no automated test/build tooling (no Godot CLI, no GUT test framework) is available in this execution environment.

### Completion Notes List

- Implemented Tasks 0–5. Verified by static review only:
  - `project.godot`: appended `2d_physics/layer_3="enemy"` to the existing `[layer_names]` section (layers 1/2 untouched).
  - `features/player_egg/player.gd`: added `_ready()` calling `add_to_group("player")` — file had no `_ready()` before this.
  - `core/data/enemy_stats.gd` (new): `EnemyStats extends StatsResource` with the exact field list from game-architecture.md.
  - `features/enemies/enemy_base.gd` (new): `EnemyBase extends CharacterBody2D`, caches `_player` via group lookup in `_ready()`, null-guards it in `_physics_process()`, delegates direction to overridable `_get_move_direction()` (returns `Vector2.ZERO` in the base).
  - `features/enemies/enemy_base.tscn` (new): `motion_mode=1`, `collision_layer=4`, `collision_mask=1`, `CircleShape2D` radius 12, textureless `Sprite2D` placeholder, no `HurtBox`/`HitBox`/`HealthComponent`/`NavigationAgent2D` per scope.
  - `features/enemies/sperm_cell.gd` (new): `SpermCell extends EnemyBase`, overrides `_get_move_direction()` to return the normalized vector toward `_player.global_position`.
  - `features/enemies/sperm_cell.tscn` (new): duplicates `enemy_base.tscn`'s node structure with `sperm_cell.gd` attached and an `EnemyStats` sub-resource (`health=10.0`, `speed=150.0`, `damage=10.0`, `enemy_name="Sperm Cell"`) — matches GDD's Sperm Cell row exactly.
  - `features/gameplay/arena.tscn`: added a second `ext_resource` and instanced `sperm_cell.tscn` as a child of `Arena` at `(100, 360)`.
  - Reviewed all `.tscn`/`.gd` syntax against Godot 4 format-3 conventions and the patterns established in Stories 1.1/1.2 (motion_mode, collision layer bitmask values, ext/sub resource ID references).
- **Task 6 (manual verification) is NOT complete and NOT checked off.** Same environment constraint as Stories 1.1/1.2: no Godot editor or CLI available here, so I cannot open `arena.tscn`, run it, and watch the SpermCell charge the player — that requires a human at the Godot editor.
- **Correction (post hand-off):** the initial `sperm_cell.tscn` had a real defect, not a caching issue as I first assumed. `[sub_resource type="EnemyStats" ...]` is invalid — Godot's raw `.tscn` resource-text-format only accepts native ClassDB engine classes for a `[sub_resource]`/`[resource]` block's `type=` attribute; it does not resolve GDScript `class_name` aliases at that parsing layer (that's a separate, editor/scripting-level lookup). The correct format for a custom scripted `Resource` subclass is `type="Resource"` plus an explicit `script = ExtResource(...)` property pointing at the `.gd` file. Fixed in `sperm_cell.tscn`: added a second `ext_resource` for `core/data/enemy_stats.gd`, changed the sub-resource's `type` to `"Resource"`, and added `script = ExtResource("2_enemystats")`. This also resolves the cascading `arena.tscn` "referenced non-existent resource" error, which was purely a downstream symptom of `sperm_cell.tscn` failing to load at all. **No other file in this story used this pattern**, so this was the only place the bug existed.
- **Manual verification complete.** Administrator confirmed in the Godot editor, after the fix above: loads clean, SpermCell re-aims toward the player's current position as they move, blocked by the arena walls, passes through the player harmlessly, no console errors. All 6 acceptance criteria satisfied. Task 6 checked off; story moved to Status: review.

### File List

- `project.godot` (modified — appended `layer_3="enemy"`)
- `features/player_egg/player.gd` (modified — added `_ready()` with `add_to_group("player")`)
- `features/gameplay/arena.tscn` (modified — added SpermCell instance)
- `core/data/enemy_stats.gd` (new)
- `features/enemies/enemy_base.gd` (new)
- `features/enemies/enemy_base.tscn` (new)
- `features/enemies/sperm_cell.gd` (new)
- `features/enemies/sperm_cell.tscn` (new)
