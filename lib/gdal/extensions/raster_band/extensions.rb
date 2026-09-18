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
        readlines.to_a
      end

      # Iterates through all lines and builds a Numo::NArray of pixels.
      #
      # @return [Numo::NArray]
      def to_na(to_data_type = nil)
        data_array = to_a
        target_type = to_data_type || data_type
        numo_type = GDAL._gdal_data_type_to_numo_narray_type_constant(target_type)

        # Create a typed array from the nested array structure
        # to_a returns [y_size][x_size] which matches Numo's row-major order [y_size, x_size]
        numo_type.cast(data_array)
      end

      # Iterates through all lines and builds a Numo::NArray of pixels.
      #
      # @return [Numo::NArray]
      def to_nna
        to_na
      end

      # Each pixel of the raster projected using the dataset's geo_transform.
      # The output is indexed [coord, x, y] (coord 0 = x_geo, 1 = y_geo); its
      # nested (#to_a) representation is [coord][pixel][line]. Coordinates are
      # stored in an array typed after the band's pixel data type, so integer
      # bands truncate fractional projected coordinates.
      #
      # @return [Numo::NArray]
      def projected_points
        numo_type = GDAL._gdal_data_type_to_numo_narray_type_constant(data_type)
        narray = numo_type.zeros(2, x_size, y_size)
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
