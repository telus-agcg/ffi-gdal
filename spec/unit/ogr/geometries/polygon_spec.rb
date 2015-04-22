require 'spec_helper'
require 'ogr/geometry'

RSpec.describe OGR::Polygon do
  subject(:polygon) { OGR::Geometry.create_from_wkt(wkt) }
  let(:wkt) { 'POLYGON((100 100, 200 200, 300 300))' }

  it_behaves_like 'a geometry' do
    let(:geometry) { polygon }
  end

  describe '#to_multi_polygon' do
    it 'returns a MultiPolygon' do
      expect(subject.to_multi_polygon).to be_a OGR::MultiPolygon
    end
  end
end
