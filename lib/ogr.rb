# frozen_string_literal: true

require_relative 'ffi-gdal'
require_relative 'ogr/internal_helpers'
require_relative 'ogr/exceptions'
require_relative 'ogr/error_handling'

module OGR
  extend FFI::InternalHelpers
  include InternalHelpers

  FFI::OGR::API.OGRRegisterAll

  # Autoload OGR Geometry object types.
  autoload :GeometryCollection,     autoload_path('ogr/geometries/geometry_collection')
  autoload :GeometryCollection25D,  autoload_path('ogr/geometries/geometry_collection_25d')
  autoload :LineString,             autoload_path('ogr/geometries/line_string')
  autoload :LineString25D,          autoload_path('ogr/geometries/line_string_25d')
  autoload :LinearRing,             autoload_path('ogr/geometries/linear_ring')
  autoload :MultiLineString,        autoload_path('ogr/geometries/multi_line_string')
  autoload :MultiLineString25D,     autoload_path('ogr/geometries/multi_line_string_25d')
  autoload :MultiPoint,             autoload_path('ogr/geometries/multi_point')
  autoload :MultiPoint25D,          autoload_path('ogr/geometries/multi_point_25d')
  autoload :MultiPolygon,           autoload_path('ogr/geometries/multi_polygon')
  autoload :MultiPolygon25D,        autoload_path('ogr/geometries/multi_polygon_25d')
  autoload :NoneGeometry,           autoload_path('ogr/geometries/none_geometry')
  autoload :Point,                  autoload_path('ogr/geometries/point')
  autoload :Point25D,               autoload_path('ogr/geometries/point_25d')
  autoload :Polygon,                autoload_path('ogr/geometries/polygon')
  autoload :Polygon25D,             autoload_path('ogr/geometries/polygon_25d')
  autoload :UnknownGeometry,        autoload_path('ogr/geometries/unknown_geometry')

  # Autoload core OGR types
  autoload :CoordinateTransformation, autoload_path('ogr/coordinate_transformation')
  autoload :DataSource,               autoload_path('ogr/data_source')
  autoload :Driver,                   autoload_path('ogr/driver')
  autoload :Envelope,                 autoload_path('ogr/envelope')
  autoload :Feature,                  autoload_path('ogr/feature')
  autoload :FeatureDefinition,        autoload_path('ogr/feature_definition')
  autoload :FieldDefinition,          autoload_path('ogr/field_definition')
  autoload :Geometry,                 autoload_path('ogr/geometry')
  autoload :GeometryFieldDefinition,  autoload_path('ogr/geometry_field_definition')
  autoload :Layer,                    autoload_path('ogr/layer')
  autoload :SpatialReference,         autoload_path('ogr/spatial_reference')
  autoload :StyleTable,               autoload_path('ogr/style_table')
end
