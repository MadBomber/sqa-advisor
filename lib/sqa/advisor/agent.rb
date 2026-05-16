# frozen_string_literal: true

module SQA
  module Advisor
    class Agent
      TOOLS = [
        SQA::Advisor::Tools::StockPrice,
        SQA::Advisor::Tools::StockInfo,
        SQA::Advisor::Tools::IncomeStatement,
        SQA::Advisor::Tools::BalanceSheet,
        SQA::Advisor::Tools::CashFlow,
        SQA::Advisor::Tools::StockDividends,
        SQA::Advisor::Tools::StockRecommendations,
        SQA::Advisor::Tools::StockNewsSentiment,
        SQA::Advisor::Tools::StockTechnicalAnalysis,
        SQA::Advisor::Tools::CurrencyConverter,
        SQA::Advisor::Tools::Calculator,
        SQA::Advisor::Tools::DateTool,
        SQA::Advisor::Tools::Wikipedia,
        SQA::Advisor::Tools::WebSearch
      ].freeze

      def initialize(model: ENV.fetch("SQA_ADVISOR_MODEL", "claude-sonnet-4-6"))
        configure_ruby_llm
        @model               = model
        @tool_call_callbacks = []
        @chat                = build_chat
      end


      def ask(input, &block)
        full_input = "#{SQA::Advisor::Prompts::HUMAN_PREFIX}\n#{input}"
        @chat.ask(full_input, &block)
      end


      def on_tool_call(&block)
        @tool_call_callbacks << block
        @chat.before_tool_call(&block)
        self
      end


      def reset
        @chat = build_chat
      end

      private

      def configure_ruby_llm
        RubyLLM.configure do |config|
          config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"] if ENV["ANTHROPIC_API_KEY"]
          config.openai_api_key    = ENV["OPENAI_API_KEY"]    if ENV["OPENAI_API_KEY"]
        end
      end


      def build_chat
        timestamp  = Time.now.utc.strftime("%A, %B %d, %Y %H:%M UTC")
        system_msg = "#{SQA::Advisor::Prompts::SYSTEM_PROMPT}\n\nToday is #{timestamp}."

        chat = RubyLLM.chat(model: @model)
                      .with_instructions(system_msg)
                      .with_tools(*TOOLS)

        @tool_call_callbacks.each { |cb| chat.before_tool_call(&cb) }

        chat
      end
    end
  end
end
