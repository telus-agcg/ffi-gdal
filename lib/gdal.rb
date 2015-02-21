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
  ::FFI::GDAL.GDALAllRegister

  FFI_GDAL_ERROR_HANDLER = GDAL::CPLErrorHandler.handle_error
  ::FFI::CPL::Error.CPLSetErrorHandler(FFI_GDAL_ERROR_HANDLER)
end
