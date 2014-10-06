require_relative '../ffi/gdal'
require_relative 'major_object'
require 'multi_xml'
require 'log_switch'


module GDAL
  class Driver
    include FFI::GDAL
    include MajorObject
    include LogSwitch::Mixin

    GDAL_DOCS_URL = 'http://gdal.org'

    # @return [Fixnum]
    def self.driver_count
      FFI::GDAL.GDALGetDriverCount
    end

    # @return [GDAL::Driver]
    def self.by_name(name)
      new(name: name)
    end

    # Creates a new GDAL::Driver object based on the mutually exclusive given
    # parameters.  Pass in only one of the allowed parameters.
    #
    # @param file_path [String] File to get the driver for.
    # @param name [String] Name of the registered GDALDriver.
    # @param index [Fixnum] Index of the registered driver.  Must be less than
    #   GDAL::Driver.driver_count.
    def initialize(file_path: file_path, name: name, index: index)
      @gdal_driver_handle = if file_path
        GDALIdentifyDriver(::File.expand_path(file_path), nil)
      elsif name
        GDALGetDriverByName(name)
      elsif index
        count = self.class.driver_count
        raise "index must be between 0 and #{count - 1}." if index > count

        GDALGetDriver(index)
      else
        raise 'No Driver identifier given.  My pass in file_path, name, or index.'
      end
    end

    def c_pointer
      @gdal_driver_handle
    end

    # @return [String]
    def short_name
      GDALGetDriverShortName(@gdal_driver_handle)
    end

    # @return [String]
    def long_name
      GDALGetDriverLongName(@gdal_driver_handle)
    end

    # @return [String]
    def help_topic
      "#{GDAL_DOCS_URL}/#{GDALGetDriverHelpTopic(@gdal_driver_handle)}"
    end

    # Lists and describes the options that can be used when calling
    # GDAL::Dataset.create or GDAL::Dataset.create_copy.
    #
    # @return [Array]
    def creation_option_list
      return [] unless @gdal_driver_handle

      creation_option_list_xml = GDALGetDriverCreationOptionList(@gdal_driver_handle)
      MultiXml.parse(creation_option_list_xml)['CreationOptionList']['Option']
    end

    # Copy all of the associated files of a dataset from one file to another.
    #
    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def copy_dataset_files(new_name, old_name)
      cpl_err = GDALCopyDatasetFiles(@gdal_driver_handle, new_name, old_name)

      cpl_err.to_bool
    end

    # Create a new Dataset with this driver.  Legal arguments depend on the
    # driver and can't be retrieved programmatically.
    #
    # @param filename [String]
    # @param x_size [Fixnum] Width of created raster in pixels.
    # @param y_size [Fixnum] Height of created raster in pixels.
    # @param bands [Fixnum]
    # @param type [FFI::GDAL::GDALDataType]
    # @return [GDAL::Dataset] Returns the *closed* dataset.  You'll need to
    #   reopen it if you with to continue working with it.
    # @todo Implement options.
    def create_dataset(filename, x_size, y_size, bands: 1, type: :GDT_Byte, **options)
      options_pointer = FFI::MemoryPointer.new(:pointer, 2)

      options.each_with_index.map do |(k, v), i|
        options_pointer = CSLSetNameValue(options_pointer, k.to_s.upcase, v)
      end

      dataset_pointer = GDALCreate(@gdal_driver_handle,
        filename,
        x_size,
        y_size,
        bands,
        type,
        options_pointer
      )

      raise CreateFail if dataset_pointer.null?

      dataset = Dataset.new(dataset_pointer)
      yield(dataset) if block_given?
      dataset.close

      dataset
    end

    # Delete the dataset represented by +file_name+.  Depending on the driver,
    # this could mean deleting associated files, database objects, etc.
    #
    # @param file_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def delete_dataset(file_name)
      cpl_err = GDALDeleteDataset(@gdal_driver_handle, file_name)

      cpl_err.to_bool
    end

    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def rename_dataset(new_name, old_name)
      cpl_err = GDALRenameDataset(@gdal_driver_handle, new_name, old_name)


      cpl_err.to_bool
    end
  end
end
