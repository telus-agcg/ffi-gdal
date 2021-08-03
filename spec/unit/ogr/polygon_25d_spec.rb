# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::Polygon25D do
  subject do
    g = described_class.new
    g.add_geometry(linear_ring)
    g
  end

  let(:linear_ring) do
    g = OGR::LinearRing.new
    g.import_from_wkt('LINEARRING(0 0 1,0 1 1,1 1 1,0 0 1)')
    g
  end

  it_behaves_like 'a geometry'
  it_behaves_like 'a 2.5D geometry'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'

  it_behaves_like 'a container geometry' do
    let(:child_geometry) { linear_ring.to_line_string }
  end
end
