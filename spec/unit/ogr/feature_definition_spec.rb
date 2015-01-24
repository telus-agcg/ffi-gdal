require 'spec_helper'

RSpec.describe OGR::FeatureDefinition do
  describe '.create' do
    it 'returns a new FeatureDefinition' do
      expect(described_class.create('stuff')).to be_a described_class
    end
  end

  subject(:feature_definition) do
    fd = described_class.create('spec feature definition')
    fd.geometry_type = :wkbMultiPolygon
    fd
  end

  describe '#name' do
    it 'returns the name given to it' do
      expect(subject.name).to eq 'spec feature definition'
    end
  end

  describe '#field_count' do
    context 'no fields' do
      subject { feature_definition.field_count }
      it { is_expected.to be_zero }
    end
  end

  describe '#field' do
    context 'no fields' do
      it 'raises a RuntimeError' do
        expect { subject.field(0) }.to raise_exception RuntimeError
      end
    end
  end

  describe '#field_index' do
    context 'no fields' do
      it 'raises a RuntimeError' do
        expect(subject.field_index('things')).to be_nil
      end
    end
  end

  describe '#geometry_type' do
    context 'default' do
      subject(:feature_definition) do
        described_class.create('spec feature definition')
      end

      it 'is :wkbUnknown' do
        expect(subject.geometry_type).to eq :wkbUnknown
      end
    end
  end

  describe '#geometry_type= + #geometry_type' do
    context 'valid geometry type' do
      it 'assigns the new geometry type' do
        subject.geometry_type = :wkbPoint
        expect(subject.geometry_type).to eq :wkbPoint
      end
    end

    context 'invalid geometry type' do
      it 'raises an ArgumenError' do
        expect { subject.geometry_type = :bubbles }.
          to raise_exception ArgumentError
      end
    end
  end

  describe '#geometry_ignored?' do
    context 'default' do
      subject { feature_definition.geometry_ignored? }
      it { is_expected.to eq false }
    end
  end

  describe '#ignore_geometry! + #geometry_ignored?' do
    context 'set to ignore' do
      it 'causes the geometry to be ignored' do
        subject.ignore_geometry!
        expect(subject.geometry_ignored?).to eq true
      end
    end

    context 'set to not ignore' do
      it 'causes the geometry to be ignored' do
        subject.ignore_geometry! false
        expect(subject.geometry_ignored?).to eq false
      end
    end
  end

  describe '#style_ignored?' do
    context 'default' do
      subject { feature_definition.style_ignored? }
      it { is_expected.to eq false }
    end
  end

  describe '#ignore_style! + #style_ignored?' do
    context 'set to ignore' do
      it 'causes the style to be ignored' do
        subject.ignore_style!
        expect(subject.style_ignored?).to eq true
      end
    end

    context 'set to not ignore' do
      it 'causes the style to be ignored' do
        subject.ignore_style! false
        expect(subject.style_ignored?).to eq false
      end
    end
  end

  describe '#geometry_field_count' do
    context 'default' do
      subject { feature_definition.geometry_field_count }
      it { is_expected.to eq 1 }
    end
  end

  describe '#geometry_field_definition' do
    context 'default, at 0' do
      it 'returns an OGR::Field' do
        expect(subject.geometry_field_definition(0)).to be_a OGR::Field
      end
    end
  end

  describe '#fields' do
    it 'returns an array of size field_count' do
      expect(subject.fields).to be_an Array
      expect(subject.fields.size).to eq subject.field_count
    end
  end

  describe '#field_by_name' do
    context 'field with name does not exist' do
      it 'returns nil' do
        expect(subject.field_by_name('asdfasdfasdf')).to be_nil
      end
    end
  end

  describe '#geometry_field_by_name' do
    context 'field with name does not exist' do
      it 'returns nil' do
        subject.geometry_field_definition(0).name
        expect(subject.geometry_field_by_name('asdfasdf')).to be_nil
      end
    end

    context 'field with name exists' do
      it do
        p subject.geometry_field_definition(0).as_json
        name = subject.geometry_field_definition(0).name
        expect(subject.geometry_field_by_name(name)).to be_a OGR::Field
      end
    end
  end

  describe '#same?' do
    context 'is the same as the other' do
      let(:other_feature_definition) do
        df = described_class.create('spec feature definition')
        df.geometry_type = :wkbMultiPolygon
        df
      end

      it 'returns true' do
        expect(subject.same?(other_feature_definition)).to eq true
      end
    end

    context 'not the same as the other' do
      let(:other_feature_definition) do
        described_class.create('other feature definition')
      end

      it 'returns false' do
        expect(subject.same?(other_feature_definition)).to eq false
      end
    end
  end

  describe '#as_json' do
    it 'returns a Hash of all attributes and values' do
      expect(subject.as_json).to eq({
        field_count: 0,
        fields: [],
        geometry_field_count: 1,
        geometry_type: :wkbMultiPolygon,
        is_geometry_ignored: false,
        is_style_ignored: false,
        name: 'spec feature definition'
        })
    end
  end

  describe '#to_json' do
    it 'is a String' do
      expect(subject.to_json).to be_a String
      expect(subject.to_json).to_not be_empty
    end
  end
end