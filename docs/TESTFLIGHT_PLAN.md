# Orbit Breaker TestFlight validation plan

Status: Ready for release-candidate execution<br>
Target group: 20 to 30 external testers<br>
Primary objective: Validate comprehension, replay behaviour, fairness, stability, and difficulty using observed play

## Decisions this test must support

The first TestFlight round should answer:

1. Do new players understand how to begin and launch without outside help?
2. Does the game explain why a run ended?
3. Does immediate replay create another attempt quickly?
4. Do players understand perfect landings and the combo?
5. Does difficulty rise at the right pace?
6. Are Classic and Daily runs stable and fair across supported devices?
7. Do settings solve common motion, visibility, audio, and haptic concerns?
8. Do Game Center authentication, score submission, recurring leaderboards, and achievements work on real accounts?

Do not tune the game from isolated opinions alone. Use observed sessions, the session log, TestFlight crash data, and repeated themes in comments.

## Release-candidate entry gates

Do not invite the full group until:

- The headless test suite passes from a clean checkout.
- The iOS project exports without missing resources.
- A Release build installs on at least one physical iPhone.
- Classic and Daily modes each complete at least one full run.
- The app survives background and foreground transitions during a run.
- Local progress survives app termination and relaunch.
- Game Center authenticates on a test account.
- All three leaderboard identifiers exist in App Store Connect.
- All three achievement identifiers exist in App Store Connect.
- The privacy policy and support drafts match the build being tested.
- No signing credentials or personal data are present in the repository or feedback template.

## Tester mix

Recruit 20 to 30 people across these groups:

| Cohort | Target | Reason |
| --- | ---: | --- |
| Frequent mobile arcade players | 8 to 10 | Tests mastery, scoring, and replay depth |
| Occasional mobile-game players | 8 to 10 | Tests broad clarity and difficulty |
| People who rarely play mobile games | 4 to 6 | Tests first-launch comprehension |
| People who use accessibility settings | At least 4 across cohorts | Tests motion, contrast, audio, and haptic options |

Device coverage goals:

- At least one small supported iPhone display
- At least one current large iPhone display
- At least three distinct iPhone generations
- At least two supported iOS major versions if available
- Physical devices for all haptic and Game Center validation

Use pseudonymous tester IDs such as `T001`. Keep names and invitation emails in App Store Connect, not in `TESTFLIGHT_SESSION_LOG.csv`.

## Distribution sequence

### Stage 0: Internal smoke test

Use 2 to 5 internal testers for one build.

Required checks:

- Install and launch
- First Classic run
- First Daily run
- Pause, resume, and restart
- Background and foreground transition
- Score-card save
- Settings persistence
- Game Center authentication and one score submission
- No blocker or crash

### Stage 1: Comprehension cohort

Invite 8 to 10 external testers. Observe at least five first sessions live or by screen recording with consent.

Do not explain the controls before the first attempt. Record where the player hesitates, what they tap, and what they believe the objective is.

Continue only if there is no critical crash, progress-loss issue, or widespread first-launch blocker.

### Stage 2: Full beta group

Expand to 20 to 30 total external testers. Keep everyone on the same build for comparable Daily Challenge results.

Run the build for at least seven calendar days so that weekly and daily Game Center behaviour can be observed across occurrence boundaries.

### Stage 3: Focused retest

After changes, invite at least 5 previous testers and at least 3 new testers. Previous testers verify the fix. New testers provide a clean onboarding sample.

## TestFlight listing copy

### Beta app description

Orbit Breaker is a one-tap orbital arcade game. Time each launch, land on the highlighted planet, build perfect-landing combos, survive hazards, and compare Classic and Daily Challenge scores through Game Center.

### What to Test

Please complete at least five runs. On your first run, do not ask for instructions. Tell us whether the first launch made sense, whether each failure reason was clear, and whether Replay Now felt immediate. Try Classic and Daily modes, change at least one accessibility setting, save a score card, and open Game Center leaderboards. Report any crash, progress loss, incorrect daily layout, failed Game Center submission, unreadable text, delayed input, or severe frame-rate drop.

Enter the account holder's monitored feedback address directly in App Store Connect. The public issue tracker is https://github.com/fufunafu/Orbit-Breaker/issues.

## First-session protocol

### Before play

