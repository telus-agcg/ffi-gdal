require 'json'

module GDAL
  module RasterAttributeTableMixins
    module Extensions
      # Get +column_name+, +column_usage+, +column_type+ as a Hash.
      #
      # @param index [Fixnum]
      # @return [Hash]
      def column(index)
        {
          name: column_name(index),
          usage: column_usage(index),
          type: column_type(index)
        }
      end

      # @return [Array<Hash>]
      def columns
        column_count.times.map do |i|
          column(i)
        end
      end

      # @return [Hash]
      def as_json(options = nil)
        {
          column_count: column_count,
          columns: columns,
          linear_binning: linear_binning,
          row_count: row_count
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end
    end
  end
end