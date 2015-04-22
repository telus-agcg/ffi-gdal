require 'ffi'
require_relative '../ffi/cpl/string'

module GDAL
  # A wrapper for the way GDAL does key/value pair options for methods.
  class Options < Hash
    # Shortcut for if you just want to build the options and get the pointer to
    # them.
    #
    # @param hash [Hash]
    # @param nil_on_empty [Boolean] When +true+, if +hash+ is empty, return
    #   +nil+.  If +false+, creates a 0-size pointer.
    # @return [FFI::MemoryPointer, nil]
    def self.pointer(hash, nil_on_empty: true)
      if nil_on_empty
        hash.empty? ? nil : new(hash).c_pointer
      else
        new(hash).c_pointer
      end
    end

    def initialize(hash = {})
      super()
      capitalize_keys!(hash)
    end

    # @return [FFI::MemoryPointer] The double-char pointer that contains the
    #   options for GDAL to use.
    def c_pointer
      options_ptr = FFI::MemoryPointer.new(:pointer, size)

      each do |key, value|
        options_ptr = FFI::CPL::String.CSLSetNameValue(options_ptr, key, value)
      end

      options_ptr
    end

    # def to_s
    #   options_ptr = to_gdal
    #   options_array = options_ptr.read_array_of_pointer(self.size)
    #
    #   0.upto(self.size).map do |i|
    #     options_array[i].first.read_string
    #   end
    # end

    private

    def capitalize_keys!(hash)
      hash.each_with_object(self) do |(key, value), obj|
        obj[key.to_s.upcase] = value
      end
    end
  end
end
