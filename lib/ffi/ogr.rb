# frozen_string_literal: true

require_relative '../ffi-gdal'

module FFI
  module OGR
    extend FFI::InternalHelpers

    autoload :API,               autoload_path('ffi/ogr/api.rb')
    autoload :Core,              autoload_path('ffi/ogr/core.rb')
    autoload :ContourWriterInfo, autoload_path('ffi/ogr/contour_writer_info.rb')
    autoload :Envelope,          autoload_path('ffi/ogr/envelope.rb')
    autoload :Envelope3D,        autoload_path('ffi/ogr/envelope_3d.rb')
    autoload :Featurestyle,      autoload_path('ffi/ogr/featurestyle.rb')
    autoload :Field,             autoload_path('ffi/ogr/field.rb')
    autoload :Geocoding,         autoload_path('ffi/ogr/geocoding.rb')
    autoload :SRSAPI,            autoload_path('ffi/ogr/srs_api.rb')
    autoload :StyleParam,        autoload_path('ffi/ogr/style_param.rb')
    autoload :StyleValue,        autoload_path('ffi/ogr/style_value.rb')
  end
end
