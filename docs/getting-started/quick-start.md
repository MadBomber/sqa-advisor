# Quick Start

## Interactive CLI

Start the advisor:

```bash
sqa-advisor
```

You'll see the welcome banner, then a `You:` prompt. Type any investment question:

```
+---------------------------------------------------+
|   SQA Advisor  --  AI Investment Analyst          |
|   Powered by Claude + SQA + Yahoo Finance         |
|   Type 'exit', 'quit', or Ctrl+D to quit         |
|   Type 'reset' to start a new conversation       |
+---------------------------------------------------+
Using model: claude-sonnet-4-6

You: analyze AAPL
```

The advisor fetches data from multiple tools in parallel and returns a full Markdown report covering company overview, financials, technical indicators, analyst sentiment, and a buy/hold/sell recommendation.

### Useful prompts

| Goal | Example |
|------|---------|
| Full analysis | `analyze NVDA` |
| Specific metric | `what is TSLA's RSI and MACD signal?` |
| Comparison | `compare MSFT and GOOGL on free cash flow` |
| Dividend focus | `which pays a better dividend: KO or PEP?` |
| Sector question | `is the semiconductor sector in a bull trend?` |
| Watchlist | `give me a quick summary of AAPL, MSFT, and GOOGL` |

### CLI commands

| Input | Effect |
|-------|--------|
| `reset` | Start a fresh conversation (clears history) |
| `exit` / `quit` / `bye` | Exit the program |
| ++ctrl+d++ | Exit |
| ++ctrl+c++ | Interrupt current response |

## Programmatic use

```ruby
require "sqa/advisor"

# Create an agent (defaults to the model in SQA_ADVISOR_MODEL or claude-sonnet-4-6)
agent = SQA::Advisor::Agent.new

# Ask a question — returns a RubyLLM::Message
response = agent.ask("Give me a full analysis of AMD")
puts response.content   # Markdown-formatted report

# Follow-up questions use the full conversation context
response = agent.ask("How does that compare to INTC?")
puts response.content

# Start a fresh conversation
agent.reset
response = agent.ask("Analyze MSFT")
```

### Custom model

```ruby
agent = SQA::Advisor::Agent.new(model: "claude-opus-4-7")
agent = SQA::Advisor::Agent.new(model: "gpt-4o")
```

## What to expect

A typical full-analysis response includes:

- **Company Overview** — business description, sector, employee count
- **Market Position** — current price, P/E, market cap, 52-week range
- **Financial Health** — 4-year income, balance sheet, and cash flow tables
- **Dividends** — yield, payout ratio, ex-dividend date (if applicable)
- **Analyst Consensus** — Strong Buy/Buy/Hold/Sell counts, price targets
- **News Sentiment** — recent headlines classified as positive/neutral/negative
- **Technical Analysis** — RSI, MACD, Bollinger Bands, market regime, strategy signals
- **Recommendation** — Buy / Hold / Sell with specific rationale

Response time is typically 20–45 seconds for a full analysis, depending on the model and number of tool calls required.
