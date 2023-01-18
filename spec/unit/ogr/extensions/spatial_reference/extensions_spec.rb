# frozen_string_literal: true

require "ogr/extensions/spatial_reference/extensions"

RSpec.describe OGR::SpatialReference::Extensions do
  # Not sure why yet, but it seems I can only do angular unit setting with
  # certain projections; 4326 is one of them.
  describe "#angular_units= + #angular_units" do
    subject { OGR::SpatialReference.new.import_from_epsg(4326) }

    context "using a known label" do
      it "sets the new label and value" do
        subject.angular_units = :radian
        expect(subject.angular_units).to eq(unit_name: "radian", value: 1.0)
      end
    end

    context "using an unknown label and value" do
      it "raises a NameError" do
        expect { subject.angular_units = "Darrels" }.to raise_exception NameError
      end
    end
  end

  # Not sure why yet, but it seems I can only do linear unit setting with
  # certain projections; 4333 is one of them.
  describe "#linear_units= + #linear_units" do
    subject { OGR::SpatialReference.new.import_from_epsg(4333) }

    context "using a known label" do
      it "sets the new label and value" do
        subject.linear_units = :foot
        expect(subject.linear_units).to eq(unit_name: "Foot (International)", value: 0.3048)
      end
    end

    context "using an unknown label and value" do
      it "raises a NameError" do
        expect { subject.linear_units = "Darrels" }.to raise_exception NameError
      end
    end
  end
end
