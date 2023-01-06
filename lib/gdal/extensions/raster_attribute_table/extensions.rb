# frozen_string_literal: true

require 'gdal/raster_attribute_table'

module GDAL
  class RasterAttributeTable
    module Extensions
      # @param row [Integer]
      # @param field [Integer]
      # @param value [String, Float, Integer]
      def set_value(row, field, value)
        case value.class
        when String then set_value_as_string(row, field, value)
        when Float then set_value_as_double(row, field, value)
        when Integer then set_value_as_integer(row, field, value)
        else raise GDAL::UnknownRasterAttributeTableType, "Unknown value type for value '#{value}'"
        end
      end

      # Get +column_name+, +column_usage+, +column_type+ as a Hash.
      #
      # @param index [Integer]
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
        each_column.to_a
      end

      # @return [Enumerator]
      # @yieldparam [Hash]
      def each_column
        return enum_for(:each_column) unless block_given?

        column_count.times { |i| yield column(i) }
      end
    end
  end
end

GDAL::RasterAttributeTable.include(GDAL::RasterAttributeTable::Extensions)
