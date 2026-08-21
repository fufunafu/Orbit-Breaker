require "csv"
require "tempfile"
require_relative "../tools/analyze_testflight"


def check(condition, message)
  raise message unless condition
end


def valid_row(tester_id, overrides = {})
  row = TestFlightAnalysis::HEADERS.to_h { |header| [header, ""] }
  row.merge!({
    "tester_id" => tester_id,
    "session_date_utc" => "2026-08-20",
    "cohort" => "occasional",
    "app_version" => "1.0",
    "build_number" => "1",
    "device_model" => "iPhone 16 Pro",
    "device_size" => "large",
    "ios_version" => "26.6",
    "mode_sequence" => "classic|daily",
    "first_launch_understood" => "yes",
    "seconds_to_first_launch" => "8.0",
    "target_understood" => "yes",
    "failure_reason_understood" => "yes",
    "perfect_landing_understood" => "yes",
    "combo_understood" => "yes",
    "first_run_score" => "7",
    "run_scores" => "7|8|8|9|18",
    "total_runs" => "5",
    "total_score" => "50",
    "average_score" => "10.0",
    "highest_score" => "18",
    "average_run_seconds" => "30.0",
    "restarts" => "4",
    "restart_rate_pct" => "80.0",
    "game_over_to_restart_seconds" => "2|3|3|5",
    "median_game_over_to_restart_seconds" => "3.0",
    "total_landings" => "25",
    "perfect_landings" => "8",
    "highest_combo" => "4",
    "fail_miss" => "2",
    "fail_asteroid" => "1",
    "fail_pulse_mine" => "1",
    "fail_wrong_planet" => "1",
    "fail_timeout" => "0",
    "daily_attempts" => "2",
    "daily_layout_match" => "yes",
    "game_center_auth_success" => "yes",
    "leaderboard_submit_success" => "yes",
    "achievement_submit_success" => "yes",
    "crash_count" => "0",
    "freeze_count" => "0",
    "severe_frame_drop_count" => "0",
    "progress_loss" => "no",
    "accessibility_settings_used" => "high_contrast",
    "zone_change_noticed" => "yes",
    "hazard_felt_impossible" => "no",
    "hazard_layout_reference" => "",
    "most_common_complaint" => "none",
    "most_requested_improvement" => "more trails",
    "moderator_help_count" => "0",
    "notes" => "",
  })
  row.merge(overrides)
end


Tempfile.create(["orbit-testflight", ".csv"]) do |file|
  CSV.open(file.path, "w") do |csv|
    csv << TestFlightAnalysis::HEADERS
    csv << valid_row("T001").values_at(*TestFlightAnalysis::HEADERS)
    csv << valid_row("T002", {
      "first_launch_understood" => "no",
      "failure_reason_understood" => "no",
      "perfect_landing_understood" => "no",
      "combo_understood" => "no",
      "first_run_score" => "0",
      "run_scores" => "0",
      "total_runs" => "1",
      "total_score" => "0",
      "average_score" => "0.0",
      "highest_score" => "0",
      "average_run_seconds" => "10.0",
      "restarts" => "0",
      "restart_rate_pct" => "0.0",
      "game_over_to_restart_seconds" => "",
      "median_game_over_to_restart_seconds" => "0.0",
      "total_landings" => "0",
      "perfect_landings" => "0",
      "highest_combo" => "1",
      "fail_miss" => "1",
      "fail_asteroid" => "0",
      "fail_pulse_mine" => "0",
      "fail_wrong_planet" => "0",
      "daily_attempts" => "0",
      "daily_layout_match" => "not_checked",
      "game_center_auth_success" => "not_tested",
      "leaderboard_submit_success" => "not_tested",
      "achievement_submit_success" => "not_tested",
      "zone_change_noticed" => "not_reached",
      "hazard_felt_impossible" => "not_reached",
      "most_common_complaint" => "launch unclear",
      "most_requested_improvement" => "clearer guide",
      "moderator_help_count" => "1",
    }).values_at(*TestFlightAnalysis::HEADERS)
    csv << valid_row("T001", {
      "session_date_utc" => "2026-08-21",
      "first_launch_understood" => "no",
    }).values_at(*TestFlightAnalysis::HEADERS)
    csv << valid_row("S001", {
      "cohort" => "smoke",
      "device_model" => "iPhone SE (3rd generation)",
      "device_size" => "small",
      "crash_count" => "1",
      "severe_frame_drop_count" => "2",
    }).values_at(*TestFlightAnalysis::HEADERS)
  end

  rows = TestFlightAnalysis.load_rows(file.path)
  data = TestFlightAnalysis.analyze(rows)
  check(data.fetch("eligible_rows") == 2, "Two unique external testers must be eligible.")
  check(data.fetch("external_session_rows") == 3, "Follow-up external sessions must remain in aggregate evidence.")
  check(data.fetch("all_rows") == 4, "Smoke sessions must remain in stability evidence.")
  check(data.fetch("first_launch_rate") == 50.0, "First-launch rate must be calculated.")
  check(data.fetch("second_run_rate") == 50.0, "Second-run rate must be calculated.")
  check(data.fetch("five_run_rate") == 50.0, "Five-run rate must be calculated.")
  check(data.fetch("restart_rate") == 800.0 / 11.0, "Restart rate must use every external session.")
  check(data.fetch("score_buckets").fetch("0") == 1, "Zero-score bucket must be counted.")
  check(data.fetch("score_buckets").fetch("5-9") == 8, "Every run score must be counted.")
  check(data.fetch("complaints") == {"launch unclear" => 1}, "Empty complaints must be ignored.")
  check(data.fetch("crash_count") == 1, "Smoke crashes must remain in stability evidence.")
  check(data.fetch("severe_frame_drop_count") == 2, "Smoke performance failures must remain in stability evidence.")
  check(data.fetch("cohort_breakdowns").fetch("occasional").fetch("count") == 2, "Cohort breakdowns must use first sessions.")
  check(data.fetch("device_size_breakdowns").fetch("large").fetch("count") == 2, "Device-size breakdowns must use first sessions.")
  report = TestFlightAnalysis.render_report(data)
  check(report.include?("Valid external first-session rows: **2**"), "Report must state its sample size.")
  check(report.include?("All valid external session rows: **3**"), "Report must state its session count.")
  check(report.include?("Severe frame drops: 2"), "Report must include stability evidence from smoke sessions.")
  check(report.include?("| occasional | 2 |"), "Report must include cohort breakdowns.")
  check(report.include?("| large | 2 |"), "Report must include device-size breakdowns.")
  check(report.include?("**NOT READY:**"), "Small samples must not produce a release decision.")
