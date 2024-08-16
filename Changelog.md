# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

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
