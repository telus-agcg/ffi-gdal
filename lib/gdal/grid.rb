require 'forwardable'
require 'narray'
require_relative '../gdal'
require_relative 'grid_algorithms'

module GDAL
  # Wrapper for GDAL's [Grid API](http://www.gdal.org/grid_tutorial.html).
  class Grid
    extend Forwardable
    include GDAL::Logger

    # @return [FFI::GDAL::GDAL::DataType]
    attr_accessor :data_type

    def_delegator :@algorithm, :options, :algorithm_options
    def_delegator :@algorithm, :c_identifier, :algorithm_type

    # @param algorithm_type [Symbol]
    # @param data_type [FFI::GDAL::GDAL::DataType]
    def initialize(algorithm_type, data_type: :GDT_Float32)
      @algorithm = init_algorithm(algorithm_type)
      @data_type = data_type
    end

    # @param points [NArray] An NArray containing all x, y, and z points.
    # @param extents [Hash{x_min: Fixnum, y_min: Fixnum, x_max: Fixnum, y_max: Fixnum}]
    # @param data_pointer [FFI::Pointer] Pointer that will contain the gridded
    #   data (after this method is done).
    # @param output_size [Hash{x: Fixnum, y: Fixnum}] Overall dimensions of the
    #   area of the output raster to grid.
    # @param progress_block [Proc]
    # @param progress_arg [FFI::Pointer]
    # @return [FFI::MemoryPointer] Pointer to the grid data.
    def create(points, extents, data_pointer, output_size = { x: 256, y: 256 },
      progress_block = nil, progress_arg = nil)
      log "Number of points: #{points.shape[1]}"

      x_input_coordinates_ptr = make_points_pointer(x_points(points))
      y_input_coordinates_ptr = make_points_pointer(y_points(points))
      z_input_coordinates_ptr = make_points_pointer(z_points(points))

      log "x_min, y_min: #{extents[:x_min]}, #{extents[:y_min]}"
      log "x_max, y_max: #{extents[:x_max]}, #{extents[:y_max]}"
      log "output_x_size, output_y_size: #{output_size[:x]}, #{output_size[:y]}"

      FFI::GDAL::Alg.GDALGridCreate(
        @algorithm.c_identifier,                        # eAlgorithm
        @algorithm.options.to_ptr,                      # poOptions
        points.shape[1],                                # nPoints
        x_input_coordinates_ptr,                        # padfX
        y_input_coordinates_ptr,                        # padfY
        z_input_coordinates_ptr,                        # padfZ
        extents[:x_min],                                # dfXMin
        extents[:x_max],                                # dfXMax
        extents[:y_min],                                # dfYMin
        extents[:y_max],                                # dfYMax
        output_size[:x],                                # nXSize
        output_size[:y],                                # nYSize
        @data_type,                                     # eType
        data_pointer,                                   # pData,
        progress_block,                                 # pfnProgress
        progress_arg                                    # pProgressArg
      )
    end

    # @param points [NArray]
    # @return [Array]
    def x_points(points)
      points[0, true].to_a
    end

    # @param points [NArray]
    # @return [Array]
    def y_points(points)
      points[1, true].to_a
    end

    # @param points [NArray]
    # @return [Array]
    def z_points(points)
      points[2, true].to_a
    end

    private

    # @param points [Array]
    def make_points_pointer(points)
      input_coordinates_ptr = FFI::MemoryPointer.new(:double, points.length)
      input_coordinates_ptr.write_array_of_double(points)

      input_coordinates_ptr
    end

    # @param algorithm_type [Symbol]
    # @return [GDAL::GridAlgorithms]
    def init_algorithm(algorithm_type)
      case algorithm_type
      when :inverse_distance_to_a_power then GDAL::GridAlgorithms::InverseDistanceToAPower.new
      when :moving_average              then GDAL::GridAlgorithms::MovingAverage.new
      when :nearest_neighbor            then GDAL::GridAlgorithms::NearestNeighbor.new
      when :metric_average_distance     then GDAL::GridAlgorithms::MetricAverageDistance.new
      when :metric_average_distance_pts then GDAL::GridAlgorithms::MetricAverageDistancePts.new
      when :metric_count                then GDAL::GridAlgorithms::MetricCount.new
      when :metric_maximum              then GDAL::GridAlgorithms::MetricMaximum.new
      when :metric_minimum              then GDAL::GridAlgorithms::MetricMinimum.new
      when :metric_range                then GDAL::GridAlgorithms::MetricRange.new
      else fail GDAL::UnknownGridAlgorithm, algorithm_type
      end
    end
  end
end
