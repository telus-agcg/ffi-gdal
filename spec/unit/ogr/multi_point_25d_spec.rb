# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::MultiPoint25D do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Point25D.new_from_coordinates(10, 20, 30) }

  it_behaves_like 'a geometry', '3D Multi Point'
  it_behaves_like 'a 2.5D geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'not a geometry collection'
  it_behaves_like 'a GML exporter'
  it_behaves_like 'a KML exporter'
  it_behaves_like 'a GeoJSON exporter'
end
