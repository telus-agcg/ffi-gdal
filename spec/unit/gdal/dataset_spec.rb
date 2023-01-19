# frozen_string_literal: true

require "gdal/dataset"

RSpec.describe GDAL::Dataset do
  include_context "A .tif Dataset"
  it_behaves_like "a major object"

  describe "#access_flag" do
    it "returns the flag that was used to open the dataset" do
      expect(subject.access_flag).to eq :GA_ReadOnly
    end
  end

  describe "#file_list" do
    it "returns an array that includes the file that represents the dataset" do
      expect(subject.file_list).to be_an Array
      expect(subject.file_list).to include(file_path)
    end
  end

  describe "#flush_cache" do
    it "returns nil" do
      expect(subject.flush_cache).to be_nil
    end
  end
end
