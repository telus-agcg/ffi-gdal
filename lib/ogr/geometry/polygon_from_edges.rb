# frozen_string_literal: true

module OGR
  module Geometry
    module PolygonFromEdges
      # Build a ring from a bunch of arcs.  The collection must be
      # a MultiLineString or GeometryCollection.
      #
      # @param tolerance [Float]
      # @param auto_close [Boolean]
      # @return [OGR::Geometry]
      # @raise [OGR::Failure]
      def polygon_from_edges(tolerance, auto_close: false)
        ogrerr_ptr = FFI::Buffer.new_out(:pointer)

        new_geometry_ptr = FFI::OGR::API.OGRBuildPolygonFromEdges(@c_pointer,
                                                                  false,
                                                                  auto_close,
                                                                  tolerance,
                                                                  ogrerr_ptr)

        OGR::ErrorHandling.handle_ogr_err('Unable to create polygon from edges') do
          FFI::OGR::Core::Err[ogrerr_ptr.read_int]
        end

        OGR::Geometry.new_owned(new_geometry_ptr)
      end
    end
  end
end
