# Waypoint iOS

Waypoint iOS app (SwiftUI, modular architecture with local SPM packages in `Packages/`).

## Language conventions

- Everything is written in English: code, comments, docs, commit messages, and this file.
- UI text is always localized in Spanish and English. Never hardcode user-facing strings: use String Catalogs (`Localizable.xcstrings`) with keys like `module.tasks.name`, source language `es`, and a translated `en` entry for every key. In views, load with `String(localized:bundle:)` / `Text(_:bundle:)` using `.module` for package resources.

## UI / Design system

All UI must be built with the `Packages/DesignSystem` package: colors `Color.wp*`, fonts `Font.fredoka(...)`/`Font.nunito(...)` and the `Font.wp*` scale, buttons `.buttonStyle(.waypointPrimary/.waypointSecondary/.waypointTertiary)`, cards `.waypointCard()`, `WaypointTag`, `WaveShape` and `Bubble`. No colors or fonts outside the system.

For backgrounds, surfaces, text and outlines always use the **semantic tokens** (`Color.wpBackground`, `.wpSurface`, `.wpSurfaceBorder`, `.wpOutline`, `.wpTextPrimary/Secondary/Tertiary`, `.wpLabelAccent`, `.wpOnSplash`, `.wpButtonShadow`, `.wpCardShadow`, `.wpWaveFill`) — they adapt to light/dark automatically. Fixed palette colors (`.wpOceanBlue`, `.wpSplashSky`, …) are for cases where the color is the same in both modes. The user's theme choice (system/light/dark) lives in `AppearanceSettings` (WaypointCore) and is applied via `preferredColorScheme` in `ContentView`.

## Branding (source: `../waypoint_branding_darkmode/` — light and dark guides)

All UI must follow these brand rules. The identity is the Waypoint whale: friendly, round and optimistic, with a thick navy outline — every element inherits that style.

### Palette (only these colors, none outside this family)

| Name | Hex | Use |
|---|---|---|
| Deep Navy | `#1E2B85` | Outlines and text |
| Ocean Blue | `#2B8CFF` | Primary color (actions, accents) |
| Whale Blue | `#45AEF5` | Whale's body, hover/secondary states |
| Splash Sky | `#8ED8F8` | Details and soft fills |
| Foam | `#F4FBFF` | Light backgrounds |

Supporting tones from the guide: `#DCEBFA` (soft borders), `#4A57A0` (secondary text), `#7B86C2` (tertiary text), `#CFE9FF` (light text on blue), `#EAF5FF` (tag fills).

Approximate usage ratio: Foam 35% · Ocean Blue 30% · Whale Blue 15% · Splash Sky 10% · Deep Navy 10%.

### Dark mode (same family, swapped roles)

| Role | Light | Dark |
|---|---|---|
| Ground | Foam `#F4FBFF` | Midnight `#0E1330` |
| Surface (cards) | White | `#161C40` |
| Surface border | `#DCEBFA` | `#262E5C` |
| Drawn outline | Deep Navy | Splash Sky |
| Primary text | Deep Navy | Near-white `#E8ECFF` |
| Secondary / tertiary text | `#4A57A0` / `#7B86C2` | `#A9B2E0` / `#8891C7` |
| Label accent | Ocean Blue | Whale Blue |
| Button hard shadow | Deep Navy | Near-black `#0A0E24` |
| Card shadow | navy 12% | black 35% |

Dark usage ratio: Midnight 40% · Deep Navy 20% · Ocean Blue 20% · Whale Blue 10% · Splash Sky 10%. Navy text is never used on dark ground; the navy logo ring becomes Splash Sky; bubbles on dark surfaces are outlined in Midnight. Secondary buttons are transparent with a Splash Sky border; tertiary keeps the Splash Sky fill with Midnight text.

### Typography

- **Headlines: Fredoka** (weights 500–700). Always navy or white. Never long all-caps runs.
- **Body: Nunito** (400 for paragraphs, 700–800 for labels and buttons). Minimum 14 pt on screen.
- Scale: H1 48/56 · H2 32/40 · Body 16/26 · Label 13 (uppercase, wide letter-spacing, Ocean Blue). On iOS use the adapted `Font.wp*` scale (34/28/20/16/14/13).
- Both ship as variable TTFs in `Packages/DesignSystem` and register automatically when using `Font.fredoka(...)` / `Font.nunito(...)` (or by calling `WaypointFont.register()`).

### Graphic elements & UI

- Thick navy outlines (2–3 pt) and very rounded corners on cards and controls; pill-shaped buttons and tags (full radius).
- Buttons feel "drawn": 3 pt navy border + hard navy bottom shadow (offset y ~4, no blur) that sinks when pressed.
  - Primary: Ocean Blue fill, white text. Secondary: white fill, navy text. Tertiary: Splash Sky fill, navy text.
- Cards: white fill, 2 pt `#DCEBFA` border, ~20 radius, soft `rgba(30,43,133,0.12)` shadow.
- Motifs: waves (smooth curves) and bubbles — bubbles always with a navy outline.

### Logo

- Always lives inside its blue field, cropped as a circle or rounded square, with a navy border (or Splash Sky/white on dark backgrounds).
- Clear space: at least half its diameter.
- Don't stretch, rotate or recolor the whale; don't remove the navy outline; don't place it on backgrounds that fight with its blue.

### Tone

Calm, friendly and optimistic; ocean metaphors (waves, flow, splash). E.g. "Find your flow, one wave at a time".
