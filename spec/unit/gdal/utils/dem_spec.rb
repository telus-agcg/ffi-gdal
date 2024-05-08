# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::DEM do
  let(:src_dataset_path) do
    path = "../../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
    File.expand_path(path, __dir__)
  end

  let(:src_dataset) { GDAL::Dataset.open(src_dataset_path, "r") }
  after { src_dataset.close }

  describe ".perform" do
    let(:new_dataset_path) { "/vsimem/test-#{SecureRandom.uuid}.tif" }

    context "when no options are provided" do
      it "returns new dataset" do
        new_dataset = described_class.perform(
          dst_dataset_path: new_dataset_path,
          src_dataset: src_dataset,
          processing: "hillshade"
        )

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils::Info.perform(dataset: new_dataset)).not_to include("Block=256x256")

        new_dataset.close
      end

      it "returns new dataset in block" do
        described_class.perform(
          dst_dataset_path: new_dataset_path,
          src_dataset: src_dataset,
          processing: "hillshade"
        ) do |new_dataset|
          expect(new_dataset).to be_a(GDAL::Dataset)
        end
      end
    end

    context "when options are provided" do
      it "returns new dataset with options applied" do
        options = GDAL::Utils::DEM::Options.new(options: ["-of", "GTiff", "-co", "TILED=YES"])

        new_dataset = described_class.perform(
          dst_dataset_path: new_dataset_path, src_dataset: src_dataset, processing: "hillshade", options: options
        )

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("Block=256x256")

        new_dataset.close
      end
    end

    context "when operation fails with GDAL internal exception" do
      it "raises exception" do
        expect do
          described_class.perform(
            dst_dataset_path: new_dataset_path,
            src_dataset: src_dataset,
            processing: "hillshade123"
          )
        end.to raise_exception(
          ArgumentError, "Invalid processing"
        )
      end

      it "raises exception" do
        options = GDAL::Utils::DEM::Options.new(options: ["-b", "100"])

        expect do
          described_class.perform(
            dst_dataset_path: new_dataset_path,
            src_dataset: src_dataset,
            processing: "hillshade",
            options: options
          )
        end.to raise_exception(
          ArgumentError, "Unable to fetch band #100"
        )
      end
    end

    context "color-relief" do
      it "returns new dataset with color-relief applied" do
        Tempfile.create(["color", ".txt"]) do |color_file|
          color_file.write("0 255 0 0\n1 0 255 0\n2 0 0 255")
          color_file.flush

          new_dataset = described_class.perform(
            dst_dataset_path: new_dataset_path,
            src_dataset: src_dataset,
            processing: "color-relief",
            color_filename: color_file.path
          )

          expect(new_dataset).to be_a(GDAL::Dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).not_to include("COMPRESSION=DEFLATE")

          new_dataset.close
        end
      end
    end
  end
end
