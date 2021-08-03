# frozen_string_literal: true

RSpec.shared_examples 'a 2D geometry' do
  describe '#coordinate_dimension' do
    specify { expect(subject.coordinate_dimension).to eq 2 }
  end

  describe '#centroid' do
    it 'returns a OGR::Point' do
      expect(subject.centroid).to be_a OGR::Point
    end
  end

  describe '#envelope' do
    it 'returns a OGR::Envelope' do
      expect(subject.envelope).to be_a OGR::Envelope
    end
  end
end
