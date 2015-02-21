require 'spec_helper'
require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#feature_definition' do
    it 'returns a OGR::FeatureDefinition' do
      expect(subject.feature_definition).to be_a OGR::FeatureDefinition
    end
  end

  describe '#create_feature' do
    it 'returns a new OGR::Feature' do
      expect(subject.create_feature).to be_a OGR::Feature
    end
  end

  describe '#delete_feature' do
    context 'no features' do
      it 'raises an OGR::Failure' do
        expect { subject.delete_feature(0) }.to raise_exception OGR::Failure
      end
    end

    context 'has a feature' do
      before { subject.create_feature }

      it 'returns true' do
        expect(subject.delete_feature(0)).to eq true
      end
    end
  end

  describe '#feature_count' do
    it 'returns the number of features' do
      expect(subject.feature_count).to be_zero
    end
  end

  describe '#feature' do
    context 'no features' do
      it 'returns nil' do
        expect(subject.feature(0)).to be_nil
      end
    end

    context 'has a feature' do
      before { subject.create_feature }

      it 'returns an OGR::Feature' do
        expect(subject.feature(0)).to be_a OGR::Feature
      end
    end
  end

  describe '#feature=' do
    it 'adds the feature' do
      skip
    end
  end

  describe 'next_feature' do
    context 'no features' do
      it 'returns nil' do
        expect(subject.next_feature).to be_nil
      end
    end

    context 'has a feature' do
      before { subject.create_feature }

      it 'returns an OGR::Feature' do
        expect(subject.next_feature).to be_a OGR::Feature
      end
    end
  end

  describe '#next_feature_index=' do
    context 'no features' do
      it 'raises an OGR::Failure' do
        expect { subject.next_feature_index = 123 }.
          to raise_exception OGR::Failure
      end
    end

    context 'features exist' do
      let!(:feature1) do
        subject.create_feature
      end

      let!(:feature2) do
        subject.create_feature
      end

      it 'sets to the given feature' do
        subject.next_feature_index = 1
        expect(subject.next_feature).to_not be_nil
      end
    end
  end
end
