ffi-gdal
========

Ruby wrapper around GDAL, using FFI, along with some helper methods.

Installation
------------

For Ubuntu you need to install libgdal-dev via:

    sudo apt-get install libgdal-dev


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

### Logging

For classes that are enabled with logging capabilities, you can turn logging on
and off like `GDAL::RasterBand.logging_enabled = true`. If you're using ffi-gdal
in Rails, you can `GDAL::Logger.logger = Rails.logger`.

Additional Libraries
--------------------

[ffi-gdal-extensions](https://github.com/agrian-inc/ffi-gdal-extensions) provides
additional functionality, not provided in this core, GDAL-wrapper library.

Contributing
------------

1. Fork it ( https://github.com/agrian-inc/ffi-gdal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
