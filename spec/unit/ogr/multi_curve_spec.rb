# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiCurve do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g.close_rings!
    g
  end

  let(:child_geometry) do
    OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,1 1,1 0,0 0)')
  end

  it_behaves_like 'a geometry', 'Multi Curve'
  it_behaves_like 'a multi-curve geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a container geometry'
  it_behaves_like 'not a geometry collection'
end
