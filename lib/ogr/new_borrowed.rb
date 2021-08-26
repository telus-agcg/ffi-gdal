# frozen_string_literal: true

module OGR
  module NewBorrowed
    # Use for instantiating a self from a borrowed pointer (one that shouldn't
    # be freed).
    #
    # @param c_pointer [String, FFI::Pointer]
    # @return [self.class]
    # @raise [FFI::GDAL::InvalidPointer] if +c_pointer+ is null.
    def new_borrowed(c_pointer)
      raise FFI::GDAL::InvalidPointer if c_pointer.null?

      c_pointer.autorelease = false

      new(c_pointer).freeze
    end
  end
end
