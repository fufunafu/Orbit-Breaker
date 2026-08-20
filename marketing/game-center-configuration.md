# Game Center configuration

Enable Game Center for bundle identifier `com.antonio.orbitbreaker` in Certificates, Identifiers & Profiles and App Store Connect.

## Leaderboards

| Type | Reference name | Identifier | Score order | Recurrence |
| --- | --- | --- | --- | --- |
| Classic | Orbit Breaker All Time | `com.antonio.orbitbreaker.highscore` | High to low | Never resets |
| Recurring | Orbit Breaker Weekly | `com.antonio.orbitbreaker.weekly` | High to low | Every 7 days |
| Recurring | Orbit Breaker Daily | `com.antonio.orbitbreaker.daily` | High to low | Every 1 day |

Use integer points with a minimum score of 0. Set the all-time leaderboard as default.

## Achievements

| Name | Identifier | Points | Completion rule |
| --- | --- | --- | --- |
| Perfect Ten | `com.antonio.orbitbreaker.perfect10` | 25 | Complete 10 perfect landings across runs |
| Maximum Burn | `com.antonio.orbitbreaker.combo5` | 25 | Reach a 5x combo |
| Planet Runner | `com.antonio.orbitbreaker.planets50` | 50 | Land on 50 planets across runs |

Add localized title, achieved description, unachieved description, and artwork for every Game Center component. Submit the components with the app version for review.

## Verification

1. Sign into a sandbox or TestFlight Game Center account.
2. Confirm authentication appears once and can be dismissed.
3. Finish classic and daily runs.
4. Confirm the score appears on all applicable boards.
5. Trigger each achievement threshold.
6. Confirm leaderboard and achievement screens open from the game.
