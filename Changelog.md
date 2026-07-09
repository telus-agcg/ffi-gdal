# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Dropped support for Ruby < 3.4. `required_ruby_version` is now `>= 3.4`.
- CI now runs against Ruby 3.4 and 4.0 on Ubuntu 22.04/24.04 only
  (previously tested a matrix of Ruby 2.6–3.4 across Ubuntu
  20.04/22.04/24.04).

### Fixed

- Added `logger` as an explicit runtime dependency. It was removed from
  Ruby's default gems in 4.0, and `log_switch` (used for `GDAL::Logger`)
  requires it; without this, `require "ffi-gdal"` fails on Ruby 4.0.
- Fixed the Ractor integration spec on Ruby 4.0. `Ractor#take` was removed
  in Ruby 4.0 in favor of `Ractor#value` (backed by `Ractor::Port`), but
  `Ractor#value` doesn't exist prior to Ruby 4.0 — so neither method works
  across our whole Ruby matrix. The spec now picks whichever method is
  defined at runtime.
- Disabled YJIT (`RUBY_YJIT_ENABLE=0`) when running specs in CI, suspecting
  it caused an intermittent Ruby 4.0 VM crash (`[BUG] should have cvar
  cache entry` inside `rexml`) on `ubuntu-22.04`. Later confirmed YJIT was
  already off by default and unrelated to the crash — removed this in
  favor of the `:lint` group change below.
- Added `benchmark` as an explicit dependency. Without it, `rubocop`
  (pinned to `1.63.1`) fails to even start under Ruby 4.0 with
  `LoadError: cannot load such file -- benchmark`, since Ruby 4.0 removed
  `benchmark` from its default gems and rubocop's executable requires it.
- Moved `rubocop`/`rubocop-performance` (and their `benchmark` dependency)
  into a `:lint` Bundler group, excluded from the Test CI job's `bundle
  install` (`BUNDLE_WITHOUT: lint`). Rubocop (which was suspected in the
  YJIT investigation above) isn't needed to run specs; this shrinks the
  Test job's dependency footprint.
- Added `rexml` as an explicit runtime dependency. `multi_xml` (used by
  `GDAL::Driver`/`GDAL::MajorObject`) needs a real XML parser backend and
  falls back to REXML when none of Nokogiri/LibXML/Ox are installed; it
  was only working by accident because `rubocop` happened to pull in
  `rexml` transitively. Moving rubocop into the `:lint` group (above)
  surfaced this — the Test job's specs failed with `MultiXml.parse`
  errors once rexml was no longer implicitly installed.

### Removed

- Removed the "Specs in Docker" (GDAL2) CI workflow. The `Dockerfile.gdal2`
  and `docker-compose.yml` `gdal2` service remain for local testing against
  GDAL 2.4.4, but this is no longer verified in CI.
- Removed the Codacy Security Scan CI workflow. It has never passed
  (fails with a credentials/tool-repository error unrelated to this repo's
  code) and isn't worth the maintenance/noise.

### Added

- Added support for Ruby 4.0 in CI.

## [1.1.0] — 2024-08-16

### Added

- [gh-76](https://github.com/telus-agcg/ffi-gdal/issues/76): Add VSI
  `PathSpecificOptions` and `VSI` Credentials.
- [gh-78](https://github.com/telus-agcg/ffi-gdal/issues/78): Add basic support
  for Ractors.
- [gh-79](https://github.com/telus-agcg/ffi-gdal/issues/79): Initial GDAL Utils
  support.
- [gh-81](https://github.com/telus-agcg/ffi-gdal/issues/81): Improve support for
  GDAL 3.
- [gh-84](https://github.com/telus-agcg/ffi-gdal/issues/84): Improve raster band
  offset/scaling handling.
- [gh-86](https://github.com/telus-agcg/ffi-gdal/issues/86): Add
  `GDAL::GeoTransform#==`.
- [gh-91](https://github.com/telus-agcg/ffi-gdal/issues/91): Add
  `GDAL::MajorObject#description=`.
- [gh-100](https://github.com/telus-agcg/ffi-gdal/issues/100): Add support for
  `GDT_Int8`, `GDT_UInt64`, `GDT_Int64`.
- [gh-103](https://github.com/telus-agcg/ffi-gdal/issues/103): Add support for
  GDAL 3.6, 3.8.

### Changed

- [gh-102](https://github.com/telus-agcg/ffi-gdal/issues/102): Add support for
  new CPLE error codes.

### Fixed

- [gh-74](https://github.com/telus-agcg/ffi-gdal/issues/74): Add
  `/opt/homebrew/include` to header file search paths (fix for macOS).
- [gh-77](https://github.com/telus-agcg/ffi-gdal/issues/77): Fix logging for
  debug messages.

## [1.0.4] — 2023-02-06

### Fixed

- Move `OGR::GeometryMixins::Extensions#is_3d?` to `OGR::Geometry`.

## [1.0.3] — 2023-01-27

### Fixed

- Fix nil return value from `OGR::GeometryMixins::Extensions#utm_zone` when
  `spatial_reference` is not 4326.

## [1.0.2] — 2023-01-13

### Fixed

- Fix requires for lib/\*/extensions/all.rb.

## [1.0.1] — 2023-01-13

### Fixed

- Fix NoMethodError in `OGR::GeometryMixins::Extensions#utm_zone` when geometry
  is invalid.

## [1.0.0] — 2023-01-06

Changes for all releases leading up to 1.0.0 can be found in
[Changelog-0.x](/Changelog-0.x.md).

- Happy birthday!
