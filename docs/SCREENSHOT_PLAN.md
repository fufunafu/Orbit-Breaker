# Orbit Breaker App Store screenshot and preview plan

Status: Four screenshots captured from the release source; four optional additions listed<br>
Target platform: iPhone, portrait<br>
Captured screenshots: 4 (`marketing/screenshots/01-home.png` through `04-score-card.png`)<br>
Capture tool: `tools/capture_marketing.gd`, which refuses to save a capture whose size differs from 1320 by 2868

## Capture gate

Do not capture final media until:

- Gameplay and HUD work is complete.
- The app icon and final visual palette are locked.
- All screenshot claims are implemented in the captured build.
- Safe-area layout passes on the target simulator or device.
- Debug overlays, cursor, touch indicators, frame counters, and personal notifications are hidden.
- Test profiles contain only intentional, presentation-ready names and scores.
- Game Center screens use a test account with no unwanted personal information visible.
- The App Store description and screenshot captions tell the same feature story.

## Current Apple constraints

- App Store Connect accepts 1 to 10 screenshots per supported device size and language.
- Screenshots must be JPEG, JPG, or PNG and cannot contain an alpha channel.
- For the 6.9-inch iPhone class, accepted portrait screenshot sizes currently include 1260 by 2736, 1290 by 2796, and 1320 by 2868 pixels.
- Up to three app previews can be supplied per device size and localization.
- App previews must be 15 to 30 seconds long, no larger than 500 MB, and no more than 30 frames per second.
- A 6.9-inch portrait app preview can use the accepted 886 by 1920 resolution.

Recheck Apple's live specifications immediately before capture and upload.

## Visual direction

- Use one dominant short caption per screenshot.
- Keep typography large enough to read in the App Store thumbnail view.
- Use the game palette and effects, but preserve clear separation between caption and gameplay.
- Show different game states rather than repeating the same orbit composition.
- Use actual gameplay from the shipping build.
- Keep the player score plausible and internally consistent.
- Avoid claims such as best, number one, free, or multiplayer unless they are accurate and approved.

## Captured set

The four shipping captures and the feature each one carries are listed in
[marketing/app-store-metadata.md](../marketing/app-store-metadata.md). They map
to sequence items 1, 2, 4, and 8 below and were reviewed visually on August 20,
2026. Captions are not baked into the images.

## Screenshot sequence

Items 3, 5, 6, and 7 are optional additions for a later update; they are not
part of the 1.0 submission.

### 1. One tap breaks orbit

Caption: **TAP. LAUNCH. LAND.**

Capture state:

- Early Classic run
- Ship positioned at a readable tangent to the highlighted planet
- High-contrast guide visible if it improves clarity
- Score and target unobstructed

Purpose: Explain the core interaction in one image.

### 2. Thread the perfect zone

Caption: **NAIL THE PERFECT LANDING**

Capture state:

- Perfect-zone contact or immediate perfect feedback
- Pink perfect effects clearly visible
- Combo increased to at least 2x

Purpose: Show precision and the main mastery loop.

### 3. Build a 5x combo

Caption: **PUSH YOUR COMBO TO 5x**

Capture state:

- 5x combo label visible
- Mid-run composition with a meaningful score
- Adaptive visual intensity visible without obscuring play

Purpose: Show scoring depth and risk.

### 4. Survive shifting hazards

Caption: **FIND THE SAFE LAUNCH WINDOW**

Capture state:

- Asteroid and pulse mine visible in a later run
- A valid path to the target remains visually plausible
- Ship, hazard, and target silhouettes are distinct

Purpose: Communicate rising difficulty and fairness.

### 5. Climb through three space zones

Caption: **BREAK INTO NEW SPACE ZONES**

Capture state:

- Sunforge or Nova Drift palette
- Planet and background presentation clearly different from screenshot 1
- Score above the relevant zone threshold

Purpose: Show visual progression during a run.

### 6. Earn new looks through skill

