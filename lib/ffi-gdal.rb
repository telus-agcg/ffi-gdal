require 'log_switch'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods
  extend LogSwitch

  autoload :ColorInterpretation,
    File.expand_path('gdal/color_interpretation', __dir__)
  autoload :DataType,
    File.expand_path('gdal/data_type', __dir__)
  autoload :Options,
    File.expand_path('gdal/options', __dir__)

  # Register all drivers!
  FFI::GDAL.GDALAllRegister
end

module OGR
  extend LogSwitch
end

GDAL.log_class_name = true
OGR.log_class_name = true

require_relative 'ffi/gdal'
require_relative 'ffi/ogr'
require_relative 'ext/float_ext'
require_relative 'gdal/dataset'
require_relative 'ogr/data_source'
