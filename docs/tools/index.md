# Tools Overview

SQA Advisor provides 14 tools that the LLM selects and invokes automatically based on your question. You never call them directly — the agent decides which ones to use and in what order.

## Tool registry

| Tool | Category | Data source |
|------|----------|-------------|
| [StockPrice](fundamental.md#stockprice) | Fundamental | Yahoo Finance |
| [StockInfo](fundamental.md#stockinfo) | Fundamental | Yahoo Finance |
| [IncomeStatement](fundamental.md#incomestatement) | Fundamental | Yahoo Finance |
| [BalanceSheet](fundamental.md#balancesheet) | Fundamental | Yahoo Finance |
| [CashFlow](fundamental.md#cashflow) | Fundamental | Yahoo Finance |
| [StockDividends](fundamental.md#stockdividends) | Fundamental | Yahoo Finance |
| [StockRecommendations](fundamental.md#stockrecommendations) | Fundamental | Yahoo Finance |
| [StockNewsSentiment](fundamental.md#stocknewssentiment) | Fundamental | Yahoo Finance + Claude |
| [StockTechnicalAnalysis](technical.md) | Technical | Yahoo Finance + SQA/TA-Lib |
| [CurrencyConverter](utilities.md#currencyconverter) | Utility | frankfurter.app |
| [Calculator](utilities.md#calculator) | Utility | Built-in |
| [DateTool](utilities.md#datetool) | Utility | Built-in |
| [Wikipedia](utilities.md#wikipedia) | Utility | Wikipedia API |
| [WebSearch](utilities.md#websearch) | Utility | DuckDuckGo |

## How tools are selected

The system prompt describes every tool to the LLM. When you ask a question, Claude decides which tools to call, in what order, and how many times — then synthesizes all results into a single response.

For a full stock analysis, the agent typically calls 6–9 tools in sequence: price → company info → financials → dividends → recommendations → news → technical analysis.

## Extending the tool set

To add a new tool:

1. Create `lib/sqa/advisor/tools/my_tool.rb` inheriting from `RubyLLM::Tool`
2. Add the class to `SQA::Advisor::Agent::TOOLS` in `lib/sqa/advisor/agent.rb`

The file is auto-loaded via the glob in `lib/sqa/advisor.rb`; only the `TOOLS` array entry is manual.

```ruby
class MyTool < RubyLLM::Tool
  description "What this tool does and when to use it"
  param :symbol, desc: "Ticker symbol"

  def execute(symbol:)
    # fetch/compute something
    JSON.generate({ result: "..." })
  end
end
```
