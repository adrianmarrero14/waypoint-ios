# Contributing to Waypoint iOS

Thanks for your interest in contributing! This document describes the conventions used in this repository.

## Branching model

- `main` is the stable branch and is protected: changes land only through pull requests.
- `develop` is the integration branch. Branch off `develop` for new work:
  - `feature/<short-description>` for features
  - `fix/<short-description>` for bug fixes

Open pull requests against `develop`; `develop` is merged into `main` for releases.

## Conventions

- **Language**: everything is written in English — code, comments, docs, and commit messages.
- **Localization**: UI text is always localized in Spanish and English. Never hardcode user-facing strings; use String Catalogs (`Localizable.xcstrings`) with source language `es` and an `en` translation for every key.
- **Design system**: all UI must be built with the `Packages/DesignSystem` package (semantic color tokens, `Font.fredoka`/`Font.nunito`, Waypoint button styles, cards, tags). No colors or fonts outside the system.
- **Commits**: use concise, imperative messages with a conventional prefix, e.g. `feat: add habit streaks`, `fix: correct journal month layout`, `refactor: extract entry row view`.

## Pull requests

1. Make sure the project builds and tests pass in Xcode.
2. Keep PRs focused — one topic per pull request.
3. Describe what changed and why, and add screenshots for UI changes (light and dark mode).
