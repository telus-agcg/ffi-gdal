# frozen_string_literal: true

module GDAL
  module Utils
    class Info
      # Ruby wrapper for GDALInfoOptions C API (options for gdalinfo utility).
      #
      # @see GDAL::Utils::Info
      # @see https://gdal.org/programs/gdalinfo.html gdalinfo utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALInfoOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALInfoOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/gdalinfo.html
        #   List of available options could be found in gdalinfo utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::Info::Options.new(options: ["-json", "-mdd", "all"])
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
          ::FFI::GDAL::Utils.GDALInfoOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
