require_relative '../ffi/gdal'
require_relative 'major_object'
require_relative 'driver_extensions'
require 'multi_xml'
require 'log_switch'


module GDAL
  class Driver
    include MajorObject
    include GDAL::Logger
    include DriverExtensions

    GDAL_DOCS_URL = 'http://gdal.org'

    # @return [Fixnum]
    def self.count
      FFI::GDAL.GDALGetDriverCount
    end

    # @param name [String] Short name of the registered GDALDriver.
    # @return [GDAL::Driver]
    def self.by_name(name)
      driver_ptr = FFI::GDAL.GDALGetDriverByName(name)
      return nil if driver_ptr.null?

      new(driver_ptr)
    end

    # @return [Array<String>]
    def self.short_names
      return @short_names if @short_names

      names = 0.upto(count - 1).map do |i|
        driver = at_index(i)
        driver.short_name
      end

      @short_names = names.compact.sort
    end

    # @return [Array<String>]
    def self.long_names
      return @long_names if @long_names

      names = 0.upto(count - 1).map do |i|
        at_index(i).long_name
      end

      @long_names = names.compact.sort
    end

    # @return [Hash{String => String}] Keys are driver short names, values are
    #   driver long names.
    def self.names
      return @names if @names

      names = 0.upto(count - 1).each_with_object({}) do |i, obj|
        driver = at_index(i)
        obj[driver.short_name] = driver.long_name
      end

      @names = Hash[names.sort]
    end

    # @param index [Fixnum] Index of the registered driver.  Must be less than
    #   GDAL::Driver.count.
    # @return [GDAL::Driver]
    def self.at_index(index)
      if index > count
        raise "index must be between 0 and #{count - 1}."
      end

      driver_ptr = FFI::GDAL.GDALGetDriver(index)

      new(driver_ptr)
    end

    # @param file_path [String] File to get the driver for.
    # @return [GDAL::Driver]
    def self.identify_driver(file_path)
      driver_ptr = FFI::GDAL.GDALIdentifyDriver(::File.expand_path(file_path), nil)

      new(driver_ptr)
    end

    # @param driver [GDAL::Driver, FFI::Pointer]
    def initialize(driver)
      @driver_pointer = GDAL._pointer(GDAL::Driver, driver)
    end

    def c_pointer
      @driver_pointer
    end

    # @return [String]
    def short_name
      FFI::GDAL.GDALGetDriverShortName(@driver_pointer)
    end

    # @return [String]
    def long_name
      FFI::GDAL.GDALGetDriverLongName(@driver_pointer)
    end

    # @return [String]
    def help_topic
      "#{GDAL_DOCS_URL}/#{FFI::GDAL.GDALGetDriverHelpTopic(@driver_pointer)}"
    end

    # Lists and describes the options that can be used when calling
    # GDAL::Dataset.create or GDAL::Dataset.create_copy.
    #
    # @return [Array]
    def creation_option_list
      return [] unless @driver_pointer

      creation_option_list_xml = FFI::GDAL.GDALGetDriverCreationOptionList(@driver_pointer)
      root = MultiXml.parse(creation_option_list_xml)
      return [] if root.nil? || root.empty?

      list = root['CreationOptionList']
      return [] if list.nil? || list.empty?

      list['Option']
    end

    # @param options [Hash]
    # @return [Boolean]
    def validate_creation_options(options)
      options_pointer = if options.is_a? GDAL::Options
        options.c_pointer
      else
        GDAL::Options.pointer(options)
      end

      FFI::GDAL.GDALValidateCreationOptions(@driver_pointer, options_pointer).to_bool
    end

    # Copy all of the associated files of a dataset from one file to another.
    #
    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def copy_dataset_files(new_name, old_name)
      cpl_err = FFI::GDAL.GDALCopyDatasetFiles(@driver_pointer, new_name, old_name)

      cpl_err.to_bool
    end

    # Create a new Dataset with this driver.  Legal arguments depend on the
    # driver and can't be retrieved programmatically.  NOTE: In order to write
    # out all data to the destination, you must call #close on the dataset!
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
      options_pointer = GDAL::Options.pointer(options)

      dataset_pointer = FFI::GDAL.GDALCreate(@driver_pointer,
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

      dataset
    end

    # @param filename [String] The name for the new dataset file.
    # @param source_dataset [GDAL::Dataset, FFI::Pointer] The dataset to copy.
    # @param strict [Boolean] +false+ indicates the copy may adapt as needed for
    #   the output format.
    # @param options [Hash]
    # @param progress [Proc] For outputing copy progress.  Conforms to the
    #   FFI::GDAL::GDALProgressFunc signature.
    def copy_dataset(filename, source_dataset, strict: true, **options, &progress)
      options_ptr = GDAL::Options.pointer(options)

      source_dataset_ptr = if source_dataset.is_a? GDAL::Dataset
        source_dataset.c_pointer
      elsif source_dataset.is_a? String
        GDAL::Dataset.open(source_dataset, 'r').c_pointer
      else
        source_dataset
      end

      raise "Source dataset couldn't be read" if source_dataset_ptr.null?

      destination_dataset_ptr = FFI::GDAL.GDALCreateCopy(@driver_pointer,
        filename,
        source_dataset_ptr,
        strict,
        options_ptr,
        progress,
        nil
      )

      raise CreateFail if destination_dataset_ptr.null?

      dataset = Dataset.new(destination_dataset_ptr)
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
      cpl_err = FFI::GDAL.GDALDeleteDataset(@driver_pointer, file_name)

      cpl_err.to_bool
    end

    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def rename_dataset(new_name, old_name)
      cpl_err = FFI::GDAL.GDALRenameDataset(@driver_pointer, new_name, old_name)

      cpl_err.to_bool
    end
  end
end
