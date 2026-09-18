# Egg Defender — Epics & Stories

**Project:** Egg Defender
**Total Epics:** 8
**MVP Stories:** 42
**Estimated Sprints:** 6-8 (2-week sprints)

---

## Epic 1: Core Foundation (P0)

**Goal:** Get a movable character on screen with basic auto-attack
**Priority:** P0 — Must Have
**Sprint:** 1

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E1-S1 | Player movement (WASD/arrows) with 8-directional | 3 | Ready |
| E1-S2 | Player collision with arena boundaries | 2 | Ready |
| E1-S3 | Basic enemy (SpermCell) that charges at player | 5 | Ready |
| E1-S4 | Enemy-player collision (damage on contact) | 3 | Ready |
| E1-S5 | Player health system (take damage, die) | 3 | Ready |
| E1-S6 | Basic auto-attack weapon (Yolk Spit) | 5 | Ready |
| E1-S7 | Weapon fires at nearest enemy automatically | 3 | Ready |
| E1-S8 | Projectile hits enemy (damage application) | 2 | Ready |
| E1-S9 | Enemy death (HP reaches 0, despawn) | 2 | Ready |

**Total Points:** 28

### Acceptance Criteria

- [ ] Player moves smoothly in 8 directions
- [ ] Enemies spawn and charge toward player
- [ ] Player takes damage on enemy contact
- [ ] Player dies when HP reaches 0
- [ ] Weapon auto-fires at nearest enemy
- [ ] Projectiles damage and kill enemies
- [ ] Runs at 60fps with 50+ enemies

---

## Epic 2: Wave System (P0)

**Goal:** Progressive difficulty with wave announcements
**Priority:** P0 — Must Have
**Sprint:** 1-2

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E2-S1 | Wave spawner system (timed enemy spawns) | 5 | Ready |
| E2-S2 | Wave counter display | 2 | Ready |
| E2-S3 | Wave completion detection (all enemies dead) | 3 | Ready |
| E2-S4 | Wave announcement UI ("WAVE 5") | 3 | Ready |
| E2-S5 | Difficulty scaling per wave | 5 | Ready |
| E2-S6 | Enemy type variety (add SwarmSperm, FatSperm) | 5 | Ready |
| E2-S7 | Boss wave every 5 waves | 8 | Ready |
| E2-S8 | Boss health bar display | 3 | Ready |
| E2-S9 | Boss defeat detection | 2 | Ready |

**Total Points:** 36

### Acceptance Criteria

- [ ] Waves spawn enemies at increasing rate
- [ ] Wave number displayed on HUD
- [ ] Next wave starts after clearing current
- [ ] Difficulty increases per wave
- [ ] Boss appears every 5 waves
- [ ] Boss has unique mechanics
- [ ] Wave announcement appears between waves

---

## Epic 3: XP & Leveling (P0)

**Goal:** Collect XP, level up, choose upgrades
**Priority:** P0 — Must Have
**Sprint:** 2

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E3-S1 | XP gems drop from enemies | 3 | Ready |
| E3-S2 | XP gem collection (magnet range) | 3 | Ready |
| E3-S3 | XP bar UI display | 2 | Ready |
| E3-S4 | Level-up detection (XP threshold) | 2 | Ready |
| E3-S5 | Level-up screen (3 upgrade choices) | 8 | Ready |
| E3-S6 | Weapon upgrade selection | 5 | Ready |
| E3-S7 | Stat upgrade selection (health, speed, etc.) | 3 | Ready |
| E3-S8 | New weapon acquisition | 5 | Ready |
| E3-S9 | Upgrade animation and feedback | 3 | Ready |

**Total Points:** 34

### Acceptance Criteria

- [ ] Enemies drop XP gems on death
- [ ] Player collects gems within range
- [ ] XP bar fills and shows progress
- [ ] Level-up pauses game
- [ ] 3 random upgrade options shown
- [ ] Upgrades apply correctly
- [ ] Visual feedback on upgrade selection

---

## Epic 4: Weapon System (P0)

**Goal:** Multiple weapon types with upgrades and evolutions
**Priority:** P0 — Must Have
**Sprint:** 2-3

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E4-S1 | Weapon slot system (up to 5) | 3 | Ready |
| E4-S2 | Weapon base class and inheritance | 5 | Ready |
| E4-S3 | Shell Fragment (AoE weapon) | 3 | Ready |
| E4-S4 | Mucus Trail (DOT weapon) | 3 | Ready |
| E4-S5 | Acid Spray (Cone weapon) | 3 | Ready |
| E4-S6 | Nucleus Beam (Piercing weapon) | 3 | Ready |
| E4-S7 | Flagellum Whip (Melee weapon) | 3 | Ready |
| E4-S8 | Membrane Shield (Defensive weapon) | 5 | Ready |
| E4-S9 | Weapon upgrade levels (1-5) | 5 | Ready |
| E4-S10 | Weapon evolution system | 8 | Ready |
| E4-S11 | Weapon visual effects | 3 | Ready |

**Total Points:** 44

### Acceptance Criteria

- [ ] 7 weapons implemented with unique mechanics
- [ ] Weapons upgrade from level 1-5
- [ ] 3 evolution combinations work
- [ ] Each weapon has distinct visual
- [ ] Weapon slots limited to 5
- [ ] Weapon switching works

---

## Epic 5: UI & Menus (P1)

