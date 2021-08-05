# frozen_string_literal: true

RSpec.shared_examples 'a geometry' do
  require 'ogr'

  describe '#type' do
    context 'when created with data' do
      it 'returns described_class::GEOMETRY_TYPE' do
        expect(subject.type).to eq described_class::GEOMETRY_TYPE
      end
    end

    context 'when created without data' do
      subject { described_class.new }

      it 'returns described_class::GEOMETRY_TYPE' do
        expect(subject.type).to eq described_class::GEOMETRY_TYPE
      end
    end
  end

  describe '#coordinate_dimension=' do
    context 'valid value' do
      it 'changes the dimension to the new value' do
        skip
      end
    end

    context 'invalid value' do
      it '???' do
        skip
      end
    end
  end

  describe '#empty!' do
    it 'removes all points/geometries from the geometry' do
      thing = subject.clone
      thing.empty!
      expect(thing).to be_empty
    end
  end

  describe '#empty?' do
    context 'when empty' do
      specify { expect(described_class.new).to be_empty }
    end

    context 'when with points' do
      it 'is not empty' do
        skip 'Writing the test'
      end
    end
  end

  describe '#envelope' do
    specify { expect(subject.envelope).to be_a OGR::Envelope }
  end

  describe '#dump_readable' do
    context 'with prefix' do
      it 'writes out to a file' do
        skip
      end
    end

    context 'without prefix' do
      it 'writes out to a file' do
        skip
      end
    end
  end

  describe '#intersects?' do
    context 'self intersects other geometry' do
      it 'returns true' do
        expect(subject.intersects?(subject.clone)).to eq true
      end
    end

    context 'self does not intersect other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#equals?' do
    context 'self equals other geometry' do
      it 'returns true' do
        expect(subject.equals?(subject.clone)).to eq true
      end
    end

    context 'self does not equals other geometry' do
      it 'returns false' do
        expect(subject.equals?(described_class.new)).to eq false
      end
    end
  end

  describe '#disjoint?' do
    context 'self disjoints other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not disjoint other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#touches?' do
    context 'self touches other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not touch other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#crosses?' do
    context 'self touches other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not touch other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#within?' do
    context 'self is within other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not within other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#contains?' do
    context 'self contains other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not contain other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#overlaps?' do
    context 'self overlaps other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not overlap other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#valid?' do
    context 'self is valid' do
      it 'returns true' do
        expect(subject).to be_valid
      end
    end

    context 'self is not valid' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#simple?' do
    context 'self is simple' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not simple' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#ring?' do
    context 'self is a ring' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not a ring' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#intersection' do
    specify { skip 'Implementation' }
  end

  describe '#union' do
    context 'where there is no union' do
      specify { skip }
    end

    context 'where there is union' do
      specify { skip }
    end
  end

  describe '#close_rings!' do
    it 'adds points to close any potential rings' do
      skip
    end
  end

  describe '#difference' do
    it 'creates a new geometry that represents the difference' do
      skip
    end
  end

  describe '#symmetric_difference' do
    it 'creates a new geometry that represents the difference' do
      skip
    end
  end

  describe '#distance_to' do
    context 'other geometry is nil' do
      it '???' do
        skip
      end
    end

    context 'other geometry is valid' do
      it 'creates a new geometry that represents the difference' do
        skip
      end
    end
  end

  describe '#spatial_reference' do
    context 'none assigned' do
      subject { described_class.new }

      it 'returns nil' do
        expect(subject.spatial_reference).to be_nil
      end
    end

    context 'has one assigned' do
      it 'returns a spatial reference' do
        subject.spatial_reference = OGR::SpatialReference.new.import_from_epsg(4326)
        expect(subject.spatial_reference).to be_a OGR::SpatialReference
      end
    end
  end

  describe '#spatial_reference=' do
    it 'assigns the new spatial reference' do
      skip
    end
  end

  describe '#transform!' do
    it 'assigns the new spatial reference' do
      skip
    end
  end

  describe '#transform_to!' do
    it 'transforms the points into the new spatial reference' do
      skip
    end

    it 'sets the new spatial reference' do
      skip
    end
  end

  describe '#simplify' do
    context 'preserve_topology is true' do
      it 'returns a new geometry' do
        skip
      end
    end

    context 'preserve_topology is false' do
      it 'returns a new geometry' do
        skip
      end
    end
  end

  describe '#segmentize!' do
    it 'updates the geometry' do
      skip
    end
  end

  describe '#boundary' do
    it 'returns a geometry that represents the boundary of self' do
      skip
    end
  end

  describe '#buffer' do
    it 'returns a new geometry that adds a boundary around self' do
      skip
    end
  end

  describe '#convex_hull' do
    it 'returns a new geometry that is the convex hull of self' do
      skip
    end
  end

  describe '#import_from_wkb' do
    it 'updates self with the new geometry info' do
      skip
    end
  end

  describe '#import_from_wkt' do
    it 'updates self with the new geometry info' do
      skip
    end
  end

  describe '#wkb_size' do
    it 'returns a non-zero integer' do
      size = subject.wkb_size

      expect(size).to be_a Integer

      if subject.name == 'LINEARRING'
        expect(size).to be_zero
      else
        expect(size).to be_positive
      end
    end
  end

  describe '#to_wkb' do
    it 'returns some binary String data' do
      if subject.name == 'LINEARRING'
        expect { subject.to_wkb }.to raise_exception OGR::UnsupportedOperation
      else
        wkb = subject.to_wkb
        expect(wkb).to be_a String
        expect(wkb).to_not be_empty
      end
    end
  end

  describe '#to_wkt' do
    it 'returns some String data' do
      wkt = subject.to_wkt
      expect(wkt).to be_a String
      expect(wkt).to_not be_empty
    end
  end
end
