# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yfinance'

Gem::Specification.new do |spec|
  spec.name          = "yfinance"
  spec.version       = "1.0.13"
  spec.authors       = ["Alexander Potrykus"]
  spec.email         = ["1530801+apotry@users.noreply.github.com"]
  spec.summary       = %q{Fetches Yahoo! Finance data using parallel HTTP requests.}
  spec.description   = %q{Uses Typhoeus to make HTTP requests to the Yahoo! Finance API in parallel. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = "lib"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.4"
  spec.add_dependency "typhoeus", '~> 0.6.9'
  spec.add_dependency "ffi", '~> 1.9'
end
