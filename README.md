# BlendShapeLab

A lightweight macOS tool for interactively previewing **blendshapes (morph targets)** in USDZ/USD files.

Perfect for 3D artists and developers who want to quickly inspect facial expressions, body morphs, or any blendshape-driven animations without opening heavy 3D software.

https://github.com/user-attachments/assets/d71a8d18-3da1-4cdc-9fda-9f2218796be1

## Features

- **Real-time Preview** — Adjust blendshape weights with a slider and see changes instantly
- **Solo Mode** — Isolate individual blendshapes to inspect them without interference
- **Sweep Animation** — Automatically animate weights from 0↔1 to visualize the full range of motion
- **Drag & Drop** — Simply drop your USDZ/USD file to start exploring
- **Search & Filter** — Quickly find blendshapes by name in large models

## Supported Formats

`.usdz` `.usd` `.usda` `.usdc`

## Installation

### Download (Recommended)

1. Go to [Releases](https://github.com/setouchi-h/BlendShapeLab/releases)
2. Download the latest `BlendShapeLab.dmg`
3. Open the DMG and drag BlendShapeLab to your Applications folder

### Build from Source

Requirements:
- macOS 14.0+
- Xcode 16.0+

Steps:
1. Clone this repository
2. Open `BlendShapeLab.xcodeproj` in Xcode
3. Build and run the `BlendShapeLab` target

## Usage

1. Open a file with `⌘O` or drag & drop onto the window
2. Select a blendshape from the list
3. Use the slider to adjust weights (0.0 – 1.0)

## Controls

| Control | Description |
|---------|-------------|
| **Solo** | When enabled, sets all other blendshape weights to 0 |
| **Reset All** | Resets all blendshape weights to 0 |
| **Sweep** | Animates the selected blendshape weight back and forth |

## Notes

- Some models may display blendshape names as `target_0`, `target_1`, etc. This happens when the original model doesn't include blendshape name metadata.

## License

MIT License - see [LICENSE](LICENSE) for details.
