# frozen_string_literal: true

module GDAL
  module Utils
    class DEM
      # Ruby wrapper for GDALDEMProcessingOptions C API (options for gdaldem utility).
      #
      # @see GDAL::Utils::DEM
      # @see https://gdal.org/programs/gdaldem.html gdaldem utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALDEMProcessingOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALDEMProcessingOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/gdaldem.html
        #   List of available options could be found in gdaldem utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::DEM::Options.new(options: ["-of", "GTiff", "-co", "COMPRESS=DEFLATE"])
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
          ::FFI::GDAL::Utils.GDALDEMProcessingOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
