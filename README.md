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

ffi-gdal provides two interfaces, really: the direct FFI wrapper around GDAL's
C API, and a Ruby-fied interface that uses the FFI wrapper to make use more
like using an object-oriented library instead of a functional one.  Most likely
you'll just want to use the Ruby-fied library, but if for some reason that
doesn't get you what you want, direct access to the FFI wrapper (which is
really just direct access to the C API) is available.


### The Ruby-fied Library

To distinguish this gem from the already-existing gdal gem, you
`require ffi-gdal` to get access to the `GDAL` module and its children.


### The direct FFI wrapper

Following RubyGem conventions, to get access to the FFI wrapper, you
`require ffi/gdal`.


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
