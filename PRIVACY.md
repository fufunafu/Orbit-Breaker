# Orbit Breaker Privacy Policy

Effective date: August 23, 2026<br>
Developer: Fuanne Gao, 15041074 Canada Inc<br>
Contact: <fuannegao25@gmail.com> or the [Orbit Breaker support page](https://fufunafu.github.io/Orbit-Breaker/support.html)

This Privacy Policy explains how Orbit Breaker handles information when you use the iOS application.

## Summary

Orbit Breaker does not currently include advertising, an app-specific account system, developer-operated analytics, or a developer-operated online service. Game progress and preferences are stored locally on your device. If you use Game Center, Apple processes Game Center information and Orbit Breaker submits gameplay results to that service.

This summary was rechecked on August 23, 2026 against the release source, the
export configuration, the generated privacy manifest, and all bundled
third-party software.

## Information stored on your device

Orbit Breaker stores a local game profile so that progress and preferences remain available between sessions. The profile may include:

- Best score and daily best score
- Total landings and total perfect landings
- Highest combo, completed-run count, and restart count
- Tutorial-completion status
- Unlocked and selected ship colours, trails, and planet themes
- Sound, music, haptic, reduced-motion, high-contrast, and trajectory-guide settings
- The UTC date associated with the locally stored daily best score

The app also records aggregate gameplay statistics in every build: completed
runs, run length, restart count, score ranges, first-landing success, and
failure reasons. These statistics contain no identifiers and are never
transmitted automatically. You can export them as a file with **Export
Gameplay Stats** in Settings and choose whether to share that file.

These files live in the app's Documents folder:

- `save.cfg`: the game profile listed above
- `playtest_metrics.json`: the aggregate gameplay statistics
- `orbit-breaker-score-*.png`: score-card images you save
- `orbit-breaker-gameplay-stats.json`: the exported statistics report

The Documents folder is visible in the Files app under **On My iPhone > Orbit
Breaker**, where you can view, copy, or delete any of these files. Because the
folder is part of the app's data, iOS includes it in device and iCloud backups
unless you exclude the app from backups in iOS Settings. The developer does not
receive any of this information through a developer-operated server in the
current version.

## Score-card images

When you choose Save Score Card, Orbit Breaker creates a PNG image from the game view and saves it in the app's Documents folder. The current version does not automatically upload the image or send it to another person or service. Any later sharing or copying that you perform through the Files app or other system tools is controlled by you and the relevant service provider.

## Daily challenge

The daily challenge uses the current UTC date to calculate a deterministic layout seed. The planet and hazard sequence is generated on the device. The layout itself is not downloaded from a developer-operated server in the current version.

If you submit a Daily Challenge score through Game Center, the score is handled as described below.

## Game Center

Orbit Breaker can use Apple Game Center for authentication, leaderboards, and achievements. When Game Center is available and you are signed in, the app may submit:

- Classic and Daily Challenge scores
- Progress toward achievements based on perfect landings, highest combo, and total landings

Game Center is operated by Apple. Apple may process your Game Center account information, player identifier, scores, achievements, friends, device information, and related service data under Apple's terms and privacy policies. Orbit Breaker does not store your Game Center account credentials.

You can manage Game Center through your Apple device settings. If Game Center is unavailable or you are not authenticated, the core game remains playable and online scores and achievements are not submitted.

Apple privacy information: https://www.apple.com/legal/privacy/

## TestFlight

If you use a beta version through TestFlight, Apple may provide the developer with TestFlight information such as device model, operating-system version, sessions, crashes, and feedback that you choose to submit. Apple controls TestFlight collection and processing. Information the developer receives through TestFlight is used to test the app, investigate defects, and improve reliability and usability.

Do not enter personal or sensitive information in free-form beta feedback unless it is necessary for support.

## Analytics, advertising, and tracking

The repository audited on 2026-08-23 does not include a developer-operated analytics service, advertising SDK, or cross-app tracking system. Orbit Breaker does not request permission to track users across apps or websites in that audited version.

This section must be updated before release if analytics, crash reporting, advertising, attribution, account services, cloud saves, or any other data-collecting SDK is added.

## Data sharing

The developer does not sell the local game profile or score-card images. Data submitted to Game Center or generated through TestFlight is handled by Apple as described above. The developer may disclose information when required by applicable law or when reasonably necessary to protect users, rights, or service security.

## Retention and deletion

Local game data remains in the app's Documents folder until you delete individual files through the Files app or delete the app. Offloading the app keeps its documents and data for a later reinstall. Restoring a device or app from an iCloud or computer backup may restore an earlier copy of these files.

To manage or delete Game Center data, use the controls Apple provides for your Apple Account and Game Center. For privacy questions concerning information directly held by the developer, email <fuannegao25@gmail.com>. The developer cannot delete information controlled solely by Apple.

## Children

Orbit Breaker is not designed to collect personal information directly from children through a developer-operated service. Game Center availability and account features are controlled by Apple, including applicable family and child-account settings. App Store Connect privacy answers must remain consistent with this policy and the saved age rating.

## Security

Orbit Breaker limits local data to gameplay progress and preferences. No method of electronic storage is completely secure, but the app does not currently transmit that local profile to a developer-operated server.

## International use

Apple may process Game Center and TestFlight information in locations described in Apple's privacy materials. The developer does not currently operate separate servers for Orbit Breaker.

## Changes to this policy

This policy may be updated when the app's features, data practices, third-party services, or legal requirements change. The published policy will display an updated effective date. Material changes should be reflected in App Store Connect privacy answers before the corresponding app version is released.

## Contact

For privacy questions, contact:

Fuanne Gao, 15041074 Canada Inc<br>
Email: <fuannegao25@gmail.com><br>
[Orbit Breaker support](https://fufunafu.github.io/Orbit-Breaker/support.html)

## Release audit record

The prepared release IPA contains no advertising, analytics, attribution,
developer account, or developer-operated networking SDK. Its privacy manifest
declares the required-reason file timestamp, system boot time, and disk-space
APIs and declares tracking as disabled. The app submits only scores and
achievement progress to Apple Game Center after authentication. Score cards and
gameplay statistics remain local unless the user chooses to share them. The
published policy and App Store Connect answers must be updated if any of these
facts change.

Apple requires a privacy-policy URL for iOS apps and requires developers to disclose their own and integrated third parties' data practices accurately. See https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
