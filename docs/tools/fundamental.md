# Fundamental Data Tools

These eight tools fetch live data from Yahoo Finance and cover the full range of fundamental investment analysis.

---

## StockPrice

Returns live price and key market metrics for a ticker.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol (e.g. `AAPL`, `BRK-B`) |

**Returns**

| Field | Description |
|-------|-------------|
| `symbol` | Normalised ticker |
| `price` | Current price |
| `change` | Price change |
| `change_pct` | Percentage change |
| `volume` | Trading volume |
| `avg_volume` | 90-day average volume |
| `market_cap` | Market capitalisation (K/M/B/T) |
| `pe_ratio` | Price-to-earnings ratio |
| `eps` | Trailing twelve-month EPS |
| `week_52_high` / `week_52_low` | 52-week range |
| `beta` | Beta vs S&P 500 |
| `forward_pe` | Forward P/E |
| `price_to_book` | Price-to-book ratio |

---

## StockInfo

Returns comprehensive company profile and financial health metrics.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol |

**Returns**

Company description, sector, industry, country, number of employees, website, plus: revenue growth, gross/operating/profit margins, return on equity, return on assets, debt-to-equity ratio, and current ratio.

---

## IncomeStatement

Returns four years of annual income statement history.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol |

**Returns** *(per year)*

Total revenue, cost of revenue, gross profit, operating income, EBITDA, net income, and basic EPS — expressed in K/M/B/T scale.

---

## BalanceSheet

Returns four years of annual balance sheet history.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol |

**Returns** *(per year)*

Total assets, total liabilities, stockholder equity, cash and equivalents, short-term investments, total debt, and net debt — expressed in K/M/B/T scale.

---

## CashFlow

Returns four years of annual cash flow statement history.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol |

**Returns** *(per year)*

Operating cash flow, investing cash flow, financing cash flow, capital expenditures, free cash flow (operating + capex), depreciation & amortisation, change in cash, dividends paid, and stock repurchases — expressed in K/M/B/T scale.

---

## StockDividends

Returns dividend yield, payout details, and key dates.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol |

**Returns**

Whether the stock pays a dividend, annual dividend rate, dividend yield (%), payout ratio (%), five-year average yield, ex-dividend date, last dividend date and value, and last stock split details.

!!! note
    For non-dividend stocks, a `note` field is included explaining that no dividend is currently paid.

---

## StockRecommendations

Returns analyst consensus ratings and the ten most recent upgrades/downgrades.

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `symbol` | Ticker symbol |

**Returns**

Consensus periods (each with Strong Buy / Buy / Hold / Sell / Strong Sell counts) and the ten most recent analyst rating changes including firm name, action (upgrade/downgrade/initiate), and from/to ratings.

---

## StockNewsSentiment

Fetches recent news headlines and classifies each as positive, neutral, or negative using a fast Claude Haiku model.

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `symbol` | Yes | Ticker symbol |
| `count` | No | Number of headlines to analyse (1–15, default: 8) |

**Returns**

Overall sentiment summary (e.g. "Predominantly positive"), individual headlines with sentiment classification, and total headline count.

!!! info "Sentiment classification"
    Classification is performed by a secondary LLM call to `claude-haiku-4-5-20251001`, separate from the main conversation model. If classification fails, all headlines default to `neutral`.
