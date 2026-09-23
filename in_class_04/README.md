# Fantasy Spellbook

A Flutter app for In-Class Activity 03 (*The Cyber-Tactile Control Studio*),
re-themed as an enchanted **Fantasy Spellbook**. Tap glowing rune buttons that
physically sink under your finger, watch your **Spells Cast** counter climb, and
channel **mana** with a slider — push it to 80% or higher and the whole spellbook
surges.

## Persona

| Original starter | Spellbook version |
| --- | --- |
| Cyber-Tactile Control Studio | Fantasy Spellbook |
| TURBO (⚡ amber) | **FIREBALL** (fire icon, ember orange) |
| SHIELD (🛡 teal) | **FROST WARD** (snowflake, icy blue) |
| RADAR (📡 purple) | **SCRYING** (eye, arcane purple) |
| LAUNCH (🚀 red) | **SUMMON** (wand, gold) |
| Total Taps / Energy Level | **Spells Cast** / **Mana Level** |
| Power Calibration slider | **Mana Channeling** slider |

## Milestones

### Milestone 1 — Custom Theming & Persona
- Custom Material 3 `ThemeData` seeded from arcane purple (`ColorScheme.fromSeed`)
  with a serif font for an old-book feel.
- **Midnight Grimoire** (dark) and **Aged Parchment** (light) palettes, switchable
  from the sun/moon button in the app bar.
- All four `TactileButton`s given new icons, labels, accent colors, and spell
  names; the status banner reads e.g. `STATUS: FIREBALL CAST`.

### Milestone 2 — Interactive Feedback (80% threshold)
- `isSurging = powerLevel >= 80` is checked when the background color is chosen.
- At 80% or more mana the background fades (via `AnimatedContainer`) to a deep
  crimson (dark) or warm amber (light), the mana readout and slider turn ember
  orange, and a **MANA SURGE** warning appears under the status line.
- Dropping back below 80% restores the normal palette instantly.

### Milestone 3 — README
This file.

## Concepts Practiced
- `StatefulWidget` and `setState()` for the counter, status text, and slider
- `GestureDetector` (`onTapDown` / `onTapUp` / `onTapCancel`) for the press effect
- Dual opposing `BoxShadow`s for neomorphic 3D depth
- Passing theme state and callbacks from parent to child widgets
- Extracting a reusable custom widget (`TactileButton`)

## How to Run

```bash
flutter pub get
flutter run
```
