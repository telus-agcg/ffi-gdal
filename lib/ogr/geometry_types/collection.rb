module OGR
  module GeometryTypes
    module Collection
      def collection?
        true
      end
      
      # If this geometry is a container, this fetches the geometry at the
      #   sub_geometry_index.
      #
      # @param sub_geometry_index [Fixnum]
      # @return [OGR::Geometry]
      def geometry_at(sub_geometry_index)
        build_geometry do |ptr|
          FFI::GDAL.OGR_G_GetGeometryRef(ptr, sub_geometry_index)
        end
      end

      # Build a ring from a bunch of arcs.
      #
      # @param tolerance [Float]
      # @param auto_close [Boolean]
      # @return [OGR::Geometry]
      def polygon_from_edges(tolerance, auto_close)
        best_effort = false
        ogrerr_ptr = FFI::MemoryPointer.new(:pointer)

        new_geometry_ptr = FFI::GDAL.OGRBuildPolygonFromEdges(@geometry_pointer,
          best_effort,
          auto_close,
          tolerance,
          ogrerr_ptr)

        ogrerr_int = ogrerr_ptr.read_int
        ogrerr = FFI::GDAL::OGRErr[ogrerr_int]

        if ogrerr == :OGRERR_FAILURE
          raise "Couldn't create polygon"
        end

        self.class._to_geometry_type(new_geometry_ptr)
      end
    end
  end
end
