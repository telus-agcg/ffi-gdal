require 'ffi'


module FFI
  module GDAL
    class GDALTransformerInfo < FFI::Struct
      layout :signature, :string,
        :class_name, :string,
        :transform, :GDALTransformerFunc,
        :cleanup, :pointer,
        :serialize, :pointer
    end
  end
end
