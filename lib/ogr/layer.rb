require_relative '../ffi/ogr'
require_relative 'geometry'
require_relative 'feature'

module OGR
  class Layer
    include FFI::GDAL

    def initialize(ogr_layer_pointer: nil)
      @ogr_layer_pointer = if ogr_layer_pointer
        ogr_layer_pointer
      end
    end

    def c_pointer
      @ogr_layer_pointer
    end

    def name
      OGR_L_GetName(@ogr_layer_pointer)
    end

    def geometry_type
      OGR_L_GetGeomType(@ogr_layer_pointer)
    end

    def spatial_filter
      filter_pointer = OGR_L_GetSpatialFilter(@ogr_layer_pointer)
      return nil if filter_pointer.null?

      OGR::Geometry.new(ogr_geometry_pointer: filter_pointer)
    end

    # @param force [Boolean] Force the calculation even if it's
    #   expensive.
    # @return [Fixnum]
    def feature_count(force=false)
      OGR_L_GetFeatureCount(@ogr_layer_pointer, force)
    end

    def feature(index)
      feature_pointer = OGR_L_GetFeature(@ogr_layer_pointer, index)
      return nil if feature_pointer.null?

      OGR::Feature.new(ogr_feature_pointer: feature_pointer)
    end

    def next_feature
      feature_pointer = OGR_L_GetNextFeature(@ogr_layer_pointer)
      return nil if feature_pointer.null?

      OGR::Feature.new(ogr_feature_pointer: feature_pointer)
    end
  end
end
