require_relative '../ffi/ogr'

module OGR
  class SpatialReference
    include FFI::GDAL

    def initialize(ogr_spatial_ref_pointer: nil)
      @ogr_spatial_ref_pointer = if ogr_spatial_ref_pointer
        ogr_spatial_ref_pointer
      end
    end

    def c_pointer
      @ogr_spatial_ref_pointer
    end
  end
end
