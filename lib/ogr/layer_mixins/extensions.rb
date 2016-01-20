require 'json'

module OGR
  module LayerMixins
    # Methods not part of the C Layer API.
    module Extensions
      # Enumerates through all associated features. Beware: it calls
      # {#reset_reading} both before and after it's called. If you're using
      # {OGR::Layer#next_feature} for iterating through features somewhere in
      # your code, this will reset that reading.
      #
      # @return [Enumerator]
      # @yieldparam [OGR::Feature]
      def each_feature
        return enum_for(:each_feature) unless block_given?

        reset_reading

        loop do
          break unless feature = next_feature
          yield feature
        end

        reset_reading
      end

      # @return [Array<OGR::Feature>]
      def features
        each_feature.to_a
      end

      # @return [OGR::Polygon] A polygon derived from a LinearRing that connects
      #   the 4 bounding box points (from the extent).
      def geometry_from_extent
        ring = OGR::LinearRing.new

        ring.point_count = 5
        ring.set_point(0, extent.x_min, extent.y_min)
        ring.set_point(1, extent.x_min, extent.y_max)
        ring.set_point(2, extent.x_max, extent.y_max)
        ring.set_point(3, extent.x_max, extent.y_min)
        ring.set_point(4, extent.x_min, extent.y_min)

        polygon = OGR::Polygon.new spatial_reference: spatial_reference.dup
        polygon.add_geometry(ring)

        polygon
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
      #   points = layer.point_values('Moisture' => :double, 'Color' => :string)
      #   # => [[100, 100, 74.2, 'Red'],
      #         [100, 120, 19.0, 'Blue'],
      #         [110, 110, 21.1, 'Red'],
      #         [110, 100, 54.99, 'Green'],
      #         [100, 100, 3.3, 'Red']]
      #
      # @param with_attributes [String, Array<String>]
      # @return [Array<Array>]
      # @raise [OGR::UnsupportedGeometryType] if a geometry of some type is
      #   encountered that the method doesn't know how to extract point values
      #   from.
      def point_values(with_attributes = {})
        return [[]] if feature_count.zero?

        field_indices = with_attributes.keys.map { |field_name| find_field_index(field_name) }
        values = Array.new(feature_count) { Array.new(2 + with_attributes.size) }

        start = Time.now
        i = 0

        each_feature do |feature|
          next unless yield(feature.geometry) if block_given?

          field_values = field_indices.map.with_index do |j, attribute_index|
            feature.send("field_as_#{with_attributes.values[attribute_index]}", j)
          end

          feature.geometry.flatten_to_2d! if feature.geometry.is_3d?

          case feature.geometry
          when OGR::Point
            values[i] = extract_point_values(feature.geometry.point_value, field_values)
            i += 1
          when OGR::LineString, OGR::LinearRing
            feature.geometry.point_values.each.with_index(i) do |point_values, geom_num_plus_i|
              values[geom_num_plus_i] = extract_point_values(point_values, field_values)
              i += 1
            end
          when OGR::Polygon
            feature.geometry.each do |ring|
              ring.point_values.each.with_index(i) do |point_values, geom_num_plus_i|
                values[geom_num_plus_i] = extract_point_values(point_values, field_values)
                i += 1
              end
            end
          when OGR::MultiPoint, OGR::MultiLineString, OGR::MultiLineString
            feature.geometry.each do |ls|
              ls.point_values.each.with_index(i) do |point_values, geom_num_plus_i|
                values[geom_num_plus_i] = extract_point_values(point_values, field_values)
                i += 1
              end
            end
          when OGR::MultiPolygon
            feature.geometry.each do |polygon|
              polygon.each do |ring|
                ring.point_values.each.with_index(i) do |point_values, geom_num_plus_i|
                  values[geom_num_plus_i] = extract_point_values(point_values, field_values)
                  i += 1
                end
              end
            end
          else fail OGR::UnsupportedGeometryType,
            "Not sure how to extract point_values for a #{feature.geometry.class}"
          end
        end

        log "#point_values took #{Time.now - start}s"
        values
      end

      # Iterates through features to see if any of them are 3d.
      #
      # @return [Boolean]
      def any_geometries_with_z?
        found_z_geom = false
        feature = next_feature

        until found_z_geom || feature.nil?
          found_z_geom = feature.geometry.is_3d?
          feature = next_feature
        end

        found_z_geom
      end

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

      private

      # While it's a really simple method, I wanted to ensure that all Array
      # building for related things was done in the most efficient way.
      #
      # @param point_value [Array<Float>] The (x, y) values of a point.
      # @param field_values [Array<Number>] The valus from an associated Field
      #   to merge to the +point_value+ array.
      def extract_point_values(point_value, field_values)
        point_value.push(*field_values)
      end
    end
  end
end
