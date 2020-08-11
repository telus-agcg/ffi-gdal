# frozen_string_literal: true

require_relative 'line_string'

module OGR
  class LinearRing < LineString
    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      super()
      geometry_ptr ||= OGR::Geometry.create(:wkbLinearRing)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end

    def to_line_string
      line_string = OGR::LineString.new
      line_string.spatial_reference = spatial_reference if spatial_reference
      line_string.import_from_wkt(to_wkt.sub('LINEARRING', 'LINESTRING'))

      line_string
    end
  end
end