**Goal:** Complete menu flow with HUD
**Priority:** P1 — Should Have
**Sprint:** 3

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E5-S1 | Main menu screen | 3 | Ready |
| E5-S2 | In-game HUD (HP, XP, wave, timer) | 5 | Ready |
| E5-S3 | Pause menu (resume, settings, quit) | 3 | Ready |
| E5-S4 | Game over screen (stats summary) | 3 | Ready |
| E5-S5 | Level-up UI (upgrade cards) | 5 | Ready |
| E5-S6 | Boss health bar UI | 2 | Ready |
| E5-S7 | Wave announcement UI | 2 | Ready |
| E5-S8 | Score display and tracking | 2 | Ready |
| E5-S9 | Timer display | 1 | Ready |

**Total Points:** 26

### Acceptance Criteria

- [ ] Main menu navigable
- [ ] HUD shows all critical info
- [ ] Pause works correctly
- [ ] Game over shows run stats
- [ ] Level-up UI is clear and responsive
- [ ] All UI elements are readable

---

## Epic 6: Meta-Progression (P1)

**Goal:** Permanent upgrades between runs
**Priority:** P1 — Should Have
**Sprint:** 4

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E6-S1 | Coin currency system | 3 | Ready |
| E6-S2 | Coins earned per run (based on performance) | 2 | Ready |
| E6-S3 | Save/load meta data (FileAccess) | 5 | Ready |
| E6-S4 | Unlock shop UI | 5 | Ready |
| E6-S5 | Permanent stat upgrades (HP, speed, etc.) | 5 | Ready |
| E6-S6 | Weapon unlock system | 5 | Ready |
| E6-S7 | Starting weapon selection | 3 | Ready |
| E6-S8 | Unlock animations and feedback | 3 | Ready |

**Total Points:** 31

### Acceptance Criteria

- [ ] Coins persist between runs
- [ ] Save/load works correctly
- [ ] Unlock shop shows available upgrades
- [ ] Purchases apply permanently
- [ ] New weapons unlock correctly
- [ ] Starting weapon can be changed

---

## Epic 7: Content & Juice (P1)

**Goal:** Polish, effects, and game feel
**Priority:** P1 — Should Have
**Sprint:** 4-5

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E7-S1 | Particle effects (enemy death, XP collect) | 5 | Ready |
| E7-S2 | Screen shake on big hits | 2 | Ready |
| E7-S3 | Damage numbers display | 3 | Ready |
| E7-S4 | Enemy death animations | 3 | Ready |
| E7-S5 | Player hurt animation/flash | 2 | Ready |
| E7-S6 | Level-up flash effect | 2 | Ready |
| E7-S7 | Boss spawn warning effect | 2 | Ready |
| E7-S8 | Arena visual themes (3 variants) | 5 | Ready |
| E7-S9 | Background music integration | 3 | Ready |
| E7-S10 | SFX integration (attacks, pickups, UI) | 5 | Ready |

**Total Points:** 32

### Acceptance Criteria

- [ ] Particles on enemy death
- [ ] Screen shake feels impactful
- [ ] Damage numbers visible
- [ ] Animations are smooth
- [ ] Audio enhances game feel
- [ ] Visual themes work

---

## Epic 8: Mobile Port (P2)

**Goal:** Touch controls for mobile
**Priority:** P2 — Nice to Have
**Sprint:** 6

### Stories

| ID | Story | Points | Status |
|---|---|---|---|
| E8-S1 | Virtual joystick implementation | 5 | Ready |
| E8-S2 | Touch UI scaling | 3 | Ready |
| E8-S3 | Touch-friendly upgrade selection | 3 | Ready |
| E8-S4 | Performance optimization for mobile | 5 | Ready |
| E8-S5 | Mobile-specific UI layout | 3 | Ready |

**Total Points:** 19

### Acceptance Criteria

- [ ] Virtual joystick works
- [ ] UI scales to mobile screens
- [ ] Touch targets are 44px+
- [ ] 30fps minimum on mobile
- [ ] No UI overlap issues

---

## Sprint Breakdown

### Sprint 1 (Weeks 1-2): Core Foundation + Wave System Start
**Stories:** E1-S1 to E1-S9, E2-S1 to E2-S3
**Points:** 28 + 10 = 38
**Goal:** Playable prototype with movement, enemies, and basic waves

### Sprint 2 (Weeks 3-4): Wave System + XP & Leveling
**Stories:** E2-S4 to E2-S9, E3-S1 to E3-S9
**Points:** 26 + 34 = 60
**Goal:** Complete wave system with level-up mechanics

### Sprint 3 (Weeks 5-6): Weapon System + UI
**Stories:** E4-S1 to E4-S11, E5-S1 to E5-S9
**Points:** 44 + 26 = 70
**Goal:** All weapons implemented, complete UI

### Sprint 4 (Weeks 7-8): Meta-Progression + Juice Start
**Stories:** E6-S1 to E6-S8, E7-S1 to E7-S5
**Points:** 31 + 14 = 45
**Goal:** Save system, unlock shop, visual polish

### Sprint 5 (Weeks 9-10): Content & Juice Complete
**Stories:** E7-S6 to E7-S10
**Points:** 18
**Goal:** Full polish, audio, arena themes

### Sprint 6 (Weeks 11-12): Mobile + Final Polish
**Stories:** E8-S1 to E8-S5
**Points:** 19
**Goal:** Mobile port, final testing, release prep

---

## Definition of Done

- [ ] Code compiles and runs without errors
- [ ] Feature works as described in acceptance criteria
- [ ] No performance regression (maintains 60fps target)
- [ ] SignalBus communication used (no direct references)
- [ ] Code follows project conventions (typed variables, class names)
- [ ] Tested on target platform