end


Tempfile.create(["orbit-testflight-nonfinite", ".csv"]) do |file|
  invalid = valid_row("T004", {"seconds_to_first_launch" => "Infinity"})
  CSV.open(file.path, "w") do |csv|
    csv << TestFlightAnalysis::HEADERS
    csv << invalid.values_at(*TestFlightAnalysis::HEADERS)
  end
  begin
    TestFlightAnalysis.load_rows(file.path)
    raise "Non-finite observations must fail."
  rescue ArgumentError => error
    check(error.message.include?("seconds_to_first_launch"), "Validation must identify the non-finite field.")
  end
end

Tempfile.create(["orbit-testflight-invalid", ".csv"]) do |file|
  invalid = valid_row("T003", {
    "hazard_felt_impossible" => "yes",
    "hazard_layout_reference" => "",
  })
  CSV.open(file.path, "w") do |csv|
    csv << TestFlightAnalysis::HEADERS
    csv << invalid.values_at(*TestFlightAnalysis::HEADERS)
  end
  begin
    TestFlightAnalysis.load_rows(file.path)
    raise "Impossible-hazard reports without layout references must fail."
  rescue ArgumentError => error
    check(error.message.include?("hazard_layout_reference"), "Validation must identify the missing reference.")
  end
end

Tempfile.create(["orbit-testflight-invalid-scores", ".csv"]) do |file|
  invalid = valid_row("T004", {
    "run_scores" => "7|8|9",
  })
  CSV.open(file.path, "w") do |csv|
    csv << TestFlightAnalysis::HEADERS
    csv << invalid.values_at(*TestFlightAnalysis::HEADERS)
  end
  begin
    TestFlightAnalysis.load_rows(file.path)
    raise "A run-score sequence that does not match total_runs must fail."
  rescue ArgumentError => error
    check(error.message.include?("run_scores count"), "Validation must identify the bad score sequence.")
  end
end

passing_rows = 20.times.map do |index|
  valid_row(format("T%03d", index + 100))
end
passing_report = TestFlightAnalysis.render_report(TestFlightAnalysis.analyze(passing_rows))
check(
  passing_report.include?("Valid external first-session rows: **20**"),
  "Twenty unique testers must satisfy the sample-size requirement."
)
check(
  passing_report.include?("**READY FOR OWNER REVIEW:**"),
  "A complete passing sample must advance to owner review without recording an automatic go decision."
)
check(
  passing_report.include?("| First launch understood | 100.0% | 80% | PASS | 20 |"),
  "A passing behavioural gate must be rendered explicitly."
)

blocked_rows = passing_rows.map(&:dup)
blocked_rows.first["progress_loss"] = "yes"
blocked_report = TestFlightAnalysis.render_report(TestFlightAnalysis.analyze(blocked_rows))
check(blocked_report.include?("**NOT READY:**"), "Critical signals must block release readiness.")
check(blocked_report.include?("Progress-loss cases: 1"), "The release blocker must be named in the report.")

puts "TESTFLIGHT_ANALYSIS_TESTS_OK"
