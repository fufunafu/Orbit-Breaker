#!/usr/bin/env ruby

require "csv"
require "date"

module TestFlightAnalysis
  HEADERS = %w[
    tester_id session_date_utc cohort app_version build_number device_model
    device_size ios_version mode_sequence first_launch_understood seconds_to_first_launch
    target_understood failure_reason_understood perfect_landing_understood
    combo_understood first_run_score run_scores total_runs total_score average_score
    highest_score average_run_seconds restarts restart_rate_pct game_over_to_restart_seconds
    median_game_over_to_restart_seconds total_landings perfect_landings
    highest_combo fail_miss fail_asteroid fail_pulse_mine fail_wrong_planet
    fail_timeout daily_attempts daily_layout_match game_center_auth_success
    leaderboard_submit_success achievement_submit_success crash_count
    freeze_count severe_frame_drop_count progress_loss
    accessibility_settings_used zone_change_noticed hazard_felt_impossible
    hazard_layout_reference most_common_complaint most_requested_improvement
    moderator_help_count notes
  ].freeze

  INTEGER_FIELDS = %w[
    build_number first_run_score total_runs total_score highest_score restarts
    total_landings perfect_landings highest_combo fail_miss fail_asteroid
    fail_pulse_mine fail_wrong_planet fail_timeout daily_attempts crash_count
    freeze_count severe_frame_drop_count moderator_help_count
  ].freeze

  DECIMAL_FIELDS = %w[
    seconds_to_first_launch average_score average_run_seconds restart_rate_pct
    median_game_over_to_restart_seconds
  ].freeze

  REQUIRED_TEXT_FIELDS = %w[
    tester_id session_date_utc cohort app_version device_model ios_version
    mode_sequence most_common_complaint most_requested_improvement
  ].freeze

  YES_NO_FIELDS = %w[
    first_launch_understood target_understood failure_reason_understood
    perfect_landing_understood combo_understood progress_loss
  ].freeze

  ENUM_FIELDS = {
    "cohort" => %w[frequent occasional rare accessibility internal smoke],
    "device_size" => %w[small standard large],
    "daily_layout_match" => %w[yes no not_checked],
    "game_center_auth_success" => %w[yes no not_tested],
    "leaderboard_submit_success" => %w[yes no not_tested],
    "achievement_submit_success" => %w[yes no not_tested],
    "zone_change_noticed" => %w[yes no not_reached],
    "hazard_felt_impossible" => %w[yes no not_reached],
  }.freeze

  SCORE_BUCKETS = {
    "0" => 0..0,
    "1-4" => 1..4,
    "5-9" => 5..9,
    "10-24" => 10..24,
    "25+" => 25..Float::INFINITY,
  }.freeze

  module_function

  def load_rows(path)
    table = CSV.read(path, headers: true, encoding: "bom|utf-8")
    actual_headers = table.headers || []
    unless actual_headers == HEADERS
      missing = HEADERS - actual_headers
      extra = actual_headers - HEADERS
      raise ArgumentError,
        "unexpected CSV headers; missing=#{missing.inspect} extra=#{extra.inspect}"
    end

    rows = table.map.with_index(2) do |row, line_number|
      values = row.to_h.transform_values { |value| value.to_s.strip }
      validate_row(values, line_number)
      values
    end

    duplicates = rows.group_by do |row|
      [row.fetch("tester_id"), row.fetch("session_date_utc"), row.fetch("build_number")]
    end.select { |_key, values| values.length > 1 }.keys
    unless duplicates.empty?
      raise ArgumentError, "duplicate tester/date/build rows: #{duplicates.inspect}"
    end
    rows
  rescue CSV::MalformedCSVError => error
    raise ArgumentError, "malformed CSV: #{error.message}"
  end

  def validate_row(row, line_number)
    REQUIRED_TEXT_FIELDS.each do |field|
      raise ArgumentError, "line #{line_number}: #{field} is required" if row.fetch(field).empty?
    end

    begin
      parsed_date = Date.iso8601(row.fetch("session_date_utc"))
      unless parsed_date.iso8601 == row.fetch("session_date_utc")
        raise ArgumentError
      end
    rescue ArgumentError # Date::Error subclasses ArgumentError and is absent on Ruby < 3.0
      raise ArgumentError, "line #{line_number}: session_date_utc must be YYYY-MM-DD"
    end

    INTEGER_FIELDS.each do |field|
      value = parse_integer(row.fetch(field), line_number, field)
      raise ArgumentError, "line #{line_number}: #{field} must be nonnegative" if value.negative?
    end

    if row.fetch("build_number").to_i < 1
      raise ArgumentError, "line #{line_number}: build_number must be at least 1"
    end

    DECIMAL_FIELDS.each do |field|
      value = parse_decimal(row.fetch(field), line_number, field)
      raise ArgumentError, "line #{line_number}: #{field} must be nonnegative" if value.negative?
    end

    YES_NO_FIELDS.each do |field|
      validate_enum(row, line_number, field, %w[yes no])
    end
    ENUM_FIELDS.each do |field, values|
      validate_enum(row, line_number, field, values)
    end

    modes = row.fetch("mode_sequence").split("|", -1)
    unless modes.any? && modes.all? { |mode| %w[classic daily].include?(mode) }
      raise ArgumentError, "line #{line_number}: mode_sequence must contain classic or daily values"
    end

    total_runs = row.fetch("total_runs").to_i
    raise ArgumentError, "line #{line_number}: total_runs must be at least 1" if total_runs < 1

    run_scores = parse_number_list(row.fetch("run_scores"), line_number, "run_scores", integer: true)
    unless run_scores.length == total_runs
      raise ArgumentError, "line #{line_number}: run_scores count must match total_runs"
    end
    unless run_scores.first == row.fetch("first_run_score").to_i
      raise ArgumentError, "line #{line_number}: first_run_score must match the first run_scores value"
    end
    unless run_scores.sum == row.fetch("total_score").to_i
      raise ArgumentError, "line #{line_number}: total_score must match the run_scores sum"
    end
    unless run_scores.max == row.fetch("highest_score").to_i
      raise ArgumentError, "line #{line_number}: highest_score must match the highest run_scores value"
    end

    expected_average = run_scores.sum.to_f / total_runs
    unless (row.fetch("average_score").to_f - expected_average).abs <= 0.05
      raise ArgumentError, "line #{line_number}: average_score does not match total_score / total_runs"
    end

    expected_restart_rate = row.fetch("restarts").to_f * 100.0 / total_runs
    unless (row.fetch("restart_rate_pct").to_f - expected_restart_rate).abs <= 0.1
      raise ArgumentError, "line #{line_number}: restart_rate_pct does not match restarts / total_runs"
    end
    if row.fetch("restarts").to_i > total_runs
      raise ArgumentError, "line #{line_number}: restarts exceed total_runs"
    end

    restart_times = parse_number_list(
      row.fetch("game_over_to_restart_seconds"),
      line_number,
      "game_over_to_restart_seconds",
      allow_empty: true
    )
    if restart_times.length > row.fetch("restarts").to_i
      raise ArgumentError, "line #{line_number}: restart timing count exceeds restarts"
    end
    if restart_times.empty?
      unless row.fetch("median_game_over_to_restart_seconds").to_f.zero?
        raise ArgumentError, "line #{line_number}: restart median must be zero when no timings are recorded"
      end
    else
      expected_median = median(restart_times)
      unless (row.fetch("median_game_over_to_restart_seconds").to_f - expected_median).abs <= 0.05
        raise ArgumentError, "line #{line_number}: restart median does not match game_over_to_restart_seconds"
      end
    end

    if row.fetch("perfect_landings").to_i > row.fetch("total_landings").to_i
      raise ArgumentError, "line #{line_number}: perfect_landings exceed total_landings"
    end
    unless (1..5).cover?(row.fetch("highest_combo").to_i)
      raise ArgumentError, "line #{line_number}: highest_combo must be from 1 through 5"
    end
    if row.fetch("daily_attempts").to_i > total_runs
      raise ArgumentError, "line #{line_number}: daily_attempts exceed total_runs"
    end
    if row.fetch("daily_attempts").to_i.zero? && row.fetch("daily_layout_match") != "not_checked"
      raise ArgumentError, "line #{line_number}: daily_layout_match must be not_checked without a Daily attempt"
    end
    if row.fetch("highest_score").to_i < 10 && row.fetch("zone_change_noticed") != "not_reached"
      raise ArgumentError, "line #{line_number}: zone_change_noticed must be not_reached below score 10"
    end
    if row.fetch("highest_score").to_i >= 10 && row.fetch("zone_change_noticed") == "not_reached"
      raise ArgumentError, "line #{line_number}: zone_change_noticed must be yes or no after score 10"
    end

    failure_total = %w[
      fail_miss fail_asteroid fail_pulse_mine fail_wrong_planet fail_timeout
    ].sum { |field| row.fetch(field).to_i }
    if failure_total > total_runs
      raise ArgumentError, "line #{line_number}: failure counts exceed total_runs"
    end

    if row.fetch("hazard_felt_impossible") == "yes" && row.fetch("hazard_layout_reference").empty?
      raise ArgumentError,
        "line #{line_number}: hazard_layout_reference is required for an impossible-hazard report"
    end
  end

  def analyze(rows)
    external = rows.reject { |row| %w[internal smoke].include?(row.fetch("cohort").downcase) }
    first_sessions = external.group_by { |row| row.fetch("tester_id") }.values.map do |tester_rows|
      tester_rows.min_by do |row|
        [Date.iso8601(row.fetch("session_date_utc")), row.fetch("build_number").to_i]
      end
    end
    total_runs = external.sum { |row| row.fetch("total_runs").to_i }
    total_restarts = external.sum { |row| row.fetch("restarts").to_i }
    weighted_run_seconds = external.sum do |row|
      row.fetch("average_run_seconds").to_f * row.fetch("total_runs").to_i
    end

    restart_times = external.flat_map do |row|
      parse_number_list(row.fetch("game_over_to_restart_seconds"), 0, "game_over_to_restart_seconds", allow_empty: true)
    end
    zone_rows = external.select { |row| %w[yes no].include?(row.fetch("zone_change_noticed")) }

    cohort_groups = first_sessions.group_by { |row| row.fetch("cohort") }
    device_size_groups = first_sessions.group_by { |row| row.fetch("device_size") }

    {
      "all_rows" => rows.length,
      "external_session_rows" => external.length,
      "eligible_rows" => first_sessions.length,
      "total_runs" => total_runs,
      "first_launch_rate" => yes_rate(first_sessions, "first_launch_understood"),
      "second_run_rate" => predicate_rate(first_sessions) { |row| row.fetch("total_runs").to_i >= 2 },
      "five_run_rate" => predicate_rate(first_sessions) { |row| row.fetch("total_runs").to_i >= 5 },
      "failure_understanding_rate" => yes_rate(first_sessions, "failure_reason_understood"),
      "perfect_understanding_rate" => yes_rate(first_sessions, "perfect_landing_understood"),
      "combo_understanding_rate" => yes_rate(first_sessions, "combo_understood"),
      "restart_rate" => percentage(total_restarts, total_runs),
      "median_restart_seconds" => median(restart_times),
      "median_restart_count" => restart_times.length,
      "average_run_seconds" => total_runs.zero? ? nil : weighted_run_seconds / total_runs,
      "zone_notice_rate" => yes_rate(zone_rows, "zone_change_noticed"),
      "zone_notice_count" => zone_rows.length,
      "crash_count" => rows.sum { |row| row.fetch("crash_count").to_i },
      "freeze_count" => rows.sum { |row| row.fetch("freeze_count").to_i },
      "severe_frame_drop_count" => rows.sum { |row| row.fetch("severe_frame_drop_count").to_i },
      "progress_loss_count" => rows.count { |row| row.fetch("progress_loss") == "yes" },
      "daily_mismatch_count" => rows.count { |row| row.fetch("daily_layout_match") == "no" },
      "game_center_auth_failure_count" => rows.count { |row| row.fetch("game_center_auth_success") == "no" },
      "leaderboard_failure_count" => rows.count { |row| row.fetch("leaderboard_submit_success") == "no" },
      "achievement_failure_count" => rows.count { |row| row.fetch("achievement_submit_success") == "no" },
      "impossible_hazard_count" => rows.count { |row| row.fetch("hazard_felt_impossible") == "yes" },
      "score_buckets" => score_buckets(external),
      "complaints" => ranked_text(external, "most_common_complaint"),
      "requested_improvements" => ranked_text(external, "most_requested_improvement"),
      "cohorts" => first_sessions.group_by { |row| row.fetch("cohort") }.transform_values(&:length),
      "devices" => external.group_by { |row| row.fetch("device_model") }.transform_values(&:length),
      "device_sizes" => first_sessions.group_by { |row| row.fetch("device_size") }.transform_values(&:length),
      "cohort_breakdowns" => cohort_groups.transform_values { |group| behavioral_breakdown(group) },
      "device_size_breakdowns" => device_size_groups.transform_values { |group| behavioral_breakdown(group) },
    }
  end

  def render_report(data)
    rows = data.fetch("eligible_rows")
    lines = [
      "# Orbit Breaker TestFlight findings",
      "",
      "This report is generated from `docs/TESTFLIGHT_SESSION_LOG.csv`.",
      "Smoke and internal sessions are excluded from behavioural percentages.",
      "",
      "Valid external first-session rows: **#{rows}**",
      "All valid external session rows: **#{data.fetch("external_session_rows")}**",
      "",
      "## Behavioural gates",
      "",
      "| Metric | Result | Gate | Status | Evidence count |",
      "| --- | ---: | ---: | --- | ---: |",
      gate_row("First launch understood", data["first_launch_rate"], 80.0, rows),
      gate_row("Started a second run", data["second_run_rate"], 70.0, rows),
      gate_row("Completed five runs", data["five_run_rate"], 50.0, rows),
      gate_row("Failure reason understood", data["failure_understanding_rate"], 90.0, rows),
      gate_row("Perfect landing understood", data["perfect_understanding_rate"], 70.0, rows),
      gate_row("Combo understood", data["combo_understanding_rate"], 70.0, rows),
      seconds_gate_row(
        "Median game-over-to-restart",
        data["median_restart_seconds"],
        5.0,
        data["median_restart_count"]
      ),
      gate_row("Zone change noticed", data["zone_notice_rate"], 60.0, data["zone_notice_count"]),
      "",
      "## Aggregate play",
      "",
      "- Total completed runs: #{data.fetch("total_runs")}",
      "- Overall restart rate: #{format_percentage(data["restart_rate"])} (#{data.fetch("external_session_rows")} sessions, #{data.fetch("total_runs")} runs)",
      "- Weighted average run length: #{format_seconds(data["average_run_seconds"])} (#{data.fetch("total_runs")} runs)",
      "- Run score distribution: #{format_counts(data.fetch("score_buckets"))}",
      "",
      "## Critical signals",
      "",
      "These totals include all #{data.fetch("all_rows")} external, internal, and smoke session rows.",
      "",
      "- Crashes: #{data.fetch("crash_count")}",
      "- Freezes: #{data.fetch("freeze_count")}",
      "- Severe frame drops: #{data.fetch("severe_frame_drop_count")}",
      "- Progress-loss cases: #{data.fetch("progress_loss_count")}",
      "- Daily layout mismatches: #{data.fetch("daily_mismatch_count")}",
      "- Game Center authentication failures: #{data.fetch("game_center_auth_failure_count")}",
      "- Leaderboard submission failures: #{data.fetch("leaderboard_failure_count")}",
      "- Achievement submission failures: #{data.fetch("achievement_failure_count")}",
      "- Impossible-hazard reports: #{data.fetch("impossible_hazard_count")}",
      "",
      "## Coverage",
      "",
      "- Cohorts: #{format_counts(data.fetch("cohorts"))}",
      "- Devices: #{format_counts(data.fetch("devices"))}",
      "- Device sizes: #{format_counts(data.fetch("device_sizes"))}",
      "",
      "## Behavioural breakdowns",
      "",
      breakdown_table("Cohort", data.fetch("cohort_breakdowns")),
      "",
      breakdown_table("Device size", data.fetch("device_size_breakdowns")),
      "",
      "## Ranked feedback",
      "",
      "- Common complaints: #{format_counts(data.fetch("complaints"))}",
      "- Requested improvements: #{format_counts(data.fetch("requested_improvements"))}",
      "",
      "## Release interpretation",
      "",
    ]

    blockers = release_blockers(data)
    if rows < 20
      lines << "**NOT READY:** At least 20 valid external first-session rows are required before a release decision."
    elsif blockers.any?
      lines << "**NOT READY:** The evidence contains unresolved release blockers:"
      lines << ""
      blockers.each { |blocker| lines << "- #{blocker}" }
    else
      lines << "**READY FOR OWNER REVIEW:** The measured TestFlight gates pass. Complete the remaining release checklist before recording a go decision."
    end
    lines << ""
    lines.join("\n")
  end

  def write_report(csv_path, output_path)
    data = analyze(load_rows(csv_path))
    File.write(output_path, render_report(data))
    data
  end

  def parse_integer(value, line_number, field)
    Integer(value, 10)
  rescue ArgumentError
    raise ArgumentError, "line #{line_number}: #{field} must be an integer"
  end

  def parse_decimal(value, line_number, field)
    number = Float(value)
    raise ArgumentError unless number.finite?
    number
  rescue ArgumentError
    raise ArgumentError, "line #{line_number}: #{field} must be numeric"
  end

  def parse_number_list(value, line_number, field, integer: false, allow_empty: false)
    return [] if allow_empty && value.empty?
    values = value.split("|", -1)
    if values.empty? || values.any?(&:empty?)
      raise ArgumentError, "line #{line_number}: #{field} must be a pipe-separated number list"
    end
    values.map do |item|
      number = integer ? Integer(item, 10) : Float(item)
      raise ArgumentError if number.negative? || (!integer && !number.finite?)
      number
    rescue ArgumentError
      kind = integer ? "nonnegative integers" : "nonnegative numbers"
      raise ArgumentError, "line #{line_number}: #{field} must contain #{kind}"
    end
  end

  def validate_enum(row, line_number, field, allowed)
    value = row.fetch(field)
    return if allowed.include?(value)
    raise ArgumentError, "line #{line_number}: #{field} must be one of #{allowed.join(", ")}"
  end

  def yes_rate(rows, field)
    predicate_rate(rows) { |row| row.fetch(field) == "yes" }
  end

  def predicate_rate(rows, &block)
    percentage(rows.count(&block), rows.length)
  end

  def percentage(numerator, denominator)
    return nil if denominator.zero?
    numerator.to_f * 100.0 / denominator
  end

  def median(values)
    return nil if values.empty?
    sorted = values.sort
    midpoint = sorted.length / 2
    return sorted[midpoint] if sorted.length.odd?
    (sorted[midpoint - 1] + sorted[midpoint]) / 2.0
  end

  def score_buckets(rows)
    scores = rows.flat_map do |row|
      parse_number_list(row.fetch("run_scores"), 0, "run_scores", integer: true)
    end
    SCORE_BUCKETS.to_h do |name, range|
      [name, scores.count { |score| range.cover?(score) }]
    end
  end

  def ranked_text(rows, field)
    ignored = ["", "none", "n/a", "na"]
    values = rows.map { |row| row.fetch(field).strip.downcase }.reject { |value| ignored.include?(value) }
    counts = values.each_with_object(Hash.new(0)) { |value, result| result[value] += 1 }
    counts.sort_by { |text, count| [-count, text] }.to_h
  end

  def behavioral_breakdown(rows)
    {
      "count" => rows.length,
      "first_launch_rate" => yes_rate(rows, "first_launch_understood"),
      "second_run_rate" => predicate_rate(rows) { |row| row.fetch("total_runs").to_i >= 2 },
      "five_run_rate" => predicate_rate(rows) { |row| row.fetch("total_runs").to_i >= 5 },
      "failure_understanding_rate" => yes_rate(rows, "failure_reason_understood"),
      "perfect_understanding_rate" => yes_rate(rows, "perfect_landing_understood"),
      "combo_understanding_rate" => yes_rate(rows, "combo_understood"),
    }
  end

  def release_blockers(data)
    minimum_gates = {
      "First launch understood is below 80%" => [data["first_launch_rate"], 80.0],
      "Second-run rate is below 70%" => [data["second_run_rate"], 70.0],
      "Five-run completion is below 50%" => [data["five_run_rate"], 50.0],
      "Failure understanding is below 90%" => [data["failure_understanding_rate"], 90.0],
      "Perfect-landing understanding is below 70%" => [data["perfect_understanding_rate"], 70.0],
      "Combo understanding is below 70%" => [data["combo_understanding_rate"], 70.0],
      "Zone recognition is below 60% or not measured" => [data["zone_notice_rate"], 60.0],
    }
    blockers = minimum_gates.each_with_object([]) do |(message, values), result|
      measurement, minimum = values
      result << message if measurement.nil? || measurement < minimum
    end
    if data["median_restart_seconds"].nil? || data["median_restart_seconds"] > 5.0
      blockers << "Median game-over-to-restart time exceeds 5 seconds or is not measured"
    end

    critical_counts = {
      "Crashes" => "crash_count",
      "Freezes" => "freeze_count",
      "Progress-loss cases" => "progress_loss_count",
      "Daily layout mismatches" => "daily_mismatch_count",
      "Game Center authentication failures" => "game_center_auth_failure_count",
      "Leaderboard submission failures" => "leaderboard_failure_count",
      "Achievement submission failures" => "achievement_failure_count",
      "Impossible-hazard reports" => "impossible_hazard_count",
    }
    critical_counts.each do |label, key|
      count = data.fetch(key)
      blockers << "#{label}: #{count}" if count.positive?
    end
    blockers
  end

  def breakdown_table(group_label, groups)
    lines = [
      "| #{group_label} | Testers | First launch | Second run | Five runs | Failure understood | Perfect understood | Combo understood |",
      "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    if groups.empty?
      lines << "| None recorded | 0 | Not measured | Not measured | Not measured | Not measured | Not measured | Not measured |"
    else
      groups.sort_by { |name, _values| name }.each do |name, values|
        lines << "| #{name} | #{values.fetch("count")} | #{format_percentage(values["first_launch_rate"])} | #{format_percentage(values["second_run_rate"])} | #{format_percentage(values["five_run_rate"])} | #{format_percentage(values["failure_understanding_rate"])} | #{format_percentage(values["perfect_understanding_rate"])} | #{format_percentage(values["combo_understanding_rate"])} |"
      end
    end
    lines.join("\n")
  end

  def gate_row(label, result, gate, count)
    status = result.nil? ? "NOT MEASURED" : result >= gate ? "PASS" : "FAIL"
    "| #{label} | #{format_percentage(result)} | #{gate.round}% | #{status} | #{count} |"
  end

  def seconds_gate_row(label, result, gate, count)
    status = result.nil? ? "NOT MEASURED" : result <= gate ? "PASS" : "FAIL"
    "| #{label} | #{format_seconds(result)} | <= #{gate.round} sec | #{status} | #{count} intervals |"
  end

  def format_percentage(value)
    value.nil? ? "Not measured" : format("%.1f%%", value)
  end

  def format_seconds(value)
    value.nil? ? "Not measured" : format("%.1f sec", value)
  end

  def format_counts(values)
    return "None recorded" if values.empty?
    values.map { |name, count| "#{name}: #{count}" }.join(", ")
  end
end

if $PROGRAM_NAME == __FILE__
  csv_path = ARGV.fetch(0, "docs/TESTFLIGHT_SESSION_LOG.csv")
  output_path = ARGV.fetch(1, "docs/TESTFLIGHT_REPORT.md")
  data = TestFlightAnalysis.write_report(csv_path, output_path)
  puts "TESTFLIGHT_ANALYSIS_OK rows=#{data.fetch("all_rows")} report=#{output_path}"
end
