# Yfinance - Fast Yahoo Finance Wrapper Using Parallel Requests

A wrapper of the Yahoo! Finance API in Ruby using parallel HTTP requests. Requesting daily historical stock market prices of 100 companies takes only
4.8 seconds on my system - using the usual sequential approach takes 56.4 seconds!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yfinance'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yfinance

## Usage
All methods make use of parallel requests, and therefore should
be a multitude faster than using normal sequential requests.

### Latest quotes for symbols
Use the `quotes` method and pass it an array of symbols and
the list of fields
```ruby
yf = Yfinance.new
res = yf.quotes(["MSFT", "GOOG"])
p res[0].symbol # prints "MSFT"
```
Supported fields are:
```ruby
     :after_hours_change_real_time
     :annualized_gain 
     :ask
     :ask_real_time
     :ask_size
     :average_daily_volume
     :bid
     :bid_real_time
     :bid_size
     :book_value
     :change
     :change_and_percent_change
     :change_from_200_day_moving_average 
     :change_from_50_day_moving_average 
     :change_from_52_week_high 
     :change_From_52_week_low 
     :change_in_percent 
     :change_percent_realtime 
     :change_real_time
     :close 
     :comission
     :day_value_change 
     :day_value_change_realtime 
     :days_range
     :days_range_realtime 
     :dividend_pay_date 
     :dividend_per_share
     :dividend_yield
     :earnings_per_share
     :ebitda 
     :eps_estimate_current_year 
     :eps_estimate_next_quarter 
     :eps_estimate_next_year 
     :error_indicator 
     :ex_dividend_date
     :float_shares 
     :high 
     :high_52_weeks 
     :high_limit 
     :holdings_gain 
     :holdings_gain_percent 
     :holdings_gain_percent_realtime 
     :holdings_gain_realtime 
     :holdings_value 
     :holdings_value_realtime 
     :last_trade_date
     :last_trade_price
     :last_trade_realtime_withtime 
     :last_trade_size 
     :last_trade_time 
     :last_trade_with_time 
     :low 
     :low_52_weeks 
     :low_limit 
     :market_cap_realtime 
     :market_capitalization 
     :more_info 
     :moving_average_200_day 
     :moving_average_50_day 
     :name 
     :notes 
     :one_year_target_price 
     :open 
     :order_book 
     :pe_ratio 
     :pe_ratio_realtime 
     :peg_ratio 
     :percent_change_from_200_day_moving_average 
     :percent_change_from_50_day_moving_average 
     :percent_change_from_52_week_high 
     :percent_change_from_52_week_low 
     :previous_close 
     :price_eps_estimate_current_year 
     :price_eps_Estimate_next_year 
     :price_paid 
     :price_per_book 
     :price_per_sales 
     :shares_owned 
     :short_ratio 
     :stock_exchange 
     :symbol 
     :ticker_trend 
     :trade_date
     :trade_links 
     :volume
     :weeks_range_52 
```

### Getting historical data for a set of symbols
Pass an array of symbols and the date range to the Yfinance method `add_historical_data_query`
```ruby
    symbols = ['AAPL', 'MSFT', 'GOOG']
    result = Proc.new { |response| p response}
    yf = Yfinance.new
    yf.add_historical_data_query(symbols, '1971-12-30', '2014-09-17', {period: :daily}, &result)
    yf.run
```
The period can be specified as `:daily, :monthly, :weekly, :dividends`.

### Changing the number of concurrent requests
This is done in the initializer:
```ruby
Yfinance.new(max_concurrency: 50) # default 20
```
Don't set this too high, otherwise Yahoo might block any further requests.

### Autocomplete symbols
Use the `read_symbols` method
```ruby
query = "yahoo"
yf = Yfinance.new
yf.read_symbols(query) do |res|
  p res
end
```

### Memoization
Requests can be memoized during a single run call. Enable memoization in the initializer:
```ruby
yf = Yfinance.new(memoize: true) # default is 'false'
```


