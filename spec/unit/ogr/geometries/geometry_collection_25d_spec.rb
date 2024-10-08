# frozen_string_literal: true

require "ogr"

RSpec.describe OGR::GeometryCollection25D do
  describe "#type" do
    context "when created with data" do
      subject { OGR::Geometry.create_from_wkt(wkt) }
      let(:wkt) { "GEOMETRYCOLLECTION(POINT(4 6 8),LINESTRING(4 6 8,7 10 11))" }

      it "returns :wkbGeometryCollection25D" do
        expect(subject.type).to eq :wkbGeometryCollection25D
      end
    end

    context "when created without data" do
      subject { described_class.new }

      it "returns :wkbGeometryCollection" do
        skip "This spec only for GDAL before 3.8" if GDAL.version_num >= "3080000"

        expect(subject.type).to eq :wkbGeometryCollection
      end

      it "returns :wkbGeometryCollection25D" do
        skip "This spec only for GDAL 3.8+" if GDAL.version_num < "3080000"

        expect(subject.type).to eq :wkbGeometryCollection25D
      end
    end
  end
end
