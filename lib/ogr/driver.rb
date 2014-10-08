module OGR
  class Driver
    include FFI::GDAL
    include GDAL::MajorObject

    # @return [Fixnum]
    def self.count
      FFI::GDAL.OGRGetDriverCount
    end

    # @param name [String] Short name of the registered OGRDriver.
    # @return [OGR::Driver]
    def self.by_name(name)
      driver_ptr = FFI::GDAL.OGRGetDriverByName(name)

      new(driver_ptr)
    end

    # @param index [Fixnum] Index of the registered driver.  Must be less than
    #   OGR::Driver.count.
    # @return [OGR::Driver]
    def self.at_index(index)
      if index > count
        raise "index must be between 0 and #{count - 1}."
      end

      driver_ptr = FFI::GDAL.OGRGetDriver(index)

      new(driver_ptr)
    end

    # @return [Array<String>]
    def self.names
      return @names if @names

      names = 0.upto(count - 1).map do |i|
        at_index(i).name
      end

      @names = names.compact.sort
    end

    def initialize(driver)
      @driver_pointer = if driver.is_a? OGR::Driver
        driver.c_pointer
      else
        driver
      end
    end

    def c_pointer
      @driver_pointer
    end

    # @return [String]
    def name
      OGR_Dr_GetName(@driver_pointer)
    end

    # @param file_name [String]
    # @param access_flag [String] 'r' or 'w'.
    # @return [OGR::DataSource, nil]
    def open(file_name, access_flag = 'r')
      update = access_flag == 'w' ? true : false

      data_source_ptr = OGR_Dr_Open(@driver_pointer, file_name, update)
      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr)
    end

    # @param file_name [String]
    # @param options [Hash]
    # @return [OGR::DataSource, nil]
    def create_data_source(file_name, **options)
      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr = OGR_Dr_CreateDataSource(@driver_pointer, file_name, options_ptr)
      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr)
    end

    # @param file_name [String]
    def delete_data_source(file_name)
      ogr_err = OGR_Dr_DeleteDataSource(@driver_pointer, file_name)
    end

    # @param source_data_source [OGR::DataSource, FFI::Pointer]
    # @param new_file_name [String]
    # @param options [Hash]
    # @return [OGR::DataSource, nil]
    def copy_data_source(source_data_source, new_file_name, **options)
      source_ptr = if source_data_source.is_a? OGR::DataSource
        source_data_source.c_pointer
      else
        source_data_source
      end

      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr = OGR_Dr_CopyDataSource(@driver_pointer, source_ptr,
        new_file_name, options_ptr)
      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr)
    end
  end
end
