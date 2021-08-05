# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::LinearRing do
  let(:linear_ring) do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_point(65.9, 0)
    g.add_point(9, -34.5)
    g.add_point(40, -20)
    g.add_point(65.9, 0)

    g
  end

  subject { linear_ring }

  it_behaves_like 'a curve geometry'
  it_behaves_like 'a simple curve geometry'
  it_behaves_like 'a line string'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'

  describe '#name' do
    subject { linear_ring.name }
    it { is_expected.to eq 'LINEARRING' }
  end

  describe '#point_count' do
    subject { linear_ring.point_count }
    it { is_expected.to eq 4 }
  end

  describe '#intersects?' do
    context 'other geometry is a point' do
      context 'inside the ring' do
        let(:other_geometry) do
          OGR::Point.new_from_coordinates(65.9, 1)
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
          OGR::Geometry.create_from_wkt('LINESTRING (100 100, 20 20)')
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
