# frozen_string_literal: true

module GDAL
  module Utils
    class Warp
      # Ruby wrapper for GDALWarpAppOptions C API (options for ogr2ogr utility).
      #
      # @see GDAL::Utils::Warp
      # @see https://gdal.org/programs/gdalwarp.html gdalwarp utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALWarpAppOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALWarpAppOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/gdalwarp.html
        #   List of available options could be found in gdalwarp utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::Warp::Options.new(options: ["-multi", "-wo", "CUTLINE_ALL_TOUCHED=TRUE"])
        #
        # @param options [Array<String>] The options list.
        def initialize(options: [])
          @options = options
          @string_list = ::GDAL::Utils::Helpers::StringList.new(strings: options)
          @c_pointer = AutoPointer.new(options_pointer)
        end

        private

        attr_reader :string_list

        def options_pointer
          ::FFI::GDAL::Utils.GDALWarpAppOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