1. Assign a pseudonymous tester ID.
2. Record app version, build, device, iOS version, and cohort.
3. Ask whether the tester frequently plays mobile arcade games.
4. Record any accessibility settings the tester normally uses.
5. Tell the tester that the game is unfinished and that the interface is being tested, not the tester.
6. Ask permission before observing or recording the screen.

### Unassisted first run

The moderator must not explain how to start or launch.

Observe:

- First tap target
- Time until the run begins
- Time until the first intentional launch
- Whether the tester identifies the highlighted target planet
- Whether the tester waits for an aiming opportunity
- Whether the failure reason is read and understood
- Whether the tester starts another run without prompting

### Structured tasks

After the first unassisted run, ask the tester to:

1. Complete at least five Classic runs.
2. Describe what creates a perfect landing.
3. Build the highest combo they can.
4. Open Settings and change Guide visibility.
5. Enable High Contrast Guide.
6. Enable Reduced Motion and compare the experience.
7. Pause, resume, then pause and restart.
8. Save a score card.
9. Complete at least two Daily runs.
10. Open Game Center leaderboards.
11. Check whether the submitted score appears.

### Closing interview

Ask these questions in order:

1. In one sentence, what are you trying to do in the game?
2. What made your best launch successful?
3. What caused your last failure?
4. What does a perfect landing change?
5. What does the combo change?
6. Did you want to press Replay Now? Why or why not?
7. When did the game become too easy or too hard?
8. Did any hazard feel impossible or unfair?
9. Did you notice the space zone change?
10. Which reward would you most want to unlock?
11. Was any text hard to read?
12. Did motion, shake, sound, music, or haptics cause discomfort?
13. Did Classic and Daily feel meaningfully different?
14. What was the most confusing moment?
15. What single change would make you play again tomorrow?

## Session-log definitions

Record one row per tester session in `TESTFLIGHT_SESSION_LOG.csv`.

### Identity and environment

- `tester_id`: Pseudonymous ID only
- `session_date_utc`: ISO date in UTC
- `cohort`: frequent, occasional, rare, or accessibility
- `app_version` and `build_number`: Tested release identifiers
- `device_model` and `ios_version`: Physical test environment
- `mode_sequence`: Order played, for example `classic|daily`

### Comprehension

- `first_launch_understood`: yes only if the first intentional launch occurred without help
- `seconds_to_first_launch`: Seconds from ready screen appearance to first intentional launch
- `target_understood`: yes only if the tester can identify the highlighted destination
- `failure_reason_understood`: yes only if the tester correctly explains the first failure
- `perfect_landing_understood`: yes only if the tester can explain the inner zone and combo effect
- `combo_understood`: yes only if the tester can explain the score multiplier

### Run metrics

- `first_run_score`: Score from the first unassisted run
- `total_runs`: Completed runs in the session
- `total_score`: Sum of all run scores
- `average_score`: Total score divided by total runs
- `highest_score`: Highest score in the session
- `average_run_seconds`: Mean duration from run start to game over
- `restarts`: Number of replays or restarts after the first run
- `restart_rate_pct`: Restarts divided by completed runs, expressed as a percentage
- `median_game_over_to_restart_seconds`: Median time from game over to the next run
- `total_landings`, `perfect_landings`, and `highest_combo`: Session totals or maximum as named

### Failure counts

Record counts for:

- `fail_miss`
- `fail_asteroid`
- `fail_pulse_mine`
- `fail_wrong_planet`
- `fail_timeout`

The sum should equal `total_runs` unless a run was abandoned, the app crashed, or the session ended while a run was active. Explain any mismatch in `notes`.

### Daily and Game Center

- `daily_attempts`: Number of Daily runs
- `daily_layout_match`: yes, no, or not_checked after comparing the same date and build
- `game_center_auth_success`: yes, no, or not_tested
- `leaderboard_submit_success`: yes, no, or not_tested
- `achievement_submit_success`: yes, no, or not_tested

### Quality and feedback

- `crash_count`: Crashes during the session
- `freeze_count`: Unresponsive incidents that required intervention
- `severe_frame_drop_count`: Visibly severe or measured frame-rate incidents
- `progress_loss`: yes or no
- `accessibility_settings_used`: Pipe-separated setting names
- `most_common_complaint`: The primary problem expressed or observed
- `most_requested_improvement`: The highest-priority requested change
- `moderator_help_count`: Number of times the moderator had to explain or intervene
- `notes`: Short factual context

## Success criteria

