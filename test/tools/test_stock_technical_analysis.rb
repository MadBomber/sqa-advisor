# frozen_string_literal: true

require_relative "../test_helper"

class TestStockTechnicalAnalysis < Minitest::Test
  def setup
    @tool = SQA::Advisor::Tools::StockTechnicalAnalysis.new
  end

  # --- rsi_label ---

  def test_rsi_label_oversold
    assert_equal "oversold", @tool.send(:rsi_label, 25.0)
  end

  def test_rsi_label_below_midline
    assert_equal "below_midline", @tool.send(:rsi_label, 40.0)
  end

  def test_rsi_label_above_midline
    assert_equal "above_midline", @tool.send(:rsi_label, 60.0)
  end

  def test_rsi_label_overbought
    assert_equal "overbought", @tool.send(:rsi_label, 75.0)
  end

  def test_rsi_label_nil
    assert_equal "unknown", @tool.send(:rsi_label, nil)
  end

  # --- bb_position ---

  def test_bb_position_near_upper
    assert_equal "near_upper_band", @tool.send(:bb_position, 198.0, 200.0, 180.0)
  end

  def test_bb_position_near_lower
    assert_equal "near_lower_band", @tool.send(:bb_position, 182.0, 200.0, 180.0)
  end

  def test_bb_position_mid
    assert_equal "mid_band", @tool.send(:bb_position, 190.0, 200.0, 180.0)
  end

  def test_bb_position_nil_args
    assert_equal "unknown", @tool.send(:bb_position, nil, 200.0, 180.0)
    assert_equal "unknown", @tool.send(:bb_position, 190.0, nil, 180.0)
  end

  def test_bb_position_zero_range
    assert_equal "unknown", @tool.send(:bb_position, 100.0, 100.0, 100.0)
  end

  # --- stoch_signal ---

  def test_stoch_oversold
    assert_equal "oversold", @tool.send(:stoch_signal, 15.0, 12.0)
  end

  def test_stoch_overbought
    assert_equal "overbought", @tool.send(:stoch_signal, 85.0, 82.0)
  end

  def test_stoch_bullish_crossover
    assert_equal "bullish_crossover", @tool.send(:stoch_signal, 55.0, 45.0)
  end

  def test_stoch_bearish
    assert_equal "bearish", @tool.send(:stoch_signal, 45.0, 55.0)
  end

  def test_stoch_nil
    assert_equal "unknown", @tool.send(:stoch_signal, nil, 50.0)
  end

  # --- price_change ---

  def test_price_change_up
    closes = [100.0, 102.0, 104.0, 106.0, 108.0, 110.0]
    result = @tool.send(:price_change, closes, 5)
    assert_in_delta 10.0, result, 0.01
  end

  def test_price_change_down
    closes = [110.0, 108.0, 106.0, 104.0, 102.0, 100.0]
    result = @tool.send(:price_change, closes, 5)
    assert_in_delta(-9.09, result, 0.01)
  end

  def test_price_change_insufficient_data
    closes = [100.0, 101.0]
    assert_nil @tool.send(:price_change, closes, 5)
  end

  # --- macd_crossover_signal ---

  def test_macd_bullish_crossover
    macd   = [1.0, -0.5, -0.1, 0.3]
    signal = [1.0,  0.5,  0.2, 0.1]
    assert_equal "bullish_crossover", @tool.send(:macd_crossover_signal, macd, signal)
  end

  def test_macd_bearish_crossover
    macd   = [1.0,  0.5,  0.2, 0.1]
    signal = [1.0, -0.5, -0.1, 0.3]
    assert_equal "bearish_crossover", @tool.send(:macd_crossover_signal, macd, signal)
  end

  def test_macd_bullish_no_crossover
    macd   = [0.5, 0.8]
    signal = [0.1, 0.3]
    assert_equal "bullish", @tool.send(:macd_crossover_signal, macd, signal)
  end

  def test_macd_insufficient_data
    assert_equal "insufficient_data", @tool.send(:macd_crossover_signal, nil, nil)
    assert_equal "insufficient_data", @tool.send(:macd_crossover_signal, [0.1], [0.1])
  end
end
