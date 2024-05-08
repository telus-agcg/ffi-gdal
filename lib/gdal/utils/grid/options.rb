# frozen_string_literal: true

module GDAL
  module Utils
    class Grid
      # Ruby wrapper for GDALGridOptions C API (options for gdal_grid utility).
      #
      # @see GDAL::Utils::Grid
      # @see https://gdal.org/programs/gdal_grid.html gdal_grid utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALGridOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALGridOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/gdal_grid.html
        #   List of available options could be found in gdal_grid utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::Grid::Options.new(options: ["-of", "GTiff", "-outsize", "10", "10"])
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
          ::FFI::GDAL::Utils.GDALGridOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
