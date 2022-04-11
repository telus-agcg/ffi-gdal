* Documentation
* add more OGR::StyleTable
* set attributes to instance variables
* more GDALDriver
* Finish MajorObject
* Make object attributes that behave like Hashes be hashes
    * MajorObject#metadata
    * ColorTable color entries
    * Raster bands in a dataset
* Functions that take a GDALProgressFunc arg should no longer be a block; they
  should be a Proc. _Then_ the other argument should also be accepted so that
  the function can take advantage of the meta function (the one that can handle
  many layers deep of functions & their progress).
* rubocop
* Make sure extensions are in their extension files.
* Extract non-core-GDAL/OGR things into another gem?
* Fix circular dependencies. Autoload things.
* Make Enumerators for classes that do iterating over child objects
* Tame down integration tests--don't need to test so many files now.

---

2/24/2022

- [ ] GDAL1 -> GDAL2
  - [ ] Go through docs and check we've added GDAL2 functions:
    - [ ] https://gdal.org/api/cpl.html
    - [ ] https://gdal.org/api/raster_c_api.html
    - [ ] https://gdal.org/api/vector_c_api.html
    - [ ] https://gdal.org/api/ogr_srs_api.html
    - [ ] https://gdal.org/api/gdal_alg.html
    - [ ] https://gdal.org/api/gdal_utils.html
  - [ ] Remove GDAL1 things that have been deprecated in GDAL2.
- [ ] GDAL2 -> GDAL3
  - [ ] Go through docs and check we've added GDAL3 functions.
    - [ ] https://gdal.org/api/cpl.html
    - [ ] https://gdal.org/api/raster_c_api.html
    - [ ] https://gdal.org/api/vector_c_api.html
    - [ ] https://gdal.org/api/ogr_srs_api.html
    - [ ] https://gdal.org/api/gdal_alg.html
    - [ ] https://gdal.org/api/gdal_utils.html
  - [ ] Remove GDAL2 things that have been deprecated in GDAL3.
