require_relative '../ffi/gdal'
require 'multi_xml'


module GDAL
  class Driver
    include FFI::GDAL

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
      FFI::GDAL.GDALAllRegister

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
  end
end
