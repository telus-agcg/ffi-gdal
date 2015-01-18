require 'narray'
require_relative 'grid_types'
require_relative 'geo_transform'

module GDAL
  class Grid
    include GDAL::Logger

    attr_reader :gridder
    attr_accessor :points

    # @return [GDAL::GeoTransform]
    attr_accessor :geo_transform

    # @param algorithm [Symbol]
    def initialize(algorithm, data_type: :GDT_Byte)
      @data_type = data_type
      @gridder = init_gridder(algorithm)
      @points = nil
      @geo_transform = GDAL::GeoTransform.new
    end

    def create(&progress_block)
      options_ptr = GDAL::Options.pointer(@gridder.options)

      log "number of points: #{point_count}"
      x_coordinates_ptr = FFI::MemoryPointer.new(:double, point_count)
      y_coordinates_ptr = FFI::MemoryPointer.new(:double, point_count)
      x_coordinates_ptr.write_array_of_float(@points[0, true].to_a)
      y_coordinates_ptr.write_array_of_float(@points[1, true].to_a)

      if @points.shape.first == 3
        z_coordinates_ptr = FFI::MemoryPointer.new(:double, point_count)
        z_coordinates_ptr.write_array_of_float(@points[2, true].to_a)
        log "z coordinates: #{z_coordinates_ptr.read_array_of_float(point_count)}"
      else
        z_coordinates_ptr = nil
      end

      log "x_min: #{x_min}"
      log "x_max: #{x_max}"
      log "y_min: #{y_min}"
      log "y_max: #{y_max}"
      log "x_size: #{x_size}"
      log "y_size: #{y_size}"
      data_ptr = FFI::MemoryPointer.new(:buffer_inout, x_size * y_size)

      cpl_err = FFI::GDAL::GDALGridCreate(
        @gridder.algorithm,                             # eAlgorithm
        options_ptr,                                    # poOptions
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

      cpl_err.to_bool

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
      @geo_transform.x_size(x_max, x_min)
    end

    def y_min
      @points.nil? ? nil : @points[1, true].to_a.compact.min
    end

    def y_max
      @points.nil? ? nil : @points[1, true].to_a.compact.max
    end

    def y_size
      @geo_transform.y_size(y_max, y_min)
    end

    private

    def init_gridder(algorithm)
      case algorithm
      when :inverse_distance_to_a_power
        GDAL::GridTypes::InverseDistanceToAPower.new
      when :moving_average
        GDAL::GridTypes::MovingAverage.new
      when :nearest_neighbor
        GDAL::GridTypes::NearestNeighbor.new
      else
        raise GDAL::UnknownGridAlgorithm.new(algorithm)
      end
    end

    # def metric_minimum
    #   create_grid(:GGA_MetricMinimum)
    # end
    #
    # def metric_maximum
    #   create_grid(:GGA_MetricMaximum)
    # end
    #
    # def metric_range
    #   create_grid(:GGA_MetricRange)
    # end
    #
    # def metric_count
    #   create_grid(:GGA_MetricCount)
    # end
    #
    # def metric_average_distance
    #   create_grid(:GGA_MetricAverageDistance)
    # end
    #
    # def metric_average_distance_pts
    #   create_grid(:GGA_MetricAverageDistancePts)
    # end
  end
end
