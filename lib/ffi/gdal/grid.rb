# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module GDAL
    module Grid
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      callback :GDALGridFunction,
               [
                 :pointer,
                 FFI::CPL::Port.find_type(:GUInt32),
                 :pointer,
                 :pointer,
                 :pointer,
                 :double,
                 :double,
                 :pointer,
                 :pointer
               ],
               FFI::CPL::Error.enum_type(:CPLErr)

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_gdal_function :GDALGridInverseDistanceToAPower,
                           [
                             :pointer,
                             FFI::CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridInverseDistanceToAPointerNoSearch,
                           [
                             :pointer,
                             FFI::CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridMovingAverage,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridNearestNeighbor,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridDataMetricMinimum,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridDataMetricMaximum,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridDataMetricRange,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridDataMetricCount,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridDataMetricAverageDistance,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALGridDataMetricAverageDistancePts,
                           [
                             :pointer,
                             CPL::Port.find_type(:GUInt32),
                             :pointer,
                             :pointer,
                             :pointer,
                             :double,
                             :double,
                             :pointer,
                             :pointer
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :ParseAlgorithmAndOptions,
                           [:string, FFI::GDAL::Alg.enum_type(:GridAlgorithm), :pointer],
                           FFI::CPL::Error.enum_type(:CPLErr)
    end
  end
end
