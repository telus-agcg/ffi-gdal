# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiLineString do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Geometry.create_from_wkt('LINESTRING(65 0,9 -34,40 -20,65 0)') }

  it_behaves_like 'a geometry', 'Multi Line String'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a multi-curve geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'not a geometry collection'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'

  describe '#polygonize' do
    it 'returns a geometry from the set of sparse edges' do
      expect(subject.polygonize).to be_a OGR::GeometryCollection
    end
  end
end
