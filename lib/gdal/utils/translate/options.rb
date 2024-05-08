# frozen_string_literal: true

module GDAL
  module Utils
    class Translate
      # Ruby wrapper for GDALTranslateOptions C API (options for gdal_translate utility).
      #
      # @see GDAL::Utils::Translate
      # @see https://gdal.org/programs/gdal_translate.html gdal_translate utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALTranslateOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALTranslateOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/gdal_translate.html
        #   List of available options could be found in gdal_translate utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::Translate::Options.new(options: ["-of", "GTiff", "-co", "COMPRESS=DEFLATE"])
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
          ::FFI::GDAL::Utils.GDALTranslateOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
