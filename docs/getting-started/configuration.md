# Configuration

SQA Advisor is configured via environment variables. The easiest way is to copy `.env.example` to `.env` in the project root.

```bash
cp .env.example .env
```

## Environment variables

### API keys

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes (or OpenAI) | Anthropic API key — enables Claude models |
| `OPENAI_API_KEY` | Yes (or Anthropic) | OpenAI API key — use instead of Claude |

At least one API key must be set. If both are set, `ANTHROPIC_API_KEY` takes precedence unless `SQA_ADVISOR_MODEL` is set to an OpenAI model name.

### Model selection

| Variable | Default | Description |
|----------|---------|-------------|
| `SQA_ADVISOR_MODEL` | `claude-sonnet-4-6` | Any model name supported by RubyLLM |

Examples:

```dotenv
SQA_ADVISOR_MODEL=claude-opus-4-7          # most capable Claude
SQA_ADVISOR_MODEL=claude-haiku-4-5-20251001  # fastest, lowest cost
SQA_ADVISOR_MODEL=gpt-4o                   # OpenAI (requires OPENAI_API_KEY)
```

### Yahoo Finance session (optional)

Yahoo Finance occasionally rate-limits requests by IP. If you see authentication errors, you can supply a browser session directly:

| Variable | Description |
|----------|-------------|
| `YF_COOKIE` | Cookie string from an active browser session on finance.yahoo.com |
| `YF_CRUMB` | Crumb token from the same session |

**How to obtain:**

1. Open [finance.yahoo.com](https://finance.yahoo.com) in your browser
2. Open DevTools → Application → Cookies
3. Copy the `A1`, `A1S`, and `A3` cookie values, formatted as `A1=xxx; A1S=yyy; A3=zzz`
4. Navigate to `https://query2.finance.yahoo.com/v1/test/getcrumb` in the same browser — the page body is your crumb

```dotenv
YF_COOKIE=A1=abc123; A1S=def456; A3=ghi789
YF_CRUMB=yourCrumbValue
```

!!! tip
    These credentials expire with the browser session. They are only needed as a workaround for rate limiting; under normal conditions SQA Advisor acquires them automatically.

## Example `.env`

```dotenv
ANTHROPIC_API_KEY=sk-ant-api03-...
SQA_ADVISOR_MODEL=claude-sonnet-4-6
```
