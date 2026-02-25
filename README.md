# CrownSpin

A discrete Apple Watch fidget app that provides satisfying haptic feedback when rotating the Digital Crown.

## Features

- **Digital Crown Haptics**: Infinite rotation with customizable haptic feedback
- **10 Haptic Patterns**: From subtle clicks to complex rhythms
- **Discrete Design**: Nearly invisible dark UI for use in meetings
- **Quick Launch**: Complication support for one-tap access
- **Eyes-Free Operation**: Switch patterns with simple taps

## Haptic Patterns

### Basic Patterns
| Pattern | Description |
|---------|-------------|
| Clicks | Classic clicky feel, high sensitivity |
| Soft | Gentle bumps, medium sensitivity |
| Heavy | Strong thuds, low sensitivity |

### Rhythm Patterns
| Pattern | Description |
|---------|-------------|
| Heartbeat | Lub-dub pulse pattern |
| Double Tap | Two quick taps per rotation |
| Gallop | Long-short-short rhythm |
| Waltz | 1-2-3 rhythm with emphasis |
| Staccato | Rapid sharp bursts |
| Wave | Intensity builds and fades |
| Random | Unpredictable timing and intensity |

## Usage

1. Rotate the Digital Crown to feel haptic feedback
2. Tap left side of screen for previous pattern
3. Tap right side of screen for next pattern
4. Double-tap to hide/show the visual indicator

## Requirements

- watchOS 10.0+
- Apple Watch with Digital Crown

## Building

1. Open `CrownSpin.xcodeproj` in Xcode 15+
2. Select your Apple Watch as the destination
3. Build and run

## Project Structure

```
CrownSpin/
├── CrownSpin Watch App/
│   ├── CrownSpinApp.swift      # App entry point
│   ├── ContentView.swift       # Main fidget view
│   ├── HapticManager.swift     # Haptic feedback engine
│   ├── HapticPattern.swift     # Pattern definitions
│   ├── CrownSpinWidget.swift   # Complication widget
│   └── Assets.xcassets/        # App assets
├── scripts/                   # Utility helpers (icons, tooling)
└── README.md
```

## Agentic Orchestration

This repository ships with a lightweight agent orchestrator inspired by the agent swarm workflow you outlined. Zoe lives in `.clawdbot/` and handles:

- Prompt synthesis from `README.md` and `AppStoreMetadata.md`.
- Tmux-based agent runs (Codex or Claude).
- Task tracking in `.clawdbot/active-tasks.json`.
- Monitoring (`check-agents.sh`) and cleanup (`cleanup-orphans.sh`).
- OpenClaw notifications when a task reaches your definition of done.

See `docs/agent-swarm.md` for documentation and command examples.

## License

MIT License
