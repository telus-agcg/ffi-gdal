# frozen_string_literal: true

require_relative 'geometry_collection'

module OGR
  # NOTE: {{#type}} will return :wkbGeometryCollection (read: 2D instead of
  # 2.5D) until a Z value is set.
  class GeometryCollection25D < GeometryCollection
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbGeometryCollection25D
  end
end
