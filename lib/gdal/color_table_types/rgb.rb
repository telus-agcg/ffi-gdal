module GDAL
  module ColorTableTypes
    module RGB
      def reds
        all_entries_for :c1
      end

      def greens
        all_entries_for :c2
      end

      def blues
        all_entries_for :c3
      end

      def alphas
        all_entries_for :c4
      end

      def to_a
        NMatrix[reds, greens, blues, alphas].transpose.to_a
      end
    end
  end
end
