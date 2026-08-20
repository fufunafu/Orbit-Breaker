# Orbit Breaker release checklist

Status: Working release-control document<br>
Target version: 1.0<br>
Minimum iOS version in current preset and bundled native frameworks: 17.0<br>
Bundle identifier in current preset: `com.antonio.orbitbreaker`

## Status legend

- **TODO:** Work or evidence is missing.
- **READY:** Artifact or procedure exists, but final execution or account-specific confirmation remains.
- **PASS:** Requirement was verified against the named release candidate.
- **BLOCKED:** A named external dependency prevents verification.
- **N/A:** Confirmed not applicable, with the reason recorded.

Replace every `[OWNER]`, `[DATE]`, `[BUILD]`, and contact placeholder before release. A checkbox is not evidence by itself. Put the command output, App Store Connect record, screenshot, device log, or review link in the Evidence column.

## Release identity

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | App name is Orbit Breaker | Product owner | Match `project.godot`, Xcode product name, and App Store record | `project.godot` audited 2026-08-20 |
| READY | Bundle identifier is final and owned by the Apple team | Apple account owner | Match signed archive and App Store record | Current preset: `com.antonio.orbitbreaker` |
| READY | Marketing version is final | Release owner | Match Godot preset, Xcode archive, and App Store version | Current draft: 1.0 |
| READY | Build number is unique and increasing | Release owner | Inspect uploaded archive | Current draft: 1 |
| PASS | Copyright holder is confirmed | Project owner | Legal name replaces placeholders | `LICENSE` and metadata identify Fuanne Gao |
| TODO | Public developer or publisher name is confirmed | Project owner | Match App Store seller or publisher details |  |
| TODO | Availability countries and regions are selected | Product owner | App Store Connect availability record |  |
| TODO | Price model is selected | Product owner | App Store Connect price record | Confirm free, paid, or future purchases |

## Repository readiness

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | README explains controls, setup, tests, and export | Developer | Review from a clean checkout | `README.md` |
| PASS | License notice exists | Project owner | Confirm copyright holder and terms | `LICENSE` |
| READY | Third-party license audit is documented | Release owner | Verify every plugin and asset source against its upstream license | `THIRD_PARTY_NOTICES.md`; final completeness audit remains TODO |
| READY | Third-party notices file exists | Release owner | Compare bundled files against license obligations | `THIRD_PARTY_NOTICES.md` |
| READY | Release documents are present | Release owner | Check all links from README | `docs/` package |
| PASS | Repository contains no secrets | Security owner | Secret scan plus manual inspection | Regex and manual scans found no credentials, signing files, private keys, or tokens on 2026-08-20 |
| PASS | Unrelated generated files are excluded | Developer | Inspect clean `git status` after import and export | `.godot`, `build`, and `.DS_Store` remain ignored after final import and export checks |
| TODO | Release commit is tagged | Release owner | Signed or annotated version tag points to submitted source |  |

## Automated tests

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| PASS | Gameplay GitHub workflow exists | Developer | Inspect workflow syntax and trigger set | `.github/workflows/tests.yml` |
| PASS | Gameplay workflow pins Godot 4.7.2 | Developer | Inspect install step and engine output | GitHub run 32408952489 used Godot 4.7.2 |
| PASS | Gameplay workflow runs `tests/test_runner.gd` headlessly | Developer | Successful GitHub run prints `ORBIT_BREAKER_TESTS_OK` | GitHub run 32408952489 passed the headless gameplay job |
| PASS | Release-artifact job exists | Developer | Validate CSV, links, metadata limits, and punctuation | GitHub run 32408952489 passed release-artifact validation |
| PASS | Clean-checkout CI run passes | Developer | Link successful GitHub Actions run for release commit | `https://github.com/fufunafu/Orbit-Breaker/actions/runs/32408952489` passed for 5ac55a9 |
| PASS | Local headless test run passes | Developer | Save command output and exit status | Godot 4.7.2 printed `ORBIT_BREAKER_TESTS_OK` on 2026-08-20 |
| PASS | Test shutdown is free of leaked-instance warnings | Developer | Repeat with `--verbose` and resolve owned leaks | Godot 4.7.2 verbose run exited 0 without leaked ObjectDB instances or resources on 2026-08-20 |
| TODO | Ten consecutive full editor runs complete without errors | QA owner | Manual test log |  |

