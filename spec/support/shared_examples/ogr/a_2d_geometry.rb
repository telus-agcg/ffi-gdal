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

  describe '#is_3d?' do
    specify do
      expect(subject.is_3d?).to eq false
    end
  end

  describe '#distance3d' do
    context 'self' do
      specify do
        skip 'Figure out how to detect if OGR was built with SFCGAL'

        expect { subject.distance3d(subject.clone) }.to raise_exception OGR::Failure
      end
    end

    context 'other geometry is empty' do
      specify do
        skip 'Figure out how to detect if OGR was built with SFCGAL'

        expect { subject.distance3d(described_class.new) }.to raise_exception OGR::Failure
      end
    end

    context 'other geometry is valid' do
      let(:other) { OGR::Point.new_from_coordinates(180, 180) }

      specify do
        skip 'Figure out how to detect if OGR was built with SFCGAL'

        expect { subject.distance3d(other) }.to raise_exception OGR::Failure
      end
    end
  end
end
