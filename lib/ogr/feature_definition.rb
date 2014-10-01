require_relative '../ffi/ogr'

module OGR
  class FeatureDefinition
    include FFI::GDAL

    def initialize(ogr_feature_defn_pointer: nil)
      @ogr_feature_defn_pointer = if ogr_feature_defn_pointer
        ogr_feature_defn_pointer
      end
    end

    def c_pointer
      @ogr_feature_defn_pointer
    end
  end
end
