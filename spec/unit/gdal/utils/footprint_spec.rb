# frozen_string_literal: true

require "spec_helper"
require "gdal"
require "ogr"

RSpec.describe GDAL::Utils::Footprint do
  let(:src_dataset_path) do
    path = "../../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
    File.expand_path(path, __dir__)
  end

  let(:src_dataset) { GDAL::Dataset.open(src_dataset_path, "r") }

  after { src_dataset.close }

  describe ".perform" do
    let(:new_dataset_path) { "/vsimem/test-#{SecureRandom.uuid}.tif" }

    context "when no options are provided" do
      it "raises exceptions (size or resolution must be provided)" do
        expect do
          described_class.perform(dst_dataset_path: new_dataset_path, src_dataset: src_dataset)
        end.to raise_exception(GDAL::Error, "Bands are missing")
      end
    end

    context "when options are provided" do
      it "returns new dataset with options applied" do
        options = GDAL::Utils::Footprint::Options.new(options: ["-b", "1"])

        new_dataset = described_class.perform(
          dst_dataset_path: new_dataset_path, src_dataset: src_dataset, options: options
        )

        # Not sure if will be always it
        expect(new_dataset).to be_a(OGR::DataSource)
        expect(new_dataset.driver.name).to eq("GeoJSON")

        new_dataset.close
      end
    end
  end
end
