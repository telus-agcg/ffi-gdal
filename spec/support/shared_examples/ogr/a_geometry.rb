# frozen_string_literal: true

RSpec.shared_examples 'a geometry' do |expected_type_to_name|
  require 'ogr'

  def subject_is_3d?
    described_class.name.end_with?('25D')
  end

  describe '#clone' do
    it 'returns a new object of the same type and value' do
      expect(subject.clone).to eq(subject)
    end
  end

  describe '#empty!' do
    it 'removes all points/geometries from the geometry' do
      thing = subject.clone
      thing.empty!
      expect(thing).to be_empty
    end
  end

  describe '#dimension' do
    it 'returns 1, 2, or 3 based on the type' do
      case subject
      when OGR::Point, OGR::MultiPoint then expect(subject.dimension).to eq(0)
      when OGR::Curve, OGR::MultiCurve then expect(subject.dimension).to eq(1)
      when OGR::Surface, OGR::MultiSurface then expect(subject.dimension).to eq(2)
      when OGR::GeometryCollection then expect(subject.dimension).to eq(1).or(eq(2)).or(eq(3))
      else raise 'add me'
      end
    end
  end

  describe '#coordinate_dimension' do
    it 'returns 1, 2, or 3 based on the type' do
      if subject_is_3d?
        expect(subject.coordinate_dimension).to eq(3)
      else
        expect(subject.coordinate_dimension).to eq(2)
      end
    end
  end

  describe '#coordinate_dimension=' do
    context 'setting to 2' do
      it 'is allowed for any geometry' do
        subject.coordinate_dimension = 2
        expect(subject.coordinate_dimension).to eq(2)
      end
    end

    context 'setting to 3' do
      it 'is allowed for any geometry' do
        subject.coordinate_dimension = 3
        expect(subject.coordinate_dimension).to eq(3)
      end
    end

    context 'setting to not 2 or 3' do
      it 'raises a OGR::Failure' do
        expect { subject.coordinate_dimension = 4 }.to raise_exception OGR::Failure
      end
    end
  end

  describe '#envelope' do
    specify do
      if subject_is_3d?
        expect(subject.envelope).to be_a OGR::Envelope3D
      else
        expect(subject.envelope).to be_a OGR::Envelope
      end
    end
  end

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

  describe '#type_to_name' do
    specify { expect(subject.type_to_name).to eq(expected_type_to_name) }
  end

  describe '#name' do
    specify do
      if subject_is_3d?
        expect(subject.name).to eq(described_class.name.split('::').last.sub('25D', '').upcase)
      else
        expect(subject.name).to eq(described_class.name.split('::').last.upcase)
      end
    end
  end

  describe '#centroid' do
    specify do
      if subject_is_3d?
        expect(subject.centroid).to be_a(OGR::Point25D)
      else
        expect(subject.centroid).to be_a(OGR::Point)
      end
    end
  end

  describe '#dump_readable' do
    let(:output_file_path) { 'tmp/dump_readable_geometry_test' }

    context 'without file_path, with prefix' do
      it 'writes to stdout with the prefix' do
        # This doesn't pick up the STDOUT from GDAL for some reason
        # expect { subject.dump_readable(prefix: 'MEOW: ') }.to output("MEOW: #{subject.to_wkt}").to_stdout
        subject.dump_readable(output_file_path, prefix: 'MEOW: ')
        expect(File.read(output_file_path)).to start_with("MEOW: #{subject.name}")
      end
    end

    context 'without file_path, without prefix' do
      it 'writes out to stdout without a prefix' do
        # This doesn't pick up the STDOUT from GDAL for some reason
        # expect { subject.dump_readable(prefix: 'MEOW: ') }.to output("MEOW: #{subject.to_wkt}").to_stdout
        subject.dump_readable(output_file_path)
        expect(File.read(output_file_path)).to start_with(subject.name)
      end
    end
  end

  describe '#spatial_reference=, #spatial_reference' do
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

  describe '#transform!' do
    it 'assigns the new spatial reference' do
      ct = OGR::CoordinateTransformation.new(subject.spatial_reference,
                                             OGR::SpatialReference.new.import_from_epsg(3857))
      expect { subject.transform!(ct) }.to(change { subject.to_wkt })
    end
  end

  describe '#transform_to!' do
    it 'transforms the points into the new spatial reference' do
      expect { subject.transform_to!(OGR::SpatialReference.new.import_from_epsg(3857)) }
        .to(change { subject.to_wkt })
    end

    it 'sets the new spatial reference' do
      original = subject.spatial_reference.authority_code
      sr3857 = OGR::SpatialReference.new.import_from_epsg(3857)

      expect { subject.transform_to!(sr3857.clone) }
        .to(change { subject.spatial_reference.authority_code }.from(original).to(sr3857.authority_code))
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
        expect(subject.intersects?(described_class.new)).to eq false
      end
    end
  end

  describe '#empty?' do
    context 'when empty' do
      specify { expect(described_class.new).to be_empty }
    end

    context 'when with points' do
      specify { expect(subject).to_not be_empty }
    end
  end

  describe '#equals?' do
    context 'self equals other geometry' do
      specify { expect(subject.equals?(subject.clone)).to eq true }
    end

    context 'self does not equals other geometry' do
      specify { expect(subject.equals?(described_class.new)).to eq false }
    end
  end

  describe '#disjoint?' do
    context 'self disjoints other geometry' do
      specify { expect(subject.disjoint?(described_class.new)).to eq true }
    end

    context 'self does not disjoint other geometry' do
      specify { expect(subject.disjoint?(subject.clone)).to eq false }
    end
  end

  describe '#touches?' do
    context 'self touches other geometry' do
      skip
    end

    context 'self does not touch other geometry' do
      specify { expect(subject.touches?(described_class.new)).to eq false }
    end
  end

  describe '#crosses?' do
    context 'self crosses other geometry' do
      skip
    end

    context 'self does not cross other geometry' do
      specify { expect(subject.crosses?(described_class.new)).to eq false }
    end
  end

  describe '#within?' do
    context 'self is within other geometry' do
      let(:other) { subject.buffer(0.001) }
      specify { expect(subject.within?(other)).to eq true }
    end

    context 'self is not within other geometry' do
      specify { expect(subject.within?(described_class.new)).to eq false }
    end
  end

  describe '#contains?' do
    context 'self contains other geometry' do
      specify { expect(subject.contains?(subject.clone)).to eq true }
    end

    context 'self does not contain other geometry' do
      specify { expect(subject.contains?(described_class.new)).to eq false }
    end
  end

  describe '#overlaps?' do
    context 'self overlaps other geometry' do
      skip
    end

    context 'self does not overlap other geometry' do
      specify { expect(subject.overlaps?(described_class.new)).to eq false }
    end
  end

  describe '#valid?' do
    context 'self is valid' do
      specify { expect(subject).to be_valid }
    end

    context 'self is not valid' do
      skip
    end
  end

  describe '#ring?' do
    context 'self is a ring' do
      skip
    end

    context 'self is not a ring' do
      specify { expect(subject.ring?).to eq false }
    end
  end

  describe '#intersection' do
    specify { expect(subject.intersection(subject.clone)).to_not be_nil }
  end

  describe '#union' do
    context 'where there is no union' do
      specify do
        result = subject.union(described_class.new)

        case subject
        when OGR::CompoundCurve then expect(result).to be_a(OGR::CircularString)
        when OGR::CircularString then expect(result).to be_a(OGR::LineString)
        else
          expect(result).to be_a(described_class)
        end
      end
    end

    context 'where there is union' do
      specify { expect(subject.union(subject.clone)).to_not be_nil }
    end
  end

  describe '#close_rings!' do
    it 'does not raise' do
      subject.close_rings!
    end
  end

  describe '#difference' do
    context 'no difference' do
      specify { expect(subject.difference(subject.clone)).to be_a OGR::GeometryCollection }
    end

    context 'other is empty' do
      specify do
        diff = subject.difference(described_class.new)

        case subject
        when OGR::CircularString then expect(diff).to eq(subject.to_line_string)
        when OGR::MultiCurve then expect(diff).to eq(subject.to_multi_line_string)
        when OGR::CompoundCurve then expect(diff).to be_a(OGR::CircularString) # I don't get this, but oh well
        when OGR::MultiSurface then expect(diff).to eq(subject.to_multi_polygon)
        else
          expect(diff).to eq(subject)
        end
      end
    end
  end

  describe '#symmetric_difference' do
    context 'no difference' do
      specify { expect(subject.symmetric_difference(subject.clone)).to be_a OGR::GeometryCollection }
    end

    context 'other is empty' do
      specify do
        diff = subject.symmetric_difference(described_class.new)

        case subject
        when OGR::CircularString then expect(diff).to eq(subject.to_line_string)
        when OGR::MultiCurve then expect(diff).to eq(subject.to_multi_line_string)
        when OGR::CompoundCurve then expect(diff).to be_a(OGR::CircularString) # I don't get this, but oh well
        when OGR::MultiSurface then expect(diff).to eq(subject.to_multi_polygon)
        else
          expect(diff).to eq(subject)
        end
      end
    end
  end

  describe '#distance_to' do
    context 'self' do
      specify { expect(subject.distance_to(subject.clone)).to be_zero }
    end

    context 'other geometry is empty' do
      specify { expect(subject.distance_to(described_class.new)).to be_zero }
    end

    context 'other geometry is valid' do
      let(:other) { OGR::Point.new_from_coordinates(180, 180) }
      specify { expect(subject.distance_to(other)).to be > 0 }
    end
  end

  describe '#simplify' do
    context 'preserve_topology is true' do
      it 'returns a new geometry' do
        expect(subject.simplify(0.1, preserve_topology: true)).to be_a OGR::Geometry::GeometryMethods
      end
    end

    context 'preserve_topology is false' do
      it 'returns a new geometry' do
        expect(subject.simplify(0.1, preserve_topology: false)).to be_a OGR::Geometry::GeometryMethods
      end
    end
  end

  describe '#segmentize!' do
    it 'updates the geometry and returns self' do
      c_pointer_before = subject.c_pointer
      result = subject.segmentize!(1)
      expect(c_pointer_before).to eq(result.c_pointer)
    end
  end

  describe '#buffer' do
    it 'returns a new geometry' do
      expect(subject.buffer(0.001)).to be_a OGR::Geometry::GeometryMethods
    end
  end

  describe '#convex_hull' do
    it 'returns a new geometry' do
      expect(subject.convex_hull).to be_a OGR::Geometry::GeometryMethods
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

  describe '#to_iso_wkt' do
    it 'returns some String data' do
      wkt = subject.to_iso_wkt
      expect(wkt).to be_a String
      expect(wkt).to_not be_empty
    end
  end

  describe '#to_line_string' do
    it 'returns a geometry of some sort' do
      expect(subject.to_line_string).to be_a(OGR::Geometry::GeometryMethods)
    end
  end

  describe '#to_linear_ring' do
    it 'returns a geometry of some sort' do
      expect(subject.to_linear_ring).to be_a(OGR::Geometry::GeometryMethods)
    end
  end

  describe '#to_polygon' do
    it 'returns a geometry of some sort' do
      expect(subject.to_polygon).to be_a(OGR::Geometry::GeometryMethods)
    end
  end

  describe '#to_multi_point' do
    it 'returns a geometry of some sort' do
      expect(subject.to_multi_point).to be_a(OGR::Geometry::GeometryMethods)
    end
  end

  describe '#to_multi_line_string' do
    it 'returns a geometry of some sort' do
      expect(subject.to_multi_line_string).to be_a(OGR::Geometry::GeometryMethods)
    end
  end

  describe '#to_multi_polygon' do
    it 'returns a geometry of some sort' do
      expect(subject.to_multi_polygon).to be_a(OGR::Geometry::GeometryMethods)
    end
  end

  describe '#force_to_type' do
    it 'returns a geometry of some sort' do
      expect(subject.force_to_type(:wkbGeometryCollection)).to be_a(OGR::GeometryCollection)
    end
  end
end
