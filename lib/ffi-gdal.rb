require 'log_switch'
require_relative 'ext/narray_ext'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods

  module Logger
    include LogSwitch
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
  autoload :WarpOperation,
    File.expand_path('gdal/warp_operation', __dir__)

  # Register all drivers!
  FFI::GDAL.GDALAllRegister

  # Internal factory method for returning a pointer from +variable+, which could
  # be either of +klass+ class or a type of FFI::Pointer.
  def self._pointer(klass, variable, warn_on_nil=true)
    if variable.kind_of?(klass)
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

  # @param data_type [FFI::GDAL::GDALDataType]
  # @return [Symbol] The FFI Symbol that represents a data type.
  def self._pointer_from_data_type(data_type, size=nil)
    pointer_type = _gdal_data_type_to_ffi(data_type)

    if size
      FFI::MemoryPointer.new(pointer_type, size)
    else
      FFI::MemoryPointer.new(pointer_type)
    end
  end

  # Maps GDAL DataTypes to FFI types.
  #
  # @param data_type [FFI::GDAL::GDALDataType]
  def self._gdal_data_type_to_ffi(data_type)
    case data_type
    when :GDT_Byte then :uchar
    when :GDT_UInt16 then :uint16
    when :GDT_Int16 then :int16
    when :GDT_UInt32 then :uint32
    when :GDT_Int32 then :int32
    when :GDT_Float32 then :float
    when :GDT_Float64 then :double
    else
      :float
    end
  end

  # Check to see if the function is supported in the version of GDAL that we're
  # using.
  #
  # @param function_name [Symbol]
  # @return [Boolean]
  def self._supported?(function_name)
    !FFI::GDAL.unsupported_gdal_functions.include?(function_name)
  end
end

module OGR
  autoload :CoordinateTransformation,
    File.expand_path('ogr/coordinate_transformation', __dir__)
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
  autoload :LineString,
    File.expand_path('ogr/line_string', __dir__)
  autoload :LinearRing,
    File.expand_path('ogr/linear_ring', __dir__)
  autoload :MultiLineString,
    File.expand_path('ogr/multi_line_string', __dir__)
  autoload :MultiPoint,
    File.expand_path('ogr/multi_point', __dir__)
  autoload :MultiPolygon,
    File.expand_path('ogr/multi_polygon', __dir__)
  autoload :Point,
    File.expand_path('ogr/point', __dir__)
  autoload :Polygon,
    File.expand_path('ogr/polygon', __dir__)
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
