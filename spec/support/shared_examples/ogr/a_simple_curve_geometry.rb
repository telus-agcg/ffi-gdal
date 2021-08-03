# frozen_string_literal: true

RSpec.shared_examples 'a simple curve geometry' do
  describe '#x' do
    context 'point exists' do
      it 'returns the value of the point' do
        expect(subject.x(0)).to be_a Float
      end
    end

    context 'point does not exist' do
      it 'raises GDAL::UnsupportedOperation' do
        expect { subject.x(-2) }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end
end
