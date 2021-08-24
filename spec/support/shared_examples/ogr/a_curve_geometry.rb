# frozen_string_literal: true

RSpec.shared_examples 'a curve geometry' do
  describe '#length' do
    specify { expect(subject.length).to be > 0.0 }
  end

  describe '#value' do
    specify { expect(subject.value(0)).to be_a OGR::Point }
  end
end
