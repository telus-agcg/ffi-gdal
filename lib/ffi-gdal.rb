require 'log_switch'
require_relative 'gdal/version_info'

module GDAL
  extend VersionInfo
  extend LogSwitch
end

module OGR
  extend LogSwitch
end

GDAL.log_class_name = true
OGR.log_class_name = true

require_relative 'ffi/gdal'
require_relative 'ffi/ogr'
require_relative 'gdal/dataset'
require_relative 'ogr/data_source'
