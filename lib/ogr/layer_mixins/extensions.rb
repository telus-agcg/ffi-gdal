require 'json'

module OGR
  module LayerMixins
    # Methods not part of the C Layer API.
    module Extensions
      # @return [Array<OGR::Feature>]
      def features
        return [] if feature_count.zero?

        feature_list = feature_count.times.map do |i|
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

        geometry.convex_hull
      end

      # Iterates through all geometries in the Layer and extracts the point
      # values to an Array. The result will be an Array of Arrays where the
      # inner Array is the point values. If +with_attributes+ is given, it will
      # extract the field values for each given field names.
      #
      # @example Not passing +with_attributes+
      #   points = layer.point_values
      #   # => [[100, 100], [100, 120], [110, 110], [110, 100], [100, 100]]
      #
      # @example With +with_attributes+
      #   points = layer.point_values('Moisture', 'Color')
      #   # => [[100, 100, 74.2, 'Red'],
      #         [100, 120, 19.0, 'Blue'],
      #         [110, 110, 21.1, 'Red'],
      #         [110, 100, 54.99, 'Green'],
      #         [100, 100, 3.3, 'Red']]
      #
      # @param with_attributes [String, Array<String>]
      # @return [Array<Array>]
      def point_values(*with_attributes)
        return [] if feature_count.zero?

        field_indeces = with_attributes.map { |field_name| find_field_index(field_name) }

        values = []
        features.each do |feature|
          field_values = field_indeces.map { |i| feature.field(i) }
          feature.geometry.flatten_to_2d! if feature.geometry.is_3d?

          case feature.geometry
          when OGR::Point, OGR::Point25D
            values += [feature.geometry.point_values + field_values]
          when OGR::LineString, OGR::LineString25D, OGR::LinearRing
            values += feature.geometry.point_values + field_values
          when OGR::Polygon, OGR::Polygon25D
            feature.geometry.each { |ring| values += ring.point_values + field_values }
          when OGR::MultiPoint, OGR::MultiPoint25D, OGR::MultiLineString, OGR::MultiLineString
            feature.geometry.each { |ls| values += ls.point_values + field_values }
          when OGR::MultiPolygon, OGR::MultiPolygon25D
            feature.geometry.each do |polygon|
              polygon.each { |ring| values += ring.point_values + field_values }
            end
          else fail RuntimeError, "Got geometry #{feature.geometry.class}"
          end
        end

        values
      # @return [Hash]
      def as_json(options = nil)
        {
          layer: {
            extent: extent.as_json(options),
            feature_count: feature_count,
            feature_definition: feature_definition.as_json(options),
            features: features.map(&:as_json),
            fid_column: fid_column,
            geometry_column: geometry_column,
            geometry_type: geometry_type,
            name: name,
            spatial_reference: spatial_reference ? spatial_reference.as_json(options) : nil,
            style_table: style_table ? style_table.as_json(options) : nil
          },
          metadata: nil # all_metadata
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end
    end
  end
end
