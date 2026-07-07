# frozen_string_literal: true

require_relative "ffi-gdal"
require_relative "ffi/gdal"

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

    private

    def gdal_require(path)
      File.expand_path(path, __dir__)
    end
  end

  # Autoload just the core GDAL object types.
  autoload :ColorTable,           gdal_require("gdal/color_table")
  autoload :Dataset,              gdal_require("gdal/dataset")
  autoload :DataType,             gdal_require("gdal/data_type")
  autoload :Driver,               gdal_require("gdal/driver")
  autoload :GeoTransform,         gdal_require("gdal/geo_transform")
  autoload :Logger,               gdal_require("gdal/logger")
  autoload :MajorObject,          gdal_require("gdal/major_object")
  autoload :Options,              gdal_require("gdal/options")
  autoload :RasterAttributeTable, gdal_require("gdal/raster_attribute_table")
  autoload :RasterBand,           gdal_require("gdal/raster_band")
  autoload :Utils,                gdal_require("gdal/utils")
end

require_relative "gdal/exceptions"
require_relative "gdal/version_info"
require_relative "gdal/environment_methods"
require_relative "gdal/internal_helpers"
require_relative "gdal/cpl_error_handler"

module GDAL
  extend VersionInfo
  extend EnvironmentMethods
  include InternalHelpers

  # Register all drivers!
  ::FFI::GDAL::GDAL.GDALAllRegister

  # We define our own error handler so we can turn GDAL errors into Ruby exceptions.
  #
  # The handler is installed in two places on purpose:
  #
  #   * As the GLOBAL handler we install GDAL's native (C) default handler. GDAL's own worker
  #     threads (e.g. the multi-threaded warp in GDAL >= 3.11) report through the global
  #     handler; it must NOT be a Ruby callback. A Ruby callback invoked from a worker thread
  #     needs the GVL, which the calling Ruby thread holds across the blocking GDAL call, so
  #     the two deadlock. The native default handler keeps worker-thread warnings visible on
  #     stderr. See GDAL::CPLErrorHandler::NATIVE_DEFAULT_HANDLER.
  #   * As a PUSHED handler on the main thread we install the Ruby handler. GDAL's error
  #     handler stack is thread-local, so this only affects the main thread: main-thread
  #     errors are still turned into Ruby exceptions exactly as before, while worker threads
  #     fall back to the native global handler.
  FFI_GDAL_ERROR_HANDLER = GDAL::CPLErrorHandler.handle_error
  ::FFI::CPL::Error.CPLSetErrorHandler(GDAL::CPLErrorHandler::NATIVE_DEFAULT_HANDLER)
  ::FFI::CPL::Error.CPLPushErrorHandler(FFI_GDAL_ERROR_HANDLER)
end
