# frozen_string_literal: true

require_relative 'ffi-gdal'

module GDAL
  class << self
    # Use when you want something quick and easy for when you need something
    # quick for a +FFI::GDAL::GDALProgressFunc+. Outputs the duration and
    # percentage completed.
    #
    # @return [Proc] A Proc that works for a +GDALProgressFunc+ callback.
    def simple_progress_formatter
      start = Time.now

      lambda do |d, _, _|
        print "Duration: #{(Time.now - start).to_f.round(2)}s\t| #{(d * 100).round(2)}%\r"
        true
      end
    end
  end

  extend FFI::InternalHelpers

  # Autoload just the core GDAL object types.
  autoload :ColorTable,           autoload_path('gdal/color_table')
  autoload :Dataset,              autoload_path('gdal/dataset')
  autoload :DataType,             autoload_path('gdal/data_type')
  autoload :Driver,               autoload_path('gdal/driver')
  autoload :GeoTransform,         autoload_path('gdal/geo_transform')
  autoload :Logger,               autoload_path('gdal/logger')
  autoload :MajorObject,          autoload_path('gdal/major_object')
  autoload :Options,              autoload_path('gdal/options')
  autoload :RasterAttributeTable, autoload_path('gdal/raster_attribute_table')
  autoload :RasterBand,           autoload_path('gdal/raster_band')
end

require_relative 'gdal/exceptions'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'
require_relative 'gdal/internal_helpers'
require_relative 'gdal/cpl_error_handler'
require 'ffi/gdal'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods
  include InternalHelpers

  # Register all drivers!
  ::FFI::GDAL::GDAL.GDALAllRegister

  # We define our own error handler so we can turn GDAL errors into Ruby
  # exceptions.
  FFI_GDAL_ERROR_HANDLER = GDAL::CPLErrorHandler.handle_error
  ::FFI::CPL::Error.CPLSetErrorHandler(FFI_GDAL_ERROR_HANDLER)
end
