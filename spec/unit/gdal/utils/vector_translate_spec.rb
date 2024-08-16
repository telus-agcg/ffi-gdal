# frozen_string_literal: true

require "spec_helper"
require "gdal"
require "ogr"

RSpec.describe GDAL::Utils::VectorTranslate do
  let(:src_dataset_path) do
    path = "../../../../spec/support/shapefiles/states_21basic/states.shp"
    File.expand_path(path, __dir__)
  end

  let(:src_dataset) { OGR::DataSource.open(src_dataset_path, "r") }
  after { src_dataset.close }

  describe ".perform" do
    context "when dst_dataset_path used" do
      let(:dst_dataset_path) { "/vsimem/test-#{SecureRandom.uuid}.geojson" }

      context "when no options are provided" do
        it "returns new dataset" do
          new_dataset = described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset])

          expect(new_dataset).to be_a(OGR::DataSource)
          expect(new_dataset.driver.name).to eq("GeoJSON")
          expect(new_dataset.layer(0).geometry_type).to eq(:wkbPolygon)

          new_dataset.close
        end

        it "returns new dataset in block" do
          described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset]) do |new_dataset|
            expect(new_dataset).to be_a(OGR::DataSource)
          end
        end
      end

      context "when options are provided" do
        it "returns new dataset with options applied" do
          options = GDAL::Utils::VectorTranslate::Options.new(options: ["-nlt", "MULTIPOLYGON"])

          new_dataset = described_class.perform(
            dst_dataset_path: dst_dataset_path, src_datasets: [src_dataset], options: options
          )

          expect(new_dataset).to be_a(OGR::DataSource)
          expect(new_dataset.layer(0).geometry_type).to eq(:wkbMultiPolygon)

          new_dataset.close
        end
      end

      context "when operation fails with GDAL internal exception" do
        it "raises exception" do
          expect do
            described_class.perform(dst_dataset_path: dst_dataset_path, src_datasets: [])
          end.to raise_exception(
            GDAL::Error, "nSrcCount != 1"
          )
        end
      end
    end

    context "when dst_dataset used" do
      let(:dst_dataset) do
        OGR::Driver.by_name("GeoJSON").create_data_source("/vsimem/test-#{SecureRandom.uuid}.geojson")
      end
      after { dst_dataset.close }

      context "when no options are provided" do
        it "returns dst_dataset with changes applied" do
          new_dataset = described_class.perform(dst_dataset: dst_dataset, src_datasets: [src_dataset])

          expect(new_dataset).to eq(dst_dataset)
          expect(new_dataset.driver.name).to eq("GeoJSON")
          expect(new_dataset.layer(0).geometry_type).to eq(:wkbPolygon)
        end
      end

      context "when options are provided" do
        it "returns dst_dataset with changes applied with options" do
          options = GDAL::Utils::VectorTranslate::Options.new(options: ["-nlt", "MULTIPOLYGON"])

          new_dataset = described_class.perform(
            dst_dataset: dst_dataset, src_datasets: [src_dataset], options: options
          )

          expect(new_dataset).to eq(dst_dataset)
          expect(new_dataset.driver.name).to eq("GeoJSON")
          expect(new_dataset.layer(0).geometry_type).to eq(:wkbMultiPolygon)
        end
      end

      context "when operation fails with GDAL internal exception" do
        it "raises exception" do
          options = GDAL::Utils::VectorTranslate::Options.new(options: ["-where", "test123"])

          expect do
            described_class.perform(dst_dataset: dst_dataset, src_datasets: [src_dataset], options: options)
          end.to raise_exception(
            GDAL::Error, "SetAttributeFilter(test123) on layer 'states' failed."
          )
        end
      end
    end
  end
end
