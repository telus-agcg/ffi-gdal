# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::Point25D do
  subject { OGR::Geometry.create_from_wkt(wkt) }
  let(:wkt) { 'POINT(1 2 3)' }

  it_behaves_like 'a geometry'
  it_behaves_like 'a 2.5D geometry'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
