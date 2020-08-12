# frozen_string_literal: true

require 'ffi'

module GDAL
  # A wrapper for the way GDAL does key/value pair options for methods.
  class Options
    # Shortcut for if you just want to build the options and get the pointer to
    # them.
    #
    # @param hash [Hash]
    # @return [FFI::MemoryPointer, nil]
    def self.pointer(hash)
      return if hash.empty?

      options_ptr = FFI::MemoryPointer.new(:pointer)
      options_ptr.autorelease = false

      hash.each do |key, value|
        # Note, we started off with a MemoryPointer above, but this returns a
        # new FFI::Pointer.
        options_ptr = FFI::CPL::String.CSLAddNameValue(options_ptr, key.to_s.upcase, value.to_s)
      end

      FFI::AutoPointer.new(options_ptr, lambda do |ptr|
        FFI::CPL::String.CSLDestroy(ptr)
      end)
    end

    # Takes a GDAL options pointer and turns it into a Ruby Hash.
    #
    # @param pointer [FFI::Pointer]
    # @return [Hash]
    def self.to_hash(pointer)
      # Docs say passing a null pointer here is ok; will result in 0.
      count = FFI::CPL::String.CSLCount(pointer)

      return {} if count.zero?

      count.times.each_with_object({}) do |i, o|
        # Docs say that the pointer return from CSLGetField shouldn't be freed.
        key_and_value = FFI::CPL::String.CSLGetField(pointer, i)
        key, value = key_and_value.split('=')
        o[key.downcase.to_sym] = value
      end
    end
  end
end
