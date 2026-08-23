# Game Center configuration

Enable Game Center for bundle identifier `com.antonio.orbitbreaker` in Certificates, Identifiers & Profiles and App Store Connect.

## Leaderboards

| Type | Reference name | Identifier | Score order | Recurrence |
| --- | --- | --- | --- | --- |
| Classic | Orbit Breaker All Time | `com.antonio.orbitbreaker.highscore` | High to low | Never resets |
| Recurring | Orbit Breaker Weekly | `com.antonio.orbitbreaker.weekly` | High to low | Every 7 days |
| Recurring | Orbit Breaker Daily | `com.antonio.orbitbreaker.daily` | High to low | Every 1 day |

Use integer points with a minimum score of 0. Set the all-time leaderboard as default.

Every completed run posts to the all-time and weekly boards. Daily Challenge
runs additionally post to the daily board, so a Daily score can also become a
player's all-time or weekly best.

### Daily version compatibility

Version 1 uses the three identifiers above for every 1.x build whose scoring,
physics, hazard timing, and Daily layout generation remain competitively
equivalent. A future build that materially changes any of those rules must not
mix its Daily scores into the existing recurring occurrence. Before releasing
such a build, create a versioned Daily leaderboard identifier, update the code
and metadata together, and begin the new recurrence at 00:00 UTC. Cosmetic,
copy, accessibility, and crash-only updates may keep the current identifiers
when they do not affect score comparability.

## Achievements

| Name | Identifier | Points | Completion rule | Image |
| --- | --- | --- | --- | --- |
| Perfect Ten | `com.antonio.orbitbreaker.perfect10` | 25 | Complete 10 perfect landings across runs | `game-center-achievements/perfect-ten.png` |
| Maximum Burn | `com.antonio.orbitbreaker.combo5` | 25 | Reach a 5x combo | `game-center-achievements/maximum-burn.png` |
| Planet Runner | `com.antonio.orbitbreaker.planets50` | 50 | Land on 50 planets across runs | `game-center-achievements/planet-runner.png` |

Configure all three as visible, non-repeatable achievements.

### English localization

| Name | Pre-earned description | Earned description |
| --- | --- | --- |
| Perfect Ten | Complete 10 perfect landings. | You completed 10 perfect landings. |
| Maximum Burn | Reach a 5x combo in one run. | You reached maximum burn with a 5x combo. |
| Planet Runner | Land on 50 planets across all runs. | You landed on 50 planets and carried the signal onward. |

The three supplied images are 1024 by 1024 RGB PNG files at 72 ppi without alpha. They keep their important content centered for Game Center's circular mask. Add localized title, pre-earned description, earned description, and the matching image for every achievement, then submit the components with the app version for review.

## Verification

1. Sign into a sandbox or TestFlight Game Center account.
2. Confirm authentication appears once and can be dismissed.
3. Finish classic and daily runs.
4. Confirm the score appears on all applicable boards.
5. Trigger each achievement threshold.
6. Confirm leaderboard and achievement screens open from the game.
