# frozen_string_literal: true

require "ogr/spatial_reference"

RSpec.describe OGR::SpatialReference do
  describe "#to_erm" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns a Hash" do
        expect(subject.to_erm).to eq(projection_name: "GEODETIC", datum_name: "WGS72DOD", units: "METERS")
      end
    end

    context "empty SRS" do
      it "raises an OGR::UnsupportedSRS" do
        expect { subject.to_erm }.to raise_exception OGR::UnsupportedSRS
      end
    end
  end

  describe "#to_mapinfo" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns the string" do
        expect(subject.to_mapinfo).to start_with "Earth Projection"
      end
    end

    context "empty SRS" do
      it 'returns a "NonEarth Units" message' do
        expect(subject.to_mapinfo).to start_with "NonEarth Units"
      end
    end
  end

  describe "#to_pci" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns a Hash" do
        expect(subject.to_pci).to eq(
          projection: "LONG/LAT    D001",
          units: "DEGREE",
          projection_parameters: []
        )
      end
    end

    context "empty SRS" do
      it "returns default values" do
        expect(subject.to_pci).to eq(
          projection: "LONG/LAT    E012",
          units: "DEGREE",
          projection_parameters: []
        )
      end
    end
  end

  describe "#to_proj4" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns a PROJ4 String" do
        expected_proj4 =
          if GDAL.version_num >= "3000100" && OGR::SpatialReference.proj_version.major > 6
            # Returns official PROJ4 string for EPSG:4322 (https://epsg.io/4322).
            "+proj=longlat +ellps=WGS72 +no_defs"
          else
            # NOTE: The result is slightly different for different versions of PROJ4.
            # Just documenting the difference here.
            "+proj=longlat +ellps=WGS72 +towgs84=0,0,4.5,0,0,0.554,0.2263 +no_defs"
          end

        expect(subject.to_proj4.strip).to eq(expected_proj4)
      end
    end

    context "empty SRS" do
      it "raises an exception" do
        if GDAL.version_num < "3000000"
          expect { subject.to_proj4 }.to raise_exception(GDAL::UnsupportedOperation)
        else
          expect { subject.to_proj4 }.to raise_exception(OGR::Failure, "Unable to export to PROJ.4")
        end
      end
    end
  end

  describe "#to_wkt" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns a well-known text String" do
        expect(subject.to_wkt).to start_with 'GEOGCS["WGS 72",DATUM["'
      end
    end

    context "empty SRS" do
      it "raises an exception" do
        if GDAL.version_num < "3000000"
          # NOTE: GDAL 2 returns an empty string instead of raise exception.
          expect(subject.to_wkt).to eq("")
        else
          expect { subject.to_wkt }.to raise_exception(OGR::Failure, "Unable to export to WKT")
        end
      end
    end
  end

  describe "#to_pretty_wkt" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns a formatted well-known text String" do
        expect(subject.to_wkt).to start_with %(GEOGCS["WGS 72",DATUM[")
      end
    end

    context "empty SRS" do
      it "raises an exception" do
        if GDAL.version_num < "3000000"
          # NOTE: GDAL 2 returns an empty string instead of raise exception.
          expect(subject.to_pretty_wkt).to eq("")
        else
          expect { subject.to_pretty_wkt }.to raise_exception(OGR::Failure, "Unable to export to pretty WKT")
        end
      end
    end
  end

  describe "#to_xml" do
    context "known projection" do
      subject { described_class.new.import_from_epsg(4322) }

      it "returns an XML string" do
        expect(subject.to_xml).to start_with '<gml:GeographicCRS gml:id="ogrcrs1">'
      end
    end

    context "empty SRS" do
      it "raises an OGR::UnsupportedSRS" do
        expect { subject.to_xml }.to raise_exception OGR::UnsupportedSRS
      end
    end
  end

  describe "#to_gml" do
    it { is_expected.to respond_to :to_gml }
  end
end
