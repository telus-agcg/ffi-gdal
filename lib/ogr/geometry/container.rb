# frozen_string_literal: true

module OGR
  class Geometry
    module Container
      # @return [Integer]
      def geometry_count
        FFI::OGR::API.OGR_G_GetGeometryCount(@c_pointer)
      end
      alias count geometry_count

      # Adds sub_geometry to self by cloning sub_geometry. Use this if you need
      # to keep using sub_geometry for other things. If sub_geometry won't be
      # used after this call, consider using #add_geometry_directly, as it's
      # less expensive.
      #
      # If this geometry is a container, this adds +geometry+ to the container.
      # If this is a Polygon, +geometry+ must be a LinearRing.  If the Polygon is
      # empty, the first added +geometry+ will be the exterior ring.  Subsequent
      # geometries added will be interior rings.
      #
      # @param sub_geometry [OGR::Geometry, FFI::Pointer]
      # @raise [FFI::GDAL::InvalidPointer]
      # @raise [OGR::Failure]
      def add_geometry(sub_geometry)
        sub_geometry_ptr = GDAL._pointer(sub_geometry)

        OGR::ErrorHandling.handle_ogr_err("Unable to add geometry: #{sub_geometry}") do
          FFI::OGR::API.OGR_G_AddGeometry(@c_pointer, sub_geometry_ptr)
        end
      end

      # Takes ownership of sub_geometry and added it to self; thus sub_geometry
      # is set to `autorelease: false` and it's up to you to release sub_geometry
      # when self is released.
      #
      # @param sub_geometry [OGR::Geometry, FFI::Pointer]
      # @raise [FFI::GDAL::InvalidPointer]
      # @raise [OGR::Failure]
      def add_geometry_directly(sub_geometry)
        sub_geometry_ptr = GDAL._pointer(sub_geometry, autorelease: false)

        OGR::ErrorHandling.handle_ogr_err("Unable to add geometry directly: #{sub_geometry}") do
          FFI::OGR::API.OGR_G_AddGeometryDirectly(@c_pointer, sub_geometry_ptr)
        end
      end

      # @param geometry_index [Integer]
      # @param delete [Boolean]
      # @raise [OGR::Failure]
      def remove_geometry(geometry_index, delete: true)
        msg = "Unable to add remove geometry at index #{geometry_index} (delete? #{delete})"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::API.OGR_G_RemoveGeometry(@c_pointer, geometry_index, delete)
        end
      end

      # If this geometry is a container, this fetches the geometry at the
      # sub_geometry_index.
      #
      # @param sub_geometry_index [Integer]
      # @return [OGR::Geometry]
      def geometry_at(sub_geometry_index)
        tmp_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(@c_pointer, sub_geometry_index)

        return if tmp_ptr.null?

        tmp_ptr.autorelease = false

        # TODO: This clone doesn't seem necessary...
        OGR::Geometry.factory(FFI::OGR::API.OGR_G_Clone(tmp_ptr))
      end
      alias geometry_ref geometry_at
    end
  end
end