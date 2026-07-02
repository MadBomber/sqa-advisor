# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

task default: :test

desc "Check code style with RuboCop"
task :rubocop do
  sh "bundle exec rubocop --format simple"
end

desc "Auto-correct RuboCop offenses"
task :rubocop_fix do
  sh "bundle exec rubocop -a"
end

FLOG_WARN_THRESHOLD = 20.0
FLOG_FAIL_THRESHOLD = 50.0

# Methods exempted from the failure threshold.
# These are data-extraction execute methods whose Flog score reflects
# the number of fields fetched, not logical complexity.
FLOG_EXCEPTIONS = %w[
  SQA::Advisor::Tools::StockPrice#execute
  SQA::Advisor::Tools::StockInfo#execute
  SQA::Advisor::Tools::StockRecommendations#execute
  SQA::Advisor::Tools::StockDividends#execute
  SQA::Advisor::Tools::BalanceSheet#execute
  SQA::Advisor::Tools::WebSearch#extract_result
  SQA::Advisor::Tools::StockTechnicalAnalysis#execute
].freeze

desc "Check code complexity with Flog (warn ≥20, fail ≥50)"
task :flog_check do
  require "flog"

  flogger = Flog.new(all: true)
  flogger.flog(*Dir.glob("lib/**/*.rb"))

  warnings = []
  failures = []

  flogger.each_by_score do |method, score|
    next if method.end_with?("#none")
    next if FLOG_EXCEPTIONS.include?(method)

    if score > FLOG_FAIL_THRESHOLD
      failures << "#{format("%.1f", score)}: #{method}"
    elsif score > FLOG_WARN_THRESHOLD
      warnings << "#{format("%.1f", score)}: #{method}"
    end
  end

  unless warnings.empty?
    puts "\nFlog warnings (#{FLOG_WARN_THRESHOLD}–#{FLOG_FAIL_THRESHOLD}) — target for future refactoring:"
    warnings.each { |v| puts "  #{v}" }
  end

  if failures.empty?
    puts "\nFlog: no methods exceed the failure threshold (≥#{FLOG_FAIL_THRESHOLD})"
  else
    puts "\nFlog failures (≥#{FLOG_FAIL_THRESHOLD}) — must be refactored:"
    failures.each { |v| puts "  #{v}" }
    abort "\nFlog quality gate failed: #{failures.size} method(s) exceed #{FLOG_FAIL_THRESHOLD}"
  end
end

desc "Check for structural code duplication with Flay (mass >= 50)"
task :flay_check do
  require "flay"

  mass_threshold = 50

  flay = Flay.new(mass: mass_threshold, diff: false, verbose: false, summary: false, timeout: 60)
  flay.process(*Dir.glob("lib/**/*.rb"))
  flay.analyze

  if flay.hashes.empty?
    puts "\nFlay: no structural duplication detected (mass >= #{mass_threshold})"
  else
    puts "\nFlay found structural duplication (mass >= #{mass_threshold}):"
    flay.report
    abort "\nFlay quality gate failed: #{flay.hashes.length} pattern(s) detected"
  end
end

desc "Check code smells with Reek (fails only on new/worsened files vs .quality/reek_baseline.txt)"
task :reek_check do
  require "reek"
  require "reek/configuration/app_configuration"

  # Resolve .reek.yml by walking up from cwd: a gem-level config wins,
  # otherwise the shared workspace-level one is used.
  config_file = nil
  dir = Pathname.new(Dir.pwd).expand_path
  loop do
    candidate = dir.join(".reek.yml")
    if candidate.exist?
      config_file = candidate.to_s
      break
    end
    break if dir.root?

    dir = dir.parent
  end
  config = config_file ? Reek::Configuration::AppConfiguration.from_path(Pathname.new(config_file)) : nil

  # Smell count per file (only files with at least one smell).
  current = Dir.glob("lib/**/*.rb").each_with_object({}) do |file, acc|
    count = Reek::Examiner.new(File.read(file), configuration: config).smells.size
    acc[file] = count if count.positive?
  end

  # Grandfathered smell counts from .quality/reek_baseline.txt ("count\tfile").
  baseline_path = File.join(".quality", "reek_baseline.txt")
  baseline = {}
  if File.exist?(baseline_path)
    File.readlines(baseline_path).each do |line|
      count, file = line.strip.split("\t", 2)
      baseline[file] = count.to_i if file && !file.empty?
    end
  end

  new_files = current.reject { |file, _| baseline.key?(file) }
  worsened  = current.select { |file, count| baseline.key?(file) && count > baseline[file] }

  puts "\nReek: #{current.values.sum} warning(s) across #{current.size} file(s) " \
       "(#{baseline.values.sum} grandfathered across #{baseline.size} file(s))."

  if new_files.empty? && worsened.empty?
    puts "Reek: no new or worsened files (quality gate passed)"
  else
    puts "\nReek quality gate failed:"
    new_files.each { |file, count| puts "  NEW      #{count.to_s.rjust(3)} warning(s): #{file}" }
    worsened.each  { |file, count| puts "  WORSENED #{baseline[file].to_s.rjust(3)} -> #{count.to_s.rjust(3)}: #{file}" }
    abort "\nReek quality gate failed: #{new_files.size + worsened.size} file(s) regressed. " \
          "Fix smells, or run `asgard reek_baseline` if intentional."
  end
end

desc "Run all quality checks: tests (with coverage), RuboCop, Flog, Flay, and Reek"
task :quality do
  results = {}

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Tests + Coverage"
  puts "=" * 60
  results[:tests] = system("bundle exec rake test") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Gate: RuboCop"
  puts "=" * 60
  results[:rubocop] = system("bundle exec rubocop") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Flog Complexity"
  puts "=" * 60
  results[:flog] = system("bundle exec rake flog_check") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Flay Duplication"
  puts "=" * 60
  results[:flay] = system("bundle exec rake flay_check") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Reek Smells"
  puts "=" * 60
  results[:reek] = system("bundle exec rake reek_check") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Summary"
  puts "=" * 60
  results.each do |gate, status|
    icon = status == :pass ? "PASS" : "FAIL"
    puts "  [#{icon}] #{gate}"
  end
  puts "=" * 60

  abort "\nQuality gate failed" if results.values.any?(:fail)
  puts "\nAll quality gates passed."
end
