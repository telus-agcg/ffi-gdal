# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::CompoundCurve do
  subject do
    g = described_class.new(spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326))
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Geometry.create_from_wkt('CIRCULARSTRING (0 0,0 1,1 1)') }

  it_behaves_like 'a geometry'
  it_behaves_like 'a curve geometry'
  it_behaves_like 'a container geometry'
end
