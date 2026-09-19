---
baseline_commit: 05f7aa95e27c0e0467de9cff8f9aac450f054fc1
---

# Story 1.5: Player health system (take damage, die)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a player,
I want to lose health when enemies hit me and die when it runs out,
so that surviving the horde is a real risk with a real end.

## Acceptance Criteria

1. **Player health data.** `Player` (`features/player_egg/player.gd`) gains `@export var stats: StatsResource`. Maximum health is `stats.health` (100.0, matching gdd.md#Health System). A runtime `current_health: float` is initialised to the maximum in `_ready()`. `stats.health` is never mutated (it is the *maximum*, and the resource is configuration, not run state). [Source: AGENTS.md#Code Conventions; user spec; Story 1.3 review finding on mutating shared stats]
2. **One stats resource, not two.** The Player's `stats` and the existing `HurtBox.stats` (added in Story 1.4) reference the **same** embedded `StatsResource` sub-resource in `player_egg.tscn`. Do not add a second resource or new stat fields. `cooldown` stays the invulnerability window (unchanged from 1.4). [Source: AGENTS.md "do not duplicate stat fields"; user spec]
3. **Damage is applied from the existing request signal.** `Player` connects to `SignalBus.player_damaged(amount: int)` and reduces `current_health` by `amount`, clamped at 0 (`current_health` is never negative, even when the last hit exceeds the remaining health). `amount <= 0` is ignored (a negative amount must not heal). Public method `take_damage(amount: int)` holds the logic. **The Player never emits `player_damaged`.** [Source: Story 1.4 review decision; sprint-status.yaml E1-S5 tasks]
4. **Health-changed notification.** After every accepted change, the Player emits `SignalBus.player_health_changed(current: float, maximum: float)`. This is the new notification for future HUD and feedback; nothing listens to it yet. [Source: Story 1.4 review decision]
5. **Death fires exactly once.** When `current_health` reaches 0, the Player emits `SignalBus.player_died()` (signature per game-architecture.md#SignalBus) exactly once. A dead Player ignores all further damage: no more health changes, no more `player_health_changed`, no second `player_died`, even while enemies stay parked on it. [Source: user spec; epics-and-stories.md Epic 1 "Player dies when HP reaches 0"]
6. **GameManager owns "game over".** `GameManager` connects to `player_died` and sets `is_game_over = true` (its existing, currently unused field). Neither `player.gd` nor any `features/` script decides what game-over means or references `GameManager`. This story does **not** change scenes, pause the tree, or show anything. [Source: user spec; AGENTS.md#Core System Responsibilities]
7. **Contact damage stops after death (folds in a Story 1.4 deferred item).** After `player_died`, `PlayerHurtBox` no longer resolves or emits `player_damaged`. The "No game-over gating on contact damage" entry in `deferred-work.md` is marked resolved. [Source: deferred-work.md, code review of 1-4]
8. **Scope held.** No new invulnerability logic (Story 1.4's window is unchanged and is the only i-frame mechanism), no knockback, no damage flash or hit feedback, no health bar or any UI, no `HealthComponent` node, no respawn or restart. Movement is unchanged **except** that the Player stops processing movement input after `player_died` (see Task 1b). Enemy behaviour is untouched and there is no visual or animation for death. [Source: user spec; user instruction 2026-09-19]
9. **Story 1.4 behaviour preserved.** With contact damage from one or two enemies, exactly one `player_damaged` still lands per about 1 s window, and the higher damage still wins within a window.
10. The arena runs without console errors or warnings.

## Tasks / Subtasks

- [x] Task 0: New signals on SignalBus (AC: #4, #5)
  - [x] In `core/autoload/signal_bus.gd` add `signal player_health_changed(current: float, maximum: float)` and `signal player_died()`, with a doc comment each. Do not change any existing signal, and keep the existing `player_damaged` comment (it already says listeners must not re-emit it).
- [x] Task 1: Player health (AC: #1, #2, #3, #4, #5)
  - [x] `player.gd`: add `@export var stats: StatsResource`, `var current_health: float`, `var _is_dead: bool = false`.
  - [x] `_ready()` (keep the existing `add_to_group("player")`): `current_health = stats.health` (guard `stats == null` with `push_error` and a fallback of 100.0 so a misconfigured scene degrades rather than crashes), then `SignalBus.player_damaged.connect(take_damage)`.
  - [x] `take_damage(amount: int) -> void`: return if `_is_dead` or `amount <= 0`; `current_health = maxf(current_health - amount, 0.0)`; emit `SignalBus.player_health_changed.emit(current_health, <max>)`; if `current_health <= 0.0` call `_die()`.
  - [x] `_die() -> void`: `_is_dead = true`, then `SignalBus.player_died.emit()`. Set `_is_dead` **before** emitting so a re-entrant call cannot double-fire.
  - [x] Do not touch movement (`speed`, `_physics_process`) or the `speed` export; migrating `speed` onto `stats` is a separate deferred cleanup (see Dev Notes).
- [x] Task 1b: Freeze player input on death (AC: #8) - **added by user instruction 2026-09-19** (this story had flagged it as an option; the user then requested it)
  - [x] In `player.gd`, `_physics_process` returns early once `_is_dead`, and `_die()` zeroes `velocity`. Player only: no change to enemy movement, no visual, no animation.
- [x] Task 2: Share one stats resource (AC: #2)
  - [x] In `player_egg.tscn`, add `stats = SubResource("StatsResource_player")` to the `Player` root node (the same sub-resource id `HurtBox` already uses). Set `health = 100.0` explicitly on that sub-resource for readability (it equals the default). Keep `resource_local_to_scene = true` and `cooldown = 1.0`. No new `ext_resource` or `sub_resource`, so `load_steps` stays 7.
- [x] Task 3: GameManager handles game-over (AC: #6)
  - [x] In `core/autoload/game_manager.gd`, connect `SignalBus.player_died` in `_connect_signals()` and add `_on_player_died()` that sets `is_game_over = true`. Nothing else.
- [x] Task 4: Stop contact damage after death (AC: #7)
  - [x] In `features/player_egg/player_hurt_box.gd`, connect to `SignalBus.player_died` and set a `_player_dead` flag that makes `_resolve_pending_damage()` discard pending damage and return without emitting. Use the signal, not `GameManager.is_game_over`: it keeps `player_egg` self-contained and independent of another system's state.
  - [x] Update `deferred-work.md`: mark the "No game-over gating on contact damage" entry resolved by Story 1.5 (keep the history, as Story 1.4 did for the arrival-distance item).
- [x] Task 5: Manual verification (AC: #3, #5, #7, #9, #10)
  - [x] **Temporary** debug (removed before finishing): in `GameManager._ready()` add prints for `player_health_changed` (current, max, timestamp) and `player_died` (timestamp). There is no HUD, so this is the only way to see events.
  - [x] **Temporary** clamp test: in `player_egg.tscn` set the shared stats resource `health = 95.0`, so ten 10-damage hits end at -5 unless clamped. Revert to `100.0` afterwards.
  - [x] Run `arena.tscn`, stand still under both SpermCells. Expect health to step down about once per second, the final `player_health_changed` to print `0.0` (never `-5.0`), and `player_died` to print once.
  - [x] Keep standing there for at least 5 more seconds with enemies on you. Expect **no** further `player_health_changed`, **no** second `player_died`.
  - [x] Confirm no console errors or warnings. Then remove all temporary prints and restore `health = 100.0`; confirm with `git diff`.
- [x] Task 6: Bookkeeping
  - [x] Update the story File List and Change Log; set status per the workflow.
  - [x] Log the `stats.speed` vs bare `speed` export duplication in `deferred-work.md` (user instruction; do not migrate).

### Review Findings

- [x] [Review][Decision] **Resolved 2026-09-19: deferred broadcast in `_ready()`.** `Player._ready()` now calls `_broadcast_health.call_deferred()`, which emits `player_health_changed(current_health, _max_health)` once the frame settles, so anything connected by the first frame receives the starting value without depending on ready order. No new signal was added. Original finding: Nothing ever emits the player's starting health, so a future HUD cannot learn it. `_ready()` performs an accepted health change (`current_health = _max_health`) without emitting, so the first `player_health_changed` a listener ever sees is after the first hit, e.g. `(90.0, 100.0)`. This contradicts the signal's own doc comment ("after every accepted health change") and means E5-S2's health bar would render nothing until the player is first hit, seconds into a run. Reading `Player.current_health` directly is not a workaround: `AGENTS.md`'s Communication Rule forbids cross-feature node references, and Godot readies children before parents, so a node under the Player would read `0.0` anyway. A plain emit at the end of `_ready()` is also not enough, because a listener elsewhere in the tree may not be connected yet. Options: (a) `call_deferred` a broadcast at the end of `_ready()` so anything connected by the first frame receives it; (b) add a `player_spawned(current, maximum)` signal; (c) leave it and let E5-S2 solve it when the HUD actually exists. Flagged by two layers. [features/player_egg/player.gd:24, core/autoload/signal_bus.gd:13]
- [x] [Review][Patch] The `stats` guard checks only `null`, not a non-positive `health`, which produces exactly the state the guard was written to prevent. An assigned resource with `health = 0.0` gives `_max_health = 0.0`, `current_health = 0.0` and `_is_dead = false`: the player walks around alive at zero health, `player_died` never fires (violating the "exactly once when health reaches 0" contract), and the first contact emits `player_health_changed(0.0, 0.0)`, a divide-by-zero for any bar computing `current / maximum`. Deleting the resource entirely yields a *working* player while a half-configured one does not. This story's own Task 5 used exactly that pattern (a temporary `health = 95.0`), so a stray `0.0` is a live risk. Fix: guard `stats == null or stats.health <= 0.0`. Flagged by two layers. [features/player_egg/player.gd:20-24]
- [x] [Review][Patch] Post-death contact reports never stop, and `_pending_damage` latches non-zero forever. `_on_enemy_reached_player()` has no `_player_dead` guard, and `_resolve_pending_damage()` returns *before* the `_pending_damage = 0` line, so every enemy parked on the corpse keeps writing into the accumulator every physics frame for the rest of the run. Guaranteed on every death, because `arrival_distance` parks enemies on the body, the dead Player is never removed from the `"player"` group, and nothing despawns enemies at game over. Two consequences ahead: with Story 2.1's spawner it is N enemies x 60 Hz of dead signal traffic after game over, and any future path that clears `_player_dead` in place (revive, restart without reload) applies the latched damage on its first frame back. The `_pending_damage = 0` in `_on_player_died()` runs once and is immediately undone. Flagged by all three layers. [features/player_egg/player_hurt_box.gd:33-34, 41]
- [x] [Review][Patch] The story contradicts itself about the input freeze. AC #8, Task 1b, the File List and the Change Log were all amended to include it, but Dev Notes design decision #5 still reads "**Flagged, not built:** freezing player input on death ... belongs in a small follow-up ... not silently here", and the "Out of scope (do not build)" list still names "freezing player movement on death". A reader of the out-of-scope list alone would correctly call the implemented freeze scope creep. Stale text, not a scope defect. [1-5-player-health-system.md Dev Notes, Out of scope]
- [x] [Review][Patch] The `sprint-status.yaml` edit is broader than the File List discloses. The diff also changes `completed_points: 5` to `16`, silently back-filling points for Stories 1.3 and 1.4 that were never counted. The arithmetic is right (3+2+5+3+3), but the File List describes the file only as "(modified: E1-S5 status)" and the Change Log does not mention it at all. [1-5-player-health-system.md File List, sprint-status.yaml]
- [x] [Review][Defer] Death state latches with no reset path anywhere in code. `Player._is_dead`, `PlayerHurtBox._player_dead` and `GameManager.is_game_over` are all set on death and never cleared; `current_health` only ever decreases. `GameManager.start_game()` does reset `is_game_over`, but it has zero callers project-wide. So an in-place restart leaves the player alive-but-dead and invulnerable, while a `reload_current_scene()` restart that forgets `start_game()` leaves the autoload claiming the run is over while the fresh Player is alive - a split-brain state. [features/player_egg/player.gd, features/player_egg/player_hurt_box.gd, core/autoload/game_manager.gd] - deferred: restart and game-over flow are Epic 5 scope (E5-S4), and this story deliberately built no restart. The story's Dev Notes flagged it, but only in the story file where Epic 5 planning would not see it; this ledger entry corrects that. Flagged by all three layers.
- [x] [Review][Defer] Health routing over the global bus silently assumes exactly one Player. Every Player connects `take_damage` to the global `player_damaged` and every HurtBox emits into it, so with two live instances each Player applies both emissions (double damage), `player_health_changed` interleaves two senders with no identity payload, and `player_died` fires twice - contradicting the "exactly once" contract on the signal. The `_is_dead` guard is per-instance and structurally cannot protect a global signal. [features/player_egg/player.gd:25, features/player_egg/player_hurt_box.gd:48, core/autoload/signal_bus.gd:14] - deferred: `arena.tscn` instances exactly one Player and nothing today creates a second. Becomes reachable if Epic 5's restart instances a new player before freeing the old (`add_child` then `queue_free` leaves both live for a frame, which `change_scene_to_*` avoids), or if a decoy/clone upgrade is ever added. Settle it then, by adding sender identity or routing per-instance.

## Dev Notes

### Reconciling the request against the repo (things the user asked to have flagged)

- **No pre-existing E1-S5 story file existed.** Its only sources were the sprint-status task list, the epics one-liner ("Player health system (take damage, die)", 3 points, "Player dies when HP reaches 0"), and the user's spec, which this story folds in. The story key is `1-5-player-health-system`.
- **"Check whether the player already has a StatsResource":** `player.gd` has none (`speed` is a bare export, a Story 1.1 deviation logged in `deferred-work.md`). The only player `StatsResource` is embedded on the **HurtBox** node, created in Story 1.4 with `health = 100` and `cooldown = 1.0` and explicitly noted there as a placeholder for Story 1.5 to hoist. This story hoists it by having Player and HurtBox share the one sub-resource. No fields are added.
- **Signal name:** the architecture doc defines `player_died()` (game-architecture.md line 50), so that is the name used.
- **i-frames:** they already exist (Story 1.4's `PlayerHurtBox` window). "Don't add i-frames" is honoured by adding none. The health system sits *behind* that gate and sees at most one `player_damaged` per window.
- **"HealthComponent":** Story 1.4's decision text said "No HealthComponent yet, that's S5's job", but the architecture only places a `HealthComponent` node on **enemies**, and Story 1.3 assigns that to Story 1.9. The player's health belongs in `Player.gd` per game-architecture.md ("Player.gd Responsibilities: Manage health"), and the sprint task says "Add health variable to player". So this story adds **no** `HealthComponent`. If a shared reusable component was intended for both player and enemies, say so before dev starts.
- **Working agreement on review model:** the user referenced a rule about using a different review model for this story's damage/death edge cases. It could not be located in `AGENTS.md`, planning artifacts, story files or saved memory. Nothing here depends on it; it is recorded so it isn't silently assumed satisfied.

### Design decisions made by story creation (flagged for review)

1. **`current_health` is a runtime `Player` variable, `stats.health` is the maximum.** Mutating the resource would repeat the shared-state bug flagged in Story 1.3's review, and would break the "max_health" meaning.
2. **Health is `float`** to match `StatsResource.health`, while `player_damaged` carries `int` (Story 1.4). `maxf(current_health - amount, 0.0)` mixes them safely.
3. **`_is_dead` guard set before emitting `player_died`**, so the "exactly once" property holds even under re-entrancy and does not depend on enemies or `PlayerHurtBox` behaving.
4. **Two independent layers stop post-death damage:** Player's own `_is_dead` guard (correctness: never negative, never re-die) and `PlayerHurtBox`'s `_player_dead` flag (stops the signal traffic and closes the deferred ledger item). Either alone would satisfy AC #5; both are cheap.
5. **Death is intentionally invisible.** With no UI, no freeze of the *world* and no game-over screen, death shows only as a stopped player and a signal on the bus: enemies keep charging and nothing on screen announces it. Player input is frozen (Task 1b, added by user instruction during implementation), but no visual, animation or tint was built - that is Epic 5/7 scope.

### Critical technical gotchas

- **Do not re-emit `player_damaged`** from `take_damage()`. It is the incoming request; re-emitting recurses to a stack overflow (Story 1.4 review decision, documented on the signal in `signal_bus.gd`).
- **Connect with the method directly:** `SignalBus.player_damaged.connect(take_damage)` works because `take_damage(amount: int)` matches the signal signature. The connection to an autoload is auto-severed when the Player is freed.
- **Emit order inside one call chain:** `PlayerHurtBox._resolve_pending_damage()` sets its invulnerability timer, then emits `player_damaged`, which synchronously runs `take_damage`, which may synchronously emit `player_died`, which `PlayerHurtBox` and `GameManager` receive. All state changes are made before each emit, so this is safe. Keep that ordering.
- **Shared local-to-scene resource:** one instantiation of `player_egg.tscn` gets one duplicate of the sub-resource, referenced by both the root and `HurtBox`. Even if it were not shared, both copies hold identical values, so behaviour is unchanged; sharing is only about a single source of truth.
- **`stats == null` on the Player:** `push_error` once and fall back to 100.0. Do not silently use `0`, which would kill the player on the first tick.
- **Scene reload / restart is out of scope**, but note for the Epic 5 restart story: `GameManager.is_game_over` persists in the autoload across a scene reload, so the restart path must call `GameManager.start_game()` (which resets it), while Player's `_is_dead` and `current_health` reset naturally with the scene.

### Existing code this story touches (read in full)

| File | State today | This story changes | Must preserve |
|---|---|---|---|
| `core/autoload/signal_bus.gd` | `enemy_died`, `player_damaged`, `wave_completed`, `enemy_reached_player`, with semantics comments | add `player_health_changed`, `player_died` | all existing signals and comments |
| `core/autoload/game_manager.gd` | `is_game_over` declared and reset in `start_game()`, never set true or read; connects `enemy_died`, `wave_completed` | connect `player_died`, set `is_game_over` | existing connections, `start_game()` |
| `features/player_egg/player.gd` | `speed` export; `_ready()` adds `"player"` group; `_physics_process` moves | health fields, `take_damage`, `_die` | group registration, movement, `speed` export |
| `features/player_egg/player_egg.tscn` | `Player` root, `HurtBox` (layer 8, `monitoring=false`) with `stats = SubResource("StatsResource_player")` (`cooldown = 1.0`, local to scene); `load_steps=7` | root `stats` assignment, explicit `health = 100.0` | HurtBox settings, layers, shape radii |
| `features/player_egg/player_hurt_box.gd` | accumulates `enemy_reached_player` with `maxi`, resolves once per physics frame, 1.0 s window, `FALLBACK_COOLDOWN` | dead flag via `player_died` | max-damage resolution, window logic, warn-once fallback |
| `_bmad-output/implementation-artifacts/deferred-work.md` | "No game-over gating" entry open | mark resolved | rest of the ledger |

### Architecture compliance

- Feature scripts use `SignalBus` only. `Player` and `PlayerHurtBox` (same feature) do not reference `GameManager` or any enemy. `GameManager` (core) reacts to a bus event; it does not reach into the Player.
- Typed GDScript with `class_name` where applicable (Definition of Done, epics-and-stories.md).
- `player.gd` "Manage health (take damage, heal)" per game-architecture.md#Player. `player_healed` from the architecture's signal list is **not** added (no healing source exists yet).

### Testing requirements

- No automated test framework exists; verification is manual (Task 5), as in Stories 1.1-1.4. Do not claim it happened without a human-reported result if no Godot editor is available in your environment.
- The three properties that matter are: `player_died` fires exactly once, health never goes negative, and nothing changes after death. The clamp needs the temporary `health = 95.0` setup, because with 100 health and 10 damage the final hit lands exactly on 0 and would not exercise clamping.

### Previous story intelligence (1.4)

- Code review resolved: `player_damaged` is the request and 1.5 must not re-emit it; the gate takes max damage per window; `PlayerHurtBox` warns once on missing stats. All are preserved here.
- Story 1.4's post-review patches changed the damage path **after** its manual run and were never re-tested in the editor. This story's manual run therefore also serves as that re-verification: confirm one `player_damaged` per about 1 s and a single hit when both enemies touch.
- Hand-authored `.tscn` pitfalls that already bit twice: scripted-resource `type="Resource"` + `script = ExtResource(...)`, `resource_local_to_scene = true`, and recounting `load_steps` (resources + 1). This story adds no new resources, so `load_steps` stays 7.
- Encoding: write artifact files as UTF-8. A cp1252 write corrupted em-dashes during Story 1.4's review and had to be repaired.

### Git intelligence

- Latest commits: `05f7aa9` (Story 1.4 with review fixes), `b19ac42` (Story 1.3). Conventional commits with a scope, for example `feat(player): add health and death handling (Story 1.5)`. One atomic commit.
- Commit the generated `.gd.uid` files if any new scripts are created (this story creates none).

### Project Structure Notes

- No new files except this story. Modified: `signal_bus.gd`, `game_manager.gd`, `player.gd`, `player_egg.tscn`, `player_hurt_box.gd`, `deferred-work.md`, `sprint-status.yaml`.
- No `project-context.md` exists; rules come from `AGENTS.md`.

### Out of scope (do not build)

Health bar or any HUD (Epic 5); screen flash and hit feedback (Epic 5/7, EXPERIENCE.md "Take damage" row); death animation, slow-mo or any visual death feedback (EXPERIENCE.md PLAYING to RUN_END); game-over screen or scene change (E5-S4); restart; healing (`player_healed`, health orbs); armor or extra-HP upgrades; enemy health (Story 1.9); migrating `player.gd`'s `speed` onto `stats` (deferred cleanup: `stats.speed` defaults to 200.0 and duplicates the bare `speed` export in spirit, but leave both alone here so the change stays scoped).

### References

- [Source: _bmad-output/planning-artifacts/epics/epics-and-stories.md#Epic 1 - E1-S5, Epic acceptance "Player dies when HP reaches 0"]
- [Source: _bmad-output/implementation-artifacts/sprint-status.yaml - E1-S5 tasks (corrected in the Story 1.4 review)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#SignalBus (player_died, player_damaged), #Player (Player.gd responsibilities), #StatsResource]
- [Source: _bmad-output/planning-artifacts/gdd.md#Health System (100 HP, damage on contact, no regen by default)]
- [Source: _bmad-output/planning-artifacts/ux-design/EXPERIENCE.md#Feedback, #State transitions (deferred to Epic 5)]
- [Source: _bmad-output/implementation-artifacts/1-4-enemy-player-contact-damage.md - Review Findings and Dev Notes]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md - "No game-over gating on contact damage", Player `speed` / StatsResource deviation]
- [Source: AGENTS.md#Communication Rule, #Code Conventions, #Core System Responsibilities]

## Change Log

- 2026-09-19: Story created (ready-for-dev) from the E1-S5 sprint tasks and the user's health/death spec, reconciled against the repo, with the Story 1.4 signal decision and the deferred game-over gating item folded in.

- 2026-09-19: Implemented Tasks 0-4 plus Task 1b (input freeze on death, added by user instruction). Logged the `speed` duplication in `deferred-work.md`.
- 2026-09-19: Code review (3 parallel layers, run on Opus 5 while the implementation was written on Sonnet 5). 1 decision resolved, 4 patches applied, 2 items deferred, 4 dismissed. Patches: the `stats` guard now also rejects `health <= 0`; `PlayerHurtBox._on_enemy_reached_player()` drops reports once the player is dead, so post-death signal traffic stops and `_pending_damage` cannot latch; the story's two stale "do not build the input freeze" passages were corrected; the `completed_points` back-fill is now disclosed in the File List. Decision: the starting health is now broadcast via a deferred emit in `_ready()`. Deferred to the ledger: the death-state latch with no reset path (Epic 5 restart), and the single-Player assumption in global-bus health routing.
- **Re-verification advised:** the patches changed `_ready()` and the hurtbox report path after Administrator's manual run, so the damage and death cadence has not been re-tested in the editor.
- 2026-09-19: Administrator ran `arena.tscn` with the temporary scaffolding and confirmed: health stepped 95 to 85 ... to 5 to 0 with no negative value (clamp verified), `player_died` fired exactly once, the player stayed frozen with no further health, damage or death events after death, `player_damaged` still lands about once per second with a single hit when both enemies overlap (Story 1.4's post-review patches re-verified), and no console errors. Temporary `[TEMP]` prints and `health = 95.0` were removed and `git diff` confirmed no leftover scaffolding. Task 5 done; story marked done at the user's instruction. No `code-review` pass has been run on this story.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5 (claude-sonnet-5)

### Debug Log References

### Completion Notes List

- All tasks (0-6, including Task 1b input freeze added by user instruction) complete. Manual verification was performed by Administrator in the Godot editor (see Change Log); no automated test framework exists.
- Verified: clamp at 0 (health 95 with 10-damage hits ended at 0, never -5), `player_died` exactly once, input frozen and no further events after death, Story 1.4 contact-damage cadence intact, no console errors. Temporary scaffolding removed.
- Not done: no code review has been run on this story; death has no visual feedback (out of scope by design).

### File List

- `core/autoload/signal_bus.gd` (modified: `player_health_changed`, `player_died`)
- `core/autoload/game_manager.gd` (modified: sets `is_game_over` on `player_died`)
- `features/player_egg/player.gd` (modified: `stats`, `current_health`, `take_damage()`, `_die()`, input freeze on death)
- `features/player_egg/player_hurt_box.gd` (modified: stops resolving damage after `player_died`)
- `features/player_egg/player_egg.tscn` (modified: Player root `stats` shares the HurtBox sub-resource; explicit `health = 100.0`)
- `_bmad-output/implementation-artifacts/deferred-work.md` (modified: game-over gating resolved; `speed` vs `stats.speed` duplication logged)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified: E1-S5 status; also `completed_points` 5 -> 16, back-filling Stories 1.3 and 1.4 which were never counted)
- `_bmad-output/implementation-artifacts/1-5-player-health-system.md` (this file)
