# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::CircularString do
  subject do
    cs = OGR::Geometry.create_from_wkt('CIRCULARSTRING (0 0, 1 1, 42 42)')
    cs.spatial_reference = OGR::SpatialReference.new.import_from_epsg(4326)
    cs
  end

  it_behaves_like 'a geometry', 'Circular String'
  it_behaves_like 'a curve geometry'
  it_behaves_like 'a simple curve geometry'
  it_behaves_like 'a 2D geometry'
  it_behaves_like 'not a geometry collection'
end
