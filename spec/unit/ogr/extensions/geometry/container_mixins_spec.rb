# frozen_string_literal: true

require 'ogr/extensions/geometry/container_mixins'

RSpec.describe OGR::GeometryCollection do
  describe '#collection' do
    it { is_expected.to be_collection }
  end

  describe '#each' do
    subject { described_class.new.each }
    it { is_expected.to be_a Enumerator }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end
  end
end

RSpec.describe OGR::MultiPolygon do
  it_behaves_like 'a container geometry' do
    let(:child_geometry) { OGR::Polygon.new }
  end
end

RSpec.describe OGR::MultiLineString do
  it_behaves_like 'a container geometry' do
    let(:child_geometry) do
      OGR::LineString.new
    end
  end
end

RSpec.describe OGR::MultiPoint do
  it_behaves_like 'a container geometry' do
    let(:child_geometry) { OGR::Point.new }
    let(:edge_geometry1) { OGR::Point.new }
    let(:edge_geometry2) { OGR::Point.new }
  end
end

RSpec.describe OGR::Polygon do
  it_behaves_like 'a container geometry' do
    let(:child_geometry) { OGR::LinearRing.new }
  end
end
