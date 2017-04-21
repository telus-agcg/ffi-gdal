# frozen_string_literal: true

require 'spec_helper'
require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '.projection_methods' do
    context 'strip underscores' do
      subject { described_class.projection_methods(true) }

      it 'returns an Array of Strings' do
        expect(subject).to be_an Array
        expect(subject.first).to be_a String
      end

      it 'has Strings with no underscores' do
        expect(subject).to satisfy { |v| !v.include?('_') }
      end
    end

    context 'not strip underscores' do
      subject { described_class.projection_methods(false) }

      it 'returns an Array of Strings' do
        expect(subject).to be_an Array
        expect(subject.first).to be_a String
      end

      it 'has Strings with underscores' do
        expect(subject).to satisfy { |v| !v.include?(' ') }
      end
    end
  end

  describe '#copy_geog_cs_from' do
    let(:other_srs) { OGR::SpatialReference.new_from_epsg(4326) }

    it 'copies the info over' do
      expect(subject.to_wkt).to be_empty
      subject.copy_geog_cs_from(other_srs)
      expect(subject.to_wkt).to eq other_srs.to_wkt
    end
  end
end
