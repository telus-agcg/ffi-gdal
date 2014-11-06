module OGR
  module DataSourceExtensions

    # @return [Array<OGR::Layer>]
    def layers
      l = 0.upto(layer_count - 1).map do |i|
        layer(i)
      end

      @layers = l
    end

    # @return [Hash]
    def as_json
      {
        data_source: {
          driver: driver.name,
          layer_count: layer_count,
          layers: layers.map(&:as_json),
          name: name,
          style_table: style_table ? style_table.as_json : nil
        },
        metadata: all_metadata
      }
    end

    # @return [String]
    def to_json
      as_json.to_json
    end
  end
end
