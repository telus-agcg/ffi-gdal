# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::CircularString do
  subject { described_class.create_from_wkt('CIRCULARSTRING (0 0, 1 1, 42 42)') }

  it_behaves_like 'a geometry'
  it_behaves_like 'a curve geometry'
  it_behaves_like 'a simple curve geometry'
  it_behaves_like 'a 2D geometry'
end
