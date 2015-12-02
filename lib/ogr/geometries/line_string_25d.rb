require_relative 'line_string'

module OGR
  class LineString25D < LineString
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLineString25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z)
      super(x, y, z)
    end
  end
end
