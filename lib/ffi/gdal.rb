require 'ffi'
require 'ffi/tools/const_generator'

module FFI
  module GDAL
    extend ::FFI::Library

    def self.search_paths
      @search_paths ||= begin
        return if ENV['GDAL_LIBRARY_PATH']

        if FFI::Platform.windows?
          ENV['PATH'].split(File::PATH_SEPARATOR)
        else
          %w[/usr/local/{lib64,lib} /opt/local/{lib64,lib} /usr/{lib64,lib} /usr/lib/{x86_64,i386}-linux-gnu]
        end
      end
    end

    def self.find_lib(lib)
      if ENV['GDAL_LIBRARY_PATH'] && File.file?(ENV['GDAL_LIBRARY_PATH'])
        ENV['GDAL_LIBRARY_PATH']
      else
        Dir.glob(search_paths.map do |path|
          File.expand_path(File.join(path, "#{lib}.#{FFI::Platform::LIBSUFFIX}"))
        end).first
      end
    end

    def self.gdal_library_path
      return @gdal_library_path if @gdal_library_path

      @gdal_library_path = find_lib('{lib,}gdal*')
    end

    # @return [Array<String>] Related files that contain C constants.
    def self._files_with_constants
      header_files = %w[
        cpl_conv.h cpl_error.h cpl_port.h cpl_string.h cpl_vsi.h
        gdal.h gdal_alg.h gdal_vrt.h gdalwarper.h
        ogr_core.h ogr_srs_api.h
      ]

      header_search_paths = %w[/usr/local/include /usr/include]

      header_files.map do |file|
        dir = header_search_paths.find do |d|
          File.exist?("#{d}/#{file}")
        end
        dir ? "#{dir}/#{file}" : nil
      end.compact
    end

    # Locates one of the files that has constants.
    #
    # @return [String] Full path to +file_name+.
    def self._file_with_constants(file_name)
      _files_with_constants.find { |f| f.end_with?(file_name) }
    end

    ffi_lib(gdal_library_path)

    attach_function :GDALVersionInfo, %i[string], :string
    attach_function :GDALCheckVersion, %i[int int string], :bool
  end
end

require_relative 'cpl/conv'
require_relative 'gdal/gdal'
require_relative 'gdal/version'
require_relative '../ext/to_bool'
