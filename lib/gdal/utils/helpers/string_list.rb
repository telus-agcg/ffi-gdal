# frozen_string_literal: true

module GDAL
  module Utils
    module Helpers
      # A basic wrapper for CPLStringList (e.g. char **papszArgv).
      #
      # @private
      # @note This class is intended only to be used internally in ffi-gdal. It's API may change.
      #   Do not use this class directly.
      class StringList
        class AutoPointer < ::FFI::AutoPointer
          # @param pointer [FFI::Pointer]
          def self.release(pointer)
            return unless pointer && !pointer.null?

            ::FFI::CPL::String.CSLDestroy(pointer)
          end
        end

        # @return [FFI::Pointer] C pointer to CPLStringList (e.g. char **papszArgv).
        attr_reader :c_pointer

        # @return [Array<String>] Strings in the list.
        attr_reader :strings

        # @param strings [Array<String>] Strings to build the list.
        def initialize(strings: [])
          @strings = strings
          @c_pointer = AutoPointer.new(string_list_pointer)
        end

        private

        def string_list_pointer
          pointer = ::FFI::Pointer.new(FFI::Pointer::NULL)

          strings.each do |string|
            pointer = ::FFI::CPL::String.CSLAddString(pointer, string.to_s)
          end

          pointer
        end
      end
    end
  end
end
