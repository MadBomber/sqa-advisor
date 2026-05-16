# SQA Advisor

An AI-powered investment advisor that combines Claude (via [RubyLLM](https://github.com/crmne/ruby_llm)) with the [SQA](https://github.com/MadBomber/sqa) technical analysis library and Yahoo Finance data. Ask questions about any stock in plain English and receive a structured Markdown report covering fundamentals, technicals, news sentiment, and a recommendation.

## Features

- **Conversational REPL** — interactive `sqa-advisor` CLI with readline history
- **14 financial tools** automatically selected and invoked by the LLM:
  - Fundamental data: price, company info, income statement, balance sheet, cash flow, dividends, analyst recommendations, news sentiment
  - Technical analysis: RSI, SMA, EMA, MACD, Bollinger Bands, ATR, Stochastic, OBV, market regime detection, and strategy signals via SQA's 150+ TA-Lib indicators
  - Utilities: currency conversion, calculator, date parsing, Wikipedia, web search
- **Structured 9-section reports** — Company Overview → Technical Analysis → Investment Recommendation
- **Multi-provider LLM support** — defaults to Claude, switchable to OpenAI via env var

## Requirements

- Ruby >= 3.2
- An Anthropic API key (or OpenAI API key)
- The [sqa](https://github.com/MadBomber/sqa) gem (provides TA-Lib bindings)

## Installation

Add to your Gemfile:

```ruby
gem "sqa-advisor"
```

Or install directly:

```bash
gem install sqa-advisor
```

## Configuration

Copy `.env.example` to `.env` and fill in your key:

```bash
cp .env.example .env
```

```dotenv
# Required — defaults to Claude
ANTHROPIC_API_KEY=your_anthropic_key_here

# Alternative: use OpenAI instead
# OPENAI_API_KEY=your_openai_key_here

# Optional: override the default model (default: claude-sonnet-4-6)
# SQA_ADVISOR_MODEL=claude-opus-4-7

# Optional: supply Yahoo Finance session credentials if rate-limited
# YF_COOKIE=A1=xxx; A1S=yyy; A3=zzz
# YF_CRUMB=your_crumb_here
```

## Usage

### Interactive CLI

```bash
bundle exec sqa-advisor
```

```
+---------------------------------------------------+
|   SQA Advisor  --  AI Investment Analyst          |
|   Powered by Claude + SQA + Yahoo Finance         |
|   Type 'exit', 'quit', or Ctrl+D to quit         |
|   Type 'reset' to start a new conversation       |
+---------------------------------------------------+

You: analyze AAPL
You: compare MSFT and GOOGL on cash flow
You: what is NVDA's RSI and is it overbought?
You: reset
```

### Programmatic use

```ruby
require "sqa/advisor"

agent = SQA::Advisor::Agent.new                         # defaults to claude-sonnet-4-6
agent = SQA::Advisor::Agent.new(model: "gpt-4o")        # or any RubyLLM-supported model

response = agent.ask("Give me a full analysis of TSLA")
puts response.content   # Markdown report

agent.reset             # start a fresh conversation
```

## Development

```bash
git clone https://github.com/MadBomber/sqa-advisor
cd sqa-advisor
bundle install
bundle exec rake test        # run tests
bundle exec rake quality     # tests + RuboCop + Flog complexity
bundle exec rake rubocop_fix # auto-correct style offenses
bin/console                  # interactive console with gem loaded
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MadBomber/sqa-advisor.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
