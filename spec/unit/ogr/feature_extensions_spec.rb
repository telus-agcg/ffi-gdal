require 'spec_helper'
require 'ogr'

RSpec.describe OGR::Feature do
  let(:integer_field_def) { OGR::FieldDefinition.new('test integer field', :OFTInteger) }

  let(:feature_definition) do
    fd = OGR::FeatureDefinition.new('test FD')
    fd.add_field_definition(integer_field_def) # 0

    gfd = fd.geometry_field_definition(0)
    gfd.type = :wkbPoint
    gfd.name = 'test point'

    fd
  end

  let(:geometry) { OGR::Point.create_from_wkt('POINT (0 1)') }

  subject(:feature) do
    f = described_class.new(feature_definition)
    f.set_geometry_field(0, geometry)

    f
  end

  describe '#each_field' do
    context 'no block given' do
      it 'returns an Enumerator' do
        expect(subject.each_field).to be_a Enumerator
      end
    end

    context 'block given' do
      it 'yields each geometry field definition' do
        expect { |b| subject.each_field(&b) }.to yield_successive_args(0)
      end
    end
  end

  describe '#fields' do
    it 'returns all of the field values as an Array' do
      expect(subject.fields).to eq [0]
    end
  end

  describe '#each_geometry_field_definition' do
    context 'no block given' do
      it 'returns an Enumerator' do
        expect(subject.each_geometry_field_definition).to be_a Enumerator
      end
    end

    context 'block given' do
      it 'yields each geometry field definition' do
        expect { |b| subject.each_geometry_field_definition(&b) }.
          to yield_successive_args(OGR::GeometryFieldDefinition)
      end
    end
  end

  describe '#geometry_field_definitions' do
    it 'returns all of the geometry field definitions as an Array of GeometryFieldDefinitions' do
      expect(subject.geometry_field_definitions).to contain_exactly instance_of(OGR::GeometryFieldDefinition)
    end
  end

  describe '#each_geometry_field' do
    context 'no block given' do
      it 'returns an Enumerator' do
        expect(subject.each_geometry_field).to be_a Enumerator
      end
    end

    context 'block given' do
      it 'yields each geometry field' do
        expect { |b| subject.each_geometry_field(&b) }.
          to yield_successive_args(geometry)
      end
    end
  end

  describe '#geometry_fields' do
    it 'returns all of the geometry fields as an Array of Geometries' do
      expect(subject.geometry_fields).to eq [geometry]
    end
  end
end
