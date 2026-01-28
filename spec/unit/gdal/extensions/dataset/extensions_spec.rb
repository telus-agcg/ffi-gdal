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

      it "stacks each band's pixels into per-pixel band-value tuples" do
        expect(result).to eq(
          Numo::UInt8.cast(
            [
              [
                [0, 100, 200],
                [1, 101, 201],
                [2, 102, 202]
              ],
              [
                [3, 103, 203],
                [4, 104, 204],
                [5, 105, 205]
              ]
            ]
          )
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
      # representation regroups each pixel's band values into one tuple.
      it "nests #to_a as the written bands regrouped into per-pixel tuples" do
        expect(result.to_a).to eq(
          [
            [
              [0, 100, 200],
              [1, 101, 201],
              [2, 102, 202]
            ],
            [
              [3, 103, 203],
              [4, 104, 204],
              [5, 105, 205]
            ]
          ]
        )
      end

      # Numo's == compares values across types, so the preserved band data
      # type needs its own assertion.
      it "preserves the bands' byte data type" do
        expect(result.class).to eq(Numo::UInt8)
      end
    end

    context "convert to Float32" do
      subject(:result) { dataset.to_na(:GDT_Float32) }

      it "converts each band before stacking" do
        expect(result).to eq(
          Numo::SFloat.cast(
            [
              [
                [0.0, 100.0, 200.0],
                [1.0, 101.0, 201.0],
                [2.0, 102.0, 202.0]
              ],
              [
                [3.0, 103.0, 203.0],
                [4.0, 104.0, 204.0],
                [5.0, 105.0, 205.0]
              ]
            ]
          )
        )
      end

      # A Float32 request now returns true single precision, where narray
      # aliased FLOAT to double.
      it "returns the requested data type" do
        expect(result.class).to eq(Numo::SFloat)
      end
    end
  end
end