## Gameplay and fairness

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | Clockwise and counterclockwise launches use correct tangents | QA owner | Automated test plus visual device check | Unit assertions cover both tangent directions; device observation remains |
| PASS | Generated targets are reachable | QA owner | Automated generation test and seeded stress test | Deterministic 100-layout integration stress test validates reachability and launch windows |
| PASS | Hazards preserve at least one valid launch window | QA owner | Automated sampling test across late-game seeds | 300 seeded layouts across five progression stages retain the configured safe sample count |
| PASS | Asteroids appear before pulse mines | QA owner | Play through both introduction thresholds | Automated generation checks every pre-pulse hazard is an asteroid |
| PASS | Combined hazards appear only after individual introductions | QA owner | Verify tuning thresholds and gameplay | Automated generation rejects multi-hazard segments before the combined threshold |
| READY | Every failure reason matches the actual cause | QA owner | Force miss, asteroid, pulse mine, wrong planet, and timeout | Automated collision and label checks cover miss, asteroid, and timeout; device forcing remains for pulse mine and wrong planet |
| READY | Rapid taps cannot double launch | QA owner | Automated and device input test | Duplicate input and repeated launch calls are rejected in integration tests; device tapping remains |
| PASS | Replay starts the same mode immediately | QA owner | Test Classic and Daily game-over paths | Integration tests cover immediate Classic and deterministic Daily replay |
| PASS | New Best appears only for a strict new high score | QA owner | Test lower, equal, and higher score cases | Save and HUD integration assertions cover equal and higher scores |
| PASS | Run summary totals are accurate | QA owner | Compare score, landings, perfects, combo, and reason to observed run | End-run integration verifies score, best, landings, perfects, combo, failure, and unlock text |
| READY | Score-card PNG saves successfully | QA owner | Save and open image on each target device class | RGB PNG generation and filesystem persistence pass headlessly; device Files verification remains |

## Progression and persistence

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| PASS | Ship-colour unlock conditions are correct | QA owner | Reach each milestone and relaunch | Boundary tests cover 10 perfect landings and a 5x combo |
| PASS | Trail unlock conditions are correct | QA owner | Reach each milestone and relaunch | Boundary tests cover 10 perfect landings and score 25 |
| PASS | Planet-theme unlock conditions are correct | QA owner | Reach each milestone and relaunch | Boundary tests cover 25 and 50 total landings |
| PASS | Locked cosmetics cannot be selected | QA owner | Cycle each category before unlock | Catalog cycling tests remain on defaults below every threshold |
| PASS | Selected cosmetics persist | QA owner | Select, terminate, and relaunch | Complete profile save and reload retains selections and unlock arrays |
| READY | Three score-driven zones are visually distinct | Art and QA owners | Capture same route state in each zone | Source audit confirms distinct background, star, glow, planet, and named transition treatments; same-route device capture remains |
| PASS | Unlocks are based on skill milestones, not time or currency | Product owner | Review catalog and build | Catalog logic and boundary tests use only score, combo, perfects, and landings |
| READY | Version 1 save data loads after upgrade | QA owner | Install upgrade over previous build | Version 1 fixture preserves score, progression, and settings; installed upgrade remains |
| READY | Corrupt save data falls back safely | QA owner | Automated test and manual device check | Corrupt fixture returns defaults; device observation remains |
| PASS | App reinstall behaviour is documented | Support owner | Confirm local data removal or restore behaviour | `docs/SUPPORT.md` distinguishes Delete App, Offload App, and backup restoration and links to current Apple guidance |

## Daily Challenge

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| PASS | UTC date changes at the intended boundary | QA owner | Test before and after 00:00 UTC | Exact 23:59:59 and 00:00:00 UTC boundary assertions pass |
| READY | Same date and build produce the same sequence | QA owner | Compare at least three devices for 20 targets | Deterministic seed and random sequence assertions pass; cross-device comparison remains |
| PASS | Classic mode remains randomly seeded | QA owner | Compare fresh Classic runs | Integration verifies separate Classic starts receive different RNG states while Daily remains deterministic |
| PASS | Daily replay preserves the same date seed | QA owner | Replay several runs before UTC rollover | Integration replay reproduces the first target position and size |
| PASS | Daily local best resets by date | QA owner | Test two UTC dates | Save-store assertions preserve same-day best and reset on the next UTC date |
| TODO | Daily leaderboard occurrence matches the UTC date | Game Center owner | Compare in-game label and App Store configuration |  |
| PASS | Version mismatch policy is documented | Product owner | Decide whether old builds remain eligible for comparable Daily scores | `marketing/game-center-configuration.md` requires versioned IDs after material scoring or layout changes |

