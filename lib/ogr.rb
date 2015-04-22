require_relative 'ffi/ogr'
require_relative 'ogr/internal_helpers'

module OGR
  include InternalHelpers

  FFI::OGR::API.OGRRegisterAll
end
