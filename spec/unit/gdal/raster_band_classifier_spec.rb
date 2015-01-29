require 'spec_helper'

RSpec.describe GDAL::RasterBandClassifier do
  let(:driver) { GDAL::Driver.by_name('MEM') }

  let(:dataset) do
    driver.create_dataset 'test dataset', 640, 480
  end

  let(:raster_band) do
    band = dataset.raster_band 1
    new_values = band.to_na.indgen!
    band.write_array(new_values)
    band
  end

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

  describe '#equal_value_ranges' do
    context 'band type is :GDT_Byte' do
      subject { classifier.equal_value_ranges(4) }

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
        band.write_array(new_values)
        band
      end

      let(:float_dataset) do
        driver.create_dataset 'test dataset', 640, 480, data_type: :GDT_Float32
      end

      subject { classifier.equal_value_ranges(4) }

      it 'is an Array of Hashes' do
        expect(subject).to be_an Array
        expect(subject.first).to be_a Hash
      end

      it 'has map_to values that are between 1 and 4' do
        map_to_values = subject.map { |range| range[:map_to] }.uniq
        expect(map_to_values).to contain_exactly(1.0, 2.0, 3.0, 4.0)
      end
    end
  end

  describe '#classify!' do
    before do
      ranges = subject.equal_value_ranges(10)
      subject.add_ranges(ranges)
    end

    context 'no_data_value is set' do
      before do
        raster_band.no_data_value = 0
        subject.classify!
      end

      it 'has a max value equal to the number of ranges' do
        min_max = raster_band.min_max
        expect(min_max[:max]).to eq 10
      end

      it 'has a min value of 1' do
        min_max = raster_band.min_max
        expect(min_max[:min]).to eq 1
      end
    end

    context 'no_data_value is not set' do
      before do
        subject.classify!
      end

      it 'has a max value equal to the number of ranges' do
        min_max = raster_band.min_max
        expect(min_max[:max]).to eq 10
      end

      it 'has a min value of 0' do
        min_max = raster_band.min_max
        expect(min_max[:min]).to eq 0
      end
    end
  end
end