## Game Center

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | Game Center entitlement is enabled in the Godot preset | iOS developer | Inspect exported entitlements | Current preset requests Game Center |
| READY | All-time identifier matches code | Game Center owner | Compare App Store Connect to code | `com.antonio.orbitbreaker.highscore` |
| READY | Weekly identifier matches code | Game Center owner | Compare App Store Connect to code | `com.antonio.orbitbreaker.weekly` |
| READY | Daily identifier matches code | Game Center owner | Compare App Store Connect to code | `com.antonio.orbitbreaker.daily` |
| TODO | All-time leaderboard exists and is localized | Game Center owner | App Store Connect component record |  |
| TODO | Weekly leaderboard recurs every seven days | Game Center owner | App Store Connect recurrence record | Confirm start day and 00:00 UTC boundary |
| TODO | Daily leaderboard recurs every 24 hours | Game Center owner | App Store Connect recurrence record | Start at 00:00 UTC |
| TODO | High scores sort high to low as integers | Game Center owner | Submit two ordered test scores |  |
| TODO | Perfect Ten achievement exists and is localized | Game Center owner | Identifier, points, copy, and 1024 by 1024 image |  |
| TODO | Maximum Burn achievement exists and is localized | Game Center owner | Identifier, points, copy, and 1024 by 1024 image |  |
| TODO | Planet Runner achievement exists and is localized | Game Center owner | Identifier, points, copy, and 1024 by 1024 image |  |
| TODO | Achievement progress increments correctly | QA owner | Test partial and complete values on physical device |  |
| TODO | Completion banners appear once | QA owner | Complete each achievement on test account |  |
| TODO | Unauthenticated play remains functional | QA owner | Sign out of Game Center and complete runs |  |
| TODO | Leaderboard button handles unavailable Game Center | QA owner | Test signed out, offline, and restricted states |  |
| TODO | Test leaderboard data is removed before launch | Game Center owner | App Store Connect test-data action |  |
| TODO | Game Center components are attached to the submitted app version | Game Center owner | Submission record |  |

## Audio and visual identity

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| PASS | Every bundled audio file has documented rights | Audio owner | Source and license ledger | Original music plus Kenney CC0 effect mappings in `THIRD_PARTY_NOTICES.md` |
| READY | Launch, land, perfect, fail, and UI sounds are distinct | QA owner | Listening test on device speaker and headphones | Automated resource assertions prove five distinct files; device listening remains |
| PASS | Music intensity responds to combo and zone | QA owner | Capture transition checks | Integration verifies combo raises the drive layer and later zones raise both layer pitches together |
| TODO | Sound and music levels avoid clipping | Audio owner | Metered and subjective device test |  |
| TODO | Ship, planets, asteroids, and pulse mines are recognizable | Art and QA owners | First-session identification test |  |
| TODO | Background and palette changes communicate progression | Art and QA owners | Zone recognition results |  |
| TODO | Effects remain readable at 60 FPS | Performance owner | Profile late-game scene on oldest target device |  |

