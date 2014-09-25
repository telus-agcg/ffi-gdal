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
      dataset.geo_transform
    end

    describe '#x_origin' do
      it 'is a Float' do
        expect(subject.x_origin).to be_a Float
      end
    end

    describe '#y_origin' do
      it 'is a Float' do
        expect(subject.y_origin).to be_a Float
      end
    end

    describe '#pixel_width' do
      it 'is a Float' do
        expect(subject.pixel_width).to be_a Float
      end
    end

    describe '#x_rotation' do
      it 'is a Float' do
        expect(subject.x_rotation).to be_a Float
      end
    end

    describe '#y_rotation' do
      it 'is a Float' do
        expect(subject.y_rotation).to be_a Float
      end
    end

    describe '#pixel_height' do
      it 'is a Float' do
        expect(subject.pixel_height).to be_a Float
      end
    end

    describe '#x_projection' do
      it 'is a Float' do
        expect(subject.x_projection(0, 0)).to be_a Float
      end
    end

    describe '#y_projection' do
      it 'is a Float' do
        expect(subject.y_projection(0, 0)).to be_a Float
      end
    end
  end
end
