require_relative 'ffi/ogr'
require_relative 'ogr/internal_helpers'

module OGR
  include InternalHelpers

  FFI::OGR::API.OGRRegisterAll

  autoload :GeometryCollection,     'ogr/geometries/geometry_collection'
  autoload :GeometryCollection25D,  'ogr/geometries/geometry_collection_25d'
  autoload :LineString,             'ogr/geometries/line_string'
  autoload :LineString25D,          'ogr/geometries/line_string_25d'
  autoload :LinearRing,             'ogr/geometries/linear_ring'
  autoload :MultiLineString,        'ogr/geometries/multi_line_string'
  autoload :MultiLineString25D,     'ogr/geometries/multi_line_string_25d'
  autoload :MultiPoint,             'ogr/geometries/multi_point'
  autoload :MultiPoint25D,          'ogr/geometries/multi_point_25d'
  autoload :MultiPolygon,           'ogr/geometries/multi_polygon'
  autoload :MultiPolygon25D,        'ogr/geometries/multi_polygon_25d'
  autoload :NoneGeometry,           'ogr/geometries/none_geometry'
  autoload :Point,                  'ogr/geometries/point'
  autoload :Point25D,               'ogr/geometries/point_25d'
  autoload :Polygon,                'ogr/geometries/polygon'
  autoload :Polygon25D,             'ogr/geometries/polygon_25d'
  autoload :UnknownGeometry,        'ogr/geometries/unknown_geometry'
end
