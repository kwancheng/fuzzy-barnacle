# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Fuzzy Barnacle" is an iOS app (SwiftUI + SwiftData), deployment target iOS 26.5. It is a fresh Xcode template project: the app code is still the default boilerplate (a `NavigationSplitView` list of SwiftData `Item` records with add/delete), with no custom features yet. The app's intent is not yet defined in the repo — confirm the product direction with the user before assuming requirements.

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
