# frozen_string_literal: true

require "gdal"

RSpec.describe GDAL::Dataset::InternalFunctions do
  describe ".band_numbers_args" do
    context "param is nil" do
      it "returns no pointer and 0 band count" do
        pointer, count = described_class.band_numbers_args(nil)

        expect(pointer.size).to eq 0
        expect(pointer.type_size).to eq FFI::NativeType::INT32.size
        expect(count).to be_zero
      end
    end

    context "param is an array of numbers" do
      it "returns a pointer and the number of bands" do
        result_ptr, band_count = described_class.band_numbers_args([3, 4, 5])
        expect(result_ptr).to be_a FFI::MemoryPointer
        expect(band_count).to eq 3
      end
    end
  end
end