## Accessibility and settings

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | Sound toggle persists and silences effects | QA owner | Toggle, play, terminate, and relaunch | Persistence and playback gating pass automatically; device listening remains |
| READY | Music toggle persists and silences music | QA owner | Toggle, play, terminate, and relaunch | Persistence and minus-80 dB mute assertions pass; device listening remains |
| READY | Haptic toggle persists and suppresses haptics | QA owner | Physical-device test | Persistence passes automatically; physical haptic verification remains |
| PASS | Reduced Motion suppresses screen shake | QA owner | Force perfect and failure feedback | Integration test proves shake time remains zero when either reduction setting is active |
| READY | Reduced Motion reduces background movement | QA owner | Compare all three zones | Particles and starfield receive the reduced-motion state; visual device comparison remains |
| READY | High Contrast Guide is visibly distinct | Accessibility owner | Contrast review on target displays | Integration proves the high-contrast render path is selected; target-display review remains |
| PASS | Guide Off, Tutorial, and Always behave correctly | QA owner | Test first and later runs | Integration covers all three guide modes before and after tutorial completion |
| READY | Pause, resume, and restart are reachable | QA owner | Test safe-area layout on small and large screens | State, world processing, and music assertions pass; safe-area device review remains |
| READY | Backgrounding preserves the current run | QA owner | Physical-device test during orbit and flight | Pause and resume notifications preserve state automatically; physical-device verification remains |
| READY | UI does not rely on colour alone for critical meaning | Accessibility owner | Manual review and user test | `docs/ACCESSIBILITY_AUDIT.md` records text, shape, motion, numeric, sound, and haptic cues; target user testing remains |
| TODO | Accessibility Nutrition Label claims are evidence-backed | Accessibility owner | Complete Apple's current evaluation criteria |  |

## iOS export and device validation

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| PASS | iOS preset targets iPhone portrait | iOS developer | Inspect exported target and orientation | Clean exported Xcode project targets iPhone portrait |
| PASS | Deployment target matches all bundled frameworks | iOS developer | Align preset, Xcode target, and framework `MinimumOSVersion` | Preset is 17.0; `xcrun vtool -show-build` reports `minos 17.0` for both device framework binaries |
| PASS | Godot 4.7.2 export templates are installed | iOS developer | Successful clean export | Project-only release export succeeded on 2026-08-20 |
| PASS | Xcode project exports without missing files | iOS developer | Export log | `tools/prepare_ios_export.sh` printed `ORBIT_BREAKER_IOS_EXPORT_READY` |
| PASS | Native Game Center frameworks are embedded and signed | iOS developer | Xcode build phases and archive validation | Fresh automatically signed archive embeds and signs both XCFrameworks on 2026-08-20 |
| PASS | App Store package signs with intended distribution identity | Release owner | Xcode App Store export | 31 MB IPA signed by Apple Distribution: 15041074 Canada Inc on 2026-08-20 |
| PASS | Generic iPhone arm64 build completes | iOS developer | Unsigned Xcode build log | Release device build succeeded with signing disabled on 2026-08-20 |
| PASS | Simulator build completes | QA owner | Build log and smoke-test record | Release simulator build succeeds with `ARCHS=x86_64`; runtime smoke test remains |
| READY | Physical iPhone build completes | QA owner | Device install and run record | Signed Release build installed on iPhone 16 Pro; unlock and launch validation remain |
| TODO | Small and large supported iPhone layouts pass | QA owner | Screenshot matrix |  |
| TODO | Portrait lock works on physical device | QA owner | Rotation test |  |
| TODO | Touch response remains immediate | QA owner | Input latency observation |  |
| TODO | Stable 60 FPS target is met | Performance owner | Frame-time profile on oldest target device |  |
| TODO | App background and resume behaviour passes | QA owner | State preservation log |  |

## Privacy and compliance

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | Privacy-policy draft covers current repository behaviour | Privacy owner | Final binary and SDK audit | `docs/PRIVACY_POLICY.md` |
| READY | Support-page draft covers current features | Support owner | Replace contacts and verify build | `docs/SUPPORT.md` |
| PASS | Privacy policy has no placeholders | Privacy owner | Search published source and page | Published policy identifies Fuanne Gao and links to the public support channel |
| PASS | Support page has real contact information | Support owner | Open public page | Public page links to the Orbit Breaker GitHub issue tracker |
| PASS | Privacy policy is published at a stable HTTPS URL | Web owner | Public browser check | `https://fufunafu.github.io/Orbit-Breaker/privacy.html` returned HTTP 200 |
| PASS | Support page is published at a stable HTTPS URL | Web owner | Public browser check | `https://fufunafu.github.io/Orbit-Breaker/support.html` returned HTTP 200 |
| READY | Privacy manifest matches accessed APIs and SDK declarations | iOS and privacy owners | Inspect final archive and `PrivacyInfo.xcprivacy` files | The App Store IPA contains a valid root privacy manifest declaring file timestamp, system boot time, and disk space reasons with tracking disabled; Apple upload validation remains pending |
| TODO | App Store Connect privacy answers match actual practices | Privacy owner | Compare final binary, policy, and published answers |  |
| PASS | Third-party SDK data practices are included | Privacy owner | SDK and dependency audit | Privacy policy covers Apple Game Center and TestFlight, and the repository has no advertising, analytics, attribution, or developer-operated account SDK |
| READY | Score-card storage and sharing wording is accurate | Privacy owner | Device test final implementation | Code and automated save test match the privacy and support wording: local PNG only, with no automatic Photos write, share sheet, or upload; device Files check remains |
| TODO | Export-compliance answers are complete | Release owner | App Store Connect response and any documentation |  |
| PASS | Age-rating questionnaire is complete | Product owner | App Store Connect result | Saved on 2026-08-20; App Store Connect shows 12+ and 13+ regional results and a legacy global 12+ rating |
| TODO | Required legal and regional trader details are complete | Account owner | App Store Connect compliance sections | Depends on distribution regions |

