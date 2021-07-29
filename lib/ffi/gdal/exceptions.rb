# frozen_string_literal: true

module FFI
  module GDAL
    class LibraryNotFound < RuntimeError
    end

    class InvalidPointer < RuntimeError
    end
  end
end
