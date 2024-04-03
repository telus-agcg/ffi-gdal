# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Warp do
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
          new_dataset = described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset])

          expect(new_dataset).to be_a(GDAL::Dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).not_to include("WGS 84 / Pseudo-Mercator")

          new_dataset.close
        end

        it "returns new dataset in block" do
          described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset]) do |new_dataset|
            expect(new_dataset).to be_a(GDAL::Dataset)
          end
        end
      end

      context "when options are provided" do
        it "returns new dataset with options applied" do
          options = GDAL::Utils::Warp::Options.new(options: ["-t_srs", "EPSG:3857"])

          new_dataset = described_class.perform(
            dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset], options: options
          )

          expect(new_dataset).to be_a(GDAL::Dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("WGS 84 / Pseudo-Mercator")

          new_dataset.close
        end
      end

      context "when operation fails with GDAL internal exception" do
        it "raises exception" do
          expect do
            described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [])
          end.to raise_exception(
            GDAL::Error, "No usable source images."
          )
        end
      end

      context "when operation fails without GDAL internal exception" do
        it "raises exception" do
          options = GDAL::Utils::Warp::Options.new(options: ["-of", "UnknownFormat123"])

          expect do
            described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset], options: options)
          end.to raise_exception(
            GDAL::Error, "GDALWarp failed."
          )
        end
      end
    end

    context "when dst_dataset used" do
      let(:dst_dataset) do
        dataset = GDAL::Driver.by_name("GTiff").create_dataset("/vsimem/test-#{SecureRandom.uuid}.tif", 100, 100)

        dataset.projection = OGR::SpatialReference.new.import_from_epsg(3857).to_wkt
        dataset.geo_transform = GDAL::GeoTransform.new.tap do |gt|
          gt.x_origin = 0
          gt.y_origin = 0
          gt.pixel_width = 10_000
          gt.pixel_height = -10_000
        end

        dataset
      end
      after { dst_dataset.close }

      context "when no options are provided" do
        it "returns dst_dataset with changes applied" do
          new_dataset = described_class.perform(dst_dataset: dst_dataset, src_datasets: [src_dataset])

          expect(new_dataset).to eq(dst_dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("WGS 84 / Pseudo-Mercator")
        end
      end

      context "when options are provided" do
        it "returns dst_dataset with changes applied with options" do
          options = GDAL::Utils::Warp::Options.new(options: ["-t_srs", "EPSG:3857"])

          new_dataset = described_class.perform(
            dst_dataset: dst_dataset, src_datasets: [src_dataset], options: options
          )

          expect(new_dataset).to eq(dst_dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("WGS 84 / Pseudo-Mercator")
        end
      end

      context "when operation fails with GDAL internal exception" do
        it "raises exception" do
          options = GDAL::Utils::Warp::Options.new(options: ["-cutline", "/vsimem/unknown.shp"])

          expect do
            described_class.perform(dst_dataset: dst_dataset, src_datasets: [src_dataset], options: options)
          end.to raise_exception(
            GDAL::Error, "Cannot open /vsimem/unknown.shp."
          )
        end
      end
    end
  end
end
