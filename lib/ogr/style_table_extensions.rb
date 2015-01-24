require 'json'

module OGR
  module StyleTableExtensions
    # @return [String]
    def as_json
      'StyleTable interface not yet wrapped with ffi-ruby'
    end

    # @return [String]
    def to_json(_ = nil)
      as_json.to_json
    end
  end
end
