require 'spec_helper'
require 'gdal/driver'
require 'gdal/raster_band'

RSpec.describe 'GDAL::RasterBandMixins::IOExtensions' do
  let(:driver) { GDAL::Driver.by_name('MEM') }
  let(:dataset_byte) { driver.create_dataset('test', 15, 25, data_type: :GDT_Byte) }
  let(:dataset_int16) { driver.create_dataset('test', 15, 25, data_type: :GDT_Int16) }
  let(:dataset_uint16) { driver.create_dataset('test', 15, 25, data_type: :GDT_UInt16) }
  let(:dataset_int32) { driver.create_dataset('test', 15, 25, data_type: :GDT_Int32) }
  let(:dataset_uint32) { driver.create_dataset('test', 15, 25, data_type: :GDT_UInt32) }
  let(:dataset_float32) { driver.create_dataset('test', 15, 25, data_type: :GDT_Float32) }
  let(:dataset_float64) { driver.create_dataset('test', 15, 25, data_type: :GDT_Float64) }

  subject(:raster_band) { dataset_byte.raster_band(1) }

  describe '#set_pixel_value/#pixel_value' do
    context 'valid values, GDT_Byte' do
      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, 123)
        expect(subject.pixel_value(0, 0)).to eq(123)
      end
    end

    context 'valid values, GDT_Int16' do
      subject { dataset_int16.raster_band(1) }

      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, -12_345)
        expect(subject.pixel_value(0, 0)).to eq(-12_345)
      end
    end

    context 'valid values, GDT_UInt16' do
      subject { dataset_uint16.raster_band(1) }

      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, 32_123)
        expect(subject.pixel_value(0, 0)).to eq(32_123)
      end
    end

    context 'valid values, GDT_Int32' do
      subject { dataset_int32.raster_band(1) }

      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, -123_456_789)
        expect(subject.pixel_value(0, 0)).to eq(-123_456_789)
      end
    end

    context 'valid values, GDT_UInt32' do
      subject { dataset_uint32.raster_band(1) }

      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, 4_123_456_789)
        expect(subject.pixel_value(0, 0)).to eq(4_123_456_789)
      end
    end

    context 'valid values, GDT_Float32' do
      subject { dataset_float32.raster_band(1) }

      # For some reason, precision of float32 values isn't there past a couple
      # decimals when reading back.
      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, -123.456)
        expect(subject.pixel_value(0, 0)).to be_within(0.001).of(-123.456)
      end
    end

    context 'valid values, GDT_Float64' do
      subject { dataset_float64.raster_band(1) }

      it 'sets and gets the value successfully' do
        subject.set_pixel_value(0, 0, -123_456_789_101.456)
        expect(subject.pixel_value(0, 0)).to eq(-123_456_789_101.456)
      end
    end
  end

  describe '#block_count' do
    it 'returns a Hash of relevant values' do
      expect(subject.block_count).to eq(
        x: 1,
        x_remainder: 0,
        y: 25,
        y_remainder: 0
      )
    end
  end

  describe '#block_buffer_size' do
    subject { raster_band.block_buffer_size }
    it { is_expected.to eq(15) }
  end

  describe '#read_lines_by_block' do
    context 'block is given' do
      it 'yields each row of pixels' do
        expect { |b| subject.read_lines_by_block(&b) }.
          to yield_successive_args(*Array.new(25, Array.new(15, 0)))
      end
    end

    context 'no block given' do
      it 'returns an Enumerator' do
        expect(subject.read_lines_by_block).to be_a(Enumerator)
      end
    end
  end
end
