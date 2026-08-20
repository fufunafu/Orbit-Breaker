# TestFlight validation plan

## Cohort

Recruit 20 to 30 external testers across small and large supported iPhones. Include new arcade players and experienced score-chasing players.

## Test build

- Use a Release archive with Game Center enabled.
- Add the build to an external TestFlight group.
- Include the testing focus and support link in Test Information.
- Run the test for at least seven days so the weekly and daily boards both exercise reset behavior.

## Tasks

1. Launch the game without instructions from the developer.
2. Complete at least five runs.
3. Try the daily challenge on two different days.
4. Open settings and test one accessibility option.
5. Open Game Center and verify a score.
6. Send TestFlight feedback with any confusing or unfair moment.

## Measurements

Use the in-game **Export Playtest Report** action to collect aggregate, non-personal metrics:

- First-landing rate as a proxy for understanding the first launch
- Average run length
- Restart rate
- Score distribution
- Failure-reason distribution

On iPhone, retrieve the exported JSON report from **Files > On My iPhone > Orbit Breaker** and attach it to the tester's feedback.

Use TestFlight feedback for common complaints and qualitative notes. Consolidate responses without attaching player identities to gameplay metrics.

## Survey

Ask each tester:

1. Did you understand when and where to tap on your first run?
2. Did any failure feel unfair? If so, what happened?
3. Did you immediately replay after a loss? Why or why not?
4. Which sound, visual, or progression element felt most satisfying?
5. What would make you return tomorrow?

## Initial acceptance targets

- At least 70 percent of runs achieve one landing after the first session
- At least 60 percent restart rate
- No reproducible crash or save corruption
- No layout reported as impossible and no verified hazard layout below the safe-window threshold
- At least 80 percent can explain perfect landings after the tutorial
- Game Center submissions succeed for at least 90 percent of authenticated testers

Tune difficulty only after reviewing both the local aggregate report and tester comments.

Enter one pseudonymous row per session in `docs/TESTFLIGHT_SESSION_LOG.csv`, then run `ruby tools/analyze_testflight.rb`. The generated `docs/TESTFLIGHT_REPORT.md` remains not ready until at least 20 unique external testers have valid first-session evidence.
