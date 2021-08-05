# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::Point25D do
  subject do
    g = OGR::Geometry.create_from_wkt(wkt)
    g.spatial_reference = OGR::SpatialReference.new.import_from_epsg(4326)
    g
  end

  let(:wkt) { 'POINT(1 2 3)' }

  it_behaves_like 'a geometry', '3D Point'
  it_behaves_like 'a 2.5D geometry'
  it_behaves_like 'not a geometry collection'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
