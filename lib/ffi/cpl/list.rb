# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    class List < ::FFI::Struct
      layout :data, :pointer,
             :next, List.ptr

      module ListFunctions
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          extend ::FFI::Library
          @ffi_libs = FFI::GDAL.loaded_ffi_libs

          #-------------------------------------------------------------------
          # Functions
          #-------------------------------------------------------------------
          attach_gdal_function :CPLListAppend, [List.ptr, :pointer], List.ptr
          attach_gdal_function :CPLListInsert, [List.ptr, :pointer, :int], List.ptr
          attach_gdal_function :CPLListGetLast, [List.ptr], List.ptr
          attach_gdal_function :CPLListGet, [List.ptr, :int], List.ptr
          attach_gdal_function :CPLListCount, [List.ptr], :int

          attach_gdal_function :CPLListRemove, [List.ptr, :int], List.ptr
          attach_gdal_function :CPLListDestroy, [List.ptr], :void

          attach_gdal_function :CPLListGetNext, [List.ptr], List.ptr
          attach_gdal_function :CPLListGetData, [List.ptr], :pointer
        end
      end

      include ListFunctions
    end
  end
end
