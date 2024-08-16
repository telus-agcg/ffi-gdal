# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Nearblack do
  let(:src_dataset_path) do
    path = "../../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
    File.expand_path(path, __dir__)
  end

  let(:src_dataset) { GDAL::Dataset.open(src_dataset_path, "r") }
  after { src_dataset.close }

  describe ".perform" do
    context "when dst_dataset_path used" do
      let(:dst_dataset_path) { "/vsimem/test-#{SecureRandom.uuid}.tif" }

      context "when no options are provided" do
        it "returns new dataset" do
          new_dataset = described_class.perform(dst_dataset_path: dst_dataset_path, src_dataset: src_dataset)

          expect(new_dataset).to be_a(GDAL::Dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).not_to include("Block=256x256")

          new_dataset.close
        end

        it "returns new dataset in block" do
          described_class.perform(dst_dataset_path: dst_dataset_path, src_dataset: src_dataset) do |new_dataset|
            expect(new_dataset).to be_a(GDAL::Dataset)
          end
        end
      end

      context "when options are provided" do
        it "returns new dataset with options applied" do
          options = GDAL::Utils::Nearblack::Options.new(options: ["-co", "TILED=YES", "-near", "10"])

          new_dataset = described_class.perform(
            dst_dataset_path: dst_dataset_path, src_dataset: src_dataset, options: options
          )

          expect(new_dataset).to be_a(GDAL::Dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("Block=256x256")

          new_dataset.close
        end
      end

      context "when operation fails without GDAL internal exception" do
        it "raises exception" do
          options = GDAL::Utils::Nearblack::Options.new(options: ["-of", "UnknownFormat123"])

          expect do
            described_class.perform(dst_dataset_path: dst_dataset_path, src_dataset: src_dataset, options: options)
          end.to raise_exception(
            GDAL::Error, "GDALNearblack failed."
          )
        end
      end
    end

    context "when dst_dataset used" do
      context "when no options are provided" do
        it "returns dst_dataset with changes applied" do
          dst_dataset_path = "/vsimem/test-#{SecureRandom.uuid}.tif"
          dst_dataset = GDAL::Utils::Translate.perform(dst_dataset_path: dst_dataset_path, src_dataset: src_dataset)

          result_dataset = described_class.perform(dst_dataset: dst_dataset, src_dataset: src_dataset)
          expect(result_dataset).to eq(dst_dataset)

          dst_dataset.close
        end
      end

      context "when operation fails with GDAL internal exception" do
        it "raises exception" do
          dst_dataset_path = "/vsimem/test-#{SecureRandom.uuid}.tif"
          dst_dataset = GDAL::Utils::Translate.perform(
            dst_dataset_path: dst_dataset_path,
            src_dataset: src_dataset,
            options: GDAL::Utils::Translate::Options.new(options: ["-outsize", "50%", "50%"])
          )

          expect do
            described_class.perform(dst_dataset: dst_dataset, src_dataset: src_dataset)
          end.to raise_exception(
            GDAL::Error, "The dimensions of the output dataset don't match the dimensions of the input dataset."
          )

          dst_dataset.close
        end
      end
    end
  end
end
