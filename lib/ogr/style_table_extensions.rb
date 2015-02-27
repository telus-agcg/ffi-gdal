require 'json'

module OGR
  module StyleTableExtensions
    # Gets all of the styles as Hash.  Note that this calls
    # #reset_style_string_reading.
    #
    # @return [Hash{name => style}]
    def styles
      styles = {}
      reset_style_string_reading

      while style = next_style
        styles[last_style_name] = style
      end

      reset_style_string_reading

      styles
    end

    # @return [Hash]
    def as_json(options = nil)
      styles
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
