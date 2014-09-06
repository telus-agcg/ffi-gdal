require 'spec_helper'
require 'ffi-gdal'

FILES = Dir.glob('spec/support/images/osgeo/**/*.tif')

FILES.each do |file|
  describe 'Dataset Info' do
    subject do
      GDAL::Dataset.open(file, 'r')
    end

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

    describe '#metadata_domain_list' do
      it 'is an Array of Strings' do
        expect(subject.metadata_domain_list).to be_an Array

        subject.metadata_domain_list.each do |mdl|
          expect(mdl).to be_a String
        end
      end
    end

    describe '#metadata_for_domain' do
      context 'default domain' do
        it 'is a Hash' do
          expect(subject.metadata_for_domain).to be_a Hash
        end
      end
    end

    describe '#metadata_item' do
      context 'default domain' do
        context 'first item in metadata list' do
          it 'is a String' do
            unless subject.metadata_for_domain.empty?
              key = subject.metadata_for_domain.keys.first

              expect(subject.metadata_item(key)).to be_a String
            end
          end
        end
      end
    end

    describe '#all_metadata' do
      it 'is a Hash' do
        expect(subject.all_metadata).to be_a Hash
      end

      it 'has a DEFAULT key' do
        expect(subject.all_metadata[:DEFAULT]).to eq subject.metadata_for_domain
      end
    end

    describe '#description' do
      it 'is a String' do
        expect(subject.description).to be_a String
      end
    end

    describe '#description=' do
      context 'new description is a string' do
        around :example do |example|
          original_description = subject.description
          example.run
          subject.description = original_description
        end

        it 'sets the items description' do
          subject.description = 'a test description'
          expect(subject.description).to eq 'a test description'
        end
      end
    end

    describe '#null?' do
      it { is_expected.to_not be_null }
    end
  end
end
