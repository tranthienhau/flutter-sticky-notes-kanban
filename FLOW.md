# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (if missing) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_sticky_notes_kanban
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "iPhone 17 Pro"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart`:
  - In `setUpAll`, initializes Hive, registers the `StickyNote` + `Priority` adapters, clears the `notes` box, and seeds six sticky notes across the Mon/Tue/Wed lanes with mixed priority colors (high/red, medium/yellow, low/blue) so the board renders real-looking content.
  - Pumps `BoardScreen` and shoots `01-week-board` (the weekly wall planner with seeded notes).
  - Opens the full-screen `NoteZoomSheet` for a seeded note and shoots `02-zoom-editor` (Hero zoom editor in the note's priority color).
  - Taps a priority swatch (36x36 circular `Container`) to switch the note color and shoots `03-priority-picker`.
  - Each shot calls `binding.convertFlutterSurfaceToImage()` + `pumpAndSettle()` + `binding.takeScreenshot('NN-name')`.
