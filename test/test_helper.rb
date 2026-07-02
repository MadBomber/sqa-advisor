# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_group "Tools", "lib/sqa/advisor/tools"
  add_group "Core", "lib/sqa/advisor"
end

require "minitest/autorun"
require_relative "../lib/sqa/advisor"
