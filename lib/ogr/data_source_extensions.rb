# frozen_string_literal: true

module OGR
  module DataSourceExtensions
    # @return [Array<OGR::Layer>]
    def layers
      @layers = Array.new(layer_count) { |i| layer(i) }
    end
  end
end
