require_relative '../ffi/ogr'

module OGR
  class Feature
    include FFI::GDAL

    def initialize(ogr_feature_pointer: nil)
      @ogr_feature_pointer = if ogr_feature_pointer
        ogr_feature_pointer
      end

      close_me = -> { FFI::GDAL.OGR_F_Destroy(@ogr_feature_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_feature_pointer
    end
  end
end
