require 'spec_helper'
require 'support/integration_help'
require 'ffi-gdal'

TIF_FILES.each do |file|
  describe 'Driver Info' do
    subject do
      GDAL::Driver.new(file_path: file)
    end

    it_behaves_like 'a major object'

    describe '.driver_count' do
      it 'is a non-zero Integer' do
        expect(GDAL::Driver.driver_count).to be_a Fixnum
        expect(GDAL::Driver.driver_count).to be > 0
      end
    end

    describe '#c_pointer' do
      it 'is a FFI::Pointer to the actual C driver' do
        expect(subject.c_pointer).to be_a FFI::Pointer
        expect(subject.c_pointer).to_not be_null
      end
    end

    describe '#short_name' do
      it 'is GTiff' do
        expect(subject.short_name).to eq 'GTiff'
      end
    end

    describe '#long_name' do
      it 'is GeoTiff' do
        expect(subject.long_name).to eq 'GeoTIFF'
      end
    end

    describe '#help_topic' do
      it 'is http://gdal.org/frmt_gtiff.html' do
        expect(subject.help_topic).to eq 'http://gdal.org/frmt_gtiff.html'
      end
    end

    describe '#creation_option_list' do
      it 'is an Array of Hashes' do
        expect(subject.creation_option_list).to be_an Array
        expect(subject.creation_option_list.first).to be_a Hash
      end
    end

    describe '#copy_dataset_files' do
      pending
    end

    describe '#create_dataset' do
      pending
    end
  end
end
