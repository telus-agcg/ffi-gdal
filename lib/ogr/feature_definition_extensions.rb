require 'json'

module OGR
  module FeatureDefinitionExtensions
    # @return [Array<OGR::Field>]
    def field_definitions
      return [] if field_count.zero?

      0.upto(field_count - 1).map do |i|
        field_definition(i)
      end
    end

    # @param name [String]
    # @return [OGR::Field]
    def field_by_name(name)
      i = field_index(name)
      return unless i

      field(i)
    end

    # @param name [String]
    # @return [OGR::Field]
    def geometry_field_by_name(name)
      g = geometry_field_index(name)
      return unless g

      geometry_field_definition(g)
    end

    # @return [Hash]
    def as_json
      {
        field_count: field_count,
        field_definitions: field_definitions.map(&:as_json),
        geometry_field_count: geometry_field_count,
        geometry_type: geometry_type,
        is_geometry_ignored: geometry_ignored?,
        is_style_ignored: style_ignored?,
        name: name
      }
    end

    # @return [String]
    def to_json(_ = nil)
      as_json.to_json
    end
  end
end
