require 'json'

module OGR
  module FeatureDefinitionExtensions

    # @return [Array<OGR::Field>]
    def fields
      0.upto(field_count - 1).map do |i|
        field(i)
      end
    end

    # @param name [String]
    # @return [OGR::Field]
    def field_by_name(name)
      field(field_index(name))
    end

    # @return [Hash]
    def as_json
      {
        field_count: field_count,
        fields: fields.map(&:as_json),
        geometry_field_count: geometry_field_count,
        geometry_type: geometry_type,
        name: name,
        is_style_ignored: style_ignored?
      }
    end

    # @return [String]
    def to_json
      as_json.to_json
    end
  end
end
