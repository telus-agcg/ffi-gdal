# frozen_string_literal: true

require "gdal/raster_band"
require "numo/narray"
require_relative "io_extensions"

module GDAL
  class RasterBand
    module Extensions
      # @return [Enumerator]
      def each_overview
        return enum_for(:each_overview) unless block_given?

        overview_count.times do |i|
          yield overview(i)
        end
      end

      # @return [Array]
      def overviews
        each_overview.to_a
      end

      # @return [Array]
      def to_a
        read_lines_by_block.to_a
      end

      # Iterates through all lines and builds an NArray of pixels.
      #
      # @return [NArray]
      def to_na(to_data_type = nil)
        narray = NArray.to_na(to_a)

        return narray unless to_data_type

        narray_type = GDAL._gdal_data_type_to_narray_type_constant(to_data_type)

        narray.to_type(narray_type)
      end

      # Iterates through all lines and builds an NArray of pixels.
      #
      # @return [Numo::NArray]
      def to_nna
        Numo::NArray[*to_a]
      end

      # Each pixel of the raster projected using the dataset's geo_transform.
      # The output NArray is a 3D array where the inner-most array is a the
      # lat an lon, those are contained in an array per pixel line, and finally
      # the outer array contains each of the pixel lines.
      #
      # @return [NArray]
      def projected_points
        narray = GDAL._narray_from_data_type(data_type, 2, x_size, y_size)
        geo_transform = dataset.geo_transform

        y_size.times do |y_point|
          x_size.times do |x_point|
            coords = geo_transform.apply_geo_transform(x_point, y_point)
            narray[0, x_point, y_point] = coords[:x_geo] || 0
            narray[1, x_point, y_point] = coords[:y_geo] || 0
          end
        end

        narray
      end

      # The total number of pixels in the raster band.
      #
      # @return [Integer]
      def pixel_count
        x_size * y_size
      end
    end
  end
end

GDAL::RasterBand.include(GDAL::RasterBand::Extensions)
