# Orbit Breaker Privacy Policy

Status: Draft for owner review and publication<br>
Effective date: `[EFFECTIVE DATE]`<br>
Developer: `[DEVELOPER OR PUBLISHER LEGAL NAME]`<br>
Contact: `[PRIVACY CONTACT EMAIL]`

This Privacy Policy explains how Orbit Breaker handles information when you use the iOS application.

## Summary

Orbit Breaker does not currently include advertising, an app-specific account system, developer-operated analytics, or a developer-operated online service. Game progress and preferences are stored locally on your device. If you use Game Center, Apple processes Game Center information and Orbit Breaker submits gameplay results to that service.

This summary must be rechecked against the final release binary and all included third-party software before publication.

## Information stored on your device

Orbit Breaker stores a local game profile so that progress and preferences remain available between sessions. The profile may include:

- Best score and daily best score
- Total landings and total perfect landings
- Highest combo, completed-run count, and restart count
- Tutorial-completion status
- Unlocked and selected ship colours, trails, and planet themes
- Sound, music, haptic, reduced-motion, high-contrast, and trajectory-guide settings
- The UTC date associated with the locally stored daily best score

This information is stored in the app's local container. The developer does not receive it through a developer-operated server in the current version.

## Score-card images

When you choose Save Score Card, Orbit Breaker creates a PNG image from the game view and saves it in the app's local storage. The current version does not automatically upload the image or send it to another person or service. Any later sharing or copying that you perform through device or system tools is controlled by you and the relevant service provider.

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

The repository audited on 2026-08-20 does not include a developer-operated analytics service, advertising SDK, or cross-app tracking system. Orbit Breaker does not request permission to track users across apps or websites in that audited version.

This section must be updated before release if analytics, crash reporting, advertising, attribution, account services, cloud saves, or any other data-collecting SDK is added.

## Data sharing

The developer does not sell the local game profile or score-card images. Data submitted to Game Center or generated through TestFlight is handled by Apple as described above. The developer may disclose information when required by applicable law or when reasonably necessary to protect users, rights, or service security.

## Retention and deletion

Local game data remains in the app's container until it is reset by the app, removed through an available system action, or deleted when the app is uninstalled, subject to iOS backup and restore behaviour.

To manage or delete Game Center data, use the controls Apple provides for your Apple Account and Game Center. For privacy questions or deletion requests concerning information directly held by the developer, contact `[PRIVACY CONTACT EMAIL]`. The developer cannot delete information controlled solely by Apple.

## Children

Orbit Breaker is not designed to collect personal information directly from children through a developer-operated service. Game Center availability and account features are controlled by Apple, including applicable family and child-account settings. A final age-rating and privacy review must be completed before release.

## Security

Orbit Breaker limits local data to gameplay progress and preferences. No method of electronic storage is completely secure, but the app does not currently transmit that local profile to a developer-operated server.

## International use

Apple may process Game Center and TestFlight information in locations described in Apple's privacy materials. The developer does not currently operate separate servers for Orbit Breaker.

## Changes to this policy

This policy may be updated when the app's features, data practices, third-party services, or legal requirements change. The published policy will display an updated effective date. Material changes should be reflected in App Store Connect privacy answers before the corresponding app version is released.

## Contact

For privacy questions, contact:

`[DEVELOPER OR PUBLISHER LEGAL NAME]`<br>
`[PRIVACY CONTACT EMAIL]`<br>
`[POSTAL ADDRESS IF REQUIRED]`

## Publication checklist

Before publishing this policy:

- Replace every bracketed placeholder.
- Audit the final release binary and all embedded SDKs.
- Confirm whether any diagnostics, analytics, or crash data is sent outside Apple TestFlight.
- Confirm Game Center data flows on a physical device.
- Confirm the score-card save location and any share-sheet integration.
- Match App Store Connect privacy answers to the final policy.
- Publish at a stable, public HTTPS URL.
- Link the same URL from App Store Connect and, where practical, from the app or support page.

Apple requires a privacy-policy URL for iOS apps and requires developers to disclose their own and integrated third parties' data practices accurately. See https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
