require 'forwardable'
require 'narray'
require_relative '../ffi/gdal/alg'
require_relative 'grid_types'
require_relative 'geo_transform'

module GDAL
  # Wrapper for GDAL's [Grid API](http://www.gdal.org/grid_tutorial.html).
  class Grid
    extend Forwardable
    include GDAL::Logger

    # @return [NArray]
    attr_accessor :points

    # @return [GDAL::GeoTransform]
    attr_reader :geo_transform

    # @return [FFI::GDAL::DataType]
    attr_accessor :data_type

    def_delegator :@gridder, :options, :options

    # @param algorithm [Symbol]
    # @param data_type [FFI::GDAL::DataType]
    def initialize(algorithm, data_type: :GDT_Byte)
      @data_type = data_type
      @gridder = init_gridder(algorithm)
      @points = nil
      @geo_transform = GDAL::GeoTransform.new
    end

    # @return [FFI::MemoryPointer] Pointer to the grid data.
    def create(&progress_block)
      update_geo_transform

      log "Number of points: #{point_count}"
      x_coordinates_ptr = FFI::MemoryPointer.new(:double, point_count)
      y_coordinates_ptr = FFI::MemoryPointer.new(:double, point_count)
      x_coordinates_ptr.write_array_of_float(@points[0, true].to_a)
      y_coordinates_ptr.write_array_of_float(@points[1, true].to_a)

      if @points.shape.first == 3
        z_coordinates_ptr = FFI::MemoryPointer.new(:double, point_count)
        z_coordinates_ptr.write_array_of_float(@points[2, true].to_a)
      else
        z_coordinates_ptr = nil
      end

      log "x_min, y_min: #{x_min}, #{y_min}"
      log "x_max, y_max: #{x_max}, #{y_max}"
      log "x_size, y_size: #{x_size}, #{y_size}"
      log "pixel_width: #{@geo_transform.pixel_width}"
      log "pixel_height: #{@geo_transform.pixel_height}"
      data_ptr = FFI::MemoryPointer.new(:buffer_inout, x_size * y_size)

      # gdal_grid.cpp lists this as the corner coordinates, which ends up being
      # larger than my x_max/y_min test values. That seems odd.
      # x_end = x_max + (@geo_transform.x_size(x_max) / 2)
      # y_end = y_min - (@geo_transform.y_size(y_max) / 2)
      max_pixel = @geo_transform.world_to_pixel(x_max, y_max)
      x_end = x_max + (max_pixel[:pixel] / 2)
      y_end = y_min - (max_pixel[:line] / 2)
      log "corner x1 (gdal_grid.cpp): #{x_end}"
      log "corner y1 (gdal_grid.cpp): #{y_end}"

      FFI::GDAL::Alg.GDALGridCreate(
        @gridder.algorithm,                             # eAlgorithm
        @gridder.options.to_ptr,                        # poOptions
        point_count,                                    # nPoints
        x_coordinates_ptr,                              # padfX
        y_coordinates_ptr,                              # padfY
        z_coordinates_ptr,                              # padfZ
        x_min,                                          # dfXMin
        x_max,                                          # dfXMax
        y_min,                                          # dfYMin
        y_max,                                          # dfYMax
        x_size,                                         # nXSize
        y_size,                                         # nYSize
        @data_type,                                     # eType
        data_ptr,                                       # pData,
        progress_block,                                 # pfnProgress
        nil                                             # pProgressArg
      )

      data_ptr
    end

    # @return [Fixnum] The number of points (x,y,z) in the grid.
    def point_count
      @points.shape.last
    end

    def x_min
      @points.nil? ? nil : @points[0, true].to_a.compact.min
    end

    def x_max
      @points.nil? ? nil : @points[0, true].to_a.compact.max
    end

    def x_size
      @points.nil? ? nil : (x_max - x_min)
    end

    def y_min
      @points.nil? ? nil : @points[1, true].to_a.compact.min
    end

    def y_max
      @points.nil? ? nil : @points[1, true].to_a.compact.max
    end

    def y_size
      @points.nil? ? nil : (y_max - y_min)
    end

    private

    def init_gridder(algorithm)
      case algorithm
      when :inverse_distance_to_a_power then GDAL::GridTypes::InverseDistanceToAPower.new
      when :moving_average then GDAL::GridTypes::MovingAverage.new
      when :nearest_neighbor then GDAL::GridTypes::NearestNeighbor.new
      when :metric_average_distance then GDAL::GridTypes::MetricAverageDistance.new
      when :metric_average_distance_pts then GDAL::GridTypes::MetricAverageDistancePts.new
      when :metric_count then GDAL::GridTypes::MetricCount.new
      when :metric_maximum then GDAL::GridTypes::MetricMaximum.new
      when :metric_minimum then GDAL::GridTypes::MetricMinimum.new
      when :metric_range then GDAL::GridTypes::MetricRange.new
      else
        fail GDAL::UnknownGridAlgorithm.new(algorithm)
      end
    end

    def update_geo_transform
      return if @points.nil?

      @geo_transform.x_origin = x_min
      @geo_transform.y_origin = y_max
      @geo_transform.pixel_width = (x_max - x_min) / x_size
      @geo_transform.pixel_height = (y_max - y_min) / y_size
    end
  end
end
