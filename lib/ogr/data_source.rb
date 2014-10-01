require 'uri'
require_relative '../ffi/gdal'
require_relative '../ffi/ogr'
require_relative 'exceptions'
require_relative 'layer'
require_relative 'style_table'


module OGR
  class DataSource
    include FFI::GDAL
    FFI::GDAL.OGRRegisterAll

    # @param path [String] Path/URL to the file to open.
    # @param access_flag [String] 'r' for read, 'w', for write.
    # @return [OGR::DataSource]
    def self.open(path, access_flag = 'r')
      uri = URI.parse(path)
      file_path = uri.scheme.nil? ? ::File.expand_path(path) : path

      access_bool = case access_flag
      when 'w' then true
      when 'r' then false
      else raise "Invalid access_flag '#{access_flag}'.  Use 'r' or 'w'."
      end

      #driver = FFI::MemoryPointer.new(:pointer)
      #pointer = FFI::GDAL.OGROpen(file_path, access_bool, driver)
      pointer = FFI::GDAL.OGROpen(file_path, access_bool, nil)
      raise OGR::OpenFailure.new(file_path) if pointer.null?

      new(pointer)
    end

    # @param data_source_pointer [FFI::Pointer]
    def initialize(data_source_pointer)
      @ogr_data_source = data_source_pointer
      close_me = -> { self.close }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_data_source
    end

    # Name of the file represented by this object.
    #
    # @return [String]
    def name
      OGR_DS_GetName(@ogr_data_source)
    end

    # @return [Fixnum]
    def layer_count
      OGR_DS_GetLayerCount(@ogr_data_source)
    end

    # @param index [Fixnum] 0-offset index of the layer to retrieve.
    # @return [OGR::Layer]
    def layer(index)
      layer_pointer = OGR_DS_GetLayer(@ogr_data_source, index)

      OGR::Layer.new(ogr_layer_pointer: layer_pointer)
    end

    # @param name [String]
    # @return [OGR::Layer]
    def layer_by_name(name)
      layer_pointer = OGR_DS_GetLayerByName(@ogr_data_source, name)

      OGR::Layer.new(ogr_layer_pointer: layer_pointer)
    end

    # @return [OGR::StyleTable]
    def style_table
      style_table_ptr = OGR_DS_GetStyleTable(@ogr_data_source)

      OGR::StyleTable.new(ogr_style_table_pointer: style_table_ptr)
    end
  end
end
