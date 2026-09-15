# frozen_string_literal: true

require "gdal/driver"
require "gdal/extensions/dataset/extensions"
require "gdal/extensions/raster_band/extensions"
require "gdal/extensions/raster_band/io_extensions"

RSpec.describe "GDAL::Dataset::Extensions" do
  let(:driver) { GDAL::Driver.by_name("MEM") }
  let(:dataset) { driver.create_dataset("test", 3, 2, band_count: 3, data_type: :GDT_Byte) }

  # Three 3x2 bands; pixel (x, y) of band i holds (y * 3 + x) + (i * 100), so
  # every band/x/y combination is distinguishable in the stacked result.
  let(:band_values) do
    [
      [
        [0, 1, 2],
        [3, 4, 5]
      ],
      [
        [100, 101, 102],
        [103, 104, 105]
      ],
      [
        [200, 201, 202],
        [203, 204, 205]
      ]
    ]
  end

  before do
    dataset.raster_bands.each_with_index do |band, i|
      band.write_xy_narray(band_values.fetch(i))
    end
  end

  describe "#to_na" do
    context "no conversion" do
      subject(:result) { dataset.to_na }

      # The nested representation is band-major with x/y swapped relative to
      # the band rows written above: result.to_a is [band][x][y], NOT the
      # per-pixel band-value tuples the previous doc example claimed.
      it "stacks bands into a [band][x][y]-nested NArray" do
        expect(result).to eq(
          NArray[
            [
              [0, 3],
              [1, 4],
              [2, 5]
            ],
            [
              [100, 103],
              [101, 104],
              [102, 105]
            ],
            [
              [200, 203],
              [201, 204],
              [202, 205]
            ]
          ]
        )
      end

      it "is indexed as [y, x, band]" do
        expect(result.shape).to eq([2, 3, 3])
        expect(result[0, 1, 1]).to eq(101)
        expect(result[1, 2, 2]).to eq(205)
      end

      it "reads one pixel's band values as result[y, x, true]" do
        expect(result[0, 1, true].to_a).to eq([1, 101, 201])
        expect(result[1, 2, true].to_a).to eq([5, 105, 205])
      end

      # Relative to the written band data ([band][row][pixel]), the nested
      # representation keeps the band-major grouping but transposes each
      # band's rows and pixels.
      it "nests #to_a as the written bands with rows and pixels transposed" do
        expect(result.to_a).to eq(
          [
            [
              [0, 3],
              [1, 4],
              [2, 5]
            ],
            [
              [100, 103],
              [101, 104],
              [102, 105]
            ],
            [
              [200, 203],
              [201, 204],
              [202, 205]
            ]
          ]
        )
      end

      it "upcasts byte bands to int through the NMatrix intermediate" do
        expect(result.typecode).to eq(NArray::INT)
      end
    end

    context "convert to Float32" do
      subject(:result) { dataset.to_na(:GDT_Float32) }

      it "converts each band before stacking" do
        expect(result).to eq(
          NArray[
            [
              [0.0, 3.0],
              [1.0, 4.0],
              [2.0, 5.0]
            ],
            [
              [100.0, 103.0],
              [101.0, 104.0],
              [102.0, 105.0]
            ],
            [
              [200.0, 203.0],
              [201.0, 204.0],
              [202.0, 205.0]
            ]
          ]
        )
      end

      # GDT_Float32 maps to NArray::FLOAT, which narray aliases to DFLOAT, so a
      # single-precision request comes back double-precision.
      it "widens the requested Float32 to double" do
        expect(result.typecode).to eq(NArray::DFLOAT)
      end
    end
  end
end
