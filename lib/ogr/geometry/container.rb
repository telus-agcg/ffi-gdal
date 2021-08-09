# frozen_string_literal: true

module OGR
  module Geometry
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
      # @param sub_geometry [OGR::Geometry::GeometryMethods]
      # @raise [FFI::GDAL::InvalidPointer]
      # @raise [GDAL::Error, OGR::UnsupportedGeometryType]
      def add_geometry(sub_geometry)
        OGR::ErrorHandling.handle_ogr_err("Unable to add geometry: #{sub_geometry}") do
          FFI::OGR::API.OGR_G_AddGeometry(@c_pointer, sub_geometry.c_pointer)
        end
      end

      # Takes ownership of sub_geometry and added it to self, thus releasing
      # should no longer be done in Ruby-land (the associated c_pointer gets
      # set here to autorelease: false).
      #
      # @param sub_geometry [OGR::Geometry::GeometryMethods]
      # @raise [FFI::GDAL::InvalidPointer]
      # @raise [OGR::Failure]
      def add_geometry_directly(sub_geometry)
        sub_geometry.c_pointer.autorelease = false

        OGR::ErrorHandling.handle_ogr_err("Unable to add geometry directly: #{sub_geometry}") do
          FFI::OGR::API.OGR_G_AddGeometryDirectly(@c_pointer, sub_geometry.c_pointer)
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
      # @return [OGR::Geometry, nil]
      def geometry_at(sub_geometry_index)
        geometry_ref = FFI::OGR::API.OGR_G_GetGeometryRef(@c_pointer, sub_geometry_index)

        return if geometry_ref.null?

        OGR::Geometry.new_borrowed(geometry_ref)
      end
      alias geometry_ref geometry_at
    end
  end
end
