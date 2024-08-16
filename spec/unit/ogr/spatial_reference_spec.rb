# frozen_string_literal: true

require "ogr/spatial_reference"

RSpec.describe OGR::SpatialReference do
  subject do
    described_class.new.import_from_epsg(3819)
  end

  describe ".proj_version" do
    it "returns a Version with proper attributes" do
      skip "Only available starting GDAL 3.0.1" if GDAL.version_num < "3000100"

      version = described_class.proj_version

      expect(version.major).to be_an_instance_of(Integer)
      expect(version.minor).to be_an_instance_of(Integer)
      expect(version.patch).to be_an_instance_of(Integer)
    end
  end

  # NOTE: `.projection_methods` was removed without a replacement in GDAL 3.0.
  projection_methods_skip_reason = GDAL.version_num >= "3000000" ? "GDAL 3 removed this method" : false
  describe ".projection_methods", skip: projection_methods_skip_reason do
    context "strip underscores" do
      subject { described_class.projection_methods(strip_underscores: true) }

      it "returns an Array of Strings" do
        expect(subject).to be_an Array
        expect(subject.first).to be_a String
      end

      it "has Strings with no underscores" do
        expect(subject).to(satisfy { |v| !v.include?("_") })
      end
    end

    context "not strip underscores" do
      subject { described_class.projection_methods(strip_underscores: false) }

      it "returns an Array of Strings" do
        expect(subject).to be_an Array
        expect(subject.first).to be_a String
      end

      it "has Strings with underscores" do
        expect(subject).to(satisfy { |v| !v.include?(" ") })
      end
    end
  end

  describe "#axis_mapping_strategy" do
    it "returns default OAMS_AUTHORITY_COMPLIANT strategy" do
      skip "Only available in GDAL 3" if GDAL.version_num < "3000000"

      expect(subject.axis_mapping_strategy).to eq(:OAMS_AUTHORITY_COMPLIANT)
    end
  end

  describe "#axis_mapping_strategy=" do
    it "sets the axis_mapping_strategy" do
      skip "Only available in GDAL 3" if GDAL.version_num < "3000000"

      subject.axis_mapping_strategy = :OAMS_TRADITIONAL_GIS_ORDER
      expect(subject.axis_mapping_strategy).to eq(:OAMS_TRADITIONAL_GIS_ORDER)
    end
  end

  describe "#copy_geog_cs_from" do
    let(:other_srs) { OGR::SpatialReference.new.import_from_epsg(4326) }

    it "copies the info over" do
      subject.copy_geog_cs_from(other_srs)
      expect(subject.to_wkt).to eq other_srs.to_wkt
    end
  end
end
