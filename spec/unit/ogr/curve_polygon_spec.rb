# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::CurvePolygon do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Geometry.create_from_wkt('COMPOUNDCURVE(CIRCULARSTRING (0 0,1 1,2 0),(2 0,0 0))') }

  it_behaves_like 'a geometry'
  it_behaves_like 'a surface geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a container geometry'
end
