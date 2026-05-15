# frozen_string_literal: true

require "test_helper"

class TestAdvisor < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SQA::Advisor::VERSION
  end
end
