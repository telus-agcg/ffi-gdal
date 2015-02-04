require 'json'

module OGR
  module FieldExtensions
    # @return [Hash]
    def as_json(options = nil)
      {
        is_ignored: ignored?,
        justification: justification,
        name: name,
        precision: precision,
        type: type,
        width: width
      }
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
