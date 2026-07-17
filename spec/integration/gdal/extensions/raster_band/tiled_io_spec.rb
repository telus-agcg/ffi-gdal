# frozen_string_literal: true

require "ffi-gdal"
require "gdal"
require "gdal/extensions/all"

RSpec.describe "Tiled RasterBand IO extensions", type: :integration do
  subject(:raster_band) { dataset.raster_band(1) }

  # 380 wide x 765 tall, tiled 128x128, so block_count[:x] == 3.
  let(:tiled_tiff) do
    path = "../../../../../spec/support/images/osgeo/geotiff/zi_imaging/image0.tif"
    File.expand_path(path, __dir__)
  end

  let(:dataset) { GDAL::Dataset.open(tiled_tiff, "r") }

  # Canonical full-band read in row-major order, used to verify pixel ordering
  # (not just shape) against the block-stitching implementation.
  let(:reference) do
    pointer = raster_band.raster_io("r")
    pixel_count = raster_band.x_size * raster_band.y_size
    GDAL._read_pointer(pointer, raster_band.data_type, pixel_count).each_slice(raster_band.x_size).to_a
  end

  after { dataset.close }

  it "reads a tiled band with more than one x-block" do
    expect(raster_band.block_count[:x]).to be > 1
  end

  describe "#to_na" do
    it "returns an NArray whose shape matches the band's x/y sizes" do
      expect(raster_band.to_na.shape).to eq([380, 765])
    end

    it "orders pixels the same as a canonical full-band read" do
      expect(raster_band.to_na).to eq(NArray.to_na(reference))
    end
  end

  describe "#read_lines_by_block" do
    it "yields one full-width row per raster line" do
      lines = raster_band.read_lines_by_block.to_a

      expect(lines.size).to eq(765)
      expect(lines.map(&:size).uniq).to eq([380])
    end

    it "stitches x-blocks into rows matching a canonical full-band read" do
      expect(raster_band.read_lines_by_block.to_a).to eq(reference)
    end
  end
end