Caption: **UNLOCK SHIPS, TRAILS, AND WORLDS**

Capture state:

- Loadout and Settings view
- At least one legitimately unlocked alternate in each relevant category
- No locked reward presented as immediately available

Purpose: Show progression without implying purchasable currency or grinding.

### 7. Same daily route. Fair challenge.

Caption: **A SHARED CHALLENGE EVERY DAY**

Capture state:

- Daily mode label and UTC date visible
- Daily leaderboard view or a split composition only if Apple review guidance permits it
- Date must match the captured leaderboard occurrence

Purpose: Explain comparable, seeded daily play.

Submission gate: Daily recurrence and same-build layout matching must pass TestFlight.

### 8. Learn, replay, beat your best

Caption: **REPLAY INSTANTLY**

Capture state:

- Game-over panel showing New Best
- Score, best, landings, perfect landings, highest combo, and failure reason visible
- Replay Now button visible

Purpose: End the story on the retention loop and useful feedback.

## Required raw captures

For every final screenshot, retain:

- Original unedited device or simulator capture
- Exported captioned image
- App version and build number
- Device model and simulator runtime
- UTC capture date
- Exact game state or seed needed to reproduce it
- Reviewer initials and approval date

Recommended filename pattern:

```text
orbit-breaker_en-CA_6.9_01_core_1320x2868.png
```

## Device-size matrix

| Asset set | Portrait size | Required action |
| --- | --- | --- |
| 6.9-inch iPhone | 1320 by 2868 | Four images captured; optional additions use the same size |
| 6.5-inch iPhone | 1284 by 2778 or 1242 by 2688 | Produce only if release strategy or App Store Connect requires it |
| Smaller supported iPhone layouts | Current accepted dimensions for each requested display class | Validate UI even if App Store scales another set |

The project is currently configured for iPhone only. Do not create iPad marketing assets unless device-family support changes.

## Accessibility media check

- Critical meaning must not depend on colour alone.
- Caption contrast should meet a readable standard against every captured background.
- Do not present Reduced Motion using a still image as proof that motion is reduced.
- Include High Contrast Guide only if the captured appearance matches the shipping setting.
- Avoid flashing frames as poster images.

## Preview video outline

Target: one 20 to 25 second portrait preview for the first release.

| Time | Content | On-screen copy |
| --- | --- | --- |
| 0:00 to 0:03 | Ship orbits, then launches immediately | One tap breaks orbit |
| 0:03 to 0:07 | Successful normal landing and next target | Read the angle |
| 0:07 to 0:11 | Perfect landing and combo increase | Hit perfect. Build combo. |
| 0:11 to 0:15 | Asteroid and pulse-mine navigation | Find the safe window |
| 0:15 to 0:18 | Clear hazard failure | Learn every miss |
| 0:18 to 0:21 | Replay Now and immediate next launch | Replay instantly |
| 0:21 to 0:25 | Daily label and Game Center leaderboard | Chase today's route |

Audio plan:

- Use in-game sound and music from the release build.
- Mix for clear mobile playback without clipping.
- Do not rely on narration to explain mandatory information.
- Verify rights for every sound included in the video.

Technical preview target:

- 886 by 1920 portrait
- 15 to 30 seconds
- 30 frames per second maximum
- H.264 with AAC stereo, using Apple's current accepted settings
- 500 MB maximum

## Review checklist for each image

- [ ] Correct pixel dimensions
- [ ] No alpha channel
- [ ] Correct localization
- [ ] Current icon, HUD, and palette
- [ ] No debug UI or personal notification
- [ ] No personal Game Center information beyond the approved test profile
- [ ] Caption is true in the captured build
- [ ] Gameplay remains the dominant visual
- [ ] Text is readable at thumbnail size
- [ ] No repeated composition
- [ ] File opens correctly after export

## Apple references

- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- App preview specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications
- Upload previews and screenshots: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots/
