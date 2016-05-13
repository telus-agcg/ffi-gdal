require 'spec_helper'
require 'gdal'

RSpec.describe GDAL::Dataset do
  let(:file_path) do
    File.expand_path('../../../support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif', __dir__)
  end

  subject do
    described_class.open(file_path, 'r', false)
  end

  describe '#create_and_reproject_image' do
    let(:output_dir) { Dir.mktmpdir(File.basename(__FILE__, '.rb')) }
    let(:output_file) { File.join(output_dir, 'reprojected_image.tif') }
    let(:output_projection) { OGR::SpatialReference.new_from_epsg(3857).to_wkt }
    after { FileUtils.rm_rf(output_dir) if Dir.exist?(output_dir) }

    it 'creates a valid dataset' do
      subject.create_and_reproject_image(output_file, :GRA_NearestNeighbor, OGR::SpatialReference.new_from_epsg(3857).to_wkt, GDAL::Driver.by_name('GTiff'))

      dest_dataset = GDAL::Dataset.open(output_file, 'r')
      expect(dest_dataset.driver.short_name).to eq 'GTiff'
      expect(dest_dataset.projection).to match(/AUTHORITY\[\"EPSG\",\"3857\"\]/)
      expect(dest_dataset.raster_count).to eq(subject.raster_count)
    end
  end
end
