require 'log_switch'
require_relative 'ffi-gdal/version_info'

module GDAL
  extend VersionInfo
  extend LogSwitch
end

GDAL.log_class_name = true

require_relative 'ffi/gdal'
require_relative 'ffi-gdal/dataset'
