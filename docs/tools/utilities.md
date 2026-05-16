# Utility Tools

Five general-purpose tools that support calculations, date handling, currency conversion, and knowledge lookups.

---

## CurrencyConverter

Converts an amount between any two world currencies using live rates from [frankfurter.app](https://frankfurter.app).

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `amount` | Yes | Numeric amount to convert (e.g. `100`, `1500.50`) |
| `base` | Yes | Source currency code (e.g. `USD`, `EUR`, `GBP`) |
| `quote` | Yes | Target currency code (e.g. `JPY`, `CHF`, `CAD`) |

**Returns**

| Field | Description |
|-------|-------------|
| `amount` | Original amount |
| `from_currency` | Normalised source code |
| `to_currency` | Normalised target code |
| `converted_amount` | Result rounded to 4 decimal places |
| `exchange_rate` | Per-unit rate rounded to 6 decimal places |
| `rate_date` | Date of the exchange rate |
| `formatted` | Human-readable string, e.g. `100 USD = 91.23 EUR` |

!!! info
    All major currencies are supported. Currency codes are automatically uppercased and trimmed.

---

## Calculator

Evaluates mathematical expressions using a sandboxed evaluator with whitelisted characters and functions.

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `expression` | Yes | A math expression string |

**Supported syntax**

| Syntax | Example |
|--------|---------|
| Basic arithmetic | `(1500 * 0.08) + 200` |
| Exponentiation (`^`) | `1.07^10` |
| Parentheses | `(100 + 50) / 3` |
| Square root | `sqrt(144)` |
| Cube root | `cbrt(27)` |
| Natural log | `log(100)` |
| Log base 10 | `log10(1000)` |
| Log base 2 | `log2(8)` |
| Exponential | `exp(1)` |
| Trig functions | `sin(3.14)`, `cos(0)`, `tan(0.785)` |
| Constants | `pi`, `PI`, `e` |

**Returns**

| Field | Description |
|-------|-------------|
| `expression` | Original input |
| `result` | Raw float result |
| `formatted` | Integer string if result is whole, else 10-decimal string |

!!! warning "Security"
    Expressions are validated against an allowlist before evaluation. Strings containing unknown identifiers or special characters are rejected.

---

## DateTool

Parses and formats dates from natural-language expressions or date strings.

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `input` | Yes | Date expression (see below) |
| `format` | No | strftime format string (default: `%A, %B %d, %Y %H:%M:%S`) |

**Supported input expressions**

| Input | Meaning |
|-------|---------|
| `now` / `today` | Current UTC time |
| `yesterday` | 24 hours ago |
| `tomorrow` | 24 hours from now |
| `3 days ago` | Relative offset (days) |
| `2 weeks ago` | Relative offset (weeks) |
| `6 months ago` | Calendar-aware month subtraction |
| `1 year ago` | Calendar-aware year subtraction |
| `2024-01-15` | ISO date string |
| `January 15 2024` | Natural date string |

**Returns**

| Field | Description |
|-------|-------------|
| `input` | Original input |
| `formatted_date` | Date in the requested format |
| `iso8601` | ISO 8601 UTC string (`YYYY-MM-DDTHH:MM:SSZ`) |
| `unix_timestamp` | Unix epoch integer |
| `day_of_week` | Full weekday name (e.g. `Wednesday`) |

---

## Wikipedia

Searches Wikipedia and returns the summary for the best-matching article.

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | Topic to search for |

**Example queries**

- `Apple Inc`
- `semiconductor industry`
- `P/E ratio`
- `Warren Buffett`

**Returns**

| Field | Description |
|-------|-------------|
| `title` | Wikipedia article title |
| `description` | Short description (e.g. "American multinational technology company") |
| `extract` | Full introductory summary text |
| `url` | Link to the desktop Wikipedia page |

!!! note
    Only present fields are returned — `description` may be absent for some articles.

---

## WebSearch

Queries DuckDuckGo's Instant Answer API for factual lookups. Best for direct factual questions, definitions, and general knowledge.

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | A factual search query |

**Returns**

| Field | Description |
|-------|-------------|
| `query` | Original query |
| `answer` | Direct answer (if DuckDuckGo provides one) |
| `abstract` | Summary paragraph |
| `source` | Source name (e.g. `Wikipedia`) |
| `abstract_url` | Link to the source page |
| `definition` | Definition text (if applicable) |
| `related_topics` | Up to 5 related results, each with `text` and `url` |

Only fields that contain data are included. If no useful result is found, a plain-text fallback message is returned suggesting StockInfo or Wikipedia as alternatives.

!!! tip "When to use each tool"
    - **Company financials** → `StockInfo` / `StockPrice`
    - **Recent news** → `StockNewsSentiment`
    - **Background / history** → `Wikipedia`
    - **Quick factual answer** → `WebSearch`
