# Orbit Breaker App Store metadata

Status: Release-candidate draft<br>
Primary language: English (Canada) or English (U.S.), to be confirmed<br>
Last repository audit: 2026-08-20

Do not paste claims marked **Pending** into App Store Connect until their checklist gates are complete.

## Product identity

| Field | Draft | Limit or note |
| --- | --- | --- |
| App name | Orbit Breaker | 30 characters maximum |
| Bundle identifier | `com.antonio.orbitbreaker` | Must match the signed build and App Store record |
| Version | 1.0 | Confirm before upload |
| Copyright | 2026 Fuanne Gao | Confirm it matches the App Store seller record |
| Primary category | Games | Recommended |
| Primary game subcategory | Action | Confirm available App Store Connect fields |
| Secondary game subcategory | Arcade | Confirm available App Store Connect fields |
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
• Unlockable ship colors, trails, and planet themes earned through skill
• Three distinct space zones as your score rises
• Adaptive music and responsive sound and haptic feedback
• Sound, music, haptic, reduced-motion, high-contrast, and guide settings
• Pause, restart, immediate replay, and locally saved score cards

There is no grinding for currency. New looks are unlocked by reaching meaningful skill milestones, including perfect landings, high combos, and total planets reached.

The route is clear. The timing is yours.

## Keywords

Recommended keyword string:

```text
arcade,space,orbit,one tap,high score,daily challenge,leaderboard,reflex,skill,neon
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

| Field | Value |
| --- | --- |
| First name | `[REVIEW CONTACT FIRST NAME]` |
| Last name | `[REVIEW CONTACT LAST NAME]` |
| Phone | `[REVIEW CONTACT PHONE]` |
| Email | `[REVIEW CONTACT EMAIL]` |

## App Review notes draft

Orbit Breaker is a portrait, one-tap arcade game. It does not require an app-specific account or purchase.

To begin a run:

1. Launch the app in portrait orientation.
2. Tap Classic for a normal run or Daily for the UTC daily challenge.
3. Tap while the ship orbits to launch along its current tangent.
4. Land on the highlighted planet. The inner target area awards a perfect landing and raises the combo.
5. Use the pause button to test resume, restart, and settings.
6. After a failure, use Replay Now for an immediate restart or Save Score Card to write a PNG inside the app's local storage.

Game Center authentication is requested through Apple's Game Center interface. The game remains playable if Game Center is unavailable or the player is not authenticated. Leaderboards and achievements require the reviewer to use a Game Center-enabled device and account.

The Daily mode derives its layout seed from the current UTC date. All players on the same build receive the same deterministic planet and hazard sequence for that UTC date.

There are no ads, in-app purchases, external web views, or developer-operated account systems in this build.

No special hardware is required. Haptics are available on supported physical devices and do not block play.

## Age-rating questionnaire notes

These are preparation notes, not a substitute for completing Apple's current questionnaire against the final build.

- Cartoon or fantasy violence: likely None. The ship can collide with stylized hazards, but there are no characters, weapons, injuries, or depictions of harm.
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

Re-audit the final binary and every bundled SDK before submitting these answers.

## Game Center configuration

### Leaderboards

| Reference name | Identifier in code | Configuration | Sort | Submission gate |
| --- | --- | --- | --- | --- |
| All-Time High Score | `com.antonio.orbitbreaker.highscore` | Classic, never resets | High to low, integer score | Create, localize, test, and submit with the app version |
| Weekly High Score | `com.antonio.orbitbreaker.weekly` | Recurring every 7 days | High to low, integer score | Confirm recurrence start day and UTC time |
| Daily Challenge | `com.antonio.orbitbreaker.daily` | Recurring every 24 hours | High to low, integer score | Start each occurrence at 00:00 UTC to match the in-game date key |

Suggested localized title format:

- All-Time Orbit Breakers
- This Week's Orbit Breakers
- Daily Challenge: `yyyy-mm-dd` occurrence managed by Game Center

**Pending:** These identifiers are referenced by the current code, but the App Store Connect components and recurrence schedules must be verified in the owner account.

### Achievements

| Reference name | Identifier in code | Suggested points | Pre-earned description | Earned description |
| --- | --- | ---: | --- | --- |
| Perfect Ten | `com.antonio.orbitbreaker.perfect10` | 25 | Complete 10 perfect landings. | You completed 10 perfect landings. |
| Maximum Burn | `com.antonio.orbitbreaker.combo5` | 25 | Reach a 5x combo. | You reached a 5x combo. |
| Planet Runner | `com.antonio.orbitbreaker.planets50` | 50 | Land on 50 planets across all runs. | You landed on 50 planets. |

Achievement images must be 1024 by 1024 pixels, RGB, and supplied in an accepted image format. Create these after the final icon and visual identity are locked.

**Pending:** Create, localize, add images, test progress reporting, and submit all three achievements for review.

## TestFlight metadata

### Beta app description

Orbit Breaker is a one-tap orbital arcade game. Time each launch, land on the highlighted planet, build perfect-landing combos, survive hazards, and compare Classic and Daily Challenge scores through Game Center.

### What to test

Please complete at least five runs. On your first run, do not ask for instructions. Tell us whether the first launch made sense, whether each failure reason was clear, and whether Replay Now felt immediate. Try Classic and Daily modes, change at least one accessibility setting, save a score card, and open Game Center leaderboards. Report any crash, progress loss, incorrect daily layout, failed Game Center submission, unreadable text, delayed input, or severe frame-rate drop.

### Feedback email

`[TESTFLIGHT FEEDBACK EMAIL]`

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
