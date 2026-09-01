# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Fuzzy Barnacle" is an iOS app (SwiftUI + SwiftData), deployment target iOS 26.5. It is a **generative art piece**: a body of water, and the lives on and in it.

- **The water**: a tide drives the motes, the light shafts, and the plume sway. On the water's own 1440 s clock there is a day and a night (`ContentView.daylight`); in the night the colony is lit by its own faint glow, and the hand is the only lamp there is.
- **The colony**: barnacles settle on a tap (persisted as `Barnacle` in SwiftData), accrete to adult size, and age. Holding one prys it off, leaving a `Ghost` — a trace that holds, then dissolves and is pruned.
- **The passing**: five "drifters" ride the current and never settle (`drifterRawPosition` — deterministic from the water's clock, stored nowhere).
- **The storm**: rare weather — two incommensurate currents must align while a slow season is willing (`ContentView.storm`); then the current surges, rain falls, the light dims under the cloud, the colony tucks in, and when it passes the water does not remember it.
- **The hand**: the press gesture parts the water, scatters the quick ones, and in the night / storm reads as a lamp. A *moving* hand also makes the water's own small light along its path — the **wake** (`ContentView.wakeStrength`/`wakeFade`, a brief ribbon that shows where the light from above is gone, brightest in the night and under the storm's cloud) — which the water forgets, the way it forgets everything. A still hand is only the lamp.
- **The voice**: the piece's own motion, *heard* (`Voice.swift`, `WaterVoice` — an `AVAudioSourceNode` that draws noise shaped by the same functions that move the water; nothing is a recording). The **murmur** is the tide's *turning* (`ContentView.murmurGain` — the change of the current's strength, not its strength, so the slack water is quiet and the flood and ebb speak), the **rain** falls only with the storm (`ContentView.rainGain`, a little less in the night), a moving hand **swishes** (`ContentView.handSwish` — the heard answer to the wake, which lingers a moment, then the water is quiet again), and the colony **tucks in** when the storm closes it (`ContentView.tuckGain` — the closing of the shells, a granular voice made of a population of eight clickers in `WaterVoice`: each a short gated mid-band sine at its own pace and pitch, the closings sparse and far at the storm's stirring, a bed of closings at its full, quiet where there is no storm). A still hand makes no swish, the way it makes no wake. The caption says "the water is quiet" at the slack (`quietLine`, shown on a 5 s caption cadence so the ~12 s slack window is not missed). The voice eases toward the piece's state a few times a second via `speak()` (a 0.25 s `.task` loop); the swish, like the hand's other answers, runs on world time, not the shifted clock. The voice's 8 s level log also reports the tuck's gain (`fb voice: level X (tuck Y)`).

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
