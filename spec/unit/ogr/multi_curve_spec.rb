# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiCurve do
  subject do
    g = described_class.new
    g.add_geometry(child_geometry)
    g
  end

  let(:child_geometry) { OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,1 1,1 0,0 0)') }

  it_behaves_like 'a geometry'
  it_behaves_like 'a multi-curve geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'a container geometry'
end
