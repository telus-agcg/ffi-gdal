# frozen_string_literal: true

require "ogr/spatial_reference"

RSpec.describe OGR::SpatialReference do
  describe "#import_from_epsg" do
    context "valid code" do
      it "updates self's info" do
        if GDAL.version_num < "3000000"
          # NOTE: GDAL 2 returns an empty string instead of raise exception.
          expect(subject.to_wkt).to eq("")
        else
          expect { subject.to_wkt }.to raise_exception(OGR::Failure, "Unable to export to WKT")
        end

        subject.import_from_epsga(4326)

        expect(subject.to_wkt).to start_with("GEOGCS[\"WGS 84\",DATUM[\"")
      end

      it "treats 4326 as lat/lon" do
        subject.import_from_epsg(4326)

        if GDAL.version_num < "3000000"
          # NOTE: Looks like it should be `true`, as in GDAL 3.
          # By some reason GDAL 2 returns `false`.
          expect(subject.epsg_treats_as_lat_long?).to eq false
        else
          expect(subject.epsg_treats_as_lat_long?).to eq true
        end
      end
    end

    context "invalid code" do
      it "raises an exception" do
        if GDAL.version_num < "3000000"
          expect { subject.import_from_epsg(1_231_234) }.to raise_exception(
            GDAL::UnsupportedOperation
          )
        else
          expect { subject.import_from_epsg(1_231_234) }.to raise_exception(
            GDAL::Error, "PROJ: proj_create_from_database: crs not found"
          )
        end
      end
    end
  end

  describe "#import_from_epsga" do
    it "updates self's info" do
      if GDAL.version_num < "3000000"
        # NOTE: GDAL 2 returns an empty string instead of raise exception.
        expect(subject.to_wkt).to eq("")
      else
        expect { subject.to_wkt }.to raise_exception(OGR::Failure, "Unable to export to WKT")
      end

      subject.import_from_epsga(4326)

      expect(subject.to_wkt).to start_with("GEOGCS[\"WGS 84\",DATUM[\"")
    end

    it "treats 4326 as lat/lon" do
      subject.import_from_epsga(4326)
      expect(subject.epsg_treats_as_lat_long?).to eq true
    end
  end
end
