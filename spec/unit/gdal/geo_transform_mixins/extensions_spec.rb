# frozen_string_literal: true

require 'spec_helper'
require 'gdal/geo_transform'
require 'gdal/geo_transform_mixins/extensions'

RSpec.describe GDAL::GeoTransformMixins::Extensions do
  let(:subject_class) do
    Class.new do |c|
      c.send :include, GDAL::GeoTransformMixins::Extensions
      c
    end
  end

  subject do
    gt = GDAL::GeoTransform.new
    gt.x_origin = 90
    gt.y_origin = -90
    gt.pixel_width = 0
    gt.pixel_height = 0

    gt
  end

  describe '.new_from_envelope' do
    let(:envelope) { instance_double 'OGR::Envelope' }

    it 'builds a new GeoTransform using the extent values from the Envelope' do
      expect(envelope).to receive(:x_min).and_return(90)
      expect(envelope).to receive(:y_min).and_return(-90)
      expect(envelope).to receive(:x_size).and_return(1.5)
      expect(envelope).to receive(:y_size).and_return(0.5)

      gt = subject_class.new_from_envelope(envelope, 300, 200)
      expect(gt).to be_a_instance_of(GDAL::GeoTransform)
      expect(gt.x_origin).to eq(90)
      expect(gt.y_origin).to eq(-90)
      expect(gt.x_rotation).to eq(0)
      expect(gt.y_rotation).to eq(0)
      expect(gt.pixel_width).to eq(0.005)
      expect(gt.pixel_height).to eq(0.0025)
    end
  end

  describe '#world_to_pixel' do
    context 'non-zero pixel width and height' do
      subject do
        gt = GDAL::GeoTransform.new
        gt.x_origin = 90
        gt.y_origin = -90
        gt.pixel_width = 1
        gt.pixel_height = 0.5

        gt
      end

      it 'returns a pixel: and line: Hash with according values' do
        expect(subject.world_to_pixel(0, 0)).to eq(pixel: -90, line: -180)
      end
    end

    context 'zero pixel width and height' do
      it 'returns a pixel: and line: Hash with according values' do
        expect { subject.world_to_pixel(0, 0) }.
          to raise_exception GDAL::InvalidGeoTransform
      end
    end
  end
end
