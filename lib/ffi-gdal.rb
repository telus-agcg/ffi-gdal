require 'log_switch'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods

  module Logger
    extend LogSwitch

    def self.included(base)
      base.log_class_name = true
    end
  end

  autoload :ColorEntry,
    File.expand_path('gdal/color_entry', __dir__)
  autoload :ColorInterpretation,
    File.expand_path('gdal/color_interpretation', __dir__)
  autoload :ColorTable,
    File.expand_path('gdal/color_table', __dir__)
  autoload :DataType,
    File.expand_path('gdal/data_type', __dir__)
  autoload :Dataset,
    File.expand_path('gdal/dataset', __dir__)
  autoload :Driver,
    File.expand_path('gdal/driver', __dir__)
  autoload :GeoTransform,
    File.expand_path('gdal/geo_transform', __dir__)
  autoload :MajorObject,
    File.expand_path('gdal/major_object', __dir__)
  autoload :Options,
    File.expand_path('gdal/options', __dir__)
  autoload :RasterAttributeTable,
    File.expand_path('gdal/raster_attribute_table', __dir__)
  autoload :Utils,
    File.expand_path('gdal/utils', __dir__)

  # Register all drivers!
  FFI::GDAL.GDALAllRegister

  # Internal factory method for returning a pointer from +variable+, which could
  # be either of +klass+ class or a type of FFI::Pointer.
  def self._pointer(klass, variable, warn_on_nil=true)
    if variable.is_a?(klass)
      variable.c_pointer
    elsif variable.kind_of? FFI::Pointer
      variable
    elsif warn_on_nil
      Logger.log "<#{name}._pointer> #{variable.inspect} is not a valid #{klass} or FFI::Pointer."
      Logger.log "<#{name}._pointer> Called at: #{caller(1, 1).first}"
    else
      nil
    end
  end
end

module OGR
  autoload :DataSource,
    File.expand_path('ogr/data_source', __dir__)
  autoload :Driver,
    File.expand_path('ogr/driver', __dir__)
  autoload :Envelope,
    File.expand_path('ogr/envelope', __dir__)
  autoload :Feature,
    File.expand_path('ogr/feature', __dir__)
  autoload :FeatureDefinition,
    File.expand_path('ogr/feature_definition', __dir__)
  autoload :GeocodingSession,
    File.expand_path('ogr/geocoding_session', __dir__)
  autoload :Geometry,
    File.expand_path('ogr/geometry', __dir__)
  autoload :Layer,
    File.expand_path('ogr/layer', __dir__)
  autoload :SpatialReference,
    File.expand_path('ogr/spatial_reference', __dir__)
  autoload :StyleTable,
    File.expand_path('ogr/style_table', __dir__)

  FFI::GDAL.OGRRegisterAll

  def self._boolean_access_flag(flag)
    case flag
    when 'w' then true
    when 'r' then false
    else raise "Invalid access_flag '#{access_flag}'.  Use 'r' or 'w'."
    end
  end
end

require_relative 'ffi/gdal'
require_relative 'ffi/ogr'
require_relative 'ext/float_ext'
