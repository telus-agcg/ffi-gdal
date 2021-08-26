# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRStyleTableH

      # ~~~~~~~~~~~~~~~~
      # Style Table-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_STBL_Create, [], :OGRStyleTableH
      attach_function :OGR_STBL_Destroy, %i[OGRStyleTableH], :void
      attach_function :OGR_STBL_AddStyle, %i[OGRStyleTableH string string], :bool
      attach_function :OGR_STBL_SaveStyleTable, %i[OGRStyleTableH string], :bool
      attach_function :OGR_STBL_LoadStyleTable, %i[OGRStyleTableH string], :bool
      attach_function :OGR_STBL_Find, %i[OGRStyleTableH string], :string
      attach_function :OGR_STBL_ResetStyleStringReading, %i[OGRStyleTableH], :void
      attach_function :OGR_STBL_GetNextStyle, %i[OGRStyleTableH], :string
      attach_function :OGR_STBL_GetLastStyleName, %i[OGRStyleTableH], :string
    end
  end
end
