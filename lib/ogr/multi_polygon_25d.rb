# frozen_string_literal: true

require_relative 'multi_polygon'

module OGR
  # NOTE: {{#type}} will return :wkbMultiPolygon (read: 2D instead of 2.5D)
  # until a Z value is set.
  class MultiPolygon25D < MultiPolygon
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiPolygon25D
  end
end
