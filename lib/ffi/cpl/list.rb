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
          attach_function :CPLListAppend, [List.ptr, :pointer], List.ptr
          attach_function :CPLListInsert, [List.ptr, :pointer, :int], List.ptr
          attach_function :CPLListGetLast, [List.ptr], List.ptr
          attach_function :CPLListGet, [List.ptr, :int], List.ptr
          attach_function :CPLListCount, [List.ptr], :int

          attach_function :CPLListRemove, [List.ptr, :int], List.ptr
          attach_function :CPLListDestroy, [List.ptr], :void

          attach_function :CPLListGetNext, [List.ptr], List.ptr
          attach_function :CPLListGetData, [List.ptr], :pointer
        end
      end

      include ListFunctions
    end
  end
end
