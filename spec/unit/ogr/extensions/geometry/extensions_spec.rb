# frozen_string_literal: true

require "ogr/extensions/geometry/extensions"
OGR::MultiPolygon.include(OGR::Geometry)

RSpec.describe OGR::Geometry do
  describe "#utm_zone" do
    let(:geom) { OGR::Geometry.create_from_wkt(wkt) }

    let(:wkt) do
      "LINESTRING (100 100, 20 20, 30 30, 100 100)"
    end

    context "no spatial_reference" do
      subject { geom.utm_zone }
      it { is_expected.to be_nil }
    end

    context "SRID is 4326" do
      subject { geom.utm_zone }
      before { geom.spatial_reference = OGR::SpatialReference.new.import_from_epsg(4326) }

      context "geometry is valid" do
        it { is_expected.to eq(36) }
      end

      context "geometry is invalid" do
        let(:wkt) do
          "MULTIPOLYGON (((100 100, 20 20, 30 30, 100 100)))"
        end

        it { is_expected.to be_nil }
      end
    end

    context "SRID is not 4326" do
      before { geom.spatial_reference = OGR::SpatialReference.new.import_from_epsg(3857) }

      it "transforms to 4326 then figures out the zone" do
        duped_subject = geom.clone
        expect(geom).to receive(:clone).and_return(duped_subject)
        expect(duped_subject).to receive(:transform_to!).and_call_original

        geom.utm_zone
      end
    end
  end
end
