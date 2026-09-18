---
title: "Egg Defender - User Experience Design"
status: draft
created: 2026-09-18
---

# Egg Defender — EXPERIENCE.md

## Foundation

**Form Factor:** 2D top-down view, single-screen gameplay (no scrolling arena)
**Engine:** Godot 4.2+ with Control nodes for UI
**Visual Identity:** See DESIGN.md for colors, typography, components
**Target Platforms:** PC (primary), Mobile (secondary)

---

## Information Architecture

### Menu Flow

```
┌─────────────────────────────────────────────────────────┐
│                    MAIN MENU                            │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │  PLAY   │  │ UNLOCKS │  │SETTINGS │  │  QUIT   │  │
│  └────┬────┘  └────┬────┘  └────┬────┘  └─────────┘  │
│       │            │            │                       │
└───────┼────────────┼────────────┼───────────────────────┘
        │            │            │
        ▼            ▼            ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ STAGE   │  │ WEAPON  │  │ AUDIO   │
   │ SELECT  │  │ UNLOCK  │  │ DISPLAY │
   │         │  │ SHOP    │  │ CONTROLS│
   └────┬────┘  └─────────┘  └─────────┘
        │
        ▼
   ┌─────────┐
   │RUN START│
   └────┬────┘
        │
        ▼
   ┌─────────┐
   │ GAMEPLAY│ ←── PAUSE MENU (ESC)
   │         │     ┌─────────────┐
   │         │     │ RESUME      │
   │         │     │ SETTINGS    │
   │         │     │ QUIT TO MENU│
   │         │     └─────────────┘
   └────┬────┘
        │ (Death)
        ▼
   ┌─────────┐
   │ RUN END │ ←── Shows stats, coins earned
   │ SUMMARY │
   └────┬────┘
        │
        ▼
   ┌─────────┐
   │UNLOCK   │ ←── Spend coins on meta-upgrades
   │SHOP     │
   └────┬────┘
        │
        ▼
   ┌─────────┐
   │  MENU   │
   └─────────┘
```

### Information Hierarchy

**Priority 1 — Always Visible During Gameplay:**
- Player health (HP bar)
- XP progress (XP bar)
- Current wave number

**Priority 2 — Visible But Subtle:**
- Kill count
- Timer
- Weapon icons with levels

**Priority 3 — On Demand:**
- Score details
- Enemy count remaining
- Boss health bar (boss waves only)

---

## Voice and Tone

### Microcopy Style

| Context | Tone | Example |
|---|---|---|
| Wave Start | Energetic | "WAVE 5 — THEY'RE COMING!" |
| Boss Warning | Dramatic | "BOSS INCOMING" |
| Level Up | Rewarding | "LEVEL UP!" |
| Game Over | Encouraging | "GOOD RUN! +150 coins" |
| Upgrade | Informative | "ACID SPRAY — Damage +20%" |

### Button Labels

| Action | Label |
|---|---|
| Start game | PLAY |
| Pause | PAUSE |
| Resume | RESUME |
| Quit | QUIT TO MENU |
| Confirm | YES |
| Cancel | NO |
| Upgrade | CHOOSE |

---

## Component Patterns

### HUD Layout (In-Game)

