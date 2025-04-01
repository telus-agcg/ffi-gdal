# frozen_string_literal: true

module GDAL
  module Utils
    class Footprint
      # Ruby wrapper for GDALFootprintOptions C API (options for gdal_footprint utility).
      #
      # @see GDAL::Utils::Footprint
      # @see https://gdal.org/programs/gdal_footprint.html gdal_footprint utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALFootprintOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALFootprintOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/gdal_footprint.html
        #   List of available options could be found in gdal_footprint utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::Footprint::Options.new(options: ["-srcnodata", "0", "-t_srs", "EPSG:4326"])
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
          ::FFI::GDAL::Utils.GDALFootprintOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
