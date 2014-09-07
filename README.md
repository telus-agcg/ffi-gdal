ffi-gdal
========

Ruby wrapper around GDAL, using FFI, along with some helper methods.

Installation
------------

Add this line to your application's Gemfile:

    gem 'ffi-gdal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffi-gdal

Usage
-----

TODO: Write usage instructions here


Testing
-------

You'll need some images to run the integration specs against, and instead of
keeping those as part of this repo, there's a Rake task that will pull OSGeo's
set of sample geotiffs down via FTP.  Running `rake get_tifs` will pull
everything down from ftp://downloads.osgeo.org/geotiff/samples and put the
files under spec/support/images/osgeo/geotiff.

Contributing
------------

1. Fork it ( https://github.com/turboladen/ffi-gdal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
