# frozen_string_literal: true

require "ogr/geometry"

RSpec.describe OGR::Polygon do
  it_behaves_like "a geometry" do
    let(:geometry) { described_class.new }
  end

  it_behaves_like "a container geometry" do
    let(:child_geometry) { OGR::LinearRing.new }
  end

  describe "#to_multi_polygon" do
    subject(:polygon) { OGR::Geometry.create_from_wkt(wkt) }
    let(:wkt) { "POLYGON((10 10, 20 20, 30 30))" }

    it "returns a MultiPolygon" do
      expect(subject.to_multi_polygon).to be_a OGR::MultiPolygon
    end
  end
end
