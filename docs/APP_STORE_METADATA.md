# Orbit Breaker App Store metadata

Status: Release-candidate draft<br>
Primary language: English (Canada)<br>
Last repository audit: 2026-08-23

Do not paste claims marked **Pending** into App Store Connect until their checklist gates are complete.

This file is the single source for store copy. `marketing/app-store-metadata.md` only maps the captured screenshots to this copy; `marketing/game-center-configuration.md` holds the Game Center component setup and must match the tables below.

## Product identity

| Field | Draft | Limit or note |
| --- | --- | --- |
| App name | Orbit Breaker | 30 characters maximum |
| Bundle identifier | `com.antonio.orbitbreaker` | Must match the signed build and App Store record |
| Version | 1.0 | Confirm before upload |
| Copyright | 2026 15041074 Canada Inc | Matches the Apple Distribution signing identity and App Store seller record |
| Primary category | Games | Recommended |
| Primary game subcategory | Action | Available in the current App Store Connect form |
| Secondary game subcategory | Casual | Available in the current App Store Connect form |
| Secondary category | Entertainment | Optional fallback if a non-game secondary category is desired |

## Subtitle options

Each option is within Apple's 30-character limit.

1. One Tap. Perfect Orbit.
2. Launch. Land. Go Higher.
3. A One-Tap Space Challenge

Recommended: **One Tap. Perfect Orbit.**

## Promotional text options

Each option is intended to remain within Apple's 170-character limit.

### Option A

Thread perfect launches through shifting hazards, build a 5x combo, unlock new looks, and chase today's shared orbital challenge.

### Option B

One tap decides everything. Read the orbit, launch at the right instant, and climb from the Ion Veil to the Sunforge.

### Option C

Chase a new best, compare daily runs, and master the perfect landing in a fast one-tap arcade challenge.

Recommended: **Option A**, after daily and Game Center device validation passes.

## Description

One tap. One launch window. How high can you climb?

Orbit Breaker is a fast portrait arcade game about reading motion and committing at exactly the right moment. Your ship circles each planet automatically. Tap to break orbit, cross open space, and land on the highlighted world above.

Hit the perfect zone to raise your combo and score faster. Miss the planet, strike an asteroid, or get caught in a pulse mine and the run ends immediately. Every attempt teaches you to read the angle a little better, and Replay Now gets you back into orbit without delay.

FEATURES

• Simple one-tap play with precise, skill-based timing
• Perfect landings and combos up to 5x
• Classic endless runs and a shared UTC daily challenge
• Clear end-of-run statistics and failure feedback
• All-time, weekly, and daily Game Center competition
• Game Center achievements for orbital milestones
• Unlockable ship colours, trails, and planet themes earned through skill
• Three distinct space zones as your score rises
• Adaptive music and responsive sound and haptic feedback
• Sound, music, haptic, reduced-motion, high-contrast, and guide settings
• Pause, restart, immediate replay, and locally saved score cards

There is no grinding for currency. New looks are unlocked by reaching meaningful skill milestones, including perfect landings, high combos, and total planets reached.

The route is clear. The timing is yours.

## Keywords

Recommended keyword string:

```text
arcade,space,planets,one tap,high score,daily challenge,leaderboard,reflex,skill,neon
```

Validation rules:

- Keep the encoded value at 100 bytes or fewer.
- Do not repeat the app name or developer name.
- Do not use competitor names, trademarks, or unsupported claims.
- Recheck byte length after localization.

## Support and privacy URLs

| Field | Value |
| --- | --- |
| Support URL | `https://fufunafu.github.io/Orbit-Breaker/support.html` |
| Privacy policy URL | `https://fufunafu.github.io/Orbit-Breaker/privacy.html` |
| Marketing URL | `https://fufunafu.github.io/Orbit-Breaker/` |

The GitHub Pages workflow publishes these files from `docs/`. Confirm all three URLs after pushing the release branch and before submission.

## App Review contact

