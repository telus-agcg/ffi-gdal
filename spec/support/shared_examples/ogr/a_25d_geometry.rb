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

  describe '#is_3d?' do
    specify do
      expect(subject.is_3d?).to eq true
    end
  end

  describe '#distance3d' do
    context 'self' do
      specify do
        pending 'Figure out how to detect if OGR was built with SFCGAL'

        expect(subject.distance3d(subject.clone)).to be_zero
      end
    end

    context 'other geometry is empty' do
      specify do
        pending 'Figure out how to detect if OGR was built with SFCGAL'

        expect(subject.distance3d(described_class.new)).to be_zero
      end
    end

    context 'other geometry is valid' do
      let(:other) { OGR::Point.new_from_coordinates(180, 180) }

      specify do
        pending 'Figure out how to detect if OGR was built with SFCGAL'

        expect(subject.distance3d(other)).to be > 0
      end
    end
  end
end
