# frozen_string_literal: true

source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

gemspec

group :test do
  gem 'rspec', '~> 3.12'
end

group :lint do
  gem 'rubocop', '~> 1.31.1'
  gem 'rubocop-rspec', '~> 2.11.1'
end

gem 'pry'
gem 'pry-byebug'

gem 'dotenv', '~> 2.8'

gem 'slop', '~> 4.10'

gem 'http', '~> 4.4' # For testing the older version of HTTP.rb

gem 'rb_sys', '~> 0.9.70'
