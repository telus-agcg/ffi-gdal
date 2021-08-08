# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRFieldDefnH

      attach_function :OGR_Fld_Create, [:string, FFI::OGR::Core::FieldType], :OGRFieldDefnH
      attach_function :OGR_Fld_Destroy, %i[OGRFieldDefnH], :void
      attach_function :OGR_Fld_SetName, %i[OGRFieldDefnH string], :void
      attach_function :OGR_Fld_GetNameRef, %i[OGRFieldDefnH], :string
      attach_function :OGR_Fld_GetType, %i[OGRFieldDefnH], FFI::OGR::Core::FieldType
      attach_function :OGR_Fld_SetType, [:OGRFieldDefnH, FFI::OGR::Core::FieldType], :void
      attach_function :OGR_Fld_GetJustify, %i[OGRFieldDefnH], FFI::OGR::Core::Justification
      attach_function :OGR_Fld_SetJustify, [:OGRFieldDefnH, FFI::OGR::Core::Justification], :void
      attach_function :OGR_Fld_GetWidth, %i[OGRFieldDefnH], :int
      attach_function :OGR_Fld_SetWidth, %i[OGRFieldDefnH int], :void
      attach_function :OGR_Fld_GetPrecision, %i[OGRFieldDefnH], :int
      attach_function :OGR_Fld_SetPrecision, %i[OGRFieldDefnH int], :void

      attach_function :OGR_Fld_Set,
                      [:OGRFieldDefnH, :string, FFI::OGR::Core::FieldType, :int, :int,
                       FFI::OGR::Core::Justification],
                      :void
      attach_function :OGR_Fld_IsIgnored, %i[OGRFieldDefnH], :bool
      attach_function :OGR_Fld_SetIgnored, %i[OGRFieldDefnH bool], :void
    end
  end
end
