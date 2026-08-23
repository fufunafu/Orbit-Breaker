# App Store product page assets

All store copy (name, subtitle, promotional text, description, keywords, URLs,
review notes, age-rating notes, and Game Center text) lives in
[docs/APP_STORE_METADATA.md](../docs/APP_STORE_METADATA.md). Do not duplicate
that copy here.

## Captured screenshots

The shipping set is the four raw 1320 by 2868 captures in
`marketing/screenshots/`, produced by `tools/capture_marketing.gd` from the
release source. They contain no caption overlays; the listing copy tells the
feature story.

| Order | File | Game state | Feature shown |
| --- | --- | --- | --- |
| 1 | `01-home.png` | Ready screen with Classic, Daily Challenge, Loadout + Settings, and Leaderboards | One-tap premise and both modes |
| 2 | `02-perfect-launch.png` | Early Classic run with the guide on the perfect zone and the tutorial visible | Timing the perfect launch |
| 3 | `03-nova-hazards.png` | Nova Drift zone at a 5x combo with an asteroid and a pulse mine | Hazards, combos, and zone progression |
| 4 | `04-score-card.png` | End-of-run summary with New Best, statistics, failure reason, and actions | Replay loop and clear feedback |

The detailed capture plan, optional additional shots, and the preview video
outline are in [docs/SCREENSHOT_PLAN.md](../docs/SCREENSHOT_PLAN.md).

## App preview

`marketing/app-preview.mp4` follows the storyboard in
[app-preview-storyboard.md](app-preview-storyboard.md). CI validates its
duration, resolution, codec, frame rate, and bit rate.
