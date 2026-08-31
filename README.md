# Waypoint iOS

Waypoint is a friendly, ocean-themed personal organization app for iOS. Find your flow, one wave at a time. 🐋

## Features

- **Journal** — year and month views with quick entry creation.
- **Tasks & Habits** — modular features to keep track of your day.
- **Reminders** — local notification reminders.
- **Dark mode** — full light/dark support with adaptive brand tokens.
- **Localized** — Spanish and English out of the box.

## Architecture

The app is built with **SwiftUI** and **SwiftData**, following a modular architecture based on local Swift Package Manager packages:

```
waypoint-ios
├── waypoint/               # App target (entry point, module registry, settings)
└── Packages/
    ├── DesignSystem/       # Brand colors, typography (Fredoka & Nunito), buttons, cards, motifs
    ├── WaypointCore/       # Shared models, routing, app-wide settings
    ├── WaypointFeature/    # Journal (year/month views, quick add)
    ├── TasksFeature/       # Tasks module
    └── HabitsFeature/      # Habits module
```

Key conventions:

- All UI is built exclusively with the `DesignSystem` package (semantic color tokens, `Font.wp*` scale, Waypoint button styles and cards).
- User-facing strings live in String Catalogs (`Localizable.xcstrings`) with Spanish as the source language and English translations for every key.
- Features are self-contained packages registered in the app's `ModuleRegistry`.

## Requirements

- Xcode 16 or later
- iOS 18 or later

## Getting started

1. Clone the repository:
   ```sh
   git clone git@github.com:adrianmarrero14/waypoint-ios.git
   ```
2. Open `waypoint.xcodeproj` in Xcode.
3. Select the `waypoint` scheme and run. Local packages resolve automatically.

## Branching model

- `main` — stable, protected branch. Changes land via pull request.
- `develop` — integration branch for day-to-day work.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the [MIT License](LICENSE).
