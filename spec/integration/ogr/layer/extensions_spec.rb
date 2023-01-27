# frozen_string_literal: true

require "ogr/extensions/layer/extensions"

RSpec.describe "OGR::Layer::Extensions" do
  let(:data_source) do
    OGR::DataSource.open("spec/support/shapefiles/states_21basic/states.shp", "r")
  end

  let(:layer0) do
    data_source.layer(0)
  end

  subject do
    layer0
  end

  describe "#features" do
    subject { layer0.features }
    it { is_expected.to be_an Array }
    specify { expect(subject.first).to be_a OGR::Feature }
    specify { expect(subject.size).to eq layer0.feature_count }
  end

  describe "#geometry_from_extent" do
    it "is a Polygon" do
      geometry = subject.geometry_from_extent
      expect(geometry).to be_a OGR::Polygon
    end
  end
end
