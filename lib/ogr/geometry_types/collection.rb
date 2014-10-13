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
    end
  end
end
