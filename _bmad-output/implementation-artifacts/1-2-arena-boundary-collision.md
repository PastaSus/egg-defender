---
baseline_commit: 6167ffa4bb10dfea91424969cf281c2a87e3e39f
---

# Story 1.2: Player collision with arena boundaries

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a player,
I want the arena to have solid boundaries,
so that I can't wander (or get pushed) off the playable area during a run.

## Acceptance Criteria

1. Four boundary walls (top, bottom, left, right) exist as solid collision geometry that the player cannot pass through. [Source: epics-and-stories.md#Epic 1: Core Foundation Acceptance Criteria — "Player moves smoothly in 8 directions" implies containment; sprint-status.yaml task "Test player cannot leave arena"]
2. Boundaries are `StaticBody2D` collision geometry, not a script-side position clamp — consistent with Godot physics conventions and this project's existing pattern of solving movement/collision via physics bodies (`CharacterBody2D` + `move_and_slide()`), not manual position math. [Source: game-architecture.md — Player already uses CharacterBody2D physics, not `position +=`]
3. Player slides smoothly along a boundary when moving diagonally into it (e.g., holding down-right into the bottom wall keeps rightward motion) rather than fully stopping — this is the expected `move_and_slide()` behavior once `motion_mode = 1` (Floating) is set correctly (already set on Player in Story 1.1). [Source: 1-1-player-movement.md Dev Agent Record — motion_mode=1 patch]
4. Player and boundaries use an explicit, documented collision layer/mask convention — NOT Godot's uncustomized defaults. [Source: 1-1-player-movement.md Review Findings — deferred item: "No explicit collision_layer/mask set on the player... revisit when E1-S2 (arena boundaries)... land"]
5. The arena is sized so a tester can visually confirm containment in all 4 directions using the default 1280×720 viewport with **no camera** (no camera-follow system exists yet in this project) — NOT the GDD's eventual 2000×2000 full-game arena size. [Source: gdd.md#Level Design Framework — "Single Arena: 2000x2000 pixel play area"; see Dev Notes for why this AC intentionally deviates from that number for this story]
6. The new arena scene instantiates and runs standalone (no crash from missing autoload/signal dependencies), and the Player is visibly contained within it.

## Tasks / Subtasks

- [x] Task 0: Establish the collision layer/mask convention (AC: #4) — **resolves a deferred item from Story 1.1's code review; do this first, other tasks depend on it**
  - [x] In `project.godot`, add a `[layer_names]` section naming 2D physics layers: layer 1 = `world` (static level geometry — arena boundaries, later walls/obstacles), layer 2 = `player`. Leave layers 3+ unnamed/reserved for future stories (enemies, projectiles) — do not invent names for systems that don't exist yet.
  - [x] Update `features/player_egg/player_egg.tscn`'s `Player` node: set `collision_layer = 2` (player occupies the "player" layer) and `collision_mask = 1` (player only physically collides with "world" geometry — this is the only layer that exists to collide with right now)
- [x] Task 1: Create the arena scene (AC: #6) — **no scene currently hosts the Player; Story 1.1 only had a standalone `player_egg.tscn` for isolated testing**
  - [x] Create `features/gameplay/arena.tscn` — this path matches game-architecture.md's `GameManager.start_run()` pattern (`res://features/gameplay/%s.tscn`), even though wiring `start_run()` itself is NOT part of this story (see Dev Notes)
  - [x] Root node: `Node2D` named `Arena`
  - [x] Instance `features/player_egg/player_egg.tscn` as a child, positioned at the center of the arena (see Task 2 for exact coordinates)
  - [x] No script needed on `Arena` for this story — it's pure scene composition, no dynamic logic yet
- [x] Task 2: Create arena boundary StaticBody2D with collision shapes on all 4 edges (AC: #1, #2, #5)
  - [x] Add a `StaticBody2D` named `ArenaBoundary` as a child of `Arena`
  - [x] Set `ArenaBoundary.collision_layer = 1` (`world`) and `collision_mask = 0` (static geometry doesn't need to detect anything — the Player's mask is what drives the collision check)
  - [x] Add 4 `CollisionShape2D` children to `ArenaBoundary` (`TopWall`, `BottomWall`, `LeftWall`, `RightWall`), each with a `RectangleShape2D` sized as a thin wall along that edge
  - [x] Size and position the play area to fit the default 1280×720 viewport with a margin — playable interior x:[40,1240], y:[40,680]; walls are 40px-thick bands outside that interior on all 4 sides
  - [x] Position the instanced Player (from Task 1) at the center of that interior: `position = Vector2(640, 360)`; `player_egg.tscn`'s own default position was left untouched
- [x] Task 3: Manual verification (AC: #1, #3, #5, #6)
  - [x] Open `features/gameplay/arena.tscn` directly in the Godot editor and use "Run Current Scene" (F6) — same reasoning as Story 1.1: `project.godot`'s `run/main_scene` still doesn't point at a real scene
  - [x] Confirm the player cannot pass through any of the 4 walls when holding movement into them — confirmed by Administrator: blocked at all 4 walls
  - [x] Confirm diagonal movement into a wall slides along it (e.g., down-right into the bottom wall keeps sliding right) rather than fully stopping or jittering — confirmed: slides smoothly along walls
  - [x] Confirm no console errors on scene load or during movement — confirmed: no console errors

### Review Findings

- [x] [Review][Defer] No floor/background visual on `ArenaBoundary` — walls are invisible collision-only geometry, so the boundary position is only discoverable by hitting it, a slightly weaker visual confirmation than a drawn edge would give. [features/gameplay/arena.tscn] — deferred, pre-existing: no art pipeline exists in the project yet (same rationale as Story 1.1's textureless Sprite2D); not required by any AC or task, and AC #5's containment check already passed via the player's own visible stop
- [x] [Review][Defer] Concave-corner collision behavior (diagonal movement aimed directly into a wall intersection) wasn't explicitly re-tested beyond the general "can't leave arena" and single-wall-diagonal-slide checks. [features/gameplay/arena.tscn — TopWall/LeftWall and other adjacent wall pairs] — deferred, low-risk: walls use the standard safe Godot pattern (overlapping static colliders at corners, no gaps), which is the conventional way to prevent corner leaks, not a known source of jitter; flagged for due diligence in a future test pass rather than blocking this story

## Dev Notes

### Critical Gaps Not Covered by Sprint Task List (read before starting)

- **This resolves a deferred item from Story 1.1.** That story's code review flagged "no explicit collision_layer/collision_mask on the player" and explicitly deferred it to this story, since Story 1.1 had no other physics body to define a convention against. This story is the first to introduce a second physics body (the arena boundary), so Task 0 is not optional polish — it's the actual point where that gap gets closed. [Source: 1-2's own AC #4; 1-1-player-movement.md Review Findings]
- **No scene currently hosts the Player.** `features/player_egg/player_egg.tscn` exists standalone (built for Story 1.1's isolated movement test) but nothing instances it into a larger scene. Task 1 creates that host scene.
- **The architecture doc never names an "arena" or "boundary" feature module.** game-architecture.md's Feature Modules section only lists Player, Enemies, Weapons, Projectiles, and UI — arena/level geometry isn't mentioned there at all. The ONE piece of grounding for where a playable scene should live is in a different section — `GameManager`'s `Scene Instancing Pattern`, which loads `res://features/gameplay/%s.tscn`. Task 1 uses `features/gameplay/arena.tscn` for that reason. **Do not invent a `features/arena/` folder** — it would contradict the one path convention the architecture doc actually specifies. [Source: game-architecture.md#Scene Management, #Scene Instancing Pattern]
- **Do NOT wire up `GameManager.start_run()` or modify `game_manager.gd` in this story.** The architecture's `start_run(stage: String)` pattern is how a real scene-select flow would eventually load `arena.tscn`, but no story in the current sprint asks for that (stage select / main menu is Epic 5, not scheduled yet). Wiring it now would be scope creep — this story's arena is opened directly via the editor (Task 3), exactly like `player_egg.tscn` was in Story 1.1.
- **AC #5 deliberately does NOT use the GDD's 2000×2000 arena size.** The GDD specifies a 2000×2000 play area with camera-follow, but no camera-follow system exists anywhere in the project yet, and no story in Epic 1 adds one. At 200 units/sec (Story 1.1's speed), a player would visually vanish off the 1280×720 viewport in about 3 seconds long before ever reaching a boundary 1000 units away — making "test player cannot leave arena" impossible to actually observe. This story intentionally sizes the arena to the visible viewport instead. **Flag to the user:** no camera-follow story currently exists in the backlog; the real 2000×2000 arena will need one before it's playable, and `arena.tscn`'s boundary will need resizing at that point.

### Relevant Architecture Patterns and Constraints

- Player already exists at `features/player_egg/player_egg.tscn` / `player.gd` from Story 1.1: `CharacterBody2D`, `motion_mode = 1` (Floating — already set, and exactly why AC #3's smooth-slide behavior is expected to work with no extra code), `@export_range(0.0, 1000.0) var speed: float = 200.0`, movement via `Input.get_vector()` + `move_and_slide()`. [Source: features/player_egg/player.gd, features/player_egg/player_egg.tscn]
- Communication rule: all feature scripts go through `SignalBus`, no direct cross-feature node references. Not triggered by this story — boundary collision is handled automatically by the physics engine via `move_and_slide()`, no signal needed for "player hit a wall." [Source: AGENTS.md#Communication Rule]
- Project structure rule: feature scripts self-contained in their `features/` subdirectory. `arena.tscn` belongs in `features/gameplay/` (new directory — doesn't exist yet, create it). [Source: AGENTS.md#Project Structure, game-architecture.md#Scene Management]

### Project Structure Notes

- New files: `features/gameplay/arena.tscn` (new directory + file).
- Modified files (UPDATE, both read in full during story creation): `project.godot` (add `[layer_names]` section), `features/player_egg/player_egg.tscn` (add `collision_layer`/`collision_mask` to the `Player` node — current state has no explicit values, meaning it currently sits at Godot's default `collision_layer = 1, collision_mask = 1`, which this story intentionally changes).
- `features/player_egg/player.gd` is NOT touched by this story — collision layer/mask are scene-file (`.tscn`) node properties, not script properties.

### Testing Requirements

- No automated test framework is set up yet (same as Story 1.1). Verification is manual, per Task 3.
- Per epics-and-stories.md#Definition of Done: code must compile and run without errors, no performance regression, follow project conventions.

### Previous Story Intelligence (from 1-1-player-movement.md)

- **Environment constraint carries over:** the execution environment has no Godot editor/CLI available. Static code/scene-file review can verify syntax and structure, but actually running the scene (Task 3) requires a human at the Godot editor, same as Story 1.1's Task 5. Do not claim manual verification happened without an actual human-reported result — this was explicitly called out as a "no lying" requirement in Story 1.1's execution and holds here too.
- **`motion_mode = 1` is already set on Player** (applied as a Story 1.1 code-review patch) — this story benefits from that fix directly (AC #3's smooth wall-slide depends on Floating mode, not the CharacterBody2D default Grounded mode).
- **Established GDScript conventions to match:** `class_name` + typed variables + `@export`/`@export_range` for tunable values (see `player.gd`); no magic numbers for anything a future story might need to tune.

### References

- [Source: _bmad-output/planning-artifacts/gdd.md#Level Design Framework]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Scene Management]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Scene Instancing Pattern]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Feature Modules]
- [Source: _bmad-output/planning-artifacts/epics/epics-and-stories.md#Epic 1: Core Foundation]
- [Source: _bmad-output/implementation-artifacts/1-1-player-movement.md — Dev Agent Record, Review Findings]
- [Source: AGENTS.md#Communication Rule, #Project Structure]
- [Source: project.godot, features/player_egg/player_egg.tscn, features/player_egg/player.gd]

## Change Log

- 2026-09-18: Implemented collision layer/mask convention, arena scene with Player instance, and 4-wall StaticBody2D boundary (Tasks 0–2). Task 3 (manual verification) left open — no Godot editor/CLI available in this environment.
- 2026-09-18: Administrator manually verified in the Godot editor: player blocked at all 4 walls, diagonal movement slides smoothly along walls, no console errors. Task 3 marked complete; story moved to review.
- 2026-09-18: Code review (Blind Hunter + Edge Case Hunter + Acceptance Auditor) completed against the diff and this spec. Zero decisions, zero patches — 0 code changes needed. 2 items deferred to `deferred-work.md` (no boundary visual; corner-collision re-test), 9 dismissed as already covered by spec or verified evidence. Story moved to done.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5 (claude-sonnet-5)

### Debug Log References

None — no automated test/build tooling (no Godot CLI, no GUT test framework) is available in this execution environment.

### Completion Notes List

- Implemented Tasks 0–2 (collision layers, arena scene, boundary walls). Verified by static review only:
  - `project.godot`: added `[layer_names]` section (`2d_physics/layer_1="world"`, `2d_physics/layer_2="player"`).
  - `features/player_egg/player_egg.tscn`: `Player` node now has `collision_layer = 2`, `collision_mask = 1` (previously unset, defaulting to Godot's `layer=1, mask=1`).
  - `features/gameplay/arena.tscn` (new): `Arena` (Node2D) root, `Player` instance of `player_egg.tscn` at `(640, 360)`, `ArenaBoundary` (StaticBody2D, `collision_layer=1`, `collision_mask=0`) with 4 `CollisionShape2D` children (`TopWall`/`BottomWall`: `RectangleShape2D` size `(1280,40)` at y=20/700; `LeftWall`/`RightWall`: size `(40,720)` at x=20/1260) framing the 1280×720 viewport with a 40px margin band on each side.
  - Reviewed `.tscn` syntax against Godot 4 format-3 conventions (ext_resource/sub_resource IDs match references, `RectangleShape2D.size` used correctly as full extents, not Godot 3's half-extent `extents` property).
- **Task 3 (manual verification) is NOT complete and NOT checked off.** Same environment constraint as Story 1.1: no Godot editor or CLI available here, so I cannot open `arena.tscn`, run it, and watch the player collide with walls — that requires a human at the Godot editor.
- **Manual verification complete.** Administrator confirmed in the Godot editor: player is blocked at all 4 walls, diagonal movement into a wall slides smoothly along it, no console errors on load. All 6 acceptance criteria satisfied. Task 3 checked off; story moved to Status: review.

### File List

- `project.godot` (modified — added `[layer_names]` section)
- `features/player_egg/player_egg.tscn` (modified — added `collision_layer`/`collision_mask` to the `Player` node)
- `features/gameplay/arena.tscn` (new)
