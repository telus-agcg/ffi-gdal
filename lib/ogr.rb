require_relative 'ffi-gdal'
require_relative 'ogr/internal_helpers'

module OGR
  include InternalHelpers

  FFI::OGR::API.OGRRegisterAll

  def self.ogr_require(path)
    File.expand_path(path, __dir__)
  end

  autoload :GeometryCollection,     ogr_require('ogr/geometries/geometry_collection')
  autoload :GeometryCollection25D,  ogr_require('ogr/geometries/geometry_collection_25d')
  autoload :LineString,             ogr_require('ogr/geometries/line_string')
  autoload :LineString25D,          ogr_require('ogr/geometries/line_string_25d')
  autoload :LinearRing,             ogr_require('ogr/geometries/linear_ring')
  autoload :MultiLineString,        ogr_require('ogr/geometries/multi_line_string')
  autoload :MultiLineString25D,     ogr_require('ogr/geometries/multi_line_string_25d')
  autoload :MultiPoint,             ogr_require('ogr/geometries/multi_point')
  autoload :MultiPoint25D,          ogr_require('ogr/geometries/multi_point_25d')
  autoload :MultiPolygon,           ogr_require('ogr/geometries/multi_polygon')
  autoload :MultiPolygon25D,        ogr_require('ogr/geometries/multi_polygon_25d')
  autoload :NoneGeometry,           ogr_require('ogr/geometries/none_geometry')
  autoload :Point,                  ogr_require('ogr/geometries/point')
  autoload :Point25D,               ogr_require('ogr/geometries/point_25d')
  autoload :Polygon,                ogr_require('ogr/geometries/polygon')
  autoload :Polygon25D,             ogr_require('ogr/geometries/polygon_25d')
  autoload :UnknownGeometry,        ogr_require('ogr/geometries/unknown_geometry')
end
