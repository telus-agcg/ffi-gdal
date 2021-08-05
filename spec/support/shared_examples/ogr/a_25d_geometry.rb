# frozen_string_literal: true

RSpec.shared_examples 'a 2.5D geometry' do
  describe '#flatten_to_2d' do
    it 'drops the z point(s)' do
      skip
    end
  end

  describe '#centroid' do
    it 'returns a OGR::Point25D' do
      expect(subject.centroid).to be_a OGR::Point25D
    end
  end
end
