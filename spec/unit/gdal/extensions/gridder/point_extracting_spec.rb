# frozen_string_literal: true

require 'gdal/extensions/gridder'

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
        expect(subject).to receive(:points_with_field_attributes)
          .with(source_layer, 'things', clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        subject.points
      end

      it 'returns an NArray' do
        allow(subject).to receive(:points_with_field_attributes)
          .with(source_layer, 'things', clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        expect(subject.points).to eq([[0, 0, 0], [1, 1, 1]])
      end
    end

    context 'input_field_name is not set' do
      before { allow(gridder_options).to receive(:input_field_name).and_return nil }

      it 'gets points with attributes without the input_field_name' do
        expect(subject).to receive(:points_no_field_attributes)
          .with(source_layer, clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        subject.points
      end

      it 'returns an NArray' do
        allow(subject).to receive(:points_no_field_attributes)
          .with(source_layer, clipping_geometry).and_return [[0, 0, 0], [1, 1, 1]]

        expect(subject.points).to eq([[0, 0, 0], [1, 1, 1]])
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
end