Enter the account holder's verified first name, last name, phone number, and email directly in App Store Connect. These private account fields are intentionally not stored in the public repository.

## App Review notes

Entered in App Store Connect > 1.0 > App Review Information > Notes on
August 24, 2026, after App Review requested this information under
Guideline 2.1 (Information Needed). Keep the two copies identical.

Orbit Breaker is a portrait, one-tap arcade game for iPhone. No account, login,
purchase, subscription, user-generated content, or sensitive-data permission
exists anywhere in the app, so no credentials or demo account are needed.

Setup and main features: Launch the app and tap Classic Run (endless) or Daily
Challenge (same UTC-date layout for every player). Tap while the ship orbits to
launch along its current tangent. Landing inside the target planet's inner zone
is a perfect landing and raises the combo multiplier up to 5x; asteroids and
pulse mines end the run on contact. The round pause button (top right during a
run) exposes Resume, Restart, Settings, and Main Menu. After a run ends: Replay
Now restarts immediately; Save Score Card writes a PNG to the app's Documents
folder (Files > On My iPhone > Orbit Breaker); Leaderboards opens the Game
Center interface. Loadout items (ships, trails, planet themes) unlock through
play only; locked items show their unlock condition. Settings includes sound,
music, haptics, reduced motion, reduced screen shake, high-contrast guide,
trajectory guide (Off / Tutorial / Always), Export Gameplay Stats, Privacy
Policy, and Support.

Game Center: Optional. Authentication uses Apple's Game Center sheet. If the
reviewer is not signed in, the game remains fully playable and leaderboard and
achievement submission is skipped silently. Three leaderboards (all time,
weekly, daily) and three achievements are configured.

Functions, value, and audience: A quick, skill-based timing game with no ads,
purchases, or accounts. General audience (4+), casual and score-chasing arcade
players.

Devices tested: Physical: iPhone 16 Pro, iOS 26.6 (TestFlight). Simulator:
iPhone 16 Pro and iPhone SE (3rd generation), iOS 26.5. Minimum iOS 17.0;
iPhone only, portrait.

External services: Apple Game Center (GameKit) only. No analytics, advertising,
tracking, authentication, payment, AI, or third-party network services; the app
makes no network requests of its own. Built with the open-source Godot Engine
4.7.2 (MIT). Privacy Policy and Support links open the public site in Safari:
<https://fufunafu.github.io/Orbit-Breaker/>

Regional differences: None. Identical in all regions; the Daily Challenge uses
UTC.

Regulated industry / third-party material: Not applicable. Third-party material
is openly licensed: five Kenney sound effects (CC0), the Archivo and Archivo
Black typefaces (SIL OFL 1.1), Godot Engine and Godot Apple Plugins (MIT).
Licenses are included in the app's public source repository.

A screen recording of the full user flow captured on an iPhone 16 Pro was
provided in the 1.0 review thread on August 24, 2026.

### Screen recording shot list

If App Review asks for a recording again, capture on a physical iPhone running
the latest iOS, starting from the Home screen: launch the app; Classic Run with
at least one perfect landing and a combo; pause, Settings, toggle a setting,
Done, Resume; let the run end; Save Score Card; Leaderboards (signed in to Game
Center so the sheet opens); Main Menu; Daily Challenge; Loadout; Settings;
Privacy Policy. 60 to 120 seconds is enough.

## Age-rating questionnaire notes

These are preparation notes, not a substitute for completing Apple's current questionnaire against the final build.

- Cartoon or fantasy violence: None. The ship can collide with stylized hazards, but there are no characters, weapons, injuries, or depictions of harm.
- Realistic violence: None observed.
- Profanity or crude humour: None observed.
- Horror or fear themes: None observed.
- Alcohol, tobacco, drugs, gambling, loot boxes, or simulated gambling: None observed.
- Sexual or nudity content: None observed.
- Medical or wellness content: None observed.
- Unrestricted web access: None observed.
- User-generated content or chat: None observed.
- Advertising or in-app purchases: None observed.
- Location sharing: None observed.
- Game Center: leaderboards and achievements are present and should be disclosed wherever the questionnaire asks about online or social game features.

