# frozen_string_literal: true

require_relative '../ogr'
require_relative '../gdal'
require_relative '../gdal/major_object'
require_relative 'driver_mixins/capability_methods'

module OGR
  # Wrapper for OGR's Driver class.  In this case, to use a driver, find the
  # driver you're looking for using +.by_name+ or +.by_index+; that will return
  # an instance of an OGR::Driver.
  #
  # More about the C API here: http://www.gdal.org/ogr_drivertut.html.
  class Driver
    include GDAL::MajorObject
    include GDAL::Logger
    include DriverMixins::CapabilityMethods

    # @return [Integer]
    def self.count
      if GDAL.major_version >= 2
        FFI::GDAL::GDAL.GDALGetDriverCount
      else
        FFI::OGR::API.OGRGetDriverCount
      end
    end

    # @param name [String] Short name of the registered OGRDriver.
    # @return [OGR::Driver]
    # @raise [OGR::DriverNotFound] if a driver with +name+ isn't found.
    def self.by_name(name)
      driver_ptr = if GDAL.major_version >= 2
                     FFI::GDAL::GDAL.GDALGetDriverByName(name)
                   else
                     FFI::OGR::API.OGRGetDriverByName(name)
                   end
      raise OGR::DriverNotFound, name if driver_ptr.null?

      new(driver_ptr)
    end

    # @param index [Integer] Index of the registered driver.  Must be less than
    #   OGR::Driver.count.
    # @return [OGR::Driver]
    # @raise [OGR::DriverNotFound] if a driver at +index+ isn't found.
    def self.at_index(index)
      raise OGR::DriverNotFound, index if index > count

      driver_ptr = if GDAL.major_version >= 2
                     FFI::GDAL::GDAL.GDALGetDriver(index)
                   else
                     FFI::OGR::API.OGRGetDriver(index)
                   end
      return nil if driver_ptr.null?
      raise OGR::DriverNotFound, index if driver_ptr.null?

      new(driver_ptr)
    end

    # @return [Array<String>]
    def self.names
      Array.new(count) { |i| at_index(i).name }.sort
    end

    # @return [FFI::Pointer] C pointer that represents the Driver.
    attr_reader :c_pointer

    # You probably don't want to use this directly--see .by_name and .at_index
    # to instantiate a OGR::Driver object.
    #
    # @param driver [OGR::Driver, FFI::Pointer]
    def initialize(driver)
      @c_pointer = GDAL._pointer(OGR::Driver, driver)
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_Dr_GetName(@c_pointer)
    end

    # @param file_name [String]
    # @param access_flag [String] 'r' or 'w'.
    # @return [OGR::DataSource, nil]
    def open(file_name, access_flag = 'r')
      update = OGR._boolean_access_flag(access_flag)

      data_source_ptr = if GDAL.major_version >= 2
                          FFI::GDAL::GDAL.GDALOpenEx(file_name, update, nil, nil, nil)
                        else
                          FFI::OGR::API.OGR_Dr_Open(@c_pointer, file_name, update)
                        end

      raise OGR::InvalidDataSource, "Unable to open data source at #{file_name}" if data_source_ptr.null?

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
      unless can_create_data_source?
        raise OGR::UnsupportedOperation, 'This driver does not support data source creation.'
      end

      options_ptr = GDAL::Options.pointer(options)

      data_source_ptr =
        if GDAL.major_version >= 2
          # Per the docs: In GDAL 2, the arguments nXSize, nYSize and nBands can be passed to 0 when
          # creating a vector-only dataset for a compatible driver.
          FFI::GDAL::GDAL.GDALCreate(
            @c_pointer,
            file_name,
            0,
            0,
            0,
            0,
            options_ptr
          )
        else
          FFI::OGR::API.OGR_Dr_CreateDataSource(
            @c_pointer,
            file_name,
            options_ptr
          )
        end

      return nil if data_source_ptr.null?

      ds = OGR::DataSource.new(data_source_ptr, 'w')
      yield ds if block_given?

      ds
    end

    # @param file_name [String]
    # @return +true+ if successful, otherwise raises an OGR exception.
    def delete_data_source(file_name)
      unless can_delete_data_source?
        raise OGR::UnsupportedOperation, 'This driver does not support deleting data sources.'
      end

      ogr_err = if GDAL.major_version >= 2
                  FFI::GDAL::GDAL.GDALDeleteDataset(@c_pointer, file_name)
                else
                  FFI::OGR::API.OGR_Dr_DeleteDataSource(@c_pointer, file_name)
                end

      ogr_err.handle_result
    end

    # @param source_data_source [OGR::DataSource, FFI::Pointer]
    # @param new_file_name [String]
    # @param options [Hash]
    # @return [OGR::DataSource, nil]
    def copy_data_source(source_data_source, new_file_name, **options)
      source_ptr = GDAL._pointer(OGR::DataSource, source_data_source)

      raise OGR::InvalidDataSource, source_data_source if source_ptr.nil? || source_ptr.null?

      options_ptr = GDAL::Options.pointer(options)
      strict = false
      progress_function = nil
      progress_data = nil

      data_source_ptr = if GDAL.major_version >= 2
                          FFI::GDAL::GDAL.GDALCreateCopy(
                            @c_pointer,
                            new_file_name,
                            source_ptr,
                            strict,
                            options_ptr,
                            progress_function,
                            progress_data
                          )
                        else
                          FFI::OGR::API.OGR_Dr_CopyDataSource(
                            @c_pointer,
                            source_ptr,
                            new_file_name,
                            options_ptr
                          )
                        end

      return nil if data_source_ptr.null?

      OGR::DataSource.new(data_source_ptr, nil)
    end

    # @param [String] capability
    # @return [Boolean]
    def test_capability(capability)
      if GDAL.major_version >= 2
        FFI::GDAL::GDAL.GDALGetMetadataItem(@c_pointer, capability, nil) == 'YES'
      else
        FFI::OGR::API.OGR_Dr_TestCapability(@c_pointer, capability)
      end
    end
  end
end
