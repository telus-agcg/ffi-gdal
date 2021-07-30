# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiCurve do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) do
      OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,1 1,1 0,0 0)')
    end
  end
end
