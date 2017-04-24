# frozen_string_literal: true

require_relative 'exceptions'

module OGR
  # OGR returns errors as Integers--not as part of the GDAL/CPLErr error
  # handling callback interface.  This hacks together a facility for sort of
  # doing that with OGR.
  #
  # Unlike the OGR API, ffi-gdal defines an Enum for the OGRERR types, which
  # in turns causes OGR to return Symbols on errors (the #defines for those can
  # be found here: http://www.gdal.org/ogr__core_8h.html).  This maps those
  # Symbols to Ruby exceptions (or lack thereof).  The sad part of this
  # solution is that any function that returns an OGRErr needs to assign that
  # Symbol to a variable, then call #handle_result to get that
  # Symbol-to-Exception mapping to take place.
  module ErrorHandling
    def handle_result(msg = nil)
      error_class_map(self).call(msg)
    end

    private

    # @param [Symbol] error_class
    # @return [Proc]
    def error_class_map(error_class)
      {
        OGRERR_NONE: proc { true },
        OGRERR_NOT_ENOUGH_DATA: ->(msg) { raise_exception(OGR::NotEnoughData, msg) },
        OGRERR_NOT_ENOUGH_MEMORY: ->(msg) { raise_exception(::NoMemoryError, msg) },
        OGRERR_UNSUPPORTED_GEOMETRY_TYPE: ->(msg) { raise_exception(OGR::UnsupportedGeometryType, msg) },
        OGRERR_UNSUPPORTED_OPERATION: ->(msg) { raise_exception(OGR::UnsupportedOperation, msg) },
        OGRERR_CORRUPT_DATA: ->(msg) { raise_exception(OGR::CorruptData, msg) },
        OGRERR_FAILURE: ->(msg) { raise_exception(OGR::Failure, msg) },
        OGRERR_UNSUPPORTED_SRS: ->(msg) { raise_exception(OGR::UnsupportedSRS, msg) },
        OGRERR_INVALID_HANDLE: ->(msg) { raise_exception(OGR::InvalidHandle, msg) }
      }.fetch(error_class) { raise "Unknown OGRERR type: #{self}" }
    end

    # Exists solely to strip off the top 4 lines of the backtrace so it doesn't
    # look like the problem is coming from here.
    def raise_exception(exception, message)
      e = exception.new(message)
      e.set_backtrace(caller(4))
      raise(e)
    end
  end
end
