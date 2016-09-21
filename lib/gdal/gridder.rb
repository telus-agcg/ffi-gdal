require 'narray'
require_relative '../gdal'
require_relative 'gridder_options'
require_relative 'gridder/point_extracting'
require_relative 'options'
require_relative '../ogr'

module GDAL
  # Somewhat analogous to the gdal_grid utility.
  class Gridder
    include PointExtracting
    include GDAL::Logger

    DESIRED_BUFFER_SIZE = 16 * 1024 * 1024

    # Object used by for doing the actual grid work.
    #
    # @!attribute [r] grid
    # @return [GDAL::Grid]
    attr_reader :grid

    # @param source_layer [OGR::Layer] The layer from which to use points and
    #   spatial reference for interpolating. Alternatively, use +points+ to give
    #   specific point values for gridding.
    # @param dest_file_name [String] The path to output the gridded raster to.
    # @param gridder_options [GDAL::GridderOptions]
    # @param points [Array<Array<Float>>] A 2D array of (x, y, z) points to use
    #   for gridding. Used for when you don't want to use all points from
    #   +source_layer+.
    def initialize(source_layer, dest_file_name, gridder_options, points: nil)
      @source_layer = source_layer
      @dest_file_name = dest_file_name
      @options = gridder_options

      @points = points
      @x_min = nil
      @x_max = nil
      @y_min = nil
      @y_max = nil
    end

    # Does all of the things: gathers points from the associated Layer,
    # processes the points according to associated GridderOptions, grids the
    # points, and writes out the newly gridder raster.
    def grid!
      dataset = build_dataset(@options.output_driver,
        @dest_file_name,
        @options.output_data_type,
        @options.output_creation_options)

      grid_and_write(dataset.raster_band(1), dataset.geo_transform)

      if @options.algorithm_options[:no_data_value]
        dataset.raster_band(1).no_data_value = @options.algorithm_options[:no_data_value]
      end

      dataset.close
    end

    #--------------------------------------------------------------------------
    # PRIVATES
    #--------------------------------------------------------------------------

    private

    # Builds the Dataset to use for writing gridded raster data to.
    #
    # @param driver [GDAL::Driver]
    # @param dest_file_name [String]
    # @param data_type [FFI::GDAL::GDAL::DataType]
    # @param creation_options [Hash]
    # @return [GDAL::Dataset]
    def build_dataset(driver, dest_file_name, data_type, creation_options = {})
      dataset = driver.create_dataset(dest_file_name,
        output_width,
        output_height,
        data_type: data_type,
        **creation_options)

      dataset.projection = build_output_spatial_reference
      dataset.geo_transform = build_output_geo_transform

      dataset
    end

    # Tries to get WKT of a spatial reference to use for the output dataset.
    # First it tries to use {GDAL::GridderOptions#output_projection}, then tries
    # the associated source layers {OGR::Layer#spatial_reference}.
    #
    # @return [String, nil] WKT of the spatial reference to use; +nil+ if none
    #   is found to use.
    def build_output_spatial_reference
      spatial_ref = @options.output_projection || @source_layer.spatial_reference

      unless spatial_ref
        log 'No spatial reference specified'
        return
      end

      spatial_ref.to_wkt
    end

    # If @options.output_y_extent and/or @options.output_x_extent are set, it
    # uses those and @options.output_size to build a {GDAL::GeoTransform} to be
    # used with the output {GDAL::Dataset}.
    #
    # @return [GDAL::GeoTransform]
    def build_output_geo_transform
      envelope = OGR::Envelope.new

      envelope.x_min = x_min
      envelope.x_max = x_max
      envelope.y_min = y_min
      envelope.y_max = y_max

      GDAL::GeoTransform.new_from_envelope(envelope, output_width, output_height)
    end

    # The x_min value to be used for the gridder and output raster.
    #
    # @return [Float]
    def x_min
      @x_min ||= @options.output_x_extent.fetch(:min) { @source_layer.extent.x_min }
    end

    # The x_max value to be used for the gridder and output raster.
    #
    # @return [Float]
    def x_max
      @x_max ||= @options.output_x_extent.fetch(:max) { @source_layer.extent.x_max }
    end

    # The y_min value to be used for the gridder and output raster.
    #
    # @return [Float]
    def y_min
      @y_min ||= @options.output_y_extent.fetch(:min) { @source_layer.extent.y_min }
    end

    # The y_max value to be used for the gridder and output raster.
    #
    # @return [Float]
    def y_max
      @y_max ||= @options.output_y_extent.fetch(:max) { @source_layer.extent.y_max }
    end

    # @return [Fixnum]
    def output_width
      @options.output_size[:width]
    end

    # @return [Fixnum]
    def output_height
      @options.output_size[:height]
    end

    # Figures out the proper block sizes to use for iterating over layer pixels,
    # gridding them, and writing them to the raster file.
    #
    # @param raster_band_block_size [Fixnum]
    def each_block(raster_band_block_size)
      data_type_size = @options.output_data_type_size
      block_size = build_block_sizes(raster_band_block_size, data_type_size)
      log "Work buffer: #{block_size[:x]} * #{block_size[:y]}"

      block_number = 0
      block_count = build_block_count(block_size[:x], block_size[:y], output_width, output_height)
      log "Block count: #{block_count}"

      0.step(output_height - 1, block_size[:y]).each do |y_offset|
        0.step(output_width - 1, block_size[:x]).each do |x_offset|
          yield block_number, block_count, block_size, x_offset, y_offset
          block_number += 1
        end
      end
    end

    # Iterates through each block of data, grids it, then writes it to the
    # output raster.
    #
    # @param raster_band [GDAL::RasterBand]
    # @param geo_transform [GDAL::GeoTransform]
    def grid_and_write(raster_band, geo_transform)
      data_ptr = GDAL._pointer_from_data_type(@options.output_data_type, output_width * output_height)
      each_block(raster_band.block_size) do |block_number, block_count, block_size, x_offset, y_offset|
        scaled_progress_ptr = nil
        progress_arg = nil

        if @options.progress_formatter
          scaled_progress_ptr = build_scaled_progress_pointer(block_number, block_count)
          progress_arg = FFI::CPL::Progress::ScaledProgress
        end

        x_request = build_data_request_size(block_size[:x], x_offset, output_width)
        y_request = build_data_request_size(block_size[:y], y_offset, output_height)
        output_size = { x: x_request, y: y_request }

        grid_x_min, grid_x_max = build_grid_extents(x_min, geo_transform.pixel_width, x_offset, x_request)
        grid_y_min, grid_y_max = build_grid_extents(y_min, geo_transform.pixel_height, y_offset, y_request)
        extents = { x_min: grid_x_min, x_max: grid_x_max, y_min: grid_y_min, y_max: grid_y_max }

        @options.grid.create(points, extents, data_ptr, output_size,
          progress_arg, scaled_progress_ptr)

        raster_band.raster_io('w', data_ptr, x_offset: x_offset, y_offset: y_offset,
                                             x_size: x_request, y_size: y_request,
                                             buffer_x_size: x_request, buffer_y_size: y_request)
      end
    end

    # @param raster_band_block_size [Hash{x: Fixnum, y: Fixnum}]
    # @param data_type_size [Fixnum]
    # @return [Hash{x: Fixnum, y: Fixnum}]
    def build_block_sizes(raster_band_block_size, data_type_size)
      block_x_size = raster_band_block_size[:x]
      block_y_size = raster_band_block_size[:y]

      if block_x_size.to_i < output_width && block_y_size.to_i < output_height &&
         block_x_size.to_i < DESIRED_BUFFER_SIZE / (block_y_size * data_type_size)
        new_block_x_size = DESIRED_BUFFER_SIZE / (block_y_size * data_type_size)
        block_x_size = (new_block_x_size / block_x_size) * block_x_size

        block_x_size = output_width if block_x_size.to_i > output_width
      elsif block_x_size.to_i == output_width && block_y_size.to_i < output_height &&
            block_y_size.to_i < DESIRED_BUFFER_SIZE / (output_width * data_type_size)
        new_block_y_size = DESIRED_BUFFER_SIZE / (output_width * data_type_size)
        block_y_size = (new_block_y_size / block_y_size) * block_y_size

        block_y_size = output_height if block_y_size.to_i > output_height
      end

      { x: block_x_size.freeze, y: block_y_size.freeze }
    end

    # Builds a pointer to a GDALScaledProgress function. This is used in
    # conjunction with the @options.progress_function to be able to display
    # progress across grid+rasterize iterations. Without this, the user would
    # only get progress for each time through a block, not for all of the
    # blocks.
    #
    # @see http://gdal.sourcearchive.com/documentation/1.7.2/gdal_8h_904fbbb050e16c9d0ac028dc5113ef27.html
    # @param block_number [Fixnum]
    # @param block_count [Fixnum]
    # @return [FFI::Pointer]
    def build_scaled_progress_pointer(block_number, block_count)
      return unless @options.progress_formatter

      FFI::CPL::Progress.GDALCreateScaledProgress(
        block_number.to_f / block_count,
        (block_number + 1).to_f / block_count,
        @options.progress_formatter,
        nil)
    end

    # Determines how large of a chunk of data to grid and rasterize.
    #
    # @param block_size [Fixnum]
    # @param raster_border [Fixnum]
    # @return [Fixnum]
    def build_data_request_size(block_size, offset, raster_border)
      request = block_size

      if offset + request > raster_border
        raster_border - offset
      else
        request
      end
    end

    # @param min [Float]
    # @param pixel_size [Float]
    # @param offset [Float]
    # @param request_size [Fixnum]
    # @return [Array<Fixnum, Fixnum>] The min and max values based on the given
    #   parameters.
    def build_grid_extents(min, pixel_size, offset, request_size)
      grid_min = min + pixel_size * offset
      grid_max = min + pixel_size * (offset + request_size)

      [grid_min, grid_max]
    end

    # @param block_x_size [Fixnum]
    # @param block_y_size [Fixnum]
    # @param raster_width [Fixnum]
    # @param raster_height [Fixnum]
    # @return [Fixnum] The total number of blocks that should be iterated
    #   through during the grid+rasterize process.
    def build_block_count(block_x_size, block_y_size, raster_width, raster_height)
      build_block_size(raster_width, block_x_size) * build_block_size(raster_height, block_y_size)
    end

    # @param total_pixels [Fixnum] Number of pixels in the width or height.
    # @param block_size [Fixnum] Size of the reported block.
    def build_block_size(total_pixels, block_size)
      (total_pixels + block_size - 1) / block_size
    end
  end
end
