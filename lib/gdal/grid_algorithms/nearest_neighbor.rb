# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class NearestNeighbor < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridNearestNeighborOptions
      end

      def c_identifier
        :GGA_NearestNeighbor
      end
    end
  end
end
