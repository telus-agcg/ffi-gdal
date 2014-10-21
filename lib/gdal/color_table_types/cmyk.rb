module GDAL
  module ColorTableTypes
    module CMYK
      def cyans
        all_entries_for :c1
      end

      def magentas
        all_entries_for :c2
      end

      def yellows
        all_entries_for :c3
      end

      def blacks
        all_entries_for :c4
      end

      def to_a
        NMatrix[cyans, magentas, yellows, blacks].transpose.to_a
      end
    end
  end
end