## App Store product page

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | App name draft is within 30 characters | Marketing owner | Count characters and reserve name | `Orbit Breaker` |
| READY | Subtitle options are within 30 characters | Marketing owner | Automated byte or character check | `docs/APP_STORE_METADATA.md` |
| READY | Promotional text options are within 170 characters | Marketing owner | Automated character check |  |
| READY | Description is within 4,000 characters | Marketing owner | Automated character check |  |
| READY | Keyword draft is within 100 bytes | Marketing owner | UTF-8 byte count |  |
| TODO | Final metadata contains no pending claims | Product owner | Compare each claim to release build |  |
| TODO | Support URL is entered | Release owner | App Store Connect version record |  |
| TODO | Privacy-policy URL is entered | Release owner | App Store Connect app privacy record |  |
| TODO | Copyright is final | Project owner | App Store Connect record |  |
| TODO | Primary and secondary categories are final | Product owner | App Store Connect record |  |
| TODO | Review contact is complete | Release owner | App Review Information |  |
| READY | App Review notes draft exists | Release owner | Update against final build | `docs/APP_STORE_METADATA.md` |

## Icon, screenshots, and previews

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | App icon meets current App Store requirements | Art and release owners | Asset validation in Xcode and App Store Connect | `marketing/app-icon-1024.png` is 1024 by 1024 RGB with no alpha; Xcode and upload validation remain |
| PASS | Icon has no unintended transparency or clipped content | Art owner | Inspect exported 1024 by 1024 asset | `sips` reports 1024 by 1024 RGB and `hasAlpha: no` on 2026-08-20 |
| READY | Eight-shot screenshot story exists | Marketing owner | Review feature coverage | `docs/SCREENSHOT_PLAN.md` |
| PASS | Final 6.9-inch screenshots are captured | Marketing owner | Validate dimensions and alpha channel | All four marketing PNGs are 1320 by 2868 RGB with no alpha |
| PASS | Screenshots show only implemented features | Product owner | Compare to release build | All four final screenshots are rendered directly from the current `scenes/game.tscn` release implementation |
| N/A | Screenshot captions are readable and accurate | Marketing and accessibility owners | Thumbnail review | The final four use only in-game UI and contain no added marketing captions |
| N/A | Game Center captures contain no unintended personal data | Privacy owner | Inspect final files | The final four do not include a Game Center account or leaderboard screen |
| READY | Preview storyboard exists | Marketing owner | Review timing and claims | `docs/SCREENSHOT_PLAN.md` |
| PASS | Preview video is 15 to 30 seconds with valid codec, audio, size, and frame rate | Marketing owner | Inspect the final video stream | Current file: 30 sec, H.264, 886 by 1920, 30 fps, AAC stereo, about 38 MB |
| PASS | Media rights are documented | Release owner | Asset ledger | Screenshots, preview, and icon derive from the game; authored and CC0 bundled assets are recorded in `THIRD_PARTY_NOTICES.md` |

