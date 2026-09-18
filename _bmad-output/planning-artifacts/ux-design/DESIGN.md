---
title: "Egg Defender - Visual Identity Design"
status: draft
created: 2026-09-18
---

# Egg Defender — DESIGN.md

## Brand & Style

**Tone:** Absurd, humorous, lighthearted. Think "science class meets arcade chaos."

**Visual Language:** Cartoon cellular biology. Clean shapes, exaggerated proportions, expressive animations. Not realistic — playful and approachable.

**Inspiration:** Osmosis Jones aesthetic meets Vampire Survivors gameplay clarity.

---

## Colors

### Primary Palette

| Token | Hex | Usage |
|---|---|---|
| `egg.white` | `#F5F5F0` | Egg shell, player body |
| `egg.yolk` | `#FFD93D` | Player center, health bar fill |
| `sperm.blue` | `#4ECDC4` | Enemy body, primary threat color |
| `sperm.tail` | `#45B7D1` | Enemy movement trails |

### Accent Colors

| Token | Hex | Usage |
|---|---|---|
| `xp.blue` | `#00D4FF` | XP gems, level-up effects |
| `xp.green` | `#7FFF00` | Uncommon XP gems |
| `xp.red` | `#FF6B6B` | Rare XP gems, danger |
| `coin.gold` | `#FFD700` | Currency, meta-progression |

### UI Colors

| Token | Hex | Usage |
|---|---|---|
| `ui.bg` | `#1A1A2E` | Menu backgrounds, overlays |
| `ui.panel` | `#16213E` | HUD panels, cards |
| `ui.border` | `#0F3460` | Borders, separators |
| `ui.text` | `#E8E8E8` | Primary text |
| `ui.text.dim` | `#8B8B8B` | Secondary text |
| `ui.success` | `#4CAF50` | Positive feedback |
| `ui.danger` | `#FF5252` | Damage, warnings |

### Semantic Colors

| Token | Hex | Usage |
|---|---|---|
| `health.full` | `#4CAF50` | Health bar at 100% |
| `health.mid` | `#FFC107` | Health bar at 50% |
| `health.low` | `#FF5252` | Health bar below 25% |
| `wave.incoming` | `#FF9800` | Wave announcement |
| `wave.boss` | `#9C27B0` | Boss wave indicator |

---

## Typography

### Headers

| Token | Font | Size | Weight | Usage |
|---|---|---|---|---|
| `heading.xl` | System Sans | 48px | Bold | Title screen |
| `heading.lg` | System Sans | 32px | Bold | Wave announcements |
| `heading.md` | System Sans | 24px | SemiBold | Section headers |
| `heading.sm` | System Sans | 18px | Medium | Card titles |

### Body

| Token | Font | Size | Weight | Usage |
|---|---|---|---|---|
| `body.lg` | System Sans | 18px | Regular | Upgrade descriptions |
| `body.md` | System Sans | 14px | Regular | HUD labels |
| `body.sm` | System Sans | 12px | Regular | Secondary info |

### Monospace

| Token | Font | Size | Weight | Usage |
|---|---|---|---|---|
| `mono.md` | Monospace | 16px | Regular | Score, timer |
| `mono.sm` | Monospace | 12px | Regular | Debug info |

---

## Layout & Spacing

### Screen Zones

```
┌─────────────────────────────────────────┐
│  [TOP-LEFT]        [TOP-CENTER]        [TOP-RIGHT]  │
│  Wave Info         Timer/Score         Minimap*     │
│                                                   │
│                                                   │
│              [CENTER - GAMEPLAY]                  │
│              Player + Enemies                     │
│                                                   │
│                                                   │
│  [BOTTOM-LEFT]    [BOTTOM-CENTER]    [BOTTOM-RIGHT] │
│  HP/XP Bars       Level Up Prompt    Weapon Icons  │
└─────────────────────────────────────────┘
```

### Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `space.xs` | 4px | Tight spacing |
| `space.sm` | 8px | Element gaps |
| `space.md` | 16px | Section padding |
| `space.lg` | 24px | Panel padding |
| `space.xl` | 32px | Major sections |

### HUD Margins

| Edge | Margin | Content |
|---|---|---|
| Top | 16px | Wave info, score |
| Bottom | 16px | HP/XP bars, weapons |
| Left | 16px | Health, XP progress |
| Right | 16px | Kill count, timer |

---

## Elevation & Depth

### Layer Hierarchy

