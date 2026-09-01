# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Fuzzy Barnacle" is an iOS app (SwiftUI + SwiftData), deployment target iOS 26.5. It is a **generative art piece**: a body of water, and the lives on and in it.

- **The water**: a tide drives the motes, the light shafts, and the plume sway. On the water's own 1440 s clock there is a day and a night (`ContentView.daylight`); in the night the colony is lit by its own faint glow, and the hand is the only lamp there is.
- **The colony**: barnacles settle on a tap (persisted as `Barnacle` in SwiftData), accrete to adult size, and age. Holding one prys it off, leaving a `Ghost` — a trace that holds, then dissolves and is pruned.
- **The passing**: five "drifters" ride the current and never settle (`drifterRawPosition` — deterministic from the water's clock, stored nowhere).
- **The storm**: rare weather — two incommensurate currents must align while a slow season is willing (`ContentView.storm`); then the current surges, rain falls, the light dims under the cloud, the colony tucks in, and when it passes the water does not remember it.
- **The hand**: the press gesture parts the water, scatters the quick ones, and in the night / storm reads as a lamp.

`README.md` is the latest entry of a trail, written in the artist's first-person voice, with screenshots in `screenshots/`; earlier entries are kept in `readme-archive/`. Every README page (live and archived) opens with the verbatim installation-statement block — keep it when archiving.

## Layout

- `Fuzzy Barnacle/` — app target source (note the space in the directory name; the Swift module is `Fuzzy_Barnacle`, hence `@testable import Fuzzy_Barnacle` in tests)
- `Fuzzy Barnacle.xcodeproj` — single project; one scheme: `Fuzzy Barnacle`; targets: `Fuzzy Barnacle`, `Fuzzy BarnacleTests` (Swift Testing), `Fuzzy BarnacleUITests` (XCUITest)
- Bundle IDs use the `com.gk.` prefix

## Commands

All commands run from the repo root; the project path contains a space, so quote it.

```sh
# Build (Release is the default config; use -configuration Debug for faster iteration)
xcodebuild -project "Fuzzy Barnacle.xcodeproj" -scheme "Fuzzy Barnacle" \
  -destination 'generic/platform=iOS Simulator' build

# Run all unit tests (pick a concrete simulator from: xcrun simctl list devices available)
xcodebuild -project "Fuzzy Barnacle.xcodeproj" -scheme "Fuzzy Barnacle" \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test (class/method in Fuzzy_BarnacleTests)
xcodebuild -project "Fuzzy Barnacle.xcodeproj" -scheme "Fuzzy Barnacle" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:'Fuzzy BarnacleTests/Fuzzy_BarnacleTests/example' test
```

Prefer the Xcode app / simulator for interactive work; `xcodebuild` is for scriptable builds and tests.
