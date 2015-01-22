require 'spec_helper'

RSpec.describe OGR::GeometryCollection do
  it_behaves_like 'a polygon from edges'

  describe '#collection?' do
    it 'returns true' do
      expect(subject.collection?).to eq true
    end
  end

  describe '#geometry_at' do
    context 'geometry exists at the index' do
      let(:polygon) do
        OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
      end

      subject do
        gc = described_class.new
        gc.add_geometry(polygon)
        gc
      end

      it 'returns the geometry' do
        expect(subject.geometry_at(0)).to be_a OGR::Polygon
      end
    end

    context 'no geometries' do
      it 'returns nil' do
        expect(subject.geometry_at(0)).to be_nil
      end
    end
  end

  describe '#to_polygon' do
    let(:polygon) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end

    subject do
      gc = described_class.new
      gc.add_geometry(polygon)
      gc
    end

    it 'returns a Polygon' do
      expect(subject.to_polygon).to be_a OGR::Polygon
    end
  end

  describe '#to_multi_polygon' do
    let(:polygon1) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end

    let(:polygon2) do
      OGR::Geometry.create_from_wkt('POLYGON ((10 10,10 11,11 11,11 10,10 10))')
    end

    subject do
      gc = described_class.new
      gc.add_geometry(polygon1)
      gc.add_geometry(polygon2)
      gc
    end

    it 'returns a MultiPolygon' do
      expect(subject.to_multi_polygon).to be_a OGR::MultiPolygon
    end
  end
end