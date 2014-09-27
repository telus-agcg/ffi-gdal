module FFI
  module GDAL

    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    typedef :pointer, :OGRGeometryH
    typedef :pointer, :OGRSpatialReferenceH
    typedef :pointer, :OGRCoordinateTransformationH
    typedef :pointer, :OGRFieldDefnH
    typedef :pointer, :OGRFeatureDefnH
    typedef :pointer, :OGRFeatureH
    typedef :pointer, :OGRStyleTableH
    typedef :pointer, :OGRGeomFieldDefnH
    typedef :pointer, :OGRLayerH
    typedef :pointer, :OGRDataSourceH
    typedef :pointer, :OGRSFDriverH
    typedef :pointer, :OGRStyleMgrH
    typedef :pointer, :OGRStyleToolH
  end
end
