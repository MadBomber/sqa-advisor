# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

task default: :test

desc "Check code style with RuboCop"
task :rubocop do
  sh "bundle exec rubocop"
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

desc "Run all quality checks: tests, RuboCop, and Flog"
task :quality do
  results = {}

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Tests"
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
