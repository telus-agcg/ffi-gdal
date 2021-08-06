# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  subject do
    described_class.new.import_from_epsg(3819)
  end

  describe '#copy_geog_cs_from' do
    let(:other_srs) { OGR::SpatialReference.new.import_from_epsg(4326) }

    it 'copies the info over' do
      subject.copy_geog_cs_from(other_srs)
      expect(subject.to_wkt).to eq other_srs.to_wkt
    end
  end
end
