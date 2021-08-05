# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::LineString25D do
  subject do
    g = OGR::Geometry.create_from_wkt(wkt)
    g.spatial_reference = OGR::SpatialReference.new.import_from_epsg(4326)
    g
  end

  let(:wkt) { 'LINESTRING (0 1 2, 1 20 30, 2 40 50)' }

  it_behaves_like 'a curve geometry'
  it_behaves_like 'a 2.5D geometry'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
