# frozen_string_literal: true

require 'json'

RSpec.shared_examples 'a GeoJSON exporter' do
  describe '#to_geo_json' do
    it 'returns some String data' do
      geo_json = subject.to_geo_json
      expect(geo_json).to be_a String
      expect(geo_json).to_not be_empty
    end
  end

  describe '#to_geo_json_ex' do
    context 'no options' do
      it 'returns some String data' do
        geo_json = subject.to_geo_json_ex
        expect(geo_json).to be_a String
        expect(geo_json).to_not be_empty
      end
    end

    context 'with :coordinate_precision' do
      it 'returns some String data' do
        geo_json = subject.to_geo_json_ex(coordinate_precision: 1)
        expect(geo_json).to be_a String
        expect(geo_json).to_not be_empty
      end
    end

    context 'with :significant_figures' do
      it 'returns some String data' do
        geo_json = subject.to_geo_json_ex(significant_figures: 10)
        expect(geo_json).to be_a String
        expect(geo_json).to_not be_empty
      end
    end
  end
end
