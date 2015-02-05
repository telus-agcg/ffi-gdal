require 'spec_helper'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

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
