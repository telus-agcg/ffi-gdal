# frozen_string_literal: true

require 'ffi'
require 'ffi/library'

module FFI
  # Wrapping #attach_function so we can avoid bombing out if a called method
  # is not defined.
  module FFILibraryFunctionChecks
    def attach_gdal_function(func, args, returns, **options)
      raise "Must specify return type for function '#{func}'" if returns.nil?

      attach_function(func, args, returns, options)
    rescue TypeError
      puts "func: #{func}"
      puts "args: #{args}"
      puts "arg count: #{args.length}"
      puts "returns: #{returns}"
      raise
    rescue FFI::NotFoundError
      @unsupported_gdal_functions ||= []

      if $VERBOSE || ENV['VERBOSE']
        warn "ffi-gdal warning: function '#{args&.first}' is not available in this " \
          "build of GDAL/OGR (v#{FFI::GDAL.GDALVersionInfo('RELEASE_NAME')})"
      end

      @unsupported_gdal_functions << args&.first if args&.first
    end

    def unsupported_gdal_functions
      @unsupported_gdal_functions ||= []
    end
  end
end

FFI::Library.include(FFI::FFILibraryFunctionChecks)
