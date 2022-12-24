# frozen_string_literal: true

require 'ogr/data_source'

module OGR
  class DataSource
    module Extensions
      # @return [Array<OGR::Layer>]
      def layers
        @layers = Array.new(layer_count) { |i| layer(i) }
      end
    end
  end
end

OGR::DataSource.include(OGR::DataSource::Extensions)
