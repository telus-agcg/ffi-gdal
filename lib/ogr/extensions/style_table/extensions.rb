# frozen_string_literal: true

require 'ogr/style_table'

module OGR
  class StyleTable
    module Extensions
      # Gets all of the styles as Hash.  Note that this calls
      # #reset_style_string_reading.
      #
      # @return [Hash{name => style}]
      def styles
        styles = {}
        reset_style_string_reading

        loop do
          style = next_style
          break unless style

          styles[last_style_name] = style
        end

        reset_style_string_reading

        styles
      end
    end
  end
end

OGR::StyleTable.include(OGR::StyleTable::Extensions)
