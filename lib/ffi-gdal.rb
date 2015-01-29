require_relative 'ext/narray_ext'
require_relative 'ext/numeric_as_data_type'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'
require_relative 'gdal/internal_helpers'
require_relative 'gdal/cpl_error_handler'
require_relative 'ogr/internal_helpers'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods
  include InternalHelpers

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
  autoload :Grid,
    File.expand_path('gdal/grid', __dir__)
  autoload :MajorObject,
    File.expand_path('gdal/major_object', __dir__)
  autoload :Options,
    File.expand_path('gdal/options', __dir__)
  autoload :RasterAttributeTable,
    File.expand_path('gdal/raster_attribute_table', __dir__)
  autoload :RasterBand,
    File.expand_path('gdal/raster_band', __dir__)
  autoload :RasterBandClassifier,
    File.expand_path('gdal/raster_band_classifier', __dir__)
  autoload :Utils,
    File.expand_path('gdal/utils', __dir__)
  autoload :WarpOperation,
    File.expand_path('gdal/warp_operation', __dir__)

  # Register all drivers!
  FFI::GDAL.GDALAllRegister

  FFI_GDAL_ERROR_HANDLER = GDAL::CPLErrorHandler.handle_error
  FFI::GDAL.CPLSetErrorHandler(FFI_GDAL_ERROR_HANDLER)
end

module OGR
  include InternalHelpers

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
  autoload :Field,
    File.expand_path('ogr/field', __dir__)
  autoload :GeocodingSession,
    File.expand_path('ogr/geocoding_session', __dir__)
  autoload :Geometry,
    File.expand_path('ogr/geometry', __dir__)
  autoload :GeometryCollection,
    File.expand_path('ogr/geometries/geometry_collection', __dir__)
  autoload :GeometryFieldDefinition,
    File.expand_path('ogr/geometry_field_definition', __dir__)
  autoload :Layer,
    File.expand_path('ogr/layer', __dir__)
  autoload :LineString,
    File.expand_path('ogr/geometries/line_string', __dir__)
  autoload :LinearRing,
    File.expand_path('ogr/geometries/linear_ring', __dir__)
  autoload :MultiLineString,
    File.expand_path('ogr/geometries/multi_line_string', __dir__)
  autoload :MultiPoint,
    File.expand_path('ogr/geometries/multi_point', __dir__)
  autoload :MultiPolygon,
    File.expand_path('ogr/geometries/multi_polygon', __dir__)
  autoload :NoneGeometry,
    File.expand_path('ogr/geometries/none_geometry', __dir__)
  autoload :Point,
    File.expand_path('ogr/geometries/point', __dir__)
  autoload :Polygon,
    File.expand_path('ogr/geometries/polygon', __dir__)
  autoload :SpatialReference,
    File.expand_path('ogr/spatial_reference', __dir__)
  autoload :StyleTable,
    File.expand_path('ogr/style_table', __dir__)
  autoload :StyleTool,
    File.expand_path('ogr/style_tool', __dir__)
  autoload :UnknownGeometry,
    File.expand_path('ogr/geometries/unknown_geometry', __dir__)

  FFI::GDAL.OGRRegisterAll
end

require_relative 'ffi/gdal'
require_relative 'ffi/ogr'
require_relative 'ext/float_ext'
