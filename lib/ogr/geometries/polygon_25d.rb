require_relative 'polygon'

module OGR
  class Polygon25D < Polygon
    # @param geometry_ptr [FFI::Pointer]
    # @param spatial_reference [OGR::SpatialReference]
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPolygon25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
