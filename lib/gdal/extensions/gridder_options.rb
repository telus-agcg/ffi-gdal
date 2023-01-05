# frozen_string_literal: true

require 'gdal/grid'
require 'gdal/options'
require 'ogr/exceptions'
require 'ogr/geometry'
require 'ogr/spatial_reference'

module GDAL
  # Object to be used with a {GDAL::Gridder}.
  class GridderOptions
    extend Forwardable

    # Name of field attribute to extract from each feature to use for Z values.
    #
    # @!attribute [rw] input_field_name
    # @return [String]
    attr_accessor :input_field_name

    # Custom progress output Proc, passed on to {GDAL::Grid#create}. This must
    # follow semantics imposed by +FFI::GDAL::GDAL.ProgressFunc+.
    #
    # This option doesn't exist in gdal_grid; you only get their output format
    # or no output at all (using +-q+).
    #
    # @!attribute [rw] progress_formatter
    # @return [Proc]
    attr_accessor :progress_formatter

    # Use for filtering out input points; any input points from the layer that
    # fall within this boundary will be excluded from the gridding process.
    # Note that this does not clip the output raster.
    #
    # Replaces gdal_grid's +-clipsrc+ option.
    #
    # @!attribute [rw] input_clipping_geometry
    # @return [OGR::Geometry]
    attr_reader :input_clipping_geometry

    # Driver-specific options to pass to the {GDAL::Driver} when creating the
    # raster. Check out GDAL documentation for the driver you're specifying
    # (specified here through {#output_format}) to see what options you have
    # available.
    #
    # Correlates to gdal_grid option +-co+.
    #
    # @!attribute output_creation_options
    # @return [Hash]
    attr_reader :output_creation_options

    # The {GDAL::Driver} name to use for creating the output raster.
    #
    # Correlates to gdal_grid option +-of+.
    #
    # @!attribute [rw] output_format
    # @return [String]
    attr_reader :output_format

    # The minimum and maximum X coordinates for the output raster.
    #
    # Correlates to gdal_grid option +-txe+.
    #
    # @!attribute [rw] output_x_extent
    # @return [Hash{min: Number, max: Number}]
    attr_reader :output_x_extent

    # The minimum and maximum Y coordinates for the output raster.
    #
    # Correlates to gdal_grid option +-tye+.
    #
    # @!attribute [rw] output_y_extent
    # @return [Hash{min: Number, max: Number}]
    attr_reader :output_y_extent

    # The SpatialReference to use for the output raster's {GDAL::Dataset#projection}.
    # If one isn't given, the {GDAL::Gridder} will try to use the one from the
    # source layer.
    #
    # Correlates to gdal_grid option +-a_srs+.
    #
    # @!attribute [rw] output_projection
    # @return [OGR::SpatialReference]
    attr_reader :output_projection

    # Dimensions to output the raster in.
    #
    # Correlates to gdal_grid option +-outsize+.
    #
    # @overload output_size
    # @overload output_size=(width_height_array)
    #   Sets the output Hash using a 2-element Array.
    #   @param width_height_array [Array<Float>]
    #     A 2-element Array specifying the width and height of the output raster.
    # @overload output_size=(width_height_hash)
    #   Sets the output Hash using a similar input Hash.
    #   @param width_height_hash [Hash{width => Number, height => Number}]
    #     A Hash with :width and :height keys, specifying the width and height
    #     of the output raster.
    # @return [Hash{width: Number, height: Number}]
    attr_reader :output_size

    # Data type of the output raster values.
    #
    # Correlates to gdal_grid option +-ot+.
    #
    # @!attribute [rw] output_data_type
    # @return [FFI::GDAL::GDAL::DataType]
    attr_reader :output_data_type

    # Object used by the {GDAL::Gridder} for doing the actual grid work.
    #
    # @!attribute [r] grid
    # @return [GDAL::Grid]
    attr_reader :grid

    # Object used by the {GDAL::Gridder} for doing the actual grid work.
    #
    # @!method algorithm_options
    # @return [FFI::Struct] One of the FFI::GDAL grid algorithm Options objects.
    def_delegator :@grid, :algorithm_options, :algorithm_options

    # @param algorithm_type [Symbol] One of {FFI::GDAL::Alg::GridAlgorithm}.
    def initialize(algorithm_type)
      # Options with defaults
      @output_data_type = :GDT_Float64
      @output_format = 'GTiff'
      @output_size = { width: 256, height: 256 }

      # Options without defaults
      @input_clipping_geometry = nil
      @output_x_extent = {}
      @output_y_extent = {}
      @output_projection = nil
      @output_creation_options = {}
      @progress_formatter = nil

      @grid = GDAL::Grid.new(algorithm_type, data_type: @output_data_type)
    end

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def input_clipping_geometry=(geometry)
      unless geometry.is_a?(OGR::Geometry)
        raise OGR::InvalidGeometry,
              "Clipping geometry must be a OGR::Geometry type, but was a #{geometry.class}"
      end

      @input_clipping_geometry = geometry
    end

    # @param type [Symbol] Must be one of FFI::GDAL::GDAL::DataType.
    def output_data_type=(type)
      data_types = FFI::GDAL::GDAL::DataType.symbols

      unless data_types.include?(type)
        raise GDAL::InvalidDataType, "output_data_type must be one of #{data_types} but was #{type}"
      end

      @grid.data_type = @output_data_type = type
    end

    # @return [Integer]
    def output_data_type_size
      GDAL::DataType.size(@output_data_type) / 8
    end

    # @param format [String] Must be one of GDAL::Driver.short_names.
    def output_format=(format)
      driver_names = GDAL::Driver.short_names

      unless driver_names.include?(format)
        raise GDAL::InvalidDriverName, "output_form must be one of #{driver_names} but was #{format}"
      end

      @output_format = format
    end

    # The {GDAL::Driver}, based on {#output_format} to use for creating the
    # output raster.
    #
    # @return [GDAL::Driver]
    def output_driver
      @output_driver ||= GDAL::Driver.by_name(@output_format)
    end

    # @param min_max [Array<Integer>, Hash{min => Number, max => Number}]
    def output_x_extent=(min_max)
      min, max = extract_min_max(min_max, :min, :max)

      @output_x_extent = { min: min, max: max }
    end

    # @param min_max [Array<Integer>, Hash{min => Number, max => Number}]
    def output_y_extent=(min_max)
      min, max = extract_min_max(min_max, :min, :max)

      @output_y_extent = { min: min, max: max }
    end

    # @param width_height [Array<Float>, Hash{width => Number, height => Number}]
    #   Either a 2-element Array or a Hash with :width and :height keys,
    #   specifying the width and height of the output raster.
    def output_size=(width_height)
      width, height = extract_min_max(width_height, :width, :height)

      @output_size = { width: width, height: height }
    end

    # Set to use a different SRID for the output raster. Defaults to use the
    # same as the source Layer.
    #
    # @param spatial_reference [OGR::SpatialReference]
    def output_projection=(spatial_reference)
      unless spatial_reference.is_a?(OGR::SpatialReference)
        raise OGR::InvalidSpatialReference,
              "output_projection must be an OGR::SpatialReference but was a #{spatial_reference.class}"
      end

      @output_projection = spatial_reference
    end

    # @param options_hash [Hash]
    def output_creation_options=(**options_hash)
      return if options_hash.empty?

      @output_creation_options = options_hash
    end

    private

    # Extracts a min and max value from either a 2-element Array or a Hash with
    # :min and :max keys.
    #
    # @param content [Array, Hash]
    # @param min_name [Symbol]
    # @param max_name [Symbol]
    # @return [Array<Number>]
    def extract_min_max(content, min_name, max_name)
      case content
      when Array
        extract_min_max_from_array(content, min_name, max_name)
      when Hash
        extract_min_max_from_hash(content, min_name, max_name)
      end
    end

    # @param content [Array, Hash]
    # @param min_name [Symbol]
    # @param max_name [Symbol]
    # @return [Array<Number>]
    def extract_min_max_from_array(content, min_name, max_name)
      unless content.length == 2
        raise ArgumentError, "Please supply only 2 elements, one for #{min_name}, one for #{max_name}"
      end

      [content[0], content[1]]
    end

    # @param content [Array, Hash]
    # @param min_name [Symbol]
    # @param max_name [Symbol]
    # @return [Array<Number>]
    def extract_min_max_from_hash(content, min_name, max_name)
      valid_keys = [min_name, max_name]
      actual_keys = content.keys

      unless actual_keys.length == 2 && valid_keys & actual_keys == valid_keys
        raise ArgumentError, "Please supply only key/value pairs for #{min_name} and #{max_name}"
      end

      [content[min_name], content[max_name]]
    end
  end
end
