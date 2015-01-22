require_relative '../gdal/exceptions'
require_relative '../ogr/exceptions'


class ::Symbol

  # When FFI interfaces with a GDAL CPLError, it returns a Symbol that
  # maps to the CPLErr enum (see GDAL's cpl_error.h or cpl_error.rb docs). Since
  # many of the GDAL C API's functions return these symbols _and_ because the
  # symbols have some functional implications, this wrapping here is simply for
  # returning Ruby-esque values when the GDAL API returns one of these symbols.
  #
  # The optional params let you override behavior.
  def to_ruby(fail_msg=nil, none: :none, debug: :debug, warning: :warning, failure: :failure, fatal: :fatal)
    case self
    when :CE_None then none
    when :CE_Debug then debug
    when :CE_Warning then warning
    when :CE_Failure then failure
    when :CE_Fatal then fatal
    when :OGRERR_NONE then none
    when :OGRERR_NOT_ENOUGH_DATA then fail(OGR::NotEnoughData, fail_msg)
    when :OGRERR_NOT_ENOUGH_MEMORY then fail(OGR::NotEnoughMemory, fail_msg)
    when :OGRERR_UNSUPPORTED_GEOMETRY_TYPE then fail(OGR::UnsupportedGeometryType, fail_msg)
    when :OGRERR_UNSUPPORTED_OPERATION then fail(OGR::UnsupportedOperation, fail_msg)
    when :OGRERR_CORRUPT_DATA then fail(OGR::CorruptData, fail_msg)
    when :OGRERR_FAILURE then fail(OGR::Failure, fail_msg)
    when :OGRERR_UNSUPPORTED_SRS then fail(OGR::UnsupportedSRS, fail_msg)
    when :OGRERR_INVALID_HANDLE then fail(OGR::InvalidHandle, fail_msg)
    else
      fail "Unknown CPLErr/OGRErr type: #{self}"
    end
  end

  def to_bool(fail_msg=nil)
    case self
    when :CE_None then true
    when :CE_Debug then true
    when :CE_Warning then false
    when :CE_Failure then fail GDAL::CPLErrFailure, fail_msg
    when :CE_Fatal then fail GDAL::CPLErrFailure, fail_msg
    when :OGRERR_NONE then true
    when :OGRERR_NOT_ENOUGH_DATA then fail(OGR::NotEnoughData, fail_msg)
    when :OGRERR_NOT_ENOUGH_MEMORY then fail(OGR::NotEnoughMemory, fail_msg)
    when :OGRERR_UNSUPPORTED_GEOMETRY_TYPE then fail(OGR::UnsupportedGeometryType, fail_msg)
    when :OGRERR_UNSUPPORTED_OPERATION then fail(OGR::UnsupportedOperation, fail_msg)
    when :OGRERR_CORRUPT_DATA then fail(OGR::CorruptData, fail_msg)
    when :OGRERR_FAILURE then fail(OGR::Failure, fail_msg)
    when :OGRERR_UNSUPPORTED_SRS then fail(OGR::UnsupportedSRS, fail_msg)
    when :OGRERR_INVALID_HANDLE then fail(OGR::InvalidHandle, fail_msg)
    else
      fail "Unknown CPLError type: #{self}"
    end
  end
end
