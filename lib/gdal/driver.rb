require_relative '../ffi-gdal'
require_relative '../gdal'
require_relative 'major_object'
require_relative 'exceptions'
require_relative 'driver_mixins/extensions'
require_relative 'dataset'
require_relative 'options'
require 'multi_xml'

module GDAL
  # Wrapper for GDAL drivers (aka "formats"). Useful for opening and working
  # with GDAL datasets.
  class Driver
    include MajorObject
    include GDAL::Logger
    include DriverMixins::Extensions

    GDAL_DOCS_URL = 'http://gdal.org'

    # @return [Fixnum]
    def self.count
      FFI::GDAL::GDAL.GDALGetDriverCount
    end

    # @param name [String] Short name of the registered GDALDriver.
    # @return [GDAL::Driver]
    # @raise [GDAL::InvalidDriverName] If +name+ does not represent a valid
    #   driver name.
    def self.by_name(name)
      driver_ptr = FFI::GDAL::GDAL.GDALGetDriverByName(name)

      if driver_ptr.null?
        fail InvalidDriverName, "'#{name}' is not a valid driver name."
      end

      new(driver_ptr)
    end

    # @param index [Fixnum] Index of the registered driver.  Must be less than
    #   GDAL::Driver.count.
    # @return [GDAL::Driver]
    # @raise [GDAL::InvalidDriverIndex] If driver at +index+ does not exist.
    def self.at_index(index)
      if index > count
        fail InvalidDriverIndex, "index must be between 0 and #{count - 1}."
      end

      driver_ptr = FFI::GDAL::GDAL.GDALGetDriver(index)

      new(driver_ptr)
    end

    # @param file_path [String] File to get the driver for.
    # @return [GDAL::Driver] Returns nil if the file is unsupported.
    def self.identify_driver(file_path)
      driver_ptr = FFI::GDAL::GDAL.GDALIdentifyDriver(::File.expand_path(file_path), nil)
      return nil if driver_ptr.null?

      new(driver_ptr)
    end

    attr_reader :c_pointer

    # @param driver [GDAL::Driver, FFI::Pointer]
    def initialize(driver)
      @c_pointer = GDAL._pointer(GDAL::Driver, driver)
    end

    # @return [String]
    def short_name
      FFI::GDAL::GDAL.GDALGetDriverShortName(@c_pointer)
    end

    # @return [String]
    def long_name
      FFI::GDAL::GDAL.GDALGetDriverLongName(@c_pointer)
    end

    # @return [String]
    def help_topic
      "#{GDAL_DOCS_URL}/#{FFI::GDAL::GDAL.GDALGetDriverHelpTopic(@c_pointer)}"
    end

    # Lists and describes the options that can be used when calling
    # GDAL::Dataset.create or GDAL::Dataset.create_copy.
    #
    # @return [Array]
    def creation_option_list
      return [] unless @c_pointer

      creation_option_list_xml = FFI::GDAL::GDAL.GDALGetDriverCreationOptionList(@c_pointer)
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

      FFI::GDAL::GDAL.GDALValidateCreationOptions(@c_pointer, options_pointer)
    end

    # Copy all of the associated files of a dataset from one file to another.
    #
    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def copy_dataset_files(old_name, new_name)
      FFI::GDAL::GDAL.GDALCopyDatasetFiles(@c_pointer, new_name, old_name)
    end

    # Create a new Dataset with this driver.  Legal arguments depend on the
    # driver and can't be retrieved programmatically.  NOTE: In order to write
    # out all data to the destination, you must call #close on the dataset!
    #
    # @param filename [String]
    # @param x_size [Fixnum] Width of created raster in pixels.
    # @param y_size [Fixnum] Height of created raster in pixels.
    # @param band_count [Fixnum]
    # @param data_type [FFI::GDAL::GDAL::DataType]
    # @return [GDAL::Dataset] Returns the *open* dataset.  You'll need to
    #   close it.
    def create_dataset(filename, x_size, y_size, band_count: 1, data_type: :GDT_Byte, **options)
      options_pointer = GDAL::Options.pointer(options)

      dataset_pointer = FFI::GDAL::GDAL.GDALCreate(
        @c_pointer,
        filename,
        x_size,
        y_size,
        band_count,
        data_type,
        options_pointer
      )

      fail CreateFail if dataset_pointer.null?

      dataset = GDAL::Dataset.new(dataset_pointer, nil)
      yield(dataset) if block_given?

      dataset
    end

    # @param source_dataset [GDAL::Dataset, FFI::Pointer] The dataset to copy.
    # @param destination_path [String] The name for the new dataset file.
    # @param strict [Boolean] +false+ indicates the copy may adapt as needed for
    #   the output format.
    # @param options [Hash]
    # @param progress [Proc] For outputting copy progress.  Conforms to the
    #   FFI::GDAL::GDAL::GDALProgressFunc signature.
    def copy_dataset(source_dataset, destination_path, strict: true, **options, &progress)
      options_ptr = GDAL::Options.pointer(options)
      source_dataset_ptr = make_dataset_pointer(source_dataset)
      fail "Source dataset couldn't be read" if source_dataset_ptr.null?

      destination_dataset_ptr = FFI::GDAL::GDAL.GDALCreateCopy(
        @c_pointer,
        destination_path,
        source_dataset_ptr,
        strict,
        options_ptr,
        progress,
        nil
      )

      fail CreateFail if destination_dataset_ptr.null?

      dataset = Dataset.new(destination_dataset_ptr, 'w')
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
      FFI::GDAL::GDAL.GDALDeleteDataset(@c_pointer, file_name)
    end

    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def rename_dataset(new_name, old_name)
      FFI::GDAL::GDAL.GDALRenameDataset(@c_pointer, new_name, old_name)
    end

    private

    # @param [GDAL::Dataset, FFI::Pointer, String] dataset Can be another
    #   dataset, the pointer to another dataset, or the path to a dataset.
    # @return [GDAL::Dataset]
    def make_dataset_pointer(dataset)
      if dataset.is_a? GDAL::Dataset
        dataset.c_pointer
      elsif dataset.is_a? String
        GDAL::Dataset.open(dataset, 'r').c_pointer
      else
        dataset
      end
    end
  end
end

require_relative 'dataset'
