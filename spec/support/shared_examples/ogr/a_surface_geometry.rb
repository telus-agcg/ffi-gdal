# frozen_string_literal: true

RSpec.shared_examples 'a surface geometry' do
  describe '#area' do
    it 'has some value' do
      expect(subject.area).to be > 0.0
    end
  end

  describe '#point_on_surface' do
    it 'returns an OGR::Point' do
      expect(subject.point_on_surface).to be_a OGR::Point
    end
  end

  describe '#envelope' do
    it 'returns a OGR::Envelope' do
      expect(subject.envelope).to be_a OGR::Envelope
    end
  end
end
