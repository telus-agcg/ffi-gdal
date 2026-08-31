# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in ffi-gdal.gemspec
gemspec

gem "bundler"
gem "byebug"
gem "climate_control"
gem "fakefs"
gem "rake"
gem "rspec", "~> 3.0"
gem "rspec-github"
gem "simplecov", "~> 1.0"
gem "thor"

group :lint do
  # Ruby 4.0 removed `benchmark` from default gems; rubocop's executable
  # requires it, so rubocop can't run at all under Ruby 4.0 without this.
  gem "benchmark"
  # RuboCop stack is now current. Gemfile.lock is gitignored (gem convention),
  # so these EXACT pins are what keep CI reproducible and prevent a rubocop
  # minor from silently adding cops (NewCops: enable) and breaking a green
  # build with no code change. Upgrades are deliberate: bump the pin in a
  # reviewed PR.
  gem "rubocop", "1.90.0"
  gem "rubocop-performance", "= 1.26.1"
  gem "rubocop-rake", "= 0.7.1"
  gem "rubocop-rspec", "= 3.10.2"
end
