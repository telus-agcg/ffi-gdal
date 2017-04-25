# frozen_string_literal: true

require 'spec_helper'
require 'gdal/gridder_options'

RSpec.describe GDAL::GridderOptions do
  subject(:gridder_options) { described_class.new(:metric_count) }

  describe 'attributes' do
    it { is_expected.to respond_to :input_clipping_geometry }
    it { is_expected.to respond_to :input_clipping_geometry= }
    it { is_expected.to respond_to :input_field_name }
    it { is_expected.to respond_to :input_field_name= }

    it { is_expected.to respond_to :progress_formatter }
    it { is_expected.to respond_to :progress_formatter= }
    it { is_expected.to respond_to :grid }
    it { is_expected.to respond_to :algorithm_options }

    it { is_expected.to respond_to :output_creation_options }
    it { is_expected.to respond_to :output_creation_options= }
    it { is_expected.to respond_to :output_format }
    it { is_expected.to respond_to :output_format= }
    it { is_expected.to respond_to :output_x_extent }
    it { is_expected.to respond_to :output_x_extent= }
    it { is_expected.to respond_to :output_y_extent }
    it { is_expected.to respond_to :output_y_extent= }
    it { is_expected.to respond_to :output_projection }
    it { is_expected.to respond_to :output_projection= }
    it { is_expected.to respond_to :output_size }
    it { is_expected.to respond_to :output_size= }
    it { is_expected.to respond_to :output_data_type }
    it { is_expected.to respond_to :output_data_type= }
  end

  describe 'default values' do
    describe '#output_data_type' do
      subject { gridder_options.output_data_type }
      it { is_expected.to eq :GDT_Float64 }
    end

    describe '#output_format' do
      subject { gridder_options.output_format }
      it { is_expected.to eq 'GTiff' }
    end

    describe '#output_size' do
      subject { gridder_options.output_size }
      it { is_expected.to eq(width: 256, height: 256) }
    end
  end

  describe '#input_clipping_geometry=' do
    context 'param is a OGR::Geometry' do
      it 'sets the attribute' do
        geom = OGR::Point.new
        subject.input_clipping_geometry = geom
        expect(subject.input_clipping_geometry).to eq geom
      end
    end

    context 'param is not a OGR::Geometry' do
      it 'raises a OGR::InvalidGeometry exception' do
        expect { subject.input_clipping_geometry = 'meow' }.
          to raise_exception OGR::InvalidGeometry
      end
    end
  end

  describe '#output_data_type=' do
    context 'param is a FFI::GDAL::GDAL::DataType' do
      it 'sets the attribute and the grid data type' do
        subject.output_data_type = :GDT_Byte
        expect(subject.output_data_type).to eq :GDT_Byte
        expect(subject.grid.data_type).to eq :GDT_Byte
      end
    end

    context 'param is not a FFI::GDAL::GDAL::DataType' do
      it 'raises a OGR::InvalidGeometry exception' do
        expect { subject.output_data_type = 'meow' }.
          to raise_exception GDAL::InvalidDataType
      end
    end
  end

  describe '#output_format=' do
    context 'param is a GDAL::Driver short name' do
      it 'sets the attribute' do
        subject.output_format = 'SAGA'
        expect(subject.output_format).to eq 'SAGA'
      end
    end

    context 'param is not a GDAL::Driver short name' do
      it 'raises a GDAL::InvalidDriverName exception' do
        expect { subject.output_format = 'meow' }.
          to raise_exception GDAL::InvalidDriverName
      end
    end
  end

  describe '#output_x_extent=' do
    it 'returns a Hash with min and max keys' do
      expect(subject).to receive(:extract_min_max).with(%w[some values], :min, :max).
        and_return(%w[some values])
      subject.output_x_extent = %w[some values]
      expect(subject.output_x_extent).to eq(min: 'some', max: 'values')
    end
  end

  describe '#output_y_extent=' do
    it 'returns a Hash with min and max keys' do
      expect(subject).to receive(:extract_min_max).with(%w[some values], :min, :max).
        and_return(%w[some values])
      subject.output_y_extent = %w[some values]
      expect(subject.output_y_extent).to eq(min: 'some', max: 'values')
    end
  end

  describe '#output_size=' do
    it 'returns a Hash with min and max keys' do
      expect(subject).to receive(:extract_min_max).with(%w[some values], :width, :height).
        and_return(%w[some values])
      subject.output_size = %w[some values]
      expect(subject.output_size).to eq(width: 'some', height: 'values')
    end
  end

  describe '#output_projection=' do
    context 'param is a OGR::SpatialReference' do
      it 'sets the attribute' do
        projection = OGR::SpatialReference.new_from_epsg(4326)
        subject.output_projection = projection
        expect(subject.output_projection).to eq projection
      end
    end

    context 'param is not a OGR::SpatialReference' do
      it 'raises a OGR::InvalidSpatialReference exception' do
        expect { subject.output_projection = 'meow' }.
          to raise_exception OGR::InvalidSpatialReference
      end
    end
  end

  describe '#extract_min_max_from_array' do
    context 'param is a 2-element Array' do
      it 'sets the attribute' do
        expect(subject.send(:extract_min_max_from_array, [1, 20], :foo, :bar)).
          to eq([1, 20])
      end
    end

    context 'param is an Array with not 2 elements' do
      it 'raises an ArgumentError' do
        expect { subject.send(:extract_min_max_from_array, [1, 20, 30], :foo, :bar) }.
          to raise_exception ArgumentError
      end
    end
  end

  describe '#extract_min_max_from_hash' do
    context 'param is a Hash with :min and :max keys' do
      it 'sets the attribute' do
        expect(subject.send(:extract_min_max_from_hash, { min: 1, max: 20 }, :min, :max)).
          to eq([1, 20])
      end
    end

    context 'param is a Hash with :min, :max, and :other' do
      it 'raises an ArgumentError' do
        expect { subject.send(:extract_min_max_from_hash, { min: 1, max: 20, other: 30 }, :min, :max) }.
          to raise_exception ArgumentError
      end
    end

    context 'param is a Hash without :min and :max' do
      it 'raises an ArgumentError' do
        expect { subject.send(:extract_min_max_from_hash, { things: 1, stuff: 20 }, :min, :max) }.
          to raise_exception ArgumentError
      end
    end
  end
end