Expected result: **4+**. App Store Connect currently shows a 12+ rating saved on 2026-08-20, which does not follow from these answers; re-answer the questionnaire in App Store Connect so the saved rating becomes 4+ before submission.

Re-audit the final binary and every bundled SDK before submitting these answers.

## Game Center configuration

### Leaderboards

| Reference name | Identifier in code | Configuration | Sort | Submission gate |
| --- | --- | --- | --- | --- |
| Orbit Breaker All Time | `com.antonio.orbitbreaker.highscore` | Classic, never resets | High to low, integer score | Create, localize, test, and submit with the app version |
| Orbit Breaker Weekly | `com.antonio.orbitbreaker.weekly` | Recurring every 7 days | High to low, integer score | Confirm recurrence start day and UTC time |
| Orbit Breaker Daily | `com.antonio.orbitbreaker.daily` | Recurring every 24 hours | High to low, integer score | Start each occurrence at 00:00 UTC to match the in-game date key |

Every completed run posts to the all-time and weekly boards; Daily Challenge runs also post to the daily board.

Suggested localized title format:

- All-Time Orbit Breakers
- This Week's Orbit Breakers
- Daily Challenge: `yyyy-mm-dd` occurrence managed by Game Center

**Pending:** These identifiers are referenced by the current code, but the App Store Connect components and recurrence schedules must be verified in the owner account.

### Achievements

| Reference name | Identifier in code | Suggested points | Pre-earned description | Earned description |
| --- | --- | ---: | --- | --- |
| Perfect Ten | `com.antonio.orbitbreaker.perfect10` | 25 | Complete 10 perfect landings. | You completed 10 perfect landings. |
| Maximum Burn | `com.antonio.orbitbreaker.combo5` | 25 | Reach a 5x combo in one run. | You reached maximum burn with a 5x combo. |
| Planet Runner | `com.antonio.orbitbreaker.planets50` | 50 | Land on 50 planets across all runs. | You landed on 50 planets and carried the signal onward. |

The prepared achievement images are 1024 by 1024 RGB PNG files at 72 ppi without alpha. They are stored in `marketing/game-center-achievements/` and mapped in `marketing/game-center-configuration.md`.

**Pending:** Create and localize the App Store Connect achievement records, upload the prepared images, test progress reporting on a physical device, and submit all three achievements for review.

## TestFlight metadata

### Beta app description

Orbit Breaker is a one-tap orbital arcade game. Time each launch, land on the highlighted planet, build perfect-landing combos, survive hazards, and compare Classic and Daily Challenge scores through Game Center.

### What to test

Please complete at least five runs. On your first run, do not ask for instructions. Tell us whether the first launch made sense, whether each failure reason was clear, and whether Replay Now felt immediate. Try Classic and Daily modes, change at least one accessibility setting, save a score card and confirm it appears in Files, and open Game Center leaderboards. Report any crash, progress loss, incorrect daily layout, failed Game Center submission, unreadable text, delayed input, or severe frame-rate drop.

### Feedback email

Use fuannegao25@gmail.com, which is also published on the support and privacy pages. The public issue tracker remains available at https://github.com/fufunafu/Orbit-Breaker/issues.

## Localization plan

The first release can launch with one thoroughly reviewed English localization. For each added language, localize and review:

- App name and subtitle
- Promotional text, description, and keywords
- Screenshot captions
- Privacy and support pages
- Leaderboard titles and score suffixes
- Achievement titles and pre-earned and earned descriptions
- TestFlight beta description and What to Test text

Do not rely on English fallback for Game Center components intended to appear in localized storefronts.

## Source references

- Apple app information: https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Apple platform version information: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Apple app privacy: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
- Apple Game Center configuration: https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-game-center/
- Apple achievements: https://developer.apple.com/help/app-store-connect/configure-game-center/manage-achievements/
- Apple TestFlight overview: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview
