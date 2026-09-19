---
baseline_commit: 6167ffa4bb10dfea91424969cf281c2a87e3e39f
---

# Story 1.1: Player movement (WASD/arrows) with 8-directional

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a player,
I want to move my egg character in 8 directions using WASD or arrow keys,
so that I can position myself to dodge enemies and aim my auto-attacks.

## Acceptance Criteria

1. Player character moves in 8 directions (up, down, left, right, and 4 diagonals) in response to WASD or Arrow key input. [Source: gdd.md#Movement, epics-and-stories.md#Epic 1: Core Foundation Acceptance Criteria]
2. Movement speed is 200 units/second on cardinal axes; diagonal movement is normalized (via `Vector2.normalized()`) so diagonal speed does not exceed 200 units/second. [Source: gdd.md#Movement — "Speed: 200 base units/second, upgradeable"]
3. Player stops immediately when no movement key is held (no acceleration/deceleration curve — GDD specifies none for MVP).
4. Movement uses Godot's Input Map actions `move_up`, `move_down`, `move_left`, `move_right` — NOT hardcoded `KEY_W` etc. checks. [Source: game-architecture.md#Input Handling]
5. Player is a `CharacterBody2D` and moves via `move_and_slide()` (not `position +=`), consistent with the architecture's chosen physics body. [Source: game-architecture.md#Player (features/player_egg/)]
6. Player scene instantiates and moves correctly when run standalone (no crash from missing autoload/signal dependencies).

## Tasks / Subtasks

- [x] Task 0: Define Input Map actions (AC: #1, #4) — **prerequisite, not yet configured anywhere in the project**
  - [x] Add `move_up` (W, Up arrow), `move_down` (S, Down arrow), `move_left` (A, Left arrow), `move_right` (D, Right arrow) to `project.godot` `[input]` section, matching the table in game-architecture.md#Input Handling
  - [x] Verify actions appear in Project Settings > Input Map after edit — verified via static review of the InputEventKey entries (physical_keycode values for W/A/S/D=87/65/83/68, arrows=4194320/4194319/4194322/4194321); no Godot editor/CLI available in this environment to open Project Settings directly (see Completion Notes)
- [x] Task 1: Create Player scene with CharacterBody2D (AC: #5, #6)
  - [x] Create `features/player_egg/player_egg.tscn` with root `CharacterBody2D` named `Player`
  - [x] Add `CollisionShape2D` with a `CircleShape2D` (represents the egg yolk hitbox per architecture node structure)
  - [x] Add `Sprite2D` child (placeholder texture acceptable for this story — no art asset pipeline yet)
  - [x] Attach new script `features/player_egg/player.gd` with `class_name Player extends CharacterBody2D`
  - [x] Do NOT add HurtBox/HitBox/WeaponPivot/AnimationPlayer nodes yet — those belong to later stories (E1-S4, E1-S5, E1-S6) per architecture's full node structure; keep this story's scene minimal to avoid building ahead of scope
- [x] Task 2: Implement movement input handling (AC: #1, #4)
  - [x] In `player.gd`, read input via `Input.get_vector("move_left", "move_right", "move_up", "move_down")` inside `_physics_process(delta)`
- [x] Task 3: Add 8-directional movement with WASD/arrows (AC: #1, #2, #3)
  - [x] Set `velocity = input_vector.normalized() * speed` (normalize BEFORE scaling by speed so diagonals aren't faster)
  - [x] Call `move_and_slide()` each physics frame
- [x] Task 4: Set movement speed to 200 units/sec (AC: #2)
  - [x] Add `@export var speed: float = 200.0` to `player.gd` (exported, not a magic number, so later stat-upgrade stories can modify it)
- [x] Task 5: Manual verification (AC: #1–#6)
  - [x] Open `player_egg.tscn` directly in the Godot editor and use "Run Current Scene" (F6) — do NOT rely on "Run Project" (F5), because `project.godot`'s `run/main_scene` currently points at an autoload script, not a real scene (see Dev Notes)
  - [x] Confirm player moves in all 8 directions and stops cleanly when keys are released — confirmed by Administrator: 8-directional movement works, diagonal isn't faster than cardinal, stops on release, no console errors

### Review Findings

- [x] [Review][Defer] Arrow keys are now double-bound to `move_*` and Godot's built-in `ui_up`/`ui_down`/`ui_left`/`ui_right` actions — once any UI has focus (pause menu, level-up cards, main menu), arrow-key presses will simultaneously move the player and shift UI focus/navigation. [project.godot] — deferred, log for Epic 5 (UI & Menus): decide there whether to unbind arrows from `ui_*` or gate `move_*` input by game state
- [x] [Review][Patch] `@export var speed: float = 200.0` has no lower-bound guard — can be set to 0 or negative in the Inspector, silently freezing or inverting movement. [features/player_egg/player.gd:6] — fixed: changed to `@export_range(0.0, 1000.0) var speed: float = 200.0`
- [x] [Review][Patch] `CharacterBody2D` left at default `motion_mode = 0` (Grounded) for a top-down game; should be `motion_mode = 1` (Floating) so `move_and_slide()` doesn't apply floor/ceiling/slide semantics once arena boundaries (E1-S2) and enemies (E1-S3) add other physics bodies to collide with. [features/player_egg/player_egg.tscn] — fixed: added `motion_mode = 1` to the Player node
- [x] [Review][Defer] No gamepad/joypad events bound on `move_*` actions (only keyboard); the `deadzone: 0.5` field is currently meaningless since no analog input is bound. [project.godot] — deferred, pre-existing scope boundary: gamepad support has no story yet in the epics backlog
- [x] [Review][Defer] `velocity = input_vector.normalized() * speed` re-normalizes an already magnitude-clamped `Input.get_vector()` result, forcing full speed regardless of input magnitude. [features/player_egg/player.gd:9] — deferred, harmless for keyboard-only input (always magnitude 0 or 1); only matters once gamepad/analog input is added
- [x] [Review][Defer] No explicit `collision_layer`/`collision_mask` set on the player; relies on Godot defaults. [features/player_egg/player_egg.tscn] — deferred, no other physics bodies exist yet (arena boundaries land in E1-S2, enemies in E1-S3) to define a layer convention against
- [x] [Review][Defer] Collision shape radius (16px) is a guess with no player art yet to validate it against. [features/player_egg/player_egg.tscn] — deferred, no art assets exist in the project yet

## Dev Notes

### Critical Gaps Not Covered by Sprint Task List (read before starting)

- **Input Map does not exist yet.** Neither `project.godot` nor any other project file defines `move_up`/`move_down`/`move_left`/`move_right` actions. The architecture doc (game-architecture.md#Input Handling) specifies these action names and their key bindings — Task 0 above must be done first, or `Input.get_vector()` will silently do nothing.
- **No runnable main scene exists.** `project.godot` currently sets `run/main_scene="res://core/autoload/game_manager.gd"` — a script, not a `.tscn`. This will not run correctly via F5/"Run Project". For this story, verify the player scene by opening `player_egg.tscn` and using "Run Current Scene" (F6) instead. Do not attempt to fix `run/main_scene` as part of this story — that's a separate concern (likely a future E1 story or infra task) outside E1-S1's scope; flag it in your completion notes if it blocks you further.
- **Existing autoloads have narrower signal/state surface than the architecture doc describes.** `core/autoload/signal_bus.gd` currently only defines `enemy_died`, `player_damaged`, `wave_completed` — the full signal list in game-architecture.md#SignalBus (e.g., `player_died`, `player_leveled_up`) does not exist yet. `core/autoload/game_manager.gd` has a flat `current_wave`/`score`/`is_game_over` state rather than the `GameState` enum described in the architecture. **This story does not need new signals** (movement has no signal per architecture), so do not add unused signals speculatively — leave `signal_bus.gd`/`game_manager.gd` untouched unless a later story requires it.

### Relevant Architecture Patterns and Constraints

- Player node structure (full, target state across E1-S1 through E1-S6): `Player (CharacterBody2D)` → `CollisionShape2D` (CircleShape2D, "yolk"), `Sprite2D`, `HurtBox` (Area2D + CollisionShape2D), `HitBox` (Area2D + CollisionShape2D), `WeaponPivot` (Node2D), `AnimationPlayer`, `player.gd`. **This story only builds the CharacterBody2D + CollisionShape2D + Sprite2D + script subset** — do not build HurtBox/HitBox/WeaponPivot now. [Source: game-architecture.md#Player (features/player_egg/)]
- Communication rule: all feature scripts must go through `SignalBus`, no direct cross-feature node references. Not triggered by this story (no cross-feature interaction yet), but keep `player.gd` free of any reference to other features. [Source: AGENTS.md#Communication Rule]
- Code conventions: GDScript 4.x syntax, typed variables, `@export`, `class_name`. The project's actual Godot version is **4.7** per `project.godot` (`config/features=PackedStringArray("4.7", "GL Compatibility")`), not the "4.2+" stated in gdd.md/game-architecture.md — this is a newer, compatible version; standard `CharacterBody2D`/`move_and_slide()` APIs used here are unchanged across 4.2–4.7. [Source: project.godot, AGENTS.md#Code Conventions]
- Project structure rule: feature scripts self-contained in their `features/` subdirectory. `player.gd` and `player_egg.tscn` both belong in `features/player_egg/`. [Source: AGENTS.md#Project Structure, game-architecture.md#File Structure]

### Project Structure Notes

- Target files: `features/player_egg/player_egg.tscn` (new), `features/player_egg/player.gd` (new). Both paths match game-architecture.md#File Structure exactly.
- `features/player_egg/.gitkeep` currently occupies this directory — it can remain; Godot/git do not require its removal, and it will simply stop being the only file present.
- No existing files are being modified (UPDATE) by this story — `signal_bus.gd`, `game_manager.gd`, and `stats_resource.gd` are read-only context for this story, not touch targets.

### Testing Requirements

- No automated test framework is set up yet (Test Architecture Enterprise / GDS test-framework skills have not been run). Verification for this story is manual, per Task 5.
- Per epics-and-stories.md#Definition of Done: code must compile and run without errors, no performance regression, follow project conventions (typed variables, class names) — no SignalBus usage is expected in this story specifically, since movement has no cross-feature signal in the architecture's SignalBus contract.

### References

- [Source: _bmad-output/planning-artifacts/gdd.md#Movement]
- [Source: _bmad-output/planning-artifacts/gdd.md#Controls and Input]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Input Handling]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Player (features/player_egg/)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#File Structure]
- [Source: _bmad-output/planning-artifacts/epics/epics-and-stories.md#Epic 1: Core Foundation]
- [Source: AGENTS.md#Communication Rule, #Code Conventions]
- [Source: project.godot]

## Change Log

- 2026-09-18: Implemented Input Map actions, Player scene/script, and 8-directional movement (Tasks 0–4). Task 5 (manual verification) left open — no Godot editor/CLI available in this environment.
- 2026-09-18: Administrator manually verified movement in the Godot editor (all 8 directions, diagonal normalization, stop-on-release, no console errors). Task 5 marked complete; story moved to review.
- 2026-09-18: Code review (Blind Hunter + Edge Case Hunter + Acceptance Auditor) completed against the diff and this spec. 1 decision deferred to Epic 5 (arrow-key/`ui_*` conflict), 2 patches applied (speed lower-bound guard via `@export_range`; `motion_mode = 1` for top-down movement), 4 items deferred to `deferred-work.md` (gamepad support, normalize-on-clamped-vector, collision layer/mask convention, collision radius vs. art), 6 dismissed as already covered by spec or later evidence. Story moved to done.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5 (claude-sonnet-5)

### Debug Log References

None — no automated test/build tooling (no Godot CLI, no GUT test framework) is available in this execution environment.

### Completion Notes List

- Implemented Tasks 0–4 (Input Map, player scene, movement input, 8-directional normalization, exported speed). Code was verified by static review only:
  - `project.godot` `[input]` block hand-authored in Godot 4's native InputEventKey format; physical_keycode values checked against the standard Godot 4 `Key` enum (W=87, A=65, S=83, D=68, KEY_UP=4194320, KEY_LEFT=4194319, KEY_DOWN=4194322, KEY_RIGHT=4194321).
  - `player.gd` and `player_egg.tscn` reviewed line-by-line for GDScript 4.x syntax and `.tscn` format-3 correctness (ext_resource/sub_resource IDs match their references).
- **Task 5 (manual verification) is NOT complete and NOT checked off.** This environment has no Godot editor or CLI (`godot`/`godot4` not on PATH), so I cannot open the scene, press F6, or watch the character move — that step requires a human at the Godot editor. Per the "no lying or cheating" rule, I'm reporting this honestly rather than claiming a run that didn't happen.
- **Manual verification complete.** Administrator confirmed in the Godot editor: 8-directional movement works, diagonal speed is not faster than cardinal (normalization confirmed), player stops immediately on key release, no console errors on scene load. All 6 acceptance criteria satisfied. Task 5 checked off; story moved to Status: review.

### File List

- `project.godot` (modified — added `[input]` section with move_up/move_down/move_left/move_right actions)
- `features/player_egg/player.gd` (new)
- `features/player_egg/player_egg.tscn` (new)
