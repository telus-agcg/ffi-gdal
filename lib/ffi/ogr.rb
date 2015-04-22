require 'ffi'
require_relative 'gdal'

require_relative 'cpl/conv'
require_relative 'cpl/minixml'
require_relative 'ogr/core'
require_relative 'ogr/api'

# All of these depend on the above
require_relative 'ogr/srs_api'
require_relative 'ogr/featurestyle'
require_relative 'ogr/geocoding'
