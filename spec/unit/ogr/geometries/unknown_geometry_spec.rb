require 'spec_helper'

RSpec.describe OGR::UnknownGeometry do
  it 'can be created from a pointer to a geometry' do
    geom_ptr = FFI::GDAL.OGR_G_CreateGeometry(:wkbPoint)
    geom = described_class.new(geom_ptr)
    expect(geom).to be_a OGR::UnknownGeometry
  end
end
