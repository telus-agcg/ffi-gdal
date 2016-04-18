require 'json'

module OGR
  module FeatureDefinitionExtensions
    # @return [Array<OGR::FieldDefinition>]
    def field_definitions
      return [] if field_count.zero?

      Array.new(field_count) { |i| field_definition(i) }
    end

    # @return [Array<OGR::GeometryFieldDefinition>]
    def geometry_field_definitions
      return [] if geometry_field_count.zero?

      Array.new(geometry_field_count) { |i| geometry_field_definition(i) }
    end

    # @param name [String]
    # @return [OGR::FieldDefinition]
    def field_definition_by_name(name)
      i = field_index(name)
      return unless i

      field_definition(i)
    end

    # @param name [String]
    # @return [OGR::GeometryFieldDefinition]
    def geometry_field_definition_by_name(name)
      g = geometry_field_index(name)
      return unless g

      geometry_field_definition(g)
    end

    # @return [Hash]
    def as_json(_options = nil)
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
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
