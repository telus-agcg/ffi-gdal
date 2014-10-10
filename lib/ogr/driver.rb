module OGR
  class Driver
    include FFI::GDAL
    include GDAL::MajorObject
    extend GDAL::Logger
    include LogSwitch::Mixin

    # @return [Fixnum]
    def self.count
      FFI::GDAL.OGRGetDriverCount
    end

    # @param name [String] Short name of the registered OGRDriver.
    # @return [OGR::Driver]
    def self.by_name(name)
      driver_ptr = FFI::GDAL.OGRGetDriverByName(name)
      return nil if driver_ptr.null?

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
      @driver_pointer = GDAL._pointer(OGR::Driver, driver)
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
      update = OGR._boolean_access_flag(access_flag)

      data_source_ptr = OGR_Dr_Open(@driver_pointer, file_name, update)
      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr)
    end

    # Creates a new data source at path +file_name+.  Yields the newly created
    # data source to a block, if given.  Always closes/destroys before returning.
    #
    # @param file_name [String]
    # @param options [Hash]
    # @return [OGR::DataSource, nil]
    def create_data_source(file_name, **options)
      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr = OGR_Dr_CreateDataSource(@driver_pointer, file_name, options_ptr)
      return nil if data_source_ptr.null?

      ds = OGR::DataSource.new(data_source_ptr)

      yield ds if block_given?
      ds.close

      ds
    rescue GDAL::InvalidBandNumber
      ds.close
      delete_data_source(file_name)
      raise
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
      source_ptr = GDAL._pointer(OGR::DataSource, source_data_source)
      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr = OGR_Dr_CopyDataSource(@driver_pointer, source_ptr,
        new_file_name, options_ptr)
      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr)
    end
  end
end