The first beta passes only when all critical gates and the required behavioural gates are met.

### Critical gates

- No reproducible progress-loss issue
- No critical crash in the tested release candidate
- No blocker affecting Game Center authentication or score submission on supported devices
- Same-build Daily Challenge layouts match for the same UTC date
- No tested hazard layout eliminates every valid launch window

### Behavioural gates

- At least 80 percent understand the first launch without assistance.
- At least 70 percent start a second run.
- At least 50 percent complete five or more runs in one session.
- At least 90 percent correctly understand their failure reason.
- Median game-over-to-restart time is 5 seconds or less among players who continue.
- At least 70 percent can explain perfect landings after five runs.
- At least 70 percent can explain the combo after five runs.

### Experience gates

- No repeated report that text is unreadable on a supported screen size.
- Reduced Motion materially reduces shake and background motion for affected testers.
- High Contrast Guide is distinguishable from the default guide for affected testers.
- Audio, music, and haptic toggles persist after relaunch.
- At least 60 percent notice a space-zone change among sessions that reach the first threshold.

## Analysis procedure

1. Validate every CSV row before calculating results.
2. Exclude smoke-test rows from onboarding percentages, but keep them for stability evidence.
3. Calculate metrics for the full group and separately by cohort and device size.
4. Report the sample size beside every percentage.
5. Group complaints by observed issue, not by wording alone.
6. Separate a single preference from a repeated usability failure.
7. Link every proposed change to at least one metric, observation, or repeated complaint.
8. Retest any onboarding change with new testers.

Recommended report:

| Metric | Result | Gate | Pass | Evidence count |
| --- | ---: | ---: | --- | ---: |
| First launch understood |  | 80% |  |  |
| Started second run |  | 70% |  |  |
| Completed five runs |  | 50% |  |  |
| Failure reason understood |  | 90% |  |  |
| Perfect landing understood |  | 70% |  |  |
| Combo understood |  | 70% |  |  |
| Median restart time |  | 5 sec |  |  |
| Critical crashes |  | 0 |  |  |
| Progress-loss cases |  | 0 |  |  |

## Difficulty-tuning rules

- If first-run comprehension misses the gate, improve the first prompt or guide before changing physics.
- If players understand the action but consistently miss the first target, widen the early launch window or slow early orbit speed.
- If experienced players reach late hazards easily but other cohorts fail before hazards appear, protect the early game and tune later tiers separately.
- If one hazard causes a disproportionate failure spike immediately after introduction, extend its solo teaching period before combining hazards.
- If failures are understood but feel unfair, review launch-window sampling and the specific seeded layout before changing feedback.
- If run length is high but replay rate is low, investigate reward clarity, pacing, and end-of-run motivation.
- Do not alter several physics constants in the same beta build unless the intended effect can still be isolated.

## Defect severity

| Severity | Definition | Response |
| --- | --- | --- |
| Critical | Crash loop, progress loss, impossible gameplay, privacy issue, or signing/authentication blocker affecting most testers | Stop rollout and replace the build |
| High | Reproducible failed score submission, Daily mismatch, inaccessible primary action, or common run-ending defect | Fix before release candidate |
| Medium | Confusing feedback, layout issue, setting persistence bug, or device-specific presentation problem | Prioritize and retest |
| Low | Cosmetic issue, isolated copy problem, or non-blocking polish request | Track for current or later release |

## Build comparison log

For each beta build, record:

| Build | Date | Hypothesis | Changes under test | Tester count | Result | Decision |
| --- | --- | --- | --- | ---: | --- | --- |
| `[BUILD]` | `[UTC DATE]` | `[HYPOTHESIS]` | `[CHANGES]` |  |  |  |

## Completion criteria

TestFlight validation is complete when:

- 20 to 30 testers have been invited and the accepted/installed count is recorded.
- At least 20 valid first-session rows exist.
- The build has run across at least one Daily and one Weekly leaderboard boundary.
- Every critical and behavioural gate has a measured result.
- Common complaints are ranked by frequency and severity.
- Difficulty decisions cite observed data.
- Fixes for failed critical gates are retested.
- A release decision is recorded as go, conditional go, or no-go with named owners.

## Apple references

- TestFlight overview: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview
- Invite external testers: https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers
- TestFlight tester information: https://developer.apple.com/help/app-store-connect/reference/testflight/testflight-tester-information
- Game Center testing: https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-testing-game-center
