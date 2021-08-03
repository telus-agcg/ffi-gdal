# frozen_string_literal: true

require_relative '../error_handling'
require_relative '../envelope_3d'

module OGR
  class Geometry
    module HasThreeCoordinateDimensions
      # @return [Integer]
      def centroid
        point = OGR::Point25D.new

        OGR::ErrorHandling.handle_ogr_err('Unable to get centroid') do
          FFI::OGR::API.OGR_G_Centroid(@c_pointer, point.c_pointer)
        end

        point
      end

      # Converts this geometry to a 2D geometry.
      def flatten_to_2d!
        FFI::OGR::API.OGR_G_FlattenTo2D(@c_pointer)
      end

      # @return [OGR::Envelope3D, nil]
      def envelope
        envelope = FFI::OGR::Envelope3D.new
        FFI::OGR::API.OGR_G_GetEnvelope3D(@c_pointer, envelope)

        OGR::Envelope3D.new(envelope)
      end
    end
  end
end
