require 'spec_helper'
require 'support/integration_help'
require 'ffi-gdal'

TIF_FILES.each do |file|
  describe 'Dataset Info' do
    subject do
      GDAL::Dataset.open(file, 'r')
    end

    it_behaves_like 'a major object'

    describe '#open?' do
      it { is_expected.to be_open }
    end

    describe '#driver' do
      it 'is a GDAL::Driver' do
        expect(subject.driver).to be_a GDAL::Driver
      end
    end

    describe '#file_list' do
      it 'is a non-empty Array' do
        expect(subject.file_list).to be_an Array
      end

      it 'contains the file name' do
        expect(subject.file_list).to include(File.expand_path(file))
      end
    end

    describe '#raster_x_size' do
      it 'is a Fixnum' do
        expect(subject.raster_x_size).to be_a Fixnum
      end
    end

    describe '#raster_y_size' do
      it 'is a Fixnum' do
        expect(subject.raster_y_size).to be_a Fixnum
      end
    end

    describe '#raster_count' do
      it 'is a Fixnum' do
        expect(subject.raster_count).to be_a Fixnum
      end
    end

    describe '#raster_band' do
      it 'each band is a GDAL::RasterBand' do
        1.upto(subject.raster_count) do |i|
          expect(subject.raster_band(i)).to be_a GDAL::RasterBand
        end
      end
    end

    describe '#projection_definition' do
      it 'is a String' do
        expect(subject.projection_definition).to be_a String
      end
    end

    describe '#access_flag' do
      it 'is GA_ReadOnly' do
        expect(subject.access_flag).to be :GA_ReadOnly
      end
    end

    describe '#geo_transform' do
      it 'is a GDAL::GeoTransform' do
        expect(subject.geo_transform).to be_a GDAL::GeoTransform
      end
    end

    describe '#gcp_count' do
      it 'is a Fixnum' do
        expect(subject.gcp_count).to be_a Fixnum
      end
    end

    describe '#gcp_projection' do
      it 'is a String' do
        expect(subject.gcp_projection).to be_a String
      end
    end

    describe '#gcps' do
      it 'is a GDALGCP' do
        expect(subject.gcps).to be_a FFI::GDAL::GDALGCP
      end
    end
  end
end
