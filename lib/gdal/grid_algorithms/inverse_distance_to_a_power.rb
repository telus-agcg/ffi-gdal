# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class InverseDistanceToAPower < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridInverseDistanceToAPowerOptions
      end

      def c_identifier
        :GGA_InverseDistanceToAPower
      end
    end
  end
end
