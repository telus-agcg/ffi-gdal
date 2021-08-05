# frozen_string_literal: true

RSpec.shared_examples 'not a geometry collection' do
  describe '#simple?' do
    context 'self is simple' do
      specify { expect(subject).to be_simple }
    end

    context 'self is not simple' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#boundary' do
    it 'returns a geometry that represents the boundary of self' do
      expect(subject.boundary).to be_a OGR::Geometry::GeometryMethods
    end
  end
end
