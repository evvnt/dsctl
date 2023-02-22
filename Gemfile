# frozen_string_literal: true

source "https://rubygems.org"

ruby `[  -z "$RBENV_VERSION" ] && cat .ruby-version || echo $RBENV_VERSION`

gem "faraday", "~> 2.7.4"
gem "faraday-net_http"
gem "dotenv"

group :development do
  gem "pry"
end
group :test do
  gem "rspec"
  gem "webmock"
end