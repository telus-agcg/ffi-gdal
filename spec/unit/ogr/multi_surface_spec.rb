# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiSurface do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))') }

  it_behaves_like 'a geometry', 'Multi Surface'
  it_behaves_like 'a surface geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'not a geometry collection'

  describe '#union_cascaded' do
    subject { OGR::Geometry.create_from_wkt(wkt) }

    let(:wkt) do
      'MULTISURFACE(POLYGON((0 0,0 1,1 1,0 0)),CURVEPOLYGON((0 0,1 1,1 0,0 0)))'
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
