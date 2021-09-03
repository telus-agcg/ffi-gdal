# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::Polygon do
  subject(:polygon) do
    g = described_class.new(spatial_reference: OGR::SpatialReference.create.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) do
    g = OGR::LinearRing.new
    g.import_from_wkt('LINEARRING(0 0,0 1,1 1,0 0)')

    g
  end

  it_behaves_like 'a geometry', 'Polygon'
  it_behaves_like 'a container geometry'
  it_behaves_like 'a surface geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'not a geometry collection'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
