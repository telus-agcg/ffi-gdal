class Float
  # Converts a packed DMS value (DDDMMMSSS.SS) into decimal degress.
  #
  # @return [Float]
  def to_decimal_degress
    FFI::GDAL.GDALPackedDMSToDec(self)
  end

  # Converts decimal degress int a packed DMS value (DDDMMMSSS.SS).
  #
  # @return [Float]
  def to_dms
    FFI::GDAL.GDALDecToPackedDMS(self)
  end
end
