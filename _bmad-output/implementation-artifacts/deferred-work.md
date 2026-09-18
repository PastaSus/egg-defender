# Deferred Work Ledger

## Deferred from: code review of 1-2-arena-boundary-collision (2026-09-18)

- No floor/background visual on `ArenaBoundary` (`features/gameplay/arena.tscn`) — walls are invisible collision-only geometry. Pre-existing: no art pipeline exists in the project yet (same rationale as Story 1.1's textureless Sprite2D); not required by any AC or task.
- Concave-corner collision behavior (diagonal movement aimed directly into a wall intersection in `features/gameplay/arena.tscn`) wasn't explicitly re-tested beyond the general "can't leave arena" and single-wall-diagonal-slide checks. Low-risk: walls use the standard safe Godot pattern (overlapping static colliders at corners, no gaps). Flagged for due diligence in a future test pass.

## Deferred from: code review of 1-1-player-movement (2026-09-18)

- Arrow keys are double-bound to `move_*` (this story) and Godot's built-in `ui_up`/`ui_down`/`ui_left`/`ui_right` actions in `project.godot`. Once any UI has focus (pause menu, level-up cards, main menu), arrow-key presses will simultaneously move the player and shift UI focus/navigation. Logged for Epic 5 (UI & Menus): decide there whether to unbind arrows from `ui_*` or gate `move_*` input by game state.
- No gamepad/joypad events bound on `move_*` actions in `project.godot` (only keyboard); the `deadzone: 0.5` field is currently meaningless since no analog input is bound. Pre-existing scope boundary — gamepad support has no story yet in the epics backlog.
- `velocity = input_vector.normalized() * speed` in `features/player_egg/player.gd:9` re-normalizes an already magnitude-clamped `Input.get_vector()` result, forcing full speed regardless of input magnitude. Harmless for keyboard-only input (always magnitude 0 or 1); only matters once gamepad/analog input is added.
- No explicit `collision_layer`/`collision_mask` set on the player (`features/player_egg/player_egg.tscn`); relies on Godot defaults. No other physics bodies exist yet (arena boundaries land in E1-S2, enemies in E1-S3) to define a layer convention against.
- Collision shape radius (16px) on the player (`features/player_egg/player_egg.tscn`) is a guess with no player art yet to validate it against. No art assets exist in the project yet.
