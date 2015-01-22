require 'spec_helper'

RSpec.describe OGR::MultiPolygon do
  subject { OGR::Geometry.create_from_wkt(wkt) }
  let(:wkt) do
    'MULTIPOLYGON(((0 0,0 1,1 1,0 0)),((0 0,1 1,1 0,0 0)))'
  end

  describe '#to_polygon' do
    it 'returns a Polygon' do
      expect(subject.to_polygon).to be_a OGR::Polygon
    end
  end

  describe '#union_cascaded' do
    let(:wkt) do
      'MULTIPOLYGON(((0 0,0 1,1 1,0 0)),((0 0,1 1,1 0,0 0)))'
    end

    it 'returns a Geometry' do
      expect(subject.union_cascaded).to be_a OGR::Polygon
    end

    it 'does a union on the geometry' do
      expect(subject.union_cascaded.to_wkt).
        to eq 'POLYGON ((0 0,0 1,1 1,1 0,0 0))'
    end
  end
end