# frozen_string_literal: true

require "ruby_llm"
require "dotenv/load"
require "httparty"
require "json"
require "uri"
require "date"
require "sqa"

require_relative "advisor/version"
require_relative "advisor/prompts"
require_relative "advisor/tools/yahoo_finance"

Dir[File.join(__dir__, "advisor", "tools", "*.rb")].each { |f| require f }

require_relative "advisor/agent"
