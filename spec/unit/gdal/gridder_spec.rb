require 'spec_helper'
require 'gdal/gridder'

RSpec.describe GDAL::Gridder do
  let(:source_layer) { instance_double 'OGR::Layer' }
  let(:dest_file_name) { 'blah.docx' }
  let(:gridder_options) { instance_double 'GDAL::GridderOptions' }

  subject(:gridder) { described_class.new(source_layer, dest_file_name, gridder_options) }

  describe '#points' do
    let(:clipping_geometry) { instance_double 'OGR::LineString' }

    before do
      expect(subject).to receive(:ensure_z_values)
      allow(gridder_options).to receive(:input_clipping_geometry).and_return clipping_geometry
    end

    context 'input_field_name is set' do
      before { allow(gridder_options).to receive(:input_field_name).and_return 'things' }

      it 'gets points with attributes by the input_field_name' do
        expect(subject).to receive(:points_with_field_attributes).
          with(source_layer, 'things', clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        subject.points
      end

      it 'returns an NArray' do
        allow(subject).to receive(:points_with_field_attributes).
          with(source_layer, 'things', clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        expect(subject.points).to be_a NArray
      end
    end

    context 'input_field_name is not set' do
      before { allow(gridder_options).to receive(:input_field_name).and_return nil }

      it 'gets points with attributes without the input_field_name' do
        expect(subject).to receive(:points_no_field_attributes).
          with(source_layer, clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        subject.points
      end

      it 'returns an NArray' do
        allow(subject).to receive(:points_no_field_attributes).
          with(source_layer, clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        expect(subject.points).to be_a NArray
      end
    end
  end

  describe '#ensure_z_values' do
    context 'layer does not have a field by the requested name' do
      before do
        allow(subject).to receive(:layer_missing_specified_field?).and_return true
        allow(gridder_options).to receive(:input_field_name).and_return 'meow'
      end

      it 'raises an OGR::InvalidFieldName' do
        expect { subject.send(:ensure_z_values) }.to raise_exception OGR::InvalidFieldName
      end
    end

    context 'no requested field name set and layer has no geometries with Z values' do
      before do
        allow(subject).to receive(:layer_missing_specified_field?).and_return false
        allow(gridder_options).to receive(:input_field_name).and_return nil
        allow(source_layer).to receive(:any_geometries_with_z?).and_return false
        allow(source_layer).to receive(:name).and_return 'meow'
      end

      it 'raises an GDAL::NoValuesToGrid' do
        expect { subject.send(:ensure_z_values) }.to raise_exception GDAL::NoValuesToGrid
      end
    end
  end

  describe '#layer_missing_specified_field?' do
    subject { gridder.send(:layer_missing_specified_field?) }

    context 'input_field_name not set' do
      before { allow(gridder_options).to receive(:input_field_name).and_return nil }
      it { is_expected.to be false }
    end

    context 'input_field_name set but layer does not contain fields with that name' do
      before do
        allow(gridder_options).to receive(:input_field_name).and_return 'things'
        expect(source_layer).to receive(:find_field_index).with('things').and_return nil
      end

      it { is_expected.to be true }
    end
  end

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
end
