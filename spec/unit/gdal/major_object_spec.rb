# frozen_string_literal: true

require "gdal/major_object"

RSpec.describe GDAL::MajorObject do
  subject { band.extend(described_class) }

  let(:driver) { GDAL::Driver.by_name("GTiff") }
  let(:dataset) { driver.create_dataset("/vsimem/test-#{SecureRandom.uuid}.tif", 1, 1) }
  let(:band) { dataset.raster_band(1) }
  after { dataset.close }

  describe "#description" do
    context "when the object has no description" do
      it "returns an empty string" do
        expect(subject.description).to eq("")
      end
    end

    context "when the object has a description" do
      before { subject.description = "This is a description" }

      it "returns the description of the object" do
        expect(subject.description).to eq("This is a description")
      end
    end
  end

  describe "#description=" do
    it "sets the description of the object" do
      expect(subject.description).to eq("")
      subject.description = "This is a description"
      expect(subject.description).to eq("This is a description")
    end
  end
end
