require 'spec_helper'

RSpec.describe OGR::MultiLineString do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) do
      OGR::LineString.new
    end
  end
end
