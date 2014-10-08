require 'ffi'

module FFI
  module GDAL
    extend ::FFI::Library

    autoload :GDALColorEntry,
      File.expand_path('gdal/gdal_color_entry', __dir__)
    autoload :GDALGCP,
      File.expand_path('gdal/gdal_gcp', __dir__)
    autoload :GDALGridDataMetricsOptions,
      File.expand_path('gdal/gdal_grid_data_metrics_options', __dir__)
    autoload :GDALGridInverseDistanceToAPowerOptions,
      File.expand_path('gdal/gdal_grid_inverse_distance_to_a_power_options', __dir__)
    autoload :GDALGridMovingAverageOptions,
      File.expand_path('gdal/gdal_grid_moving_average_options', __dir__)
    autoload :GDALGridNearestNeighborOptions,
      File.expand_path('gdal/gdal_grid_nearest_neighbor_options', __dir__)
    autoload :GDALRPCInfo,
      File.expand_path('gdal/gdal_rpc_info', __dir__)
    autoload :GDALTransformerInfo,
      File.expand_path('gdal/gdal_transformer_info', __dir__)

    autoload :OGRContourWriterInfo,
      File.expand_path('ogr/ogr_contour_writer_info', __dir__)
    autoload :OGREnvelope,
      File.expand_path('ogr/ogr_envelope', __dir__)
    autoload :OGREnvelope3D,
      File.expand_path('ogr/ogr_envelope_3d', __dir__)
    autoload :OGRField,
      File.expand_path('ogr/ogr_field', __dir__)
    autoload :OGRStyleParam,
      File.expand_path('ogr/ogr_style_param', __dir__)
    autoload :OGRStyleValue,
      File.expand_path('ogr/ogr_style_value', __dir__)

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

    ffi_lib(gdal_library_path)
  end
end

require_relative 'gdal/version'
require_relative 'cpl/conv_h'
require_relative 'cpl/error_h'
require_relative 'cpl/minixml_h'
require_relative 'cpl/string_h'
require_relative 'cpl/vsi_h'
require_relative '../ext/to_bool'

require_relative 'gdal/gdal_h'
