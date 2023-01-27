# frozen_string_literal: true

module GDAL
  class Dataset
    module Accessors
      # @return [GDAL::Driver] The driver to be used for working with this
      #   dataset.
      def driver
        driver_ptr = FFI::GDAL::GDAL.GDALGetDatasetDriver(@c_pointer)

        Driver.new(driver_ptr)
      end

      def projection
        # Returns a pointer to an internal projection reference string. It should
        # not be altered, freed or expected to last for long.
        proj, ptr = FFI::GDAL::GDAL.GDALGetProjectionRef(@c_pointer)
        ptr.autorelease = false

        proj || ""
      end

      # @param new_projection [String] Should be in WKT or PROJ.4 format.
      # @raise [GDAL::Error]
      def projection=(new_projection)
        GDAL::CPLErrorHandler.manually_handle("Unable to set projection") do
          FFI::GDAL::GDAL.GDALSetProjection(@c_pointer, new_projection.to_s)
        end
      end

      # @return [GDAL::GeoTransform]
      # @raise [GDAL::Error]
      def geo_transform
        return @geo_transform if @geo_transform

        geo_transform_pointer = GDAL::GeoTransform.new_pointer

        GDAL::CPLErrorHandler.manually_handle("Unable to get geo_transform") do
          FFI::GDAL::GDAL.GDALGetGeoTransform(@c_pointer, geo_transform_pointer)
        end

        @geo_transform = GeoTransform.new(geo_transform_pointer)
      end

      # @param new_transform [GDAL::GeoTransform, FFI::Pointer]
      # @return [GDAL::GeoTransform]
      # @raise [GDAL::Error]
      def geo_transform=(new_transform)
        new_pointer = GDAL._pointer(GDAL::GeoTransform, new_transform)

        GDAL::CPLErrorHandler.manually_handle("Unable to set geo_transform") do
          FFI::GDAL::GDAL.GDALSetGeoTransform(@c_pointer, new_pointer)
        end

        @geo_transform = new_transform.is_a?(FFI::Pointer) ? GeoTransform.new(new_pointer) : new_transform
      end

      # @return [String    # @return [Integer]
      def gcp_count
        return 0 if null?

        FFI::GDAL::GDAL.GDALGetGCPCount(@c_pointer)
      end

      # @return [String]
      def gcp_projection
        return "" if null?

        proj, ptr = FFI::GDAL::GDAL.GDALGetGCPProjection(@c_pointer)
        ptr.autorelease = false

        proj
      end

      # @return [FFI::GDAL::GCP]
      def gcps
        return FFI::GDAL::GCP.new if null?

        gcp_array_pointer = FFI::GDAL::GDAL.GDALGetGCPs(@c_pointer)

        if gcp_array_pointer.null?
          FFI::GDAL::GCP.new
        else
          FFI::GDAL::GCP.new(gcp_array_pointer)
        end
      end

      # Creates a OGR::SpatialReference object from the dataset's projection.
      #
      # @return [OGR::SpatialReference]
      def spatial_reference
        return @spatial_reference if @spatial_reference

        proj = projection
        return nil if proj.empty?

        @spatial_reference = OGR::SpatialReference.new(proj)
      end
    end
  end
end
