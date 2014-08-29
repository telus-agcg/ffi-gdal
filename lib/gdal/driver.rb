require_relative '../ffi/gdal'
require_relative 'major_object'
require 'multi_xml'


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

    # @param file_path [String] File to get the driver for.
    # @param name [String] Name of the registered GDALDriver.
    # @param index [Fixnum] Index of the registered driver.  Must be less than
    #   GDAL::Driver.driver_count.
    # @param dataset [FFI::Pointer] Pointer to the GDALDataset.
    def initialize(file_path: file_path, name: name, index: index, dataset: dataset)
      @gdal_driver_handle = if file_path
        GDALIdentifyDriver(::File.expand_path(file_path), nil)
      elsif name
        GDALGetDriverByName(name)
      elsif index
        count = self.class.driver_count
        raise "index must be between 0 and #{count - 1}." if index > count

        GDALGetDriver(index)
      elsif dataset
        GDALGetDatasetDriver(dataset)
      end
    end

    def c_pointer
      @gdal_driver_handle
    end

    # @return [String]
    def short_name
      return '' unless @gdal_driver_handle

      GDALGetDriverShortName(@gdal_driver_handle)
    end

    # @return [String]
    def long_name
      return '' unless @gdal_driver_handle

      GDALGetDriverLongName(@gdal_driver_handle)
    end

    # @return [String]
    def help_topic
      return '' unless @gdal_driver_handle

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
    # @return true on success, false on warning.
    # @raise [GDAL::CPLErrFailure] If failures.
    def copy_dataset_files(destination, source)
      cpl_err = GDALCopyDatasetFiles(@gdal_driver_handle, destination, source)

      cpl_err.to_ruby
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
    def create_dataset(filename, x_size, y_size, bands: 1, type: :GDT_Byte, **options, &block)
      log "creating dataset with size #{x_size},#{y_size}"

      dataset_pointer = GDALCreate(@gdal_driver_handle,
        filename,
        x_size,
        y_size,
        bands,
        type,
        nil
      )

      raise CreateFail if dataset_pointer.null?

      dataset = Dataset.new(dataset_pointer)
      block.call(dataset) if block_given?
      dataset.close

      dataset
    end
  end
end