```
┌──────────────────────────────────────────────────────────────┐
│ WAVE 5                          ⏱ 12:34              💀 847 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                              │
│                                                              │
│                                                              │
│                        [GAMEPLAY]                            │
│                                                              │
│                                                              │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ ❤️ 75/100  ████████████████████░░░░░░  Lv.5  ████████░░ │ │
│ │                    XP BAR                         WEAPONS│ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**Top Bar (Wave Info):**
- Left: Wave number + boss indicator
- Center: Timer (format: MM:SS)
- Right: Kill count (💀 icon)

**Bottom Bar (Player Info):**
- Left: HP bar + numeric value
- Center: XP bar + level number
- Right: Weapon icons (up to 5 slots)

### Level-Up Screen

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                      LEVEL UP!                              │
│                                                             │
│   ┌───────────┐   ┌───────────┐   ┌───────────┐           │
│   │  [ICON]   │   │  [ICON]   │   │  [ICON]   │           │
│   │  Weapon   │   │  Weapon   │   │  Stat     │           │
│   │  Name     │   │  Name     │   │  Name     │           │
│   │           │   │           │   │           │           │
│   │  Desc     │   │  Desc     │   │  Desc     │           │
│   │           │   │           │   │           │           │
│   │  Lv.2→3   │   │  NEW      │   │  +20%     │           │
│   └───────────┘   └───────────┘   └───────────┘           │
│                                                             │
│              Click or press 1/2/3 to choose                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Behavior:**
- Game pauses when level-up appears
- 3 random options presented
- Click or press 1/2/3 to select
- Selection animates, screen resumes

### Boss Health Bar

```
┌─────────────────────────────────────────────────────────────┐
│                        THE PATRIARCH                        │
│  ████████████████████████████████████████████░░░░░░░░  80% │
└─────────────────────────────────────────────────────────────┘
Position: Top center, below wave info
Visibility: Boss waves only
Animation: Slides in when boss spawns
```

### Pause Menu

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                    ╔═══════════════╗                        │
│                    ║    PAUSED     ║                        │
│                    ╚═══════════════╝                        │
│                                                             │
│                    ┌───────────────┐                        │
│                    │    RESUME     │                        │
│                    └───────────────┘                        │
│                                                             │
│                    ┌───────────────┐                        │
│                    │    SETTINGS   │                        │
│                    └───────────────┘                        │
│                                                             │
│                    ┌───────────────┐                        │
│                    │  QUIT TO MENU │                        │
│                    └───────────────┘                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Game Over Screen

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                       GAME OVER                             │
│                                                             │
│                    Wave: 12 | Time: 15:32                   │
│                    Kills: 847 | Score: 12,450               │
│                                                             │
│                    Coins Earned: +150                       │
│                                                             │
│                    ┌───────────────┐                        │
│                    │   CONTINUE    │                        │
│                    └───────────────┘                        │
│                                                             │
│                    ┌───────────────┐                        │
│                    │  QUIT TO MENU │                        │
│                    └───────────────┘                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## State Patterns

### Game States

| State | HUD | Gameplay | UI |
|---|---|---|---|
| `MAIN_MENU` | Hidden | None | Main menu visible |
| `STAGE_SELECT` | Hidden | None | Stage selection |
| `PLAYING` | Visible | Active | Minimal |
| `PAUSED` | Visible | Frozen | Pause menu overlay |
| `LEVEL_UP` | Visible | Frozen | Upgrade selection |
| `BOSS_WARNING` | Visible | Active | Boss announcement |
| `RUN_END` | Hidden | None | Summary screen |
| `UNLOCK_SHOP` | Hidden | None | Meta-progression |

### Transitions

| From | To | Trigger | Animation |
|---|---|---|---|
| MENU | PLAYING | Click PLAY | Fade to black → Fade in |
| PLAYING | PAUSED | Press ESC | Dim background, slide menu |
| PLAYING | LEVEL_UP | XP threshold | Flash, pause, show cards |
| PLAYING | RUN_END | Player death | Slow-mo → Fade to summary |
| RUN_END | MENU | Click CONTINUE | Fade to menu |

---

## Interaction Primitives

### Movement Input

**PC:**
- WASD / Arrow keys: 8-directional movement
- Gamepad left stick: Analog 8-directional
- No mouse input during gameplay (focus on positioning)

**Mobile:**
- Virtual joystick: Left side of screen
- Touch and drag to move
- Release to stop

### Selection Input

**PC:**
- Mouse click: Select upgrade, menu buttons
- Number keys (1/2/3): Quick-select upgrade
- ESC: Pause/unpause

**Mobile:**
- Tap: Select upgrade, menu buttons
- No keyboard shortcuts

### Feedback

| Action | Visual | Audio |
|---|---|---|
| Take damage | Screen flash red, HP bar shake | Impact sound |
| Kill enemy | Enemy pop animation, XP gem spawn | Pop sound |
| Level up | Screen flash, XP bar pulse | Ascending chime |
| Boss spawn | Screen shake, warning text | Dramatic sting |
| Wave complete | Brief pause, wave counter update | Completion jingle |

---

## Accessibility Floor

### Minimum Requirements

- [ ] All text readable at 16px minimum
- [ ] Color is not sole indicator (icons + text)
- [ ] HUD elements have sufficient contrast (4.5:1 ratio)
- [ ] Pause available at all times
- [ ] No time-sensitive inputs required for menus
- [ ] Gamepad support with remappable controls (PC)

### Colorblind Considerations

- Health bar: Use position + icon, not just color
- XP gems: Different shapes + colors
- Enemy types: Silhouette differences, not just color

---

## Key Flows

### Flow 1: First Run (New Player)

```
START → Main Menu → Click PLAY → Stage Select → Select Stage 1
   → Gameplay begins → Tutorial prompts (move to collect XP)
   → Level up → Choose first upgrade → Continue playing
   → Die at Wave 5 → Game Over → See summary → +50 coins
   → Return to Main Menu
```

**Climax Beat:** First level-up — player realizes they can choose upgrades

### Flow 2: Meta-Progression (Returning Player)

```
START → Main Menu → Click UNLOCKS → Weapon Shop
   → Buy "Acid Spray" for 200 coins → Return to Menu
   → Click PLAY → Select Stage 1 → Choose Acid Spray as starting weapon
   → Gameplay with new weapon → Different build experience
```

**Climax Beat:** Unlocking a new weapon and trying it for the first time

### Flow 3: Boss Wave

```
WAVE 4 COMPLETE → Wave 5 begins → "BOSS INCOMING" warning
   → Boss spawns → Health bar appears → Intense combat
   → Boss defeated → Massive XP drop → Level up × 3
   → Wave 6 begins → Normal enemies return
```

**Climax Beat:** Boss defeat with massive reward explosion

---

## Responsive & Platform

### PC (1280×720+)

- Full HUD visible
- Keyboard/mouse or gamepad
- Windowed or fullscreen

### Tablet (768-1279px)

- Condensed HUD (smaller fonts, tighter spacing)
- Larger touch targets for menus
- Virtual joystick appears

### Mobile (< 768px)

- Minimal HUD (HP/XP only during gameplay)
- Large virtual joystick
- Simplified upgrade cards (tap to select)
- Portrait or landscape support

---

## Anti-Patterns to Avoid

1. **Overloaded HUD** — Don't show everything at once; reveal on context
2. **Tiny Touch Targets** — Minimum 44×44px for mobile buttons
3. **No Pause** — Always allow pausing, even during animations
4. **Unclear Feedback** — Every action needs visual + audio response
5. **Blocking UI** — Menus should not obscure critical gameplay info
