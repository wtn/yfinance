require 'test_helper.rb'

class YfinanceTest < Minitest::Test
  def test_it_receives_quotes_for_valid_symbols
    yf = Yfinance.new
    res = yf.quotes(["AAPL"])
    refute_empty res
  end

  def test_it_returns_a_hash
    yf = Yfinance.new
    res = yf.quotes(["MSFT", "TEP.L"])
    assert res.kind_of?(Hash), "It does NOT return a hash"
  end

  def test_it_always_adds_the_symbol_to_the_resulting_hash
    yf = Yfinance.new
    res = yf.quotes(["TWTR", "BARC.L"], [:last_trade_date, :close])
    assert_equal res["TWTR"][:symbol], "TWTR"
  end

  def test_it_work_for_an_invalid_symbol
    yf = Yfinance.new
    res = yf.quotes_all_info(["TWTR", "MADASDFASD", "AAPL"])
    assert_equal res.length, 3
  end

  def test_it_works_requesting_all_data_for_valid_symbols
    yf = Yfinance.new
    res = yf.quotes_all_info(["MSFT", "TWTR", "TEP.L"])
    assert_equal 3, res.length
    assert_equal "MSFT", res["MSFT"][:symbol]
    assert_equal "TWTR", res["TWTR"][:symbol]
    assert_equal "TEP.L", res["TEP.L"][:symbol]
  end

  def test_it_works_requesting_all_data_for_one_invalid_symbol
    yf = Yfinance.new
    res = yf.quotes_all_info(["asdf"])
    assert_nil res["ASDF"] 
  end

  def test_it_returns_an_error_for_a_mix_of_valid_and_invalid__symbols
    yf = Yfinance.new
    res = yf.quotes_all_info(["AAPL", "bcxza", "MSFT"])
    assert_equal 3, res.length
    assert_nil res["BCXZA"]
  end

  def test_historical_data_works_for_one_symbol
    yf = Yfinance.new
    res = Proc.new { |resp| assert resp["MSFT"].kind_of?(Array)}
    yf.add_historical_data_query(['MSFT'], '2013-01-01', Date.today, {period: :daily}, &res)
    yf.run
  end

  def test_daily_historical_data_is_returned_as_one_hash_for_multiple_symbols
    yf = Yfinance.new
    symbols = ["MSFT", "TEP.L", "TWTR"]
    result = yf.daily_historical_data(symbols, Date.today - 7, Date.today)
    assert_equal symbols.length, result.length
  end

  def test_daily_historical_data_is_returned_via_callbacks_for_multiple_valid_symbols
    yf = Yfinance.new
    symbols = ["MSFT", "TEP.L", "TWTR"]
    h = Hash.new
    res = Proc.new do |resp|
      assert true
    end 
    yf.daily_historical_data_callback(symbols, Date.today - 7, Date.today, &res)
  end

  def test_historical_data_works_for_invalid_symbols
    yf = Yfinance.new
    symbols = ["MSFT", "asdfbc", "TWTR"]
    result = yf.daily_historical_data(symbols, Date.today - 7, Date.today)
    assert_equal symbols.length, result.length
    assert result["ASDFBC"].kind_of?(String)
  end

end
