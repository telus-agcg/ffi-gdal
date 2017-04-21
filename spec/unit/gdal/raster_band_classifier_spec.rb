# frozen_string_literal: true

require 'spec_helper'
require 'gdal/driver'
require 'gdal/raster_band_classifier'

RSpec.describe GDAL::RasterBandClassifier do
  let(:driver) { GDAL::Driver.by_name('MEM') }

  let(:dataset) do
    d = driver.create_dataset('test dataset', 640, 480)
    band = d.raster_band 1
    new_values = band.to_na.indgen!
    band.write_xy_narray(new_values)

    d
  end

  let(:raster_band) { dataset.raster_band 1 }
  subject(:classifier) { described_class.new(raster_band) }

  describe '#add_range' do
    context 'range param is a Range' do
      it 'adds the hash to the list of @ranges' do
        expect do
          subject.add_range 0..10, 1
        end.to change { subject.ranges.size }.by 1
      end
    end

    context 'range param is not a Range' do
      it 'raises a RuntimeError' do
        expect do
          subject.add_range [1, 2, 3], 1
        end.to raise_exception RuntimeError
      end
    end
  end

  describe '#add_ranges' do
    let(:ranges) do
      [
        { range: 0..10, map_to: 1000 },
        { range: 10..100, map_to: 1 }
      ]
    end

    it 'adds a list of ranges to @ranges' do
      expect do
        subject.add_ranges(ranges)
      end.to change { subject.ranges.size }.by ranges.size
    end
  end

  describe '#equal_count_ranges' do
    context 'band type is :GDT_Byte' do
      subject { classifier.equal_count_ranges(4) }

      it 'is an Array of Hashes' do
        expect(subject).to be_an Array
        expect(subject.first).to be_a Hash
      end

      it 'has map_to values that are between 1 and 4' do
        map_to_values = subject.map { |range| range[:map_to] }.uniq
        expect(map_to_values).to contain_exactly(1, 2, 3, 4)
      end
    end

    context 'band type is :GDT_Float32' do
      let(:raster_band) do
        band = float_dataset.raster_band 1
        new_values = band.to_na.indgen!
        band.write_xy_narray(new_values)
        band
      end

      let(:float_dataset) do
        driver.create_dataset 'test dataset', 640, 480, data_type: :GDT_Float32
      end

      subject { classifier.equal_count_ranges(4) }

      it 'is an Array of Hashes' do
        expect(subject).to be_an Array
        expect(subject.first).to be_a Hash
      end

      it 'has map_to values that are between 1 and 4' do
        map_to_values = subject.map { |range| range[:map_to] }.uniq
        expect(map_to_values).to contain_exactly(1.0, 2.0, 3.0, 4.0)
      end
    end

    context 'not enough values between breaks to generate unique break values' do
      subject { classifier.equal_count_ranges(1_000) }
      it { is_expected.to be_nil }
    end

    context 'all nodata pixels' do
      let(:band_narray) { NArray.byte(0) }
      before { allow(raster_band).to receive(:to_na).and_return(band_narray) }

      it 'returns an empty Array' do
        expect(subject.equal_count_ranges(10)).to eq([])
      end
    end
  end

  describe '#classify!' do
    before do
      ranges = subject.equal_count_ranges(10)
      subject.add_ranges(ranges)
    end

    context 'no_data_value is set to 0' do
      before do
        raster_band.no_data_value = 0
      end

      it 'has a max value equal to the number of ranges' do
        subject.classify!
        min_max = raster_band.min_max
        expect(min_max[:max]).to eq 10
      end

      it 'has a min value of 1' do
        subject.classify!
        min_max = raster_band.min_max
        expect(min_max[:min]).to eq 1
      end

      it 'retains its NODATA pixels' do
        expect { subject.classify! }.to_not change { raster_band.to_na.eq(-9999.0).count_true }
      end
    end

    # Relevant because NArray inits its arrays to 0.
    context 'no_data_value is set to non-0' do
      let(:dataset) do
        d = driver.create_dataset('test dataset', 640, 480, data_type: :GDT_Float32)
        band = d.raster_band 1
        band.no_data_value = -9999.0
        new_values = band.to_na.indgen!
        new_values[true, 0] = -9999.0
        band.write_xy_narray(new_values)

        d
      end

      it 'has a max value equal to the number of ranges' do
        subject.classify!
        min_max = raster_band.min_max
        expect(min_max[:max]).to eq 10
      end

      it 'has a min value of 1' do
        subject.classify!
        min_max = raster_band.min_max
        expect(min_max[:min]).to eq 1
      end

      it 'retains its NODATA pixels' do
        expect { subject.classify! }.to_not change { raster_band.to_na.eq(-9999.0).count_true }
        pixels = raster_band.to_na
        expect(pixels.eq(-9999).count_true).to eq 640
        expect(pixels.eq(0).count_true).to eq 0
        expect(pixels.eq(1).count_true).to eq 30_656
        expect(pixels.eq(2).count_true).to eq 30_656
        expect(pixels.eq(3).count_true).to eq 30_656
        expect(pixels.eq(4).count_true).to eq 30_656
        expect(pixels.eq(5).count_true).to eq 30_656
        expect(pixels.eq(6).count_true).to eq 30_656
        expect(pixels.eq(7).count_true).to eq 30_656
        expect(pixels.eq(8).count_true).to eq 30_656
        expect(pixels.eq(9).count_true).to eq 30_656
        expect(pixels.eq(10).count_true).to eq 30_656
      end
    end

    context 'no_data_value is not set' do
      it 'has a max value equal to the number of ranges' do
        subject.classify!
        min_max = raster_band.min_max
        expect(min_max[:max]).to eq 10
      end

      it 'has a min value of 0' do
        subject.classify!
        min_max = raster_band.min_max
        expect(min_max[:min]).to eq 0
      end

      it 'retains its NODATA pixels' do
        expect { subject.classify! }.to_not change { raster_band.to_na.eq(-9999.0).count_true }
      end
    end
  end
end
