require 'ffi'

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
      return if nil_on_empty && hash.empty?

      new(hash).c_pointer
    end

    # Takes a GDAL options pointer and turns it into a Ruby Hash.
    #
    # @param pointer [FFI::Pointer]
    # @return [Hash]
    def self.to_hash(pointer)
      FFI::CPL::String.CSLCount(pointer).times.each_with_object({}) do |i, o|
        key_and_value = FFI::CPL::String.CSLGetField(pointer, i)
        key, value = key_and_value.split('=')
        o[key.downcase.to_sym] = value
      end
    end

    # @param hash [Hash] The hash of options to turn into a CPL key/value pair
    #   set.
    def initialize(hash = {})
      super()
      capitalize_keys!(hash)
    end

    # @return [FFI::MemoryPointer] The double-char pointer that contains the
    #   options for GDAL to use.
    def c_pointer
      options_ptr = FFI::MemoryPointer.new(:pointer, size)

      each do |key, value|
        options_ptr = FFI::CPL::String.CSLSetNameValue(options_ptr, key, value.to_s)
      end

      options_ptr
    end

    private

    def capitalize_keys!(hash)
      hash.each_with_object(self) do |(key, value), obj|
        obj[key.to_s.upcase] = value
      end
    end
  end
end
