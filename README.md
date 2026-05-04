# MV vs MVVM vs TCA for SwiftUI

This repository is a practical iOS proof of concept comparing three ways to build the same SwiftUI feature:

- **MVVM** with `ObservableObject` and `@Published`
- **MV** with Swift's Observation framework and `@Observable`
- **TCA** with Point-Free's Composable Architecture 1.x

The goal is to answer a focused question: **is MVVM still the best default in the SwiftUI Observation era, or should a team prefer MV or TCA?**

## What It Builds

All three app targets implement the same "GitHub User Explorer" feature set:

- Debounced GitHub user search
- Loading, empty, error, and success states
- User detail navigation with profile and repository loading
- Parallel detail requests for profile and top repositories
- Favorite and unfavorite actions from list and detail screens
- Persisted favorites using `UserDefaults`
- A favorites tab shared across the app experience

The apps use the unauthenticated GitHub REST API, so GitHub search rate limits can apply during manual testing. Unit tests mock the network.

## Recommendation

For this app shape, the comparison recommends **MV with `@Observable` as the default architecture**.

MV keeps the implementation close to SwiftUI, has similar code size to MVVM, builds fastest in the measured runs, and avoids the dependency and learning overhead of TCA. TCA remains the strongest option when exact state-transition testing, effect cancellation, and cross-feature coordination matter more than compile time and ceremony.

See [COMPARISON.md](COMPARISON.md) for the full scorecard and build measurements.

## Project Structure

```text
TCA-iOS/
|-- Shared/        # Models, networking, persistence, design-system helpers
|-- MVVM/          # MVVM app implementation
|-- MV/            # @Observable model app implementation
|-- TCA/           # Composable Architecture app implementation
|-- MVVMTests/     # MVVM parity tests
|-- MVTests/       # MV parity tests
|-- TCATests/      # TCA parity tests
|-- project.yml    # XcodeGen project definition
|-- COMPARISON.md  # Results and recommendation
|-- PLAN.md        # Original POC plan and feature spec
`-- STANDARDS.md   # Code standards used for a fair comparison
```

## Targets And Schemes

| Scheme | Architecture | Notes |
|---|---|---|
| `MVVMApp` | MVVM | `ObservableObject`, `@Published`, initializer injection |
| `MVApp` | MV | `@Observable`, plain stored state, initializer injection |
| `TCAApp` | TCA | `@Reducer`, `@ObservableState`, `TestStore`, TCA dependencies |

Each scheme builds an independent app target and runs its matching unit test target.

## Requirements

- Xcode 16 or newer
- iOS 17.0 or newer simulator/runtime
- Swift 6.0
- Swift Package Manager
- XcodeGen, only if regenerating the project from `project.yml`

The checked-in `TCA-iOS.xcodeproj` can be opened directly.

## Getting Started

Open the project:

```sh
open TCA-iOS.xcodeproj
```

Then choose one of the app schemes:

- `MVVMApp`
- `MVApp`
- `TCAApp`

Run with `Cmd+R` or test with `Cmd+U`.

If you edit `project.yml`, regenerate the Xcode project with:

```sh
xcodegen generate
```

## Running Tests From Terminal

Use any available iOS simulator destination on your machine:

```sh
xcodebuild test \
  -project TCA-iOS.xcodeproj \
  -scheme MVApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Swap the scheme to run another architecture:

```sh
xcodebuild test -project TCA-iOS.xcodeproj -scheme MVVMApp -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild test -project TCA-iOS.xcodeproj -scheme MVApp   -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild test -project TCA-iOS.xcodeproj -scheme TCAApp  -destination 'platform=iOS Simulator,name=iPhone 16'
```

If `iPhone 16` is not installed locally, list available simulators with:

```sh
xcrun simctl list devices available
```

## Comparison Snapshot

| Axis | MVVM | MV | TCA |
|---|---:|---:|---:|
| App source lines | 512 | 515 | 605 |
| Test source lines | 446 | 446 | 387 |
| Tests passing | 14 | 14 | 14 |
| Measured clean build average | 29.7s | 25.7s | 125.0s |
| Scorecard total | 36 | 39 | 29 |

The numbers above come from the completed POC and are explained in [COMPARISON.md](COMPARISON.md).

## Notes

- `Shared/` is included directly in all three app targets to keep the comparison flat.
- MVVM and MV use plain protocol-based dependency injection.
- TCA uses `@Dependency` and `TestStore`.
- The project compiles with strict concurrency set to `complete`.
- A local `Packages/swift-navigation` checkout is included because this project needed a patched package path for the tested Xcode/Swift toolchain.