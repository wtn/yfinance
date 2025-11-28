require 'csv'
require 'uri'
require 'typhoeus'
require 'json'

class Yfinance

  attr_reader :error_message

  class YahooFinanceException < Exception
  end

  class SymbolNotFoundException < YahooFinanceException
  end

  COLUMNS = {
     :ask => "a",
     :average_daily_volume => "a2",
     # :ask_size => "a5", # sometimes includes comma which isn't parsed correctly
     :bid => "b",
     :ask_real_time => "b2",
     :bid_real_time => "b3",
     :book_value => "b4",
     # :bid_size => "b6", # sometimes includes comma which isn't parsed correctly
     :change_and_percent_change => "c",
     :change => "c1",
     :comission => "c3",
     :change_real_time => "c6",
     :after_hours_change_real_time => "c8",
     :dividend_per_share => "d",
     :last_trade_date => "d1",
     :trade_date => "d2",
     :earnings_per_share => "e",
     :error_indicator => "e1",
     :eps_estimate_current_year => "e7",
     :eps_estimate_next_year => "e8",
     :eps_estimate_next_quarter => "e9", 
     #:float_shares => "f6",  # sometimes includes comma which isn't parsed correctly
     :low => "g",
     :high => "h",
     :low_52_weeks => "j",
     :high_52_weeks => "k",
     :holdings_gain_percent => "g1",
     :annualized_gain => "g3",
     :holdings_gain => "g4",
     :holdings_gain_percent_realtime => "g5",
     :holdings_gain_realtime => "g6",
     :more_info => "i",
     :order_book => "i5", 
     :market_capitalization => "j1",
     :market_cap_realtime => "j3", 
     :ebitda => "j4",
     :change_From_52_week_low => "j5",
     :percent_change_from_52_week_low => "j6",
     :last_trade_realtime_withtime => "k1",
     :change_percent_realtime => "k2",
     :last_trade_size => "k3",
     :change_from_52_week_high => "k4",
     :percent_change_from_52_week_high => "k5",
     :last_trade_with_time => "l",
     :last_trade_price => "l1",
     :close => "l1",
     :high_limit => "l2",
     :low_limit => "l3",
     :days_range => "m",
     :days_range_realtime => "m2",
     :moving_average_50_day => "m3",
     :moving_average_200_day => "m4",
     :change_from_200_day_moving_average => "m5",
     :percent_change_from_200_day_moving_average => "m6",
     :change_from_50_day_moving_average => "m7",
     :percent_change_from_50_day_moving_average => "m8",
     :name => "n",
     :notes => "n4",
     :open => "o",
     :previous_close => "p",
     :price_paid => "p1",
     :change_in_percent => "p2",
     :price_per_sales => "p5",
     :price_per_book => "p6",
     :ex_dividend_date => "q",
     :pe_ratio => "r",
     :dividend_pay_date => "r1",
     :pe_ratio_realtime => "r2",
     :peg_ratio => "r5",
     :price_eps_estimate_current_year => "r6",
     :price_eps_Estimate_next_year => "r7",
     :symbol => "s",
     :shares_owned => "s1",
     :short_ratio => "s7",
     :last_trade_time => "t1",
     #:trade_links => "t6", # doesn't work anymore - asks for brokerage and is not parse correctly
     :ticker_trend => "t7",
     :one_year_target_price => "t8",
     :volume => "v",
     :holdings_value => "v1",
     :holdings_value_realtime => "v7",
     :weeks_range_52 => "w",
     :day_value_change => "w1",
     :day_value_change_realtime => "w4",
     :stock_exchange => "x",
     :dividend_yield => "y"
  }

  # these options do not mess up the CSV parser by including ',' in the data fields
  SAVE_OPTIONS = [:symbol, :name, :average_daily_volume, :dividend_per_share, :earnings_per_share, :eps_estimate_current_year, :eps_estimate_next_year, :eps_estimate_next_quarter, :low_52_weeks, :high_52_weeks, :market_capitalization, :ebitda, :moving_average_50_day, :moving_average_200_day, :ex_dividend_date, :peg_ratio, :price_eps_estimate_current_year, :shares_owned, :volume, :stock_exchange, :dividend_yield, :change, :previous_close, :last_trade_trade]
  
  HISTORICAL_MODES = {
    :daily => "d",
    :weekly => "w",
    :monthly => "m",
    :dividends_only => "v"
  }

  def initialize(max_concurrency: 20, memoize: false)
    @hydra = Typhoeus::Hydra.new(max_concurrency: max_concurrency)
    Typhoeus::Config.memoize = memoize
    @error_message = "Symbol not found"
  end

  def run
    @hydra.run
  end

  def add_historical_data_query(symbols_array, start_date, end_date, options={}, &callback)
     start_date = Date.parse(start_date) unless start_date.is_a?(Date)
     end_date = Date.parse(end_date) unless end_date.is_a?(Date)
     options = {}
     options[:raw] ||= true
     options[:period] ||= :daily
     symbols_array.each do |symbol|
       symbol = symbol.rstrip.upcase
       url = "http://ichart.finance.yahoo.com/table.csv?s=#{URI.escape(symbol)}&d=#{end_date.month-1}&e=#{end_date.day}&f=#{end_date.year}&g=#{HISTORICAL_MODES[options[:period]]}&a=#{start_date.month-1}&b=#{start_date.day}&c=#{start_date.year}&ignore=.csv"
      @hydra.queue(make_request(url, symbol, options, callback))
    end
  end

  # returns daily historical data in one hash
  def daily_historical_data(symbols_array, start_date, end_date)
    result = {}
    callb = Proc.new do |resp|
      result.merge!(resp)
      if result.length == symbols_array.length
        return result
      end
    end
    add_historical_data_query(symbols_array, start_date, end_date, {period: :daily}, &callb)
    run
  end

  # for each symbol, the callback is executed
  def daily_historical_data_callback(symbols_array, start_date, end_date, &callback)
    add_historical_data_query(symbols_array, start_date, end_date, {period: :daily}, &callback)
    run
  end

  def read_symbols(query, &callback)
     url = "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=#{query}&callback=YAHOO.Finance.SymbolSuggest.ssCallback"
     request = Typhoeus::Request.new(url, method: :get)
     request.on_complete do |response|
       body = response.body
       body.sub!('YAHOO.Finance.SymbolSuggest.ssCallback(', '').chomp!(')')
       json_result = JSON.parse(body)
       callback.call(json_result["ResultSet"]["Result"])
     end
     @hydra.queue(request)
     @hydra.run
  end

  def quotes(symbols_array, columns_array = [:symbol, :last_trade_price, :last_trade_date, :change, :previous_close], options = {})
    options[:raw] ||= true
    symbols_array = symbols_array.map(&:upcase)
    ret = Hash[symbols_array.each_slice(1).to_a]
    symb_str = symbols_array.join("+")
    columns_array.unshift(:symbol)
    columns = "#{columns_array.map {|col| COLUMNS[col] }.join('')}"
    url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{URI.escape(symb_str)}&f=#{columns}"
    request = Typhoeus::Request.new(url, method: :get)
    request.on_complete do |response|
      begin
        result = CSV.parse(response.body, headers: columns_array)
        result.each do |row|
          h = row.to_hash
          if h[:name] == h[:symbol]
            ret[h[:symbol]] = nil 
          else 
            ret[h[:symbol]] = h
          end
        end
        return ret
      rescue
        return {error: @error_message}
      end
    end
    @hydra.queue(request)
    @hydra.run
  end

  def quotes_all_info(symbols_array)
    quotes(symbols_array, SAVE_OPTIONS)
  end

  private

  def make_request(url, symbol, options, callback)
    request = Typhoeus::Request.new(url, method: :get)
    cols = 
      if options[:period] == :dividends_only
        [:dividend_pay_date, :dividend_yield]
      else
        [:trade_date, :open, :high, :low, :close, :volume, :adjusted_close]
      end
    request.on_complete do |response|
      if response.code == 200
        if response.body[0..40] != "Date,Open,High,Low,Close,Volume,Adj Close"
          raise YahooFinanceException.new(" * Error: Unknown response body from Yahoo - #{ response.body[0..40] } ...")
        else
          result = CSV.parse(response.body, headers: cols).to_a
          result.delete_at(0)
          result.delete_at(0)
          result_hash = { symbol => result }
          callback.call(result_hash)
        end
      elsif response.code == 404
        result_hash = { symbol => "#{symbol} not found at Yahoo" }
        callback.call(result_hash)
        # raise SymbolNotFoundException.new("#{symbol} not found at Yahoo")
      else
        raise YahooFinanceException.new("Error communicating with Yahoo. Response code #{ response.code }. URL: " + "#{ url }. Response: #{ response.inspect }")
      end
    end
    request
  end

end
