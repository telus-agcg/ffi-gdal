# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`ffi-gdal` is a Ruby gem that wraps the GDAL/OGR C library using FFI. It exposes two interfaces:

- **`require "ffi/gdal"`** — direct FFI bindings to GDAL's C API (`lib/ffi/`)
- **`require "ffi-gdal"` / `require "gdal"`** — Ruby-ified OOP wrappers (`lib/gdal/`, `lib/ogr/`)

The gem requires `libgdal` to be installed on the system. The library path can be overridden via `GDAL_LIBRARY_PATH` env var (defaults to `"gdal"`).

## Commands

```sh
# Run all specs
bundle exec rspec spec

# Run only unit specs
bundle exec rake spec:unit

# Run only integration specs
bundle exec rake spec:integration

# Run a single spec file
bundle exec rspec spec/unit/gdal/dataset_spec.rb

# Lint
bundle exec rubocop --parallel

# Test against GDAL 2 or 3 via Docker
docker compose run --rm gdal2 bundle exec rspec
docker compose run --rm gdal3 bundle exec rspec
```

Rubocop lives in the `:lint` Bundler group; when running specs, use `BUNDLE_WITHOUT=lint` to avoid pulling it in (CI does this automatically).

## Architecture

### Two-layer structure

```
lib/ffi/cpl/        — CPL (Common Portability Library) FFI bindings
lib/ffi/gdal/       — GDAL raster FFI bindings + C structs/enums
lib/ffi/ogr/        — OGR vector FFI bindings + C structs/enums

lib/gdal/           — Ruby OOP layer for raster (GDAL::Dataset, GDAL::RasterBand, etc.)
lib/ogr/            — Ruby OOP layer for vector (OGR::DataSource, OGR::Layer, OGR::Geometry, etc.)
lib/ext/            — Core Ruby extensions (NArray, Float, numeric type helpers)
```

### Extensions pattern

Both `lib/gdal/extensions/` and `lib/ogr/extensions/` add optional Ruby-convenience methods on top of the core GDAL/OGR classes. These are not part of the direct FFI mapping — they provide things like Enumerable-style iteration, Ruby-idiomatic type conversions, and richer I/O helpers. Loaded via `lib/gdal/extensions/all.rb` and `lib/ogr/extensions/all.rb`.

### GDAL version-aware layouts

`FFI::GDAL::InternalHelpers::LayoutVersionResolver` selects the correct FFI struct layout at runtime based on the detected GDAL version (from `GDALVersionInfo("VERSION_NUM")`). This is used in structs whose memory layout changed between GDAL 2 and 3.

### Error handling

`GDAL::CPLErrorHandler` intercepts GDAL's C error callbacks and re-raises them as Ruby exceptions. It's installed at load time in `lib/gdal.rb`. GDAL CE_Warning → `logger.warn`, CE_Failure/CE_Fatal → raise the corresponding Ruby exception class from `CPLE_MAP`.

### Key classes

- `GDAL::Dataset` — most complex class; split across several mixins in `lib/gdal/dataset/`
- `GDAL::RasterBand` — raster pixel data access; algorithm mixins in `lib/gdal/raster_band_mixins/`
- `OGR::Geometry` — base for all geometry types; concrete subclasses in `lib/ogr/geometries/`
- `OGR::Layer` — vector layer access; split across mixins in `lib/ogr/layer_mixins/`

## Tests

- `spec/unit/` — pure Ruby unit tests, no GDAL library calls needed
- `spec/integration/` — require real GDAL and test against files in `spec/support/`
- Integration specs include `IntegrationHelp` (via `config.include IntegrationHelp, type: :integration`) which provides `make_temp_test_file` for copying test fixtures to `tmp/` and cleaning up after each example
- Spec `before` hooks call `FFI::GDAL::GDAL.GDALAllRegister` and clear `tmp/`

## Style

- Double-quoted strings (`Style/StringLiterals: double_quotes`)
- `Style/ArgumentsForwarding` and `Naming/BlockForwarding` disabled — use named `**options`/`&block` forwarding to keep YARD `@param`/`@option` docs accurate
- `Style/HashSyntax` shorthand disabled — use `{x: x}` not `{x:}`
- `Dir.glob(...).sort` — keep explicit `.sort` for deterministic require order
- Commits should follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
