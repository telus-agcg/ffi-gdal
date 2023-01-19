# frozen_string_literal: true

require "gdal"

RSpec.describe GDAL::Dataset::RasterBandMethods do
  include_context "A .tif Dataset"

  describe ".valid_min_buffer_size" do
    it "returns the number of bytes for the GDT type * x buffer size * y buffer size" do
      expect(described_class.valid_min_buffer_size(:GDT_Float32, 3, 4)).to eq 48
    end
  end

  describe ".parse_mask_flag_symbols" do
    context "empty params" do
      it "returns 0" do
        expect(described_class.parse_mask_flag_symbols(nil)).to eq 0
      end
    end

    context ":GMF_ALL_VALID" do
      it "returns 1" do
        expect(described_class.parse_mask_flag_symbols(:GMF_ALL_VALID)).to eq 1
      end
    end

    context ":GMF_ALL_VALID, :GMF_NODATA" do
      it "returns 1" do
        expect(described_class.parse_mask_flag_symbols(:GMF_ALL_VALID, :GMF_NODATA)).to eq 9
      end
    end
  end

  describe "#raster_x_size" do
    it "returns an Integer" do
      expect(subject.raster_x_size).to eq 101
    end
  end

  describe "#raster_y_size" do
    it "returns an Integer" do
      expect(subject.raster_y_size).to eq 101
    end
  end

  describe "#raster_count" do
    it "returns an Integer" do
      expect(subject.raster_count).to eq 1
    end
  end

  describe "#raster_band" do
    it "returns a GDAL::RasterBand" do
      expect(subject.raster_band(1)).to be_a GDAL::RasterBand
    end
  end

  describe "#add_band" do
    it "raises a GDAL::UnsupportedOperation" do
      expect { subject.add_band(:GDT_Byte) }.to raise_exception(GDAL::UnsupportedOperation)
    end
  end

  describe "#create_mask_band" do
    context "no flags given" do
      it "returns nil" do
        expect(subject.create_mask_band(0)).to be_nil
      end
    end
  end
end
