# frozen_string_literal: true

require "gdal/dataset"

RSpec.describe GDAL::Dataset do
  include_context "A .tif Dataset"

  describe "#driver" do
    it "returns the driver that was used to open the dataset" do
      expect(subject.driver).to be_a GDAL::Driver
    end
  end

  describe "#projection" do
    let(:expected_wkt) do
      'GEOGCS["unknown",DATUM["unknown",SPHEROID["Bessel 1841",' \
        '6377397.155,299.1528128000033,AUTHORITY["EPSG","7004"]],' \
        "TOWGS84[598.1,73.7,418.2,0.202,0.045,-2.455,6.7]]," \
        'PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]]'
    end

    it "returns the projection string" do
      expect(subject.projection).to start_with 'GEOGCS["unknown",DATUM["'
    end
  end

  describe "#projection=" do
    context "good projection" do
      it "sets the new projection" do
        proj = subject.projection
        expect(subject.projection = proj).to eq proj
        expect(subject.projection).to eq proj
      end
    end

    context "bad projection" do
      it do
        expect { subject.projection = "meow" }.to raise_exception(GDAL::Error)
      end
    end
  end

  describe "#geo_transform" do
    it "returns a GDAL::GeoTransform" do
      expect(subject.geo_transform).to be_a GDAL::GeoTransform
    end
  end
end
