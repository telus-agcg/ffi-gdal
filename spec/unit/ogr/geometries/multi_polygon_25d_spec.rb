# frozen_string_literal: true

require "ogr"

RSpec.describe OGR::MultiPolygon25D do
  describe "#type" do
    context "when created with data" do
      subject { OGR::Geometry.create_from_wkt(wkt) }
      let(:wkt) { "MULTIPOLYGON(((0 0 1,0 1 1,1 1 1,0 0 1)),((0 0 5,1 1 5,1 0 5,0 0 5)))" }

      it "returns :wkbMultiPolygon25D" do
        expect(subject.type).to eq :wkbMultiPolygon25D
      end
    end

    context "when created without data" do
      subject { described_class.new }

      it "returns :wkbMultiPolygon" do
        skip "This spec only for GDAL before 3.8" if GDAL.version_num >= "3080000"

        expect(subject.type).to eq :wkbMultiPolygon
      end

      it "returns :wkbMultiPolygon25D" do
        skip "This spec only for GDAL 3.8+" if GDAL.version_num < "3080000"

        expect(subject.type).to eq :wkbMultiPolygon25D
      end
    end
  end
end
