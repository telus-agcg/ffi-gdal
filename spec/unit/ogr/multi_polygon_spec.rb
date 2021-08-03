# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiPolygon do
  subject do
    g = described_class.new
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Polygon.create_from_wkt('POLYGON((4 6,7 10,12 40,4 6))') }

  it_behaves_like 'a geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'

  describe '#to_polygon' do
    it 'returns a Polygon' do
      expect(subject.to_polygon).to be_a OGR::Polygon
    end
  end

  describe '#union_cascaded' do
    subject { OGR::Geometry.create_from_wkt(wkt) }

    let(:wkt) do
      'MULTIPOLYGON(((0 0,0 1,1 1,0 0)),((0 0,1 1,1 0,0 0)))'
    end

    it 'returns a Geometry' do
      expect(subject.union_cascaded).to be_a OGR::Polygon
    end

    it 'does a union on the geometry' do
      expect(subject.union_cascaded.to_wkt)
        .to eq 'POLYGON ((0 0,0 1,1 1,1 0,0 0))'
    end
  end
end
