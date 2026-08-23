# Accessibility Communication Audit

Audit date: August 23, 2026

This audit records how the release candidate communicates critical gameplay
state without relying on colour alone. It supports source review and automated
testing. Target-display review and first-session user testing remain required.

## Launch and target guidance

- The target planet has a pulsing inner perfect-zone ring and a separate outer
  ring, while non-target planets do not.
- The trajectory guide is a dashed line. It adds one pulsing ring around the
  target when the current tangent can land and a second ring when the launch
  would be perfect.
- The tutorial states: `WAIT FOR THE GUIDE TO TOUCH THE TARGET THEN TAP TO
  LAUNCH` and explains that a double ring means perfect.
- High Contrast Guide changes both line colour and line width.

## Hazards and failures

- Asteroids use an irregular polygon silhouette with a cross-shaped surface
  mark.
- Pulse mines use a circular core, eight radial spokes, and an expanding and
  contracting collision ring.
- The game introduces each hazard with a named text tip.
- Every failed run ends with a written cause, including asteroid, pulse mine,
  dead-orbit collision, timeout, or deep-space miss.

## Score, progression, and mode

- Score, best score, and combo are shown numerically.
- Perfect landings change the numeric score and combo, and use a sound and
  haptic pattern distinct from an ordinary landing when those settings are on.
- Classic and Daily are named in text. Daily also shows its UTC date.
- Zone transitions display the destination zone name in text.
- Unlocks and New Best status appear as text in the run summary.

## Motion and flashing

- Landings and failures trigger a brief full-screen colour flash (alpha 0.18
  to 0.38, 0.24 second fade) and, for perfect landings and failures, a 0.28
  second camera shake.
- Reduced Motion disables the flashes, the camera shake, background parallax,
  and most particle output. Reduced Screen Shake disables only the shake.
- Flash frequency is bounded by landing cadence, which the launch speed and
  minimum planet gap keep below three per second.

## Controls and settings

- Buttons use text labels rather than colour-only icons, except the pause
  control, which uses the familiar `II` symbol.
- Check buttons expose checked state and a written setting name.
- Guide mode is written as Off, Tutorial, or Always.
- Cosmetic choices display their selected names.
- Pause, resume, restart, main menu, save, privacy, support, and leaderboard
  actions all have visible labels.

## Remaining validation

- Review the release build on the smallest and largest supported iPhone
  displays.
- Test with colour filters, increased contrast, reduced motion, and reduced
  transparency where applicable.
- Include players with colour-vision differences in the TestFlight cohort.
- Confirm that the pause symbol is understood or replace it with a written
  `PAUSE` label after user testing.
- Complete Apple's current Accessibility Nutrition Label evaluation from the
  final installed build.
