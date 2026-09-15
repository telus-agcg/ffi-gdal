# frozen_string_literal: true

require "gdal/driver"
require "gdal/extensions/raster_band/extensions"

RSpec.describe "GDAL::RasterBand::Extensions" do
  subject(:raster_band) { dataset_byte.raster_band(1) }

  let(:driver) { GDAL::Driver.by_name("MEM") }
  let(:dataset_byte) { driver.create_dataset("test", 15, 25, data_type: :GDT_Byte) }

  let(:values_dataset) { driver.create_dataset("values_test", 3, 2, data_type: :GDT_Byte) }
  let(:values_band) { values_dataset.raster_band(1) }
  let(:band_rows) do
    [
      [0, 1, 2],
      [3, 4, 5]
    ]
  end

  describe "#to_a" do
    subject { raster_band.to_a }

    it { is_expected.to eq(Array.new(25, Array.new(15, 0))) }
  end

  describe "#to_na" do
    context "no conversion" do
      subject { raster_band.to_na }

      it { is_expected.to eq(NArray.byte(15, 25)) }
    end

    context "convert to Int16" do
      subject { raster_band.to_na(:GDT_Int16) }

      it { is_expected.to eq(NArray.sint(15, 25)) }
    end

    context "convert to UInt16" do
      subject { raster_band.to_na(:GDT_UInt16) }

      it { is_expected.to eq(NArray.int(15, 25)) }
    end

    context "convert to Int32" do
      subject { raster_band.to_na(:GDT_Int32) }

      it { is_expected.to eq(NArray.int(15, 25)) }
    end

    context "convert to UInt32" do
      subject { raster_band.to_na(:GDT_UInt32) }

      it { is_expected.to eq(NArray.int(15, 25)) }
    end

    context "convert to Float32" do
      subject { raster_band.to_na(:GDT_Float32) }

      it { is_expected.to eq(NArray.sfloat(15, 25)) }
    end

    context "convert to Float64" do
      subject { raster_band.to_na(:GDT_Float64) }

      it { is_expected.to eq(NArray.float(15, 25)) }
    end

    context "convert to CInt16" do
      subject { raster_band.to_na(:GDT_CInt16) }

      it { is_expected.to eq(NArray.scomplex(15, 25)) }
    end

    context "convert to CInt32" do
      subject { raster_band.to_na(:GDT_CInt32) }

      it { is_expected.to eq(NArray.scomplex(15, 25)) }
    end

    context "convert to CFloat32" do
      subject { raster_band.to_na(:GDT_CFloat32) }

      it { is_expected.to eq(NArray.scomplex(15, 25)) }
    end

    context "convert to CFloat64" do
      subject { raster_band.to_na(:GDT_CFloat64) }

      it { is_expected.to eq(NArray.complex(15, 25)) }
    end

    context "with distinct pixel values" do
      subject(:result) { values_band.to_na }

      before { values_band.write_xy_narray(band_rows) }

      it "returns an NArray shaped [x, y]" do
        expect(result).to eq(
          NArray[
            [0, 1, 2],
            [3, 4, 5]
          ]
        )
      end

      it "is indexed as [x, y]" do
        expect(result.shape).to eq([3, 2])
        expect(result[1, 0]).to eq(1)
        expect(result[2, 1]).to eq(5)
      end

      it "nests #to_a as the written rows" do
        expect(result.to_a).to eq(
          [
            [0, 1, 2],
            [3, 4, 5]
          ]
        )
      end

      # NArray.to_na infers the type from the Ruby integers rather than from
      # the band's data type, so even without a conversion a byte band comes
      # back as int.
      it "returns int for a byte band" do
        expect(result.typecode).to eq(NArray::INT)
      end
    end
  end

  describe "#to_nna" do
    subject(:result) { raster_band.to_nna }

    it "returns a Numo array shaped [y, x]" do
      expect(result).to eq(Numo::Int32.zeros(25, 15))
    end

    # Numo::NArray[*rows] infers the element type from the Ruby integers
    # rather than from the band's data type, so a byte band comes back Int32.
    # (Numo's == compares values across types, so the class needs its own
    # assertion.)
    it "infers Int32 for a byte band" do
      expect(result.class).to eq(Numo::Int32)
    end

    context "with distinct pixel values" do
      subject(:result) { values_band.to_nna }

      before { values_band.write_xy_narray(band_rows) }

      it "returns a Numo::NArray shaped [y, x]" do
        expect(result).to eq(
          Numo::Int32.cast(
            [
              [0, 1, 2],
              [3, 4, 5]
            ]
          )
        )
      end

      it "is indexed as [y, x]" do
        expect(result.shape).to eq([2, 3])
        expect(result[0, 1]).to eq(1)
        expect(result[1, 2]).to eq(5)
      end

      it "nests #to_a as the written rows" do
        expect(result.to_a).to eq(
          [
            [0, 1, 2],
            [3, 4, 5]
          ]
        )
      end

      # Numo::NArray[*rows] infers the element type from the Ruby integers
      # rather than from the band's data type, so a byte band comes back
      # Int32.
      it "infers Int32 for a byte band" do
        expect(result.class).to eq(Numo::Int32)
      end
    end
  end

  describe "#projected_points" do
    subject(:result) { projected_band.projected_points }

    let(:projected_dataset) do
      driver.create_dataset("projected_points_test", 3, 2, data_type: data_type).tap do |dataset|
        geo_transform = GDAL::GeoTransform.new
        geo_transform.x_origin = 100.5
        geo_transform.pixel_width = 10.0
        geo_transform.y_origin = 200.25
        geo_transform.pixel_height = -10.0
        dataset.geo_transform = geo_transform
      end
    end
    let(:projected_band) { projected_dataset.raster_band(1) }

    context "byte band" do
      let(:data_type) { :GDT_Byte }

      # Coordinates are stored in an array typed after the band's pixel data
      # type, so an integer band truncates the fractional projected
      # coordinates (100.5 -> 100).
      it "returns truncated coordinates nested [line][pixel][coord]" do
        expect(result).to eq(
          NArray[
            [
              [100, 200],
              [110, 200],
              [120, 200]
            ],
            [
              [100, 190],
              [110, 190],
              [120, 190]
            ]
          ]
        )
        expect(result.typecode).to eq(NArray::BYTE)
      end

      it "is indexed as [coord, x, y]" do
        expect(result.shape).to eq([2, 3, 2])
        expect(result[0, 1, 0]).to eq(110)
        expect(result[1, 0, 1]).to eq(190)
      end
    end

    context "double band" do
      let(:data_type) { :GDT_Float64 }

      it "returns exact projected coordinates" do
        expect(result).to eq(
          NArray[
            [
              [100.5, 200.25],
              [110.5, 200.25],
              [120.5, 200.25]
            ],
            [
              [100.5, 190.25],
              [110.5, 190.25],
              [120.5, 190.25]
            ]
          ]
        )
        expect(result.typecode).to eq(NArray::DFLOAT)
      end
    end
  end
end
