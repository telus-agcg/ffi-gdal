module GDAL
  class DataType
    # The size in bits.
    #
    # @param gdal_data_type [FFI::GDAL::GDAL::DataType]
    # @return [Fixnum]
    def self.size(gdal_data_type)
      FFI::GDAL::GDAL.GDALGetDataTypeSize(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::GDAL::DataType]
    # @return [Fixnum]
    def self.complex?(gdal_data_type)
      FFI::GDAL::GDAL.GDALDataTypeIsComplex(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::GDAL::DataType]
    # @return [String]
    def self.name(gdal_data_type)
      FFI::GDAL::GDAL.GDALGetDataTypeName(gdal_data_type)
    end

    # The data type's symbolic name.
    #
    # @param name [String]
    # @return [FFI::GDAL::GDAL::DataType]
    def self.by_name(name)
      FFI::GDAL::GDAL.GDALGetDataTypeByName(name.to_s)
    end

    # @param gdal_data_type1 [FFI::GDAL::GDAL::DataType]
    # @param gdal_data_type2 [FFI::GDAL::GDAL::DataType]
    # @return [FFI::GDAL::GDAL::DataType]
    def self.union(gdal_data_type1, gdal_data_type2)
      FFI::GDAL::GDAL.GDALDataTypeUnion(gdal_data_type1, gdal_data_type2)
    end
  end
end
