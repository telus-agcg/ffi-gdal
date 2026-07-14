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
gem "simplecov", "~> 0.9"
gem "thor"

group :lint do
  # Ruby 4.0 removed `benchmark` from default gems; rubocop's executable
  # requires it, so rubocop can't run at all under Ruby 4.0 without this.
  gem "benchmark"
  # TODO: Upgrade rubocop/rubocop-performance. These are pinned to old
  # versions because bumping them pulls in ~100+ new cop violations that
  # haven't been triaged yet. Now that we've dropped Ruby < 3.4, there's no
  # longer a Ruby-version reason to hold back — this is purely deferred
  # cleanup work.
  gem "rubocop", "<= 1.88.3"
  gem "rubocop-performance", "<= 1.24.0"
end
