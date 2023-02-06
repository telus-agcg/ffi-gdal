# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.4] - 2023-02-06

### Fixed

- Move `OGR::GeometryMixins::Extensions#is_3d?` to `OGR::Geometry`.

## [1.0.3] - 2023-01-27

### Fixed

- Fix nil return value from `OGR::GeometryMixins::Extensions#utm_zone` when
  spatial_reference is not 4326.

## [1.0.2] - 2023-01-13

### Fixed

- Fix requires for lib/\*/extensions/all.rb.

## [1.0.1] - 2023-01-13

### Fixed

- Fix NoMethodError in `OGR::GeometryMixins::Extensions#utm_zone` when geometry
  is invalid.

## [1.0.0] — 2023-01-06

Changes for all releases leading up to 1.0.0 can be found in
[Changelog-0.x](/Changelog-0.x.md).

- Happy birthday!
