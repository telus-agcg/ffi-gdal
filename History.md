# Change Log

Format for this file derived from [http://keepachangelog.com](http://keepachangelog.com).

## Unreleased / yyyy-mm-dd

## New Features

* Added wrappers for the Grid API. It uses `GDAL::Gridder`, which is the
  programmatic equivalent to the `gdal_grid` command-line utility,
  `GDAL::GridderOptions`, which is an object used to mimic the options you pass
  to `gdal_grid`, and `GDAL::Grid`, which is the simple object that performs the
  gridding.

### Improvements

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
* Added `OGR::Point#set_point`, `OGR::Point25#set_point`, and
  `OGR::GeometryTypes::Curve#set_point` wrappers for `OGR_G_SetPoint_2D` and
  `OGR_G_SetPoint`.
* `GDAL::DatasetMixins::Extensions#extent` now manually builds an `OGR::Polygon`
  instead of polygonizing the entire dataset and taking the envelope of that.
  Much faster this way.
* Refactored `GDAL::RasterBandMixins::Exsentions#projected_points` to return a
  3D NArray (indicating pixel/row position) instead of just a 2D NArray of
  coordinates.
* Added `GDAL::InternalHelpers` methods for creating NArrays based on GDAL
  data types.
* Added `OGR::LineString#add_geometry` to allow adding a OGR::Point object to
  the LineString instead of having to pass coordinates in to #add_point.
* `GDAL::Options` values all have `#to_s` called on them to ensure they're
  Strings before handing them over to GDAL. The GDAL options "hash" requires
  that both keys and values be Strings.

### Bug Fixes

* `OGR::Field#date=` was casting the passed value to a `Time` object, which in
  doing so was setting the time zone. If a user passes in an object that doesn't
  have the TZ set, the method shouldn't be setting it for them.
* `OGR::Geometry#point_on_surface` now properly returns a geometry object.

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
      contained in `Extentions` modules don't directly wrap GDAL/OGR functions,
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
