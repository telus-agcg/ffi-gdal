# frozen_string_literal: true

require "ogr"

RSpec.describe OGR::LineString25D do
  describe "#type" do
    context "when created with data" do
      subject { OGR::Geometry.create_from_wkt(wkt) }
      let(:wkt) { "LINESTRING(1 2 3, 2 2 3)" }

      it "returns :wkbLineString25D" do
        expect(subject.type).to eq :wkbLineString25D
      end
    end

    context "when created without data" do
      subject { described_class.new }

      it "returns :wkbLineString" do
        skip "This spec only for GDAL before 3.8" if GDAL.version_num >= "3080000"

        expect(subject.type).to eq :wkbLineString
      end

      it "returns :wkbLineString25D" do
        skip "This spec only for GDAL 3.8+" if GDAL.version_num < "3080000"

        expect(subject.type).to eq :wkbLineString25D
      end
    end
  end
end
