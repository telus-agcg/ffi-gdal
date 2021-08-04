# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::GeometryCollection25D do
  subject do
    g = described_class.new
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Geometry.create_from_wkt('LINESTRING(4 6 8,7 10 11))') }

  it_behaves_like 'a geometry'
  it_behaves_like 'a 2.5D geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
