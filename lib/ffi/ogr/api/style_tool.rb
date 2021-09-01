# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRStyleToolH

      # ~~~~~~~~~~~~~~~~
      # Style Tool-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_ST_Create, [FFI::OGR::Core::STClassId], :OGRStyleToolH
      attach_function :OGR_ST_Destroy, %i[OGRStyleToolH], :void

      attach_function :OGR_ST_GetType, %i[OGRStyleToolH], FFI::OGR::Core::STClassId

      attach_function :OGR_ST_GetUnit, %i[OGRStyleToolH], FFI::OGR::Core::STUnitId
      attach_function :OGR_ST_SetUnit, [:OGRStyleToolH, FFI::OGR::Core::STUnitId, :double], :void

      attach_function :OGR_ST_GetParamStr, %i[OGRStyleToolH int pointer], :string
      attach_function :OGR_ST_GetParamNum, %i[OGRStyleToolH int pointer], :int
      attach_function :OGR_ST_GetParamDbl, %i[OGRStyleToolH int pointer], :double
      attach_function :OGR_ST_SetParamStr, %i[OGRStyleToolH int string], :void
      attach_function :OGR_ST_SetParamNum, %i[OGRStyleToolH int int], :void
      attach_function :OGR_ST_SetParamDbl, %i[OGRStyleToolH int double], :void

      attach_function :OGR_ST_GetStyleString, %i[OGRStyleToolH], :string
      attach_function :OGR_ST_GetRGBFromString,
                      %i[OGRStyleToolH string pointer pointer pointer pointer],
                      :bool
    end
  end
end
