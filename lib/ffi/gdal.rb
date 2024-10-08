# frozen_string_literal: true

require "ffi"
require "ffi/tools/const_generator"
require_relative "gdal/exceptions"
require_relative "../ext/ffi_library_function_checks"

module FFI
  module GDAL
    extend ::FFI::Library

    autoload :Alg, File.expand_path("gdal/alg.rb", __dir__)
    autoload :ColorEntry, File.expand_path("gdal/color_entry.rb", __dir__)
    autoload :GDAL, File.expand_path("gdal/gdal.rb", __dir__)
    autoload :GCP, File.expand_path("gdal/gcp.rb", __dir__)
    autoload :Grid, File.expand_path("gdal/grid.rb", __dir__)
    autoload :GridDataMetricsOptions, File.expand_path("gdal/grid_data_metrics_options.rb", __dir__)
    autoload :GridInverseDistanceToAPowerOptions,
             File.expand_path("gdal/grid_inverse_distance_to_a_power_options.rb", __dir__)
    autoload :GridMovingAverageOptions, File.expand_path("gdal/grid_moving_average_options.rb", __dir__)
    autoload :GridNearestNeighborOptions, File.expand_path("gdal/grid_nearest_neighbor_options.rb", __dir__)
    autoload :InternalHelpers, File.expand_path("gdal/internal_helpers.rb", __dir__)
    autoload :Matching, File.expand_path("gdal/matching.rb", __dir__)
    autoload :RPCInfo, File.expand_path("gdal/rpc_info.rb", __dir__)
    autoload :TransformerInfo, File.expand_path("gdal/transformer_info.rb", __dir__)
    autoload :Utils, File.expand_path("gdal/utils.rb", __dir__)
    autoload :VRT, File.expand_path("gdal/vrt.rb", __dir__)
    autoload :Warper, File.expand_path("gdal/warper.rb", __dir__)
    autoload :WarpOptions, File.expand_path("gdal/warp_options.rb", __dir__)

    # @return [String]
    def self.gdal_library_path
      @gdal_library_path ||= ENV.fetch("GDAL_LIBRARY_PATH", "gdal")
    end

    # @return [Array<String>] Related files that contain C constants.
    def self._files_with_constants
      header_files = %w[
        cpl_conv.h cpl_error.h cpl_port.h cpl_string.h cpl_vsi.h
        gdal.h gdal_alg.h gdal_vrt.h gdalwarper.h
        ogr_core.h ogr_srs_api.h
      ]

      header_search_paths = %w[/usr/local/include /usr/include /usr/include/gdal /opt/homebrew/include/]

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

    if gdal_library_path.nil? || gdal_library_path.empty?
      raise FFI::GDAL::LibraryNotFound, "Can't find required gdal library using path: '#{gdal_library_path}'"
    end

    ffi_lib(gdal_library_path)

    attach_function :GDALVersionInfo, %i[string], :string
    attach_function :GDALCheckVersion, %i[int int string], :bool
  end
end

require_relative "gdal/version"
require_relative "../ext/to_bool"
