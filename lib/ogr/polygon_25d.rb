# frozen_string_literal: true

require_relative 'polygon'

module OGR
  # NOTE: {{#type}} will return :wkbPolygon (read: 2D instead of 2.5D) until a Z
  # value is set.
  class Polygon25D < Polygon
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbPolygon25D
  end
end
