# Development

## Setup

```bash
git clone git@github.com:MadBomber/sqa-advisor.git
cd sqa-advisor
bundle install
cp .env.example .env   # then add your ANTHROPIC_API_KEY
```

The `sqa` gem is loaded from a local path (`../sqa/main`). Ensure the `sqa` repo is checked out at `../sqa` relative to this directory, on the `main` branch.

---

## Common commands

```bash
bundle exec rake test          # run full test suite
ruby -Ilib:test test/path.rb   # run a single test file

bundle exec rake rubocop        # lint check
bundle exec rake rubocop_fix    # auto-fix lint offenses

bundle exec rake flog_check     # complexity check (threshold 50.0)
bundle exec rake quality        # rubocop + flog_check together

bundle exec rake                # default: test + quality

bin/console                     # IRB with gem loaded
bin/sqa-advisor                 # interactive CLI
```

---

## Adding a tool

1. Create `lib/sqa/advisor/tools/my_tool.rb` inheriting from `RubyLLM::Tool`:

```ruby
# frozen_string_literal: true

module SQA
  module Advisor
    module Tools
      class MyTool < RubyLLM::Tool
        description "What this tool does and when the LLM should use it"

        param :symbol, desc: "Ticker symbol (e.g. AAPL)"
        param :limit,  desc: "Max results to return", required: false

        def execute(symbol:, limit: 10)
          # fetch or compute something
          JSON.generate({ symbol: symbol.upcase, data: [] })
        rescue StandardError => e
          "MyTool error: #{e.message}"
        end
      end
    end
  end
end
```

2. Add the class to `TOOLS` in `lib/sqa/advisor/agent.rb`:

```ruby
TOOLS = [
  ...
  SQA::Advisor::Tools::MyTool,
].freeze
```

The file is autoloaded by Zeitwerk — no `require` needed. Only the `TOOLS` entry is manual.

3. Update `Prompts::SYSTEM_PROMPT` in `lib/sqa/advisor/prompts.rb` to describe the new tool so the LLM knows when to use it.

4. Add tests in `test/tools/test_my_tool.rb`.

---

## Testing

Tests use Minitest with Rake. The suite is in `test/`:

```
test/
  test_helper.rb
  sqa/
    test_advisor.rb
  tools/
    test_calculator.rb
    test_date_tool.rb
    test_stock_technical_analysis.rb
```

Run a single test:

```bash
ruby -Ilib:test test/tools/test_calculator.rb
```

Tests for tools that call external APIs (Yahoo Finance, DuckDuckGo, etc.) may make live network requests. Stub or skip these in CI if needed.

---

## Code quality

### RuboCop

`.rubocop.yml` enforces the project style. Key settings:

- Line length: 109 characters
- `Naming/VariableNumber: EnforcedStyle: snake_case` — allows financial indicator names like `rsi_14`, `sma_20`, `ema_26`
- Metrics thresholds are raised to accommodate data-extraction methods

Run:

```bash
bundle exec rake rubocop       # check only
bundle exec rake rubocop_fix   # auto-fix
```

### Flog

Flog measures code complexity. The failure threshold is **50.0** per method.

Data-extraction `execute` methods are exempt via `FLOG_EXCEPTIONS` in the `Rakefile` — they are inherently high-scoring due to many field assignments, not genuine complexity.

To add a new exception:

```ruby
FLOG_EXCEPTIONS = %w[
  ...
  SQA::Advisor::Tools::MyTool#execute
].freeze
```

---

## Debugging

Use `debug_me` instead of `puts`:

```ruby
require "debug_me"
include DebugMe

debug_me { :my_var }                    # labeled variable
debug_me { %i[var1 var2 var3] }         # multiple variables
debug_me "Some message"                 # string to STDOUT
```

---

## Release

```bash
bundle exec rake build    # build .gem into pkg/
bundle exec rake install  # install locally for testing
```

Version is in `lib/sqa/advisor/version.rb`. Follow [Semantic Versioning](https://semver.org). Update `CHANGELOG.md` before tagging.
