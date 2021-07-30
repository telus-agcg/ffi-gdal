# frozen_string_literal: true

# Requirements:
#
# * :child_geometry - one that the described class can add to an instance of
#   itself.
RSpec.shared_examples 'a container geometry' do
  describe '#add_geometry' do
    it 'adds the geometry to the container' do
      skip
    end
  end

  describe '#add_directly' do
    it 'adds the geometry to the container' do
      skip
    end
  end

  describe '#remove_geometry' do
    it 'removes the geometry to the container' do
      skip
    end
  end

  describe '#geometry_count' do
    context 'geometry exists at the index' do
      subject do
        gc = described_class.new
        gc.add_geometry(child_geometry)
        gc
      end

      it 'returns the number of child geometries in self' do
        expect(subject.geometry_count).to eq 1
      end
    end

    context 'no geometries' do
      specify { expect(subject.geometry_count).to eq 0 }
    end
  end

  describe '#geometry_at' do
    context 'geometry exists at the index' do
      subject do
        gc = described_class.new
        gc.add_geometry(child_geometry)
        gc
      end

      it 'returns the geometry' do
        expect(subject.geometry_at(0)).to be_a(child_geometry.class)
      end
    end

    context 'no geometries' do
      it 'returns nil' do
        expect(subject.geometry_at(0)).to be_nil
      end
    end
  end
end
