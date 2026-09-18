# Egg Defender - AI Agent Guidelines

## Project Structure

- `core/` — Core systems (autoloads, data resources). **All game-wide logic lives here.**
- `features/` — Gameplay features (player, enemies, weapons, UI). **No direct cross-feature references.**
- `assets/` — Art, audio, and other assets.
- `_bmad-output/` — Planning and implementation artifacts (GDD, architecture, sprints).

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

## Git Workflow

### Branching Strategy

- `main` — Stable, production-ready code. Never commit directly.
- `feature/*` — New features (e.g., `feature/enemy-spawning`, `feature/weapon-system`).
- `fix/*` — Bug fixes (e.g., `fix/projectile-collision`).
- `chore/*` — Tooling, docs, config (e.g., `chore/update-agents-md`).

### Commit Conventions

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation only
- `style` — Formatting, no code change
- `refactor` — Code restructuring
- `test` — Adding tests
- `chore` — Tooling, config, dependencies

**Examples:**
```
feat(weapons): add acid spray cone weapon
fix(enemies): prevent swarmspawn collision overlap
docs(gdd): update weapon evolution table
chore(godot): update project to 4.2.1
```

### Atomic Commits

- One logical change per commit
- Each commit should compile and run
- Don't mix formatting changes with logic changes
- Don't commit broken code (use `git stash` if needed)

### Workflow

```bash
# Start new feature
git checkout main
git pull
git checkout -b feature/your-feature-name

# Work, commit atomically
git add <files>
git commit -m "feat(scope): description"

# Push and create PR
git push -u origin feature/your-feature-name
```

## Technology Stack

- **Engine:** Godot 4.2+ (GL Compatibility renderer)
- **Language:** GDScript 4.x
- **Display:** 1280×720, canvas_items stretch mode
- **Renderer:** GL Compatibility, nearest texture filter

## Key Documents

| Document | Location | Purpose |
|---|---|---|
| GDD | `_bmad-output/planning-artifacts/gdd.md` | Game design specification |
| Architecture | `_bmad-output/planning-artifacts/game-architecture.md` | Technical design |
| UX Design | `_bmad-output/planning-artifacts/ux-design/` | UI/UX specifications |
| Epics | `_bmad-output/planning-artifacts/epics/epics-and-stories.md` | Sprint breakdown |
| Sprint Status | `_bmad-output/implementation-artifacts/sprint-status.yaml` | Current sprint tasks |
