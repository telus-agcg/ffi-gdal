module OGR
  module DataSourceExtensions
    # @return [Array<OGR::Layer>]
    def layers
      l = layer_count.times.map do |i|
        layer(i)
      end

      @layers = l
    end

    # @return [Hash]
    def as_json(options = nil)
      {
        data_source: {
          driver: driver.name,
          layer_count: layer_count,
          layers: layers.map(&:as_json),
          name: name,
          style_table: style_table ? style_table.as_json(options) : nil
        },
        metadata: all_metadata
      }
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
