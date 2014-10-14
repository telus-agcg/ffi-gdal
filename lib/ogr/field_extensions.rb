module OGR
  module FieldExtensions

    # @return [Hash]
    def as_json
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
    def to_json
      as_json.to_json
    end
  end
end
