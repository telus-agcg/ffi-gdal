# frozen_string_literal: true

require 'ffi'
require_relative 'ext/ffi_library_function_checks'
require_relative 'ext/narray_ext'
require_relative 'ext/numeric_as_data_type'
require_relative 'ext/float_ext'

module FFI
  module InternalHelpers
    def autoload_path(relative_path)
      File.expand_path(relative_path, __dir__ || '.')
    end
  end

  extend FFI::InternalHelpers

  autoload :CPL, autoload_path('ffi/cpl.rb')
  autoload :GDAL, autoload_path('ffi/gdal.rb')
  autoload :OGR, autoload_path('ffi/ogr.rb')
end
