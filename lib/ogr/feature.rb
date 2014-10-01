require_relative '../ffi/ogr'

module OGR
  class Feature
    include FFI::GDAL

    def initialize(ogr_feature_pointer: nil)
      @ogr_feature_pointer = if ogr_feature_pointer
        ogr_feature_pointer
      end
    end

    def c_pointer
      @ogr_feature_pointer
    end
  end
end
