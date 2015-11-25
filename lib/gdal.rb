require_relative 'ffi/gdal'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'
require_relative 'gdal/internal_helpers'
require_relative 'gdal/cpl_error_handler'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods
  include InternalHelpers

  # Register all drivers!
  ::FFI::GDAL::GDAL.GDALAllRegister

  FFI_GDAL_ERROR_HANDLER = GDAL::CPLErrorHandler.handle_error
  ::FFI::CPL::Error.CPLSetErrorHandler(FFI_GDAL_ERROR_HANDLER)

  class << self
    # Use when you want something quick and easy for when you need something
    # quick for a +FFI::GDAL::GDALProgressFunc+. Outputs the duration and
    # percentage completed.
    #
    # @return [Proc] A Proc that works for a +GDALProgressFunc+ callback.
    def simple_progress_formatter
      start = Time.now

      lambda do |d, _, _|
        print "Duration: #{(Time.now - start).to_i}s\t| #{(d * 100).round(2)}%\r"
        true
      end
    end
  end
end
