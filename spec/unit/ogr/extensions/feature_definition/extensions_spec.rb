# frozen_string_literal: true

require "ogr/extensions/feature_definition/extensions"

RSpec.describe OGR::FeatureDefinition::Extensions do
  subject(:feature_definition) do
    fd = OGR::FeatureDefinition.new("spec feature definition")
    fd.geometry_type = :wkbMultiPolygon
    fd
  end

  describe "#field_definitions" do
    it "returns an array of size field_count" do
      expect(subject.field_definitions).to be_an Array
      expect(subject.field_definitions.size).to eq subject.field_count
    end
  end

  describe "#field_definition_by_name" do
    context "field with name does not exist" do
      it "returns nil" do
        expect(subject.field_definition_by_name("asdfasdfasdf")).to be_nil
      end
    end
  end

  describe "#geometry_field_definition_by_name" do
    context "field with name does not exist" do
      it "returns nil" do
        subject.geometry_field_definition(0).name
        expect(subject.geometry_field_definition_by_name("asdfasdf")).to be_nil
      end
    end

    context "field with name exists" do
      it "returns the OGR::GeometryFieldDefinition" do
        name = subject.geometry_field_definition(0).name
        expect(subject.geometry_field_definition_by_name(name))
          .to be_a OGR::GeometryFieldDefinition
      end
    end
  end
end
