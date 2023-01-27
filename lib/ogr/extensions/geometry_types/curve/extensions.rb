# frozen_string_literal: true

require "ogr/geometry"
require "gdal/extensions/geo_transform/extensions"

module OGR
  module GeometryTypes
    module Curve
      module Extensions
        # It seems as if {{#point}} should return an OGR::Point, but since OGR's
        # OGR_G_GetPoint only returns coordinates, this allows getting the point
        # as an OGR::Point.
        #
        # @param number [Integer] Index of the point to get.
        # @return [OGR::Point]
        def point_geometry(number)
          coords = point(number)
          point = OGR::Point.new
          point.set_point(0, *coords)

          point
        end

        # @return [Enumerator]
        # @yieldparam [OGR::Point]
        def each_point_geometry
          return enum_for(:each_point_geometry) unless block_given?

          point_count.times do |point_num|
            yield point_as_geometry(point_num)
          end
        end

        # @return [Array<OGR::Point>]
        # @see #each_point_geometry, #point_geometry
        def point_geometries
          each_point_geometry.to_a
        end

        # @param geo_transform [GDAL::GeoTransform]
        # @return [Array<Array>]
        def pixels(geo_transform)
          log "points count: #{point_count}"
          points.map do |x_and_y|
            result = geo_transform.world_to_pixel(*x_and_y)

            [result[:pixel].to_i.abs, result[:line].to_i.abs]
          end
        end

        def start_point
          point(0)
        end

        def end_point
          point(point_count - 1)
        end

        def closed?
          start_point == end_point
        end
      end
    end
  end
end

OGR::LineString.include(OGR::GeometryTypes::Curve::Extensions)
OGR::MultiLineString.include(OGR::GeometryTypes::Curve::Extensions)
