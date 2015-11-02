module GDAL
  module GridTypes
    class InverseDistanceToAPower
      # @return [FFI::GDAL::GridInverseDistanceToAPowerOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridInverseDistanceToAPowerOptions.new
      end

      # @return [Symbol]
      def algorithm
        :GGA_InverseDistanceToAPower
      end
    end
  end
end
