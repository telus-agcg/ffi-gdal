require 'json'

module OGR
  module FeatureExtensions
    # @return [Array<OGR::Field>]
    def fields
      0.upto(field_count - 1).map do |i|
        { field_definition: field_definition(i), value_as_string: field_as_string(i) }
      end
    end

    # @return [Array<OGR::GeometryFieldDefinition>]
    def geometry_field_definitions
      0.upto(geometry_field_count - 1).map do |i|
        geometry_field_definition(i)
      end
    end

    def geometry_fields
      0.upto(geometry_field_count - 1).map do |i|
        geometry_field_definition(i)
      end
    end

    # @return [Hash]
    def as_json
      fields_with_nested_json = fields.map do |f|
        {
          field_definition: f[:field_definition].as_json,
          value_as_string: f[:value_as_string]
        }
      end

      {
        definition: definition.as_json,
        fid: fid,
        field_count: field_count,
        fields: fields_with_nested_json,
        geometry: geometry ? geometry.as_json : nil,
        geometry_field_count: geometry_field_count,
        geometry_field_definitions: geometry_field_definitions.map(&:as_json),
        style_string: style_string,
        style_table: style_table ? style_table.as_json : nil
      }
    end

    # @return [String]
    def to_json(_ = nil)
      as_json.to_json
    end
  end
end
