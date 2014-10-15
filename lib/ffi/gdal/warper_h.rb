module FFI
  module GDAL
    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    typedef :pointer, :GDALWarpOperationH
    callback :GDALMaskFunc,
      [:pointer, :int, FFI::GDAL::GDALDataType, :int, :int, :int, :int, :pointer, :int, :pointer],
      :pointer

    #------------------------------------------------------------------------
    # Enums
    #------------------------------------------------------------------------
    GDALResampleAlg = enum :GRA_NearestNeighbor, 0,
      :GRA_Bilinear, 1,
      :GRA_Cubic, 2,
      :GRA_CubicSpline, 3,
      :GRA_Lanczos, 4,
      :GRA_Average, 5,
      :GRA_Mode, 6

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    attach_function :GDALCreateWarpOptions, [], FFI::GDAL::GDALWarpOptions.ptr
    attach_function :GDALSerializeWarpOptions,
      [FFI::GDAL::GDALWarpOptions.ptr],
      FFI::GDAL::CPLXMLNode.ptr

    attach_function :GDALCreateWarpOperation,
      [FFI::GDAL::GDALWarpOptions.ptr],
      :GDALWarpOperationH
    attach_function :GDALDestroyWarpOperation, [:GDALWarpOperationH], :void

    attach_function :GDALChunkAndWarpImage,
      %i[GDALWarpOperationH int int int int],
      CPLErr
    attach_function :GDALChunkAndWarpMulti,
      %i[GDALWarpOperationH int int int int],
      CPLErr
    attach_function :GDALWarpRegion,
      %i[GDALWarpOperationH int int int int int int int int],
      CPLErr
    attach_function :GDALWarpRegionToBuffer,
      [:GDALWarpOperationH, :int, :int, :int, :int, :pointer, GDALDataType, :int, :int, :int, :int],
      CPLErr
  end
end
