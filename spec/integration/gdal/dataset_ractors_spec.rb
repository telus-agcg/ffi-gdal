# frozen_string_literal: true

require "ffi-gdal"
require "gdal"
require "gdal/dataset"

RSpec.describe "Dataset with Ractors", type: :integration do
  let(:tiff1) do
    path = "../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
    File.expand_path(path, __dir__)
  end
  let(:tiff2) do
    path = "../../../spec/support/images/123.tiff"
    File.expand_path(path, __dir__)
  end
  let(:dataset_paths) { [tiff1, tiff2] }

  if Object.const_defined?("Ractor")
    it "succesfully open datasets in Ractor threads" do
      ractors = dataset_paths.map do |file_path|
        Ractor.new(file_path) do |file_path_r|
          GDAL::Dataset.open(file_path_r, "r", shared: false)
        end
      end

      datasets = ractors.map(&:take)

      expect(datasets.size).to eq(2)
      expect(datasets.map(&:description)).to contain_exactly(tiff1, tiff2)

      datasets.each(&:close)
    end
  end
end
