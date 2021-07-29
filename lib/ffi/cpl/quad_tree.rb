# frozen_string_literal: true

require 'ffi'
require_relative 'rect_obj'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module QuadTree
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #-------------------------------------------------------------------------
      # Typedefs
      #-------------------------------------------------------------------------
      callback :CPLQuadTreeGetBoundsFunc, [:pointer, RectObj.ptr], :void
      callback :CPLQuadTreeForeachFunc, %i[pointer pointer], :int
      callback :CPLQuadTreeDumpFeatureFunc, %i[pointer int pointer], :void

      # Taking liberties here...
      typedef :pointer, :CPLQuadTreeH

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_gdal_function :CPLQuadTreeCreate,
                           [FFI::CPL::RectObj.ptr, :CPLQuadTreeGetBoundsFunc],
                           :CPLQuadTreeH
      attach_gdal_function :CPLQuadTreeDestroy, %i[CPLQuadTreeH], :void
      attach_gdal_function :CPLQuadTreeSetBucketCapacity,
                           %i[CPLQuadTreeH int],
                           :void
      attach_gdal_function :CPLQuadTreeGetAdvisedMaxDepth, %i[int], :int
      attach_gdal_function :CPLQuadTreeSetMaxDepth, %i[CPLQuadTreeH int], :void
      attach_gdal_function :CPLQuadTreeInsert, %i[CPLQuadTreeH pointer], :void
      attach_gdal_function :CPLQuadTreeInsertWithBounds,
                           [:CPLQuadTreeH, :pointer, FFI::CPL::RectObj.ptr],
                           :void
      attach_gdal_function :CPLQuadTreeSearch,
                           [:CPLQuadTreeH, FFI::CPL::RectObj.ptr, :pointer],
                           :void
      attach_gdal_function :CPLQuadTreeForeach,
                           %i[CPLQuadTreeH CPLQuadTreeForeachFunc pointer],
                           :void
      attach_gdal_function :CPLQuadTreeDump,
                           %i[CPLQuadTreeH CPLQuadTreeDumpFeatureFunc pointer],
                           :void
      attach_gdal_function :CPLQuadTreeGetStats,
                           %i[CPLQuadTreeH pointer pointer pointer pointer],
                           :void
    end
  end
end
