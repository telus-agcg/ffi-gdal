require 'json'

module OGR
  module LayerExtensions

    # @return [Array<OGR::Feature>]
    def features
      feature_list = 0.upto(feature_count).map do |i|
        feature(i)
      end

      @features = feature_list
    end

    # @return [OGR::Geometry] A convex hull geometry derived from a LineString
    #   that connects the 4 bounding box points (from the extent).
    def geometry_from_extent
      sr = spatial_reference
      geometry = OGR::Geometry.create(:wkbLineString)
      geometry.spatial_reference = sr

      geometry.add_point(extent.x_min, extent.y_min)
      geometry.add_point(extent.x_min, extent.y_max)
      geometry.add_point(extent.x_max, extent.y_max)
      geometry.add_point(extent.x_max, extent.y_min)
      geometry.add_point(extent.x_min, extent.y_min)
      geometry.flatten_to_2d!

      geometry.convex_hull
    end

    # @return [Hash]
    def as_json
      {
        layer: {
          extent: extent.as_json,
          feature_count: feature_count,
          feature_definition: feature_definition.as_json,
          #features: features.map(&:as_json),
          fid_column: fid_column,
          geometry_column: geometry_column,
          geometry_type: geometry_type,
          name: name,
          spatial_reference: spatial_reference.as_json,
          style_table: style_table ? style_table.as_json : nil
        },
        metadata: nil #all_metadata
      }
    end

    # @return [String]
    def to_json
      as_json.to_json
    end
  end
end
