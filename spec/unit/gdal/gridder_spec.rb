# frozen_string_literal: true

require 'spec_helper'
require 'gdal/gridder'

RSpec.describe GDAL::Gridder do
  let(:source_layer) { instance_double 'OGR::Layer' }
  let(:dest_file_name) { 'blah.docx' }
  let(:gridder_options) { instance_double 'GDAL::GridderOptions' }

  subject(:gridder) { described_class.new(source_layer, dest_file_name, gridder_options) }

  describe '#build_output_spatial_reference' do
    let(:spatial_reference) { instance_double 'OGR::SpatialRefernce' }

    context 'no output_projection given, source layer has one set' do
      before do
        allow(gridder_options).to receive(:output_projection).and_return nil
        allow(source_layer).to receive(:spatial_reference).and_return spatial_reference
        allow(spatial_reference).to receive(:to_wkt).and_return 'BLAH'
      end

      it "returns WKT of the source layer's SpatialReference" do
        expect(subject.send(:build_output_spatial_reference)).to eq 'BLAH'
      end
    end

    context 'output_projection given' do
      before do
        allow(gridder_options).to receive(:output_projection).and_return spatial_reference
        allow(spatial_reference).to receive(:to_wkt).and_return 'MEOW'
      end

      it "returns WKT of the source layer's SpatialReference" do
        expect(subject.send(:build_output_spatial_reference)).to eq 'MEOW'
      end
    end

    context 'no output_projection given, source layer does not have one set' do
      before do
        allow(gridder_options).to receive(:output_projection).and_return nil
        allow(source_layer).to receive(:spatial_reference).and_return nil
      end

      it 'returns nil' do
        expect(subject.send(:build_output_spatial_reference)).to eq nil
      end
    end
  end

  describe '#x_min' do
    context 'output_x_extent is set' do
      before { allow(gridder_options).to receive(:output_x_extent).and_return(min: 123) }

      it 'sets x_min to that value' do
        expect(subject.send(:x_min)).to eq 123
      end
    end

    context 'output_x_extent is not set' do
      let(:extent) { instance_double 'OGR::Envelope', x_min: 456 }

      before do
        allow(gridder_options).to receive(:output_x_extent).and_return({})
        allow(source_layer).to receive(:extent).and_return extent
      end

      it "sets x_min to the source layer's extent's x_min value" do
        expect(subject.send(:x_min)).to eq 456
      end
    end
  end

  describe '#x_max' do
    context 'output_x_extent is set' do
      before { allow(gridder_options).to receive(:output_x_extent).and_return(max: 321) }

      it 'sets x_max to that value' do
        expect(subject.send(:x_max)).to eq 321
      end
    end

    context 'output_x_extent is not set' do
      let(:extent) { instance_double 'OGR::Envelope', x_max: 654 }

      before do
        allow(gridder_options).to receive(:output_x_extent).and_return({})
        allow(source_layer).to receive(:extent).and_return extent
      end

      it "sets x_max to the source layer's extent's x_max value" do
        expect(subject.send(:x_max)).to eq 654
      end
    end
  end

  describe '#y_min' do
    context 'output_y_extent is set' do
      before { allow(gridder_options).to receive(:output_y_extent).and_return(min: 123) }

      it 'sets y_min to that value' do
        expect(subject.send(:y_min)).to eq 123
      end
    end

    context 'output_y_extent is not set' do
      let(:extent) { instance_double 'OGR::Envelope', y_min: 456 }

      before do
        allow(gridder_options).to receive(:output_y_extent).and_return({})
        allow(source_layer).to receive(:extent).and_return extent
      end

      it "sets y_min to the source layer's extent's y_min value" do
        expect(subject.send(:y_min)).to eq 456
      end
    end
  end

  describe '#y_max' do
    context 'output_y_extent is set' do
      before { allow(gridder_options).to receive(:output_y_extent).and_return(max: 321) }

      it 'sets y_max to that value' do
        expect(subject.send(:y_max)).to eq 321
      end
    end

    context 'output_y_extent is not set' do
      let(:extent) { instance_double 'OGR::Envelope', y_max: 654 }

      before do
        allow(gridder_options).to receive(:output_y_extent).and_return({})
        allow(source_layer).to receive(:extent).and_return extent
      end

      it "sets y_max to the source layer's extent's y_max value" do
        expect(subject.send(:y_max)).to eq 654
      end
    end
  end

  describe '#build_block_count' do
    it 'builds block sizes for both x and y' do
      raster_width = 4
      block_x_size = 2
      raster_height = 5
      block_y_size = 3

      expect(subject).to receive(:build_block_size).with(raster_width, block_x_size).
        and_call_original
      expect(subject).to receive(:build_block_size).with(raster_height, block_y_size).
        and_call_original

      subject.send(:build_block_count, block_x_size, block_y_size, raster_width, raster_height)
    end
  end

  describe '#build_block_size' do
    context 'calculation should not be evenly divisible' do
      it 'returns the floor of the count' do
        raster_width = 4
        block_x_size = 2

        result = subject.send(:build_block_size, raster_width, block_x_size)

        expect(result).to eq 2
      end
    end

    context 'calculation should be evenly divisible' do
      it 'returns the floor of the count' do
        raster_width = 4
        block_x_size = 1

        result = subject.send(:build_block_size, raster_width, block_x_size)

        expect(result).to eq 4
      end
    end
  end
end
