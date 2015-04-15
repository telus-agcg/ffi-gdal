require 'json'

module OGR
  module GeometryFieldDefinitionExtensions
    # @return [Hash]
    def as_json(options = nil)
      {
        is_ignored: ignored?,
        name: name,
        spatial_reference: spatial_reference ? spatial_reference.as_json(options) : nil,
        type: type
      }
    end

    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
