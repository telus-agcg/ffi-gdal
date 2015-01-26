require 'json'

module OGR
  module GeometryFieldDefinitionExtensions
    # @return [Hash]
    def as_json
      {
        is_ignored: ignored?,
        name: name,
        spatial_reference: spatial_reference ? spatial_reference.as_json : nil,
        type: type,
      }
    end

    def to_json(_ = nil)
      as_json.to_json
    end
  end
end
