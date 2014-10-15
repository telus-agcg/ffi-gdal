module FFI
  module GDAL

    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    callback :GDALGridFunction,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    attach_function :GDALGridInverseDistanceToAPower,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    # attach_function :GDALGridInverseDistanceToAPointerNoSearch,
    #   %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
    #   CPLErr

    attach_function :GDALGridMovingAverage,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr

    attach_function :GDALGridNearestNeighbor,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr

    attach_function :GDALGridDataMetricMinimum,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    attach_function :GDALGridDataMetricMaximum,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    attach_function :GDALGridDataMetricRange,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    attach_function :GDALGridDataMetricCount,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    attach_function :GDALGridDataMetricAverageDistance,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    attach_function :GDALGridDataMetricAverageDistancePts,
      %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
      CPLErr
    attach_function :ParseAlgorithmAndOptions,
      [:string, GDALGridAlgorithm, :pointer],
      CPLErr
  end
end