## TestFlight

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| READY | Validation plan exists | QA owner | Review protocol and gates | `docs/TESTFLIGHT_PLAN.md` |
| READY | Session log schema exists | QA owner | Parse CSV and inspect fields | `docs/TESTFLIGHT_SESSION_LOG.csv` |
| READY | Session analyzer and findings report exist | Research owner | Run analyzer tests and regenerate report | `tools/analyze_testflight.rb` and `docs/TESTFLIGHT_REPORT.md` |
| TODO | Beta description, What to Test, and feedback email are entered | Release owner | App Store Connect Test Information |  |
| TODO | Internal smoke group passes | QA owner | Completed smoke log |  |
| TODO | First external build passes Beta App Review if required | Release owner | TestFlight build status |  |
| TODO | 20 to 30 testers are invited | QA owner | App Store Connect tester count |  |
| TODO | At least 20 valid first-session rows are recorded | Research owner | CSV row count and validation |  |
| TODO | First-launch comprehension reaches 80 percent | Research owner | Cohort analysis |  |
| TODO | Second-run rate reaches 70 percent | Research owner | Cohort analysis |  |
| TODO | Five-run completion reaches 50 percent | Research owner | Cohort analysis |  |
| TODO | Failure understanding reaches 90 percent | Research owner | Cohort analysis |  |
| TODO | Crash and session metrics are reviewed | QA owner | App Store Connect build metrics |  |
| TODO | Common complaints are ranked | Product owner | Beta findings report |  |
| TODO | Difficulty changes cite actual observations | Design owner | Build comparison log |  |
| TODO | Failed critical gates are fixed and retested | QA owner | Retest evidence |  |

## Submission and release

| Status | Item | Owner | Verification | Evidence |
| --- | --- | --- | --- | --- |
| TODO | Final archive passes Xcode validation | Release owner | Organizer validation result |  |
| TODO | Correct build is selected in App Store Connect | Release owner | Version page |  |
| TODO | Game Center components are included in submission | Game Center owner | Submission contents |  |
| TODO | Required screenshots are uploaded | Marketing owner | Product page preview |  |
| TODO | App preview poster frame is selected | Marketing owner | App Store Connect preview |  |
| TODO | App privacy details are published | Privacy owner | Product page preview |  |
| TODO | Review notes match final behaviour | Release owner | Final copy review |  |
| TODO | Manual release is selected for version 1.0 | Product owner | Version release setting | Recommended for controlled launch |
| TODO | App Review submission is complete | Release owner | Submission status and timestamp |  |
| TODO | Approval result and any reviewer correspondence are archived | Release owner | Release folder or issue link |  |
| TODO | Public privacy and support pages are monitored after launch | Support owner | Page availability check |  |
| TODO | Launch build crash, review, and leaderboard signals are monitored | Product owner | First 72-hour report |  |

## Current known release blockers

These items are known to require external state or owner decisions:

1. Confirm the publisher name, price, regions, TestFlight feedback contact, and App Review contact.
2. Push the Linux CI isolation fix and attach successful workflow evidence for the resulting source commit.
3. Create the prepared App Store Connect app record and enter the public privacy and support URLs.
4. Configure and attach the three leaderboards and three achievements, then upload the prepared achievement images.
5. Unlock the connected iPhone and complete launch, safe-area, backgrounding, persistence, haptic, accessibility, performance, and Game Center tests.
6. Transmit the prepared App Store package to Apple for validation and upload after explicit approval.
7. Recruit 20 to 30 testers and run the documented seven-day TestFlight validation.
8. Complete the final privacy answers, age rating, export compliance, regional compliance, pricing, availability, and third-party-license audit.
9. Replace the installed Godot simulator export template with an arm64-compatible build, or keep the validated x86_64 simulator workflow under Rosetta.

## Go or no-go record

| Field | Value |
| --- | --- |
| Candidate version and build | `[VERSION] ([BUILD])` |
| Decision | `[GO / CONDITIONAL GO / NO-GO]` |
| Decision date UTC | `[DATE]` |
| Product owner | `[OWNER]` |
| Engineering owner | `[OWNER]` |
| QA owner | `[OWNER]` |
| Privacy owner | `[OWNER]` |
| Open conditions | `[NONE OR LIST]` |
| Evidence bundle | `[LINK OR PATH]` |

No release is a go while any Critical TestFlight gate, privacy-policy requirement, signing requirement, or App Review submission requirement remains unverified.

## Apple references

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App privacy management: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- App preview specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications
- TestFlight overview: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview
- Game Center testing: https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-testing-game-center
- Recurring leaderboards: https://developer.apple.com/documentation/gamekit/creating-recurring-leaderboards
