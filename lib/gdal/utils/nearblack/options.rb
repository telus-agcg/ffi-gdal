# frozen_string_literal: true

module GDAL
  module Utils
    class Nearblack
      # Ruby wrapper for GDALNearblackOptions C API (options for nearblack utility).
      #
      # @see GDAL::Utils::Nearblack
      # @see https://gdal.org/programs/nearblack.html nearblack utility documentation.
      class Options
        # @private
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::GDAL::Utils.GDALNearblackOptionsFree(pointer)
          end
        end

        # @return [AutoPointer] C pointer to the GDALNearblackOptions.
        attr_reader :c_pointer

        # @return [Array<String>] The options.
        attr_reader :options

        # Create a new instance.
        #
        # @see https://gdal.org/programs/nearblack.html
        #   List of available options could be found in nearblack utility documentation.
        #
        # @example Create a new instance.
        #  options = GDAL::Utils::Nearblack::Options.new(options: ["-of", "GTiff", "-near", "10"])
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
          ::FFI::GDAL::Utils.GDALNearblackOptionsNew(string_list.c_pointer, nil)
        end
      end
    end
  end
end
