require_relative 'ffi/ogr'
require_relative 'ogr/internal_helpers'

module OGR
  include InternalHelpers

  FFI::OGR::API.OGRRegisterAll

  autoload :GeometryCollection,     'ogr/geometries/geometry_collection'
  autoload :LineString,             'ogr/geometries/line_string'
  autoload :LinearRing,             'ogr/geometries/linear_ring'
  autoload :MultiLineString,        'ogr/geometries/multi_line_string'
  autoload :MultiPoint,             'ogr/geometries/multi_point'
  autoload :MultiPolygon,           'ogr/geometries/multi_polygon'
  autoload :NoneGeometry,           'ogr/geometries/none_geometry'
  autoload :Point,                  'ogr/geometries/point'
  autoload :Polygon,                'ogr/geometries/polygon'
  autoload :UnknownGeometry,        'ogr/geometries/unknown_geometry'
end
