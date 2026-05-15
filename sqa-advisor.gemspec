# frozen_string_literal: true
require_relative "lib/sqa/advisor/version"

Gem::Specification.new do |spec|
  spec.name     = "sqa-advisor"
  spec.version  = SQA::Advisor::VERSION
  spec.authors  = ["Dewayne VanHoozer"]
  spec.email    = ["dvanhoozer@gmail.com"]

  spec.summary     = "AI-powered investment advisor built on SQA"
  spec.description = "Extends the SQA technical analysis library with LLM-powered investment " \
                     "reports, fundamental data (income statement, balance sheet, cash flow), " \
                     "news sentiment, currency conversion, and conversational stock analysis."
  spec.homepage    = "https://github.com/MadBomber/sqa-advisor"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files         = Dir.glob("{bin,lib,test}/**/*") + %w[.env.example Gemfile sqa-advisor.gemspec]
  spec.executables   = ["sqa-advisor"]
  spec.require_paths = ["lib"]

  spec.add_dependency "dotenv",    "~> 3.0"
  spec.add_dependency "httparty",  "~> 0.22"
  spec.add_dependency "logger"
  spec.add_dependency "ostruct"
  spec.add_dependency "ruby_llm"
  spec.add_dependency "sqa"

  spec.add_development_dependency "debug_me"
  spec.add_development_dependency "flog"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  spec.metadata["rubygems_mfa_required"] = "true"
end
