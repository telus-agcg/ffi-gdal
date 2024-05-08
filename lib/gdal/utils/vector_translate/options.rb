# frozen_string_literal: true

module GDAL
  module Utils
    class VectorTranslate
      # Ruby wrapper for GDALVectorTranslateOptions C API (options for ogr2ogr utility).
      #
      # @see GDAL::Utils::VectorTranslate
      # @see https://gdal.org/programs/ogr2ogr.html ogr2ogr utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALVectorTranslateOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALVectorTranslateOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/ogr2ogr.html
        #   List of available options could be found in ogr2ogr utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::VectorTranslate::Options.new(options: ["-overwrite", "-nlt", "MULTIPOLYGON"])
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
          ::FFI::GDAL::Utils.GDALVectorTranslateOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
