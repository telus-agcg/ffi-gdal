# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Translate do
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
        new_dataset = described_class.perform(dst_dataset_path: new_dataset_path, src_dataset: src_dataset)

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils::Info.perform(dataset: new_dataset)).not_to include("COMPRESSION=DEFLATE")

        new_dataset.close
      end

      it "returns new dataset in block" do
        described_class.perform(dst_dataset_path: new_dataset_path, src_dataset: src_dataset) do |new_dataset|
          expect(new_dataset).to be_a(GDAL::Dataset)
        end
      end
    end

    context "when options are provided" do
      it "returns new dataset with options applied" do
        options = GDAL::Utils::Translate::Options.new(options: ["-co", "COMPRESS=DEFLATE"])

        new_dataset = described_class.perform(
          dst_dataset_path: new_dataset_path, src_dataset: src_dataset, options: options
        )

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("COMPRESSION=DEFLATE")

        new_dataset.close
      end
    end

    context "when operation fails with GDAL internal exception" do
      it "raises exception" do
        options = GDAL::Utils::Translate::Options.new(options: ["-b", "100"])

        expect do
          described_class.perform(dst_dataset_path: new_dataset_path, src_dataset: src_dataset, options: options)
        end.to raise_exception(
          GDAL::Error, "Band 100 requested, but only bands 1 to 1 available."
        )
      end
    end
  end
end
