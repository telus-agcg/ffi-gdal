require 'ffi'

module FFI
  module GDAL
    class OGRStyleParam < FFI::Struct
      layout :param, :int,
        :token, :string,
        :georef, :GBool,
        :type, OGRSType
    end
  end
end
