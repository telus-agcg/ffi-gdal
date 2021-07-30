# frozen_string_literal: true

require_relative 'ffi-gdal'
require_relative 'ogr/internal_helpers'
require_relative 'ogr/exceptions'
require_relative 'ogr/error_handling'

module OGR
  include InternalHelpers

  FFI::OGR::API.OGRRegisterAll

  def self.ogr_require(path)
    File.expand_path(path, __dir__)
  end

  # Autoload OGR Geometry object types.
  autoload :CircularString,         ogr_require('ogr/circular_string')
  autoload :CompoundCurve,          ogr_require('ogr/compound_curve')
  autoload :CurvePolygon,           ogr_require('ogr/curve_polygon')
  autoload :MultiCurve,             ogr_require('ogr/multi_curve')
  autoload :MultiSurface,           ogr_require('ogr/multi_surface')

  autoload :GeometryCollection,     ogr_require('ogr/geometry_collection')
  autoload :LineString,             ogr_require('ogr/line_string')
  autoload :LinearRing,             ogr_require('ogr/linear_ring')
  autoload :MultiLineString,        ogr_require('ogr/multi_line_string')
  autoload :MultiPoint,             ogr_require('ogr/multi_point')
  autoload :MultiPolygon,           ogr_require('ogr/multi_polygon')
  autoload :Point,                  ogr_require('ogr/point')
  autoload :Polygon,                ogr_require('ogr/polygon')

  autoload :GeometryCollection25D,  ogr_require('ogr/geometry_collection_25d')
  autoload :LineString25D,          ogr_require('ogr/line_string_25d')
  autoload :MultiLineString25D,     ogr_require('ogr/multi_line_string_25d')
  autoload :MultiPoint25D,          ogr_require('ogr/multi_point_25d')
  autoload :MultiPolygon25D,        ogr_require('ogr/multi_polygon_25d')
  autoload :Point25D,               ogr_require('ogr/point_25d')
  autoload :Polygon25D,             ogr_require('ogr/polygon_25d')

  autoload :NoneGeometry,           ogr_require('ogr/none_geometry')
  autoload :UnknownGeometry,        ogr_require('ogr/unknown_geometry')

  # Autoload core OGR types
  autoload :CoordinateTransformation, ogr_require('ogr/coordinate_transformation')
  autoload :DataSource,               ogr_require('ogr/data_source')
  autoload :Driver,                   ogr_require('ogr/driver')
  autoload :Envelope,                 ogr_require('ogr/envelope')
  autoload :Feature,                  ogr_require('ogr/feature')
  autoload :FeatureDefinition,        ogr_require('ogr/feature_definition')
  autoload :FieldDefinition,          ogr_require('ogr/field_definition')
  autoload :Geometry,                 ogr_require('ogr/geometry')
  autoload :GeometryFieldDefinition,  ogr_require('ogr/geometry_field_definition')
  autoload :Layer,                    ogr_require('ogr/layer')
  autoload :SpatialReference,         ogr_require('ogr/spatial_reference')
  autoload :StyleTable,               ogr_require('ogr/style_table')
end
