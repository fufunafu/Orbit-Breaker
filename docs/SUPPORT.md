# Orbit Breaker Support

Public support: https://fufunafu.github.io/Orbit-Breaker/support.html<br>
App version: 1.0

## How to play

Orbit Breaker is a one-tap timing game.

1. Choose Classic or Daily from the ready screen.
2. Watch your ship orbit the current planet.
3. Tap when its tangent points toward the highlighted target planet.
4. Land inside the inner target area for a perfect landing and a larger combo.
5. Keep climbing until you miss or hit a hazard.

The trajectory guide can be set to Off, Tutorial, or Always in Settings.

## Controls

- Tap while orbiting: launch
- Pause button: pause the active run
- Resume: continue a paused run
- Restart: immediately begin the current mode again
- Replay Now: restart after game over
- Save Score Card: save a PNG image inside the app's local storage
- Leaderboards: open Game Center leaderboards when Game Center is available

## Settings

Orbit Breaker includes controls for:

- Sound effects
- Music
- Haptics
- Reduced motion and screen shake
- High-contrast trajectory guide
- Guide visibility
- Unlocked ship colour
- Unlocked trail
- Unlocked planet theme

Settings and unlocked items are saved locally.

## Why did my run end?

The game-over panel reports the cause:

- **Drifted into deep space:** the launch missed the target or left the playable area.
- **Struck an asteroid:** the ship crossed an asteroid before reaching the target.
- **Caught in a pulse mine:** the ship entered the mine's active collision radius.
- **Collided with a dead orbit:** the ship struck a non-target planet or obstruction.
- **Signal timed out:** the ship remained in flight beyond the allowed time.

The same panel shows score, best score, landings, perfect landings, highest combo, unlocks, and New Best status.

## Daily Challenge

The Daily Challenge changes at 00:00 UTC. Everyone using the same game version receives a layout generated from the same UTC date seed.

If two players see different layouts, confirm:

- Both devices use the same Orbit Breaker version and build.
- Both devices have the correct date and time.
- Both players selected Daily rather than Classic.
- Neither run crossed the 00:00 UTC date boundary before restarting.

## Game Center troubleshooting

If leaderboards or achievements do not appear:

1. Confirm that the device is connected to the internet.
2. Confirm that Game Center is enabled and signed in under iOS Settings.
3. Restart Orbit Breaker and allow the Game Center authentication prompt to complete.
4. Complete a run before checking whether a score was submitted.
5. Confirm that the app is a TestFlight or App Store build with Game Center enabled.
6. During beta testing, confirm that the required leaderboard and achievement components are active for the tested app version in App Store Connect.

The game remains playable without Game Center, but online scores and achievement progress cannot be submitted.

## Progress or settings did not save

Orbit Breaker stores progress in its local app container.

- Avoid force-quitting the app immediately after changing a setting or ending a run.
- Confirm that sufficient device storage is available.
- Deleting the app removes its local progress, settings, and saved score cards
  from the device. Restoring an iPhone backup may restore an earlier copy.
- Offloading the app keeps its documents and data so they are available after
  the app is reinstalled.
- Restoring a device or app from backup may restore older local data.
- If save data is invalid, the game safely starts from default progress rather than blocking play.

There is currently no developer-operated cloud-save or account-recovery service.
Apple documents the difference between offloading and deleting in
[Manage storage on iPhone](https://support.apple.com/guide/iphone/manage-storage-on-iphone-iph47c931112/ios).

## Score-card troubleshooting

Save Score Card writes an image to the app's local Godot user-data location. The current version does not automatically add the image to Photos and does not open the iOS share sheet.

If saving fails, include that fact in a bug report along with the device, iOS version, app build, and available storage. Do not send a score-card image if it contains anything you do not want included in a support message.

## Audio, haptic, or motion concerns

- Check Orbit Breaker's Sound, Music, and Haptics toggles.
- Check device volume, silent mode, Focus settings, and system haptic settings.
- Enable Reduced Motion to reduce animated background changes and disable gameplay screen shake.
- Enable High Contrast Guide if the default trajectory guide is hard to see.
- Set Guide to Always if you want the trajectory guide throughout every run.

## Report a bug

Open an issue at https://github.com/fufunafu/Orbit-Breaker/issues with:

- Orbit Breaker version and build number
- iPhone model
- iOS version
- Classic or Daily mode
- UTC date if the issue involved Daily Challenge
- What you expected
- What happened
- Exact steps that reproduce the issue
- Failure reason displayed, if relevant
- Whether Game Center was signed in
- Accessibility settings in use
- Screenshot or TestFlight feedback, if helpful

Never include an Apple Account password, App Store Connect credential, provisioning profile, private key, or other secret.

## Privacy

Read the [Orbit Breaker Privacy Policy](https://fufunafu.github.io/Orbit-Breaker/privacy.html).

## Contact

Developer: Fuanne Gao<br>
Support page: https://fufunafu.github.io/Orbit-Breaker/support.html<br>
Issue tracker: https://github.com/fufunafu/Orbit-Breaker/issues
