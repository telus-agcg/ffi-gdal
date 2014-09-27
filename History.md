### 0.0.4 / 2014-09-27

* Bug fixes
    * Fixed failure to load on Ubuntu 12.04 (GDAL v1.7.3).

### 0.0.3 / 2014-09-26

* Improvements
    * The `approx_ok` param for `RasterBand#histogram` should default to
      `false` (prefering data exactness over performance).
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
