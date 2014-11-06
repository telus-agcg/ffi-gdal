module GDAL
  class DataType
    # The size in bits.
    #
    # @param gdal_data_type [FFI::GDAL::GDALDataType]
    # @return [Fixnum]
    def self.size(gdal_data_type)
      FFI::GDAL.GDALGetDataTypeSize(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::GDALDataType]
    # @return [Fixnum]
    def self.complex?(gdal_data_type)
      FFI::GDAL.GDALDataTypeIsComplex(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::GDALDataType]
    # @return [String]
    def self.name(gdal_data_type)
      FFI::GDAL.GDALGetDataTypeName(gdal_data_type)
    end

    # The data type's symbolic name.
    #
    # @param name [String]
    # @return [FFI::GDAL::GDALDataType]
    def self.by_name(name)
      FFI::GDAL.GDALGetDataTypeByName(name)
    end

    # @param gdal_data_type1 [FFI::GDAL::GDALDataType]
    # @param gdal_data_type2 [FFI::GDAL::GDALDataType]
    # @return [FFI::GDAL::GDALDataType]
    def self.union(gdal_data_type1, gdal_data_type2)
      FFI::GDAL.GDALDataTypeUnion(gdal_data_type1, gdal_data_type2)
    end
  end
end
