# Change Log

Format for this file derived from [http://keepachangelog.com](http://keepachangelog.com).

## Unreleased

### Added

- `GDAL::ColorTable.new_pointer`
- `GDAL::Dataset.new_pointer`
- `GDAL::RasterAttributeTable.new_pointer`

### Changed

- *BREAKING*: All methods with default boolean args are now keyword args.
- `GDAL::Dataset.open` now defaults to `shared_open: false`.
- `GDAL::Dataset.close` now checks that the internal pointer isn't null.
- `GDAL::Options` no longer subclasses `Hash`.
- `GDAL::RasterBand#initialize` now initializes its related `GDAL::Dataset`,
  ensuring the `Dataset` stays in memory while working with the `RasterBand`.

### Fixed

- `GDAL::ColorTable#initialize` ensures the related pointer is cleaned up.
- `GDAL::Dataset#geo_transform` ensures the related pointer is cleaned up.
- Fixed dangling pointer in `GDAL::Options.pointer` when building the string
  list.
- `GDAL::RasterAttributeTable#initialize` ensures the related pointer is cleaned up.
- `GDAL::Transformers::*` ensure the related pointer is cleaned up.
- `GDAL::WarpOperation#initialize` ensures the related pointer is cleaned up.

### Removed

* [DEV-361] Move extension methods to ffi-gdal-extensions.
* Removed attach_function to CPLURLGetValue and CPLURLAddKVP as they are not in GDAL 2.

## 1.0.0.beta11 / 2020-06-02

### Bug Fixes

* Change CPLFileFinder callback return type to pointer.

## 1.0.0.beta10 / 2019-08-28

### Bug Fixes

* [DEV-7980] Ensure `OGR::Feature#field_as_string` returns a UTF-8 encoded String.

## 1.0.0.beta9 / 2018-03-26

### Bug Fixes

* [AGDEV-30729] Change `OGERR_NONE` to use a lambda.

### Improvements

* Fix some new rubocops.

## 1.0.0.beta8 / 2017-04-24

### Improvements

* Ruby 2.3 frozen string compatibility.
* Ruby 2.4 `DateTime` time zone handling in `OGR::Feature#set_field_date_time`.

### Bug Fixes

* Ensure `GDAL::RasterBandMixinsIOExtensions#read_blocks_by_block` always yields
  an Array of pixels.

## 1.0.0.beta7 / 2016-09-21

### Improvements

* Removed all `#as_json` and `#to_json` definitions. They were out of date, not
  used, and sometimes confusing (ex OGR::Geometries#to_json vs #to_geo_json).

#### GDAL

* Added wrapper for GDALCreateAndReprojectImage in
  `gdal/dataset_mixins/warp_methods.rb`.
* (BREAKING CHANGE) Additionally, changed
  `GDAL::DatasetMixins::WarpMethods#reproject_image`'s
  `destination_spatial_reference` named param to `destination_projection` which
  takes a String of WKT for a projection instead of an `OGR::SpatialReference`.
* Added `GDAL::Options.to_hash` to convert a pointer of options to a Ruby Hash.
* Return `nil` for missing NODATA values in `GDAL::RasterBand#no_data_value` and
  `#no_data_value=`.

### Bug Fixes

#### Core

* Fixed specifying an alternate GDAL library using the `GDAL_LIBRARY_PATH`.

#### GDAL

* `GDAL::RasterBandMixins::IOExtensions#write_xy_narray` no longer duplicates
  data when blocks have a remainder.
* `GDAL::WarpOptions` should properly act as a wrapper for `FFI::GDAL::WarpOptions`.
* `Updated extract methods to be compatible with latest `GDAL::Driver#create_dataset`.
* `GDAL::MajorObject` now gets autoloaded.
* Fix `GDAL::DatasetMixins::AlgorithmMethods` to use the right `FFI` module for
  `#rasterize_geometries` and `#rasterize_layers`.

#### OGR

* [AGDEV-17357] Define constants from C using `const_set` instead of `class_eval`.
* Fixed `OGR::GeometryTypes::Curve#points` (missing local variable).

## 1.0.0.beta6 / 2016-04-18

### New Features

#### GDAL

* Added wrappers for the Grid API. It uses `GDAL::Gridder`, which is the
  programmatic equivalent to the `gdal_grid` command-line utility,
  `GDAL::GridderOptions`, which is an object used to mimic the options you pass
  to `gdal_grid`, and `GDAL::Grid`, which is the simple object that performs the
  gridding.
* Added first wrapper of `gdalwarper.h` methods, found in
  `GDAL::DatasetMixins::WarpMethods`.

#### OGR

* Added `OGR::CoordinateTransform#transform_ex`.

### Improvements

* Removed all `ObjectSpace.define_finalizer` calls that "cleaned up" C pointers
  for Ruby-wrapped objects that had not yet been closed/destroyed. This was
  keeping those Ruby objects from getting collected (?) and effectively causing
  lots of unnecessary memory use.

#### GDAL

* Added `GDAL::GeoTransformMixins::Extensions.new_from_envelope` which lets you
  create a `GDAL::GeoTransform` using the points from an `OGR::Envelope` and the
  destination raster's width and height. It's convenient because it calculates
  the pixel size for you.
* Renamed `GDAL::GridTypes` to `GDAL::GridAlgorithms`. This shouldn't impact
  anyone/thing since it's only relative to the newly added Grid API wrapper.
  There just happened to me some Grid cruft that had been laying around for some
  time.
* Added `GDAL::RasterBand#write_block`. Somehow this went missing from previous
  `RasterBand` wrapping.
* Renamed `GDAL::RasterBandMixins::Extenions#each_by_block` to `#read_by_block`.
  Its functionality was doing reading, yet implied reading or writing; since
  writing by block isn't needed anywhere internally yet, I just renamed this.
* Renamed `GDAL::RasterBandMixins#write_array` to `#write_xy_narray`. This
  method's name inferred that it could write any old Array, but that's not the
  case--it only writes 2D NArray data.
* Added `GDAL::InternalHelpers._buffer_from_data_type` to compliment the
  existing `._pointer_from_data_type`. Useful for creating buffer-specific
  pointers from a GDAL data type.
* `GDAL::DatasetMixins::Extensions#extent` now manually builds an `OGR::Polygon`
  instead of polygonizing the entire dataset and taking the envelope of that.
  Much faster this way.
* Refactored `GDAL::RasterBandMixins::Exsentions#projected_points` to return a
  3D NArray (indicating pixel/row position) instead of just a 2D NArray of
  coordinates.
* Added `GDAL::InternalHelpers` methods for creating NArrays based on GDAL
  data types.
* `GDAL::Options` values all have `#to_s` called on them to ensure they're
  Strings before handing them over to GDAL. The GDAL options "hash" requires
  that both keys and values be Strings.
* `GDAL::RasterBandMixins::AlgorithmMethods` that use GDALProgressFunc functions
  can now participate in GDALScaledProgress functions.
* Added `GDAL::RasterBandMixins::Extensions#pixel_count`.
* Allow `GDAL::RasterBand#create_mask_band` to take a single flag or many.
* Allow `GDAL::Dataset`s to be open in shared mode vs non-shared mode. All
  Datasets now default to use shared mode.
* Allow `GDAL::Driver#create_dataset` and `GDAL::Dataset.open` to take a block,
  yielding the dataset then closing it afterwards.
* `GDAL::RasterBandClassifier` now uses NArray to classify. Can result in quite
  a large performance gain.
* `GDAL::Driver#copy_dataset` now properly takes progress block arguments.
* `GDAL::Driver#copy_dataset` now yields a writable Dataset.
* Swapped order of params in `GDAL::Driver#rename_dataset` to be (old, new)
  instead of (new, old).
* Added enumerator `RasterAttributeTableMixins::Extensions#each_column` to allow
  nicer iterating over columns.
* `GDAL::RasterAttributeTable` methods that returned -1 when a value can't be
  returned now return nil instead.
* Renamed `GDAL::RasterAttributeTable#value_to_*` methods to be named after
  their C functions. Also, renamed `#add_value` to `#set_value` and refactored
  into `RasterAttributeTableMixins::Extensions`.

#### OGR

* Added `OGR::FeatureExtensions#field()` which gets the field using the
  associated `OGR::FieldDefinition#type`. Makes so you don't always have to
  request the field by its type (`field_as_double`).
* Added `OGR::LayerMixins::Extensions#point_values()` which gets values for all
  of the points in the layer. It also allows you to specify getting field values
  with that, which helps retrieving data for the Grid API. You can also pass it
  a block to filter out points that don't match some criteria defined in the
  block.
* Added `OGR::LayerMixins::Extensions#any_geometries_with_z?` which simply
  checks to see if the layer has any geometries with Z values.
* `GDAL::DataType.by_name` always calls `#to_s` on the param now, letting you
  pass in Symbols.
* Added `OGR::Point#set_point`, `OGR::Point25#set_point`, and
  `OGR::GeometryTypes::Curve#set_point` wrappers for `OGR_G_SetPoint_2D` and
  `OGR_G_SetPoint`.
* Added `OGR::LineString#add_geometry` to allow adding a OGR::Point object to
  the LineString instead of having to pass coordinates in to #add_point.
* `OGR::LayerMixins::Extensions#geometry_from_extent` now builds an
  `OGR::Polygon` using the same algorithm that
  `GDAL::DatasetMixins::Extensions#extent` uses. One could argue that there was
  also a bug here in that `geometry_from_extent` used to return the convex hull
  of the extent, not the extent itself.
* Extracted `OGR::LayerMixins::Extensions#each_feature` from
  `OGR::LayerMixins::Extensions#features` to provide an Enumerator. This lets
  consumers utilize yielded `OGR::Feature`s as they're retrieved instead of
  after the `features` Array has been built.
  `OGR::LayerMixins::Extensions#features` now uses this too.
* Added `OGR::GeometryMixins::Extensions#invalid?` to compliment
  `OGR::Geometry#valid?`.
* Added `OGR::LayerMixins::Extensions#point_geometry`, `#each_point_geometry`,
  and `point_geometries`. Since `#point` implies it returns a Point object, but
  the OGR API's related method returns point values (x, y, z), it seemed like
  it would be useful to have a method that returned a geometry.
* `OGR::DataSource.open` can now take a block, yielding the data source, then
  closing it afterwards.

### Bug Fixes

* Cleanup `OGR::Feature`s that were a result of `OGR::Layer#next_feature`.
  According to GDAL docs, these *must* be cleaned up before the layer is.

#### GDAL

* `GDAL::RasterBandMixins::AlgorithmMethods#fill_nodata!` was calling the old
  name of the C function.
* `GDAL::EnvironmentMethods#dump_open_datasets` now works.

#### OGR

* `OGR::Field#date=` was casting the passed value to a `Time` object, which in
  doing so was setting the time zone. If a user passes in an object that doesn't
  have the TZ set, the method shouldn't be setting it for them.
* `OGR::Geometry#point_on_surface` now properly returns a geometry object.
* `OGR::CoordinateTransform#transform` never worked. Fixed.
* `OGR::GeometryMixins::Extensions#utm_zone` no longer creates invalid geometry.
* `OGR::Feature#dump_readable` never worked. Fixed.
* `OGR::Geometry#dump_readable` never worked. Fixed.
* Added missing output_layer param to `OGR::LayerMixins::OGRLayerMethodMethods`.
* `FFI::OGR::Core::WKBGeometryType` was using an INT32 instead of UINT32 and
  thus 25D geometry types weren't completely accurate.

## 1.0.0.beta5 / 2015-06-16

* Improvements
    * `GDAL::RasterBandClassifier#equal_count_ranges` now returns `nil` if there
      aren't enough points per group/class to return the requested number of
      breaks.
    * Simplified NDVI (and related) methods in
      `GDAL::DatasetMixins::Extensions`.
    * NDVI and related methods in `GDAL::DatasetMixins::Extensions` now close
      the newly created dataset instead of leaving it open. It's been far too
      easy to forget to close the dataset after creation, leaving seemingly
      incorrect resulting datasets (since GDAL doesn't flush writes until the
      dataset is closed).
    * NDVI methods in `GDAL::DatasetMixins::Extensions` no longer check for
      NaNs after doing the NDVI calculations, thus speeding up the algorithm.
    * `GDAL::DatasetMixins::Extensions#remove_negatives_from` now uses an NArray
      mask to remove the negative values instead of looping through each value.
    * Added `GDAL::RasterBand#raster_io` and refactored
      `GDAL::RasterBand#write_array` to use it.
    * `GDAL::DatasetMixins::Extensions` NDVI methods now default to NODATA of -9999.0.

## 1.0.0.beta4 / 2015-04-22

Whoa there's lots of changes here... Many are outlined below, but there's really
a ton more.

* Improvements
    * Full refactor of FFI/C function wrapper. Closer mapping of Ruby functions
      within modules to the C-header files where the functions actually reside.
    * Full redesign of the error handling mechanism; ffi-gdal now hooks in to
      GDAL's error handling, thus errors raised from GDAL automagically get handed
      over as Ruby exceptions. (GDAL only; OGR doesn't provide this.) This also
      entailed adding a bunch of new exceptions and renaming some old ones.
    * Better library finding on Linux.
    * Wrapped most of GDAL's Grid API.
    * Wrapped some of GDAL's Warp API.
    * GDAL::Dataset can now open PostGISRaster datasets.
    * Lots more OGR love. Much of this API has now been vetted.
    * Added `GDAL::RasterClassifier` for classifying raster bands.
    * Added some wrapper methods for classes that support capability testing.
* Bug fixes
    * Fixed some GDAL::Dataset extension methods (`extract_ndvi` and friends)
      that weren't properly handling various data types.
    * Better handling of large files.
    * Fixed regular crashes when dealing with OGR Geometries and
      SpatialReferences.

## 1.0.0.beta3 / 2014-11-11

* Bug fixes
    * `ogr/exceptions` wasn't being required for `ext/error_symbols.rb`, thus
      any use of an OGR exception was causing a `NameError`.

## 1.0.0.beta2 / 2014-10-23

* Improvements
    * Added more documentation
    * Uncommented `attach_function` calls that had been commented out due to
      lack of support in versions I'd tested on.  These get handled now on load.

## 1.0.0.beta1 / 2014-10-23

Lots of changes, so just the highlights here...

* API Improvements
    * Added C and Ruby wrapper for most of OGR.
    * Better handling of CPLErr return values.
    * Allow loading, even when C functions aren't defined in the version of
      GDAL that you're using.
    * Split out additions to GDAL/OGR in `*_extensions.rb` modules.  Methods
      contained in `Extensions` modules don't directly wrap GDAL/OGR functions,
      but either provide new functionality or attempt to make library usage more
      Rubyesque.
    * Added `#as_json`, `#to_json` to many classes.
* Internal Improvements
    * Lots of cleanup of class internals.
    * `autoload` child GDAL and OGR Ruby classes.
    * Renamed files under ffi/ that were derived from GDAL/OGR header files to
      include `_h` in the name.

## 0.0.4 / 2014-09-27

* Bug fixes
    * Fixed failure to load on Ubuntu 12.04 (GDAL v1.7.3).

## 0.0.3 / 2014-09-26

* Improvements
    * The `approx_ok` param for `RasterBand#histogram` should default to
      `false` (preferring data exactness over performance).
* Bug fixes
    * Fixed URL silliness introduced in 0.0.2.
    * `Dataset#*_band` methods should return `nil` if the band with that color
      isn't found.
    * `RasterBand#default_histogram` died if the band didn't have any values.
    * `RasterBand#histogram` wasn't returning totals.

## 0.0.2 / 2014-09-26

* New things
    * Added ability to pass a URL into `GDAL::Dataset`.

## 0.0.1 / 2014-09-26

* Happy Birthday!
