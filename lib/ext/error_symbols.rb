require_relative '../gdal/exceptions'


class ::Symbol

  # When FFI interfaces with a GDAL CPLError, it returns a Symbol that
  # maps to the CPLErr enum (see GDAL's cpl_error.h or cpl_error.rb docs). Since
  # many of the GDAL C API's functions return these symbols _and_ because the
  # symbols have some functional implications, this wrapping here is simply for
  # returning Ruby-esque values when the GDAL API returns one of these symbols.
  #
  # The optional params let you override behavior.  Passing in a block instead
  # will call the block.  Ex.
  #
  #   cpl_err = GDALCopyDatasetFiles(@gdal_driver_handle, new_name, old_name)
  #   cpl_err.to_ruby      # returns the default value
  #   cpl_err.to_ruby { raise 'Crap!' }
  def to_ruby(none: :none, debug: :debug, warning: :warning, failure: :failure, fatal: :fatal)
    case self
    when :CE_None then none
    when :CE_Debug then debug
    when :CE_Warning then warning
    when :CE_Failure then failure
    when :CE_Fatal then fatal
    when :OGRERR_NONE then none
    when :OGRERR_NOT_ENOUGH_DATA then fail(OGR::NotEnoughData)
    when :OGRERR_NOT_ENOUGH_MEMORY then fail(OGR::NotEnoughMemory)
    when :OGRERR_UNSUPPORTED_GEOMETRY_TYPE then fail(OGR::UnsupportedGeometryType)
    when :OGRERR_UNSUPPORTED_OPERATION then fail(OGR::UnsupportedOperation)
    when :OGRERR_CORRUPT_DATA then fail(OGR::CorruptData)
    when :OGRERR_FAILURE then fail(OGR::Failure)
    when :OGRERR_UNSUPPORTED_SRS then fail(OGR::UnsupportedSRS)
    when :OGRERR_INVALID_HANDLE then fail(OGR::InvalidHandle)
    else
      raise "Unknown CPLErr/OGRErr type: #{self}"
    end
  end

  def to_bool
    case self
    when :CE_None then true
    when :CE_Debug then true
    when :CE_Warning then false
    when :CE_Failure then raise GDAL::CPLErrFailure
    when :CE_Fatal then raise GDAL::CPLErrFailure
    when :OGRERR_NONE then true
    when :OGRERR_NOT_ENOUGH_DATA then fail(OGR::NotEnoughData)
    when :OGRERR_NOT_ENOUGH_MEMORY then fail(OGR::NotEnoughMemory)
    when :OGRERR_UNSUPPORTED_GEOMETRY_TYPE then fail(OGR::UnsupportedGeometryType)
    when :OGRERR_UNSUPPORTED_OPERATION then fail(OGR::UnsupportedOperation)
    when :OGRERR_CORRUPT_DATA then fail(OGR::CorruptData)
    when :OGRERR_FAILURE then fail(OGR::Failure)
    when :OGRERR_UNSUPPORTED_SRS then fail(OGR::UnsupportedSRS)
    when :OGRERR_INVALID_HANDLE then fail(OGR::InvalidHandle)
    else
      raise "Unknown CPLError type: #{self}"
    end
  end
end
