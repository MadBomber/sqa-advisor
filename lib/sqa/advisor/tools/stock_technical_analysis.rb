# frozen_string_literal: true

module SQA
  module Advisor
    module Tools
      class StockTechnicalAnalysis < RubyLLM::Tool
        include YahooFinance

        description "Perform comprehensive technical analysis on a stock using SQA + TA-Lib " \
                    "(150+ indicators). Returns RSI, SMA, EMA, MACD, Bollinger Bands, ATR, " \
                    "Stochastic, OBV, market regime detection, strategy signals (RSI/MACD/SMA), " \
                    "and an AI-synthesized short-term prediction."

        param :symbol, desc: "The stock ticker symbol (e.g. AAPL, MSFT, GOOGL)"
        param :range,
              desc: "Historical data range: 1mo, 3mo, 6mo, 1y (default: 6mo)",
              required: false

        def execute(symbol:, range: "6mo")
          symbol = symbol.upcase.strip
          chart  = price_chart(symbol, interval: "1d", range: range)

          result_data = chart.dig("chart", "result", 0)
          return "No chart data available for #{symbol}." unless result_data

          meta    = result_data["meta"] || {}
          quotes  = result_data.dig("indicators", "quote", 0) || {}

          closes  = (quotes["close"]  || []).compact.map(&:to_f)
          highs   = (quotes["high"]   || []).compact.map(&:to_f)
          lows    = (quotes["low"]    || []).compact.map(&:to_f)
          volumes = (quotes["volume"] || []).compact.map(&:to_f)

          return "Insufficient price history for technical analysis (need 35+ days)." if closes.length < 35

          indicators = compute_indicators(closes, highs, lows, volumes)
          regime     = compute_regime(closes)
          signals    = compute_signals(closes, indicators)
          prediction = llm_predict(symbol, indicators, regime, signals)

          JSON.generate({
                          symbol: symbol,
                          currency: meta["currency"],
                          current_price: closes.last&.round(4),
                          data_points: closes.length,
                          indicators: indicators,
                          market_regime: regime,
                          strategy_signals: signals,
                          prediction: prediction,
                          disclaimer: "Technical analysis is for informational purposes only, " \
                                      "not financial advice."
                        })
        rescue StandardError => e
          "Error performing technical analysis for #{symbol}: #{e.message}"
        end

        private

        def compute_indicators(closes, highs, lows, volumes)
          [
            compute_rsi(closes),
            compute_moving_averages(closes),
            compute_macd_indicators(closes),
            compute_bollinger(closes),
            compute_atr_stoch(highs, lows, closes),
            compute_volume_indicators(closes, volumes)
          ].reduce(:merge).compact
        rescue StandardError => e
          { error: "Indicator computation failed: #{e.message}" }
        end

        def compute_rsi(closes)
          rsi_val = SQAI.rsi(closes, period: 14).last&.round(2)
          { rsi_14: rsi_val, rsi_signal: rsi_label(rsi_val) }
        end

        def compute_moving_averages(closes)
          sma_20_val = SQAI.sma(closes, period: 20).last&.round(4)
          sma_50_arr = closes.length >= 50 ? SQAI.sma(closes, period: 50) : nil
          sma_50_val = sma_50_arr&.last&.round(4)
          ema_12_val = SQAI.ema(closes, period: 12).last&.round(4)
          ema_26_val = SQAI.ema(closes, period: 26).last&.round(4)
          price      = closes.last
          {
            sma_20: sma_20_val,
            sma_50: sma_50_val,
            ema_12: ema_12_val,
            ema_26: ema_26_val,
            price_vs_sma_20: if price && sma_20_val
                               price >= sma_20_val ? "above" : "below"
                             end,
            price_vs_sma_50: if price && sma_50_val
                               price >= sma_50_val ? "above" : "below"
                             end
          }
        end

        def compute_macd_indicators(closes)
          macd_line, signal_line, histogram = SQAI.macd(closes)
          {
            macd: macd_line.last&.round(4),
            macd_signal_line: signal_line.last&.round(4),
            macd_histogram: histogram.last&.round(4),
            macd_crossover: macd_crossover_signal(macd_line, signal_line)
          }
        end

        def compute_bollinger(closes)
          upper_band, middle_band, lower_band = SQAI.bbands(closes, period: 20)
          bb_upper  = upper_band.last&.round(4)
          bb_middle = middle_band.last&.round(4)
          bb_lower  = lower_band.last&.round(4)
          bb_width  = if bb_upper && bb_lower && bb_middle && !bb_middle.zero?
                        ((bb_upper - bb_lower) / bb_middle * 100).round(2)
                      end
          {
            bb_upper: bb_upper,
            bb_middle: bb_middle,
            bb_lower: bb_lower,
            bb_bandwidth_pct: bb_width,
            bb_position: bb_position(closes.last, bb_upper, bb_lower)
          }
        end

        def compute_atr_stoch(highs, lows, closes)
          atr_arr = highs.length >= 14 ? SQAI.atr(highs, lows, closes, period: 14) : nil
          stoch_k_arr, stoch_d_arr = SQAI.stoch(highs, lows, closes)
          stoch_k = stoch_k_arr.last&.round(2)
          stoch_d = stoch_d_arr.last&.round(2)
          {
            atr_14: atr_arr&.last&.round(4),
            stoch_k: stoch_k,
            stoch_d: stoch_d,
            stoch_signal: stoch_signal(stoch_k, stoch_d)
          }
        end

        def compute_volume_indicators(closes, volumes)
          obv_arr   = volumes.length.positive? ? SQAI.obv(closes, volumes) : nil
          vol_5     = volumes.last(5).sum  / 5.0
          vol_20    = volumes.last(20).sum / 20.0
          vol_trend = if vol_5 > vol_20 * 1.1
                        "increasing"
                      else
                        vol_5 < vol_20 * 0.9 ? "decreasing" : "stable"
                      end
          {
            obv: obv_arr&.last&.round(0),
            volume_trend: vol_trend,
            price_change_5d_pct: price_change(closes, 5),
            price_change_20d_pct: price_change(closes, 20)
          }
        end

        def compute_regime(closes)
          trend = SQA::MarketRegime.detect_trend_with_score(closes)
          vol   = SQA::MarketRegime.detect_volatility_with_score(closes)
          str   = SQA::MarketRegime.detect_strength_with_score(closes)

          {
            trend: trend[:type],
            trend_score: trend[:score]&.round(2),
            volatility: vol[:type],
            volatility_score: vol[:score]&.round(2),
            strength: str[:type],
            strength_score: str[:score]&.round(2)
          }
        rescue StandardError => e
          { error: "Regime detection failed: #{e.message}" }
        end

        def compute_signals(closes, indicators)
          rsi_trend = case indicators[:rsi_14]
                      when 0...30 then :over_sold
                      when 70..100 then :over_bought
                      else :neutral
                      end
          rsi_vector  = Struct.new(:rsi).new({ trend: rsi_trend })
          rsi_signal  = SQA::Strategy::RSI.trade(rsi_vector)

          macd_vector = Struct.new(:prices).new(closes)
          macd_signal = SQA::Strategy::MACD.trade(macd_vector)

          sma_20 = indicators[:sma_20]
          sma_50 = indicators[:sma_50]
          sma_signal = if sma_20 && sma_50
                         if sma_20 > sma_50
                           :buy
                         else
                           sma_20 < sma_50 ? :sell : :hold
                         end
                       else
                         :hold
                       end

          votes      = [rsi_signal, macd_signal, sma_signal]
          buy_count  = votes.count(:buy)
          sell_count = votes.count(:sell)
          consensus  = if buy_count > sell_count
                         :buy
                       else
                         (sell_count > buy_count ? :sell : :hold)
                       end

          {
            rsi_strategy: rsi_signal,
            macd_strategy: macd_signal,
            sma_strategy: sma_signal,
            consensus: consensus
          }
        rescue StandardError => e
          { error: "Strategy signal computation failed: #{e.message}" }
        end

        def llm_predict(symbol, indicators, regime, signals)
          prompt = <<~PROMPT
            You are a professional technical analyst. Based on the data below for #{symbol}, provide a short-term (5–10 trading day) prediction.

            Technical Indicators:
            #{JSON.generate(indicators)}

            Market Regime:
            #{JSON.generate(regime)}

            Strategy Signals (RSI/MACD/SMA):
            #{JSON.generate(signals)}

            Respond with ONLY a valid JSON object (no markdown, no text outside JSON):
            {
              "direction": "Bullish" | "Bearish" | "Neutral",
              "confidence": "High" | "Medium" | "Low",
              "key_signals": ["signal 1", "signal 2", "signal 3"],
              "reasoning": "one sentence summary"
            }
          PROMPT

          predictor = RubyLLM.chat(model: "claude-haiku-4-5-20251001")
          response  = predictor.ask(prompt)

          json_text = response.content.match(/\{.*\}/m)&.[](0)
          if json_text
            JSON.parse(json_text)
          else
            { direction: "Neutral", confidence: "Low",
              reasoning: "Unable to parse prediction." }
          end
        rescue StandardError
          { direction: "Neutral", confidence: "Low", reasoning: "Prediction unavailable." }
        end

        def rsi_label(rsi)
          return "unknown" unless rsi

          case rsi
          when 0...30  then "oversold"
          when 30...50 then "below_midline"
          when 50..70  then "above_midline"
          when 70..100 then "overbought"
          else "unknown"
          end
        end

        def macd_crossover_signal(macd_line, signal_line)
          return "insufficient_data" if macd_line.nil? || signal_line.nil? || macd_line.size < 2

          curr_macd   = macd_line[-1]
          curr_signal = signal_line[-1]
          prev_macd   = macd_line[-2]
          prev_signal = signal_line[-2]

          return "unknown" if [curr_macd, curr_signal, prev_macd, prev_signal].any?(&:nil?)

          if prev_macd <= prev_signal && curr_macd > curr_signal
            "bullish_crossover"
          elsif prev_macd >= prev_signal && curr_macd < curr_signal
            "bearish_crossover"
          elsif curr_macd > curr_signal
            "bullish"
          else
            "bearish"
          end
        end

        def bb_position(price, upper, lower)
          return "unknown" unless price && upper && lower

          range = upper - lower
          return "unknown" if range.zero?

          pct = (price - lower) / range * 100
          if pct > 80
            "near_upper_band"
          elsif pct < 20
            "near_lower_band"
          else
            "mid_band"
          end
        end

        def stoch_signal(pct_k, pct_d)
          return "unknown" unless pct_k && pct_d

          if pct_k < 20 && pct_d < 20
            "oversold"
          elsif pct_k > 80 && pct_d > 80
            "overbought"
          elsif pct_k > pct_d
            "bullish_crossover"
          else
            "bearish"
          end
        end

        def price_change(closes, days)
          return nil if closes.length < days + 1

          ((closes.last - closes[-(days + 1)]) / closes[-(days + 1)] * 100).round(2)
        rescue StandardError
          nil
        end
      end
    end
  end
end
