# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiPoint do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Point.new_from_coordinates(1, 2) }

  it_behaves_like 'a geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
