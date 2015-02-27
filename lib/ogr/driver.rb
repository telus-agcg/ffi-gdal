require_relative '../ffi/ogr'
require_relative '../gdal/major_object'
require_relative '../gdal/options'
require_relative 'data_source'

module OGR
  # Wrapper for OGR's Driver class.  In this case, to use a driver, find the
  # driver you're looking for using +.by_name+ or +.by_index+; that will return
  # an instance of an OGR::Driver.
  #
  # More about the C API here: http://www.gdal.org/ogr_drivertut.html.
  class Driver
    include GDAL::MajorObject
    include GDAL::Logger

    # @return [Fixnum]
    def self.count
      FFI::OGR::API.OGRGetDriverCount
    end

    # @param name [String] Short name of the registered OGRDriver.
    # @return [OGR::Driver]
    # @raise [OGR::DriverNotFound] if a driver with +name+ isn't found.
    def self.by_name(name)
      driver_ptr = FFI::OGR::API.OGRGetDriverByName(name)
      fail OGR::DriverNotFound, name if driver_ptr.null?

      new(driver_ptr)
    end

    # @param index [Fixnum] Index of the registered driver.  Must be less than
    #   OGR::Driver.count.
    # @return [OGR::Driver]
    # @raise [OGR::DriverNotFound] if a driver at +index+ isn't found.
    def self.at_index(index)
      fail OGR::DriverNotFound, index if index > count

      driver_ptr = FFI::OGR::API.OGRGetDriver(index)
      return nil if driver_ptr.null?
      fail OGR::DriverNotFound, index if driver_ptr.null?

      new(driver_ptr)
    end

    # @return [Array<String>]
    def self.names
      0.upto(count - 1).map do |i|
        at_index(i).name
      end.sort
    end

    # You probably don't want to use this directly--see .by_name and .at_index
    # to instantiate a OGR::Driver object.
    #
    # @param driver [OGR::Driver, FFI::Pointer]
    def initialize(driver)
      @driver_pointer = GDAL._pointer(OGR::Driver, driver)
    end

    # @return [FFI::Pointer]
    def c_pointer
      @driver_pointer
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_Dr_GetName(@driver_pointer)
    end

    # @param file_name [String]
    # @param access_flag [String] 'r' or 'w'.
    # @return [OGR::DataSource, nil]
    def open(file_name, access_flag = 'r')
      update = OGR._boolean_access_flag(access_flag)

      data_source_ptr = FFI::OGR::API.OGR_Dr_Open(@driver_pointer, file_name, update)

      if data_source_ptr.null?
        fail OGR::InvalidDataSource, "Unable to open data source at #{file_name}"
      end

      OGR::DataSource.new(data_source_ptr, nil)
    end

    # Creates a new data source at path +file_name+.  Yields the newly created
    # data source to a block, if given.  NOTE: in order to write out all
    # in-memory data, you need to call #close on the created DataSource.
    #
    # @param file_name [String]
    # @param options [Hash]
    # @return [OGR::DataSource, nil]
    def create_data_source(file_name, **options)
      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr = FFI::OGR::API.OGR_Dr_CreateDataSource(@driver_pointer,
        file_name, options_ptr)
      return nil if data_source_ptr.null?

      ds = OGR::DataSource.new(data_source_ptr, nil)
      yield ds if block_given?

      ds
    end

    # @param file_name [String]
    # @return +true+ if successful, otherwise raises an OGR exception.
    def delete_data_source(file_name)
      ogr_err = FFI::OGR::API.OGR_Dr_DeleteDataSource(@driver_pointer, file_name)

      ogr_err.handle_result
    end

    # @param source_data_source [OGR::DataSource, FFI::Pointer]
    # @param new_file_name [String]
    # @param options [Hash]
    # @return [OGR::DataSource, nil]
    def copy_data_source(source_data_source, new_file_name, **options)
      source_ptr = GDAL._pointer(OGR::DataSource, source_data_source)

      if source_ptr.nil? || source_ptr.null?
        fail OGR::InvalidDataSource, source_data_source
      end

      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr = FFI::OGR::API.OGR_Dr_CopyDataSource(@driver_pointer,
        source_ptr, new_file_name, options_ptr)
      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr, nil)
    end

    # @param [String] capability
    # @return [Boolean]
    def test_capability(capability)
      FFI::OGR::API.OGR_Dr_TestCapability(@driver_pointer, capability)
    end
  end
end
