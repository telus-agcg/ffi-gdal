# frozen_string_literal: true

require 'ogr/geometries/geometry_collection'
require 'ogr/geometries/geometry_collection_25d'
require 'ogr/geometries/multi_line_string'
require 'ogr/geometries/multi_line_string_25d'
require 'ogr/geometries/multi_point'
require 'ogr/geometries/multi_point_25d'
require 'ogr/geometries/multi_polygon'
require 'ogr/geometries/multi_polygon_25d'
require 'ogr/geometries/polygon'
require 'ogr/geometries/polygon_25d'

module OGR
  module GeometryMixins
    module ContainerMixins
      include Enumerable

      def collection?
        true
      end

      # Iterates over each geometry in the container geometry. Per `OGR` docs, the
      # yielded geometry should not be modified; if you need to do something to
      # that geometry, you should {{#clone}} it. Additionally, the yielded
      # geometry is only valid until the container changes.
      #
      # @yieldparam [OGR::Geometry]
      # @return [Enumerator]
      # @see http://gdal.org/1.11/ogr/ogr__api_8h.html#a6bac93150529a5c98811db29e289dd66
      def each
        return enum_for(:each) unless block_given?

        geometry_count.times do |i|
          yield geometry_at(i)
        end
      end
    end
  end
end

# Using prepend here to override the `#collection?` method that's already defined on Geometry.
OGR::GeometryCollection.prepend(OGR::GeometryMixins::ContainerMixins)
OGR::GeometryCollection25D.prepend(OGR::GeometryMixins::ContainerMixins)

OGR::MultiPolygon.prepend(OGR::GeometryMixins::ContainerMixins)
OGR::MultiPolygon25D.prepend(OGR::GeometryMixins::ContainerMixins)

OGR::MultiLineString.prepend(OGR::GeometryMixins::ContainerMixins)
OGR::MultiLineString25D.prepend(OGR::GeometryMixins::ContainerMixins)

OGR::MultiPoint.prepend(OGR::GeometryMixins::ContainerMixins)
OGR::MultiPoint25D.prepend(OGR::GeometryMixins::ContainerMixins)

OGR::Polygon.prepend(OGR::GeometryMixins::ContainerMixins)
OGR::Polygon25D.prepend(OGR::GeometryMixins::ContainerMixins)
