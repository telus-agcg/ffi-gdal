require 'spec_helper'

describe OGR::LinearRing do
  let(:linear_ring) do
    g = OGR::Geometry.create(:wkbLinearRing)
    g.add_point(0, 0)
    g.add_point(0, 10)
    g.add_point(10, 10)
    g.add_point(10, 0)
    g.add_point(0, 0)

    g
  end

  subject { linear_ring }

  describe '#closed' do
    it { is_expected.to be_closed }
  end

  describe '#dimension' do
    subject { linear_ring.dimension }
    it { is_expected.to eq 1 }
  end

  describe '#coordinate_dimension' do
    subject { linear_ring.coordinate_dimension }
    it { is_expected.to eq 2 }
  end

  describe '#envelope' do
    subject { linear_ring.envelope }
    it { is_expected.to be_a OGR::Envelope }
  end

  describe '#type' do
    subject { linear_ring.type }
    it { is_expected.to eq :wkbLineString }
  end

  describe '#type_to_name' do
    subject { linear_ring.type }
    it { is_expected.to eq :wkbLineString }
  end

  describe '#name' do
    subject { linear_ring.name }
    it { is_expected.to eq 'LINEARRING' }
  end

  describe '#count' do
    subject { linear_ring.count }
    it { is_expected.to be_zero  }
  end

  describe '#point_count' do
    subject { linear_ring.point_count }
    it { is_expected.to eq 5  }
  end

  describe '#intersects?' do
    context 'other geometry is a point' do
      context 'inside the ring' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('POINT (0 1)')
        end

        subject { linear_ring.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end

      context 'on a vertex of the ring' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('POINT (0 0)')
        end

        subject { linear_ring.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end
    end

    context 'other geometry is a line string' do
      context 'outside the ring' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('LINESTRING (100 100, 200 200)')
        end

        subject { linear_ring.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end

      context 'ends on a vertex' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('LINESTRING (50 50, 0 0)')
        end

        subject { linear_ring.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end

      context 'passes across the boundary' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('LINESTRING (15 5, 5 5)')
        end

        subject { linear_ring.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end
    end
  end
end
