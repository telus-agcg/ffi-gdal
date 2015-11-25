require_relative 'options'

module GDAL
  class WarpOptions
    attr_reader :c_struct

    def initialize(options = {})
      @c_struct = FFI::GDAL::WarpOptions.new

      options.keys do |k|
        @c_struct[k] = options[k]
      end
    end

    def c_pointer
      @c_struct.to_ptr
    end

    # @param options [Hash]
    def warp_operation_options=(options)
      @c_struct[:warp_operation_options] = GDAL::Options.pointer(options)
    end

    # @param limit [Float]
    def warp_memory_limit=(limit)
      @c_struct[:warp_memory_limit] = limit
    end

    # @param algorithm_type [FFI::GDAL::Warper::ResampleAlg]
    def resample_algorithm=(algorithm_type)
      @c_struct[:resample_alg] = algorithm_type
    end

    # @param data_type [FFI::GDAL::GDAL::DataType]
    def working_data_type=(data_type)
      @c_struct[:working_data_type] = data_type
    end

    # @param dataset [GDAL::Dataset]
    def source_dataset=(dataset)
      @c_struct[:source_dataset] = dataset.c_pointer
    end

    # @param dataset [GDAL::Dataset]
    def destination_dataset=(dataset)
      @c_struct[:destination_dataset] = dataset.c_pointer
    end

    # @param count [Fixnum]
    def band_count=(count)
      @c_struct[:band_count] = count
    end

    # @param band_numbers [Array<Fixnum>]
    def source_bands=(band_numbers)
      bands_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.length)
      bands_ptr.write_array_of_int(band_numbers)

      @c_struct[:source_bands] = bands_ptr
    end

    # @param band_numbers [Array<Fixnum>]
    def destination_bands=(band_numbers)
      bands_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.length)
      bands_ptr.write_array_of_int(band_numbers)

      @c_struct[:destination_bands] = bands_ptr
    end

    def transformer_arg=(transformation_object)
      @c_struct[:transformer_arg] = transformation_object.c_pointer

      @c_struct[:transformer] = transformation_object.function
    end

    def transformer=(transformer)
      @c_struct[:transformer] = transformer
    end

    def progress_formatter=(output_proc)
      @c_struct[:progress] = output_proc
    end

    def cutline_geometry=(geometry)
      fail 'Not a geom' unless geometry.is_a?(OGR::Geometry)

      @c_struct[:cutline] = geometry.c_pointer
      # @c_struct[:cutline] = geometry.clone.c_pointer
    end

    def cutline_blend_distance=(distance)
      @c_struct[:cutline_blend_distance] = distance
    end

    def source_no_data_real=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:source_no_data_real] = values_ptr
    end

    def source_no_data_imaginary=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:source_no_data_imaginary] = values_ptr
    end

    def destination_no_data_real=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:destination_no_data_real] = values_ptr
    end

    def destination_no_data_imaginary=(values)
      values_ptr = FFI::MemoryPointer.new(:double, values.length)
      values_ptr.write_array_of_double(values)

      @c_struct[:destination_no_data_imaginary] = values_ptr
    end

    # Used for getting attributes of the internal WarpOptions struct.
    #
    # @param meth [Symbol] The FFI::GDAL::WarpOptions key.
    def method_missing(meth)
      super unless FFI::GDAL::WarpOptions.members.include?(meth)

      @c_struct[meth]
    end
  end
end
