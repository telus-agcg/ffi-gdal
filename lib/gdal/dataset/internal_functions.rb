# frozen_string_literal: true

module GDAL
  class Dataset
    module InternalFunctions
      # Makes a pointer of +band_numbers+.
      #
      # @param band_numbers [Array<Integer>]
      # @return [Array<FFI::MemoryPointer, Integer>]
      def self.band_numbers_args(band_numbers)
        band_count = band_numbers&.size || 0
        ptr = FFI::MemoryPointer.new(:int, band_count)

        ptr.write_array_of_int(band_numbers) if band_numbers

        ptr.autorelease = false

        [ptr, band_count]
      end
    end
  end
end
