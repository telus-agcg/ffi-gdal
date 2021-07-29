# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class TransformerInfo < FFI::Struct
      layout :signature, :string,
             :class_name, :string,
             :transform, FFI::GDAL::Alg.find_type(:GDALTransformerFunc),
             :cleanup, :pointer,
             :serialize, :pointer
    end
  end
end
