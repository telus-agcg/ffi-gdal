# frozen_string_literal: true

require "spec_helper"
require "gdal"
require "ogr"

RSpec.describe GDAL::Utils::Footprint do
  let(:src_dataset) { GDAL::Dataset.open(src_dataset_path, "r") }

  after { src_dataset.close }

  describe ".perform" do
    let(:dst_dataset_path) { "/vsimem/test-#{SecureRandom.uuid}.geojson" }

    context "when options are provided for valid tiff" do
      let(:expected_wkt) do
        "MULTIPOLYGON (((-117.641721475391 33.9438318680271,-117.641718643113 33.6649697255499," \
          "-117.308745395101 33.664972062262,-117.308748199413 33.9438342216806," \
          "-117.641721475391 33.9438318680271)))"
      end

      let(:src_dataset_path) do
        path = "../../../../spec/support/images/osgeo/geotiff/gdal_eg/cea.tif"
        File.expand_path(path, __dir__)
      end

      it "returns new dataset with options applied" do
        options = GDAL::Utils::Footprint::Options.new(options: ["-t_srs", "EPSG:4326"])

        described_class.perform(
          dst_dataset_path: dst_dataset_path,
          src_dataset: src_dataset,
          options: options
        ) do |new_dataset|
          expect(new_dataset).to be_a(OGR::DataSource)
          expect(new_dataset.layer(0).feature_count).to eq(1)
          expect(new_dataset.layer(0).feature(0).geometry.to_wkt).to eq(expected_wkt)
        end
      end
    end

    context "when options are provided for empty tiff" do
      let(:src_dataset_path) do
        path = "../../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
        File.expand_path(path, __dir__)
      end

      it "returns new dataset with options applied" do
        options = GDAL::Utils::Footprint::Options.new(options: ["-t_srs", "EPSG:4326"])

        new_dataset = described_class.perform(
          dst_dataset_path: dst_dataset_path, src_dataset: src_dataset, options: options
        )

        expect(new_dataset.layer(0).feature_count).to eq(0)

        new_dataset.close
      end
    end
  end
end
