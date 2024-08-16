# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Info do
  let(:src_dataset_path) do
    path = "../../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
    File.expand_path(path, __dir__)
  end

  let(:dataset) { GDAL::Dataset.open(src_dataset_path, "r") }
  after { dataset.close }

  describe ".perform" do
    context "when no options are provided" do
      it "returns GDALInfo text" do
        expect(described_class.perform(dataset: dataset)).to include("Driver: GTiff/GeoTIFF")
      end
    end

    context "when options are provided" do
      it "returns GDALInfo text with options applied" do
        options = GDAL::Utils::Info::Options.new(options: ["-json"])
        parsed_result = JSON.parse(described_class.perform(dataset: dataset, options: options))
        expect(parsed_result).to include(
          {
            "driverShortName" => "GTiff",
            "driverLongName" => "GeoTIFF",
            "size" => [101, 101]
          }
        )
      end
    end
  end
end
