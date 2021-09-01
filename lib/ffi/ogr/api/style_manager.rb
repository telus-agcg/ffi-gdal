# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRStyleMgrH

      # ~~~~~~~~~~~~~~~~
      # Style Manager-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_SM_Create, %i[OGRStyleTableH], :OGRStyleMgrH
      attach_function :OGR_SM_Destroy, %i[OGRStyleMgrH], :void

      attach_function :OGR_SM_InitFromFeature, %i[OGRStyleMgrH OGRFeatureH], :string
      attach_function :OGR_SM_InitStyleString, %i[OGRStyleMgrH string], :bool

      attach_function :OGR_SM_GetPartCount, %i[OGRStyleMgrH pointer], :int
      attach_function :OGR_SM_GetPart,
                      %i[OGRStyleMgrH int pointer],
                      :OGRStyleToolH

      attach_function :OGR_SM_AddPart, %i[OGRStyleMgrH OGRStyleToolH], :int
      attach_function :OGR_SM_AddStyle, %i[OGRStyleMgrH string string], :int
    end
  end
end
