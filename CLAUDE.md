# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle install
bundle exec rake test                         # run all tests
ruby -Ilib:test test/sqa/test_advisor.rb      # run a single test file
bundle exec ruby -Ilib:test test/tools/test_calculator.rb
bin/sqa-advisor                               # launch interactive REPL
```

Environment variables must be set before running (see `.env.example`):
- `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` — required by the CLI
- `SQA_ADVISOR_MODEL` — overrides the default LLM model (`claude-sonnet-4-6`)
- `YF_COOKIE` / `YF_CRUMB` — bypass Yahoo Finance cookie acquisition (rate-limit workaround)

## Architecture

**sqa-advisor** is an agentic investment analysis CLI that wraps Claude (via RubyLLM) with 14 domain tools and produces structured Markdown investment reports.

### Core flow

```
bin/sqa-advisor  →  Agent#ask(input)  →  RubyLLM chat  →  Tool calls  →  LLM synthesis  →  Markdown report
```

### Key files

| File | Role |
|------|------|
| `lib/sqa/advisor/agent.rb` | Instantiates the RubyLLM chat session, binds all tools, exposes `ask` / `reset` |
| `lib/sqa/advisor/prompts.rb` | `SYSTEM_PROMPT` (analyst persona + 9-step report format) and `HUMAN_PREFIX` (injected before every user message) |
| `lib/sqa/advisor/tools/*.rb` | 14 `RubyLLM::Tool` subclasses; each declares params via `param` and implements `execute` returning a JSON string |
| `lib/sqa/advisor/tools/yahoo_finance.rb` | Shared mixin included by financial tools — handles Yahoo Finance cookie/crumb acquisition with module-level Mutex cache (30-min TTL) |

### Tool pattern

Every tool follows this structure:

```ruby
class MyTool < RubyLLM::Tool
  description "What this tool does"
  param :symbol, desc: "Ticker symbol"

  def execute(symbol:)
    # ... fetch/compute ...
    JSON.generate({ key: value })
  end
end
```

Tools always return a JSON string. All exceptions are rescued and returned as an error string so the agent can continue with partial data.

### Agent registration

`Agent::TOOLS` is an explicit array of tool classes. Adding a new tool requires both creating the file under `tools/` (auto-loaded via glob in `lib/sqa/advisor.rb`) **and** adding the class to `Agent::TOOLS`.

### Local gem dependency

The `sqa` gem is loaded from `path: "../sqa/main"` (relative to this repo). It provides 150+ technical indicators via TA-Lib and is required for `StockTechnicalAnalysis`.
