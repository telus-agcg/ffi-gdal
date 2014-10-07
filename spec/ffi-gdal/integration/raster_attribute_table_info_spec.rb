require 'spec_helper'
require 'support/integration_help'
require 'ffi-gdal'


TIF_FILES.each do |file|
  dataset =  GDAL::Dataset.open(file, 'r')

  describe 'Raster Band Info' do
    after :all do
      dataset.close
    end

    subject do
      band = dataset.raster_band(1)
      band.default_raster_attribute_table
    end

    describe '#column_count' do
      pending 'Test files with RATs'
    end
  end
end
