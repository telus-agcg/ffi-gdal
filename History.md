### 1.0.0.beta4 / 2015-04-22

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

### 1.0.0.beta3 / 2014-11-11

* Bug fixes
    * `ogr/exceptions` wasn't being required for `ext/error_symbols.rb`, thus
      any use of an OGR exception was causing a `NameError`.

### 1.0.0.beta2 / 2014-10-23

* Improvements
    * Added more documentation
    * Uncommented `attach_function` calls that had been commented out due to
      lack of support in versions I'd tested on.  These get handled now on load.

### 1.0.0.beta1 / 2014-10-23

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

### 0.0.4 / 2014-09-27

* Bug fixes
    * Fixed failure to load on Ubuntu 12.04 (GDAL v1.7.3).

### 0.0.3 / 2014-09-26

* Improvements
    * The `approx_ok` param for `RasterBand#histogram` should default to
      `false` (preferring data exactness over performance).
* Bug fixes
    * Fixed URL silliness introduced in 0.0.2.
    * `Dataset#*_band` methods should return `nil` if the band with that color
      isn't found.
    * `RasterBand#default_histogram` died if the band didn't have any values.
    * `RasterBand#histogram` wasn't returning totals.

### 0.0.2 / 2014-09-26

* New things
    * Added ability to pass a URL into `GDAL::Dataset`.

### 0.0.1 / 2014-09-26

* Happy Birthday!
