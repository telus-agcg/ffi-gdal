# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    # Base abstract class for all grid algorithms.
    class AlgorithmBase
      # @return Options object.
      attr_reader :options

      def initialize
        @options = options_class.new
        assign_size_of_structure
      end

      # @return [Class] Options class.
      def options_class
        # This method must be overridden in subclasses.
      end

      # @return [Symbol] C identifier for the algorithm.
      def c_identifier
        # This method must be overridden in subclasses.
      end

      private

      def assign_size_of_structure
        # Starting GDAL 3.6.0 we must assign nSizeOfStructure to the size of the structure.
        return unless @options.members.include?(:n_size_of_structure)

        @options[:n_size_of_structure] = @options.size
      end
    end
  end
end
