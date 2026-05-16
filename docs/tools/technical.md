# Technical Analysis Tool

## StockTechnicalAnalysis

Performs comprehensive technical analysis using SQA's TA-Lib bindings (150+ professional indicators) and synthesizes a short-term directional prediction via a secondary LLM call.

**Parameters**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `symbol` | Yes | Ticker symbol (e.g. `AAPL`, `MSFT`) |
| `range` | No | Historical data range: `1mo`, `3mo`, `6mo`, `1y` (default: `6mo`) |

Requires at least 35 days of price history. Returns an error string if insufficient data is available.

---

## Indicators returned

### Momentum

| Field | Description |
|-------|-------------|
| `rsi_14` | 14-period Relative Strength Index |
| `rsi_signal` | `oversold` / `below_midline` / `above_midline` / `overbought` |
| `stoch_k` | Stochastic %K |
| `stoch_d` | Stochastic %D |
| `stoch_signal` | `oversold` / `overbought` / `bullish_crossover` / `bearish` |

### Trend

| Field | Description |
|-------|-------------|
| `sma_20` | 20-period Simple Moving Average |
| `sma_50` | 50-period SMA (omitted if insufficient data) |
| `ema_12` | 12-period Exponential Moving Average |
| `ema_26` | 26-period EMA |
| `price_vs_sma_20` | `above` or `below` |
| `price_vs_sma_50` | `above` or `below` (omitted if insufficient data) |
| `macd` | MACD line value |
| `macd_signal_line` | Signal line value |
| `macd_histogram` | Histogram value |
| `macd_crossover` | `bullish_crossover` / `bearish_crossover` / `bullish` / `bearish` |

### Volatility

| Field | Description |
|-------|-------------|
| `bb_upper` | Bollinger Band upper |
| `bb_middle` | Bollinger Band middle (20-period SMA) |
| `bb_lower` | Bollinger Band lower |
| `bb_bandwidth_pct` | Band width as % of middle band |
| `bb_position` | `near_upper_band` / `mid_band` / `near_lower_band` |
| `atr_14` | 14-period Average True Range |

### Volume

| Field | Description |
|-------|-------------|
| `obv` | On-Balance Volume |
| `volume_trend` | `increasing` / `stable` / `decreasing` |
| `price_change_5d_pct` | 5-day price change % |
| `price_change_20d_pct` | 20-day price change % |

---

## Market regime

Detected via `SQA::MarketRegime`:

| Field | Description |
|-------|-------------|
| `trend` | `bullish` / `bearish` / `sideways` |
| `trend_score` | Numeric confidence score |
| `volatility` | `high` / `normal` / `low` |
| `volatility_score` | Numeric score |
| `strength` | `strong` / `moderate` / `weak` |
| `strength_score` | Numeric score |

---

## Strategy signals

Three built-in SQA strategies vote independently:

| Field | Description |
|-------|-------------|
| `rsi_strategy` | `:buy` / `:sell` / `:hold` from `SQA::Strategy::RSI` |
| `macd_strategy` | `:buy` / `:sell` / `:hold` from `SQA::Strategy::MACD` |
| `sma_strategy` | `:buy` / `:sell` / `:hold` from SMA-20/50 crossover |
| `consensus` | Majority vote across all three strategies |

---

## AI prediction

A secondary call to `claude-haiku-4-5-20251001` synthesizes all indicators into a short-term (5–10 trading day) prediction:

| Field | Description |
|-------|-------------|
| `direction` | `Bullish` / `Bearish` / `Neutral` |
| `confidence` | `High` / `Medium` / `Low` |
| `key_signals` | Array of the most influential signals |
| `reasoning` | One-sentence summary |

!!! warning "Disclaimer"
    Technical analysis is for informational purposes only and does not constitute financial advice.
