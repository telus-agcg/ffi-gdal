# frozen_string_literal: true

require_relative 'line_string'
require_relative 'geometry/interfaces/area'

module OGR
  class LinearRing < LineString
    include OGR::Geometry::Interfaces::Area
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbLinearRing

    def to_line_string
      line_string = OGR::LineString.new
      line_string.spatial_reference = spatial_reference if spatial_reference
      line_string.import_from_wkt(to_wkt.sub('LINEARRING', 'LINESTRING'))

      line_string
    end
  end
end
