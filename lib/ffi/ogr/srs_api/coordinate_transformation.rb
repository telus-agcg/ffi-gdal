# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module SRSAPI
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRCoordinateTransformationH

      attach_function :OCTNewCoordinateTransformation,
                      %i[OGRSpatialReferenceH OGRSpatialReferenceH],
                      :OGRCoordinateTransformationH

      attach_function :OCTDestroyCoordinateTransformation,
                      %i[OGRCoordinateTransformationH],
                      :void

      attach_function :OCTTransform,
                      %i[OGRCoordinateTransformationH int pointer pointer pointer],
                      :bool
      attach_function :OCTTransformEx,
                      %i[OGRCoordinateTransformationH int pointer pointer pointer pointer],
                      :bool
    end
  end
end
