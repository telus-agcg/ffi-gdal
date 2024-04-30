# frozen_string_literal: true

require "spec_helper"
require "gdal"
require "ogr"

RSpec.describe GDAL::Utils::Grid do
  let(:src_dataset_path) do
    path = "../../../../spec/support/shapefiles/states_21basic/states.shp"
    File.expand_path(path, __dir__)
  end

  let(:src_dataset) { OGR::DataSource.open(src_dataset_path, "r") }
  after { src_dataset.close }

  describe ".perform" do
    let(:new_dataset_path) { "/vsimem/test-#{SecureRandom.uuid}.tif" }

    context "when no options are provided" do
      it "returns new dataset" do
        new_dataset = described_class.perform(dst_dataset_path: new_dataset_path, src_dataset: src_dataset)

        expect(new_dataset).to be_a(GDAL::Dataset)

        new_dataset.close
      end
    end

    context "when options are provided" do
      it "returns new dataset with options applied" do
        options = GDAL::Utils::Grid::Options.new(options: ["-outsize", "10", "10"])

        new_dataset = described_class.perform(
          dst_dataset_path: new_dataset_path, src_dataset: src_dataset, options: options
        )

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("Size is 10, 10")

        new_dataset.close
      end

      it "returns new dataset in block" do
        options = GDAL::Utils::Grid::Options.new(options: ["-outsize", "10", "10"])

        described_class.perform(
          dst_dataset_path: new_dataset_path,
          src_dataset: src_dataset,
          options: options
        ) do |new_dataset|
          expect(new_dataset).to be_a(GDAL::Dataset)
          expect(GDAL::Utils::Info.perform(dataset: new_dataset)).to include("Size is 10, 10")
        end
      end
    end

    context "when operation fails with GDAL internal exception" do
      it "raises exception" do
        options = GDAL::Utils::Grid::Options.new(options: ["-of", "UnknownFormat123"])

        expect do
          described_class.perform(dst_dataset_path: new_dataset_path, src_dataset: src_dataset, options: options)
        end.to raise_exception(
          GDAL::Error, /Output driver `UnknownFormat123' not recognised/
        )
      end
    end
  end
end