| Layer | Z-Index | Content |
|---|---|---|
| Background | 0 | Arena floor, environment |
| Gameplay | 10 | Enemies, projectiles, XP gems |
| Player | 20 | Player character |
| Effects | 30 | Particles, screen effects |
| HUD | 100 | In-game UI overlay |
| Menus | 200 | Pause, upgrade selection |
| Overlay | 300 | Transitions, fade effects |

### HUD Panel Styling

```css
/* Semi-transparent panel */
background: rgba(26, 26, 46, 0.85)
border: 1px solid rgba(15, 52, 96, 0.5)
border-radius: 8px
backdrop-filter: blur(4px)
```

---

## Shapes

### UI Elements

| Element | Radius | Style |
|---|---|---|
| Buttons | 6px | Rounded rectangle |
| Panels | 8px | Rounded rectangle |
| Health bars | 4px | Rounded rectangle |
| Icons | 0px | Square (pixel art) |
| Portraits | 50% | Circle |

### Gameplay Elements

| Element | Shape | Style |
|---|---|---|
| Player (Egg) | Oval | Squash/stretch on movement |
| Enemies (Sperm) | Teardrop | Tail follows movement |
| XP Gems | Diamond | Pulsing glow |
| Projectiles | Circle/Cone | Varies by weapon |

---

## Components

### Buttons

| Type | Size | Colors | States |
|---|---|---|---|
| Primary | 200x60px | `egg.yolk` bg, dark text | Normal, Hover, Pressed, Disabled |
| Secondary | 160x48px | `ui.panel` bg, `ui.text` | Normal, Hover, Pressed |
| Icon | 48x48px | Transparent bg | Normal, Hover, Selected |

### Health Bar

```
┌────────────────────────────────────┐
│ ████████████████░░░░░░  75/100     │
└────────────────────────────────────┘
Width: 200px | Height: 20px
Fill color: Dynamic (green → yellow → red)
Background: rgba(0, 0, 0, 0.5)
Border: 2px solid rgba(255, 255, 255, 0.2)
```

### XP Bar

```
┌────────────────────────────────────┐
│ ██████████████████████████  Lv.5  │
└────────────────────────────────────┘
Width: Full screen width | Height: 12px
Fill color: `xp.blue` with pulse animation on level up
Position: Bottom edge of screen
```

### Weapon Icon

```
┌─────────┐
│  [IMG]  │  48x48px
│   Lv.3  │  Level indicator
└─────────┘
Background: `ui.panel`
Border: 2px solid `ui.border`
Glow: On active weapon
```

### Upgrade Card

```
┌─────────────────────────┐
│  [WEAPON ICON]          │
│  Weapon Name            │
│  ─────────────────────  │
│  Description of the     │
│  upgrade effect         │
│                         │
│  Lv.2 → Lv.3           │
└─────────────────────────┘
Width: 220px | Height: 280px
Background: `ui.panel`
Border: 2px solid `ui.border`
Hover: Glow effect + scale(1.05)
Selected: `egg.yolk` border
```

### Wave Announcement

```
        ╔═══════════════════╗
        ║    WAVE 5         ║
        ║   BOSS INCOMING   ║
        ╚═══════════════════╝
Size: Full width, centered
Animation: Slide in → Hold 2s → Fade out
Background: Semi-transparent overlay
```

---

## Do's and Don'ts

### Do

- Keep HUD elements semi-transparent to avoid blocking gameplay
- Use consistent color coding (blue = XP, gold = coins, red = danger)
- Animate UI elements for feedback (bounces, pulses, slides)
- Ensure text is readable against busy backgrounds
- Use icons alongside text for quick recognition

### Don't

- Overload screen with UI elements
- Use small touch targets (< 44px) on mobile
- Place critical info behind menus
- Use colors that blend with gameplay
- Ignore accessibility (colorblind modes, text scaling)

---

## Responsive Breakpoints

| Breakpoint | Width | Adaptations |
|---|---|---|
| Desktop | 1280px+ | Full HUD, side panels |
| Tablet | 768-1279px | Condensed HUD, larger buttons |
| Mobile | < 768px | Minimal HUD, touch-friendly |

---

## Animation Principles

1. **Bounce** — UI elements overshoot and settle (0.2s)
2. **Pulse** — Important elements gently scale (loop)
3. **Shake** — Damage feedback, screen shake (0.1s)
4. **Fade** — Transitions between states (0.3s)
5. **Slide** — Menu transitions (0.25s)
