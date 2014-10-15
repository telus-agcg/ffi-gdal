module GDAL
  module ColorTableTypes
    module HLS
      def hues
        all_entries_for :c1
      end

      def lightnesses
        all_entries_for :c2
      end

      def saturations
        all_entries_for :c3
      end

      def to_a
        NArray[hues, lightnesses, saturations].rot90(3).to_a
      end
    end
  end
end
