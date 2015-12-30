require 'spec_helper'
require 'ffi-gdal'

RSpec.describe 'Raster Band Info', type: :integration do
  let(:dataset) { GDAL::Dataset.open(file, 'r') }
  after { dataset.close }

  subject do
    band = dataset.raster_band(1)
    band.default_raster_attribute_table
  end

  describe '#column_count' do
    pending 'Test files with RATs'
  end
end
