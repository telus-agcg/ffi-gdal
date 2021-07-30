# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiSurface do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end
  end
end
