# frozen_string_literal: true

module OGR
  module Geometry
    # Methods used everywhere but can't be used on GeometryCollections.
    #
    module NotAGeometryCollection
      # Returns TRUE if the geometry has no anomalous geometric points, such as
      # self intersection or self tangency. The description of each instantiable
      # geometric class will include the specific conditions that cause an
      # instance of that class to be classified as not simple.
      #
      # @return [Boolean]
      def simple?
        FFI::OGR::API.OGR_G_IsSimple(@c_pointer)
      end

      # @return [OGR::Geometry]
      # @raise [OGR::Failure]
      def boundary
        result = OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_Boundary(@c_pointer) }

        raise OGR::Failure, 'Failure computing boundary' unless result

        result
      end
    end
  end
end
