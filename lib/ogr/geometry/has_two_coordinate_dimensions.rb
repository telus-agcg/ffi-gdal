# frozen_string_literal: true

require_relative '../error_handling'
require_relative '../envelope'

module OGR
  class Geometry
    module HasTwoCoordinateDimensions
      # @return [OGR::Point, nil]
      def centroid
        point = OGR::Point.new

        OGR::ErrorHandling.handle_ogr_err('Unable to get centroid') do
          FFI::OGR::API.OGR_G_Centroid(@c_pointer, point.c_pointer)
        end

        point
      end

      # @return [OGR::Envelope, nil]
      def envelope
        envelope = FFI::OGR::Envelope.new
        FFI::OGR::API.OGR_G_GetEnvelope(@c_pointer, envelope)

        return if envelope.null?

        OGR::Envelope.new(envelope)
      end
    end
  end
end
