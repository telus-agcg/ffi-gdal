# frozen_string_literal: true

require "gdal/driver"
require "gdal/extensions/raster_band/extensions"

RSpec.describe "GDAL::RasterBand::IOExtensions" do
  let(:driver) { GDAL::Driver.by_name("MEM") }
  let(:dataset_byte) { driver.create_dataset("test", 15, 25, data_type: :GDT_Byte) }
  let(:dataset_int8) { driver.create_dataset("test", 15, 25, data_type: :GDT_Int8) }
  let(:dataset_uint16) { driver.create_dataset("test", 15, 25, data_type: :GDT_UInt16) }
  let(:dataset_int16) { driver.create_dataset("test", 15, 25, data_type: :GDT_Int16) }
  let(:dataset_uint32) { driver.create_dataset("test", 15, 25, data_type: :GDT_UInt32) }
  let(:dataset_int32) { driver.create_dataset("test", 15, 25, data_type: :GDT_Int32) }
  let(:dataset_uint64) { driver.create_dataset("test", 15, 25, data_type: :GDT_UInt64) }
  let(:dataset_int64) { driver.create_dataset("test", 15, 25, data_type: :GDT_Int64) }
  let(:dataset_float32) { driver.create_dataset("test", 15, 25, data_type: :GDT_Float32) }
  let(:dataset_float64) { driver.create_dataset("test", 15, 25, data_type: :GDT_Float64) }

  subject(:raster_band) { dataset_byte.raster_band(1) }

  describe "#write_xy_narray" do
    let(:dataset) { driver.create_dataset("test dataset", 64, 4) }
    let(:raster_band) { dataset.raster_band 1 }

    it "writes pixels from the NArray" do
      row0 = Array.new(64) { 1 }
      row1 = Array.new(64) { 2 }
      row2 = Array.new(64) { 3 }
      row3 = Array.new(64) { 4 }
      narray = NArray[row0, row1, row2, row3]

      raster_band.write_xy_narray(narray)

      pixels = raster_band.to_na
      expect(pixels[true, 0]).to eq(NArray.to_na(row0))
      expect(pixels[true, 1]).to eq(NArray.to_na(row1))
      expect(pixels[true, 2]).to eq(NArray.to_na(row2))
      expect(pixels[true, 3]).to eq(NArray.to_na(row3))
    end
  end

  describe "#set_pixel_value/#pixel_value" do
    context "valid values, GDT_Byte" do
      subject { dataset_byte.raster_band(1) }

      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, 123)
        expect(subject.pixel_value(0, 0)).to eq(123)
      end
    end

    context "valid values, GDT_Int8" do
      subject { dataset_int8.raster_band(1) }

      it "sets and gets the value successfully" do
        skip "This spec only for GDAL 3.7+" if GDAL.version_num < "3070000"

        subject.set_pixel_value(0, 0, -128)
        expect(subject.pixel_value(0, 0)).to eq(-128)
      end
    end

    context "valid values, GDT_UInt16" do
      subject { dataset_uint16.raster_band(1) }

      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, 32_123)
        expect(subject.pixel_value(0, 0)).to eq(32_123)
      end
    end

    context "valid values, GDT_Int16" do
      subject { dataset_int16.raster_band(1) }

      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, -12_345)
        expect(subject.pixel_value(0, 0)).to eq(-12_345)
      end
    end

    context "valid values, GDT_UInt32" do
      subject { dataset_uint32.raster_band(1) }

      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, 4_123_456_789)
        expect(subject.pixel_value(0, 0)).to eq(4_123_456_789)
      end
    end

    context "valid values, GDT_Int32" do
      subject { dataset_int32.raster_band(1) }

      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, -123_456_789)
        expect(subject.pixel_value(0, 0)).to eq(-123_456_789)
      end
    end

    context "valid values, GDT_UInt64" do
      subject { dataset_uint64.raster_band(1) }

      it "sets and gets the value successfully" do
        skip "This spec only for GDAL 3.5+" if GDAL.version_num < "3050000"

        subject.set_pixel_value(0, 0, 18_446_744_073_709_551_615)
        expect(subject.pixel_value(0, 0)).to eq(18_446_744_073_709_551_615)
      end
    end

    context "valid values, GDT_Int64" do
      subject { dataset_int64.raster_band(1) }

      it "sets and gets the value successfully" do
        skip "This spec only for GDAL 3.5+" if GDAL.version_num < "3050000"

        subject.set_pixel_value(0, 0, -9_223_372_036_854_775_808)
        expect(subject.pixel_value(0, 0)).to eq(-9_223_372_036_854_775_808)
      end
    end

    context "valid values, GDT_Float32" do
      subject { dataset_float32.raster_band(1) }

      # For some reason, precision of float32 values isn't there past a couple
      # decimals when reading back.
      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, -123.456)
        expect(subject.pixel_value(0, 0)).to be_within(0.001).of(-123.456)
      end
    end

    context "valid values, GDT_Float64" do
      subject { dataset_float64.raster_band(1) }

      it "sets and gets the value successfully" do
        subject.set_pixel_value(0, 0, -123_456_789_101.456)
        expect(subject.pixel_value(0, 0)).to eq(-123_456_789_101.456)
      end
    end
  end

  describe "#block_count" do
    it "returns a Hash of relevant values" do
      expect(subject.block_count).to eq(
        x: 1,
        x_remainder: 0,
        y: 25,
        y_remainder: 0
      )
    end
  end

  describe "#block_buffer_size" do
    subject { raster_band.block_buffer_size }
    it { is_expected.to eq(15) }
  end

  describe "#read_lines_by_block" do
    context "block size is larger than the raster" do
      let(:rows) { (1..4).map { |i| Array.new(15) { i } } }

      let(:dataset_path) do
        filename = "/tmp/#{SecureRandom.uuid}.tif"
        options = { BLOCKXSIZE: 256, BLOCKYSIZE: 256, TILED: "YES" }
        GDAL::Driver.by_name("GTiff").create_dataset(filename, 15, 4, **options) do |dataset|
          dataset.raster_band(1).write_xy_narray(NArray.to_na(rows))
        end
        filename
      end

      after { FileUtils.rm_f(dataset_path) }

      let(:dataset) { GDAL::Dataset.open(dataset_path, "r") }

      subject { dataset.raster_band(1) }

      it "yields all block rows with correct values" do
        expect { |b| subject.read_lines_by_block(&b) }
          .to yield_successive_args(*rows)
      end
    end

    context "block is given" do
      it "yields each row of pixels" do
        expect { |b| subject.read_lines_by_block(&b) }
          .to yield_successive_args(*Array.new(25, Array.new(15, 0)))
      end
    end

    context "no block given" do
      it "returns an Enumerator" do
        expect(subject.read_lines_by_block).to be_a(Enumerator)
      end
    end
  end
end
